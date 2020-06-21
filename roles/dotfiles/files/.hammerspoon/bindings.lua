local log = require 'log'

local chain = nil
local runOnApplications = nil
local canManageWindow = nil
local sideBar = false
local isWindowsVertical = true
local isItermSplit = false
local isChromeSplit = false
local currentLayout = nil
local currentAppLayout = nil

-- chrome profiles
local chromeProfiles = {}
chromeProfiles.home = 'Cam'
chromeProfiles.alien = 'Cam (Alien)'

-- programs
local bundleIDs = {}
bundleIDs.anki = 'net.ankiweb.dtop'
bundleIDs.calendar = 'com.apple.iCal'
bundleIDs.chrome ='com.google.Chrome'
bundleIDs.dayone = 'com.bloombuilt.dayone-mac'
bundleIDs.finder = 'com.apple.finder'
bundleIDs.iterm2 = 'com.googlecode.iterm2'
bundleIDs.mail = 'com.apple.mail'
bundleIDs.notion = 'notion.id'
bundleIDs.postman = 'com.postmanlabs.mac'
bundleIDs.sketchbook = 'com.autodesk.sketchbookpro7mac'
bundleIDs.slack = 'com.tinyspeck.slackmacgap'
bundleIDs.spotify = 'com.spotify.client'
bundleIDs.todoist = 'com.todoist.mac.Todoist'
bundleIDs.whasapp = 'WhatsApp'
bundleIDs.zoom = 'us.zoom.xos'
bundleIDs.unity = 'com.unity3d.UnityEditor5.x'


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

function tablemerge(t1, t2)
  for k,v in ipairs(t2) do
    table.insert(t1, v)
  end 

  return t1
end

local maybeIsSideBar = (function(a, b)
  if sideBar then
    return a 
  else
    return b
  end
end)
local maybeIsVertical = (function(a, b)
  if isWindowsVertical then
    return a
  else
    return b
  end
end)
local maybeIsItermSplitGridCoord = (function(a, b)
  if isItermSplit then
    return a
  else
    return b
  end
end)
local maybeIsChromeSplit = (function(a, b)
  if isChromeSplit then
    return a
  else
    return b
  end
end)

