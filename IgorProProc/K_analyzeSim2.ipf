#pragma rtGlobals=1		// Use modern global access method.



//060822	Kota
//060829
// k_diplaykinetics(sim_prefix) graphing
//k_appendkinetics(sim_prefix)

//k_diplaykinetics2_3measures(sim_prefix, curvenum)

//k_calculateInitialvalue(maxparticleNumber, ERESdinsity, BackIntensity)
// --> to get the cytoplasmic estimate

// K_importMulti2Dcore(path_name,exp_namep,exp_num)	

menu "simulation analysis"
	"Import Multiple data",K_importMulti2D()	
end

//modified
Function K_importTxtData2D(path_name,exp_name,exp_num)//,currentNum)			//import 6 controls + multiple files
	String path_name,exp_name
	Variable exp_num
	variable i
	string filename=exp_name+"_"+num2str(exp_num)+".txt"
//	LoadWave/A/w/J/k=1/L={0, 1, 0, 1, 4 }/p=$path_name filename
//	LoadWave/N=org/w/J/k=1/L={0, 1, 0, 1, 3 }/p=$path_name filename		//for 2D data
	LoadWave/N=org/J/k=1/Q/L={0, 0, 0, 0, 0 }/p=$path_name filename		//for 2D data
	variable loadnumber=V_flag
	variable samplingnumber=loadnumber-2
	string org_t=exp_name+"_"+num2str(exp_num)+"_t"
		Duplicate/o $("org"+num2str(0)) $org_t
		killwaves $("org"+num2str(0))		
	string org_int//=exp_name+"_"+num2str(exp_num)+"_t"
	for (i=0;i<samplingnumber;i+=1)
		org_int=exp_name+"_"+num2str(exp_num)+"_"+num2str(i)
		Duplicate/o $("org"+num2str(i+1)) $org_int
		killwaves $("org"+num2str(i+1))		
	endfor
	killwaves/z $("org"+num2str(loadnumber-1))
	return samplingnumber		
END

Function K_importMulti2D()		
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
	string/g ExpPrefix=exp_namep	
	K_importMulti2Dcore(path_name,exp_namep,exp_num)	
end

Function K_importMulti2Dcore(path_name,exp_namep,exp_num)	
	string path_name,exp_namep
	variable exp_num	
	variable numwavesPerSim
	variable j	
	for (j=0;j<(exp_num);j+=1)
		numwavesPerSim=K_importTxtData2D(path_name,exp_namep,j)		//040303
	endfor
	K_averageimported(exp_namep,exp_num,numwavesPerSim)			
END

Function K_ImportSingle2D()		
	String path_name
	prompt path_name, "Path name?"
	String exp_namep
	prompt exp_namep, "Prefix of the File?"
	Variable exp_num
	prompt exp_num, "Experiments Number?"	
	Doprompt "Path,Name and No.::",path_name,exp_namep,exp_num
	if (V_flag)
		Abort "Processing Canceled"
	endif	
	string exp_name
	K_importMulti2Dcore(path_name,exp_namep,exp_num)			//040303

END


Function K_averageimported(exp_name,exp_num_total,numwavesPerSim)
	string exp_name
	variable exp_num_total,numwavesPerSim
	
	variable i,j,k
	string org_int,org_int_ave,org_int_sd,org_int_sem//=exp_name+"_"+num2str(exp_num)+"_t"
	org_int=exp_name+"_"+num2str(0)+"_"+num2str(0)
	wave/z org_intw=$org_int
	variable rowlength=Dimsize(org_intw,0)

	for (i=0;i<numwavesPerSim;i+=1)
		org_int_ave=exp_name+"_r"+num2str(i)+"_ave"
		org_int_sd=exp_name+"_r"+num2str(i)+"_sd"
		org_int_sem=exp_name+"_r"+num2str(i)+"_sem"
		make/o/n=(rowlength) $org_int_ave, $org_int_sd,$org_int_sem
		wave/z org_int_avew=$org_int_ave
		wave/z org_int_sdw=$org_int_sd
		wave/z org_int_semw=$org_int_sem
		for (j=0;j<rowlength;j+=1)
			for (k=0;k<exp_num_total;k+=1)
				org_int=exp_name+"_"+num2str(k)+"_"+num2str(i)
				wave/z cur_wave= $org_int
				if ((k==0)) 
					make/o/n=(exp_num_total) tempwave
					tempwave[]=0
				 endif
				tempwave[k]=cur_wave[j]
			endfor
			wavestats/q tempwave
			org_int_avew[j]=V_avg
			org_int_sdw[j]=V_sdev
			org_int_semw[j]=V_sdev/(V_npnts^0.5)
		endfor
	endfor
