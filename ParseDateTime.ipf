#pragma rtGlobals=3		// Use modern global access method and strict wave access.


// Get the time in seconds for a given date and time string
Function ParseDateTime(DateString,TimeString,[DateFormat])
	String DateString,TimeString,DateFormat
	
	If(ParamIsDefault(DateFormat))
		DateFormat="StandardFormat"
	EndIf

	Variable DateInSecs=ParseDateString(DateString,Format=DateFormat)
	Variable TimeInSecs=Time2Secs(TimeString)
	
	Return DateInSecs+TimeInSecs
	
End


// Function to parse date strings.
// Some code borrowed from http://www.igorexchange.com/node/613
Function ParseDateString(str,[Format]) 
	String str,Format		
 
	Variable day, month, year
	String DayOfWeek,monthStr=""
	
	If(ParamIsDefault(Format))
		Format="StandardFormat"
	EndIf
 
	StrSwitch(Format)
		case "StandardFormat":
			sscanf str, "%s %3s%d,%4d", DayOfWeek, monthStr, day, year
		break
		case "yyyy-mm-dd":
			sscanf str, "%4d-%2d-%2d", year,month,day
		break
	
	EndSwitch
 
	strswitch(monthStr)
		case "Jan":
			month=1
			break
		case "Feb":
			month=2
			break
		case "Mar":
			month=3
			break
		case "Apr":
			month=4
			break
		case "May":
			month=5
			break
		case "Jun":
			month=6
			break
		case "Jul":
			month=7
			break
		case "Aug":
			month=8
			break
		case "Sep":
			month=9
			break
		case "Oct":
			month=10
			break
		case "Nov":
			month=11
			break
		case "Dec":
			month=12
			break
	endswitch
	
	Variable dt			// Igor date/time format.
	dt = date2secs(year, month, day)
	return dt
End

// From http://www.igorexchange.com/node/1567
//**
// Convert a formatted time string into a number
// of seconds.  The function returns -1 if there
// was an error.
//*
Function Time2Secs(timeString)
	String timeString
 
	// NOTE:  timeString is assumed to be a colon-separated
	// string as hours:minutes:seconds PM where
	// the PM may also be AM or may be omitted.
	// Leading zeros are allowed but not required for each
	// of the three digit groups.
	// The space between the seconds digits and the 
	// AM or PM is optional.  If neither AM nor PM is
	// found, the time will be assumed to already be in
	// 24-hour format.  The case of AM and PM does not matter.
	// The range of the digits is not checked.
	Variable hours, minutes, seconds
	String ampmStr = ""
	sscanf  timeString, "%u:%u:%u%s", hours, minutes, seconds, ampmStr
	if (V_flag < 3)
		print "Error in Time2Secs:  could not successfully parse the time."
		return -1
	elseif (V_flag == 4)
		// Determine whether AM or PM or something bogus
		// was used.
		if (cmpstr(" ", ampmStr[0]) == 0)
			// Get rid of the leading space.
			ampmStr = ampmStr[1, strlen(ampmStr) - 1]
		endif
		// Test that ampmStr is now either "AM" or "PM"
		// (case insensitive).  If not, then it's a bogus string.
		ampmStr = UpperStr(ampmStr)
		StrSwitch (ampmStr)
			Case "AM":
				// Compensate for the fact that, eg., 12:30:30 AM is
				// only 30 minutes and 30 seconds past midnight (the
				// beginning of the day), and not 12 hours 30 minutes
				// and 30 seconds.
				if (hours == 12)
					hours -= 12
				endif
				break
			Case "PM":
				// Compensate for the fact that, eg., 12:30:30 PM is
				// only 30 minutes and 30 seconds past noon, which
				// is 12 hours past midnight (the beginning of the day),
				// and not 24 hours 30 minutes and 30 seconds.
				if (hours == 12)
					// Don't need to do anything.
				else
					hours += 12				
				endif
				break
			default:
				// It's bogus, report error to user.
				print "Error in Time2Secs:  Could not parse AM/PM string."
				return -1
		EndSwitch
	endif
 
	// Do the conversion into seconds.
	seconds += (minutes * 60) + (hours * 60 * 60)
	return seconds
End