local getChromeProfileWindows = (function()
  -- get chrome profiles
  local chromeProfileWindows = {}
  -- home
  chrome_switch_to(chromeProfiles.home)
  chromeProfileWindows.home = hs.window.frontmostWindow()
  -- alien
  chrome_switch_to(chromeProfiles.alien)
  chromeProfileWindows.alien = hs.window.frontmostWindow()
  return chromeProfileWindows;
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

getBundleWindows = (function(bundleIDs, callback)
  bundleWindows = {}
  for i, bundleID in pairs(bundleIDs) do
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        if canManageWindow(window) then
          table.insert(bundleWindows, window)
        end
      end
    end
  end
  return bundleWindows
end)

runOnApplications = (function(appWindows, groupGrid, showOnTop)
  for _, window in pairs(appWindows) do
      hs.grid.set(window, groupGrid, hs.screen.primaryScreen())
      if showOnTop then
        window:focus()
      end
  end
end)

-- Grid Layouts



--|------|------|------------|-------|
--|      |      |            |       |
--|      |      |     B      |       |
--|      |      |            |       |
--|  A1  |  A2  |------------|   D   |
--|      |      |            |       |
--|      |      |     C      |       |
--|      |      |            |       |
--|------|------|------------|-------|


local gridLayout = {
  one = (function()
    return maybeIsSideBar({
      A1 = maybeIsChromeSplit('0,0 4x12', '0,0 9x12'),
      A2 = maybeIsChromeSplit('4,0 5x12', '0,0 9x12'),
      B = maybeIsItermSplitGridCoord('0,0 4x12', '0,0 9x12'),
      C = maybeIsItermSplitGridCoord('0,0 4x12', '0,0 9x12'),
      D = '9,0 3x12',
    },
    {
      A1 = maybeIsChromeSplit('0,0 6x12', '0,0 12x12'),
      A2 = maybeIsChromeSplit('6,0 6x12', '0,0 12x12'),
      B = maybeIsItermSplitGridCoord('6,0 6x12', '0,0 12x12'),
      C = maybeIsItermSplitGridCoord('0,0 6x12', '0,0 12x12'),
      D = maybeIsItermSplitGridCoord('0,0 6x12', '0,0 12x12'),
    })
  end),
  two = (function()
    return maybeIsSideBar(
      maybeIsVertical({
        A1 = maybeIsChromeSplit('0,0 4x6', '0,0 4x12'),
        A2 = maybeIsChromeSplit('0,6 4x6', '0,0 4x12'),
        B = maybeIsItermSplitGridCoord('4,0 5x6', '4,0 5x12'),
        C = maybeIsItermSplitGridCoord('4,6 5x6', '4,0 5x12'),
        D = '9,0 3x12',
      },
      {
        A1 = maybeIsChromeSplit('0,0 4x6', '0,0 9x6'),
        A2 = maybeIsChromeSplit('4,0 5x6', '0,0 9x6'),
        B = maybeIsItermSplitGridCoord('4,6 5x6', '0,6 9x6'),
        C = maybeIsItermSplitGridCoord('0,6 4x6', '0,6 9x6'),
        D = '9,0 3x12',
      }),
      maybeIsVertical({
        A1 = maybeIsChromeSplit('0,0 3x12', '0,0 6x12'),
        A2 = maybeIsChromeSplit('3,0 3x12', '0,0 6x12'),
        B = maybeIsItermSplitGridCoord('6,0 6x6', '6,0 6x12'),
        C = maybeIsItermSplitGridCoord('6,6 6x6', '0,0 6x12'),
        D = maybeIsItermSplitGridCoord('6,0 6x6', '6,0 6x12'),
      },
      {
        A1 = maybeIsChromeSplit('0,0 6x6', '0,0 12x6'),
        A2 = maybeIsChromeSplit('6,0 6x6', '0,0 12x6'),
        B = maybeIsItermSplitGridCoord('6,6 6x6', '0,6 12x6'),
        C = maybeIsItermSplitGridCoord('0,6 6x6', '0,0 12x6'),
        D = maybeIsItermSplitGridCoord('6,6 6x6', '0,6 12x6'),
      })
    )
  end),
  three = (function()
    return maybeIsSideBar(
      maybeIsVertical({
        A1 = maybeIsChromeSplit('0,0 3x12', '0,0 6x12'),
        A2 = maybeIsChromeSplit('3,0 3x12', '0,0 6x12'),
        B = maybeIsItermSplitGridCoord('6,0 3x6', '6,0 3x12'),
        C = maybeIsItermSplitGridCoord('6,6 3x6', '0,0 6x12'),
        D = '8,0 4x12',
      },
      {
        A1 = maybeIsChromeSplit('0,0 4x8', '0,0 9x8'),
        A2 = maybeIsChromeSplit('4,0 5x8', '0,0 9x8'),
        B = maybeIsItermSplitGridCoord('4,8 5x4', '0,8 9x4'),
        C = maybeIsItermSplitGridCoord('0,8 4x4', maybeIsChromeSplit('0,0 4x8', '0,0 9x8')),
        D = '8,0 4x12',
      }),
      maybeIsVertical({
        A1 = maybeIsChromeSplit('0,0 4x12', '0,0 8x12'),
        A2 = maybeIsChromeSplit('4,0 4x12', '0,0 8x12'),
        B = maybeIsItermSplitGridCoord('8,0 4x6', '8,0 4x12'),
        C = maybeIsItermSplitGridCoord('8,6 4x6', maybeIsChromeSplit('4,0 4x12','0,0 8x12')),
        D = '8,0 4x12',
      },
      {
        A1 = maybeIsChromeSplit('0,0 6x8', '0,0 12x8'),
        A2 = maybeIsChromeSplit('6,0 6x8', '0,0 12x8'),
        B = maybeIsItermSplitGridCoord('6,8 6x4', '0,8 12x4'),
        C = maybeIsItermSplitGridCoord('0,8 6x4', maybeIsChromeSplit('6,0 6x8', '0,0 12x8')),
        D = '8,0 4x12',
      })
    )
  end),
}

local appLayoutFormation = {
  'default',
  'zoom',
  'unity',
}

local setAppGroup = (function(layout)
  local chromeProfileWindow = getChromeProfileWindows()
  local appLayouts = {
    default = {
      A1 = {
        chromeProfileWindow.home
      },
      A2 = {
        chromeProfileWindow.alien
      },
      B = getBundleWindows({
        bundleIDs.iterm2,
        bundleIDs.finder,
        bundleIDs.notion,
      }),
      C = getBundleWindows({
        bundleIDs.calendar,
        bundleIDs.mail,
        bundleIDs.postman,
        bundleIDs.spotify,
        bundleIDs.slack,
        bundleIDs.anki,
        bundleIDs.whasapp,
        bundleIDs.calendar,
        bundleIDs.sketchbook,
        bundleIDs.dayone,
        bundleIDs.zoom,
        bundleIDs.unity,
      }),
      D = getBundleWindows({
        bundleIDs.todoist,
      }),
    },
    unity = {
      A1 = getBundleWindows({
        bundleIDs.unity
      }),
      A2 = {
        chromeProfileWindow.home
      },
      B = getBundleWindows({
        bundleIDs.iterm2,
        bundleIDs.finder,
        bundleIDs.notion,
        bundleIDs.calendar,
        bundleIDs.mail,
        bundleIDs.postman,
        bundleIDs.spotify,
        bundleIDs.slack,
        bundleIDs.anki,
        bundleIDs.whasapp,
        bundleIDs.calendar,
        bundleIDs.sketchbook,
        bundleIDs.dayone,
        bundleIDs.zoom,
      }),
      C = {
        chromeProfileWindow.alien
      },
      D = getBundleWindows({
        bundleIDs.todoist,
      }),
    },
    zoom = {
      A1 = {
        chromeProfileWindow.home
      },
      A2 = tablemerge(
        { chromeProfileWindow.alien },
        getBundleWindows({
          bundleIDs.iterm2,
          bundleIDs.finder,
          bundleIDs.notion,
          bundleIDs.todoist,
        })
      ),
      B = getBundleWindows({ 
        bundleIDs.zoom 
      }),
      C = getBundleWindows({
        bundleIDs.calendar,
        bundleIDs.mail,
        bundleIDs.postman,
        bundleIDs.spotify,
        bundleIDs.slack,
        bundleIDs.anki,
        bundleIDs.whasapp,
        bundleIDs.calendar,
        bundleIDs.sketchbook,
        bundleIDs.dayone,
        bundleIDs.unity,
      }),
    }
  }
  if layout then
    return appLayouts[layout]
  end
  return appLayouts.default
end)

local setGridLayoutInit = (function(layout)

  local _layout
  if layout then
    _layout = layout
    currentLayout = layout
  elseif currentLayout then
    _layout = currentLayout
  else
    return
  end

  local gridSettings = gridLayout[_layout]()
  local appGroup = setAppGroup(currentAppLayout)

  if appGroup.D then
    runOnApplications( appGroup.D, gridSettings.D )
  end
  if appGroup.C then
    runOnApplications( appGroup.C, gridSettings.C )
  end
  if appGroup.B then
    runOnApplications( appGroup.B, gridSettings.B )
  end
  if appGroup.A2 then
    runOnApplications( appGroup.A2, gridSettings.A2, true )
  end
  if appGroup.A1 then
    runOnApplications( appGroup.A1, gridSettings.A1, true )
  end
end)

-- Set Layout
local chainFormation = (function()
  local cycleLength = #appLayoutFormation
  local sequenceNumber = 1
  currentAppLayout = appLayoutFormation[sequenceNumber]

  return function()
    sequenceNumber = sequenceNumber % cycleLength + 1
    currentAppLayout = appLayoutFormation[sequenceNumber]
    setGridLayoutInit()
  end
end)

-- Toggle Sidebar

local turnOnSideBar = (function()
  if sideBar then
    sideBar = false
  else
    sideBar = true
  end
  setGridLayoutInit()
end)

-- Toggle Vertial Mode

local turnOnVerticalMode = (function()
  if isWindowsVertical then
    isWindowsVertical = false
  else
    isWindowsVertical = true
  end
  setGridLayoutInit()
end)

-- Toggle Iterm Split
--
local turnOnIsItermSplit = (function()
  if isItermSplit then
    isItermSplit = false
  else
    isItermSplit = true
  end
  setGridLayoutInit()
end)


-- Toggle Chrome Split

local turnOnIsChromeSplit = (function()
  if isChromeSplit then
    isChromeSplit = false
  else
    isChromeSplit = true
  end
  setGridLayoutInit()
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
        turnOnSideBar() 
    end)

    hs.hotkey.bind(mash, '[', function() 
        turnOnVerticalMode() 
    end)

    hs.hotkey.bind(mash, '0', function() 
        turnOnIsItermSplit() 
    end)

    hs.hotkey.bind(mash, '9', function() 
        turnOnIsChromeSplit() 
    end)

    hs.hotkey.bind(mash, '1', (function() setGridLayoutInit('one') end))
    hs.hotkey.bind(mash, '2', (function() setGridLayoutInit('two') end))
    hs.hotkey.bind(mash, '3', (function() setGridLayoutInit('three') end))
    hs.hotkey.bind(mash, '4', chainFormation())
  end)
}
