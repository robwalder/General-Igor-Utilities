#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.1

// Added GetIndex.  Useful for making tables of iterations and then finding the proper index.

Function GetIndex(IterationWave,TargetIteration)
	Wave IterationWave
	Variable TargetIteration
	Variable FoundVelocity=0, CurrentIndex=0,CurrentIterationCount=0
	Variable NumVelocities=DimSize(IterationWave,0)
	Variable NextIterationCount=IterationWave[0]
	
	do
		If((TargetIteration>=CurrentIterationCount)&&(TargetIteration<=NextIterationCount))
			FoundVelocity=1
		Else
			CurrentIndex+=1
			If(CurrentIndex>=NumVelocities)
				CurrentIndex=0
			EndIf

			Variable NextIndex=CurrentIndex+1
			If(NextIndex>=NumVelocities)
				NextIndex=0
			EndIf
			CurrentIterationCount=NextIterationCount
			NextIterationCount+=IterationWave[NextIndex]
		EndIf
	While(!FoundVelocity)
	
	Return CurrentIndex

End

Function/S GetWaveDimNames(TargetWave,[DimNumber])
	Wave TargetWave
	Variable DimNumber
	If(ParamIsDefault(DimNumber))
		DimNumber=0
	EndIf
	Variable WaveSize=DimSize(TargetWave,DimNumber)
	Variable DimCounter=0
	String OutputString=""
	For(DimCounter=0;DimCounter<WaveSize;DimCounter+=1)
		OutputString+=GetDimLabel(TargetWave, DimNumber, DimCounter )+";"
	EndFor
	Return OutputString

End


Function/S WaveDimValuesToString(TargetWave,[DimNumber])
	Wave TargetWave
	Variable DimNumber
	If(ParamIsDefault(DimNumber))
		DimNumber=0
	EndIf
	Variable WaveSize=DimSize(TargetWave,DimNumber)
	Variable DimCounter=0
	String OutputString=""
	For(DimCounter=0;DimCounter<WaveSize;DimCounter+=1)
		OutputString+=GetDimLabel(TargetWave, DimNumber, DimCounter ) +"="+num2str(TargetWave[DimCounter])+";\r"
	EndFor
	Return OutputString
End
Function/S WaveDimTextToString(TargetWave,[DimNumber])
	Wave/T TargetWave
	Variable DimNumber
	If(ParamIsDefault(DimNumber))
		DimNumber=0
	EndIf

	Variable WaveSize=DimSize(TargetWave,DimNumber)
	Variable DimCounter=0
	String OutputString=""
	For(DimCounter=0;DimCounter<WaveSize;DimCounter+=1)
		OutputString+=GetDimLabel(TargetWave, DimNumber, DimCounter ) +"="+TargetWave[DimCounter]+";\r"
	EndFor
	Return OutputString
End

Function/S StandardCypherWaveNote()
	String OutputString= "K="+num2str(GV("SpringConstant"))+";\r"
	OutputString+= "Invols="+num2str(GV("InvOLS"))+";\r"
	OutputString+= "Date="+date()+";\r"
	OutputString+= "Time="+time()+";\r"
	
	OutputString+=  "ZLVDTSens="+num2str(GV("ZLVDTSens"))+";\r"
	OutputString+=  "ZLVDTOffset="+num2str(GV("ZLVDTOffset"))+";\r"
	OutputString+=  "XLVDTSens="+num2str(GV("XLVDTSens"))+";\r"
	OutputString+=  "XLVDTOffset="+num2str(GV("XLVDTOffset"))+";\r"
	OutputString+=  "YLVDTSens="+num2str(GV("YLVDTSens"))+";\r"
	OutputString+=  "YLVDTOffset="+num2str(GV("YLVDTOffset"))+";\r"
	OutputString+=  "XLVDT="+num2str( td_rv("Cypher.LVDT.X"))+";\r"
	OutputString+=  "YLVDT="+num2str( td_rv("Cypher.LVDT.Y"))+";\r"
	OutputString+=  "ZLVDT="+num2str( td_rv("Cypher.LVDT.Z"))+";\r"
	
	Wave/T VersionWave=::packages:MFP3d:Main:VersionWave
	If(WaveExists(VersionWave))
		OutputString+=  "AR Version="+VersionWave[%'AR Version']+";\r"

	EndIf
	Return OutputString
End

Function GetWaveNoteValue(TargetWave,TargetName)
	Wave TargetWave
	String TargetName
	Return str2num(GetWaveNoteString(TargetWave,TargetName))
End

Function/S GetWaveNoteString(TargetWave,TargetName)
	Wave TargetWave
	String TargetName 
	String WaveNote=note(TargetWave)
	String TargetString=StringByKey(TargetName,WaveNote,"=","\r")
	Variable TargetStringLength=strlen(TargetString)
	Return TargetString[0,TargetStringLength-2]
End

Function UpdateWaveNoteValue(TargetWave,TargetName,NewValue)
	Wave TargetWave
	String TargetName
	Variable NewValue
	UpdateWaveNoteString(TargetWave,TargetName,num2str(NewValue))
End

Function UpdateWaveNoteString(TargetWave,TargetName,NewString)
	Wave TargetWave
	String TargetName,NewString
	NewString+=";"
	
	String WaveNote=note(TargetWave)
	String NewWaveNote=ReplaceStringByKey(TargetName, WaveNote, NewString,"=","\r")
	Note/K TargetWave, NewWaveNote 
End

Function RemoveWaveNoteString(TargetWave,TargetName)
	Wave TargetWave
	String TargetName
	
	String WaveNote=note(TargetWave)
	String NewWaveNote=RemoveByKey(TargetName, WaveNote,"=","\r")
	Note/K TargetWave, NewWaveNote 
End




Function/Wave MakeForceWave(DefV,[ForceWaveName])
	Wave DefV
	String ForceWaveName
	If(ParamIsDefault(ForceWaveName))
		ForceWaveName="Force"
	EndIf
	Variable SpringConstant=GetWaveNoteValue(DefV,"K")
	Variable Invols=GetWaveNoteValue(DefV,"Invols")
	Variable Offset=-GetWaveNoteValue(DefV,"DefVOffset")
	If(numtype(Offset)==2)
		Offset=0
	EndIf
	Variable VtoF=-1*SpringConstant*Invols
	
	Duplicate/O DefV,$ForceWaveName/Wave=Force
	FastOP Force=DefV+(Offset)
	FastOP Force=(VtoF)*Force
	SetScale d 0,0,"N", Force
	Return Force
End

Function/Wave MakeSeparationWave(DefV,ZSensor,[SepWaveName])
	Wave DefV,ZSensor
	String SepWaveName
	If(ParamIsDefault(SepWaveName))
		SepWaveName="Sep"
	EndIf
	
	Variable Invols=GetWaveNoteValue(DefV,"Invols")
	Variable Offset=-GetWaveNoteValue(DefV,"DefVOffset")
	Variable ZSensorSens=-1*GetWaveNoteValue(ZSensor,"ZLVDTSens")
	Variable ZSensorOffset=-1*GetWaveNoteValue(ZSensor,"ZLVDTOffset")
	
	If(numtype(Offset)==2)
		Offset=0
	EndIf
	Duplicate/O DefV, Defl
	FastOp Defl=DefV+(Offset)
	FastOp Defl=(Invols)*Defl
	Duplicate/O ZSensor,$SepWaveName/Wave=Sep
	FastOp Sep=ZSensor+(ZSensorOffset)
	FastOP Sep=(ZSensorSens)*Sep+Defl
	KillWaves Defl
	SetScale d 0,0,"m", Sep
	Return Sep
End