on getDateSerial()
	set currentDate to current date

	-- Get UTC offset in seconds and adjust to UTC
	set timeZoneOffset to time to GMT
	set utcDate to currentDate - timeZoneOffset

	-- Extract date components
	set yearNum to year of utcDate
	set monthNum to month of utcDate as integer
	set dayNum to day of utcDate
	set hourNum to hours of utcDate
	set minuteNum to minutes of utcDate

	-- Calculate progression through the day (0-99)
	set totalMinutes to (hourNum * 60) + minuteNum
	set dayProgression to (totalMinutes * 100) div (24 * 60)

	-- Format as YYYYMMDDPP (e.g., 2024013025)
	set yearStr to yearNum as string
	set monthStr to text -2 thru -1 of ("0" & (monthNum as string))
	set dayStr to text -2 thru -1 of ("0" & (dayNum as string))
	set progressStr to text -2 thru -1 of ("0" & (dayProgression as string))

	return yearStr & monthStr & dayStr & progressStr
end getDateSerial

tell application "System Events"
	set dateSerial to my getDateSerial()
	repeat with i from 1 to length of dateSerial
		set idChar to character i of dateSerial
		keystroke idChar
		delay 5.0E-4
	end repeat
end tell
