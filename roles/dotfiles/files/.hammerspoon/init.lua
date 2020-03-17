hs.grid.setGrid('12x12') -- allows us to place on quarters, thirds and halves
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.window.animationDuration = 0 -- disable animations

local events = require 'events'
-- local iterm = require 'iterm'
local karabiner = require 'karabiner'
local log = require 'log'
local reloader = require 'reloader'

-- Forward function declarations.
local activate = nil
local activateLayout = nil
local canManageWindow = nil
local chain = nil
local handleScreenEvent = nil
local handleWindowEvent = nil
local hide = nil
local initEventHandling = nil
local internalDisplay = nil
local prepareScreencast = nil
local tearDownEventHandling = nil
local windowCount = nil
local sideBar = false
local mediaPopUp = false

local screenCount = #hs.screen.allScreens()

local grid = {
  topHalf = '0,0 12x6',
  topThird = '0,0 12x4',
  topTwoThirds = '0,0 12x8',
  rightHalf = '6,0 6x12',
  rightThird = '8,0 4x12',
  rightFiveTwelveQuarterOffset = '4,0 5x12',
  rightToolBar = '9,0 3x12',
  rightTwoThirds = '4,0 8x12',
  bottomHalf = '0,6 12x6',
  bottomThird = '0,8 12x4',
  bottomTwoThirds = '0,4 12x8',
  leftHalf = '0,0 6x12',
  leftThird = '0,0 4x12',
  leftNoToolBar = '0,0 9x12',
  leftTwoThirds = '0,0 8x12',
  topLeft = '0,0 6x6',
  topRight = '6,0 6x6',
  bottomRight = '6,6 6x6',
  bottomLeft = '0,6 6x6',
  fullScreen = '0,0 12x12',
  centeredBig = '3,3 6x6',
  centerThird = '4,0 4x12',
  centerTdird = '4,4 4x4',
}

local bringToFront = (function(bundleID)
  if bundleID then
    hs.application.launchOrFocus(bundleID)
  end
end)

