#pragma rtGlobals=1		// Use modern global access method.

//*******************  K_FRAPcalcV9i.ipf  ********************************************
// Author:	Kota Miura

// How To Use: (rough)
// 1. import data (becareful of the data format!!)
// 2. set the bleaching point.
// 3. do the calculation.

// * Copyright © 2005-2010 Kota Miura
// * License: GPL 2
// *    
// * This program is free software; you can redistribute it and/or
// * modify it under the terms of the GNU General Public License 2
// * as published by the Free Software Foundation.
// *
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *   
// * You should have received a copy of the GNU General Public License 
// * along with this program.  If not, see <http://www.gnu.org/licenses/>.


// -- for previous history, see bottom
//050714-16	added Leica data importing functions; Phair (2004) "Double Normalization", residual view in graph
//			Normalization process is different in these two cases. 
//050725		added leica data importing with 4th ROI (reference within cell)
//050803	ver7b. modified leica data importing. Sharing data in two different types of normalization. Dynamic Menu
//050804		added GapRatio calculation by AllCell intensity changes. original GapRatio calculatin by background estimation was modified.
//			 when fitting background decay, y0 is now holded to 0. 
//050808		Option for adjusting background fitting range; fitting for the background in negative value. 
//050810		K_estGapRatioFromOrigin(flatback)
//050811		Integrated Diffusion and Phair's Double Normalization into K_FrapCalcCore()
//			Integrated all types of Normalization to K_FrapCalcNormalizeCurves(FitPara_wave,normalized)
//			"Back Multiplly" method created
//			Phair's method is also possible with none-all cell data (only cell part reference)
//050814	calculate gammaQ; use stdev during prebleach FRAP for measurement error. Limit fitting to certain time points
//060803 leica importing funciton modified for single channels
//070305 JP, WaveMetrics: Made CurveFit ranges compatible with Igor 6. Added /K=1 to NewPanel.
//070328 changed the menu for Leica importing
//070827 ver 9a added Leica new file format importing (csv)
//		made K_SoumpasisHalfLife2(fitwave,amplitude) for calculateing Half max. Previous one had problem when point 1 is larger than 0.5
//		made edition changes for the texts in the graph (Half max value added to diffusion fittings)
//071030 ver9b added 	K_HalfLifeFromDoubleExpEst. Extrapolate double exponential fitting and get proper half Max time. 	
//080312 ver9c Popmenu ""value=#" problem: (report from Mark Kwaaitaal with IgorPro6.03b)
//	PopupMenu popup1,value=# G_MethodList	
//	--> changed to: PopupMenu popup1,value=# "G_MethodList" (2 cases of such). in IgorPro 6.0, global variable cannot be used for the popmenu, only quoted string or string expression function
//	http://www.wavemetrics.com/search/viewmlid.php?mid=16136
//080624 Importing: Ioannis format
//080724 ver9e Importing: Moritz Olympus csv format			
//Procedure
//1. get the invTau of the Background decay by fitting to a normal Exponential equation (see the equation in the help file).
//2. get the initial guess for the FRAP curve by fitting it to a normal Exponential equation (same as 1)
//3. Using the valuse derived from above, fit the curve to the FRAP equation. rename to V9
//081007 ver9f Importing: Chieze @UTexas Excel 4 column
//		Fixed a bug that W_coef none-existence causes error in the first run. 
//081009 ver9f still, added tab delimited text file importer
//081210 ver9g	- bugs on double exponential fitting with Halfmax-time calculation with extrapolation was fixed. 
//				- double exponential fitting equation was changed from dblexp to dblexpX0offset, following recommendation of wavemetrics.
//091026 ver9h	- allows showing fitting paprameters in plot with mobile fraction <1.5. rather than <1.0 (Christian 's request)
//				checked gammaQ usage. it's OK, but when pre-bleach fluctuation is high Q tends to be too good (1.0)
//091201 ver9i	- Batch Processing funciton added. (request from Noriko Goldsimth)
//100203, 100204, 100210 ver9j	- Batch Processing funciton, extended for averaging: 
//			K_FrapCalcCore() was modified so that averaged curve could be fitted as well. 
//			Since averaged curve does not have original normalizaton process is not required 
//			but then several parameters which are calculated during normalization will be missing. 
//			For this, flag "G_doAveraged "was added (getAverageGApRatio(Gfilelist) ). 
//			Gap Ratio is calculated by averaging individual.  
//			Fitting of averaged curve is done with actual standard deviation. finally, BatchFitting() is added with BatchAverageAndFit() in its last line. 
//100427 ver9k added importing set Zeiss time-frap-ref-base and time-frap-base-ref
//100428          added batch processing, then debugging: cellpart gap ratio debugged. 

//FittingParameterWave
//
//0:fitmethod
//1:normalized
//2:width
//3:background exists
//4:flatback
//5:BackGround_Timpoint0
//6:GapRatio
//
//7:I_prebleachBack
//8:I_prebleachFrap
//9:I_bleachfrap
//
//10:backamplitude
//11:backtau
//12:backy0
//
//15:WholeCell_Exists
//16:Ref_Exists
//17:Base_Exists

// fit method:
// 0: Rainer - single exponential
// 1: BackGroundMultiply-single exponential 
// 2: BackGroundMultiply-double exponential
// 3:
// 4: 
// 5: 
// 6: Double Normalization, single exponential
// 7: Double Normalization, double exponential
// 8: Double Normalization Ellenberg
// 9:Double Normalization Soumpasis


//data set types
//+ 1111 () 0 FRAP + Whole Cell +  Reference + Base
//+ 1101 () 1 FRAP + Whole Cell + Base
//- 1011 () 2 FRAP +  Reference + Base
//- 1100 () 3 FRAP + Whole Cell 
//+ 1010 () 4 FRAP +  Reference
//- 1001 () 5 FRAP + Base
//+ 1000 () 6 FRAP 

Menu "Frap Calc", dynamic
	submenu "Import Zeiss data..."
		"Import Data 3: Time - Frap [not for science]..", K_importFrapTxtData(2)
		"Import Data 3: Time - Frap - CellPart..", K_importFrapTxtData(0)
		"Import Data 3: Time - CellPart - Frap..", K_importFrapTxtData(1)
		"Import Data 8: Time - Frap - 6 CellPart..",K_importFrapTxtDataV2()
		"-"
		"Import Data 4: Time - Frap - All Cell - Base..", K_importFrapTxtData(3)	//050802
		"Import Data 4: Time - Frap - Base - All Cell..", K_importFrapTxtData(4)	//050802
		"-"
		"Import Data 4: Time - Frap - CellPart - Base..", K_importFrapTxtData(5)	//050802
		"Import Data 4: Time - Frap - Base - CellPart..", K_importFrapTxtData(6)	//050802

	end
	submenu "Import Leica data..."
		submenu "Single Channel data"
			"Import FRAP - AllCell - Base 9...",K_importFrapTxtData(20)	
			"Import FRAP - AllCell - Base - Cell Part 12...",K_importFrapTxtData(25)	//050803	 imports channel 2 from dual channel					
			"-"
			"Import FRAP - CellPart - Base - AllCell 5 CSV...",K_importFrapTxtData(30)	//070824	 imports channel 2 csv data from dual channel					
		end
		submenu "Double Channel Data"
			submenu "Ch1 is frap"
				"Import Ch1 Frap - AllCell - Base 12...",K_importFrapTxtData(21)
				"Import Ch1 Frap - AllCell - Base - cellPart 16...",K_importFrapTxtData(22)	//060803	 imports channel 1 from dual channel	
				"Import Ch1 Frap - cellpart1 - cellPart2 - AllCell - Base 20...",K_importFrapTxtData(26)	//080619	for Ioannis	
			end
			submenu "Ch2 is frap"
			"Import Ch2 Frap - AllCell - Base 12...",K_importFrapTxtData(24)
	//		"Import Data Ch1 Frap - AllCell - Base - Cell Part 16...",K_importFrapTxtData(22)	//050725
	//		"Import Data Ch2 Frap - AllCell - Base - Cell Part 20...",K_importFrapTxtData(23)	//050725
			"Import Ch2 Frap - AllCell - Base - Cell Part 16...",K_importFrapTxtData(23)	//050803	 imports channel 2 from dual channel		
			end
		end
	end
	submenu "Import Olympus data..."
		submenu "Single Channel Data"
			"Import FRAP - CellPart - Base - AllCell 5 CSV...", K_importFrapTxtData(40) //080724 Moritz
		end
	end
	submenu "Import Excel data..."
		submenu "Single Channel Data"
			"Import Time- FRAP  - AllCell - Base 4 xls...", K_importFrapTxtData(50) //081006 Chiez
		end
	end
	submenu "Import Tab Delimited Textfile data..."
		submenu "Single Channel Data"
			"Import Time- FRAP  - AllCell - Base 4 txt...", K_importFrapTxtData(60) //081009 Chiez
		end
	end
	"-"
	"Fit Panel...",K_FrapFitPanel()
//	"weightening OFF", K_setWeightening(0)
//	"weightening ON", K_setWeightening(1)
	"-"
	"Set Bleach Point..",K_setBleachPoint()
	//"Calculate Tau Basic",K_FrapCalc()
	//"Calculate Tau",K_FrapCalc2()
	"-"
	"Prepare Layout",K_DOprepareLayout()
	"-"
	"Export Results as a Text File...",K_ExportResults()
	"Export Data as a Text File...",K_ExportData()
	"Export Both as Text files...",K_ExportData_Results()
	"-"
	submenu "Heiko Tools"
		//"Heiko Special 1",K_FrapAnalDoMultiAtOnceV2(0)		//method=0: fit to "FRAP"  changed to V2 040318	
		"Heiko Special",K_FrapAnalDoMultiAtOnceV2(1)		//method=1: fit to "FRAP4"
		"-"
		"Draw Average Curve...",K_MultiAnalysisAveFit(0)
		"Append Average Curve...",K_MultiAnalysisAveFit(1)
		"-"
		"Heiko Special Multi Data and Results Saver",K_MultipleExportData_Results()
		"Heiko Special Export Reuslts Summary...",K_ExportSummaryData()
	end
	"-"
	submenu "Batch Processing --beta--"
		"Batch Import Zeiss Time - Frap - AllCell - Base", LoadAllFrapFiles("", 3)
		"Batch Import Zeiss Time - Frap - CellPart - Base", LoadAllFrapFiles("", 5)
		"-"
		"Batch Fit ",BatchFitting()
	end 

END

//********************************************************************************************************************

Function K_CheckAllGV()
	K_checkG_BleachPoint()
	K_checkG_exp_Name()
	K_checkFit_method()
	K_checkWeight()
	checkG_CurrentExp()
	checkG_currentMethod()
	checkG_currentWidth()
	checkG_currentNormalized()
	checkG_dataForm()
	checkG_BackStartPnt()
	checkG_ExpoRainer()
	checkG_ExpoBackMult()
	checkG_ExpoPhair()	
	K_checkG_currentMethodPopMenu()
	K_checkG_checkLimitRange()
	checkG_sdevwexists()	//100204 standard deviation curve from measurements
	 checkG_doAveraged()	//100204
END



Function K_setBleachPoint()		//040304		for setting the bleach point.
	NVAR/z G_BleachPoint
	if( NVAR_Exists(G_BleachPoint)==0)
		print "G_BleachPoint created.."
		Variable/G G_BleachPoint=10
	endif
	Variable BleachPoint=G_BleachPoint
	prompt	BleachPoint, "Bleach Point? ('point' starts with 0)"
	Doprompt "Set Bleach Point:",BleachPoint
	G_BleachPoint=BleachPoint  
end

Function K_checkG_BleachPoint()//K_checkGV()		//040317
	NVAR/z G_BleachPoint
	if( NVAR_Exists(G_BleachPoint)==0)
		Variable/G G_BleachPoint=10
		printf "G_BleachPoint created: timepoint %f",G_BleachPoint
	endif
end


function K_checkG_exp_Name()
	SVAR/z G_exp_Name
	if( SVAR_Exists(G_exp_Name)==0)
		string/g G_exp_Name="tempname"
	endif
end

function K_checkFit_method()
	NVAR/z Fit_method
	if( NVAR_Exists(Fit_method)==0)
		Variable/G Fit_method=0
	endif
end

function K_checkWeight()
	NVAR/z G_Weight
	if( NVAR_Exists(G_Weight)==0)
		Variable/G G_Weight=0
		print "G_Weight created"
		Variable/G G_WeightLowPnt=0
		Variable/G G_WeightHighPnt=10
	endif

end

Function K_setWeightening(switching)
	variable switching
	NVAR/z G_Weight,G_WeightLowPnt,G_WeightHighPnt
	K_checkWeight()
	G_Weight=switching
end

function checkG_CurrentExp()
	SVAR/z G_CurrentExp
	if( SVAR_Exists(G_CurrentExp)==0)
		String/G G_CurrentExp=stringfromlist(0,K_FrapListExperiments())
	endif
end

function checkG_currentMethod()
	NVAR/z G_currentMethod
	if( NVAR_Exists(G_currentMethod)==0)
		Variable/G G_currentMethod=0
	endif

end

function checkG_currentWidth()
	NVAR/z G_currentWidth
	if( NVAR_Exists(G_currentWidth)==0)
		Variable/G G_currentWidth=0
	endif

end

function checkG_currentNormalized()
	NVAR/z G_currentNormalized
	if( NVAR_Exists(G_currentNormalized)==0)
		Variable/G G_currentNormalized=0
	endif

end

//100204 if standard deviation of FRAP is available, then 1, otherwise 0 (normally, this value is 0)
function checkG_sdevwexists()
	NVAR/z G_sdevwexists
	if( NVAR_Exists(G_sdevwexists)==0)
		Variable/G G_sdevwexists=0
	endif

end

//100204 switch for fitting averaged curve
function checkG_doAveraged()
	NVAR/z G_doAveraged		//100204
	if( NVAR_Exists(G_doAveraged)==0)
		Variable/G G_doAveraged=0
	endif

end
	

//old -050809
//2 FRAP + Whole Cell +  Reference + Base
//1 FRAP + Whole Cell + Base
//3 FRAP +  Reference + Base
//4 FRAP + Whole Cell 
//0 FRAP +  Reference
//5 FRAP + Base
//6 FRAP

//new 050809-
//1111 () 0 FRAP + Whole Cell +  Reference + Base
//1101 () 1 FRAP + Whole Cell + Base
//1011 () 2 FRAP +  Reference + Base
//1100 () 3 FRAP + Whole Cell 
//1010 () 4 FRAP +  Reference
//1001 () 5 FRAP + Base
//1000 () 6 FRAP 

//050802
function checkG_dataForm()
	NVAR/z G_dataForm
	if( NVAR_Exists(G_dataForm)==0)
		Variable/G G_dataForm=0
	endif
end

//050802
// contains data form information for each and single experiment
function checkG_dataFormSpecific(expname)
	string expname
	string expname_dataform=expname+"_dataform"
	NVAR/z G_dataFormSpec=$expname_dataform
	if( NVAR_Exists(G_dataFormSpec)==0)
		Variable/G $expname_dataform
	endif
	return G_dataFormSpec
end

//050808
function checkG_BackStartPnt()
	NVAR/z G_BackStartPnt
	if( NVAR_Exists(G_BackStartPnt)==0)
		 K_checkG_BleachPoint()		
		NVAR/z G_BleachPoint
		Variable/G G_BackStartPnt=G_BleachPoint
	endif
end


//050809	for panel
function checkG_ExpoRainer()
	NVAR/z G_ExpoRainer
	if( NVAR_Exists(G_ExpoRainer)==0)
		Variable/G G_ExpoRainer=0
	endif
end

//050809	for panel
function checkG_ExpoBackMult()
	NVAR/z G_ExpoBackMult
	if( NVAR_Exists(G_ExpoBackMult)==0)
		Variable/G G_ExpoBackMult=0
	endif
end

//050809	for panel
function checkG_ExpoPhair()
	NVAR/z G_ExpoPhair
	if( NVAR_Exists(G_ExpoPhair)==0)
		Variable/G G_ExpoPhair=0
	endif
end

//050809 for panel
function K_expo_OneOutOfThree()
	checkG_ExpoRainer()
	NVAR/z G_ExpoRainer
	
	checkG_ExpoBackMult()
	NVAR/z G_ExpoBackMult

	checkG_ExpoPhair()
	NVAR/z G_ExpoPhair	

	if (G_ExpoRainer)
		G_ExpoBackMult=0
		G_ExpoPhair=0
	endif

	if (G_ExpoBackMult)
		G_ExpoRainer=0
		G_ExpoPhair=0
	endif

	if (G_ExpoPhair)
		G_ExpoBackMult=0
		G_ExpoRainer=0
	endif
end

Function K_checkG_currentMethodPopMenu()
	NVAR/z G_currentMethodPopMenu
	if (NVAR_exists(G_currentMethodPopMenu)==0)
		variable/g G_currentMethodPopMenu=1
	endif
END

Function K_checkG_checkLimitRange()
	NVAR/z G_checkLimitRange
	if (NVAR_exists(G_checkLimitRange)==0)
		variable/g G_checkLimitRange=0
	endif
END



//*** WINNAMES

Function/s K_GraphWinname(exp_name)//,method)
	string exp_name
	//variable method
	string window_name=exp_name+"_Frap_Fitting"//_mode"+num2str(method)
	return window_name
END
Function/s K_ResultsWinname(exp_name)//,method)
	string exp_name
	//variable method
	string window_name=exp_name+"_Frap_Fitting_results"//_mode"+num2str(method)
	return window_name
END
Function/s K_DataWinname(exp_name)//,method)
	string exp_name
	//variable method
	string window_name=exp_name+"_Frap_Data"//_mode"+num2str(method)
	return window_name 
END



//****************** UTILITIES**************************************************************************************
Function K_checkWindow(windowname)			// returns 0 if the window is not existing 0403118
	string windowname
	string ListGraph=WinList("*",";","WIN:3")
	variable NumberofGraphs=ItemsInList(ListGraph)
	variable i,j
	j=0
	string current_string
	for (i=0;i<NumberofGraphs;i+=1)
		current_string=StringFromList(i, ListGraph)
		if (cmpstr(current_string,windowname)==0)
			j+=1	
		endif
	endfor
	return j
END

Function/S K_nameFrapResultsWave(exp_name)
	string exp_name
	string newname=exp_name+"_FRAP_Results"
	//wave/z FRAP_Results
	//Duplicate/o FRAP_Results $newname
	return newname
END

Function K_checkTraceInGraph(windowname,tracename)
	string windowname,tracename
	string currentTraceList=TraceNameList(windowname, ";", 1 )	
	variable i
	variable checkflag=0
	for (i=0;i<itemsinlist(currentTraceList);i+=1)
		if (cmpstr(stringfromlist(i,currentTraceList),tracename)==0)
			checkflag=1
		endif
	endfor
	return checkflag
END

//for deriving HL with double exponential formula
function K_HalfLifeFromEst(ywave,xwave,amplitude,startpoint)
	wave ywave,xwave
	variable amplitude,startpoint
	variable i,halfpoint,halftime
	for (i=startpoint;i<(numpnts(ywave)-startpoint);i+=1)
		if ( (ywave[i]<=(0.5*(amplitude-ywave[startpoint])+ywave[startpoint])) && ((0.5*(amplitude-ywave[startpoint])+ywave[startpoint])<ywave[i+1]) )
			halfpoint=i
			break
		endif
	endfor
	halftime=(xwave[halfpoint]+xwave[halfpoint+1])/2
	return halftime
end

//071030
// when the estimation curve is too low at the right edge, the calculation will fail. 
// for this reason, extend the equation upto more  than 50 percent of the expected max value and determine the half max. 
//071211		Major Modifications: Use dblexpXoffset equation, rather than normal dblexp
//			Bugs in searching extrapolation value fixed. 
function K_HalfLifeFromDoubleExpEst(ywave,xwave,amplitude,startpoint, y0, ampA, ampB, tau1, tau2, x0offset)
	wave ywave,xwave
	variable amplitude,startpoint, y0, ampA, ampB, tau1, tau2, x0offset
	variable halfmax = y0 + (ampA + ampB) / 2
	wavestats/q ywave
	variable i,halfpoint,halftime
	variable Tmax, currentX, currentY, dt, pointnum, currentXmax
	if (V_max<halfmax)
		Tmax = 0
		currentXmax = xwave[numpnts(xwave)-1]
		currentX = currentXmax
		do
			currentX +=1
			//currentY=y0+ampA*(exp(-1*tau1*currentX))+ampB*(exp(-1*tau2*currentX))	//081210
			currentY=y0+ampA*exp(-(currentX-x0offset)*tau1)+ampB*exp(-(currentX-x0offset)*tau2)	//in 081210			
//		while (currentY>halfmaX)
		while (currentY<halfmaX)	//081210
		
		// calculate dt (time resolution) from xwave
		make/o/n=(numpnts(xwave)-1) tempSub
		tempsub[] = xwave[p+1] - xwave[p]
		wavestats/q tempsub
		pointnum = currentX/V_avg + startpoint		//081210
		dt = V_avg
		make/o/n=(pointnum) tempAdjustedWaveX, tempAdjustedWaveY
		tempAdjustedWaveX[] = (( p<numpnts(xwave)-1) ? xwave[p] : dt*p)
		//tempAdjustedWaveY[] = y0+ampA*(exp(-1*tau1*tempAdjustedWaveX[p]))+ampB*(exp(-1*tau2*tempAdjustedWaveX[p]))
		tempAdjustedWaveY[] = y0+ampA*exp(-(tempAdjustedWaveX[p]-x0offset)*tau1)+ampB*exp(-(tempAdjustedWaveX[p]-x0offset)*tau2)	//in 081210	
//		tempAdjustedWaveY[] -= halfmax	//commented out 081210	
//		wavestats/q tempAdjustedWaveY	//commented out 081210
//		halfpoint = V_minloc	//commented out 081210
//		halftime=xwave[V_minloc]	//commented out 081210

		// 081210, insted of the strategy above, do the half time search. 
		for (i=startpoint;i<(numpnts(tempAdjustedWaveY));i+=1)

			if ( (tempAdjustedWaveY[i]<=halfmax) && (halfmax<tempAdjustedWaveY[i+1]) )
				halfpoint=i
				break
			endif
		endfor
		halftime=(tempAdjustedWaveX[halfpoint]+tempAdjustedWaveX[halfpoint+1])/2
		// -- 081210
		
		print "Half Max ---> Extrapolated!"
		killwaves tempAdjustedWaveX, tempAdjustedWaveY
	else
//		for (i=startpoint;i<(numpnts(ywave)-startpoint);i+=1)
		for (i=startpoint;i<(numpnts(ywave));i+=1)

			if ( (ywave[i]<=halfmax) && (halfmax<ywave[i+1]) )
				halfpoint=i
				break
			endif
		endfor
		halftime=(xwave[halfpoint]+xwave[halfpoint+1])/2
	endif

	return halftime
end

function K_SoumpasisHalfLife(ywave,xwave,amplitude,startpoint,originalwave)
	wave ywave,xwave,originalwave
	variable amplitude,startpoint
	variable i,halfpoint,halftime
	print Amplitude
	for (i=startpoint;i<(numpnts(ywave)-startpoint);i+=1)
		if (numtype(ywave[i])==0)
			if ( (ywave[i]<=(0.5*(amplitude-originalwave[startpoint])+originalwave[startpoint])) && ((0.5*(amplitude-originalwave[startpoint])+originalwave[startpoint])<ywave[i+1]) )
				halfpoint=i
				break
			endif
		endif
	endfor
	halftime=(xwave[halfpoint]+xwave[halfpoint+1])/2
	return halftime
end

function K_SoumpasisHalfLife2(fitwave,amplitude)
	wave fitwave
	variable amplitude
	variable i,halfpoint,halftime

	Duplicate/o fitwave tempfitwaveX
	tempfitwaveX[] = x
	halftime = interp(amplitude/2, fitwave, tempfitwaveX)
	killwaves tempfitwaveX	
	return halftime
end