end

//***************************** graphing

function k_diplaykinetics(sim_prefix)
	string sim_prefix
	string timewname=sim_prefix+"_0_t"
	string noneERESname=sim_prefix+"_r0_ave"
	string ERESname=sim_prefix+"_r2_ave"
	string boundname=sim_prefix+"_r3_ave"
	wave noneERES=$noneERESname
	wave ERES=$ERESname
	wave bound=$boundname
	wave timew=$timewname
	Display noneERES, ERES, bound vs timew
	ModifyGraph tick=2
	Label left "Particles"
	Label bottom "Time [s]"
	SetAxis left 0,100 
end

function k_appendkinetics(sim_prefix)
	string sim_prefix
	string timewname=sim_prefix+"_0_t"
	string noneERESname=sim_prefix+"_r0_ave"
	string ERESname=sim_prefix+"_r2_ave"
	string boundname=sim_prefix+"_r3_ave"
	wave noneERES=$noneERESname
	wave ERES=$ERESname
	wave bound=$boundname
	wave timew=$timewname
	appendtograph noneERES, ERES, bound vs timew
end

function k_diplaykinetics2_3measures(sim_prefix, curvenum)
	string sim_prefix
	variable curvenum
	string timewname=sim_prefix+"_0_t"
	wave timew=$timewname
	string tempname
	variable i	
	for (i=0; i<curvenum; i+=1)
		wave tempw=$(sim_prefix+"_r"+num2str(i)+"_ave")
		if (i==0)
			Display tempw vs timew
		else
			appendtograph  tempw vs timew
		endif
		
	endfor
	ModifyGraph tick=2
	Label left "Particles"
	Label bottom "Time [s]"
	SetAxis left 0,100 
end


///******************* unitilty ****************

function k_calculateInitialvalue(maxparticleNumber, ERESdinsity, BackIntensity)
	variable maxparticleNumber, ERESdinsity, BackIntensity
	variable InitialBound, InitialERES, InitialBack
	InitialBack = maxparticleNumber *BackIntensity /(255 - 100)
	InitialERES = maxparticleNumber * 155 /(255 - 100)
	InitialBound = InitialERES * ERESdinsity/100
	printf "Initial Back particles: %d  ERES particles: %d  ERES bound: %d \r", InitialBack,InitialERES,InitialBound
end
//****************** 2 compartment system, Chimecal Kinetics, *****************************//

function timewiseKon(orgKon, timestep)
	variable orgKon, timestep
	variable tempKon
	variable iter=(timestep^-1)
	tempKon = 10^(timestep * log(orgKon))
	variable calced = tempKon^iter
//	printf "iteration is %g\r",iter
//	printf "original K is %g\r",orgKon
//	printf "tempKon is %g\r",tempKon
//	printf "calculated K is %g\r",calced
	return tempKon
end


//********************* very old one *****************************
//A is free, and B is complex
function ChemicalReaction(Ainitial, Koff, Kon, totalAB, timepoint)
	variable Ainitial, Koff, Kon, totalAB,timepoint
	variable Acurrent
	if (totalAB<Ainitial) 
		Ainitial=totalAB
	endif
	Acurrent = Ainitial*e^(-1*(koff+kon)*timepoint) + (kon*totalAB/(Koff+kon))*(1-e^(-1*(koff+kon)*timepoint))
	return Acurrent
end

//************************* Emax and Gamma (old one, but same) ***********************
function ChemicalReactionConst(Ainitial, Koff, Kon, cytoplasmic, Amax, gam, timepoint)
	variable Ainitial, Koff, Kon, cytoplasmic,Amax,gam,timepoint
	variable Acurrent
//	if (totalAB<Ainitial) 
//		Ainitial=totalAB
//	endif
	//Kon=Kon*gam
	//Acurrent = Ainitial*e^(-1*(koff + Kon*cytoplasmic/Amax)*timepoint) + (kon*cytoplasmic/(Koff+kon*cytoplasmic/Amax))*(1-e^(-1*(Koff+kon*cytoplasmic/Amax)*timepoint))
	Acurrent = Ainitial*e^(-1*(koff + Kon*gam*cytoplasmic/Amax)*timepoint) + (Kon*gam*cytoplasmic/(Koff+Kon*gam*cytoplasmic/Amax))*(1-e^(-1*(Koff+Kon*gam*cytoplasmic/Amax)*timepoint))
	//Acurrent = Ainitial*e^(-1*(koff)*timepoint) + (cytoplasmic*Kon/Koff)*(1-e^(-1*(koff)*timepoint))
	return Acurrent