local layoutConfig = {
  _before_ = (function()
    -- hide('com.spotify.client')
  end),

  _after_ = (function()
  end),

  ['com.apple.iCal'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if sideBar then
        hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    elseif count == 1 then
      hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
    elseif count == 2 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 3 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    end
  end),

  ['com.apple.mail'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      if sideBar then
        hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
      end
    elseif count == 3 then
      hs.grid.set(window, grid.leftTwoThirds, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomLeft, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    end
  end),

  ['net.ankiweb.dtop']  = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    end
  end),

  ['com.tinyspeck.slackmacgap'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 3 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    end
  end),

  ['com.todoist.mac.Todoist'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if sideBar then
        hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    elseif count == 1 then
      hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
    elseif count == 2 then
      hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
    elseif count == 3 then
      hs.grid.set(window, grid.rightThird, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    end
  end),

  ['com.spotify.client'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 3 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    end
  end),

  ['WhatsApp'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 3 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    end
  end),

  ['com.postmanlabs.mac'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 3 then
      hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomLeft, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    end
  end),

  ['com.figma.Desktop'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      if sideBar then
        hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
      end
    elseif count == 3 then
      hs.grid.set(window, grid.centerThird, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.bottomLeft, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    end
  end),

  ['notion.id'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      if sideBar then
        hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
      end
    elseif count == 3 then
      hs.grid.set(window, grid.rightThird, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
    end
  end),

  ['com.google.Chrome'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      if sideBar then
        hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
      end
    elseif count == 3 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.topLeft, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
    end
  end),

  ['com.googlecode.iterm2'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      if sideBar then
        hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
      end
    elseif count == 2 then
      if sideBar then
        hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
      else
        hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
      end
    elseif count == 3 then
      hs.grid.set(window, grid.rightThird, hs.screen.primaryScreen())
    elseif count == 4 then
      hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
    elseif count == 5 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 6 then
      hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
    elseif count == 7 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 8 then
      hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen())
    end
  end),
}

-- fullmode
-- iterm2
-- switch

-- here --
prepareScreencast = (function()
  local screen = 'Color LCD'
  local top = {x=0, y=0, w=1, h=.92}
  local bottom = {x=.4, y=.82, w=.5, h=.1}
  local windowLayout = {
    {'iTerm2', nil, screen, top, nil, nil},
    {'Google Chrome', nil, screen, top, nil, nil},
    {'KeyCastr', nil, screen, bottom, nil, nil},
  }

  hs.application.launchOrFocus('KeyCastr')
  local chrome = hs.appfinder.appFromName('Google Chrome')
  local iterm = hs.appfinder.appFromName('iTerm2')
  for key, app in pairs(hs.application.runningApplications()) do
    if app == chrome or app == iterm or app:name() == 'KeyCastr' then
      app:unhide()
    else
      app:hide()
    end
  end
  hs.layout.apply(windowLayout)
end)

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

local turnOnSideBar = (function()
  if sideBar then
    sideBar = false
  else
    sideBar = true
  end
end)

--
-- Event-handling
--

handleWindowEvent = (function(window)
  if canManageWindow(window) then
    local application = window:application()
    local bundleID = application:bundleID()
    if layoutConfig[bundleID] then
      layoutConfig[bundleID](window)
    end
  end
end)

local windowFilter=hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowCreated, handleWindowEvent)

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

local lastSeenChain = nil
local lastSeenWindow = nil

-- Chain the specified movement commands.
--
-- This is like the "chain" feature in Slate, but with a couple of enhancements:
--
--  - Chains always start on the screen the window is currently on.
--  - A chain will be reset after 2 seconds of inactivity, or on switching from
--    one chain to another, or on switching from one app to another, or from one
--    window to another.
--
chain = (function(movements)
  local chainResetInterval = 2 -- seconds
  local cycleLength = #movements
  local sequenceNumber = 1

  return function()
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local now = hs.timer.secondsSinceEpoch()
    local screen = win:screen()

    if
      lastSeenChain ~= movements or
      lastSeenAt < now - chainResetInterval or
      lastSeenWindow ~= id
    then
      sequenceNumber = 1
      lastSeenChain = movements
    elseif (sequenceNumber == 1) then
      -- At end of chain, restart chain on next screen.
      screen = screen:next()
    end
    lastSeenAt = now
    lastSeenWindow = id

    hs.grid.set(win, movements[sequenceNumber], screen)
    sequenceNumber = sequenceNumber % cycleLength + 1
  end
end)

switch_app = (function(app)
  hs.application.launchOrFocus(app)
end)


function chrome_switch_to(ppl)
  return function()
      hs.application.launchOrFocus("Google Chrome")
      local chrome = hs.appfinder.appFromName("Google Chrome")
      local str_menu_item
      if ppl == "Incognito" then
          str_menu_item = {"File", "New Incognito Window"}
      else
          str_menu_item = {"People", ppl}
      end

      local menu_item = chrome:findMenuItem(str_menu_item)
      if (menu_item) then
          chrome:selectMenuItem(str_menu_item)
      end

      -- local windows = chrome:visibleWindows()
      -- for _, window in pairs(windows) do
      --   if canManageWindow(window) then
      --     if ppl == 'Cam' then
      --       hs.grid.set(window, grid.leftThird, hs.screen.primaryScreen())
      --     elseif ppl == 'Alien' then
      --       hs.grid.set(window, grid.centerThird, hs.screen.primaryScreen())
      --     end
      --   end
      -- end
      -- local app = hs.application.get('com.google.Chrome')
      -- app:selectMenuItem({ 'Window', 'Bring All to Front' })
    end
end

chromeAlien = (function()
  -- get alien chrome --
  local chrome = hs.appfinder.appFromName('Google Chrome')
  if not chrome then
    return
  end
  local str_menu_item = {"People", "Cam (Alien)"}
  local menu_item = chrome:findMenuItem(str_menu_item, true)
  if (menu_item) then
      chrome:selectMenuItem(str_menu_item, true)
  end
end)

switchTo = (function(movements, func)
  local cycleLength = #movements
  local sequenceNumber = 1

  return function()
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local now = hs.timer.secondsSinceEpoch()
    local screen = win:screen()

    if
      lastSeenChain ~= movements
    then
      sequenceNumber = 1
      lastSeenChain = movements
    elseif (sequenceNumber == 1) then
      -- At end of chain, restart chain on next screen.
      screen = screen:next()
    end
    lastSeenAt = now
    lastSeenWindow = id

    func(movements[sequenceNumber])

    sequenceNumber = sequenceNumber % cycleLength + 1
  end
end)
--
-- Key bindings.
--

-- Mash to be matched to holding down enter
local mash = {'ctrl', 'alt', 'shift','cmd'}

-- hs.hotkey.bind(mash, 'y', function() hs.application.launchOrFocus('Sequel Pro') end)
-- hs.hotkey.bind(mash, 'f', function() hs.application.launchOrFocus('Firefox') end)

--- Toggle Chrome and Terminal
-- hs.hotkey.bind(mash, 'a', function()
--   local window = hs.window.frontmostWindow()
--   local application = window:application()
--   local bundleID = application:bundleID()
--
--   -- launch or focus
--   if bundleID == 'com.google.Chrome' then
--     -- iterm --
--     hs.application.launchOrFocus('iTerm')
--   else
--     chromeAlien()
--   end
-- end)

-- Remove Bolster and make it two chrome instances
hs.hotkey.bind(mash, "'", function() hs.application.launchOrFocus('Postman') end)
hs.hotkey.bind(mash, ",", function() hs.application.launchOrFocus('Figma') end)
hs.hotkey.bind(mash, ".", function() hs.application.launchOrFocus('Numi') end)

hs.hotkey.bind(mash, "a", chrome_switch_to('Cam'))
hs.hotkey.bind(mash, "o", chrome_switch_to('Cam (Alien)'))
hs.hotkey.bind(mash, 'e', function() 
    -- want to make sure that todoist comes forward too
    hs.application.launchOrFocus('Todoist')
    hs.application.launchOrFocus('iTerm')
end)
hs.hotkey.bind(mash, "u", function() hs.application.launchOrFocus('Notion') end)
hs.hotkey.bind(mash, 'i', function() hs.application.launchOrFocus('Todoist') end)
hs.hotkey.bind(mash, 'd', function() hs.application.launchOrFocus('Harvest') end)
-- hs.hotkey.bind(mash, 'd', function() hs.application.launchOrFocus('Day One') end)

hs.hotkey.bind(mash, ';', function() hs.application.launchOrFocus('Anki') end)
hs.hotkey.bind(mash, 'q', function() hs.application.launchOrFocus('Slack') end)
hs.hotkey.bind(mash, 'j', function() hs.application.launchOrFocus('Spotify') end)
hs.hotkey.bind(mash, 'k', function() hs.application.launchOrFocus('WhatsApp') end)
hs.hotkey.bind(mash, 'x', function() hs.application.launchOrFocus('Calendar') end) 

hs.hotkey.bind(mash, 'm', function() hs.application.launchOrFocus('Marked 2') end)
hs.hotkey.bind(mash, ']', function() turnOnSideBar() end)

hs.hotkey.bind({'ctrl', 'alt'}, 'up', chain({
  grid.topHalf,
  grid.topThird,
  grid.topTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt'}, 'right', chain({
  grid.rightHalf,
  grid.rightThird,
  grid.rightTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt'}, 'down', chain({
  grid.bottomHalf,
  grid.bottomThird,
  grid.bottomTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt'}, 'left', chain({
  grid.leftHalf,
  grid.leftThird,
  grid.leftTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'up', chain({
  grid.topLeft,
  grid.topRight,
  grid.bottomRight,
  grid.bottomLeft,
}))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'down', chain({
  grid.fullScreen,
  grid.centeredBig,
  grid.centeredSmall,
}))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f1', (function()
  hs.alert('One-monitor layout')
  activateLayout(1)
end))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f2', (function()
  hs.alert('Two-monitor layout')
  activateLayout(2)
end))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f3', (function()
  hs.console.alpha(.75)
  hs.toggleConsole()
end))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f4', (function()
  hs.notify.show(
    'Hammerspoon',
    'Reloaded in the background',
    'Press ⌃⌥⌘F3 to reveal the console.'
  )
  reloader.reload()
end))

hs.hotkey.bind(mash, '1', (function() activateLayout(1) end))
hs.hotkey.bind(mash, '2', (function() activateLayout(2) end))
hs.hotkey.bind(mash, '3', (function() activateLayout(3) end))
hs.hotkey.bind(mash, '4', (function() activateLayout(4) end))

hs.hotkey.bind(mash, '5', switchTo({ 5, 6 }, activateLayout))
hs.hotkey.bind(mash, '6', switchTo({ 7, 8 }, activateLayout))

-- iterm.init()
karabiner.init()
reloader.init()
initEventHandling()
events.subscribe('reload', tearDownEventHandling)

log.i('Config loaded')
