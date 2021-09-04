-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script

-- TELEMETRY
-- Place this file in the SD Card folder on your computer and TX
-- SD Card /SCRIPTS/TELEMETRY/LapTmr.lua
-- Place the accompanying sound files in /SCRIPTS/SOUNDS/LapTmr/
-- Further instructions http://rcdiy.ca/telemetry-scripts-getting-started/

-- Works On OpenTX Version: 2.3.x
-- Works With Sensor: none

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks: L Shems

-- Date: 2017 January 7
-- Update: 2018 January 1
--      Changed globals to local, formatted string placed in table, support for different LCD sizes,
--      will run as a widget with a widget loader (Horus transmitters).
-- Update: 2021 September 4
--      Compatibility with OpenTX 2.3 on Radiomaster TX16S

-- Description

-- Displays time elapsed in minutes, seconds and milliseconds.
-- Timer activated by a physical or logical switch.
-- Lap recorded by a second physical or logical switch.
-- Reset to zero by Timer switch being set to off and Lap switch set on.
-- Default Timer switch is "ls1" (logical switch one).
-- OpenTX "ls1" set to a>x, THR, -100
-- Default Lap switch is "sh", a momentary switch.

-- Change as desired
-- sa to sh, ls1 to ls32
-- If you want the timer to start and stop when the throttle is up and down
-- create a logical switch that changes state based on throttle position.
local TimerSwitch = "ls1"
-- Position U (up/away from you), D (down/towards), M (middle)
-- When using logical switches use "U" for true, "D" for false
local TimerSwitchOnPosition = "U"
local LapSwitch = "sh"
local LapSwitchRecordPosition = "U"

-- Audio
local SpeakLapTime = true

local SpeakLapNumber = true
local SpeakLapTimeHours = 0 -- 1 hours, minutes, seconds else minutes, seconds

local BeepOnLap = true
local BeepFrequency = 200 -- Hz
local BeepLengthMilliseconds = 200

-- File Paths
-- location you placed the accompanying sound files
local SoundFilesPath = "/SCRIPTS/SOUNDS/LapTmr/"



-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Time Tracking
local StartTimeMilliseconds = -1
local ElapsedTimeMilliseconds = 0
local PreviousElapsedTimeMilliseconds = 0
local LapTime = 0
local LapTimeList = {ElapsedTimeMilliseconds}
local LapTimeRecorded = false

-- Display
local Margin = 10
local Spacing = 20
local TextHeader = "LapTimer"
local TextSize = 0
local TextHeight = 12 
local Debugging = false

local function getTimeMilliseconds()
  -- Returns the number of milliseconds elapsed since the Tx was turned on
  -- Increments in 10 millisecond intervals
  -- getTime()
  -- Return the time since the radio was started in multiples of 10ms
  -- Number of 10ms ticks since the radio was started Example: run time: 12.54 seconds, return value: 1254
  local now = getTime() * 10
  return now
end

local function getMinutesSecondsHundrethsAsString(milliseconds)
  -- Returns MM:SS.hh as a string
  -- milliseconds = milliseconds or 0
  local seconds = milliseconds/1000
  local minutes = math.floor(seconds/60) -- seconds/60 gives minutes
  seconds = seconds % 60 -- seconds % 60 gives seconds
  return (string.format("%02d:%05.2f", minutes, seconds))
end

local function getSwitchPosition(switchID)
  -- Returns switch position as one of U, D, M
  -- Passed a switch identifier sa to sf, ls1 to ls32
  local switchValue = getValue(switchID)
  if Debugging == true then
    print(switchValue)
  end
  -- typical Tx switch middle value is
  if switchValue < -100 then
    return "D"
  elseif switchValue < 100 then
    return "M"
  else
    return "U"
  end
end

local function myTableInsert(t, v)
  -- Adds values to the end of the passed table
end

local function init_func()
  -- Called once when model is loaded or telemetry reset
  StartTimeMilliseconds = -1
  ElapsedTimeMilliseconds = 0
  -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
  if LCD_W > 128 then
    TextSize = MIDSIZE
  else
    TextSize = 0
  end
end

local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the TX
  --print(#LapTimeList)
  -- Start recording time
  if getSwitchPosition(TimerSwitch) == TimerSwitchOnPosition then
    -- Start reference time
    if StartTimeMilliseconds == -1 then
      StartTimeMilliseconds = getTimeMilliseconds()
    end

    -- Time difference
    ElapsedTimeMilliseconds = getTimeMilliseconds() - StartTimeMilliseconds
    -- TimerSwitch and LapSwitch On so record the lap time
    if getSwitchPosition(LapSwitch) == LapSwitchRecordPosition then
      if LapTimeRecorded == false then
        LapTime = ElapsedTimeMilliseconds - PreviousElapsedTimeMilliseconds
        PreviousElapsedTimeMilliseconds = ElapsedTimeMilliseconds
        LapTimeList[#LapTimeList+1] = getMinutesSecondsHundrethsAsString(LapTime)
        LapTimeRecorded = true
        playTone(BeepFrequency, BeepLengthMilliseconds, 0)
        if (#LapTimeList-1) <= 16 then
          local filePathName = SoundFilesPath..tostring(#LapTimeList-1)..".wav"
          playFile(filePathName)
        end
        -- playNumber(#LapTimeList-1,0)
        --if (#LapTimeList-1) == 1 then
          --playFile(SoundFilesPath.."laps.wav")
        ---else
          --playFile(SoundFilesPath.."lap.wav")
        --end
        local LapTimeInt = math.floor((LapTime/1000)+0.5)
        playDuration(LapTimeInt, SpeakLapTimeHours)
      end
    else
      LapTimeRecorded = false
    end
  else
    -- TimerSwitch Off and LapSwitch On so reset time
    if getSwitchPosition(LapSwitch) == LapSwitchRecordPosition then
      StartTimeMilliseconds = -1
      ElapsedTimeMilliseconds = 0
      PreviousElapsedTimeMilliseconds = 0
      LapTime = 0
      LapTimeList = {0}
    end
  end
end

local function run_func(event)
  -- Called periodically when screen is visible
  bg_func() -- a good way to reduce repitition

  -- LCD / Display code
  lcd.clear()

  -- lcd.drawText(x, y, text [, flags])
  -- Displays text
  -- text is the text to display
  -- flags are optional
  -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
  lcd.drawText(0, 0, TextHeader, TextSize + INVERS)

  -- lcd.drawText(lcd.getLastRightPos(), 15, "s", SMLSIZE)
  lcd.drawText(LCD_W/4, 0, getMinutesSecondsHundrethsAsString(ElapsedTimeMilliseconds), TextSize)
  lcd.drawText(LCD_W/2, 0, "Lap", TextSize + INVERS)
  lcd.drawText(LCD_W/2 + 4*12, 0, #LapTimeList-1, TextSize)
  local rowHeight = math.floor(TextHeight + 12)
  local rows = math.floor(LCD_H/rowHeight)
  local rowsMod = rows*rowHeight
  local x = 0
  local y = rowHeight
  local c = 1
  lcd.drawText(x, y, " ")
  -- i = 2 first entry is always 0:00.00 so skipping it
  for i = #LapTimeList, 2, -1 do
    if y % (rowsMod or 60) == 0 then
      c = c + 1 -- next column
      x = (LCD_W/4)*(c-1)
      y = rowHeight
    end
    if (c > 1) and x > LCD_W - x/(c-1) then
    else
      lcd.drawText(x, y, LapTimeList[i], TextSize)
    end
    y = y + rowHeight
  end
  return 0
end

return { run=run_func, background=bg_func, init=init_func  }
