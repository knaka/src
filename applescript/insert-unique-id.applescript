tell application "System Events"
	set idStr to do shell script "/usr/bin/uuidgen | /usr/bin/perl -pe 'tr/[A-Z]/[a-z]/; s/-//g; s/^(.......).*\\R/\\1/'"
	repeat with i from 1 to length of idStr
		set idChar to character i of idStr
		keystroke idChar
		delay 5.0E-4
	end repeat
end tell
