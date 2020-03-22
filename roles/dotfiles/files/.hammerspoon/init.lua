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
local runOnApplications = nil
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
local isWindowsVertical = true
local currentLayout = nil

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
  leftQuarter = '0,0 3x12',
  leftSecondQuarter = '3,0 3x12',
  leftThirdQuarter = '6,0 3x12',
  leftNoToolBar = '0,0 9x12',
  leftNoToolBarTop = '0,0 9x6',
  leftNoToolBarBottom = '0,6 9x6',
  leftTwoThirds = '0,0 8x12',
  leftTwoThirdsTop = '0,0 8x6',
  leftTwoThirdsBottom = '0,6 8x6',
  topLeft = '0,0 6x6',
  topRight = '6,0 6x6',
  bottomRight = '6,6 6x6',
  bottomLeft = '0,6 6x6',
  fullScreen = '0,0 12x12',
  centeredBig = '3,3 6x6',
  centerThird = '4,0 4x12',
  centerTdird = '4,4 4x4',
}
-- chrome profiles
local chromeProfiles = {}
chromeProfiles.home = 'Cam'
chromeProfiles.alien = 'Cam (Alien)'

-- programs
local bundleIDs = {}
bundleIDs.iterm2 = 'com.googlecode.iterm2'
bundleIDs.calendar = 'com.apple.iCal'
bundleIDs.mail = 'com.apple.mail'
bundleIDs.postman = 'com.postmanlabs.mac'
bundleIDs.spotify = 'com.spotify.client'
bundleIDs.slack = 'com.tinyspeck.slackmacgap'
bundleIDs.anki = 'net.ankiweb.dtop'
bundleIDs.notion = 'notion.id'
bundleIDs.whasapp = 'WhatsApp'
bundleIDs.todoist = 'com.todoist.mac.Todoist'


local itermBoundBundleIDs = {
  bundleIDs.iterm2,
  bundleIDs.calendar,
  bundleIDs.mail,
  bundleIDs.postman,
  bundleIDs.spotify,
  bundleIDs.slack,
  bundleIDs.anki,
  bundleIDs.notion,
  bundleIDs.whasapp,
}

-- would like to have array merge - but could not find the right way to do this
-- in Lua
local itermBoundBundleIDsWithTodoist = {
  bundleIDs.iterm2,
  bundleIDs.calendar,
  bundleIDs.mail,
  bundleIDs.postman,
  bundleIDs.spotify,
  bundleIDs.slack,
  bundleIDs.anki,
  bundleIDs.notion,
  bundleIDs.whasapp,
  bundleIDs.todoist,
}

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

runOnApplication = (function(bundleID, callback)
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        if canManageWindow(window) then
          callback(window)
        end
      end
  end
end)

runOnApplications = (function(bundleIDs, callback)
  for i, bundleID in pairs(bundleIDs) do
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        if canManageWindow(window) then
          callback(window)
        end
      end
    end
  end
end)

local turnOnSideBar = (function()
  if sideBar then
    sideBar = false
  else
    sideBar = true
  end
end)

local turnOnHorizontalMode = (function()
  if isWindowsVertical then
    isWindowsVertical = false
  else
    isWindowsVertical = true
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

chrome_switch_to = (function(ppl)
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

hs.hotkey.bind(mash, "'", function() hs.application.launchOrFocus('Postman') end)
hs.hotkey.bind(mash, ",", function() hs.application.launchOrFocus('Figma') end)
hs.hotkey.bind(mash, ".", function() hs.application.launchOrFocus('Numi') end)

hs.hotkey.bind(mash, "a", function() chrome_switch_to(chromeProfiles.home) end)
hs.hotkey.bind(mash, "o", function() chrome_switch_to(chromeProfiles.alien) end)
hs.hotkey.bind(mash, 'e', function() hs.application.launchOrFocus('iTerm') end)
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
hs.hotkey.bind(mash, '[', function() turnOnHorizontalMode() end)

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


hs.hotkey.bind(mash, '1', (function() 
  local id = '1'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if sideBar then
    hs.grid.set(windowChromeProfileHome, grid.leftNoToolBar, hs.screen.primaryScreen()) 
    hs.grid.set(windowChromeProfileAlien, grid.leftNoToolBar, hs.screen.primaryScreen()) 
    runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen()) end)
    runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
  else
    hs.grid.set(windowChromeProfileHome, grid.fullScreen, hs.screen.primaryScreen()) 
    hs.grid.set(windowChromeProfileAlien, grid.fullScreen, hs.screen.primaryScreen()) 
    runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen()) end)
  end