end

//when the cytoplasmic protein is rich enough, then B is constant. 
// Ainitial = Initial ERES intensty (bound+unbound)
// cytoplasmic = average particle numeber in the background
// Amax = ERES density


function ProfChemiReaction_constant(Ainitial, Koff, Kon, cytoplasmic,Amax,kgam)
	variable Ainitial, Koff, Kon, cytoplasmic,Amax,kgam
	string newname="kc_A"+num2str(Ainitial)+"_Koff"+num2str(koff)+"_kon"+num2str(kon)+"c"+num2str(cytoplasmic)+"_er"+num2str(Amax)
	make/o/n=200 $newname	//20sec
	//make/o/n=70 $newname	//7sec
	//Ainitial = Ainitial*Amax/100//060825 added //060920deleted
	wave kinetics=$newname
	SetScale/P x 0,0.1,"", kinetics
	kinetics[]=ChemicalReactionConst(Ainitial, Koff, Kon, cytoplasmic, Amax,kgam,x)
end

Function K_ChemicalInteraction01(w,timepoint) : FitFunc
	Wave w
	Variable timepoint

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(timepoint) = Ainitial*e^(-1*(koff + Kon*gam*cytoplasmic/Amax)*timepoint) + (Kon*gam*cytoplasmic/(Koff+Kon*gam*cytoplasmic/Amax))*(1-e^(-1*(Koff+Kon*gam*cytoplasmic/Amax)*timepoint))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ timepoint
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = Ainitial
	//CurveFitDialog/ w[1] = Koff
	//CurveFitDialog/ w[2] = Kon
	//CurveFitDialog/ w[3] = cytoplasmic
	//CurveFitDialog/ w[4] = Amax
	//CurveFitDialog/ w[5] = gam

	return w[0]*e^(-1*(w[1] + w[2]*w[5]*w[2]/w[4])*timepoint) + (w[2]*w[5]*w[3]/(w[1]+w[2]*w[5]*w[3]/w[4]))*(1-e^(-1*(w[1]+w[2]*w[5]*w[3]/w[4])*timepoint))
End


//************************* 060921 only with Emax and gamma ***********************
//Ab_init: initial value of bound proteins at timepoint 0
//k_off, k_on
//Af: free molecule density in cytoplasm.
//Emax density of ERES points
//gam: gamma value
// timepoint

function K_EmaxGamma_Equilibrium(Ab_init, k_off, k_on, Af, Emax, gam, timepoint)
	variable Ab_init, k_off, k_on, Af, Emax, gam, timepoint
	variable Acurrent
	Acurrent = Ab_init*e^(-1*(k_off + gam*k_on*Af/Emax)*timepoint) + (gam*k_on*Emax*Af/(Emax*k_off+gam*k_on*Af))*(1-e^(-1*(k_off+gam*k_on*Af/Emax)*timepoint))
	return Acurrent
end

//when the cytoplasmic protein is rich enough, then B is constant. 
// Ainitial = Initial ERES intensty (bound+unbound)
// cytoplasmic = average particle numeber in the background
// Amax = ERES density


function Prof_EmaxGamma_Equilibrium(Ab_init, k_off, k_on, Af, Emax, gam)
	variable Ab_init, k_off, k_on, Af, Emax, gam
	string newname="kc_A"+num2str(Ab_init)+"_Koff"+num2str(k_off)+"_kon"+num2str(k_on)+"c"+num2str(Af)+"_er"+num2str(Emax)
	make/o/n=200 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x 0,0.1,"", kinetics
	kinetics[]=K_EmaxGamma_Equilibrium(Ab_init, k_off, k_on, Af, Emax, gam,x)
	variable converge=(gam*k_on*Emax*Af/(Emax*k_off+gam*k_on*Af))
	printf "Converges to: %f", converge
end

Function fit_EmaxGamma_Equilibrium(w,timepoint) : FitFunc
	Wave w
	Variable timepoint

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(timepoint) = Ab_init*e^(-1*(k_off + gam*k_on*Af/Emax)*timepoint) + (gam*k_on*Emax*Af/(Emax*k_off+gam*k_on*Af))*(1-e^(-1*(k_off+gam*k_on*Af/Emax)*timepoint))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ timepoint
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = Ab_init
	//CurveFitDialog/ w[1] = k_off
	//CurveFitDialog/ w[2] = k_on
	//CurveFitDialog/ w[3] = Af
	//CurveFitDialog/ w[4] = Emax
	//CurveFitDialog/ w[5] = gam

	return K_EmaxGamma_Equilibrium(w[0], w[1], w[2], w[3], w[4], w[5], timepoint)
