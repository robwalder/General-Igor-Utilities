#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function LoadSavedWaves(SavedDF,[LoadToDF,ClearWavesInLoadToDF])
	String SavedDF,LoadToDF
	Variable ClearWavesInLoadToDF

	If(ParamIsDefault(ClearWavesInLoadToDF))
		ClearWavesInLoadToDF=1
	EndIf
	If(ParamIsDefault(LoadToDF))
		LoadToDF=GetDataFolder(1)
	EndIf
	If(!DataFolderExists(SavedDF)||!DataFolderExists(LoadToDF))
		Return 0
	EndIF

	SetDataFolder $LoadToDF	
	IF(ClearWavesInLoadToDF)
		KillWaves/A/Z
	EndIF

	SetDataFolder $SavedDF
	String WaveNames = WaveList("*", ";" ,"" )
	
	Variable NumWavesToCopy=ItemsInList(WaveNames, ";")
	Variable Counter=0
	For(Counter=0;Counter<NumWavesToCopy;Counter+=1)
		String CurrentWaveName=SavedDF+":"+StringFromList(Counter, WaveNames)
		String NewWaveName=LoadToDF+StringFromList(Counter, WaveNames)
		Duplicate/O $CurrentWaveName,$NewWaveName
	EndFor
	
	SetDataFolder $LoadToDF
	
	Return 1
End

Function SaveWavesToDF(SavedToDF,[LoadFromDF])
	String SavedToDF,LoadFromDF

	If(ParamIsDefault(LoadFromDF))
		LoadFromDF=GetDataFolder(1)
	EndIf
	
	SetDataFolder $LoadFromDF
	String WaveNames = WaveList("*", ";" ,"" )
	NewDataFolder/O $SavedToDF
	
	Variable NumWavesToCopy=ItemsInList(WaveNames, ";")
	Variable Counter=0
	For(Counter=0;Counter<NumWavesToCopy;Counter+=1)
		String CurrentWaveName=LoadFromDF+StringFromList(Counter, WaveNames)
		String NewWaveName=SavedToDF+":"+StringFromList(Counter, WaveNames)
		Duplicate/O $CurrentWaveName,$NewWaveName
	EndFor
	
End