Function K_HLestimateFromInvTau(invTau)	//040818
	variable invTau
	variable HL=(ln(0.5)/invTau*-1)		//040303
	return HL
END

Function K_HLestimateFromInvTauOFFset(invTau,y0,amp)	//040818
	variable invTau,y0,amp
	variable HL=(ln(-1*y0/2/Amp)/invTau*-1)		//040303
	return HL
END

Function K_DiffCoefestimateFromHL(HL,width)	//040818
	variable HL,width
	//HL=(width^2)/12/pi/DifCoef	
	variable DifCoef=(width^2)/12/pi/HL
	return DifCoef 
END

Function K_DiffCoefestimateFromInvTau(invTau,y0,amp,width)	//040818
	variable invTau,y0,amp,width
	variable HL=K_HLestimateFromInvTauOFFset(invTau,y0,amp)
	variable DifCoef=K_DiffCoefestimateFromHL(HL,width)
	return DifCoef
END

Function/s K_ReturnMethods(fit_method)
	variable fit_method
	string method
	switch (fit_method)
		case 0:
			method="Rainer - single exponential"
			break
		case 1:
			method="BackGroundMultiply-single exponential "
			break
		case 2:
			method="BackGroundMultiply-double exponential"
			break
		case 6:
			method="Double Normalization, single exponential"
			break
		case 7:
			method="Double Normalization, double exponential"
			break
		case 8:
			method="Double Normalization Diffusion Ellenberg"
			break
		case 9:
			method="Double Normalization Diffusion Soumpasis"
			break
	endswitch
	return method	
end

///************************************************** IMPORT***********************************************************

function K_KillLoadedwaves(LoadedNum,SetNum)
	variable LoadedNum,SetNum
	variable RightLoad
	if (LoadedNum!=SetNum)
		string tempwavename
		variable i
		for (i=0;i<LoadedNum;i+=1)
			tempwavename="original"+num2str(i)
			killwaves $tempwavename
		endfor
		RightLoad=0
	else 
		RightLoad=1
	endif
	return RightLoad	
end

// order 0: Time - Frap - Reference
// order 1: Time - Reference - Frap
// order 2: Time - Frap
//		3  Time - Frap - All Cell - Base..", K_importFrapTxtData(3)	//050802
//	 	4  Time - Frap - Base - All Cell..", K_importFrapTxtData(4)	//050802
Function K_importFrapTxtData(order)
	Variable order
	String exp_name
	prompt exp_name, "Name of the Experiment?"
	Doprompt "name::",exp_name
	if (V_flag)
		Abort "Processing Canceled"
	endif	
	K_importFrapTxtDataCore(order, exp_name, "", "")		//091130
end

Function K_importFrapTxtDataCore(order, exp_name, pathname, filename)		//091130
	Variable order
	String exp_name
	String pathname
	String filename
		
	String Original_t,Original_Back,Original_Frap,Original_AllCell,Original_base
	String Original_Back2
//	Original_Back=exp_name+"_bkgOg"
	Original_Back=exp_name+"_bkgAv"	//040429 to make single reference data calculatable. actually is not the average.
	Original_Frap=exp_name+"_FRAP"
	Original_t=exp_name+"_t"
	Original_AllCell=exp_name+"_AllCell"	//050802
	Original_base=exp_name+"_base"	//050802	
	Original_Back2 = exp_name+"_bkgAv2"

	checkG_dataForm()
	NVAR/z G_dataForm
	
	checkG_dataFormSpecific(exp_name)		//050802
	string dataformSpecName=exp_name+"_dataform"		//050802
	Nvar/z GdataformSpec=$dataformSpecName		//050802
	
	if (order<20) 	//zeiss format
		if ((strlen(pathname)>1) && (strlen(filename)>1) )
			LoadWave/N=original/D/J/k=1/P=$(pathname) filename			
		else
			LoadWave/N=original/D/J/k=1
		endif
	else
		if (order<30)
			LoadWave/N=original/D/G		//leica format
		else
			if (order ==30)
				LoadWave/N=original/D/J/k=1/L={1, 2, 0, 0, 5 } //070824 Leica format : Moritz:  Version is "1.7.0 built 1240" or I have read Version2.0
														// .csv format, which is pretty different from previous 
			endif									
			if (order ==40)	
				LoadWave/N=original/D/J/k=1/L={1, 13, 0, 0, 6 } //080724 Olympus CSV format : Moritz: 
			endif
			if (order ==50)			//Chiez
				//need to ask for the path and file, otherwise there will be a window popup
				XLLoadWave/D/Q/T/A=original/COLT="4N" //081006
			endif
			if (order==60)				//Chiez tab-Delimited, 4 columns, omit the first line (column names): Excel exported tab-delimited file
				LoadWave/N=original/D/J/k=1/L={0, 1, 0, 0, 4 }
			endif
		endif
	endif
	
	variable LoadedNum
	if (V_flag==0)
		abort "Not a data file"
	else
		LoadedNum=V_flag
	endif
	
	switch (order)
		case 0:	//1010 () 4 FRAP +  Reference
			wave/z original0,original1,original2
			DeletePoints 0,1, original0,original1,original2
			Rename original0,$Original_t
			Rename original1,$Original_Frap
			Rename original2,$Original_Back	
			
			Edit $Original_t,$Original_Back	,$Original_Frap
			Display $Original_Back,$Original_Frap vs $Original_t
			//GdataformSpec=0
			GdataformSpec=1010					
			break
			
		case 1:	//1010 () 4 FRAP +  Reference	
			wave/z original0,original1,original2
			DeletePoints 0,1, original0,original1,original2
			Rename original0,$Original_t
			Rename original2,$Original_Frap
			Rename original1,$Original_Back	
			
			Edit $Original_t,$Original_Back	,$Original_Frap
			Display $Original_Back,$Original_Frap vs $Original_t
			//GdataformSpec=0
			GdataformSpec=1010					
			break

		case 2:	//1000 () 6 FRAP 
			wave/z original0,original1
			DeletePoints 0,1, original0,original1
			Duplicate/O original0 $Original_Back
			wave/z bkgAv=$Original_Back
			bkgAv=1
			
			Rename original0,$Original_t
			Rename original1,$Original_Frap

			Edit $Original_t,$Original_Frap
			Display $Original_Frap vs $Original_t
//			GdataformSpec=0									
			GdataformSpec=1000									
			break

		case 3:	//1101 () 1 FRAP + Whole Cell + Base
			wave/z original0,original1,original2,original3
			DeletePoints 0,1, original0,original1,original2,original3
			Rename original0,$Original_t
			Rename original1,$Original_Frap
			Rename original2,$Original_AllCell	
			Rename original3,$Original_base	
			
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_base,$Original_Frap vs $Original_t
			//GdataformSpec=1							
			GdataformSpec=1101							
			break

		case 4:	//1101 () 1 FRAP + Base + Whole Cell
			wave/z original0,original1,original2,original3
			DeletePoints 0,1, original0,original1,original2,original3
			Rename original0,$Original_t	
			Rename original1,$Original_Frap
			Rename original2,$Original_base	
			Rename original3,$Original_AllCell	
			
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_base,$Original_Frap vs $Original_t			
			//GdataformSpec=1							
			GdataformSpec=1101							
			break

		case 5:	//1011 () 1 FRAP + Reference + Base
			wave/z original0,original1,original2,original3
			DeletePoints 0,1, original0,original1,original2,original3
			Rename original0,$Original_t	
			Rename original1,$Original_Frap
			Rename original2,$Original_Back	
			Rename original3,$Original_base	
			
			Edit $Original_t,$Original_Frap,$Original_Back,$Original_base
			Display $Original_Back,$Original_base,$Original_Frap vs $Original_t			
			//GdataformSpec=1							
			GdataformSpec=1011							
			break

		case 6:	//1011 () 1 FRAP + base + Reference
			wave/z original0,original1,original2,original3
			DeletePoints 0,1, original0,original1,original2,original3
			Rename original0,$Original_t	
			Rename original1,$Original_Frap
			Rename original2,$Original_base	
			Rename original3,$Original_Back	
			
			Edit $Original_t,$Original_Frap,$Original_Back,$Original_base
			Display $Original_Back,$Original_base,$Original_Frap vs $Original_t			
			//GdataformSpec=1							
			GdataformSpec=1011							
			break			


// 050713
// point No. - time - ch1 (Frap) - ch2 (order==0)
// point No. - time - ch1 - ch2 (Frap) - ch3 (order==1)	//050715
// ROI1 Frap
// ROI2 All cell
// ROI3 Background
// 4 x 3 ROI = 12 waves loaded

//		case 20:		//1101 () 1 FRAP + Whole Cell + Base
//			if (K_KillLoadedwaves(LoadedNum,12)==0)
//				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 12 columns): Select other format.")
//			endif
//			wave/z original0,original1,original2,original3	//ROI1
//			wave/z original4,original5,original6,original7	//ROI2
//			wave/z original8,original9,original10,original11	//ROI3
//
//			Rename original1,$Original_t
//			Rename original2,$Original_Frap
//			Rename original6,$Original_AllCell
//			Rename original10,$Original_base	//050802
//			Killwaves original0,original3,original4,original5,original7,original8,original9,original11
//			//GdataformSpec=1
//			GdataformSpec=1101
//			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
//			Display $Original_AllCell,$Original_base,$Original_Frap vs $Original_t			
//			break

		case 20:		//1101 () 1 single channel FRAP + Whole Cell + Base	9 clumns loaded //modified 060803
			if (K_KillLoadedwaves(LoadedNum,9)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 9 columns): Select other format.")
			endif
			wave/z original0,original1,original2//,original3	//ROI1
			wave/z original3,original4,original5//,original7	//ROI2
			wave/z original6,original7,original8//,original11	//ROI3

			Rename original1,$Original_t
			Rename original2,$Original_Frap
			Rename original5,$Original_AllCell
			Rename original8,$Original_base	//050802
			Killwaves original0,original3,original4,original6,original7
			//GdataformSpec=1
			GdataformSpec=1101
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_base,$Original_Frap vs $Original_t			
			break
			
			
		case 21:		//1101 () 1 double channel ch1 FRAP + Whole Cell + Base	//060803
			if (K_KillLoadedwaves(LoadedNum,12)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 12 columns): Select other format.")
			endif
//			wave/z original0,original1,original2,original3,original4	//ROI1
//			wave/z original5,original6,original7,original8,original9	//ROI2
//			wave/z original10,original11,original12,original13,original14	//ROI3
			wave/z original0,original1,original2,original3	//ROI1	//060803
			wave/z original4,original5,original6,original7	//ROI2
			wave/z original8,original9,original10,original11	//ROI3

			Rename original1,$Original_t
			Rename original2,$Original_Frap
			Rename original6,$Original_AllCell
			Rename original10,$Original_base	//050802
			Killwaves original0,original3,original4,original5,original7,original8,original9,original11
			//GdataformSpec=1
			GdataformSpec=1101
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_Back,$Original_Frap vs $Original_t
			break
			
		case 22:		//another ROI, channe1 is considered as FRAP, among double channel 050725
					//1111 () 0 FRAP + Whole Cell +  Reference + Base
			if (K_KillLoadedwaves(LoadedNum,16)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 16 columns): Select other format.")
			endif
			wave/z original0,original1,original2,original3	//ROI1
			wave/z original4,original5,original6,original7	//ROI2
			wave/z original8,original9,original10,original11	//ROI3
			wave/z original12,original13,original14,original15	//ROI4

			Rename original1,$Original_t
			Rename original2,$Original_Frap
			Rename original6,$Original_AllCell
			Rename original10,$Original_base	//050725
			Rename original14,$Original_back	//050725
			
			Killwaves original0,original3,original4,original5,original7,original8,original9,original11
			Killwaves original12,original13,original15
			//GdataformSpec=2
			GdataformSpec=1111
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base,$Original_Back
			Display $Original_AllCell,$Original_Back,$Original_base,$Original_Frap vs $Original_t
			break

		case 23:		//another ROI, double channel 050725
					//channe2 is considered as FRAP, among double channel 
					//1111 () 0 FRAP + Whole Cell +  Reference + Base

			if (K_KillLoadedwaves(LoadedNum,16)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 16 columns): Select other format.")
			endif
			wave/z original0,original1,original2,original3	//ROI1
			wave/z original4,original5,original6,original7	//ROI2
			wave/z original8,original9,original10,original11	//ROI3
			wave/z original12,original13,original14,original15	//ROI4
			
			Rename original1,$Original_t
			Rename original3,$Original_Frap
			Rename original7,$Original_AllCell
			Rename original11,$Original_base	//050725
			Rename original15,$Original_back	//050725

			Killwaves original0,original2
			Killwaves original5,original6,original4
			Killwaves original10,original9,original8
			Killwaves original12,original13,original14


			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base,$Original_Back
			Display $Original_AllCell,$Original_Back,$Original_base,$Original_Frap vs $Original_t
			//GdataformSpec=2
			GdataformSpec=1111
			break
			
		case 24:		//1101 () 1 double channel ch2 FRAP + Whole Cell + Base	//060803
			if (K_KillLoadedwaves(LoadedNum,12)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 12 columns): Select other format.")
			endif

			wave/z original0,original1,original2,original3	//ROI1	//060803
			wave/z original4,original5,original6,original7	//ROI2
			wave/z original8,original9,original10,original11	//ROI3

			Rename original1,$Original_t
			Rename original3,$Original_Frap
			Rename original7,$Original_AllCell
			Rename original11,$Original_base	//050802
			Killwaves original0,original2,original4,original5,original6,original8,original9,original10
			//GdataformSpec=1
			GdataformSpec=1101
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_Back,$Original_Frap vs $Original_t
			break

		case 25:		//4 ROIs, single channel 060803
					//1111 () 0 FRAP + Whole Cell +  Reference + Base

			if (K_KillLoadedwaves(LoadedNum,12)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 12 columns): Select other format.")
			endif
			wave/z original0,original1,original2	//ROI1
			wave/z original3,original4,original5	//ROI2
			wave/z original6,original7,original8	//ROI3
			wave/z original9,original10,original11	//ROI4
			
			Rename original1,$Original_t
			Rename original2,$Original_Frap
			Rename original5,$Original_AllCell
			Rename original8,$Original_base	//050725
			Rename original11,$Original_back	//050725

			Killwaves original0
			Killwaves original3,original4
			Killwaves original6,original7
			Killwaves original9,original10


			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base,$Original_Back
			Display $Original_AllCell,$Original_Back,$Original_base,$Original_Frap vs $Original_t
			//GdataformSpec=2
			GdataformSpec=1111
			break
			
			
		case 26:		//080620 two cell-parts
					//5 ROIs, channe1 is considered as FRAP, among double channel 050725
					//1111 () 0 FRAP + Whole Cell +  Reference + Base
			if (K_KillLoadedwaves(LoadedNum,20)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 20 columns): Select other format.")
			endif
			wave/z original0,original1,original2,original3	//ROI1	frap
			wave/z original4,original5,original6,original7	//ROI2	ref1
			wave/z original8,original9,original10,original11	//ROI3	ref2
			wave/z original12,original13,original14,original15	//ROI4	whole cell
			wave/z original16,original17,original18,original19	//ROI5	back

			Rename original1,$Original_t
			Rename original2,$Original_Frap
			Rename original6,$Original_back	//050725
			Rename original10,$Original_back2	//050725
			Rename original14,$Original_AllCell
			Rename	original18, $Original_base 
			
			Killwaves original0,original3,original4,original5,original7,original8,original9,original11
			Killwaves original12,original13,original15
			Killwaves original16,original17,original19
			
			//GdataformSpec=2
			GdataformSpec=1111
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base,$Original_Back, $Original_Back2
			Display $Original_AllCell,$Original_Back,$Original_Back2,$Original_base,$Original_Frap vs $Original_t
			break
						
		case 30:			//070824 for Moritz  t - FRAP - back - base - allcell
			if (K_KillLoadedwaves(LoadedNum,5)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 5 columns): Select other format.")
			endif
			
			wave/z original0,original1,original2, original3,original4 //chart_1.csv
			Rename original0,$Original_t
			Rename original1,$Original_Frap
			Rename original2,$Original_back
			Rename original3,$Original_base	
			Rename original4,$Original_AllCell					
			
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base,$Original_Back
			Display $Original_AllCell,$Original_Back,$Original_base,$Original_Frap vs $Original_t
			GdataformSpec=1111
			break

// Olympus 080724 Moritz
		case 40:			//080724 for Moritz  p - t - FRAP - back - base - allcell (GdataformSpec=1111)
			if (K_KillLoadedwaves(LoadedNum,6)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 6 columns): Select other format.")
			endif
			
			wave/z original0,original1,original2, original3,original4,original5 //chart_1.csv
			Rename original1,$Original_t
			Rename original2,$Original_Frap
			Rename original3,$Original_back
			Rename original4,$Original_base	
			Rename original5,$Original_AllCell					
			
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base,$Original_Back
			Display $Original_AllCell,$Original_Back,$Original_base,$Original_Frap vs $Original_t
			killwaves original0
			GdataformSpec=1111
			break

// Excel file 081006 Chieze
		case 50:			//081006 for Chieze  t - FRAP - allcell - base (GdataformSpec=1101)

			if (K_KillLoadedwaves(LoadedNum,4)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 4 columns): Select other format.")
			endif

			wave/z original0,original1,original2, original3
			DeletePoints 0,1, original0
			DeletePoints 0,1, original1
			DeletePoints 0,1, original2
			DeletePoints 0,1, original3

			Rename original0,$Original_t
			Rename original1,$Original_Frap
			Rename original2,$Original_AllCell	//Original_back
			Rename original3,$Original_base	
			//Rename original5,$Original_AllCell					
			
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_base,$Original_Frap vs $Original_t
			//killwaves original0
			GdataformSpec=1111

			break

		case 60:			//081009 for Chieze  t - FRAP - allcell - base (GdataformSpec=1101) tabdelimited file

			if (K_KillLoadedwaves(LoadedNum,4)==0)
				abort (num2str(LoadedNum)+"columns: Format Mismatch (should be 4 columns): Select other format.")
			endif
			wave/z original0,original1,original2, original3
			Rename original0,$Original_t
			Rename original1,$Original_Frap
			Rename original2,$Original_AllCell	//Original_back
			Rename original3,$Original_base	
			//Rename original5,$Original_AllCell					
			
			Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_base
			Display $Original_AllCell,$Original_base,$Original_Frap vs $Original_t
			//killwaves original0
			GdataformSpec=1111
			break
												
	endswitch
	
	
	G_dataForm=GdataformSpec

	K_CheckAllGV()
END

//import 6 controls. Data format of Heiko's Zeiss data.
//Delete first points.
//Rename the waves to the given experiment prefix and then average the results.
Function K_importFrapTxtDataV2()			
	String exp_name
	prompt exp_name, "Name of the Experiment?"
	Doprompt "name::",exp_name
		if (V_flag)
		Abort "Processing Canceled"
	endif
	
	variable i
	String Original_t,Original_Frap
	Original_Frap=exp_name+"_FRAP"
	Original_t=exp_name+"_t"

	LoadWave/N=original/D/J/k=1
	wave/z original0,original1,original2,original3,original4,original5,original6,original7
	DeletePoints 0,1, original0,original1,original2,original3,original4,original5,original6,original7
	Rename original0,$Original_t
	Rename original1,$Original_Frap
	Edit $Original_t,$Original_Frap
	DoWindow/N $(exp_name+"_data")
	Display $Original_Frap vs $Original_t
	DoWindow/N $(exp_name+"_graph")
	string srcewavename,renamewavename
	for (i=2;i<8;i+=1)
		srcewavename="original"+num2str(i)
		renamewavename=exp_name+"_bkgOg"+num2str(i)	
		Rename $srcewavename,$renamewavename
		DoWindow/F $(exp_name+"_data")
		AppendtoTable $renamewavename
		DoWindow/F $(exp_name+"_graph")
		AppendtoGraph $renamewavename	vs $Original_t
		ModifyGraph lstyle($renamewavename)=1
		ModifyGraph rgb($renamewavename)=(0,0,65280)
	endfor
	Make/N=(numpnts($Original_t)) $(exp_name+"_bkgAv")
	wave BackAve=$(exp_name+"_bkgAv")
	for (i=2;i<8;i+=1)
		wave Back=$(exp_name+"_bkgOg"+num2str(i))
		BackAve	[]+=Back[p]
	endfor
	BackAve/=6
	DoWindow/F $(exp_name+"_graph")
	AppendtoGraph BackAve vs $Original_t
	ModifyGraph lsize($(NameofWave(BackAve)))=2
	ModifyGraph rgb($(NameofWave(BackAve)))=(0,15872,65280)	
	
END

Function K_importFrapTxtDataV2Multi(path_name,exp_name,exp_num)//,currentNum)			//import 6 controls + multiple files
	String path_name,exp_name
	Variable exp_num//,currentNum
	variable i
	String Original_t,Original_Frap

	Original_Frap=exp_name+"_FRAP"
	Original_t=exp_name+"_t"
	
	string filename=exp_name+".txt"	//0400303

	LoadWave/N=original/D/J/k=1/p=$path_name filename
	wave/z original0,original1,original2,original3,original4,original5,original6,original7
	DeletePoints 0,1, original0,original1,original2,original3,original4,original5,original6,original7
	Rename original0,$Original_t
	Rename original1,$Original_Frap
//	Edit $Original_t,$Original_Frap
//	DoWindow/N $(exp_name+num2str(currentNum)+"_data")
	Display $Original_Frap vs $Original_t
//	DoWindow/N $(exp_name+num2str(currentNum)+"_graph")
	DoWindow/N $(exp_name+"_graph")		//040303
	string srcewavename,renamewavename
	for (i=2;i<8;i+=1)
		srcewavename="original"+num2str(i)
//		renamewavename=exp_name+num2str(currentNum)+"_bkgOg"+num2str(i)	
		renamewavename=exp_name+"_bkgOg"+num2str(i)		//040303
		Rename $srcewavename,$renamewavename
//		DoWindow/F $(exp_name+num2str(currentNum)+"_data")
//		AppendtoTable $renamewavename
//		DoWindow/F $(exp_name+num2str(currentNum)+"_graph")
		DoWindow/F $(exp_name+"_graph")		//040303
		AppendtoGraph $renamewavename	vs $Original_t
		ModifyGraph lstyle($renamewavename)=1
		ModifyGraph rgb($renamewavename)=(0,0,65280)
	endfor
//	Make/N=(numpnts($Original_t)) $(exp_name+num2str(currentNum)+"_bkgAv")
	Make/N=(numpnts($Original_t)) $(exp_name+"_bkgAv")	//040303
//	wave BackAve=$(exp_name+num2str(currentNum)+"_bkgAv")
	wave BackAve=$(exp_name+"_bkgAv")		//040303
	for (i=2;i<8;i+=1)
//		wave Back=$(exp_name+num2str(currentNum)+"_bkgOg"+num2str(i))
		wave Back=$(exp_name+"_bkgOg"+num2str(i))		//040303
		BackAve	[]+=Back[p]
	endfor
	BackAve/=6
//	DoWindow/F $(exp_name+num2str(currentNum)+"_graph")
	DoWindow/F $(exp_name+"_graph")		//040303
	AppendtoGraph BackAve vs $Original_t
	ModifyGraph lsize($(NameofWave(BackAve)))=2
	ModifyGraph rgb($(NameofWave(BackAve)))=(0,15872,65280)	
	
END

//************************************************Fit Functions********************************************

//FRAP: rainer's original mehtod.
//FRAP2: rainer's method modified. (add C)
//FRAP3: rainer's method modified. (without initial boundary condition (i(0),0)=(0,0))
//FRAP4: fit to the multiplication of acquisition bleach and FRAP exponential equation.
//FRAP_exp: normal single exponential

Function FRAP(w,t) : FitFunc
	Wave w
	Variable t

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) = A*invtau1/(invtau1+invtau2)*(1-e^(-1*(invtau1+invtau2)*t))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = invtau1
	//CurveFitDialog/ w[2] = invtau2

	return w[0]*w[1]/(w[1]+w[2])*(1-e^(-1*(w[1]+w[2])*t))
