hs.grid.setGrid('12x12') -- allows us to place on quarters, thirds and halves
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.window.animationDuration = 0 -- disable animations

local events = require 'events'
-- local iterm = require 'iterm'
local karabiner = require 'karabiner'
local log = require 'log'
local reloader = require 'reloader'
local bindings = require 'bindings'

-- Forward function declarations.
local activate = nil
local activateLayout = nil
local runOnApplications = nil
local canManageWindow = nil
local handleScreenEvent = nil
local hide = nil
local initEventHandling = nil
local internalDisplay = nil
local prepareScreencast = nil
local tearDownEventHandling = nil
local windowCount = nil
local currentLayout = false
local sideBar = false
local isWindowsVertical = true
local isItermSplit = false
local isChromeSplit = false

local screenCount = #hs.screen.allScreens()

--
-- Utility and helper functions.
--

-- Returns the number of standard, non-minimized windows in the application.
--
-- (For Chrome, which has two windows per visible window on screen, but only one
-- window per minimized window).
windowCount = (function(app)
  local count = 0
  if app then
    for _, window in pairs(app:allWindows()) do
      if window:isStandard() and not window:isMinimized() then
        count = count + 1
      end
    end
  end
  return count
end)

hide = (function(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:hide()
  end
end)

activate = (function(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:activate()
  end
end)

canManageWindow = (function(window)
  local application = window:application()
  local bundleID = application:bundleID()

  -- Special handling for iTerm: windows without title bars are
  -- non-standard.
  return window:isStandard() or
    bundleID == 'com.googlecode.iterm2'
end)

local macBookAir13 = '1440x900'
local macBookPro15_2015 = '1440x900'
local macBookPro15_2019 = '1680x1050'
local samsung_S24C450 = '1920x1200'
local currentCount = nil

internalDisplay = (function()
  return hs.screen.find(macBookPro15_2019)
end)

activateLayout = (function(forceScreenCount)
  layoutConfig._before_()
  events.emit('layout', forceScreenCount)

  for bundleID, callback in pairs(layoutConfig) do
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        if canManageWindow(window) then
          callback(window, forceScreenCount)
        end
      end
    end
  end

  currentCount = forceScreenCount
  layoutConfig._after_()
end)

--
-- Event-handling
--

handleScreenEvent = (function()
  -- Make sure that something noteworthy (display count) actually
  -- changed. We no longer check geometry because we were seeing spurious
  -- events.
  local screens = hs.screen.allScreens()
  if not (#screens == screenCount) then
    screenCount = #screens
    activateLayout(screenCount)
  end
end)

initEventHandling = (function()
  screenWatcher = hs.screen.watcher.new(handleScreenEvent)
  screenWatcher:start()
end)

tearDownEventHandling = (function()
  screenWatcher:stop()
  screenWatcher = nil
end)

switch_app = (function(app)
  hs.application.launchOrFocus(app)
end)

-- iterm.init()
karabiner.init()
reloader.init()
bindings.init()
initEventHandling()
events.subscribe('reload', tearDownEventHandling)

log.i('Config loaded')
