#pragma rtGlobals=1		// Use modern global access method.


//	Kota Miura
//	miura@embl.de
//		060329		for fatima. First Version
//		110726		filename chaned slightly, so made another function for those files. 
//					Excel file format prevailed, so importing csv format instead. 
//					Conversion of excel to csv files are done using python script. (xls2csv.py, and its batchprocessing partenr)			 
 
//import excel file copied and pasted results from ImageJ
// columnA frame
// columnB area
// columnC ave int
// columnD ave int sd
// columnE IntegratedDensity

Menu "Exel Conversion"
	"convert",K_ImportExcelCPed()
end
Function K_ImportExcelCPedcore(pathname,exppre,typefl)
	string pathname,exppre,typefl
	string fullfilename=exppre+".xls"
	//XLLoadWave/S="Sheet1"/W=1/D "D:fatima:Sec32_c1_e1_frame.xls"
	XLLoadWave/p=$pathname/S="Sheet1"/W=1/D (fullfilename)
	wave/z temp_f=$(exppre+"_f")
	if (waveexists(temp_f)==0)
		rename columnA $(exppre+"_f")
		rename columnB $(exppre+"_area")
		rename columnC $(exppre+"_"+typefl)
		rename columnD $(exppre+"_aveSD")
		rename columnE $(exppre+"_Intdens")
	else
		abort (exppre+": files with that experiments already exists")
	endif
	wave/z fluorw=$(exppre+"_"+typefl)	//060330
	fluorw[10]=nan	//060330
	wave/z framew=$(exppre+"_f")
	return (numpnts(framew))
END

Function K_ImportExcelCPedmain(pathname,expname,cellNo,eresNo,baseInt,dt)
	string pathname,expname
	variable cellNo,eresNo,baseInt,dt
	string exppre

	exppre=expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_frame" 
	K_ImportExcelCPedcore(pathname,exppre,"Allcell")
	rename $(exppre+"_Allcell") $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_AllCell")
	
	exppre=expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_frap" 
	variable framenumber
	framenumber=K_ImportExcelCPedcore(pathname,exppre,"FRAP")
	rename $(exppre+"_FRAP") $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_FRAP")

	make/o/n=(framenumber) $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_base")
	wave/z BaseW=$(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_base")
	BaseW[]=baseInt
	make/o/n=(framenumber) $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_t")
	wave/z timeW=$(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_t")
	timeW[]=p*dt

	Nvar/z G_dataForm
	if (nvar_exists(G_dataForm)==0)
		variable/g G_dataForm
	endif
	G_dataForm=1101

	checkG_dataFormSpecific(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo))
	string dataformSpecName=expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_dataform"		//050802
	Nvar/z GdataformSpec=$dataformSpecName		//050802
	GdataformSpec=1101
		
	K_CheckAllGV()
End

//20110726 modified for sheets with headers
Function K_ImportExcelCPedcore20110726(pathname,exppre,typefl)
	string pathname,exppre,typefl
	string fullfilename=exppre+".csv"
	LoadWave/P=$pathname/N=imported/D/J/k=1/L={0, 1, 0, 0, 0} fullfilename
	wave/z temp_f=$(exppre+"_f")
	if (waveexists(temp_f)==0)
		rename imported0 $(exppre+"_f")
		rename imported1 $(exppre+"_area")
		rename imported2 $(exppre+"_"+typefl)
		rename imported3 $(exppre+"_aveSD")
		rename imported4 $(exppre+"_Intdens")
		wave/z imported5
		if (waveexists(imported5)==1)
			rename imported5 $(exppre+"_RawIntdens")
		endif
	else
		abort (exppre+": files with that experiments already exists")
	endif
	wave/z fluorw=$(exppre+"_"+typefl)	//060330
	fluorw[10]=nan	//060330
	wave/z framew=$(exppre+"_f")
	return (numpnts(framew))
END


//20110726 Modifed suffix for all cell, so that it ends with '_all.xls'
Function K_ImportExcelCPedmain20110726(pathname,expname,cellNo,eresNo,baseInt,dt)
	string pathname,expname
	variable cellNo,eresNo,baseInt,dt
	string exppre

	//expname = "w" + expname	//20110726
	exppre=expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_all" 
	K_ImportExcelCPedcore20110726(pathname,exppre,"Allcell")
	rename $(exppre+"_Allcell") $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_AllCell")
	
	exppre=expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_frap" 
	variable framenumber
	framenumber=K_ImportExcelCPedcore20110726(pathname,exppre,"FRAP")
	rename $(exppre+"_FRAP") $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_FRAP")

	make/o/n=(framenumber) $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_base")
	wave/z BaseW=$(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_base")
	BaseW[]=baseInt
	make/o/n=(framenumber) $(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_t")
	wave/z timeW=$(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_t")
	timeW[]=p*dt

	Nvar/z G_dataForm
	if (nvar_exists(G_dataForm)==0)
		variable/g G_dataForm
	endif
	G_dataForm=1101

	checkG_dataFormSpecific(expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo))
	string dataformSpecName=expname+"_c"+num2str(cellNo)+"_e"+num2str(eresNo)+"_dataform"		//050802
	Nvar/z GdataformSpec=$dataformSpecName		//050802
	GdataformSpec=1101
		
	K_CheckAllGV()
End


Function K_ImportExcelCPed()
	svar/z currentpath
	if (svar_exists(currentpath)==0)
		string/g  currentpath="pp"
	endif
	svar/z currentexp	
	if (svar_exists(currentexp)==0)
		string/g  currentexp="sec23"
	endif
	
	String pathname
	prompt pathname, "Path name?"
	String expname
	prompt expname, "Prefix of the File?"
	Variable exp_s
	prompt exp_s, "start with which cell?"
	Variable exp_e
	prompt exp_e, "end with which cell?"
	Variable baseint
	prompt baseint, "base intensity?"
	Variable dt
	prompt dt, "dt?"
	Doprompt "Path,Name and No.::",pathname,expname,exp_s,exp_e,baseint,dt
	if (V_flag)
		Abort "Processing Canceled"
	endif
	variable ERESmax=1
	variable i,j
	for (j=exp_s;i<exp_e+1;i+=1)
		for (i=0;i<ERESmax;i+=1)
			K_ImportExcelCPedmain(pathname,expname,j,i+1,baseint,dt)
		endfor	
	endfor
end	