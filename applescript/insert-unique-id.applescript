-- Converts a decimal number to a hexadecimal string (lowercase).
-- This function performs base-16 conversion by repeatedly dividing the input
-- number by 16 and mapping remainders (0-15) to hex characters ('0'-'9', 'a'-'f').
-- The result is built right-to-left by prepending each hex digit.
-- Parameters:
--   decNum: A non-negative integer to convert
-- Returns:
--   A string representing the hexadecimal value (e.g., 255 -> "ff")
on decimalToHex(decNum)
	set hexChars to "0123456789abcdef"
	set hexStr to ""
	repeat while decNum > 0
		set digitValue to (decNum mod 16)
		set hexStr to (character (digitValue + 1) of hexChars) & hexStr
		set decNum to decNum div 16
	end repeat
	if hexStr is "" then set hexStr to "0"
	return hexStr
end decimalToHex

-- Generates a random hexadecimal ID string of specified length.
-- This function creates a cryptographically weak random number suitable for
-- generating non-security-critical unique identifiers (like temporary IDs or
-- short codes). For 7 hex digits, it generates a random number in the range
-- 0 to 0xFFFFFFF (268,435,455), converts it to hex, and pads with leading
-- zeros if necessary to ensure consistent length.
-- Parameters:
--   length: The desired length of the hex string (e.g., 7 for a 7-digit ID)
-- Returns:
--   A lowercase hexadecimal string of exactly 'length' characters
on generateRandomHexId(length)
	-- Generate random number (28 bits for 7 hex digits: 16^7 = 268435456 = 2^28)
	set maxValue to 268435455 -- 0xFFFFFFF
	set randomNum to random number from 0 to maxValue
	set hexId to my decimalToHex(randomNum)
	-- Pad with leading zeros if necessary
	repeat while (length of hexId) < length
		set hexId to "0" & hexId
	end repeat
	return hexId
end generateRandomHexId

tell application "System Events"
	set idStr to my generateRandomHexId(7)
	repeat with i from 1 to length of idStr
		set idChar to character i of idStr
		-- Sometimes, this starts outputting capitalized characters, which does not stop until the OS is restarted. While this is happening, an external keyboard's caps lock does not affect the main keyboard's caps lock status. Switching the external keyboard off and on sometimes seems to resolve the problem. Restarting Karabiner-Elements also can do. I am not certain.
		keystroke idChar
		-- This does not work. // AppleScript keystroke sometimes capitalizing letters? - Stack Overflow https://stackoverflow.com/questions/41227700/applescript-keystroke-sometimes-capitalizing-letters
		delay 5.0E-4
	end repeat
end tell