End

		//****************** FRAP ****************************
function K_EmaxGamma_FRAP(Ab_init, k_off, k_on, Af, Emax, gam, timepoint)
	variable Ab_init,  k_off, k_on, Af, Emax, gam, timepoint
	variable Acurrent
	Acurrent = Ab_init*e^(-1*k_off*timepoint) + (gam*k_on*Emax*Af/(Emax*k_off+gam*k_on*Af))*(1-e^(-1*k_off * timepoint))
	return Acurrent
end

//when the cytoplasmic protein is rich enough, then B is constant. 
// Ainitial = Initial ERES intensty (bound+unbound)
// cytoplasmic = average particle numeber in the background
// Amax = ERES density


function Prof_EmaxGamma_FRAP(Ab_init, k_off, k_on, Af, Emax, gam)
	variable Ab_init,  k_off, k_on, Af, Emax, gam

	variable Ab_calc=return_Ab(Ab_init, k_off, k_on, Af, Emax, gam)
	
	string newname="kf_A"+num2str(Ab_init)+"_koff"+num2str(k_off)+"_kon"+num2str(k_on)+"c"+num2str(Af)+"_er"+num2str(Emax)
	make/o/n=400 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x -0.4,0.1,"", kinetics
	
	kinetics[]=K_EmaxGamma_FRAP(Ab_init, k_off, k_on, Af, Emax, gam,x)
	variable converge=Ab_calc
	printf "Converges to: %f\r", converge
end

function return_Ab(Ab_init, k_off, k_on, Af, Emax, gam)
	variable	Ab_init, k_off, k_on, Af, Emax, gam
	variable Ab_calc
	Ab_calc = gam*k_on*Emax*Af/(Emax*k_off+gam*k_on*Af)
	return Ab_calc
end
		
Function fit_EmaxGamma_FRAP(w,timepoint) : FitFunc
	Wave w
	Variable timepoint

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(timepoint) = Ab_init*e^(-1*k_off*timepoint) + (gam*k_on*Emax*Af/(Emax*k_off+gam*k_on*Af))*(1-e^(-1*k_off * timepoint))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ timepoint
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = Ab_init
	//CurveFitDialog/ w[1] = k_off
	//CurveFitDialog/ w[2] = k_on
	//CurveFitDialog/ w[3] = gam
	//CurveFitDialog/ w[4] = Emax
	//CurveFitDialog/ w[5] = Af


	//return 	w[0]*e^(-1*w[1]*timepoint) + (w[3]*w[2]*w[4]*w[5]/(w[4]*w[1]+w[3]*w[2]*w[5]))*(1-e^(-1*w[1] * timepoint))
	return K_EmaxGamma_FRAP(w[0], w[1], w[2], w[5], w[4], w[3], timepoint)
End

//************************* 061012 only with Emax and gamma bimolecular model***********************
//Ab_init: initial value of bound proteins at timepoint 0
//k_off, k_on
//Af: free molecule density in cytoplasm.
//Emax density of ERES points
//gam: gamma value
// timepoint

function K_EmaxGamma061012_Eq(Ab_init, k_off, k_on, Af, Emax, gam, timepoint)
	variable Ab_init, k_off, k_on, Af, Emax, gam, timepoint
	variable Acurrent
	Acurrent = Ab_init*e^(-1*(k_off + gam*k_on*Af)*timepoint) + (gam*k_on*Emax*Af/(k_off+gam*k_on*Af))*(1-e^(-1*(k_off+gam*k_on*Af)*timepoint))
	return Acurrent
end

//when the cytoplasmic protein is rich enough, then B is constant. 
// Ainitial = Initial ERES intensty (bound+unbound)
// cytoplasmic = average particle numeber in the background
// Amax = ERES density


function Prof_EmaxGamma061012_Eq(Ab_init, k_off, k_on, Af, Emax, gam)
	variable Ab_init, k_off, k_on, Af, Emax, gam
	string newname="kc_A"+num2str(Ab_init)+"_Koff"+num2str(k_off)+"_kon"+num2str(k_on)+"c"+num2str(Af)+"_er"+num2str(Emax)
	make/o/n=200 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x 0,0.1,"", kinetics
	kinetics[]=K_EmaxGamma061012_Eq(Ab_init, k_off, k_on, Af, Emax, gam,x)
	variable converge=(gam*k_on*Emax*Af/(k_off+gam*k_on*Af))
	printf "Converges to: %f", converge
