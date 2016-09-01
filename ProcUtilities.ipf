#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//  From http://www.igorexchange.com/node/1464
//**
// Determine the version of a compiled procedure window
// named procedureWinTitleStr.
// The version is defined using the #pragma version
// compiler directive.  For example,
// #pragma version=1.05.
//
// As stated in the Igor documentation, the line must
// start flush with the left of the window (that is, there
// can be no leading whitespace).  Spaces
// and tabs within the directive are ignored.
//
// Returns NaN if procedure window doesn't exist,
// 1.00 if no version is defined in the procedure window,
// or the version that is defined in the procedure window.
//*
Function GetProcedureVersion(procedureWinTitleStr)
	String procedureWinTitleStr
 
	// By default, all procedures are version 1.00 unless
	// otherwise specified.
	Variable version = 1.00
	Variable versionIfError = NaN
 
	String procText = ProcedureText("", 0, procedureWinTitleStr)
	if (strlen(procText) <= 0)
		return versionIfError		// Procedure window doesn't exist.
	endif
 
	String regExp = "(?i)(?:^#pragma|\\r#pragma)(?:[ \\t]+)version(?:[\ \t]*)=(?:[\ \t]*)([\\d.]*)"
 
	String versionFoundStr
	SplitString/E=regExp procText, versionFoundStr
	if (V_flag == 1)
		version = str2num(versionFoundStr)
	endif
	return version	
End