End


Function FRAP4(w,t) : FitFunc			
	Wave w
	Variable t
	
	//040316 new formula
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) = -1*A*B*e^(-1*(invtau1+invtau2)*t)-y0*B*e^(-1*invtau1*t)+A*B*e^(-1*invtau2*t)+B*y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = B
	//CurveFitDialog/ w[2] = invtau1
	//CurveFitDialog/ w[3] = invtau2
	//CurveFitDialog/ w[4] = y0

	return -1*w[0]*w[1]*e^(-1*(w[2] +w[3])*t)-w[4]*w[1]*e^(-1*w[2] *t)+w[0]*w[1]*e^(-1*w[3]*t)+w[1]*w[4]
End

// original formula was collected for the right one. 050307
Function FRAP_Ellenberg(w,t) : FitFunc			
	Wave w
	Variable t
	
	//040429 Ellenberg(1997) formula
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) =A*(1-((w^2)/(w^2+4*3.1415*D*t))^0.5)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = w
	//CurveFitDialog/ w[2] = D

	return (w[0]*(1-((w[1]^2)/(w[1]^2+4*3.1415*w[2]*t))^0.5))
End


Function FRAP_exp(w,t) : FitFunc
	Wave w
	Variable t

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) = A*(1-e^(-1*(invtau)*t))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = invtau

	return w[0]*(1-e^(-1*w[1]*t))
End

//050715
Function FRAP_exp2(w,t) : FitFunc
	Wave w
	Variable t

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) = y0-A*e^(-1*(invtau)*t)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = invtau

	return w[0]-w[1]*e^(-1*w[2]*t)
End


Function FRAP_BACK2(w,t) : FitFunc
	Wave w
	Variable t

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) = A*(1-e^(-1*(invtau2)*t))+C
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = invtau2
	//CurveFitDialog/ w[2] = C
	
	return w[0]*(1-e^(-1*w[1]*t))+w[2]
End

Function FRAP_soumpasis(w,t) : FitFunc
	Wave w
	Variable t

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(t) =A*( e^(-1*tauD/2/t))* (bessI(0,(tauD/2/t)) +bessI(1,(tauD/2/t)))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ t
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = tauD
	variable val
	if (t!=0)
		val=w[0]* (e^(-1*w[1]/2/t) )*( bessI(0,(w[1]/2/t))+ bessI(1,(w[1]/2/t)) ) 
	else
		val=0
	endif
	return val
End


function temptestsoumpasis(A,tauD)
	variable A,tauD
	make/o/n=500 testsoum,testsoum_t
	testsoum_t[]=0.00001*p
	testsoum[]= A* (e^(-1*tauD/2/testsoum_t[p]) )*( bessI(0,(tauD/2/testsoum_t[p]))+ bessI(1,(tauD/2/testsoum_t[p])) ) 
end

//************************************************FRAP Fitting********************************************

//050203 flat returns 0
Function	CheckFlatBackground(backw)
	wave backw
	variable i,flat_flag
	flat_flag=0
	wavestats/q backw
	variable backwAVG=V_avg

	for (i=0;i<numpnts(backw);i+=1) 
		if (backw[i]!=backwAVG)
			flat_flag=1
			//print(backw[i])
			//print("non-average")
		endif
	endfor
	if (flat_flag==0)
		printf "xxx Reference is Artificial: Flat %g xxxx\r",backwAVG
	endif
	return flat_flag
END

//050306 For Normalization of the original data.
//	PreBleach Level set to 1, backgournd is ralative to this value. 
Function K_FrapCalcNormalizeCurves(FitPara_wave,normalized)//(decwave_xnm,decwave_ynm,Frapwave_ynm,FitPara_wave,normalized)
	wave FitPara_wave
	variable normalized

	NVAR/z G_BleachPoint
	SVAR/z G_CurrentExp
	
	String Original_t,Original_Back,Original_Frap,Original_base,Original_AllCell
	Original_base=G_CurrentExp+"_base"	//050802
	Original_AllCell=G_CurrentExp+"_AllCell"
	Original_Back=G_CurrentExp+"_bkgAv"
	Original_Frap=G_CurrentExp+"_FRAP"
	Original_t=G_CurrentExp+"_t"

	String Norm_t,Norm_Back,Norm_Frap,Norm_base,Norm_AllCell //Normalized
	Norm_base=Original_base+"_norm"	//050802
	Norm_AllCell=Original_AllCell+"_norm"
	Norm_Back=Original_Back+"_norm"
	Norm_Frap=Original_Frap+"_norm"
	Norm_t=Original_t+"_c"

	wave decwave_x_original=$Original_t
	wave Frapwave_y_original=$Original_Frap

// time shifting to bleach time point=0
	Duplicate/o  $Original_t $Norm_t
	wave timewave=$Norm_t
	//Variable BleachTimePoint=decwave_x_original[BleachPoint]
	//timewave-=BleachTimePoint							
	timewave-=decwave_x_original[G_BleachPoint]			//shift the timepoint
	
// Prepare Normalized waves	If there is base, subtract base from other 3 waves
// At the same time, get Prebleach average intenity from Original waves 
	variable I_Prebleach_Ref,I_Prebleach_AllCell,I_Prebleach_Frap,I_Bleach_Frap
	variable WholeCell_Exists,Ref_Exists,Base_Exists

	Duplicate/o $Original_Frap $Norm_Frap
	wave Frapwave=$Norm_Frap

	wave/z base_original=$Original_base
	if (waveexists(base_original)==1)
		Base_Exists=1
		Duplicate/o $Original_base $Norm_base
		wave Basewave=$Norm_base
		Frapwave[]=Frapwave[p]-Basewave[p]
	else
		Base_Exists=0		
	endif	
	wavestats/q/r=[0,G_BleachPoint-1] Frapwave
	I_Prebleach_Frap=V_avg	
	printf "Original: Prebleach Frap: %g ::",I_Prebleach_Frap
	I_Bleach_Frap=Frapwave[G_BleachPoint]	// I0: the baseline			//040317
	variable fullscale=(I_Prebleach_Frap-I_Bleach_Frap)
	printf "I_Bleach_Frap=%g fullscale=%g\r",I_Bleach_Frap,fullscale
				
	wave/z decwave_y_original=$Original_Back
	if (waveexists(decwave_y_original)==1)
		Ref_Exists=1
		Duplicate/o $Original_Back $Norm_Back
		wave Refwave=$Norm_Back
		if (Base_Exists==1)		
			Refwave[]=Refwave[p]-Basewave[p]
		endif
		wavestats/q/r=[0,G_BleachPoint-1] Refwave
		I_Prebleach_Ref=V_avg	
		printf "Original: Prebleach Ref: %g ::\r",I_Prebleach_Ref
	else
		Ref_Exists=0		
	endif

	
	wave/z wholecell_original=$Original_AllCell
	if (waveexists(wholecell_original)==1)
		WholeCell_Exists=1
		Duplicate/o $Original_AllCell $Norm_AllCell
		wave AllCellwave=$Norm_AllCell
		if (Base_Exists==1)		
			AllCellwave[]=AllCellwave[p]-Basewave[p]
		endif		
		wavestats/q/r=[0,G_BleachPoint-1] AllCellwave
		I_Prebleach_AllCell=V_avg
		printf "Prebleach Whole Cell: %g\r",I_Prebleach_AllCell
	else
		WholeCell_Exists=0		
	endif

//	Single normalization as Phair et al. (2000) Proposes.
//	relative recovery and loss = (It - Background) / (Iprebleach - background)

	variable Fit_method=FitPara_wave[0]
	variable I_Prebleach_Frap_norm,I_Prebleach_Allcell_norm,I_Prebleach_Ref_norm

	if ((Fit_method==0) && (normalized==0))	//Rainer's method
		Frapwave[]=(Frapwave[p]-I_Bleach_Frap)/fullscale
		if (WholeCell_Exists)	
			AllCellwave[]=(AllCellwave[p]-I_Bleach_Frap)/fullscale
		endif
		if (Ref_Exists)
			Refwave[]=(Refwave[p]-I_Bleach_Frap)/fullscale
		endif
	endif

	if ( ((Fit_method==1) || (Fit_method==2)) && (normalized==0))	//BackMultiply, single (1) and double (2) exponential
		Frapwave[]=(Frapwave[p]-I_Bleach_Frap)/fullscale
		if (WholeCell_Exists)	
			AllCellwave[]=AllCellwave[p]*I_Prebleach_Frap/I_Prebleach_AllCell		//correction for the intensity, becomes equivalent prebleach level with that of FRAP
			AllCellwave[]=(AllCellwave[p]-I_Bleach_Frap)/fullscale
		endif
		if (Ref_Exists)
			Refwave[]=Refwave[p]*I_Prebleach_Frap/I_Prebleach_Ref		//correction for the intensity, becomes equivalent prebleach level with that of FRAP
			Refwave[]=(Refwave[p]-I_Bleach_Frap)/fullscale			
		endif
	endif

	if ((Fit_method>5) && (Fit_method<10) && (normalized==0))	//phair. Background will not be nromalized, only subtracted by base as seen above. 
		//Frapwave[]=(Frapwave[p]-I_Bleach_Frap)/fullscale
		if (WholeCell_Exists)					
			Frapwave[]=Frapwave[p]*I_Prebleach_AllCell/AllCellwave[p]/I_Prebleach_Frap	//Double (single) Normalization
		else
			if (Ref_Exists)
				Frapwave[]=Frapwave[p]*I_Prebleach_Ref/Refwave[p]/I_Prebleach_Frap		//reference normalization
			else
				Frapwave[]=Frapwave[p]/I_Prebleach_Frap	//single normalization
			endif
		endif
		if ((Fit_method==8) || (Fit_method==9))		//diffusion fitting
			I_Bleach_Frap=Frapwave[G_BleachPoint]
			wavestats/q/r=[0,G_BleachPoint-1] Frapwave
			fullscale=V_avg-I_Bleach_Frap
			Frapwave[]=(Frapwave[p]-I_Bleach_Frap)/fullscale	
			printf "frap-bleach intensity normalized to 0 for diffusion fitting\r"
		endif
	endif	

	wavestats/q/r=[0,G_BleachPoint-1] Frapwave
	I_Prebleach_Frap_norm=V_avg	
	printf "Normalized: Prebleach Frap %g :: ",I_Prebleach_Frap_norm
	FitPara_wave[8]=I_Prebleach_Frap_norm

	if (WholeCell_Exists)	
		wavestats/q/r=[0,G_BleachPoint-1] AllCellwave
		I_Prebleach_Allcell_norm=V_avg
		printf "Prebleach whole cell %g\r",I_Prebleach_Allcell_norm
		FitPara_wave[7]=I_Prebleach_Allcell_norm
	else
		if (Ref_Exists)
			wavestats/q/r=[0,G_BleachPoint-1] Refwave
			I_Prebleach_Ref_norm=V_avg
			printf "Prebleach reference %g\r",I_Prebleach_Ref_norm
			FitPara_wave[7]=I_Prebleach_Ref_norm
		else
			printf "No reference\r"
			FitPara_wave[7]=0			
		endif
	endif
	
	FitPara_wave[15]=WholeCell_Exists
	FitPara_wave[16]=Ref_Exists
	FitPara_wave[17]=Base_Exists
	
	//return I_Prebleach_Back_norm
END

// 100204 for averaged curve, normalization is done but no original. For this, only get some of parameters. 
Function K_FrapCalcNormalizedCurves(FitPara_wave,normalized)//(decwave_xnm,decwave_ynm,Frapwave_ynm,FitPara_wave,normalized)
	wave FitPara_wave
	variable normalized

	NVAR/z G_BleachPoint
	SVAR/z G_CurrentExp
	
	String Original_t,Original_Back,Original_Frap,Original_base,Original_AllCell
	Original_base=G_CurrentExp+"_base"	//050802
	Original_AllCell=G_CurrentExp+"_AllCell"
	Original_Back=G_CurrentExp+"_bkgAv"
	Original_Frap=G_CurrentExp+"_FRAP"
	Original_t=G_CurrentExp+"_t"

	String Norm_t,Norm_Back,Norm_Frap,Norm_base,Norm_AllCell //Normalized
	Norm_base=Original_base+"_norm"	//050802
	Norm_AllCell=Original_AllCell+"_norm"
	Norm_Back=Original_Back+"_norm"
	Norm_Frap=Original_Frap+"_norm"
	Norm_t=Original_t+"_c"


	variable WholeCell_Exists,Ref_Exists,Base_Exists

	wave timewave=$Norm_t
	wave Frapwave=$Norm_Frap
	wave/z Basewave=$Norm_base
	Base_Exists = waveexists(Basewave) 
	
	wave/z Refwave=$Norm_Back				
	Ref_Exists=waveexists(Refwave)
	
	wave/z AllCellwave=$Norm_AllCell
	WholeCell_Exists = waveexists(AllCellwave)

//	calculate prebleach intensity from normalized waves. 

	variable Fit_method=FitPara_wave[0]
	variable I_Prebleach_Frap_norm,I_Prebleach_Allcell_norm,I_Prebleach_Ref_norm

	wavestats/q/r=[0,G_BleachPoint-1] Frapwave
	I_Prebleach_Frap_norm=V_avg	
	printf "Normalized: Prebleach Frap %g :: ",I_Prebleach_Frap_norm
	FitPara_wave[8]=I_Prebleach_Frap_norm

	if (WholeCell_Exists)	
		wavestats/q/r=[0,G_BleachPoint-1] AllCellwave
		I_Prebleach_Allcell_norm=V_avg
		printf "Prebleach whole cell %g\r",I_Prebleach_Allcell_norm
		FitPara_wave[7]=I_Prebleach_Allcell_norm
	else
		if (Ref_Exists)
			wavestats/q/r=[0,G_BleachPoint-1] Refwave
			I_Prebleach_Ref_norm=V_avg
			printf "Prebleach reference %g\r",I_Prebleach_Ref_norm
			FitPara_wave[7]=I_Prebleach_Ref_norm
		else
			printf "No reference\r"
			FitPara_wave[7]=0			
		endif
	endif
	
	FitPara_wave[15]=WholeCell_Exists
	FitPara_wave[16]=Ref_Exists
	FitPara_wave[17]=Base_Exists
	
	//return I_Prebleach_Back_norm
END






// Used for Rainer's method and back Multiply method. 
Function K_FrapBackgroundGuess(decwave_y,decwave_x,FitPara_wave)
	wave decwave_y,decwave_x,FitPara_wave

	NVAR G_BleachPoint
	variable 	invTau2,decA,decY0
	string decwave_ynm_norm=nameofwave(decwave_y)
	variable FlatBackground=FitPara_wave[4]
	SVAR/z G_CurrentExp
	string WinNameFit=K_GraphWinname(G_CurrentExp)//,fit_method)
	
	if (FlatBackground==1)
		// fit the background bleaching

		checkG_BackStartPnt()		//050808
		NVAR/z G_BackStartPnt	//050808
		
		//(1) hold y0 to 0 so that the real back ground is equal to the FRAP-bleached fluorescence level. 		
		//K0=0
		//CurveFit/H="100"/W=0/Q exp decwave_y[G_BackStartPnt,] /X=decwave_x /D
		//(2) real backgroun dlevel (offset) is estimated by fitting also. 		
//		CurveFit/H="000"/W=0/Q exp decwave_y[G_BackStartPnt,] /X=decwave_x /D
		CurveFit/H="000"/W=0/Q exp decwave_y[G_BackStartPnt,numpnts(decwave_y)-1] /X=decwave_x /D

		wave/z W_coef
		//ModifyGraph mode($decwave_ynm_norm)=3,rgb($decwave_ynm_norm)=(0,15872,65280)
		//string decayFitnm
		//decayFitnm="fit_"+decwave_ynm_norm
		//ModifyGraph/w=$WinNameFit rgb($("fit_"+nameofwave(decwave_y)))=(0,15872,65280)		
		invTau2=W_coef[2]
		decA=W_coef[1]
		decY0=W_coef[0]
		
//rescue for non-fitting and increaseing flourescence		

		if ((numtype(invTau2)!=0))		
			wavestats/q/R=[G_BackStartPnt, numpnts(decwave_y)-1] decwave_y //100210 added numpnts(decwave_y)-1, IgorProv6 compatibility
			invTau2=0
			decA=0
			decY0=V_avg
			printf "--- Bad Fitting for the Back decay. background level set to %g (time point 0)----\r",decY0
			FlatBackground=0 //flat		
		endif

		if ((invTau2<=0) || (decA<=0))	//050808 then the background is increasing or badly shaped
			wavestats/q/R=[G_BackStartPnt, numpnts(decwave_y)-1] decwave_y //100210 added numpnts(decwave_y)-1, IgorProv6 compatibility
			invTau2=0
			decA=0
			decY0=V_avg
			printf "--- Decay curve is flat or increasing . background level set to %g (Average of Post Bleach)----\r",decY0
			FlatBackground=0 //FitPara_wave[4]=0 //flat		
		endif

	else		//flat background 050203
		printf "Background is flat\r"
		//decayFitnm="fit_"+decwave_ynm_norm
		//duplicate/o decwave_y $decayFitnm
		wavestats/q/R=[G_BackStartPnt, numpnts(decwave_y)-1] decwave_y //100210 added numpnts(decwave_y)-1, IgorProv6 compatibility
		invTau2=0
		decA=0
		decY0=V_avg
	endif
	printf "Fit Background (%s): invTau=%g A=%g ",nameofwave(decwave_y),invTau2,decA
	printf "y0=%g\r",decY0
	
	FitPara_wave[10]=decA
	FitPara_wave[11]=invTau2
	FitPara_wave[12]	=decY0			

	//prepare Background curve normalized to 1		040324
	//050804	if ((normalized==0) && (invtau2!=0))	
	//050804		decA=decA/BackGround_Timpoint0			//040324
	//050804	endif
	//050804		decY0=decY0/BackGround_Timpoint0		//040324

	//printf "Fit Background: invTau=%g A=%g ",invTau2,decA
	//printf "C=%g\r",BackGround_Timpoint0
END

function K_FrapTimetoPnt(decwave_x,timepoint)
	wave decwave_x
	variable timepoint
	variable correspnt,i
	for (i=0;i<numpnts(decwave_x);i+=1)
		if ((decwave_x[i]<=timepoint) && (timepoint<decwave_x[i+1]))
			correspnt=i
		endif
	endfor
	return correspnt
end

//................ GAP RATIO calculation ..................................

Function K_retGapRatio(FitPara_wave)
	wave FitPara_wave
	//decrease of fluorescence between prebleach period and the onset of the bleaching.
	//used for calculating Mobile/Immobile fraction: two ways. if there is data on whole cellintensity, then use it. otherwise, use background decay to estimate. 
	//modified on 050804
	variable GapRatio
	variable FlatBackground=FitPara_wave[4]	
	SVAR/z G_CurrentExp
	NVAR/z G_dataFormSpec=$(G_CurrentExp+"_dataform")
	if ((G_dataFormSpec==1111) || (G_dataFormSpec==1101)|| (G_dataFormSpec==1100))	//050804 Get Gap Ratio from whole cell
		GapRatio=K_estGapRFromOrigAllcell(FlatBackground)
		printf "GapRatio (from All Cell): expected Fl level at start is %g\r",GapRatio
	else		//no whole cell data. Get Gap Ratio from Reference ROI 
		GapRatio=K_estGapRFromOrigRef(FlatBackground)	//0500810
		printf "GapRatio (by Background Estimation): expected Fl level at start is %g\r",GapRatio		
	endif
	
					
//	I_Prebleach_Frap_norm*=GapRatio

//	FitPara_wave[5]=BackGround_Timpoint0
	FitPara_wave[6]=GapRatio
//	FitPara_wave[8]=I_Prebleach_Frap_norm
	return GapRatio
END


//050810 returns estimate gap ratio from original All cell decay curve
Function K_estGapRFromOrigAllcell(flatback)
	variable flatback // if the back is flat, then 0, not flat, then 1
	variable GapRatio
	SVAR/z G_CurrentExp
	NVAR/z G_BleachPoint
	string Original_AllCell=G_CurrentExp+"_AllCell"
	string Original_Back=G_CurrentExp+"_base"	//050802
	wave/z AllCell=$Original_AllCell
	wave/z BaseWave=$Original_Back
	if (waveexists(AllCell)==0)
		abort "No Data of Whole Cell; abort execution"
	endif
		
	variable AveIntBefore,AveIntAfter
	wavestats/q/r=[0,G_BleachPoint-1] AllCell
	AveIntBefore = V_avg
	wavestats/q/r=[0,G_BleachPoint-1] BaseWave
	AveIntBefore -= V_avg		//subtraciton

	wavestats/q/r=[G_BleachPoint+1,2*G_BleachPoint+1] AllCell
	AveIntAfter = V_avg
	wavestats/q/r=[G_BleachPoint+1,2*G_BleachPoint+1] BaseWave
	AveIntAfter -= V_avg		//subtraciton
		
	GapRatio=AveIntAfter/AveIntBefore
	printf "AllCell  Prebleach %g  ",AveIntBefore
	printf "PostBleach %g\r",AveIntAfter
	
	return GapRatio
END

//050810 returns estimate gap ratio from original reference decay curve
Function K_estGapRFromOrigRef(flatback)
	variable flatback // if the back is flat, then 0, not flat, then 1
	variable GapRatio
	variable PrebleachDecMeasured,PrebleachDecEstimate
	SVAR/z G_CurrentExp
	String Original_t,Original_Back
	Original_Back=G_CurrentExp+"_bkgAv"
	Original_t=G_CurrentExp+"_t"
	wave decwave_x_original=$Original_t
	wave decwave_y_original=$Original_Back
	
	NVAR/z G_BackStartPnt
	NVAR/z G_BleachPoint
	variable 	decY0_orig,decA_orig,dec_invTau_orig

//	CurveFit/H="000"/W=0/Q exp decwave_y_original[G_BackStartPnt,] /X=decwave_x_original /D
	CurveFit/H="000"/W=0/Q exp decwave_y_original[G_BackStartPnt,numpnts(decwave_y_original)-1] /X=decwave_x_original /D
	wave/z W_coef
	decY0_orig=W_coef[0]				
	decA_orig=W_coef[1]
	dec_invTau_orig=W_coef[2]

	if ((numtype(dec_invTau_orig)!=0) || ((dec_invTau_orig<=0) || (decA_orig<=0)) || (flatback==0))		
		wavestats/q/R=[G_BackStartPnt,] decwave_y_original		//100428 decwave_y -> decwave_y_original
		dec_invTau_orig=0
		decA_orig=0
		decY0_orig=V_avg
		printf "---Decay curve is flat or increasing . background level set to %g (time point 0)---\r",decY0_orig
	endif
	duplicate/o $Original_Back tempDecayOrig
	tempDecayOrig[]=decY0_orig+decA_orig*exp(-1*dec_invTau_orig*decwave_x_original[p])
	wavestats/q/r=[0,G_BleachPoint-1] decwave_y_original
	PrebleachDecMeasured=V_avg
	wavestats/q/r=[0,G_BleachPoint-1] tempDecayOrig
	PrebleachDecEstimate=V_avg
	
	GapRatio=PrebleachDecEstimate/PrebleachDecMeasured
	printf "Pre Bleach back Measured%g  ",PrebleachDecMeasured
	printf "Post Bleach Estimate%g\r",PrebleachDecEstimate	
	
	if (GapRatio>1)
		print "---Gap Ratio > 1 (by Original Reference curve): Gap Ratio set to 1.---"
		GapRatio=1
	endif
	Killwaves tempDecayOrig
	return GapRatio
end