end

Function fit_EmaxGamma061012_Eq(w,timepoint) : FitFunc
	Wave w
	Variable timepoint

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(timepoint) = Ab_init*e^(-1*(k_off + gam*k_on*Af)*timepoint) + (gam*k_on*Emax*Af/(k_off+gam*k_on*Af))*(1-e^(-1*(k_off+gam*k_on*Af)*timepoint))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ timepoint
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = Ab_init
	//CurveFitDialog/ w[1] = k_off
	//CurveFitDialog/ w[2] = k_on
	//CurveFitDialog/ w[3] = Af
	//CurveFitDialog/ w[4] = Emax
	//CurveFitDialog/ w[5] = gam

	return K_EmaxGamma061012_Eq(w[0], w[1], w[2], w[3], w[4], w[5], timepoint)
End

		//****************** FRAP ****************************
function K_EmaxGamma061012_FRAP(Ab_init, k_off, k_on, Af, Emax, gam, timepoint)
	variable Ab_init,  k_off, k_on, Af, Emax, gam, timepoint
	variable Acurrent
	Acurrent = Ab_init*e^(-1*k_off*timepoint) + (gam*k_on*Emax*Af/(k_off+gam*k_on*Af))*(1-e^(-1*k_off * timepoint))
	return Acurrent
end

//when the cytoplasmic protein is rich enough, then B is constant. 
// Ainitial = Initial ERES intensty (bound+unbound)
// cytoplasmic = average particle numeber in the background
// Amax = ERES density


function Prof_EmaxGamma061012_FRAP(Ab_init, k_off, k_on, Af, Emax, gam)
	variable Ab_init,  k_off, k_on, Af, Emax, gam

	variable Ab_calc=return_Ab061012(Ab_init, k_off, k_on, Af, Emax, gam)
	
	string newname="kf_A"+num2str(Ab_init)+"_koff"+num2str(k_off)+"_kon"+num2str(k_on)+"c"+num2str(Af)+"_er"+num2str(Emax)
	make/o/n=400 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x -0.4,0.1,"", kinetics
	
	kinetics[]=K_EmaxGamma061012_FRAP(Ab_init, k_off, k_on, Af, Emax, gam,x)
	variable converge=Ab_calc
	printf "Converges to: %f\r", converge
end

function return_Ab061012(Ab_init, k_off, k_on, Af, Emax, gam)
	variable	Ab_init, k_off, k_on, Af, Emax, gam
	variable Ab_calc
	Ab_calc = gam*k_on*Emax*Af/(k_off+gam*k_on*Af)
	return Ab_calc
end
		
Function fit_EmaxGamma061012_FRAP(w,timepoint) : FitFunc
	Wave w
	Variable timepoint

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(timepoint) = Ab_init*e^(-1*k_off*timepoint) + (gam*k_on*Emax*Af/(k_off+gam*k_on*Af))*(1-e^(-1*k_off * timepoint))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ timepoint
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = Ab_init
	//CurveFitDialog/ w[1] = k_off
	//CurveFitDialog/ w[2] = k_on
	//CurveFitDialog/ w[3] = gam
	//CurveFitDialog/ w[4] = Emax
	//CurveFitDialog/ w[5] = Af


	//return 	w[0]*e^(-1*w[1]*timepoint) + (w[3]*w[2]*w[4]*w[5]/(w[4]*w[1]+w[3]*w[2]*w[5]))*(1-e^(-1*w[1] * timepoint))
	return K_EmaxGamma061012_FRAP(w[0], w[1], w[2], w[5], w[4], w[3], timepoint)
End





//*********************************************************************************


