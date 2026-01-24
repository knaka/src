-- Hash value in 7 digits
hs.hotkey.bind({"cmd", "shift"}, "h", function()
  math.randomseed(os.time() * 1000 + math.random(1, 1000))
  local n = math.random(0, 268435455)  -- 0xFFFFFFF
  local hexId = string.format("%07x", n)
  hs.eventtap.keyStrokes(hexId)
end)

-- Date serial (YYYYMMDD + day progress percentage)
hs.hotkey.bind({"cmd", "shift",}, "d", function()
  local now = os.time()
  -- "!*t" returns UTC time as a table. "!" means UTC, "*t" means table format
  -- — Programming in Lua : 22.1 https://www.lua.org/pil/22.1.html
  local utc = os.date("!*t", now)
  local hour = utc.hour
  local minute = utc.min
  local dayProgress = math.floor(((hour * 60 + minute) * 100) / (24 * 60))
  local dateSerial = string.format("%04d%02d%02d%02d", utc.year, utc.month, utc.day, dayProgress)
  hs.eventtap.keyStrokes(dateSerial)
end)