//050810 returns estimate gap ratio from original All cell decay curve
//100203 should be modified to use normalized all cell. 100208
Function K_estGapRFromNormAllcell(flatback)
	variable flatback // if the back is flat, then 0, not flat, then 1
	variable GapRatio
	SVAR/z G_CurrentExp
	NVAR/z G_BleachPoint
	string Original_AllCell=G_CurrentExp+"_AllCell"
	string Original_Back=G_CurrentExp+"_base"	//050802
	wave/z AllCell=$Original_AllCell
	wave/z BaseWave=$Original_Back
	if (waveexists(AllCell)==0)
		abort "No Data of Whole Cell; abort execution"
	endif
		
	variable AveIntBefore,AveIntAfter
	wavestats/q/r=[0,G_BleachPoint-1] AllCell
	AveIntBefore = V_avg
	wavestats/q/r=[0,G_BleachPoint-1] BaseWave
	AveIntBefore -= V_avg		//subtraciton

	wavestats/q/r=[G_BleachPoint+1,2*G_BleachPoint+1] AllCell
	AveIntAfter = V_avg
	wavestats/q/r=[G_BleachPoint+1,2*G_BleachPoint+1] BaseWave
	AveIntAfter -= V_avg		//subtraciton
		
	GapRatio=AveIntAfter/AveIntBefore
	printf "AllCell  Prebleach %g  ",AveIntBefore
	printf "PostBleach %g\r",AveIntAfter
	
	return GapRatio
END


// Renewed 050811
//100204, 100210 extend a bit for fitting avaraged FRAP (does not need normalization, gap-ratio calculated by averaging individual gap ratios listed in *_parameter waves)
Function K_FrapCalcCore()//decwave_xnm,decwave_ynm,Frapwave_ynm,FitPara_wave)			// Normalizing version.//040324 
	SVAR/z G_CurrentExp
	NVAR/z G_dataFormSpec=$(G_CurrentExp+"_dataform")	
	NVAR/z G_sdevwexists	//100204			check if sd curve is present
	NVAR/z G_doAveraged		//100204		check if the curve fitting now is averaged one or not. 

	string FitPara_wavename=G_CurrentExp+"_parameter"
	make/o/N=30 $FitPara_wavename
	wave FitPara_wave=$FitPara_wavename
	NVAR Fit_method		//used for functions from menu :: to be replaced
	NVAR G_currentMethod
	Fit_method=G_currentMethod
	FitPara_wave[0]=Fit_method

	NVAR/z G_BleachPoint
	K_checkG_BleachPoint()

	NVAR/z G_currentNormalized //100204
	//variable normalized=FitPara_wave[1]	//out 100204
	variable normalized=G_currentNormalized //100204
	FitPara_wave[1] = G_currentNormalized //100204

	printf "%s (",G_CurrentExp
	printf "%s)\r",K_ReturnMethods(Fit_method)
	
	String decwave_xnm,decwave_ynm,Frapwave_ynm
	String Original_t,Original_Back,Original_Frap,Original_base,Original_AllCell
	Original_base=G_CurrentExp+"_base"	//050802
	Original_AllCell=G_CurrentExp+"_AllCell"
	Original_Back=G_CurrentExp+"_bkgAv"
	Original_Frap=G_CurrentExp+"_FRAP"
	Original_t=G_CurrentExp+"_t"
	
	String Norm_t,Norm_Back,Norm_Frap,Norm_base,Norm_AllCell //Normalized
	Norm_t=(Original_t+"_c")
	Norm_base=Original_base+"_norm"
	Norm_AllCell=Original_AllCell+"_norm"
	Norm_Back=Original_Back+"_norm"
	Norm_Frap=Original_Frap+"_norm"	
		
	if (G_doAveraged == 0)					//100210
		wave/z t_original=$Original_t			//100210
		wave/z Frap_original=$Original_Frap	//100210
		G_sdevwexists =0
	endif									//100210

	if ((G_dataFormSpec==1000) || (G_dataFormSpec==1001)) 
		make/o/n=(numpnts(t_original)) $Original_Back
		wave/z Back_Original=$Original_Back
		Back_Original[]=1
		FitPara_wave[3]=0	//reference is dummy
	else
		if ((G_dataFormSpec==1100) || (G_dataFormSpec==1101))
			FitPara_wave[3]=0		//reference is not existing, implicating the use of All Cell
		else
			FitPara_wave[3]=1
		endif
	endif
	variable FlatBackground		//checks if the back ground curve is flat.
	if (G_doAveraged ==0) 	//100210 
		wave/z AllCell_Original=$Original_AllCell
		wave/z Back_Original=$Original_Back
	else
		wave/z AllCell_Original=$Norm_AllCell	//100210 in case of averaged curve, original wave does not exist, so assign normalized wave for determining the flattness. 
		wave/z Back_Original=$Norm_Back	//100210  (might be problem with phair's method, since background then is not normalized???)
	endif 
				
	if (waveexists(AllCell_Original)) 
		FlatBackground=CheckFlatBackground(AllCell_Original)	//0 if it is flat
		printf "Allcell: FlatBackground=%g\r",FlatBackground	
	else
		if (waveexists(Back_Original)) 
			FlatBackground=CheckFlatBackground(Back_Original)	//0 if it is flat
			printf "Ref: FlatBackground=%g\r",FlatBackground	
		else
			FlatBackground=-1
		endif
	endif
	FitPara_wave[4]=FlatBackground
	
//""""""""""""' Normalization *********************************	

	if (G_doAveraged ==0)		//100204
		//variable I_Prebleach_Back_norm
		K_FrapCalcNormalizeCurves(FitPara_wave,normalized)	//050306
		//FitPara_wave[7]=I_Prebleach_Back_norm
		//I_Prebleach_FRAP_norm==always 1 050307
	else
		K_FrapCalcNormalizedCurves(FitPara_wave,normalized)	//100204 for averaged curve
	endif
	
	wave Frapwave=$Norm_Frap
	wave timewave=$Norm_t

	variable WholeCell_Exists,Ref_Exists,Base_Exists		
	WholeCell_Exists=FitPara_wave[15]
	Ref_Exists=FitPara_wave[16]
	Base_Exists=FitPara_wave[17]
	if (WholeCell_Exists) 
		wave AllCellWave=$Norm_AllCell
	endif		
	if (Ref_Exists) 
		wave RefWave=$Norm_Back
	endif		
	if (Base_Exists) 
		wave BaseWave=$Norm_base
	endif		

//****************************** Graphing all possible background **********************************
	//SVAR/z G_exp_name
	string WinNameFit=K_GraphWinname(G_CurrentExp)//,fit_method)
	
	if (Fit_method<3) //Rainer or Back Multiply
		DoWindow/f  $WinNameFit
		if (V_flag==0)
			if (WholeCell_Exists)
				Display/L=frapaxis AllCellWave vs timewave		
				ModifyGraph mode($Norm_AllCell)=3,marker($Norm_AllCell)=8,rgb($Norm_AllCell)=(16384,28160,65280)
				if (Ref_Exists)
					AppendToGraph/L=frapaxis RefWave vs timewave		
					ModifyGraph mode($Norm_Back)=3,marker($Norm_Back)=8,rgb($Norm_Back)=(16384,28160,65280)
				endif
			else
				if (Ref_Exists)
					Display/L=frapaxis RefWave vs timewave		
					ModifyGraph mode($Norm_Back)=3,marker($Norm_Back)=8,rgb($Norm_Back)=(16384,28160,65280)
				endif
			endif
			if ((WholeCell_Exists==1) || (Ref_Exists==1))
				ModifyGraph lblPos(frapaxis)=40
				Label frapaxis "Relative Fl. Intensity"
				Label bottom "Time [s]"
				SetAxis/A/E=0 frapaxis		
				DoWindow/c  $WinNameFit			//give the windowname
				DoWindow/T $WinNameFit, WinNameFit
			endif
		else
			if ((K_checkTraceInGraph(WinNameFit,Norm_AllCell)==0) && (WholeCell_Exists==1))
				appendtograph /L=frapaxis AllCellWave vs timewave
				ModifyGraph mode($Norm_AllCell)=3,marker($Norm_AllCell)=8,rgb($Norm_AllCell)=(16384,28160,65280)
			endif
	
			if ((K_checkTraceInGraph(WinNameFit,Norm_Back)==0) && (Ref_Exists==1))
				appendtograph /L=frapaxis RefWave vs timewave
				ModifyGraph mode($Norm_Back)=3,marker($Norm_Back)=8,rgb($Norm_Back)=(16384,28160,65280)
			endif
			if (K_checkTraceInGraph(WinNameFit,("fit_"+Norm_AllCell))==1)
				Removefromgraph/z $("fit_"+Norm_AllCell)
			endif
			if (K_checkTraceInGraph(WinNameFit,("fit_"+Norm_Back))==0)
				Removefromgraph/z $("fit_"+Norm_Back)
			endif

		endif
	endif

//""""""""""""' Decay study *********************************	
// only for rainer and backmultiply methods. 	
	variable 	invTau2,decA,decY0
	if (Fit_method==0)	//rainer
		if (WholeCell_Exists)
			K_FrapBackgroundGuess(AllCell_Original,timewave,FitPara_wave)
		else
			if (Ref_Exists)
				K_FrapBackgroundGuess(Back_Original,timewave,FitPara_wave)
			endif
		endif
	endif	
	if ((Fit_method==1) || 	(Fit_method==2))	//back-multiplication
		if (WholeCell_Exists)
			K_FrapBackgroundGuess(AllCellWave,timewave,FitPara_wave)
		else
			if (Ref_Exists)
				K_FrapBackgroundGuess(RefWave,timewave,FitPara_wave)
			endif
		endif
	endif

	decA=FitPara_wave[10]
	invTau2=	FitPara_wave[11]
	decY0=	FitPara_wave[12]

//""""""""""""' calc Gap Ratio *********************************	
	variable 	GapRatio	//calculated for all methods
	if (FlatBackground==0)
		GapRatio=1
	else
		if (G_doAveraged ==0) //100210
			GapRatio=K_retGapRatio(FitPara_wave)
		else	//100210 when fitting avaeraged curve, no original avaliable so avarage GapRatios of each curve 
			SVAR/z Gfilelist	//this should exist	//100210
			GapRatio=getAverageGApRatio(Gfilelist) //100210
		endif
	endif

//***************************************************
	if (Fit_method>3)		//double normalization don't have graph yet
		DoWindow/f  $WinNameFit
		if (V_flag==0)
			Display/L=frapaxis Frapwave vs timewave		
			ModifyGraph mode($Norm_Frap)=3,marker($Norm_Frap)=8
			ModifyGraph lblPos(frapaxis)=40
			Label frapaxis "Relative Fl. Intensity"
			Label bottom "Time [s]"
			SetAxis/A/E=0 frapaxis		
			DoWindow/c  $WinNameFit			//give the windowname
			DoWindow/T $WinNameFit, WinNameFit
		else
			if (K_checkTraceInGraph(WinNameFit,Norm_AllCell)==1)
				RemoveFromGraph/z $Norm_AllCell
				RemoveFromGraph/z $("fit_"+Norm_AllCell)
			endif
			if (K_checkTraceInGraph(WinNameFit,Norm_Back)==1)
				RemoveFromGraph/z $Norm_Back
				RemoveFromGraph/z $("fit_"+Norm_Back)
			endif			
		endif	
	endif
	if (K_checkTraceInGraph(WinNameFit,nameofwave(Frapwave))==0)
		AppendToGraph/L=frapaxis Frapwave vs timewave
		ModifyGraph mode($Norm_Frap)=3,marker($Norm_Frap)=8
		// 100210 here, error bars should be added with averaged.  	
	endif
	
//**************************fitting of the frap curve to derive Guessing values
	variable y0_guess,amplitude_guess,invTau1_guess
	if ((Fit_method!=6) && (Fit_method!=7))
//		CurveFit/W=0/Q exp Frapwave[G_BleachPoint,] /X=timewave /D
		CurveFit/W=0/Q exp Frapwave[G_BleachPoint,numpnts(Frapwave)-1] /X=timewave /D
		wave/z W_coef
		y0_guess=W_coef[0]
		amplitude_guess=W_coef[1]
		invTau1_guess=W_coef[2]
		printf "Frap Guess Values: A %g, invTau %g\r",amplitude_guess,invTau1_guess
	endif

//------------------------------fitting of the frap curve to get the real answer
	variable HL,invTau,amplitude,backTau
	variable tauD_guess
	variable DifCoef,tauD
	variable amplitude_Ellenberg_guess,DifCoef_guess
	variable y0,amplitudeA,invTauA,amplitudeB,invTauB
	variable x0offset //081210 double exp
	variable HLsd		//100429
	NVAR/z G_weight
	K_checkWeight()
	Duplicate/o Frapwave $(Norm_Frap+"w")
	wave/z frapweight=$(Norm_Frap+"w")

	NVAR/z G_WeightLowPnt,G_WeightHighPnt
	//****** Weighting and sandard deviation****************************************
	if (G_sdevwexists == 0)		//if SD of the curve is not available, then prebleach fluctuation is sampled and SD is estimated. 
		wavestats/q/r=[0,G_BleachPoint-1] Frapwave		//050814 for deriving measurement error
		variable sdev_measure=V_sdev
		variable avg_measure=V_avg
		//frapweight[]=Frapwave[p]*V_sdev/V_avg	//050816
		frapweight=sdev_measure
		printf "Standard Deviation of Curve is calculated from Pre-Bleach fluctuation: s.d. = %g\r", frapweight
		if (G_weight==1)		//  when "Weighting" in fit panel is clicked. Q value is not really relaiable then. 
			frapweight[K_FrapTimetoPnt(timewave,G_WeightLowPnt),K_FrapTimetoPnt(timewave,G_WeightHighPnt)]=sdev_measure*0.2
			//frapweight[]=frapweight[p]/2+0.1
			printf "...but weighting is applied between %g and %g so Q value is not reliable at all. (range limits became automatically off)\r", G_WeightLowPnt, G_WeightHighPnt
		endif
	//****** Weighting end****************************************
	else // if sd curve exists (treating averaged curve) 100204: not general at all. this should be modified to generalize
		string sdwname =G_CurrentExp+ "SD"+"_FRAP_norm"
		wave/z sdw=$sdwname
		frapweight[] = sdw[p]
		printf "Standard Deviation of Averaged Curve is used for fitting \r"
	endif
	
	NVAR/z G_checkLimitRange
	variable fit_start,fit_end
	if (G_checkLimitRange==1)
		fit_start=K_FrapTimetoPnt(timewave,G_WeightLowPnt)
		fit_end=K_FrapTimetoPnt(timewave,G_WeightHighPnt)
		printf "fittig is limited to a range between pnt %g and %g (weighting becomes automatically off)\r",fit_start,fit_end
	else
		fit_start=G_BleachPoint
		fit_end=numpnts(Frapwave)-1
	endif
//Prepare estimaiton curve
	string FrapFitnm="fit_"+Norm_Frap
	string FrapFit_estimationName="fit_"+Norm_Frap+"_est"
	Duplicate/O $Norm_Frap $FrapFit_estimationName
	wave FrapEst=$FrapFit_estimationName	
	
	string residuewavename,residueTwavename
	residuewavename=K_CreateResidueWave(Frapwave,timewave)
	wave/z residuewave=$residuewavename
	wave/z residueTwave=$(residuewavename+"t")

// Fitting and create estimation curve	
	variable V_FitTol=0.0001
	wave/z W_coef
	if (waveexists(W_coef) ==0) 
		make/n=20 W_coef
	endif
	NVAR/z G_currentWidth
	switch (fit_method)
		case 0:			//040330		Rainer's method
			//amplitude_guess*=-1
			amplitude_guess=0.9	//050804
			W_coef = {amplitude_guess,invTau1_guess,invTau2}
			FuncFit/W=0/H="001" FRAP W_coef Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0	//040317
			amplitude=W_coef[0]
			invTau=W_coef[1]
			backTau=W_coef[2]
			HL=(ln(0.5)/invTau*-1)		//040303
			FrapEst[]=amplitude/invTau*(invTau+BackTau)*(1-exp(-1*invTau*timewave[p]))				
			break

		case 1:		// background multiply single exponential 
			amplitude_guess=0.9	//050804
			//W_coef = {decA,amplitude_guess,invTau1_guess,invTau2,1}		//050812
			//W_coef = {decA,amplitude_guess,invTau1_guess,invTau2,(decY0/GapRatio)}		//040324//050812
			W_coef = {decA,amplitude_guess,invTau1_guess,invTau2,(decY0)}		//040324

			FuncFit/W=0/H="10011" FRAP4 W_coef Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0
			amplitude=W_coef[1]
			invTau=W_coef[2]
			backTau=W_coef[3]
			HL=(ln(0.5)/invTau*-1)		//040303
			//Duplicate/o Frapwave TempBack
			//TempBack[]=(decY0/GapRatio)+decA*exp(-1*invTau2*timewave[p])
			FrapEst[]=amplitude*(1-exp(-1*invTau*timewave[p]))			
			break

		case 2:		// background multiply double exponential //this doesn't work currently 050808
			amplitude_guess=0.9	//050804
			W_coef = {decA,amplitude_guess,invTau1_guess,invTau2,decY0}		//040324
			FuncFit/W=0/H="10011" FRAP4 W_coef Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0
			amplitude=W_coef[1]
			invTau=W_coef[2]
			backTau=W_coef[3]
			HL=(ln(0.5)/invTau*-1)		//040303
			
			FrapEst[]=amplitude*(1-exp(-1*invTau*timewave[p]))				
			break			

				
		case 6: //fitting to the single exponetial
			//amplitude_guess=0.9
			//W_coef = {y0_guess,amplitude_guess,invTau1_guess}
			//FuncFit/W=0/H="000" FRAP_exp2 W_coef Frapwave[G_BleachPoint,] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0	//040317
			CurveFit/W=0/Q/H="000" exp  Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0 
			y0=W_coef[0]
			amplitudeA=W_coef[1]
			invTauA=W_coef[2]
			
			FrapEst[]=y0+amplitudeA*exp(-1*invTauA*timewave[p])	
			HL=(ln(0.5)/invTauA*-1)		//040303			
			break

		case 7: //direct fitting of the double exponetial
				//modified on 081210: replace dblexp to dblexp_XOffset. added x0offset, changed equation. 
//			CurveFit/W=0/Q/H="00000" dblexp  Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0 
			CurveFit/W=0/Q/H="00000" dblexp_XOffset  Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0 

			//CurveFit/W=0/Q exp Frapwave_y[BleachPoint] /X=decwave_x /D
			wave/z W_coef
			y0=W_coef[0]
			amplitudeA=W_coef[1]
			invTauA=1/W_coef[2]	//081210
			amplitudeB=W_coef[3]
			invTauB=1/W_coef[4]	//081210
			wave/z W_fitConstants	//081210
			x0offset = W_fitConstants[0]	//081210
			printf "y0=%g, A1=%g, invTau1=%g A2=%g, invTau2=%g x0offset = %g\r",y0,amplitudeA,invTauA,amplitudeB,invTauB,x0offset 
			//FrapEst[]=y0+amplitudeA*(exp(-1*invTauA*timewave[p]))+amplitudeB*(exp(-1*invTauB*timewave[p]))	//out 081210		
			FrapEst[] = y0+amplitudeA*exp(-(timewave[p]-x0offset)*invTauA)+amplitudeB*exp(-(timewave[p]-x0offset)*invTauB)	//in 081210
						
			//HL=K_HalfLifeFromEst(FrapEst,timewave,y0,G_BleachPoint)			//071030 modified to below
			 HL = K_HalfLifeFromDoubleExpEst(FrapEst,timewave,y0,G_BleachPoint, y0, amplitudeA, amplitudeB, invTauA, invTauB, x0offset)
			 //K_HalfLifeFromDoubleExpEst(ywave,xwave,amplitude,startpoint, y0, ampA, ampB, tau1, tau2)
			break
		case 8://2:		//double normalized	diffusion - ellenberg 
			if (G_currentWidth==0)
				abort "Set Frap Width"
			endif
			amplitude_Ellenberg_guess=y0_guess	//040818 
			DifCoef_guess=K_DiffCoefestimateFromInvTau(invTau1_guess,y0_guess,amplitude_guess,G_currentWidth)	//040818 
			W_coef = {amplitude_Ellenberg_guess,G_currentWidth,DifCoef_guess}										//040429
			FuncFit/W=0/H="010" FRAP_Ellenberg W_coef Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0	//040429
			amplitude=W_coef[0]
			DifCoef=W_coef[2]
			//HL=(3*width^2)/4/pi/DifCoef				//040429
			//HL=(width^2)/12/pi/DifCoef					//040719
			HL=0.75*(G_currentWidth^2)/pi/DifCoef					//040719
			
//			FrapEst[]=W_coef[0]*(1-(width^2*(width^2+4*pi*DifCoef*decwave_x[p])^-1 ))^0.5/(decY0+decA*exp(invTau2*decwave_x[p]))
			FrapEst[]=W_coef[0]*(1-((G_currentWidth^2*(G_currentWidth^2+4*pi*DifCoef*timewave[p])^-1 ))^0.5)	//050307			
			break
		case 9://3:		//double normalized  diffusion soumpasis
			if (G_currentWidth==0)
				abort "Set Frap Width"
			endif		
			amplitude_Ellenberg_guess=y0_guess	//040818 
			DifCoef_guess=K_DiffCoefestimateFromInvTau(invTau1_guess,y0_guess,amplitude_guess,G_currentWidth)	//040818 
			W_coef = {amplitude_Ellenberg_guess,G_currentWidth,DifCoef_guess}										//040429
			FuncFit/W=0/H="010" FRAP_Ellenberg W_coef Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0	//040429
			
			//V_FitTol=0.01
			amplitude_guess=W_coef[0]
			tauD_guess=(G_currentWidth^2)/W_coef[2]	
			W_coef = {amplitude_guess,tauD_guess}
			//if (G_weight==1)
				FuncFit/W=0/H="00" FRAP_soumpasis W_coef Frapwave[fit_start,fit_end] /X=timewave/I=1/W=$(nameofwave(frapweight)) /D/R=$residuewavename/A=0	//050305
			//else
				//FuncFit/W=0/H="00" FRAP_soumpasis W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x /D	//050305
			//endif
			amplitude=W_coef[0]
			tauD=W_coef[1]
			DifCoef=(G_currentWidth^2)/tauD
			
//			FrapEst[]=(W_coef[0]*(e^(-1*W_coef[1]/2/decwave_x[p]))*( bessI(0,(W_coef[1]/2/decwave_x[p]))+bessI(1,(W_coef[1]/2/decwave_x[p])) ))/(decY0+decA*exp(invTau2*decwave_x[p]))		
			FrapEst[]=(W_coef[0]*(e^(-1*W_coef[1]/2/timewave[p]))*( bessI(0,(W_coef[1]/2/timewave[p]))+bessI(1,(W_coef[1]/2/timewave[p])) ))	
//			HL=K_SoumpasisHalfLife(FrapEst,timewave,amplitude,G_BleachPoint,Frapwave)		//made new HL function
			wave/z fitwave = $("fit_"+nameofwave(Frapwave))	//070827
			HL=K_SoumpasisHalfLife2(fitwave,amplitude)	//070827					
			break
		default:
		
	endswitch
	
	ModifyGraph/z lsize($("fit_"+nameofwave(Frapwave)))=2,rgb($("fit_"+nameofwave(Frapwave)))=(32768,40704,65280)
	
	NVAR/z G_chisq
	if (NVAR_exists(G_chisq)==0)
		variable/g G_chisq 
	endif
	G_chisq=V_chisq

	NVAR/z G_gammaq
	if (NVAR_exists(G_gammaq)==0)
		variable/g G_gammaq
	endif
	
	G_gammaq=gammq((V_npnts-2)/2, G_chisq/2)

	FrapEst[0,(G_BleachPoint-1)]=NaN
	printf "Half Max: %g [s]\r",HL				//040303

//Graphing 
	if (K_checkTraceInGraph(WinNameFit,nameofwave(FrapEst))==0)
		AppendToGraph/L=frapaxis FrapEst vs timewave
		ModifyGraph rgb($FrapFit_estimationName)=(52224,52224,0)
		ModifyGraph lstyle($FrapFit_estimationName)=3
	endif
	if (G_sdevwexists == 1)
		DoWindow/f  $WinNameFit
		ErrorBars/T=0 $(nameofwave(Frapwave)) Y,wave=($(nameofwave(sdw)),$(nameofwave(sdw)))
	endif
	K_AppendResidueWave(residuewave, residueTwave, WinNameFit) // residue plotting
	