//particles
function K_simulatetwocomparts(Ainitial, Koff, Kon, totalAB,dt)
	variable Ainitial, Koff, Kon, totalAB,dt
	make/o/n=(totalAB) ParticleInfo
	variable ratioA=Ainitial/totalAB
	//initialize particle positions
	variable i,j,position
	for (i=0; i<dimsize(particleinfo,0); i+=1)
		position =abs(enoise(1))
		if (position<ratioA)
			Particleinfo[i]=1 //in A
		else
			ParticleInfo[i]=0
		endif	
	endfor
	duplicate/o   ParticleInfo ParticleInfo_copy
	variable length=20 //sec
	variable steps=length/dt
	variable freq=floor(steps/100)
	string newname="p_A"+num2str(Ainitial)+"_Koff"+num2str(koff)+"_kon"+num2str(kon)
	make/o/n=100 $newname
	wave Anumber=$newname
	SetScale/P x 0,(freq*dt),"", Anumber
	
	variable pkon=KtoPtranslator1(Kon,dt)
	variable pkoff=KtoPtranslator1(Koff,dt)
	printf "pkon %f   pkoff %f\r",pkon,pkoff
	variable reaction, counter
	for (j=0;j<steps;j+=1)
		if (mod(j,freq)==0)
			Anumber[counter]=sum(particleinfo)
			counter+=1
		endif
		for (i=0; i<dimsize(particleinfo,0); i+=1)

			if (particleinfo[i]==0)	//in B
				reaction =abs(enoise(1))
				if (reaction<pkon)
					particleinfo[i]=1
				endif
			else		//in A
				reaction =abs(enoise(1))	
				if (reaction<pkoff)
					particleinfo[i]=0
				endif
			endif
		endfor

	endfor	
end

//simply divide by steps
function KtoPtranslator1(kvalue,dt)
	variable kvalue,dt
	variable stepspersec=1/dt
	kvalue/=stepspersec
	return kvalue
end

//use log
function KtoPtranslator2(kvalue,dt)
	variable kvalue,dt
	return timewiseKon(kvalue, dt)
end

//use original
function KtoPtranslator3(kvalue,dt)
	variable kvalue,dt
	return kvalue
end


function K_testrndom()
	make/o/n=(2000) ParticleInfo
	variable i,j,position
	for (i=0; i<dimsize(particleinfo,0); i+=1)
		Particleinfo[i] =abs(enoise(1))
	endfor
	Histogram/B={0,0.1,10} ParticleInfo,ParticleInfo_Hist
end


//***************

function ChemicalReactionSimplest(Kon, Koff,  timepoint)
	variable Kon, Koff,  timepoint
	variable Acurrent
	Acurrent =(kon/(kon+koff))*(1- e^(-1*(koff+kon)*timepoint) )
	return Acurrent
end

function ProfileChemicalReactionSimple(Kon, Koff)
	variable Kon, Koff
	string newname="k_"+"_Koff"+num2str(koff)+"_kon"+num2str(kon)
	make/o/n=200 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x 0,0.1,"", kinetics
	kinetics[]=ChemicalReactionSimplest( Kon, Koff,  x)
	printf "converges to %d\r", (kon/(Koff+kon))
end


//***********************************

function K_testERES_Particleprobablity(testmat2D,particlenum)
wave testmat2D
variable particlenum

//make/o/n=(10,10) testmat2D
testmat2D[][]=0
variable placed=0
variable i,tempX,tempY
	for (i=0; i<particlenum; i+=1)
		placed=0
		do
			tempX = floor(abs(enoise(9.999,2)))
			tempY = floor(abs(enoise(9.999,2)))
			if  (testmat2D[tempX][tempY]==0)
				testmat2D[tempX][tempY]=1
				placed=1
			endif
		while (placed==0)
	endfor

end

function K_testERESprobablity()
	make/o/n=(10,10) eresmat2D, particlemat2D
	K_testERES_Particleprobablity(eresmat2D,50)
	K_testERES_Particleprobablity(particlemat2D,50)
	variable i, j, counter
	counter=0
	for (j=0;j<10;j+=1)	
		for (i=0;i<10;i+=1)	
			if ((eresmat2D[i][j]==1) && (particlemat2D[i][j]==1))
				counter+=1
			endif
		endfor
	endfor
	print counter
end



//*******************************
//estimate ratio
function K_calcGamma(k_off,k_on, Emax, Ab, Af)
	variable k_off,k_on, Emax, Ab, Af
	variable gammaV=k_off*Emax*Ab/k_on/Af/(Emax-Ab)
	print gammaV
	return gammaV
end



Function fitStdExp_061009(w,timepoint) : FitFunc
	Wave w
	Variable timepoint

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(timepoint) =A*(1-exp(-1*tau*timepoint-bleachtime))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ timepoint
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = tau
	//CurveFitDialog/ w[2] = bleachtime
	//
	
	return w[0] * ( 1 - exp(-1*w[1]*(timepoint-w[2])))
End

function getHalfMaxfromW()
	wave/z W_coef
	printf "half max is %f\r", (-1*log(0.5)/W_coef[1])
end


//============================= unused Models =====================================================================


//**************************** sprague formulas ****************************

