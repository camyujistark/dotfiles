local log = require 'log'

local chain = nil
local runOnApplications = nil
local canManageWindow = nil
local currentLayout = false
local sideBar = false
local isWindowsVertical = true
local isItermSplit = false
local isChromeSplit = false

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
bundleIDs.zoom = 'us.zoom.xos'
bundleIDs.finder = 'com.apple.finder'

local itermsAppBundleIDs = {
  bundleIDs.iterm2,
  bundleIDs.finder,
}

local sidebarBundleIDs = {
  bundleIDs.todoist,
}

local otherAppsBundleIDs = {
  bundleIDs.calendar,
  bundleIDs.mail,
  bundleIDs.postman,
  bundleIDs.spotify,
  bundleIDs.slack,
  bundleIDs.anki,
  bundleIDs.whasapp,
  bundleIDs.zoom,
  bundleIDs.calendar,
  bundleIDs.notion,
}

local grid = {
  topHalf = '0,0 12x6',
  topThird = '0,0 12x4',
  topTwoThirds = '0,0 12x8',
  rightHalf = '6,0 6x12',
  rightThird = '8,0 4x12',
  rightTwoThirds = '4,0 8x12',
  bottomHalf = '0,6 12x6',
  bottomThird = '0,8 12x4',
  bottomTwoThirds = '0,4 12x8',
  leftHalf = '0,0 6x12',
  leftThird = '0,0 4x12',
  leftTwoThirds = '0,0 8x12',
  topLeft = '0,0 6x6',
  topRight = '6,0 6x6',
  bottomRight = '6,6 6x6',
  bottomLeft = '0,6 6x6',
  fullScreen = '0,0 12x12',
  centeredBig = '3,3 6x6',
}

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

canManageWindow = (function(window)
  local application = window:application()
  local bundleID = application:bundleID()

  -- Special handling for iTerm: windows without title bars are
  -- non-standard.
  return window:isStandard() or
    bundleID == 'com.googlecode.iterm2'
end)