end))

hs.hotkey.bind(mash, '2', (function()
  local id = '2'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if isWindowsVertical then
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftThird, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftThird, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.leftHalf, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftHalf, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen()) end)
    end
  else
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftNoToolBarTop, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftNoToolBarTop, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.leftNoToolBarBottom, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.topHalf, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.topHalf, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.bottomHalf, hs.screen.primaryScreen()) end)
    end
  end
  currentLayout = id
end))

hs.hotkey.bind(mash, '3', (function() 
  local id = '3'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if isWindowsVertical then
    hs.grid.set(windowChromeProfileHome, grid.leftThird, hs.screen.primaryScreen()) 
    hs.grid.set(windowChromeProfileAlien, grid.centerThird, hs.screen.primaryScreen()) 
    runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.rightThird, hs.screen.primaryScreen()) end)
  else
    hs.grid.set(windowChromeProfileAlien, grid.leftTwoThirdsTop, hs.screen.primaryScreen()) 
    hs.grid.set(windowChromeProfileHome, grid.leftTwoThirdsBottom, hs.screen.primaryScreen()) 
    runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.rightThird, hs.screen.primaryScreen()) end)
  end
  currentLayout = id
end))

hs.hotkey.bind(mash, '4', (function() 
  local id = '4'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if isWindowsVertical then
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftQuarter, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftSecondQuarter, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.leftThirdQuarter, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.leftQuarter, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftSecondQuarter, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen()) end)
    end
  else
    if sideBar then
      hs.grid.set(windowChromeProfileAlien, grid.topLeft, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileHome, grid.bottomLeft, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.leftThirdQuarter, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.bottomLeft, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.topLeft, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen()) end)
    end
  end
  currentLayout = id
end))

hs.hotkey.bind(mash, '5', (function() 
  local id = '5'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if isWindowsVertical then
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftThird, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.leftHalf, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftHalf, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.topRight, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.iterm2, function(window) hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen()) end)
    end
  else
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftNoToolBarTop, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftNoToolBarBottom, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.leftNoToolBarBottom, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.leftHalf, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftHalf, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.iterm2, function(window) hs.grid.set(window, grid.topRight, hs.screen.primaryScreen()) end)
    end
  end
  currentLayout = id
end))

hs.hotkey.bind(mash, '6', (function() 
  local id = '6'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if isWindowsVertical then
    hs.grid.set(windowChromeProfileHome, grid.leftQuarter, hs.screen.primaryScreen()) 
    hs.grid.set(windowChromeProfileAlien, grid.leftSecondQuarter, hs.screen.primaryScreen()) 
    runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.topRight, hs.screen.primaryScreen()) end)
    runOnApplication(bundleIDs.iterm2, function(window) hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen()) end)
  else
    hs.grid.set(windowChromeProfileHome, grid.leftQuarter, hs.screen.primaryScreen()) 
    hs.grid.set(windowChromeProfileAlien, grid.leftSecondQuarter, hs.screen.primaryScreen()) 
    runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen()) end)
    runOnApplication(bundleIDs.iterm2, function(window) hs.grid.set(window, grid.topRight, hs.screen.primaryScreen()) end)
  end
  currentLayout = id
end))

hs.hotkey.bind(mash, '7', (function() 
  local id = '7'
  if sideBar then
      id = id .. 'A'
  else
      id = id .. 'B'
  end

  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()

  if isWindowsVertical then
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftThird, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.rightFiveTwelveQuarterOffset, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileHome, grid.leftHalf, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.rightHalf, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen()) end)
    end
  else
    if sideBar then
      hs.grid.set(windowChromeProfileHome, grid.leftNoToolBarTop, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileAlien, grid.leftNoToolBarBottom, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDs, function(window) hs.grid.set(window, grid.leftNoToolBarBottom, hs.screen.primaryScreen()) end)
      runOnApplication(bundleIDs.todoist, function(window) hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen()) end)
    else
      hs.grid.set(windowChromeProfileAlien, grid.topHalf, hs.screen.primaryScreen()) 
      hs.grid.set(windowChromeProfileHome, grid.bottomHalf, hs.screen.primaryScreen()) 
      runOnApplications(itermBoundBundleIDsWithTodoist, function(window) hs.grid.set(window, grid.bottomHalf, hs.screen.primaryScreen()) end)
    end
  end
  currentLayout = id
end))

-- iterm.init()
karabiner.init()
reloader.init()
initEventHandling()
events.subscribe('reload', tearDownEventHandling)

log.i('Config loaded')