////050714
//	K_GraphResidue(Frapwave,FrapEst,timewave)		
			
//Calculate Mobile-Immobile fractions

	variable MobileFraction, ImmobileFraction			//040303

	switch (fit_method)
		case 0:
			MobileFraction=(amplitude/invTau*(invTau+BackTau))/GapRatio
			break
		case 1: 
			//MobileFraction=amplitude/GapRatio
			MobileFraction=amplitude
			break			
		case 2: 
			//MobileFraction=amplitude/GapRatio
			MobileFraction=amplitude
			break			
		
		case 6:
			//MobileFraction=(y0)
			MobileFraction=(y0-FrapEst[G_BleachPoint])/(1-FrapEst[G_BleachPoint])
			break
		case 7:
			//MobileFraction=(y0)
			MobileFraction=(y0-FrapEst[G_BleachPoint])/(1-FrapEst[G_BleachPoint])
			break
		case 8:	//ellenberg 
			MobileFraction=(amplitude)		
			break			
		case 9: //soumpasis
			MobileFraction=(amplitude)		
			break	
	endswitch	

	if (MobileFraction>1)	//091026
		Printf "!!! The Mobile fraction was over 1 (%g)---\r",MobileFraction
		ImmobileFraction=0
		printf "Immobile Fraction: --\r"
		printf "Chi-Sq: %g   GammaQ: %g\r",G_chisq,G_gammaq	//040303
	else
		printf "Mobile Fraction: %g\r",MobileFraction				//040303
		ImmobileFraction=1-MobileFraction						//040303
		printf "Immobile Fraction: %g\r",ImmobileFraction			//040303
		printf "Chi-Sq: %g   GammaQ: %g\r",G_chisq,G_gammaq	//040303
	endif
	
	printf "%s	%g	%g	%g	%g	%g\r",G_CurrentExp,HL,MobileFraction,ImmobileFraction,G_chisq,G_gammaq	
	print "*******************************************************************"

	string BackName
	if (wholecell_exists)
		BackName=Norm_AllCell
	else
		BackName=Norm_Back
	endif
	
	string Txt1
	if (MobileFraction>1.5)	//081210	// 091026 changed from >1.0 to >1.5
				Txt1="\\Z08 Mobile Fraction >1.5: Check History log and your data"	
	else		
		switch (fit_method)
			case 0:
				Txt1="\\Z08\\s("+Norm_Frap+") FRAP Rainer A="+num2str(amplitude)+" iTau1="+num2str(invTau)+"\r\\s("
				Txt1+=BackName+") Background  iTau2="+num2str(backTau)+"\rHalf Max:"+num2str(HL)
				Txt1+="s Mobile: "+num2str(MobileFraction)+"\r\\s("+FrapFit_estimationName+") Estimation"
				Txt1+="\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break
			
			case 1:
				Txt1="\\Z08\\s("+Norm_Frap+") FRAP BackMulti A="+num2str(amplitude)+" iTau1="+num2str(invTau)
				Txt1+="\r\\s("+BackName+") Background  iTau2="+num2str(backTau)+"\rHalf Max:"+num2str(HL)
				Txt1+="s Mobile: "+num2str(MobileFraction)+"\r\\s("+FrapFit_estimationName+") Estimation"
				Txt1+="\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break
			
			case 2: //back multiply norm double exp			
				Txt1="\\Z08\\s("+Norm_Frap+") FRAP BackMulti A="+num2str(amplitude)+" iTau1="+num2str(invTau)
				Txt1+="\r\\s("+BackName+") Background  iTau2="+num2str(backTau)+"\rHalf Max:"+num2str(HL)
				Txt1+="s Mobile: "+num2str(MobileFraction)+"\r\\s("+FrapFit_estimationName+") Estimation"
				Txt1+="\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break
	
	
			case 6: //double norm single exp
				Txt1="\\Z08\\s("+Norm_Frap+") Single exponential\ry0="+num2str(y0)+"  A1="+num2str(amplitudeA)
				Txt1+="\riTau1="+num2str(invTauA)+"\rHalf Max:"+num2str(HL)+"s  Mob. Frac: "+num2str(MobileFraction)
				Txt1+="\r\\s("+FrapFit_estimationName+") Estimation"+"\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break
			
			case 7: //double norm dpouble exp
				Txt1="\\Z08\\s("+Norm_Frap+") Double exponential\ry0="+num2str(y0)+"\rA1="+num2str(amplitudeA)+"  iTau1="+num2str(invTauA)
				Txt1+="\rA2="+num2str(amplitudeB)+"  iTau2="+num2str(invTauB)+"\rHalf Max:"+num2str(HL)+"s  Mob. Frac: "+num2str(MobileFraction)
				Txt1+="\r\\s("+FrapFit_estimationName+") Estimation"+"\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break	
			case 8://2:	elllenberg
				Txt1="\\Z08\\s("+Norm_Frap+") FRAP Ellenberg\rA="+num2str(amplitude)+" Half Max:"+num2str(HL)+"s\rDiffusion Coef="+num2str(DifCoef)
				Txt1+="\r\\s("+FrapFit_estimationName+") Estimation"
				Txt1+="\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break
			case 9://3:	soumpasis
				Txt1="\\Z08\\s("+Norm_Frap+") FRAP Soumpasis\rA="+num2str(amplitude)+" Half Max:"+num2str(HL)+"s\rDiffusion Coef="+num2str(DifCoef)
				Txt1+="\r\\s("+FrapFit_estimationName+") Estimation"
				Txt1+="\rChiSq="+num2str(G_chisq)+" GammaQ="+num2str(G_gammaq)
				break
		endswitch
	endif
	//print Txt1	
	TextBox/W=$WinNameFit/C/N=text0/A=RB/F=0/B=1 Txt1
		
	K_FrapResultTable(HL,MobileFraction,ImmobileFraction)
	return HL
END


Function K_FrapResultTable(HL,MobileFraction,ImmobileFraction)
	Variable HL,MobileFraction,ImmobileFraction
	NVAR/z fit_method
	NVAR/z G_chisq
	NVAR/z G_gammaq
	SVAR/z G_CurrentExp
	wave W_coef
	wave W_sigma
	string ResultsWaveName=K_nameFrapResultsWave(G_CurrentExp)
	variable HLsd
	switch(fit_method)
		case 0:	
			Make/o/n=11 $ResultsWaveName
			wave FRAP_Results=$ResultsWaveName
			wave W_sigma
			HLsd = W_sigma[1] / W_coef[1] * HL	//100429
			FRAP_Results[0]=HL
			FRAP_Results[1]=HLsd //abs(W_sigma[1]*ln(0.5)/W_coef[1]/W_coef[1])		//HL s.d.	
			FRAP_Results[2]=MobileFraction
			FRAP_Results[3]=W_sigma[0]
			FRAP_Results[4]=ImmobileFraction
			FRAP_Results[5]=W_sigma[0]
			FRAP_Results[6]=W_coef[0]
			FRAP_Results[7]=W_coef[1]
			FRAP_Results[8]=W_coef[2]
			FRAP_Results[9]=G_chisq
			FRAP_Results[10]=G_gammaq
			Make/O/T/N=11 ResultParameterText
			ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A","InvTau1","DecayInvTau2","ChiSq","gammaQ"}
			break
		case 1:
			Make/o/n=13 $ResultsWaveName
			wave FRAP_Results=$ResultsWaveName
			wave W_sigma
			HLsd = W_sigma[2] / W_coef[2] * HL	//100429
			FRAP_Results[0]=HL
			FRAP_Results[1]=HLsd //abs(W_sigma[2]*ln(0.5)/W_coef[2]/W_coef[2])		//HL s.d.	
			FRAP_Results[2]=MobileFraction
			FRAP_Results[3]=W_sigma[1]
			FRAP_Results[4]=ImmobileFraction
			FRAP_Results[5]=W_sigma[1]
			FRAP_Results[6]=W_coef[1]		//A (Frap) 
			FRAP_Results[7]=W_coef[2]		//invtau1
			FRAP_Results[8]=W_coef[3]		//invtau2
			FRAP_Results[9]=W_coef[4]		//decay y0
			FRAP_Results[10]=W_coef[0]		//A (decay)
			FRAP_Results[11]=G_chisq
			FRAP_Results[12]=G_gammaq
			Make/O/T/N=13 ResultParameterText
			ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A","InvTau1","DecayInvTau2","DecayY0","DecayA","ChiSq","gammaQ"}

		case 2:

			break
	
		case 6:		//double norm single exp
			Make/o/n=14 $ResultsWaveName
			wave FRAP_Results=$ResultsWaveName
			wave W_sigma
			HLsd = W_sigma[2] / W_coef[2] * HL	//100429
			FRAP_Results[0]=HL
			FRAP_Results[1]=HLsd //abs(W_sigma[2]*ln(0.5)/W_coef[2]/W_coef[2])		//HL s.d.	
			FRAP_Results[2]=MobileFraction
			FRAP_Results[3]=W_sigma[0]
			FRAP_Results[4]=ImmobileFraction
			FRAP_Results[5]=W_sigma[0]
			FRAP_Results[6]=W_coef[1]	// A1 (Frap)
			FRAP_Results[7]=W_sigma[1]
			FRAP_Results[8]=W_coef[2]	//InvTau1
			FRAP_Results[9]=W_sigma[2]	//InvTau1 sd
			FRAP_Results[10]=W_coef[0]	// y0 (Frap)
			FRAP_Results[11]=W_sigma[0]
			FRAP_Results[12]=G_chisq
			FRAP_Results[13]=G_gammaq			
			Make/O/T/N=14 ResultParameterText
			ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A1","A1sd","invTau1","invTau1sd","y0","y0sd","ChiSq","gammaQ"}			
			//K_renameFrapResultsWave(G_exp_name)
			break	
		case 7:		//double norm double exp
			Make/o/n=18 $ResultsWaveName
			wave FRAP_Results=$ResultsWaveName
			wave W_sigma
			FRAP_Results[0]=HL
			FRAP_Results[1]=Nan //abs(W_sigma[1]*ln(0.5)/W_coef[1]/W_coef[1])		//HL s.d.	
			FRAP_Results[2]=MobileFraction
			FRAP_Results[3]=W_sigma[0]
			FRAP_Results[4]=ImmobileFraction
			FRAP_Results[5]=W_sigma[0]
			FRAP_Results[6]=W_coef[1]	// A1 (Frap)
			FRAP_Results[7]=W_sigma[1]
			FRAP_Results[8]=W_coef[2]	//invTau1
			FRAP_Results[9]=W_sigma[2]	//InvTau1 sd
			FRAP_Results[10]=W_coef[3]	// A2 (Frap)
			FRAP_Results[11]=W_sigma[3]
			FRAP_Results[12]=W_coef[4]	//invTau2
			FRAP_Results[13]=W_sigma[4]	//InvTau2 sd
			FRAP_Results[14]=W_coef[0]	// y0 (Frap)
			FRAP_Results[15]=W_sigma[0]
			FRAP_Results[16]=G_chisq
			FRAP_Results[17]=G_gammaq			
			Make/O/T/N=18 ResultParameterText
			ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A1","A1sd","invTau1","invTau1sd","A2","A2sd","invTau2","invTau2sd","y0","y0sd","ChiSq","gammaQ"}			//K_renameFrapResultsWave(G_exp_name)
			break	

		case 8:	//ellenberg
			Make/o/n=11 $ResultsWaveName
			wave FRAP_Results=$ResultsWaveName
			wave W_sigma
			HLsd = W_sigma[2] / W_coef[2] * HL					//100429 
			FRAP_Results[0]=HL
			FRAP_Results[1]= HLsd 		//HL s.d.	
			FRAP_Results[2]=MobileFraction
			FRAP_Results[3]=W_sigma[0]
			FRAP_Results[4]=ImmobileFraction
			FRAP_Results[5]=W_sigma[0]
			FRAP_Results[6]=W_coef[0]	//A (Frap)
			FRAP_Results[7]=W_coef[1]	//width
			FRAP_Results[8]=W_coef[2]	//Diffusion doefficient
			FRAP_Results[9]=G_chisq
			FRAP_Results[10]=G_gammaq						
			Make/O/T/N=11 ResultParameterText
			ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A","Width","Diffusion Coef","ChiSq","gammaQ"}			
			//K_renameFrapResultsWave(G_exp_name)
			break
		case 9:	//soumpasis
			Make/o/n=11 $ResultsWaveName
			wave FRAP_Results=$ResultsWaveName
			wave W_sigma
			FRAP_Results[0]=HL
			FRAP_Results[1]=Nan //abs(W_sigma[1]*ln(0.5)/W_coef[1]/W_coef[1])		//HL s.d.	
			FRAP_Results[2]=MobileFraction
			FRAP_Results[3]=W_sigma[0]
			FRAP_Results[4]=ImmobileFraction
			FRAP_Results[5]=W_sigma[0]
			FRAP_Results[6]=W_coef[0]	//A (Frap)
			FRAP_Results[7]=Nan
			FRAP_Results[8]=W_coef[1]	//Diffusion doefficient
			FRAP_Results[9]=G_chisq			
			FRAP_Results[10]=G_gammaq
			Make/O/T/N=11 ResultParameterText
			ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A","Width","Diffusion Coef","ChiSq","gammaQ"}			
			//K_renameFrapResultsWave(G_exp_name)
			break		
		default:
			
	endswitch

	 	
END

//050811
Function/s K_CreateResidueWave(Frapwave,timewave)
	wave Frapwave,timewave
	NVAR/z G_BleachPoint
	string residuewavename=nameofwave(Frapwave)+"Res"
	string residuetimewavename=nameofwave(Frapwave)+"Rest"
	Make/o/n=(numpnts(Frapwave)) $residuewavename,$residuetimewavename
	wave/z residuewave=$residuewavename
	wave/z residuetimewave=$residuetimewavename
	//residuewave[]=Frapwave[p+G_BleachPoint]-EstimationWave[p+G_BleachPoint]
	residuetimewave[G_BleachPoint,]=timewave[p]
	residuetimewave[,G_BleachPoint-1]=Nan

	return residuewavename
END	

//050811
Function K_AppendResidueWave(residuewave, residuetimewave, WinNameFit)
	wave residuewave, residuetimewave
	string WinNameFit
	//SVAR/z G_exp_name
	//string WinNameFit=K_GraphWinname(G_exp_name)//,fit_method)
	DoWindow/f  $WinNameFit
	if (V_flag==1)
		if (K_checkTraceInGraph(WinNameFit,nameofwave(residuewave))==0)	
			AppendtoGraph/L=residueaxis residuewave vs residuetimewave
			ModifyGraph axisEnab(frapaxis)={0,0.8},axisEnab(residueaxis)={0.83,1}
			ModifyGraph zero(residueaxis)=2
			ModifyGraph mode($(nameofwave(residuewave)))=2
			ModifyGraph margin(left)=50
			ModifyGraph freePos(frapaxis)=0,freePos(residueaxis)=0
			ModifyGraph lblPos(residueaxis)=40
			ModifyGraph lsize($(nameofwave(residuewave)))=2
		endif	
	endif	
END



Function K_FrapAnalDoMultiAtOnceV2(method)		//040318
	variable method		// 0: normalize independent, 1:normalize coordinately
	String path_name
	prompt path_name, "Path name?"
	String exp_namep
	prompt exp_namep, "Prefix of the File?"
	Variable exp_num
	prompt exp_num, "How many experiments?"	
	Doprompt "Path,Name and No.::",path_name,exp_namep,exp_num
	if (V_flag)
		Abort "Processing Canceled"
	endif	
	variable j
	Make/o/N=(exp_num) $(exp_namep+"HL")
	wave HLwave=$(exp_namep+"HL")
//	variable BleachPoint=10		//040303
	string exp_name
	Variable/g Fit_method=method
	for (j=1;j<(exp_num+1);j+=1)
		exp_name=exp_namep+num2str(j)	//040303
		K_importFrapTxtDataV2Multi(path_name,exp_name,exp_num)		//040303
//		if (method==0)
//			HLwave[j-1]= K_FrapCalc2_coreV2_norm(exp_name)				//040318
//		else // method=1
			HLwave[j-1]= K_FrapCalc_main(exp_name)//,method)
//		endif
	endfor
	wavestats/q HLwave
	variable sem
	sem=V_sdev/V_npnts^0.5
	execute "TileWindows/O=1/C"
	printf "\r\r\rExperiment %s ::\rHalf Life Ave=%g \rs.d.=%g\rs.e.m.=%g\rn=%g\r",exp_name,V_avg,V_sdev,sem,V_npnts
		
END


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function K_FrapCalc_main(exp_name)//,method)			//040324
	String	exp_name	
	variable HL
	HL=K_FrapCalcCore()//,method)
	return HL
END

//for calling from menu but unused from 050811
Function K_FrapCalc4(method)		//040324 normalized version of calc2
	Variable method
	String	Frapwave_xnm
	Variable timepoint0
	String	exp_name	
	prompt	exp_name,"Name of Experiment?"
	Doprompt "Name",exp_name

	if (V_flag)
		Abort "Processing Canceled"
	endif

	K_CheckAllGV()

	NVAR/z G_BleachPoint
	SVAR/z G_exp_Name
	G_exp_Name=exp_name
	NVAR/z Fit_method 
	Fit_method=method

	K_FrapCalc_main(exp_name)//,method)	
END

//******************************** Diffusion **************************************************

Function K_FrapCalcDiffusion(method)		//040324 normalized version of calc2
	Variable method
	String	Frapwave_xnm
	Variable timepoint0
	String	exp_name	
	prompt	exp_name,"Name of Experiment?"
	Variable	normalized	
	prompt	Normalized,"Already Normalized?",popup "no;yes;"
	Variable	width	
	prompt	width,"Bleach Width?"
	Doprompt "Name",exp_name,normalized,width

	if (V_flag)
		Abort "Processing Canceled"
	endif

	K_CheckAllGV()

	Normalized-=1	
	NVAR/z Fit_method
	Fit_method=method
	SVAR/z G_exp_Name
	G_exp_Name=exp_name
	K_FrapCalc_main(exp_name)		
END

//************************************ PANEL components ***************************************//

function/s K_FrapListExperiments()
	string timewavelist=wavelist("*_t",";","")
	string expnamelist=""
	string tempst
	variable i
	if (itemsinlist(timewavelist)==0)
		expnamelist+="none"
	else
		for (i=0;i<itemsinlist(timewavelist);i+=1)
			tempst=stringfromlist(i,timewavelist)
			expnamelist+=tempst[0,strlen(tempst)-3]+";"
		endfor
	endif
	return expnamelist
end

Function K_FrapFitPanel() : Panel
	Dowindow/f $("FitPanel")
	if (V_flag==0)
		K_CheckAllGV()
		
		NVAR/z G_BackStartPnt	//050808
		NVAR/z G_currentMethod
		NVAR/z Fit_method
		SVAR/z G_MethodList
		SVAR/z G_exp_Name
		SVAR/z G_CurrentExp
		G_exp_Name=G_CurrentExp
		if (SVAR_exists(G_MethodList)==0)
			//string/g G_MethodList="exponential -Rainer;exponential -BackMultiply;exponential -Back Correct1;exponential -Back Correct2;diffusion-Ellenberg;diffusion-Soumpasis;DoubleNorm-Single Exp;DoubleNorm-Double Exp"
			string/g G_MethodList="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
		else
			G_MethodList="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
		endif
		PauseUpdate; Silent 1		// building window...
		NewPanel/K=1 /W=(782,49,1070,265)
		//ShowTools
		PopupMenu popup0,title="Experiment",pos={5,5},size={100,21},proc=K_expnPopMenuProc
		PopupMenu popup0,mode=1,bodyWidth= 100,popvalue=stringfromlist(0,K_FrapListExperiments()),value=K_FrapListExperiments()//value= # "\"Yes;No\""
		PopupMenu popup1,title="Fit Model",pos={5,30},size={150,21},proc=K_fitmethodPopMenuProc
//		PopupMenu popup1,mode=1,bodyWidth= 150,popvalue=stringfromlist(G_currentMethod,G_MethodList),value=# G_MethodList	
//		PopupMenu popup1,mode=1,bodyWidth= 150,popvalue=stringfromlist(G_currentMethod,G_MethodList),value=# ReturnMethodList() //080312
		PopupMenu popup1,mode=1,bodyWidth= 150,popvalue=stringfromlist(G_currentMethod,G_MethodList),value=# "G_MethodList" 	//080312	
		
		CheckBox check0,pos={168,9},size={108,14},title="Normalized Original",variable=G_currentNormalized
	
		SetVariable setvar0 title="Frap Width (µm)",pos={5,101},size={120,20},limits={0.1,1000,0.1},fSize=11,value=G_currentWidth
		SetVariable setvar3 title="Bleach Pnt",pos={5,58},size={100,20},limits={0,1000,1},value=G_BleachPoint
		SetVariable setvar3 proc=K_BleachOntSetVarProc
		SetVariable BackStartPnt title="Back Starts:",pos={15,79},size={100,14},value=G_BackStartPnt,limits={0,Inf,1},fSize=11
		CheckBox check1,pos={140,83},size={108,14},title="Weighting",proc=WeightCheckProc,variable=G_weight
		SetVariable setvar1 title="Start time pnt",pos={166,100},size={110,20},value=G_WeightLowPnt
		SetVariable setvar2 title="End time pnt",pos={166,122},size={110,20},value=G_WeightHighPnt
		CheckBox checkLimitRange title="Limit",pos={215,83},proc=LimitRangeCheckProc,variable=G_checkLimitRange		
		Button button0 title="Fit !",pos={5,125},proc=K_FrapDoFitButtonProc
		DrawLine 0,147,280,147
		SetDrawEnv fillpat= 0
		DrawRRect 130,75,285,143
		
		K_expo_OneOutOfThree()
		NVAR/z G_ExpoRainer
		NVAR/z G_ExpoPhair
		NVAR/z G_ExpoBackMult
//		CheckBox checkRainer title="Rainer",pos={203,36},proc=CheckProcRainer,value=0,variable=G_ExpoRainer,fSize=11
//		CheckBox checkBackMulti title="Back Multi",pos={203,48},proc=CheckProcBackMulti,value=0,variable=G_ExpoBackMult,fSize=11
//		CheckBox checkPhair title="Phair",pos={203,60},proc=CheckProcPhair,value=0,variable=G_ExpoPhair,fSize=11

		CheckBox checkRainer title="Rainer",pos={203,36},proc=CheckProcNormalizationMethod,value=0,variable=G_ExpoRainer,fSize=11
		CheckBox checkBackMulti title="Back Multi",pos={203,48},proc=CheckProcNormalizationMethod,value=0,variable=G_ExpoBackMult,fSize=11
		CheckBox checkPhair title="Phair",pos={203,60},proc=CheckProcNormalizationMethod,value=0,variable=G_ExpoPhair,fSize=11

		DoWindow/c $("FitPanel")
	endif
EndMacro

Function WeightCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR/z G_checkLimitRange
	if (checked)
		G_checkLimitRange=0
	//else
	//	G_checkLimitRange=1	
	endif
End

Function LimitRangeCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR/z G_weight
	if (checked)
		G_weight=0
	//else
	//	G_weight=1	
	endif
End

Function K_BleachOntSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR/z G_BackStartPnt
	G_BackStartPnt=varNum
End