chrome_switch_to = (function(ppl)
  -- TODO: Need to make this launch application if does not exist
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
      chrome:activate()
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

setGridOnApplications = (function(bundleIds, gridCoord)
    runOnApplications(bundleIds, function(window) hs.grid.set(window, gridCoord, hs.screen.primaryScreen()) end)
end)


-- Toggle Sidebar

local turnOnSideBar = (function()
  if sideBar then
    sideBar = false
  else
    sideBar = true
  end
end)

local maybeIsSideBar = (function(a, b)
  if sideBar then
    return a 
  else
    return b
  end
end)

-- Toggle Vertial Mode

local turnOnVerticalMode = (function()
  if isWindowsVertical then
    isWindowsVertical = false
  else
    isWindowsVertical = true
  end
end)

local maybeIsVertical = (function(a, b)
  if isWindowsVertical then
    return a 
  else
    return b
  end
end)

-- Toggle Iterm Split
--
local turnOnIsItermSplit = (function()
  if isItermSplit then
    isItermSplit = false
  else
    isItermSplit = true
  end
end)

local maybeIsItermSplitGridCoord = (function(a, b)
  if isItermSplit then
    return a 
  else
    return b
  end
end)

-- Toggle Chrome Split

local turnOnIsChromeSplit = (function()
  if isChromeSplit then
    isChromeSplit = false
  else
    isChromeSplit = true
  end
end)

local maybeIsChromeSplit = (function(a, b)
  if isChromeSplit then
    return a 
  else
    return b
  end
end)

-- Grid Layouts

local gridLayout = {
  one = (function()
    return maybeIsSideBar({
      chromeHome = maybeIsChromeSplit('0,0 4x12', '0,0 9x12'),
      chromeAlien = maybeIsChromeSplit('4,0 5x12', '0,0 9x12'),
      itermApps = maybeIsItermSplitGridCoord('4,0 5x12', '0,0 9x12'),
      otherApps = maybeIsItermSplitGridCoord('4,0 5x12', '0,0 9x12'),
      sideBar = '9,0 3x12',
    },
    {
      chromeHome = maybeIsChromeSplit('0,0 6x12', '0,0 12x12'),
      chromeAlien = maybeIsChromeSplit('6,0 6x12', '0,0 12x12'),
      itermApps = maybeIsItermSplitGridCoord('6,0 6x12', '0,0 12x12'),
      otherApps = maybeIsItermSplitGridCoord('0,0 6x12', '0,0 12x12'),
      sideBar = maybeIsItermSplitGridCoord('0,0 6x12', '0,0 12x12'),
    })
  end),
  two = (function()
    return maybeIsSideBar(
      maybeIsVertical({
        -- would like to have a chain function for switching the chrome split to
        -- horizontal
        chromeHome = maybeIsChromeSplit('0,0 4x6', '0,0 4x12'),
        chromeAlien = maybeIsChromeSplit('0,6 4x6', '0,0 4x12'),
        itermApps = maybeIsItermSplitGridCoord('4,0 5x6', '4,0 5x12'),
        otherApps = maybeIsItermSplitGridCoord('4,6 5x6', '4,0 5x12'),
        sideBar = '9,0 3x12',
      },
      {
        chromeHome = maybeIsChromeSplit('0,0 4x6', '0,0 9x6'),
        chromeAlien = maybeIsChromeSplit('4,0 5x6', '0,0 9x6'),
        itermApps = maybeIsItermSplitGridCoord('4,6 5x6', '0,6 9x6'),
        otherApps = maybeIsItermSplitGridCoord('0,6 4x6', '0,6 9x6'),
        sideBar = '9,0 3x12',
      }),
      maybeIsVertical({
        chromeHome = maybeIsChromeSplit('0,0 3x12', '0,0 6x12'),
        chromeAlien = maybeIsChromeSplit('3,0 3x12', '0,0 6x12'),
        itermApps = maybeIsItermSplitGridCoord('6,0 6x6', '6,0 6x12'),
        otherApps = maybeIsItermSplitGridCoord('6,6 6x6', '0,0 6x12'),
        sideBar = maybeIsItermSplitGridCoord('6,0 6x6', '6,0 6x12'),
      },
      {
        chromeHome = maybeIsChromeSplit('0,0 6x6', '0,0 12x6'),
        chromeAlien = maybeIsChromeSplit('6,0 6x6', '0,0 12x6'),
        itermApps = maybeIsItermSplitGridCoord('6,6 6x6', '0,6 12x6'),
        otherApps = maybeIsItermSplitGridCoord('0,6 6x6', '0,0 12x6'),
        sideBar = maybeIsItermSplitGridCoord('6,6 6x6', '0,6 12x6'),
      })
    )
  end),
  three = (function()
    return maybeIsSideBar(
      maybeIsVertical({
        chromeHome = maybeIsChromeSplit('0,0 3x12', '0,0 6x12'),
        chromeAlien = maybeIsChromeSplit('3,0 3x12', '0,0 6x12'),
        itermApps = maybeIsItermSplitGridCoord('6,0 3x6', '6,0 3x12'),
        otherApps = maybeIsItermSplitGridCoord('6,6 3x6', '0,0 6x12'),
        sideBar = '8,0 4x12',
      },
      {
        chromeHome = maybeIsChromeSplit('0,0 4x8', '0,0 9x8'),
        chromeAlien = maybeIsChromeSplit('4,0 5x8', '0,0 9x8'),
        itermApps = maybeIsItermSplitGridCoord('4,8 5x4', '0,8 9x4'),
        otherApps = maybeIsItermSplitGridCoord('0,8 4x4', maybeIsChromeSplit('0,0 4x8', '0,0 9x8')),
        sideBar = '8,0 4x12',
      }),
      maybeIsVertical({
        chromeHome = maybeIsChromeSplit('0,0 4x12', '0,0 8x12'),
        chromeAlien = maybeIsChromeSplit('4,0 4x12', '0,0 8x12'),
        itermApps = maybeIsItermSplitGridCoord('8,0 4x6', '8,0 4x12'),
        otherApps = maybeIsItermSplitGridCoord('8,6 4x6', maybeIsChromeSplit('4,0 4x12','0,0 8x12')),
        sideBar = '8,0 4x12',
      },
      {
        chromeHome = maybeIsChromeSplit('0,0 6x8', '0,0 12x8'),
        chromeAlien = maybeIsChromeSplit('6,0 6x8', '0,0 12x8'),
        itermApps = maybeIsItermSplitGridCoord('6,8 6x4', '0,8 12x4'),
        otherApps = maybeIsItermSplitGridCoord('0,8 6x4', maybeIsChromeSplit('6,0 6x8', '0,0 12x8')),
        sideBar = '8,0 4x12',
      })
    )
  end),
  zoom = (function()
    return {
        chromeHome = '0,0 8x12',
        chromeAlien = '0,0 8x12',
        itermApps = '0,0 8x12',
        otherApps = '0,0 8x12',
        sideBar = '0,0 8x12',
        targetApps = {
          bundleIDs = { bundleIDs.zoom },
          grid = '8,0 4x12',
        }
      }
  end)
}

local setGridLayoutInit = (function(layout)
  -- cache layout ontno currentLayout
  if layout then
    gridSettings = gridLayout[layout]()
    currentLayout = layout
  elseif currentLayout then
    gridSettings = gridLayout[currentLayout]()
  else
    return
  end
  -- get chrome profiles
  chrome_switch_to(chromeProfiles.home)
  local windowChromeProfileHome = hs.window.frontmostWindow()
  chrome_switch_to(chromeProfiles.alien)
  local windowChromeProfileAlien = hs.window.frontmostWindow()
  -- init grid

  hs.grid.set(windowChromeProfileHome, gridSettings.chromeHome, hs.screen.primaryScreen()) 
  hs.grid.set(windowChromeProfileAlien, gridSettings.chromeAlien, hs.screen.primaryScreen()) 
  setGridOnApplications(itermsAppBundleIDs, gridSettings.itermApps)
  setGridOnApplications(otherAppsBundleIDs, gridSettings.otherApps)
  setGridOnApplications(sidebarBundleIDs, gridSettings.sideBar)

  if gridSettings.targetApps then
    setGridOnApplications(gridSettings.targetApps.bundleIDs, gridSettings.targetApps.grid)
  end
end)

--
-- Key bindings.
--

-- Mash to be matched to holding down enter
local mash = {'ctrl', 'alt', 'shift','cmd'}


return {
  init = (function()

    hs.hotkey.bind(mash, "'", function() hs.application.launchOrFocus('Calendar') end)
    hs.hotkey.bind(mash, ",", function() hs.application.launchOrFocus('Mail') end)
    hs.hotkey.bind(mash, ".", function() hs.application.launchOrFocus('Numi') end)
    hs.hotkey.bind(mash, "a", function()
      hs.application.launchOrFocus('Google Chrome')
      chrome_switch_to(chromeProfiles.home)
    end)
    hs.hotkey.bind(mash, "o", function()
      chrome_switch_to(chromeProfiles.alien)
    end)
    hs.hotkey.bind(mash, "e", function() hs.application.launchOrFocus('Notion') end)
    hs.hotkey.bind(mash, 'u', function() hs.application.launchOrFocus('iTerm') end)
    hs.hotkey.bind(mash, 'i', function() hs.application.launchOrFocus('Todoist') end)
    hs.hotkey.bind(mash, 'd', function() hs.application.launchOrFocus('Harvest') end)

    -- anki?
    hs.hotkey.bind(mash, ';', function() hs.application.launchOrFocus('Finder') end)
    hs.hotkey.bind(mash, 'q', function() hs.application.launchOrFocus('Slack') end)
    hs.hotkey.bind(mash, 'j', function() hs.application.launchOrFocus('Spotify') end)
    hs.hotkey.bind(mash, 'k', function() hs.application.launchOrFocus('WhatsApp') end)
    hs.hotkey.bind(mash, 'm', function() hs.application.launchOrFocus('Marked 2') end)

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

    hs.hotkey.bind(mash, ']', function() 
      if currentLayout ~= 'zoom' then
        turnOnSideBar() 
        setGridLayoutInit()
      end
    end)

    hs.hotkey.bind(mash, '[', function() 
      if currentLayout ~= 'zoom' then
        turnOnVerticalMode() 
        setGridLayoutInit()
      end
    end)

    hs.hotkey.bind(mash, '0', function() 
      if currentLayout ~= 'zoom' then
        turnOnIsItermSplit() 
        setGridLayoutInit()
      end
    end)

    hs.hotkey.bind(mash, '9', function() 
      if currentLayout ~= 'zoom' then
        turnOnIsChromeSplit() 
        setGridLayoutInit()
      end
    end)

    hs.hotkey.bind(mash, '1', (function() setGridLayoutInit('one') end))
    hs.hotkey.bind(mash, '2', (function() setGridLayoutInit('two') end))
    hs.hotkey.bind(mash, '3', (function() setGridLayoutInit('three') end))
    hs.hotkey.bind(mash, '4', (function() setGridLayoutInit('zoom') end))
  end)
}
