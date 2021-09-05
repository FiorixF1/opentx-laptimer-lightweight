local buildMode = ...
local LapTimer = nil
local options = {
	{ "Restore", BOOL, 0},
	{ "Text", COLOR, BLACK},
	{ "Warning", COLOR, YELLOW}
}
local TELE_PATH = "/SCRIPTS/TELEMETRY/"

-- Build with Companion
local v, r, m, i, e = getVersion()
if string.sub(r, -4) == "simu" and buildMode ~= true then
	loadScript(TELE_PATH .. "LapTmr", "tc")(true)
end

-- Run once at the creation of the widget
local function create(zone, options)
	LapTimerZone = { zone = zone, options = options }
	LapTimer = loadfile(TELE_PATH .. "LapTmr.luac")(false)
	LapTimer.bg_func()
	return LapTimerZone
end

-- This function allow updates when you change widgets settings
local function update(LapTimerZone, options)
	LapTimerZone.options = options
	return
end

-- Called periodically when custom telemetry screen containing widget is visible.
local function refresh(LapTimerZone)
	LapTimer.run_func()
	return
end

-- Called periodically when custom telemetry screen containing widget is not visible
local function background(LapTimerZone)
	LapTimer.bg_func()
	return
end

return { name = "LapTimer", options = options, create = create, update = update, refresh = refresh, background = background }