Function CheckProcNormalizationMethod(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR/z G_ExpoRainer
	NVAR/z G_ExpoBackMult
	NVAR/z G_ExpoPhair
	NVAR/z G_currentMethod

	K_checkG_currentMethodPopMenu()
	NVAR/z G_currentMethodPopMenu
		
	G_ExpoRainer=checked
	CheckBox $ctrlName value=checked
	if (checked==1)
		strswitch(ctrlName)	

			case "checkRainer":
				G_ExpoBackMult=0
				G_ExpoPhair=0

				switch (G_currentMethodPopMenu)
					case 1:
						G_currentMethod=0
						break
					default :		//other Normalization is impossible by Rainer's method -1
						G_currentMethod=-1
					 	break
				endswitch

				break

			case "checkBackMulti":
				G_ExpoRainer=0
				G_ExpoPhair=0

				switch (G_currentMethodPopMenu)
					case 1:
						G_currentMethod=1		//back multiply; single exp::not implemented yet
						break
					case 2:
						G_currentMethod=2		//back multiply; double exp:: not implemented yet
						break
					case 3:
						G_currentMethod=4		//back multiply; Ellenberg:: not modified yet
						break
					case 4:
						G_currentMethod=5		//back multiply; soumpasis:: not modified yet
						break
				endswitch
				break

			case "checkPhair":
				G_ExpoRainer=0
				G_ExpoBackMult=0
				switch (G_currentMethodPopMenu)
					case 1:
						G_currentMethod=6		//Phair Normalization; single exp
						break
					case 2:
						G_currentMethod=7		//Phair Normalization; double exp
						break
					case 3:
						G_currentMethod=8		//Phair Normalization;:: not implemented yet
						break
					case 4:
						G_currentMethod=9		//Phair Normalization;:: not implemented yet
						break
				endswitch

				break
		endswitch
	else
		// 1 automatic check on for the other if there where only two
		// 2	cannnot turn off check if there is only one	
	endif	
//	K_expo_OneOutOfThree()
End






//050809
Function K_expnPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	checkG_CurrentExp()
	SVAR/z G_CurrentExp
	G_CurrentExp=popStr
	
//	SVAR/z G_CurrentExp
	variable Current_dataform=checkG_dataFormSpecific(G_CurrentExp)
	SVAR/z G_MethodList
//	switch (Current_dataform)
//		case 0:
//			G_MethodList="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
//			break
//		case 1:
//			//G_MethodList="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
//			G_MethodList="single exponential;double exponential"
//			break
//		case 2:
////			G_MethodList="exponential -Rainer;exponential -BackMultiply;exponential -Back Correct1;exponential -Back Correct2;diffusion-Ellenberg;diffusion-Soumpasis;DoubleNorm-Single Exp;DoubleNorm-Double Exp"
//			G_MethodList="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
//			break
//	endswitch
	G_MethodList="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
//	PopupMenu popup1,value=# G_MethodList	
//	PopupMenu popup1,value=# ReturnMethodList()	//080312
	PopupMenu popup1,value=# "G_MethodList"	//080312
	ControlUpdate/W=$("FitPanel") popup1
End

//080312 but unused
//function/s ReturnMethodList()
//	Nvar/z switchtext
//	string returnstring 
//	if (switchtext==0) 
//		returnstring ="single exponential;double exponential;diffusion-Ellenberg;diffusion-Soumpasis"
//	else
//		returnstring ="a; b; c; d"
//	endif
//	return  returnstring
//end

Function K_checkAtLeastOneOutThree()
	NVAR/z G_ExpoRainer
	NVAR/z	G_ExpoBackMult
	NVAR/z G_ExpoPhair
	if ((G_ExpoRainer+G_ExpoBackMult+G_ExpoPhair)==0)
		G_ExpoRainer=1
	endif
end

Function K_checkAtLeastOneOutTwo()
	NVAR/z	G_ExpoBackMult
	NVAR/z G_ExpoPhair
	if ((G_ExpoBackMult+G_ExpoPhair)==0)
		G_ExpoBackMult=1
	endif
end

Function K_checkAtLeastOneOutTwoCase2()
	NVAR/z G_ExpoRainer
	NVAR/z	G_ExpoBackMult
	if ((G_ExpoBackMult+G_ExpoRainer)==0)
		G_ExpoRainer=1
	endif
end

Function K_fitmethodPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	//checkG_currentMethod()
	NVAR/z G_currentMethod
	SVAR/z G_CurrentExp
	SVAR/z G_exp_Name

	G_exp_Name=G_CurrentExp
	
	checkG_dataFormSpecific(G_exp_Name)

	NVAR/z G_dataFormSpec=$(G_exp_Name+"_dataform")
		
	NVAR/z G_ExpoRainer
	NVAR/z	G_ExpoBackMult
	NVAR/z G_ExpoPhair

//	K_checkG_currentMethodPopMenu()
	NVAR/z G_currentMethodPopMenu
	G_currentMethodPopMenu=popnum

	switch (popnum)
		case 1:	//single exponential
			switch (G_dataFormSpec)
				case 1000:		//FRAP		
					CheckBox checkRainer disable=0
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
					//G_ExpoRainer=1
					//G_ExpoBackMult=0
					//G_ExpoPhair=0
					//K_checkAtLeastOneOutTwoCase2()
					K_checkAtLeastOneOutThree()
					break
				case 1010:		//FRAP-Reference		
					CheckBox checkRainer disable=0
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
//					K_checkAtLeastOneOutTwoCase2()
					K_checkAtLeastOneOutThree()
					break
				case 1101:		//FRAP-Base-AllCell
					CheckBox checkRainer disable=0
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
					K_checkAtLeastOneOutThree()
					break
				case 1111:		//FRAP-Base-AllCell-Reference
					CheckBox checkRainer disable=0
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
					K_checkAtLeastOneOutThree()
					break
			endswitch			

			if (G_ExpoRainer==1)
				G_currentMethod=0	//Rainer-single exponential
			endif
			if (G_ExpoBackMult==1)
				G_currentMethod=1	//Back Multiply-single exponential 
			endif
			if (G_ExpoPhair==1)
				G_currentMethod=6	//Double Normalization - single exponential
			endif			
			break
		case 2:	//double exponential
			//CheckBox checkRainer title="Rainer",pos={203,36},proc=CheckProcRainer,value=0,variable=G_ExpoRainer,fSize=11
			G_ExpoRainer=0
			switch (G_dataFormSpec)
				case 1000:		//FRAP		not implemented yet
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
//					G_ExpoBackMult=1
//					G_ExpoPhair=0
					K_checkAtLeastOneOutTwo()
					break
				case 1010:		//FRAP-Reference
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
//					G_ExpoBackMult=1
//					G_ExpoPhair=0
					K_checkAtLeastOneOutTwo()
					break
				case 1101:		//FRAP-Base-AllCell
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
					K_checkAtLeastOneOutTwo()
					break
				case 1111:		//FRAP-Base-AllCell-Reference
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=0
					CheckBox checkPhair disable=0
					K_checkAtLeastOneOutTwo()
					break
			endswitch				
			if (G_ExpoBackMult==1)
				G_currentMethod=2	//Back Multiply Double exponential
			endif
			if (G_ExpoPhair==1)
				G_currentMethod=7	//Double Normalization  double exponential
			endif			
			break
		case 3:	//diffusion ellenberg
			G_ExpoRainer=0
//			CheckBox checkRainer disable=2
//			CheckBox checkBackMulti disable=0
//			CheckBox checkPhair disable=0		
//			K_checkAtLeastOneOutTwo()
			switch (G_dataFormSpec)
				case 1000:		//FRAP		
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
				case 1010:		//FRAP-Reference
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
				case 1101:		//FRAP-Base-AllCell
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
//					K_checkAtLeastOneOutTwo()
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
				case 1111:		//FRAP-Base-AllCell-Reference
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
//					K_checkAtLeastOneOutTwo()
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
			endswitch
			
			if (G_ExpoBackMult==1)
				G_currentMethod=4	//Back Multiply Ellenberg
			endif
			if (G_ExpoPhair==1)
				G_currentMethod=8	//Double Normalization  ellenberg
			endif
			break

		case 4:	//diffusion soumpasis
			G_ExpoRainer=0
//			CheckBox checkRainer disable=2
//			CheckBox checkBackMulti disable=0
//			CheckBox checkPhair disable=0		
//			K_checkAtLeastOneOutTwo()
			switch (G_dataFormSpec)
				case 1000:		//FRAP		not implemented yet
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
				case 1010:		//FRAP-Reference
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
				case 1101:		//FRAP-Base-AllCell
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
				case 1111:		//FRAP-Base-AllCell-Reference
					CheckBox checkRainer disable=2
					CheckBox checkBackMulti disable=2
					CheckBox checkPhair disable=0
					G_ExpoRainer=0
					G_ExpoBackMult=0
					G_ExpoPhair=1
					break
			endswitch
			if (G_ExpoBackMult==1)
				G_currentMethod=5	//Back Multiply Soumpasis
			endif
			if (G_ExpoPhair==1)
				G_currentMethod=9	//Double Normalization  Soumpasis
			endif

			break
	endswitch
	
	//G_currentMethod=popNum-1
End

Function K_FrapDoFitButtonProc(ctrlName) : ButtonControl
	String ctrlName
	NVAR/z G_currentMethod
	NVAR/z Fit_method
	Fit_method=G_currentMethod
	SVAR/z G_CurrentExp
	SVAR/z G_exp_Name
	if (cmpstr(G_CurrentExp, "Averaged") == 0)
		SVAR/z Gfilelist
		if (SVAR_exists(Gfilelist))
			string currentsource
			currentsource = stringfromlist(0, Gfilelist)
			G_CurrentExp = currentsource[0, strlen(currentsource)-5]
		else
			abort "experiment name with 'Averaged' is reserved and cannot be used"
		endif
	endif
	G_exp_Name=G_CurrentExp
	
	NVAR/z G_currentNormalized
	NVAR/z G_currentWidth
	
	checkG_dataFormSpecific(G_exp_Name)
	NVAR/z G_dataFormSpec=$(G_exp_Name+"_dataform")
	
	NVAR/z G_doAveraged  	//100210
	G_doAveraged = 0		//100210
		
	switch (G_currentMethod)
		case 0:		//Rainer - single exponential
			//if (G_dataFormSpec==1)
//			if (G_dataFormSpec<=1001)
//				abort "Not a proper data set for this fitting"
//			endif
			K_FrapCalc_main(G_exp_Name)
			break
		case 1:		//BackGroundMultiply-single exponential 
			//if (G_dataFormSpec==1)
			//abort "Not ready yet"
			//endif
			K_FrapCalc_main(G_exp_Name)
			//K_FrapCalc_main(G_exp_Name)
			break
		case 2:		//BackGroundMultiply-double exponential
			abort "Not ready yet"
			//K_FrapCalc_main(G_exp_Name)
			break
		case 3:
					
			break
		case 4:	//back multiply Ellenberg diffusion
			//if (G_dataFormSpec==1)
			//	abort "Not a proper data set for this fitting"
			//endif
		
			K_FrapCalc_main(G_exp_Name)
			break
		case 5:	//back multiply Soumpasis
//			if (G_dataFormSpec==1)
//				abort "Not a proper data set for this fitting"
//			endif

			K_FrapCalc_main(G_exp_Name)	
			break
		case 6:	//6: Double Normalization, single exponential
//			if ((G_dataFormSpec<1101) && (G_dataFormSpec!=1001))
//				abort "Not a proper data set for this fitting"
//			endif

			K_FrapCalc_main(G_exp_Name)
			break
		case 7:	//7: Double Normalization, double exponential
//			if ((G_dataFormSpec<1101) && (G_dataFormSpec!=1001))
//				abort "Not a proper data set for this fitting"
//			endif
		
			K_FrapCalc_main(G_exp_Name)		
			break
		case 8:	//6: Double Normalization, Ellenberg
//			if ((G_dataFormSpec<1101) && (G_dataFormSpec!=1001))
//				abort "Not a proper data set for this fitting"
//			endif

			K_FrapCalc_main(G_exp_Name)
			break
		case 9:	//7: Double Normalization, Soumpasis
//			if ((G_dataFormSpec<1101) && (G_dataFormSpec!=1001))
//				abort "Not a proper data set for this fitting"
//			endif
		
			K_FrapCalc_main(G_exp_Name)		
			break										
	endswitch			
	K_frapPanelInfo()
End

Function K_frapPanelInfo()
	Dowindow/f $("FitPanel")
	if (V_flag==1)
		string infotext1,infotext2,infotext3,infotext4,infotext5,infotext6
		NVAR/z Fit_method
		SVAR/z G_CurrentExp
		NVAR/z G_chisq
		wave/z FRAP_Results=$K_nameFrapResultsWave(G_CurrentExp)
		NVAR/z V_chisq
		infotext1=G_CurrentExp
		switch (Fit_method)
			case 0:
				infotext1+=" :Single Exponential fit -Rainer's method"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="A:"+num2str(FRAP_Results[6])+" invTau:"+num2str(FRAP_Results[7])+" DecayTau:"+num2str(FRAP_Results[8])
				infotext4="Mob:"+num2str(FRAP_Results[2])+ " Immob:"+num2str(FRAP_Results[4])
				infotext5=""
				break
			case 1:
				infotext1+=" : Single Exponential fit -Back Multiply"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="Frap:: A:"+num2str(FRAP_Results[6])+" invTau:"+num2str(FRAP_Results[7])
				infotext4="Decay:: A:"+num2str(FRAP_Results[10])+" invTau:"+num2str(FRAP_Results[8])+" y0:"+num2str(FRAP_Results[9])
				infotext5="Mobile:"+num2str(FRAP_Results[2])+ "Immobile:"+num2str(FRAP_Results[4])
				break
			case 2:
				infotext1+=" :Double  Exponential fit -Back Multiply"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="Frap:: A:"+num2str(FRAP_Results[6])+" invTau:"+num2str(FRAP_Results[7])
				infotext4="Decay:: A:"+num2str(FRAP_Results[10])+" invTau:"+num2str(FRAP_Results[8])+" y0:"+num2str(FRAP_Results[9])
				infotext5="Mobile:"+num2str(FRAP_Results[2])+ "Immobile:"+num2str(FRAP_Results[4])
				break
			case 3:
				infotext1+=" : none"
//				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
//				infotext3="Frap:: A:"+num2str(FRAP_Results[6])+" invTau:"+num2str(FRAP_Results[7])
//				infotext4="Decay:: A:"+num2str(FRAP_Results[10])+" invTau:"+num2str(FRAP_Results[8])+" y0:"+num2str(FRAP_Results[9])
//				infotext5="Mobile:"+num2str(FRAP_Results[2])+ "Immobile:"+num2str(FRAP_Results[4])
				break

			case 6:
				infotext1+=" : Single Exponential - Double Normalization"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="y0:"+num2str(FRAP_Results[10])+"A:"+num2str(FRAP_Results[6])+" invTau:"+num2str(FRAP_Results[8])
				infotext4="Mob:"+num2str(FRAP_Results[2])+ " Immob:"+num2str(FRAP_Results[4])
				infotext5=""
				break				

			case 7:
				infotext1+=" : Double Exponential Double Normalization"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="y0:"+num2str(FRAP_Results[14])+"A1:"+num2str(FRAP_Results[6])+" invTau1:"+num2str(FRAP_Results[8])
				infotext4="A2:"+num2str(FRAP_Results[10])+" invTau2:"+num2str(FRAP_Results[12])
				infotext5="Mob:"+num2str(FRAP_Results[2])+ " Immob:"+num2str(FRAP_Results[4])
				break
			case 8:
				infotext1+=" : Diffusion fit -Ellenberg Double Norm"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="A:"+num2str(FRAP_Results[6])+" laser Width:"+num2str(FRAP_Results[7])
				infotext4="Diffusion Coef:"+num2str(FRAP_Results[8])
				infotext5="Mobile:"+num2str(FRAP_Results[2])+ "Immobile:"+num2str(FRAP_Results[4])
				break
			case 9:
				infotext1+=" : Diffusion fit -Soumpasis  Double Norm"
				infotext2="HL="+num2str(FRAP_Results[0])+"±"+num2str(FRAP_Results[1])+"       Chi^2: "+num2str(G_chisq)
				infotext3="A:"+num2str(FRAP_Results[6])//+" laser Width:"+num2str(FRAP_Results[7])
				infotext4="tauD:"+num2str(FRAP_Results[8])
				infotext5="Mobile:"+num2str(FRAP_Results[2])+ "Immobile:"+num2str(FRAP_Results[4])
				break				
		
		endswitch
		SetDrawLayer/k UserBack
		SetDrawLayer UserBack
				
		SetDrawEnv fsize= 11;DrawText 10,165,infotext1
		SetDrawEnv fsize= 10;DrawText 15,178,infotext2
		SetDrawEnv fsize= 10;DrawText 15,189,infotext3
		SetDrawEnv fsize= 10;DrawText 15,200,infotext4
		SetDrawEnv fsize= 10;DrawText 15,211,infotext5
		DrawLine 0,147,280,147
		SetDrawEnv fillpat= 0
		DrawRRect 130,75,285,143		
		
	endif
End

//**************************** Panel things down to here *************************************************************

//******************  For Heiko, averaging multiple results

Function K_MultiAnalysisAveFit(mode)		//040318
	variable mode
	string exp_namep
	prompt exp_namep, "Prefix of the File?"
	Variable exp_num
	prompt exp_num, "How many experiments?"
	Doprompt "Exp Name and No.::",exp_namep,exp_num
	if (V_flag)
		Abort "Processing Canceled"
	endif
		
	variable j
	string exp_name
	string resultwavename
	string HLwavename,HLsdwavename,MobileFwavename,MobileFsdwavename,ImmobileFwavename,ImmobileFsdwavename,Awavename,iT1wavename,iT2wavename

		exp_name=exp_namep
		HLwavename=exp_name+"_HL"
		HLsdwavename=exp_name+"_HLsd"
		MobileFwavename=exp_name+"_Mo"
		MobileFsdwavename=exp_name+"_Mosd"
		ImmobileFwavename=	exp_name+"_Imo"
		ImmobileFsdwavename=exp_name+"_Imosd"
		Awavename=exp_name+"_A"
		iT1wavename=exp_name+"_iT1"
		iT2wavename=exp_name+"_iT2"
		Make/O/N=(exp_num) $HLwavename,$HLsdwavename,$MobileFwavename,$MobileFsdwavename,$ImmobileFwavename,$ImmobileFsdwavename,$Awavename,$iT1wavename,$iT2wavename
		wave HLw=$HLwavename
		wave HLsdw=$HLsdwavename
		wave Mobw=$MobileFwavename
		wave Mobsdw=$MobileFsdwavename
		wave Imow=$ImmobileFwavename
		wave Imosdw=$ImmobileFsdwavename
		wave Awave=$Awavename
		wave iT1wave=$iT1wavename
		wave iT2wave=$iT2wavename	
			
	for (j=1;j<(exp_num+1);j+=1)

		exp_name=exp_namep+num2str(j)	//040303
		resultwavename=exp_name+"_FRAP_Results"
		wave resultwave=$resultwavename
		HLw[j-1]=resultwave[0]
		HLsdw[j-1]=resultwave[1]
		Mobw[j-1]=resultwave[2]
		Mobsdw[j-1]=resultwave[3]
		Imow[j-1]=resultwave[4]
		Imosdw[j-1]=resultwave[5]
		Awave[j-1]=resultwave[6]
		iT1wave[j-1]=resultwave[7]
		iT2wave[j-1]=resultwave[8]
	endfor
	Variable A_ave,A_sd,iT1_ave,iT1_sd
	variable Mob_ave,Mob_sd,Imob_ave
	wavestats/q Awave
	A_ave=V_avg
	A_sd=V_sdev
	wavestats/q iT1wave
	iT1_ave=V_avg
	iT1_sd=V_sdev
	wavestats/q Mobw
	Mob_ave=V_avg
	Mob_sd=V_sdev
	Imob_ave=1-Mob_ave
	
//	variable HL=(ln(0.5)/iT1_ave*-1)						//040319
//	variable HLsd=abs(iT1_sd*ln(0.5)/iT1_ave/iT1_ave)	//040319
//	printf "Half Life is %g±%g [s]\r",HL,HLsd				//040319
	wavestats/q HLw
	variable HL=V_avg					//040319
	variable HLsd=V_sdev					//040319
	printf "Half Life is %g±%g [s]\r",HL,HLsd				//040319
	
	String AveCurveName=exp_namep+"_FrapEstAve"
	Make/O/N=100 $AveCurveName
	wave FrapEstAve=$AveCurveName
	SetScale/P x 0,0.5,"", FrapEstAve
	FrapEstAve[]=A_ave*(1-exp(-1*iT1_ave*x))
	if (mode==0)
		Display FrapEstAve
		Label left "Relative Fl. Intensity"
		Label bottom "Time [s]"
		SetAxis left -0.1,1.1 			
	else
		AppendtoGraph FrapEstAve
		ModifyGraph rgb($AveCurveName)=(0,15872,65280)
	endif
//	string Txt1="\\Z08\\s("+AveCurveName+") "+exp_namep+ " FRAP ave (n="+num2str(exp_num)+")\rA="+num2str(A_ave)+"±"+num2str(A_sd)+"\riTau1="+num2str(iT1_ave)+"±"+num2str(iT1_sd)+"\rHL="+num2str(HL)+"±"+num2str(HLsd)+"[s]"
	string Txt1="\\Z08\\s("+AveCurveName+") "+exp_namep+ " FRAP ave (n="+num2str(exp_num)+")\rHL="+num2str(HL)+"±"+num2str(HLsd)+"[s]"
	string Txt1b="\rMobile:"+num2str(Mob_ave)+"±"+num2str(Mob_sd)+"\rImmobile:"+num2str(Imob_ave)+"±"+num2str(Mob_sd)
	Txt1=Txt1+Txt1b
	//TextBox/C/N=text0/A=RB Txt1
	string Textboxname=exp_name+"txt"	
	TextBox/C/N=$Textboxname/A=RB Txt1	
//	variable sem
//	sem=V_sdev/V_npnts^0.5
		
END

//*********************************** Data Exporting**********************************************************************
//Function K_prepareLayout_and_Print(exp_name)  //graph, results and original data
//	K_prepareLayout(exp_name)
//END

Function K_ExportData()	//040318
	String exp_name
	prompt exp_name, "Name of the Experiment?"
	Doprompt "name::",exp_name
	K_ExportDataCore(exp_name)
END

Function K_ExportDataCore(exp_name)	//040318
	string exp_name
	string Org_t=exp_name+"_t"
	string Cor_t=exp_name+"_t_c"
	string Org_frap=exp_name+"_FRAP"
	string Norm_frap=exp_name+"_FRAP_norm"
	string Org_back=exp_name+"_bkgAv"
	string Norm_back=exp_name+"_bkgAv_norm"	
	string filetext=exp_name+"_data"
	Save/J/M="\r\n"/W $Org_t,$Cor_t,$Org_frap,$Org_back,$Norm_frap,$Norm_back as filetext	
END

Function K_ExportResults()	//040318
	String exp_name
	prompt exp_name, "Name of the Experiment?"
	Doprompt "name::",exp_name
	K_ExportResultsCore(exp_name)
END

Function K_ExportResultsCore(exp_name)	//040318
	string exp_name
	string Resu=exp_name+"_FRAP_Results"
	string filetext=exp_name+"_results"
	wave ResultParameterText
	Save/J/M="\r\n"/W ResultParameterText,$Resu as filetext	
END

Function K_ExportData_Results()	//040318
	String exp_name
	prompt exp_name, "Name of the Experiment?"
	Doprompt "name::",exp_name
	K_ExportResultsCore(exp_name)
	K_ExportDataCore(exp_name)
END

Function K_MultipleExportData_Results()		//040318
	String path_name
	prompt path_name, "Path name?"
	String exp_namep
	prompt exp_namep, "Prefix of the File?"
	Variable exp_num
	prompt exp_num, "How many experiments?"	
	Doprompt "Path,Name and No.::",path_name,exp_namep,exp_num

	string Org_t,Cor_t,Org_frap,Norm_frap,Org_back,Norm_back,filetext_data
	string Resu,filetext_results

	string exp_name
//	Make/O/T/N=10 ResultParameterText
//	ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A","InvTau1","InvTau2","B"}
	wave/z ResultParameterText	
	variable i
	for (i=0;i<exp_num;i+=1)
		exp_name=exp_namep+num2str(i+1)
		Org_t=exp_name+"_t"
		Cor_t=exp_name+"_t_c"
		Org_frap=exp_name+"_FRAP"
		Norm_frap=exp_name+"_FRAP_norm"
		Org_back=exp_name+"_bkgAv"
		Norm_back=exp_name+"_bkgAv_norm"	
		filetext_data=exp_name+"_data.txt"	
		Resu=exp_name+"_FRAP_Results"
		filetext_results=exp_name+"_results.txt"
//		wave ResultParameterText
		Save/O/P=$path_name/J/M="\r\n"/W ResultParameterText,$Resu as filetext_results
		Save/O/P=$path_name/J/M="\r\n"/W $Org_t,$Cor_t,$Org_frap,$Org_back,$Norm_frap,$Norm_back as filetext_data		
	endfor
END

Function K_ExportSummaryData()		//040324
	string exp_namep
	prompt exp_namep, "Prefix of the File?"
	Doprompt "Experiment Name::",exp_namep

	string exp_name=exp_namep
	string HLwavename,HLsdwavename,MobileFwavename,MobileFsdwavename,ImmobileFwavename,ImmobileFsdwavename,Awavename,iT1wavename,iT2wavename

		HLwavename=exp_name+"_HL"
		HLsdwavename=exp_name+"_HLsd"
		MobileFwavename=exp_name+"_Mo"
		MobileFsdwavename=exp_name+"_Mosd"
		ImmobileFwavename=	exp_name+"_Imo"
		ImmobileFsdwavename=exp_name+"_Imosd"
		Awavename=exp_name+"_A"
		iT1wavename=exp_name+"_iT1"
		iT2wavename=exp_name+"_iT2"
		wave/z HLw=$HLwavename
		if (waveexists(HLw)==0)
			abort "You must first fo the 'Draw Average Curve'!!"
		endif
		wave HLsdw=$HLsdwavename
		wave Mobw=$MobileFwavename
		wave Mobsdw=$MobileFsdwavename
		wave Imow=$ImmobileFwavename
		wave Imosdw=$ImmobileFsdwavename
		wave Awave=$Awavename
		wave iT1wave=$iT1wavename
		wave iT2wave=$iT2wavename	

		Edit HLw,HLsdw,Mobw,Mobsdw,Imow,Imosdw,Awave,iT1wave,iT2wave
		
		Variable A_ave,A_sd,iT1_ave,iT1_sd,iT2_ave,iT2_sd
		variable HL_ave,HL_sd,Mo_ave,Mo_sd,IMo_ave
		wavestats/q HLw
		HL_ave=V_avg
		HL_sd=V_sdev
		wavestats/q Mobw
		Mo_ave=V_avg
		Mo_sd=V_sdev
		IMo_ave=1-Mo_ave
		wavestats/q iT1wave
		iT1_ave=V_avg
		iT1_sd=V_sdev
		wavestats/q iT2wave
		iT2_ave=V_avg
		iT2_sd=V_sdev
		
		string MultiResultSummaryWave=exp_name+"_ResultAveSumm"
		string MultiResultSummarySDWave=exp_name+"_ResultAveSummSD"
		Make/O/N=5 $MultiResultSummaryWave,$MultiResultSummarySDWave
		wave MultAve=$MultiResultSummaryWave
		wave MultiAveSD=$MultiResultSummarySDWave
		Make/O/T/N=5 MultiResultParameters
		MultiResultParameters={"HL","MobileFrac","ImmobileFrac","invT1","invT2"}
		MultAve={HL_ave,Mo_ave,IMo_ave,iT1_ave,iT2_ave}
		MultiAveSD={HL_sd,Mo_sd,Mo_sd,iT1_sd,iT2_sd}
		
		printf "Half Life is %g±%g [s]\r",HL_ave,HL_sd				//040319		
		
		Edit MultiResultParameters,MultAve,MultiAveSD
		string filetext=exp_name+"_MultiResults"
		Save/J/M="\r\n"/W MultiResultParameters,$MultiResultSummaryWave,$MultiResultSummarySDWave as filetext			
		
END

Function K_ExportData_ResultsTestt()		//040318
	String path_name
	prompt path_name, "Path name?"
	String exp_namep
	prompt exp_namep, "Prefix of the File?"
	Variable exp_num
	prompt exp_num, "How many experiments?"	
	Doprompt "Path,Name and No.::",path_name,exp_namep,exp_num

		string filetext_results="_results"
		wave ResultParameterText
		Save/O/P=$path_name/J/M="\r\n"/W $("ResultParameterText") as filetext_results
	
END

//**********************Layout *********************************************************************************************************************

Function K_prepareLayout(exp_name)
	string exp_name
	NVAR Fit_method
	string GraphWinName=K_GraphWinname(exp_name)//,Fit_method)
	string ResultsWinName=K_ResultsWinname(exp_name)//,Fit_method)
	string DataWinName=K_DataWinname(exp_name)//,Fit_method)
	if (K_checkWindow(GraphWinName)==0)
		Abort "No Such Graph: Do the analysis"
	else
		DoWindow/F $GraphWinName
		if (K_checkWindow(ResultsWinName)==0)
			string ResultWaveName=exp_name+"_FRAP_Results"
			wave ResultWave=$ResultWaveName
			//Make/O/T ResultParameterText
			//ResultParameterText={"Half Life","Half Life s.d.","Moblie Fraction","Moblie Fraction s.d.","Immobile Fraction","Immobile Fraction s.d.","A","InvTau1","InvTau2"}
			wave ResultParameterText
			Edit ResultParameterText,$ResultWaveName
			//ModifyTable alignment(ResultParameterText)=0		//not in ver4
			DoWindow/c  $ResultsWinName			//give the windowname
			DoWindow /T $ResultsWinName, ResultsWinName
		else
			DoWindow/F  $ResultsWinName
		endif
		if (K_checkWindow(DataWinName)==0)
			String Original_t,Original_Back,Original_Frap
			Original_Back=exp_name+"_bkgAv"
			Original_Frap=exp_name+"_FRAP"
			Original_t=exp_name+"_t"
			Edit $Original_t,$Original_Frap,$Original_Back
			DoWindow/c  $DataWinName			//give the windowname
			DoWindow /T $DataWinName, DataWinName			
		else
			DoWindow/F DataWinName
		endif
		NewLayout
		AppendLayoutObject graph $GraphWinName
		AppendLayoutObject table $ResultsWinName
		ModifyLayout units=0
		ModifyLayout left($GraphWinName)=80,top($GraphWinName)=100
		ModifyLayout width($GraphWinName)=399.75,height($GraphWinName)=249.75
		ModifyLayout left($ResultsWinName)=80,top($ResultsWinName)=400
		ModifyLayout width($ResultsWinName)=249.75
		string layoutString="Experiment "+exp_name
		TextBox/C/N=text0/A=LB/X=13.95/Y=20.41 layoutString
		ModifyLayout left(text0)=72,top(text0)=72
	endif
END

Function K_DOprepareLayout()
	String exp_name
	prompt exp_name, "Name of the Experiment?"
	Doprompt "name::",exp_name
	K_prepareLayout(exp_name)
END



//******* Batch Processing 2009 (Noriko Kane-Goldmith)

// importing is OK, 
// 
// done// difference in FRAP bleach time points. --> should some how detec the largest decrease. 
//		--> 100203 this function should be removed, simply use the value from fit panel (user input)
//	2. how to get "average" with several curves with different dlta-t. Simply overlay all the data?
//	two strategies:	done// A. fit one by one, and get the average of HL. 
//					B. concatenalte all normalized, sort the numbers. reduce the time resolution and get SD for each time point.

//091130 load all frap curves in a system directory. 
//00426 added order
Function LoadAllFrapFiles(pathName, order)
	String pathName			// Name of symbolic path or "" to trigger dialog
	Variable order			//order of original data 100426
	String fileName
	String graphName
	Variable index=0

	if (strlen(pathName)==0)			// If no path specified, create one
		NewPath/O temporaryPath			// This pops up a dialog asking which directory
		if (V_flag!=0) 
			abort
		endif
		pathName = "temporaryPath"
	endif

	Svar/z Gfilelist
	if (svar_exists(Gfilelist) ==0)
		String/G Gfilelist
	endif	
	Gfilelist = "" 
	Variable result
	do			// Loop through each file in folder
		fileName = IndexedFile($pathName, index, ".txt")
		if (strlen(fileName) == 0)			// No more files?
			break									// Break out of loop
		endif
		Gfilelist += (filename+ ";")
		result = LoadAndGraph(fileName, pathName, order)
		if (result == 0)						// Did LoadAndGraph succeed?
													// Print the graph.
			graphName = WinName(0, 1)		// Get the name of the top graph
			//String cmd
			//sprintf cmd, "PrintGraphs %s", graphName
			//Execute cmd					// Explained below.

			//DoWindow/K $graphName		// Kill the graph
			//KillWaves/A/Z					// Kill all unused waves
		endif
		index += 1
	while (1)


	if (Exists("temporaryPath"))		// Kill temp path if it exists
		KillPath temporaryPath
	endif
	print Gfilelist
	return 0						// Signifies success.
End

//100426 added order as argument
Function LoadAndGraph(fileName, pathName, order)
	String fileName			// Name of file to load or "" to get dialog
	String pathName			// Name of path or "" to get dialog
	Variable order			// order of data in original FRAP data  file
	// Load the waves and set the local variables.
	//LoadWave/J/D/O/P=$pathName fileName
	string exp_name
	exp_name = fileName[0, strlen(filename)-5]
	//"Import Data 4: Time - Frap - All Cell - Base..", K_importFrapTxtData(3)	//050802
	K_importFrapTxtDataCore(order, exp_name, pathname, filename) //100426 instead of 3, order
	//LoadWave/O/N=original/D/J/k=1/P=$pathName fileName
	NVAR/z V_flag
	SVAR/z S_filename
	if (V_flag==0)				// No waves loaded. Perhaps user canceled.
		return -1
	endif

	// Annotate graph
	//Textbox/N=TBFileName/A=LT "Waves loaded from " + S_fileName

	return 0								// Signifies success.
End


///////////////////////////////

function DetermineFrapBleachPoint(frapw)
	wave frapw
	make/o/n=(numpnts(frapw)-1) difw
	difw[] =( ((numtype(frapw[p]) ==0) && (numtype(frapw[p+1])==0)) ? (frapw[p] -frapw[p+1]) : -1000)
	wavestats/q difw
	variable frappoint = V_maxloc+1
	return  frappoint
end
// for getting fitting parameters
// Function K_FrapDoFitButtonProc(ctrlName) : ButtonControl

//091201
// using the parameter settings from the panel, fitting is done for the specified experiment name. 
// Only bleaching point is not used from the panel. Calculated from the curve using DetermineFrapBleachPoint(frapw)
Function doFitting(expname)
	string expname
	NVAR/z G_BleachPoint
	NVAR/ z G_BleachPointSetter
	 setG_BleachPointSetter()
	 
	wave frapw = $(expname + "_FRAP")
	if (G_BleachPointSetter ==1)
		G_BleachPoint = DetermineFrapBleachPoint(frapw)
	endif
	SVAR/z G_CurrentExp
	G_CurrentExp = expname
	
	K_FrapDoFitButtonProc("button0")

end

// BleachPointSetter = 0; set Bleaching accoring to panel
// BleachPointSetter = 1; set Bleaching by calculating largest drop 
Function SetMethodforBleachpointSetting(BleachPointSetter)
	variable BleachPointSetter
	setG_BleachPointSetter()
	NVAR/z G_BleachPointSetter
	G_BleachPointSetter = BleachPointSetter
end

Function setG_BleachPointSetter()
	NVAR/z G_BleachPointSetter
	if (NVAR_exists(G_BleachPointSetter) == 0)
		Variable/g G_BleachPointSetter = 0	//uses panel by default. 
	endif
end

Function BatchFitting()
	Svar/z Gfilelist
	variable i
	string currentfilename, expname
	string resultwname
	if (Svar_exists(Gfilelist)==0) 
		print "Only Batch Imported experiments are analyzed with this function"
	else
		for (i=0; i<itemsInList(Gfilelist); i	+=1)
			currentfilename = StringFromList(i, Gfilelist)
			expname = currentfilename[0, strlen(currentfilename)-5]
			doFitting(expname)
		endfor 
	endif

	for (i=0; i<itemsInList(Gfilelist); i	+=1)
		currentfilename = StringFromList(i, Gfilelist)
		expname = currentfilename[0, strlen(currentfilename)-5]
		resultwname = expname+ "_FRAP_Results"
		DoWindow/F Batch_Fit_Results
		
		if ((i==0) && (V_flag==0))
			edit ResultParameterText
			DoWindow/C Batch_Fit_Results
		endif
		CheckDisplayed/w=Batch_Fit_Results  $resultwname
		if (V_flag ==0) 
			appendtotable $resultwname
		endif
	endfor
	BatchAverageAndFit()		//100210
end


//***** averaging curves: method 1: average Normalized curves, then fir that curve.
// then average each curves (check datatype) (if each digit is adde, becomes the number of curves per data set)
// fit the averaged curve, get results (averaged_mtd1).  in this case, standard deviation can be directly used for the fitting sdev wave

// preparation for averaging
// --- > all the listed waves should have same length and similar dt. 
// 1. test if the length of waves are same.
// 2. test if the bleaching time point is common. --> 091208 no test on this, since now by default 
// 3. test if dt is similar. 
//	 
function BatchCheckTimePoints()
	Svar/z Gfilelist
	variable i,j
	string currentfilename, expname
	string resultwname
	string currenttwname
	variable Firstnumpnts, FirstBleachPoint
	variable allEqual = 1
	variable dtequal = 1
	variable bleachpointequal =1
	variable averagelen
	if (Svar_exists(Gfilelist)==0) 
		print "Only Batch Imported experiments are analyzed with this function"
		return -1
	endif
	
	// check time-lapse conditions
	make/o/n=(itemsInList(Gfilelist)) BatcklistNumpnts, BatcklistBleachpnts, BatchListMaxDif
	for (i=0; i<itemsInList(Gfilelist); i	+=1)
		currentfilename = StringFromList(i, Gfilelist)
		expname = currentfilename[0, strlen(currentfilename)-5]
		currenttwname = expname + "_t" 
		wave currenttw = $(currenttwname)
		BatcklistNumpnts[i] = numpnts(currenttw)
		if (i==0)
			Firstnumpnts = numpnts(currenttw)
		else
			if (Firstnumpnts != numpnts(currenttw))
				allEqual = 0			//wave length are not constant
				print "aborted. ### all batch imported waves should have same number of time poitns. ###"
				return -1				
			endif
		endif

//			bleach point checker commented out on 091208						
//			for (j=0; j<numpnts(currenttw); j+=1)
//				if (currenttw[j] == 0)
//					BatcklistBleachpnts[i] = j
//					if (i==0)
//						FirstBleachPoint = j
//					else
//						if (j != FirstBleachPoint)
//							bleachpointequal =0		//check if bleachpoints are equal
//						endif
//					endif
//				endif
//			endfor 
		
		//dt does not have to be exactlly equal: if difference is below certain tolerance, then can be averaged. 
		//compare to the first wave, get difference waves, get the maximum of difference wave. if 
		//this maximum is below T, then say dt are same with alll waves usd. 
		variable meandt, maxdif

		if (i==0)
			Duplicate/o currenttw tempRefw, tempDifw
			make/o/n=(numpnts(currenttw) - 1) tempDTw
			maxdif = 0
		else
			tempDifw[] = abs(tempRefw[p] - currenttw[p])
			wavestats/q tempDifw
			maxdif = V_max
		endif
		tempDTw[] = currenttw[p+1] - currenttw[p]
		wavestats/q tempDTw
		meandt = V_avg				
		BatchListMaxDif[i] = maxdif/meandt
		if ((i>0) && (BatchListMaxDif[i] > 0.05) )  //here, the threshold for dt difference is set to 5% of dt. 
			dtequal = 0
			printf "curve averaging aborted. ### wave index %g have different time resolution compared to index 0 wave###\r   ... individual fittings were OK", i

			return -1
		endif

	endfor

	killwaves tempRefw, tempDifw
	
	averagelen = Firstnumpnts
	
	return averagelen
end

function BatchReturnDataForm()
	Svar/z Gfilelist
	string currentfilename = StringFromList(0, Gfilelist)
	Nvar/z dataformitem1 =$( currentfilename[0, strlen(currentfilename)-5] + "_dataform") 
	variable dataform = dataformitem1
	return dataform
end

// fit without Normalization --> FitPara_wave. FrapcalcCore shoudl be modified to respect this flag. 
// base is not normalized, since it is used before normalizzation 
Function BatchAverageAndFit()
	variable averagelen, i

	String avgname = "Averaged"
	string sdevname = avgname+"SD"
	//prompt	avgname, "name the averaging experiment"
	//Doprompt "Average Name",avgname
		
	averagelen = BatchCheckTimePoints()	// all wave length are same and dt is similar
	if (averagelen == -1)
		return averagelen //terminates because of wave length or dt mismatch
	endif
	variable dataform = BatchReturnDataForm()
	//NVAR/z gavgdataform = $("G"+avgname+"_dataform")
	NVAR/z gavgdataform = $(avgname+"_dataform")
	if (NVAR_exists(gavgdataform) == 0)
		//variable/g $("G"+avgname+"_dataform")
		variable/g $(avgname+"_dataform")
	endif
	gavgdataform = dataform
	NVAR/z G_dataForm = dataform
	string stdataform = num2str(dataform)	

	make/o/n=(averagelen) $(avgname + "_t_c")
	wave tw =  $(avgname + "_t_c")
	
	make/o/n=(averagelen) $(avgname + "_FRAP_norm")
	wave frapw =  $(avgname + "_FRAP_norm")

	if (cmpstr(stdataform[1],"1")==0) 
		make/o/n=(averagelen) $(avgname + "_AllCell_norm")
		wave allcellw = $(avgname + "_AllCell_norm")
	endif
	if (cmpstr(stdataform[2],"1")==0) 
		make/o/n=(averagelen) $(avgname + "_bkgAvg_norm")
		wave refw = $(avgname + "_bkgAvg_norm")
	endif
	if (cmpstr(stdataform[3],"1")==0) 
		make/o/n=(averagelen) $(avgname + "_base_norm")
		wave basew = $(avgname + "_base_norm")
	endif
	
	//for recording sd
	make/o/n=(averagelen) $(sdevname + "_t_c")
	wave tsdw =  $(sdevname + "_t_c")
	
	make/o/n=(averagelen) $(sdevname + "_FRAP_norm")
	wave frapsdw =  $(sdevname + "_FRAP_norm")

	if (cmpstr(stdataform[1],"1")==0) 
		make/o/n=(averagelen) $(sdevname + "_AllCell_norm")
		wave allcellsdw = $(sdevname + "_AllCell_norm")
	endif
	if (cmpstr(stdataform[2],"1")==0) 
		make/o/n=(averagelen) $(sdevname + "_bkgAvg_norm")
		wave refsdw = $(sdevname + "_bkgAvg_norm")
	endif
	if (cmpstr(stdataform[3],"1")==0) 
		make/o/n=(averagelen) $(sdevname + "_base_norm")
		wave basesdw = $(sdevname + "_base_norm")
	endif	
	//
	
	Svar/z Gfilelist
	//new version 100203
	variable j
	make/o/n=2 statw
	for (j = 0; j < averagelen; j+=1)						

		if (cmpstr(stdataform[1],"1")==0) 
			GetStatsfromWaves(statw, "_AllCell_norm", Gfilelist, j)
			allcellw[j] = statw[0]
			allcellsdw[j] = statw[1]	
		endif		

		if (cmpstr(stdataform[2],"1")==0) 
			GetStatsfromWaves(statw, "_bkgAvg_norm", Gfilelist, j)
			refw[j] = statw[0]
			refsdw[j] = statw[1]	
		endif		

		if (cmpstr(stdataform[3],"1")==0) 
			GetStatsfromWaves(statw, "_base_norm", Gfilelist, j)
			basew[j] = statw[0]
			basesdw[j] = statw[1]	
		endif		

		GetStatsfromWaves(statw, "_t_c", Gfilelist, j)
		tw[j] = statw[0]
		tsdw[j] = statw[1]
		
		GetStatsfromWaves(statw, "_FRAP_norm", Gfilelist, j)
		frapw[j] = statw[0]
		frapsdw[j] = statw[1]
		
	endfor
	//display frapw, allcellw vs tw
	//ErrorBars $(nameofwave(frapw)) Y,wave=($(nameofwave(frapsdw)),$(nameofwave(frapsdw)))
	
	//fitting 

	
	string expname = "Averaged"//currentfilename[0, strlen(currentfilename)-5]

	//checkG_currentNormalized()
	K_CheckAllGV()
	NVAR/z G_currentNormalized
	G_currentNormalized =1
	NVAR/z G_sdevwexists	//100204
	G_sdevwexists =	1		//100204
	NVAR/z G_doAveraged	//100204
	G_doAveraged = 1		//100204
	SVAR/z G_CurrentExp
	G_CurrentExp = expname

	printf "=== Fitting Averaged Curve using following curves: %s \r", Gfilelist
	K_FrapCalcCore()
	
	G_currentNormalized = 0	//100204
	G_sdevwexists =	0		//100204
	G_doAveraged = 0		//100204
		
//	ErrorBars $(nameofwave(frapw)),OFF
//	ErrorBars/T=0 $(nameofwave(frapw)) Y,wave=($(nameofwave(frapsdw)),$(nameofwave(frapsdw)))
	// fitting: assume 
	K_frapPanelInfo()
end

//100203 for getting avarage value and SD of normalized intensity for each time points. 
function GetStatsfromWaves(statw, Ssuffix, filelist, timepnt)
	wave statw
	string Ssuffix, filelist
	variable timepnt
	variable i
	string currentfilename, currentPrefix
	make/o/n=(itemsInList(filelist)) temp4stats
	for (i=0; i<itemsInList(filelist); i+=1) 
		currentfilename = StringFromList(i, filelist)
		currentPrefix = currentfilename[0, strlen(currentfilename)-5]
		wave curw = $(currentPrefix + Ssuffix)
		temp4stats[i] =curw[timepnt]		
	endfor
	wavestats/q temp4stats
	statw[0] = V_avg
	statw[1] = V_sdev
	//killwaves temp4stats
end

//100208
//from all batch processed curves, get average gap ratio. 
//only works after fitting all curves once. 
//filelsit[p=6] is the gap ratio. 
// for "rainer method" fitting, gap ration could only be derived from original non-normalized curve. (meaning that one cannot get gap ratio from average normalized background / allcell curve)
function getAverageGApRatio(filelist)
	string filelist
	string curwname
	variable i
	variable gapratiomean = 0
	for (i=0; i<itemsInList(filelist); i+=1) 
		curwname =  StringFromList(i, filelist)[0, strlen(StringFromList(i, filelist))-5] + "_parameter"
		wave curw = $curwname
		gapratioMean +=curw[6]
	endfor
	gapratioMean /= itemsInList(filelist)
	return gapratioMean
end




//***** averaging curves: method 2: concatenate curves, sort by time, fit this single (associated) data. 




//****** summarizing ******


//---------------UNused

//050811

//050715
//Function K_GraphResidue(Frapwave,EstimationWave,timewave)
//	wave Frapwave,EstimationWave,timewave
//	NVAR/z G_BleachPoint
//	string residuewavename=nameofwave(Frapwave)+"Res"
//	string residuetimewavename=nameofwave(Frapwave)+"Rest"
//	Make/o/n=(numpnts(Frapwave)-G_BleachPoint-1) $residuewavename,$residuetimewavename
//	wave/z residuewave=$residuewavename
//	wave/z residuetimewave=$residuetimewavename
//	residuewave[]=Frapwave[p+G_BleachPoint]-EstimationWave[p+G_BleachPoint]
//	residuetimewave[]=timewave[p+G_BleachPoint]
//	
//	SVAR/z G_exp_name
//	string WinNameFit=K_GraphWinname(G_exp_name)//,fit_method)
//	DoWindow/f  $WinNameFit
//	if (V_flag==1)
//		if (K_checkTraceInGraph(WinNameFit,nameofwave(residuewave))==0)	
//			AppendtoGraph/L=residueaxis residuewave vs residuetimewave
//			ModifyGraph axisEnab(frapaxis)={0,0.8},axisEnab(residueaxis)={0.83,1}
//			ModifyGraph zero(residueaxis)=2
//			ModifyGraph mode($(nameofwave(residuewave)))=2
//			ModifyGraph margin(left)=50
//			ModifyGraph freePos(frapaxis)=0,freePos(residueaxis)=0
//			ModifyGraph lblPos(residueaxis)=40
//			ModifyGraph lsize($(nameofwave(residuewave)))=2
//		endif	
//		
//		//ModifyGraph mode($Frapwave_ynm_norm)=3,marker($Frapwave_ynm_norm)=8	
////		Label left "Relative Fl. Intensity"
////		Label bottom "Time [s]"
////		SetAxis/A/E=1 left
////		DoWindow/c  $WinNameFit			//give the windowname
////		DoWindow/T $WinNameFit, WinNameFit
//	endif	
//END

//050810

//Function K_FrapCalcCore(decwave_xnm,decwave_ynm,Frapwave_ynm,FitPara_wave)			// Normalizing version.//040324 
//	string decwave_xnm,decwave_ynm,Frapwave_ynm
//	wave FitPara_wave
//
//	NVAR Fit_method		//used for functions from menu :: to be replaced
//	NVAR G_currentMethod
//	Fit_method=G_currentMethod
//	NVAR/z G_BleachPoint
//	K_checkGV()	
//	variable normalized=FitPara_wave[1]
//
//	variable FlatBackground		//checks if the back ground curve is flat. 
//		
//	wave/z decwave_x_original=$decwave_xnm
//	wave/z decwave_y_original=$decwave_ynm
//	wave/z Frapwave_y_original=$Frapwave_ynm
//
//	if (waveexists(decwave_y_original)==0)
//		FitPara_wave[3]=0	//reference exists
//		make/o/n=(numpnts(decwave_x_original)) $decwave_ynm
//		decwave_y_original[]=1
//	else
//		FitPara_wave[3]=1
//	endif
//	
//	FlatBackground=CheckFlatBackground(decwave_y_original)	//0 if it is flat
//	FitPara_wave[4]=FlatBackground
//	
//	variable I_Prebleach_Back_norm
//	I_Prebleach_Back_norm=K_FrapCalcNormalizeCurves(decwave_xnm,decwave_ynm,Frapwave_ynm,FitPara_wave,normalized)	//050306
//	FitPara_wave[7]=I_Prebleach_Back_norm
//	//I_Prebleach_FRAP_norm==always 1 050307
//	
//	String decwave_xnm_c=(decwave_xnm+"_c")
//	String decwave_ynm_norm=decwave_ynm+"_norm"
//	String Frapwave_ynm_norm=Frapwave_ynm+"_norm"
//	wave decwave_x=	$decwave_xnm_c
//	wave decwave_y=$decwave_ynm_norm
//	wave Frapwave_y=$Frapwave_ynm_norm
//
//	SVAR/z G_exp_name
//	string WinNameFit=K_GraphWinname(G_exp_name)//,fit_method)
//	DoWindow/f  $WinNameFit
//	if (V_flag==0)
//		Display/L=frapaxis decwave_y vs decwave_x
//		//ModifyGraph mode($Frapwave_ynm_norm)=3,marker($Frapwave_ynm_norm)=8
//		ModifyGraph mode($decwave_ynm_norm)=3,marker($decwave_ynm_norm)=8
//		Label frapaxis "Relative Fl. Intensity"
//		ModifyGraph lblPos(frapaxis)=40
//		Label bottom "Time [s]"
//		SetAxis/A/E=0 frapaxis		
//		DoWindow/c  $WinNameFit			//give the windowname
//		DoWindow/T $WinNameFit, WinNameFit
//	else
//		if (K_checkTraceInGraph(WinNameFit,decwave_ynm_norm)==0)
//			appendtograph /L=frapaxis decwave_y vs decwave_x
//			ModifyGraph mode($decwave_ynm_norm)=3,marker($decwave_ynm_norm)=8
//		endif
//	endif
//	
//	variable 	GapRatio,invTau2,decA,decY0,BackGround_Timpoint0
//	string decayFitnm="fit_"+decwave_ynm_norm
//	K_FrapBackgroundGuess(decwave_y,decwave_x,FitPara_wave)
//	GapRatio=FitPara_wave[6]
//	decA=FitPara_wave[10]
//	invTau2=	FitPara_wave[11]
//	decY0=	FitPara_wave[12]
//
//	if (K_checkTraceInGraph(WinNameFit,nameofwave(Frapwave_y))==0)
//		AppendToGraph/L=frapaxis Frapwave_y vs decwave_x
//		ModifyGraph mode($Frapwave_ynm_norm)=3,marker($Frapwave_ynm_norm)=8	
//	endif
//	
////fitting of the frap curve to derive Guessing values
//	CurveFit/W=0/Q exp Frapwave_y[G_BleachPoint,] /X=decwave_x /D
//	wave/z W_coef
//	variable y0_guess=W_coef[0]
//	variable amplitude_guess=W_coef[1]
//	variable invTau1_guess=W_coef[2]
//	printf "Guess Values: A %g, invTau %g\r",amplitude_guess,invTau1_guess
//
////fitting of the frap curve to get the real answer
//	variable HL,invTau,amplitude,backTau
//	variable width=FitPara_wave[2]
//	variable tauD_guess
//	variable DifCoef,tauD
//	variable amplitude_Ellenberg_guess,DifCoef_guess
//	NVAR/z G_weight
//	K_checkWeight()
//	Duplicate/o Frapwave_y $(Frapwave_ynm_norm+"w")
//	wave/z frapweight=$(Frapwave_ynm_norm+"w")
//	frapweight=1
//	if (G_weight==1)
//		NVAR/z G_WeightLowPnt,G_WeightHighPnt
//		
//		frapweight[K_FrapTimetoPnt(decwave_x,G_WeightLowPnt),K_FrapTimetoPnt(decwave_x,G_WeightHighPnt)]=0.1
//		//frapweight[]=frapweight[p]/2+0.1
//	endif
//	variable V_FitTol=0.0001
//	switch (fit_method)
//		case 0:			//040330		Rainer's method
//			//amplitude_guess*=-1
//			amplitude_guess*=0.9	//050804
//			W_coef = {amplitude_guess,invTau1_guess,invTau2}
//			FuncFit/W=0/H="001" FRAP W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x/I=1/W=$(nameofwave(frapweight)) /D	//040317
//			amplitude=W_coef[0]
//			invTau=W_coef[1]
//			backTau=W_coef[2]
//			HL=(ln(0.5)/invTau*-1)		//040303
//			break
//
//		case 1:		// background multiply //this doesn't work currently 050808
//			amplitude_guess*=0.9	//050804
//			W_coef = {decA,amplitude_guess,invTau1_guess,invTau2,decY0}		//040324
//			FuncFit/W=0/H="10011" FRAP4 W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x/I=1/W=$(nameofwave(frapweight)) /D
//			amplitude=W_coef[1]
//			invTau=W_coef[2]
//			backTau=W_coef[3]
//			HL=(ln(0.5)/invTau*-1)		//040303
//			break
//
//		case 4://2:		//diffusion - ellenberg
//			amplitude_Ellenberg_guess=y0_guess	//040818 
//			DifCoef_guess=K_DiffCoefestimateFromInvTau(invTau1_guess,y0_guess,amplitude_guess,width)	//040818 
//			W_coef = {amplitude_Ellenberg_guess,width,DifCoef_guess}										//040429
//			FuncFit/W=0/H="010" FRAP_Ellenberg W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x/I=1/W=$(nameofwave(frapweight)) /D	//040429
//			amplitude=W_coef[0]
//			DifCoef=W_coef[2]
//			//HL=(3*width^2)/4/pi/DifCoef				//040429
//			//HL=(width^2)/12/pi/DifCoef					//040719
//			HL=0.75*(width^2)/pi/DifCoef					//040719
//			break
//		case 5://3:		//diffusion soumpasis
//			amplitude_Ellenberg_guess=y0_guess	//040818 
//			DifCoef_guess=K_DiffCoefestimateFromInvTau(invTau1_guess,y0_guess,amplitude_guess,width)	//040818 
//			W_coef = {amplitude_Ellenberg_guess,width,DifCoef_guess}										//040429
//			FuncFit/W=0/H="010" FRAP_Ellenberg W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x /D	//040429
//			
//			//V_FitTol=0.01
//			amplitude_guess=W_coef[0]
//			tauD_guess=(width^2)/W_coef[2]	
//			W_coef = {amplitude_guess,tauD_guess}
//			//if (G_weight==1)
//				FuncFit/W=0/H="00" FRAP_soumpasis W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x/I=1/W=$(nameofwave(frapweight)) /D	//050305
//			//else
//				//FuncFit/W=0/H="00" FRAP_soumpasis W_coef Frapwave_y[G_BleachPoint,] /X=decwave_x /D	//050305
//			//endif
//			amplitude=W_coef[0]
//			tauD=W_coef[1]
//			DifCoef=(width^2)/tauD
//			HL=Nan			
//			break		
//
//		default:
//		
//	endswitch
//	NVAR/z G_chisq
//	if (NVAR_exists(G_chisq)==0)
//		variable/g G_chisq
//	endif
//	G_chisq=V_chisq
//
////Prepare estimaiton curve
//	string FrapFitnm="fit_"+Frapwave_ynm_norm
//	string FrapFit_estimationName="fit_"+Frapwave_ynm_norm+"_est"
//	Duplicate/O $Frapwave_ynm_norm $FrapFit_estimationName
//	wave FrapEst=$FrapFit_estimationName
//
//	switch (fit_method)
//		case 0:
//			FrapEst[]=amplitude/invTau*(invTau+BackTau)*(1-exp(-1*invTau*decwave_x[p]))		
//			break
//		
//		case 1:
//			FrapEst[]=amplitude*(1-exp(-1*invTau*decwave_x[p]))		
//			break
//			
//		case 4://2:
////			FrapEst[]=W_coef[0]*(1-(width^2*(width^2+4*pi*DifCoef*decwave_x[p])^-1 ))^0.5/(decY0+decA*exp(invTau2*decwave_x[p]))
//			FrapEst[]=W_coef[0]*(1-((width^2*(width^2+4*pi*DifCoef*decwave_x[p])^-1 ))^0.5)	//050307
//			break
//		case 5://3:
////			FrapEst[]=(W_coef[0]*(e^(-1*W_coef[1]/2/decwave_x[p]))*( bessI(0,(W_coef[1]/2/decwave_x[p]))+bessI(1,(W_coef[1]/2/decwave_x[p])) ))/(decY0+decA*exp(invTau2*decwave_x[p]))		
//			FrapEst[]=(W_coef[0]*(e^(-1*W_coef[1]/2/decwave_x[p]))*( bessI(0,(W_coef[1]/2/decwave_x[p]))+bessI(1,(W_coef[1]/2/decwave_x[p])) ))	
//			HL=K_SoumpasisHalfLife(FrapEst,decwave_x,amplitude,G_BleachPoint)
//			break	
//	
//	endswitch
//	FrapEst[0,(G_BleachPoint-1)]=NaN
//	printf "Half Life is %g [s]\r",HL				//040303
//
////Graphing 
//	if (K_checkTraceInGraph(WinNameFit,nameofwave(FrapEst))==0)
//		AppendToGraph/L=frapaxis FrapEst vs decwave_x
//		ModifyGraph rgb($FrapFit_estimationName)=(52224,52224,0)
//		ModifyGraph lstyle($FrapFit_estimationName)=3
//	endif
//
//	
//// residue plotting
////050714
//	K_GraphResidue(Frapwave_y,FrapEst,decwave_x)		
//			
////Calculate Mobile-Immobile fractions
//
//	variable MobileFraction, ImmobileFraction			//040303
//
//	if (fit_method==0)
//		MobileFraction=(amplitude/invTau*(invTau+BackTau))/GapRatio
//	else
//		MobileFraction=(amplitude)
//	endif
//
//	if (MobileFraction>1)
//		Printf "The Mobile fraction was over 1 (%g)\r",MobileFraction
//		MobileFraction=1
//	endif
//	ImmobileFraction=1-MobileFraction					//040303
//	
//	printf "Mobile Fraction is %g\r",MobileFraction		//040303
//	printf "Immobile Fraction is %g\r",ImmobileFraction	//040303
//
//	string Txt1	
//	switch (fit_method)
//		case 0:
//			Txt1="\\Z08\\s("+FrapFitnm+") FRAP Rainer A="+num2str(amplitude)+" iTau1="+num2str(invTau)+"\r\\s("+decwave_ynm_norm+") Background  iTau2="+num2str(backTau)+"\rHalf Max:"+num2str(HL)+"s Mobile: "+num2str(MobileFraction)+"\r\\s("+FrapFit_estimationName+") Estimation"
//			break
//		
//		case 1:
//			Txt1="\\Z08\\s("+FrapFitnm+") FRAP BackMulti A="+num2str(amplitude)+" iTau1="+num2str(invTau)+"\r\\s("+decwave_ynm_norm+") Background  iTau2="+num2str(backTau)+"\rHalf Max:"+num2str(HL)+"s Mobile: "+num2str(MobileFraction)+"\r\\s("+FrapFit_estimationName+") Estimation"
//			break
//			
//		case 4://2:
//			Txt1="\\Z08\\s("+FrapFitnm+") FRAP Ellenberg\rA="+num2str(amplitude)+"\rDiffusion Coef="+num2str(DifCoef)+"\r\\s("+decwave_ynm_norm+") Background\rHalf Max:"+num2str(HL)+"s\r\\s("+FrapFit_estimationName+") Estimation"
//			break
//		case 5://3:
//			Txt1="\\Z08\\s("+FrapFitnm+") FRAP Soumpasis\rA="+num2str(amplitude)+"\rDiffusion Coef="+num2str(DifCoef)+"\r\\s("+decwave_ynm_norm+") Background\r\\s("+FrapFit_estimationName+") Estimation"
//			break
//	
//	endswitch	
//	TextBox/C/N=text0/A=RB Txt1
//	
//	K_FrapResultTable(HL,MobileFraction,ImmobileFraction)
//	K_renameFrapResultsWave(G_exp_name)
//	
//	return HL
//END

////returns estimation value of the background fl. (average of fl level before the bleaching
////from the fitted back curve. 050804 
//function K_retAvgBackEstBack(decwave_x,decy0,decA,decTau,bleachpoint)
//	wave decwave_x
//	variable decy0,decA,decTau,bleachpoint
//	variable i,sigmaBackAvg
//	variable sigmaBack=0
//	duplicate/O/R=[,bleachpoint] decwave_x tempbackest
//	tempbackest[]=decy0+decA*exp(-1*decTau*decwave_x[p])
//	wavestats/q  tempbackest
//	//for (i=0;i<(bleachpoint);i+=1)
//	//	sigmaBack+=decy0+decA*(-1*decTau*decwave_x[i])
//	//endfor
//	//sigmaBackAvg=sigmaBack/bleachpoint
//	//return sigmaBackAvg
//	killwaves tempbackest
//	return V_avg
//end

// 050809

//Function K_expnPopMenuProcOLD(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	checkG_CurrentExp()
//	SVAR/z G_CurrentExp
//	G_CurrentExp=popStr
//	
////	SVAR/z G_CurrentExp
//	variable Current_dataform=checkG_dataFormSpecific(G_CurrentExp)
//	SVAR/z G_MethodList
//	switch (Current_dataform)
//		case 0:
//			G_MethodList="exponential -Rainer;-;-;-;diffusion-Ellenberg;diffusion-Soumpasis;-;-"
//			break
//		case 1:
//			G_MethodList="exponential -Rainer;-;-;-;-;-;DoubleNorm-Single Exp;DoubleNorm-Double Exp"
//			break
//		case 2:
////			G_MethodList="exponential -Rainer;exponential -BackMultiply;exponential -Back Correct1;exponential -Back Correct2;diffusion-Ellenberg;diffusion-Soumpasis;DoubleNorm-Single Exp;DoubleNorm-Double Exp"
//			G_MethodList="exponential -Rainer;-;-;-;diffusion-Ellenberg;diffusion-Soumpasis;DoubleNorm-Single Exp;DoubleNorm-Double Exp"
//			break
//	endswitch
//	PopupMenu popup1,value=# G_MethodList	
//	ControlUpdate/W=$("FitPanel") popup1
//End

//Function/S FrapMenuItem(itemNumber)
//	Variable itemNumber
////	Variable turbo = NumVarOrDefault("root:gTurboMode", 0)
//	Variable dataform = NumVarOrDefault("root:G_dataForm", 0)
//	switch (itemNumber)
//		case 0:
//			if ((dataform==0) || (dataform==2))	
//				return "Rainer's method"		// disabled state
//			else
//				return "(Rainer's method"		// enabled state
//			endif
//			break
//		case 1:
//			if ((dataform==0) || (dataform==2))	
//				return "Back Decay multiply"		// disabled state
//			else
//				return "(Back Decay multiply"		// enabled state
//			endif					
//			break
//		case 2:
//			if ((dataform==0) || (dataform==2))	
//				return "Ellenberg"		// disabled state
//			else
//				return "(Ellenberg"		// enabled state
//			endif
//			break
//					
//		case 3:
//			if ((dataform==0) || (dataform==2))	
//				return "Soumpasis"		// disabled state
//			else
//				return "(Soumpasis"		// enabled state
//			endif
//			break
//
//		case 4:
//			break
//
//
//		case 5:
//			break
//
//		case 6:
//			if ((dataform==1)|| (dataform==2))	
//				return"Double Normalize - Single Exp"		// disabled state
//			else
//				return "(Double Normalize - Single Exp"		// enabled state
//			endif
//			break
//
//		case 7:
//			if ((dataform==1)|| (dataform==2))	
//				return"Double Normalize - Double Exp"		// disabled state
//			else
//				return "(Double Normalize - Double Exp"		// enabled state
//			endif
//			break
//												
//	endswitch
//					
//End

// 050713
// point No. - time - ch1 (Frap) - ch2 (order==0)
// point No. - time - ch1 - ch2 (Frap) - ch3 (order==1)	//050715
// ROI1 Frap
// ROI2 All cell
// ROI3 Background
// 4 x 3 ROI = 12 waves loaded
//Function K_importFrapTxtLeicaData(order)
//	Variable order
//	String exp_name
//	prompt exp_name, "Name of the Experiment?"
//	Doprompt "name::",exp_name
//	if (V_flag)
//		Abort "Processing Canceled"
//	endif	
//	
//	String Original_t,Original_Back,Original_Frap,Original_AllCell
//	String Original_base //050725
////	Original_Back=exp_name+"_bkgOg"
//	Original_AllCell=exp_name+"_AllCell"
//	Original_Back=exp_name+"_bkgAv"	//040429 to make single reference data calculatable. actually is not the average.
//	Original_Frap=exp_name+"_FRAP"
//	Original_t=exp_name+"_t"
//	Original_base=exp_name+"_base"	//050725
//
//	checkG_dataFormSpecific(exp_name)		//050802
//	string dataformSpecName=exp_name+"_dataform"		//050802
//	Nvar/z GdataformSpec=$dataformSpecName		//050802
//		
//	LoadWave/N=original/D/G
//	switch (order)
//		case 0:
//			wave/z original0,original1,original2,original3	//ROI1
//			wave/z original4,original5,original6,original7	//ROI2
//			wave/z original8,original9,original10,original11	//ROI3
//
//			Rename original1,$Original_t
//			Rename original2,$Original_Frap
//			Rename original6,$Original_AllCell
//			Rename original10,$Original_Back
//			Killwaves original0,original3,original4,original5,original7,original8,original9,original11
//			GdataformSpec=1
//			break
//		case 1:
//			wave/z original0,original1,original2,original3,original4	//ROI1
//			wave/z original5,original6,original7,original8,original9	//ROI2
//			wave/z original10,original11,original12,original13,original4	//ROI3
//
//			Rename original1,$Original_t
//			Rename original3,$Original_Frap
//			Rename original8,$Original_AllCell
//			Rename original13,$Original_Back
//			Killwaves original0,original2,original4,original5,original6,original7,original9,original10,original11,original12,original14
//			GdataformSpec=1
//			break
//		case 2:		//another ROI, double channel 050725
//			wave/z original0,original1,original2,original3	//ROI1
//			wave/z original4,original5,original6,original7	//ROI2
//			wave/z original8,original9,original10,original11	//ROI3
//			wave/z original12,original13,original14,original15	//ROI4
//
//			Rename original1,$Original_t
//			Rename original2,$Original_Frap
//			Rename original6,$Original_AllCell
//			Rename original10,$Original_base	//050725
//			Rename original14,$Original_back	//050725
//			
//			Killwaves original0,original3,original4,original5,original7,original8,original9,original11
//			GdataformSpec=2
//			break
//
//		case 3:		//another ROI, double channel 050725
//			wave/z original0,original1,original2,original3,original4	//ROI1
//			wave/z original5,original6,original7,original8,original9	//ROI2
//			wave/z original10,original11,original12,original13,original4	//ROI3
//			wave/z original15,original16,original17,original18,original9	//ROI4
//
//			Rename original1,$Original_t
//			Rename original3,$Original_Frap
//			Rename original8,$Original_AllCell
//			Rename original13,$Original_base	//050725
//			Rename original18,$Original_back	//050725
//
//			Killwaves original0,original2,original4
//			Killwaves original5,original6,original7,original9
//			Killwaves original10,original11,original12,original14
//			Killwaves original15,original16,original17,original19
//			GdataformSpec=2			
//			break			
//	endswitch
//	Edit $Original_t,$Original_Frap,$Original_AllCell,$Original_Back
//	Display $Original_AllCell,$Original_Back,$Original_Frap vs $Original_t
//
//	//K_checkGV()
//END

//-------- HIstory
//030916 :	For Frap experiments -- calculate half life.
//			Coded for Heiko.
//031221:	file naming too tong -  fixed. 
//040116:	"k40" commented out
//040303:	modified for Zeta.
//			K_FrapCalc() modified: ranging the fitting t.
//			version2b
//			changed: 	K_FrapCalc2_core(exp_name,timepoint0,j) to 	K_FrapCalc2_core(exp_name,timepoint0)
//			changed:	K_importFrapTxtDataV2Multi(path_name,exp_name,exp_num,currentNum) to K_importFrapTxtDataV2Multi(path_name,exp_name,exp_num)
//040308:	implemented mobile:immobile fraction calculaiton also for the K_FrapCalc2_core()	
//040311:	f(t) = A*invtau1/(invtau1+invtau2)*(1-e^(-1*(invtau1+invtau2)*t))
//			invtau1/(invtau1+invtau2) is the weighting of the contribtion of binding (invtau1) and bleaching (invtau2) to the dynamics of fluorescnence changes
//040320:	many changes.
//040330:	checking the normalization procedure of Rainer's method.
//040429:	diffusion fitting formula (Jan Ellenberg 1997) added. 
//			In this experiment, photobleach was done to a 4um width strip. In this case, w=4.
//			save as K_FRAPcalcV4.ipf
//040430:	fixed problems with Layout
//			outsorced Result Recording.
//			FRAP_method became global value
//040719		corrected the calculation of HalfLife for Diffusion model.
			//rename  as V5
//040720		"DifCoef_guess" modified. direct use of exponential fitting -> invTau as the guess value.
			// formula for the diffusion corrected. (root to the outside)
//040818		-importing of time & frap only data enabled
//			-Diffusion Coefficient calculaiton of time & frap only data enabled			
//			-fale safe for the missing of bleach point information
//			-guessing of the diffusion coefficient from invTau (exponential fitting) is designed. Half Life is calculated, then
//			calculate the diffusion coefficient guessing value
//050203		problem when importing dummy wave (such as all 1) fixed for the reaction models. 
//			Importing of data without background bleaching is also possible. 
//050307		Changed many parts: integrated common parts, Soumpasis formula added. Updated to V6
//			"Fitting Panel" created; Weighting function added. 
//050308		soumpasis HL calculaiton; panel info print
//			assignments: acquisition bleaching correction for the diffusion fitting. 
//050310       background subtraction by Phair et al. (2000) "Single Normalization".