function ChemicalReactionSprague(Total_eq, Comp_eq, ERESmax,Koff, Kon, Particle_initial, timepoint)
	variable Total_eq, Comp_eq, ERESmax,Koff, Kon,Particle_initial,timepoint
	variable Acurrent
	variable Kon_dash
	if ((ERESmax < Comp_eq)) 
		abort("check parameter")
	endif
	Kon_dash = kon*(ERESmax - Comp_eq)
	variable K_value=Particle_initial - Total_eq * kon_dash/(kon_dash+koff)
	Acurrent = Total_eq*Kon_dash/(Kon_dash+koff) +K_value * e^(-1 * Koff * timepoint)
	return Acurrent
end


function ChemicalReactionSprague2(Total_eq, ERESmax, bindingMax, Koff, Kon, Particle_initial, timepoint)
	variable Total_eq, bindingMax, ERESmax,Koff, Kon,Particle_initial,timepoint
	variable Acurrent
	variable Kon_dash
	Kon_dash = kon*bindingMax
	variable k_ratio=kon_dash/(kon_dash+koff)
	variable K_value=Particle_initial - k_ratio * Total_eq  * (1 - k_ratio * Total_eq/ ERESmax)
	Acurrent = k_ratio * Total_eq  * (1 - k_ratio * Total_eq/ ERESmax) + K_value*e^(-1 * Koff * timepoint)
	return Acurrent
end

function ChemicalReactionSprague3(Total_eq,Koff, Kon, Particle_initial, timepoint)
	variable Total_eq,Koff, Kon, Particle_initial, timepoint
	variable Acurrent
	variable k_ratio=kon/(kon + koff)
	variable K_value=Particle_initial - k_ratio * Total_eq
	Acurrent = k_ratio * Total_eq  + K_value*e^(-1 * Koff * timepoint)
	return Acurrent
end


//Total_eq: initial intensity at the ERES spot
//Cytop_eq: initial intensity at the cytoplasm
//Particle_initial: initial value at time point 0; in case of FRAP, 0. 

function ProfChemiReaction_sprague1(Total_eq, Cytop_eq, ERESmax,Koff, Kon, Particle_initial, initialTimepoint, duration)
	variable Total_eq, Cytop_eq, ERESmax,Koff, Kon, Particle_initial, initialTimepoint, duration
	string newname="SP_A"+num2str(Total_eq)+"_Koff"+num2str(koff)+"_kon"+num2str(kon)+"c"+num2str(Cytop_eq)+"_er"+num2str(ERESmax)
	make/o/n=200 $newname	//
	variable dt=( duration - initialTimepoint)/200
	wave kinetics=$newname
	SetScale/P x initialTimepoint, dt,"", kinetics

	variable Comp_eq = Total_eq - Cytop_eq
	kinetics[]=ChemicalReactionSprague(Total_eq, Comp_eq, ERESmax,Koff, Kon, 0, x)
	variable converge = kon*(ERESmax-Comp_eq)*Total_eq/(koff+kon*(ERESmax-Comp_eq) )
	printf "Converges to %f\r", converge
end


function ProfChemiReaction_sprague2(Total_eq, ERESmax,bindingMax,Koff, Kon, Particle_initial, initialTimepoint, duration)
	variable Total_eq, ERESmax,bindingMax,Koff, Kon, Particle_initial, initialTimepoint, duration
	string newname="SP_A"+num2str(Total_eq)+"_Koff"+num2str(koff)+"_kon"+num2str(kon)+"sm"+num2str(bindingMax)+"_er"+num2str(ERESmax)
	make/o/n=200 $newname	//
	variable dt=( duration - initialTimepoint)/200
	wave kinetics=$newname
	SetScale/P x initialTimepoint, dt,"", kinetics

	kinetics[]=ChemicalReactionSprague2(Total_eq, ERESmax,bindingMax, Koff, Kon, 0, x)
	variable Kon_dash = kon*bindingMax
	variable k_ratio=kon_dash/(kon_dash+koff)
	variable converge = k_ratio * Total_eq  * (1 - k_ratio * Total_eq/ ERESmax)	
	printf "Converges to %f\r", converge
end

//simplest
function ProfChemiReaction_sprague3(Total_eq, Koff, Kon, Particle_initial, initialTimepoint, duration)
	variable Total_eq, Koff, Kon, Particle_initial, initialTimepoint, duration
	string newname="SP_A"+num2str(Total_eq)+"_Koff"+num2str(koff)+"_kon"+num2str(kon)
	make/o/n=200 $newname	//
	variable dt=( duration - initialTimepoint)/200
	wave kinetics=$newname
	SetScale/P x initialTimepoint, dt,"", kinetics

	kinetics[]=ChemicalReactionSprague3(Total_eq,Koff, Kon, 0, x)
	variable converge = kon/(koff+kon)*Total_eq
	printf "Converges to %f\r", converge
end


//************************************* devoid formula with max particle **************************************

function Equilibrium060919(bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, timepoint)
	variable bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, timepoint
	variable K_on_dash, Acurrent,tau,plateau

	K_on_dash = V_gamma * K_on * Emax * Acyto / maxparticle
	tau=k_off+(K_on_dash/maxparticle)
	plateau=maxparticle*K_on_dash/(maxparticle*k_off+K_on_dash)
	Acurrent =  bound_init*exp(-1 *tau *timepoint) +plateau *(1-exp(-1 *tau *timepoint))
	return Acurrent
end

function EqConv060919(bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, timepoint)
	variable bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, timepoint
	variable K_on_dash, Acurrent,tau,plateau

	K_on_dash = V_gamma * K_on * Emax * Acyto / maxparticle
	tau=k_off+(K_on_dash/maxparticle)
	plateau=maxparticle*K_on_dash/(maxparticle*k_off+K_on_dash)
	printf "K_on_dash  %f\r", K_on_dash
	printf "tau  %f\r", tau
//	printf "K_on_dash to %d\r", K_on_dash	
	return plateau
end

function calculategamma(Abound, Acyto, K_on, k_off, maxparticle, Emax)
	variable Abound, Acyto, K_on, k_off, maxparticle, Emax
	variable V_gamma
	V_gamma=k_off*(maxparticle^2)*Abound/k_on/Emax/Acyto/(maxparticle-Abound)
	printf "gamma  %f\r", V_gamma
	return V_gamma
end

function ProfileEQ060919(bound_init, Acyto, k_off, k_on, maxparticle, Emax, V_gamma)
	variable bound_init, Acyto, k_off, k_on, maxparticle, Emax, V_gamma
	string newname="k_Ab"+num2str(bound_init)+"_Af"+num2str(Acyto)+"_Koff"+num2str(k_off)+"_kon"+num2str(k_on)
	make/o/n=200 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x 0,0.1,"", kinetics
	kinetics[]=Equilibrium060919(bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, x)
	printf "converges to %d\r", EqConv060919(bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, 0)
end

//Function fitEq_060919(w,timepoint) : FitFunc
//	Wave w
//	Variable timepoint
//
//	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
//	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
//	//CurveFitDialog/ Equation:
//	//CurveFitDialog/ f(timepoint) = Equilibrium060919(bound_init, k_off, k_on, maxparticle, Emax, Acyto, V_gamma, timepoint)
//	//CurveFitDialog/ End of Equation
//	//CurveFitDialog/ Independent Variables 1
//	//CurveFitDialog/ timepoint
//	//CurveFitDialog/ Coefficients 7
//	//CurveFitDialog/ w[0] = bound_init
//	//CurveFitDialog/ w[1] = k_off
//	//CurveFitDialog/ w[2] = k_on
//	//CurveFitDialog/ w[3] = maxparticle
//	//CurveFitDialog/ w[4] = Emax
//	//CurveFitDialog/ w[5] = Acyto
//	//CurveFitDialog/ w[6] = V_gamma
//	
//	return Equilibrium060919(w[0], w[1], w[2], w[3], w[4], w[5], w[6], timepoint)
//End


function FRAP060919(bound_init, k_off, k_on, maxparticle, Emax, Acyto, Abound_tot,V_gamma, timepoint)
	variable bound_init, k_off, k_on, maxparticle, Emax, Acyto, Abound_tot,V_gamma, timepoint
	variable Kon_dash,Acurrent
	Kon_dash = k_on * ((maxparticle-Abound_tot)/maxparticle)*Emax/maxparticle*V_gamma*Acyto
	Acurrent = bound_init*exp(-1*k_off*timepoint)+Kon_dash/k_off*(1-exp(-1*k_off*timepoint))
end

function ProfileChemicalReaction(Ainitial, Koff, Kon, totalAB)
	variable Ainitial, Koff, Kon, totalAB
	string newname="k_A"+num2str(Ainitial)+"_Koff"+num2str(koff)+"_kon"+num2str(kon)
	make/o/n=200 $newname	//20sec
	wave kinetics=$newname
	SetScale/P x 0,0.1,"", kinetics
	kinetics[]=ChemicalReaction(Ainitial, Koff, Kon, totalAB, x)
	printf "converges to %d\r", (kon*totalAB/(Koff+kon))
end