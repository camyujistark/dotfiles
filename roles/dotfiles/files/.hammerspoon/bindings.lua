local log = require 'log'

local chain = nil
local runOnApplications = nil
local canManageWindow = nil
local sideBar = false
local isWindowsVertical = true
local isSplitX = false
local isSplitY = false
local currentLayout = 'one'
local currentAppLayout = 'default'
local isDebounceChange = false
-- currently you need chrome to be open on startup for this setup to work
local chromeWindow = {}
local toggleFocusFull = false

local macBookAir13 = '1440x900'
local macBookPro15_2019 = '1680x1050'

internalDisplay = (function()
  if hs.screen.find(macBookAir13) then
    return hs.screen.find(macBookAir13)
  end
  if hs.screen.find(macBookPro15_2019) then
    return hs.screen.find(macBookPro15_2019)
  end
end)

-- chrome profiles
local chromeProfiles = {}
chromeProfiles.work = 'Cam'
chromeProfiles.home = 'Cam (Home)'
chromeProfiles.side = 'Cam (Side)'

-- programs
local bundleIDs = {}
bundleIDs.anki = 'net.ankiweb.dtop'
bundleIDs.calendar = 'com.apple.iCal'
bundleIDs.chrome ='com.google.Chrome'
bundleIDs.dayone = 'com.bloombuilt.dayone-mac'
bundleIDs.finder = 'com.apple.finder'
bundleIDs.iterm2 = 'com.googlecode.iterm2'
bundleIDs.mail = 'com.apple.mail'
bundleIDs.obsidian = 'md.obsidian'
bundleIDs.notion = 'notion.id'
bundleIDs.postman = 'com.postmanlabs.mac'
bundleIDs.marked2 = 'com.brettterpstra.marked2'
bundleIDs.sketchbookpro = 'com.autodesk.sketchbookpro7mac'
bundleIDs.sketchbook = 'com.autodesk.SketchBook'
bundleIDs.slack = 'com.tinyspeck.slackmacgap'
bundleIDs.spotify = 'com.spotify.client'
bundleIDs.todoist = 'com.todoist.mac.Todoist'
bundleIDs.whatsapp = 'WhatsApp'
bundleIDs.zoom = 'us.zoom.xos'
bundleIDs.unity = 'com.unity3d.UnityEditor5.x'
bundleIDs.unityhub = 'com.unity3d.unityhub'
bundleIDs.vscode = 'com.microsoft.VSCode'
bundleIDs.preview = 'com.apple.Preview'
bundleIDs.logseq = 'com.electron.logseq'
bundleIDs.obsidian = 'md.obsidian'
bundleIDs.raindropio = 'io.raindrop.macapp'

local grid = {
  topHalf = '0,0/12x6',
  topThird = '0,0/12x4',
  topTwoThirds = '0,0/12x8',
  rightHalf = '6,0/6x12',
  rightThird = '8,0/4x12',
  rightTwoThirds = '4,0/8x12',
  bottomHalf = '0,6/12x6',
  bottomThird = '0,8/12x4',
  bottomTwoThirds = '0,4/12x8',
  leftHalf = '0,0/6x12',
  leftThird = '0,0/4x12',
  leftTwoThirds = '0,0/8x12',
  topLeft = '0,0/6x6',
  topRight = '6,0/6x6',
  bottomRight = '6,6/6x6',
  bottomLeft = '0,6/6x6',
  fullScreen = '0,0/12x12',
  centeredBig = '3,3/6x6',
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
local maybeIsHorizonal = (function(a, b)
  if isWindowsVertical then
    return a
  else
    return b
  end
end)
local maybeSplitXGridCoord = (function(a, b)
  if isSplitX then
    return a
  else
    return b
  end
end)
local maybeSplitYGridCoord = (function(a, b)
  if isSplitY then
    return a
  else
    return b
  end
end)

local getChromeProfileWindows = (function()
  -- note may need
  if chromeWindow.work == nil
    or hs.window.find(chromeWindow.work:id()) == nil then
    -- work
    chrome_switch_to(chromeProfiles.work)
    chromeWindow.work = hs.window.frontmostWindow()
    log.i(chromeWindow.work)
  end
  if chromeWindow.home == nil
    or hs.window.find(chromeWindow.home:id()) == nil then
    -- home
    chrome_switch_to(chromeProfiles.home)
    chromeWindow.home = hs.window.frontmostWindow()
  end
  if chromeWindow.side == nil
    or hs.window.find(chromeWindow.side:id()) == nil then
    -- side
    chrome_switch_to(chromeProfiles.side)
    chromeWindow.side = hs.window.frontmostWindow()
  end
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
      str_menu_item = {"Profiles", ppl}
  end

  local menu_item = chrome:findMenuItem(str_menu_item)
  if (menu_item) then
      chrome:selectMenuItem(str_menu_item)
      chrome:activate()
  end
end)

getBundleWindow = (function(bundleID)
  local applicationWindow;
  local application = hs.application.get(bundleID)
  if application then
    local windows = application:visibleWindows()
    for _, window in pairs(windows) do
      if canManageWindow(window) then
        applicationWindow = window
      end
    end
  end
  return applicationWindow
end)

getBundleWindows = (function(bundleIDs)
  bundleWindows = {}
  for i, bundleID in pairs(bundleIDs) do
    table.insert(bundleWindows, getBundleWindow(bundleID));
  end
  return bundleWindows
end)

runOnApplications = (function(appWindows, groupGrid, screen)
  for _, window in pairs(appWindows) do
      local windowGrid = hs.grid.get(window)
      local windowScreen = hs.screen.primaryScreen()
      if screen then
        windowScreen = screen
      end
      if(windowGrid.string ~= groupGrid) then
        hs.grid.set(window, groupGrid, windowScreen)
      end
      if showOnTop then
        window:focus()
      end
  end
end)

closeApplications = (function(bundleIDs)
  for _, bundleID in pairs(bundleIDs) do
  local application = hs.application.get(bundleID)
  if application then
      application:kill()
    end
  end
end)

openApplicationsByBundleID = (function(bundleIDs)
  for _, bundleID in pairs(bundleIDs) do
    local window = getBundleWindow(bundleID)
    if window then
    else
      hs.application.launchOrFocusByBundleID(bundleID)
    end
  end
end)
-- Grid Layouts



--|------|------|------------|-------|
--|      |      |            |       |
--|      A      |     B      |       |
--|      |      |            |       |
--|  A1  |  A2  |------------|   D   |
--|      |      |            |       |
--|      |      |     C      |       |
--|      |      |            |       |
--|------|------|------------|-------|


local laptopGridLayout = {
  one = (function()
    return maybeIsSideBar({
      -- A = '0,0/10x12',
      A1 = '0,0/8x12',
      A2 = '0,0/8x12',
      B = '0,0/8x12',
      C = '0,0/8x12',
      D = '8,0/4x12',
    },
    {
      -- A = '0,0/12x12',
      A1 = '0,0/12x12',
      A2 = '0,0/12x12',
      B = '0,0/12x12',
      C = '0,0/12x12',
      D = '0,0/12x12',
    })
  end),
  two = (function()
    return maybeIsSideBar(
      maybeIsHorizonal({
        -- too small to have a vertical split
        -- A = '0,0/4x12',
        A1 = maybeSplitXGridCoord('0,0/5x6','0,0/5x12'),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('0,6/5x6', '0,0/5x12'),
          maybeSplitXGridCoord('0,0/5x6', '0,0/5x12')
        ),
        B = '5,0/5x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('0,6/5x6', '0,0/5x12'),
          maybeSplitXGridCoord('0,6/5x6', '0,0/5x12')
        ),
        D = '10,0/2x12',
      },
      {
        -- A = '0,0/10x6',
        A1 = maybeSplitYGridCoord('0,0/5x6', '0,0/10x6'),
        A2 = maybeSplitYGridCoord('5,0/5x6', '0,0/10x6'),
        B = maybeSplitXGridCoord('5,6/5x6', '0,6/10x6'),
        C = maybeSplitXGridCoord('0,6/5x6', maybeSplitYGridCoord('5,0/5x6', '0,0/10x6')),
        D = '10,0/2x12',
      }),
      maybeIsHorizonal({
        A1 = maybeSplitYGridCoord(
          '0,0/3x12',
          maybeSplitXGridCoord('0,0/6x6','0,0/6x12')
        ),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,0/3x6', '3,0/3x12'),
          maybeSplitXGridCoord('0,0/6x6','0,0/6x12')
        ),
        B = '6,0/6x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,6/3x6','3,0/3x12'),
          maybeSplitXGridCoord('0,6/6x6','0,0/6x12')
        ),
        D = '6,0/6x12',
      },
      {
        A1 = maybeSplitYGridCoord('0,0/6x6', '0,0/12x6'),
        A2 = maybeSplitYGridCoord('6,0/6x6', '0,0/12x6'),
        B = maybeSplitXGridCoord('6,6/6x6', '0,6/12x6'),
        C = maybeSplitXGridCoord('0,6/6x6', maybeSplitYGridCoord('6,0/6x6', '0,0/12x6')),
        D = maybeSplitXGridCoord('6,6/6x6', '0,6/12x6'),
      })
    )
  end),
  three = (function()
    return maybeIsSideBar(
      maybeIsHorizonal({
        A1 = maybeSplitYGridCoord(
          '0,0/3x12',
          maybeSplitXGridCoord('0,0/5x6','0,0/5x12')
        ),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,0/3x6', '3,0/3x12'), 
          maybeSplitXGridCoord('0,0/5x6','0,0/5x12')
        ),
        B = '5,0/5x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,6/3x6','3,0/3x12'),
          maybeSplitXGridCoord('0,6/5x6','0,0/5x12')
        ),
        D = '10,0/2x12',
      },
      {
        A1 = maybeSplitYGridCoord('0,0/5x8', '0,0/10x8'),
        A2 = maybeSplitYGridCoord('5,0/5x8', '0,0/10x8'),
        B = maybeSplitXGridCoord('5,8/5x5', '0,8/10x5'),
        C = maybeSplitXGridCoord('0,8/5x5', maybeSplitYGridCoord('0,0/5x8', '0,0/10x8')),
        D = '10,0/2x12',
      }),
      maybeIsHorizonal({
        A1 = maybeSplitYGridCoord(
          '0,0/4x12',
          maybeSplitXGridCoord('0,0/8x6','0,0/8x12')
        ),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('4,0/4x6', '4,0/4x12'), 
          maybeSplitXGridCoord('0,0/8x6','0,0/8x12')
        ),
        B = '8,0/4x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('4,6/4x6','4,0/4x12'),
          maybeSplitXGridCoord('0,6/8x6','0,0/8x12')
        ),
        D = '8,0/4x12',
      },
      {
        A1 = maybeSplitYGridCoord('0,0/6x8', '0,0/12x8'),
        A2 = maybeSplitYGridCoord('6,0/6x8', '0,0/12x8'),
        B = maybeSplitXGridCoord('6,8/6x4', '0,8/12x4'),
        C = maybeSplitXGridCoord('0,8/6x4', maybeSplitYGridCoord('6,0/6x8', '0,0/12x8')),
        D = maybeSplitYGridCoord('6,0/6x8', '0,0/12x8'),
      })
    )
  end),
}


local largeGridLayout = {
  one = (function()
    return maybeIsSideBar({
      -- A = '0,0/10x12',
      A1 = '0,0/10x12',
      A2 = '0,0/10x12',
      B = '0,0/10x12',
      C = '0,0/10x12',
      D = '10,0/2x12',
    },
    {
      -- A = '0,0/12x12',
      A1 = '0,0/12x12',
      A2 = '0,0/12x12',
      B = '0,0/12x12',
      C = '0,0/12x12',
      D = '0,0/12x12',
    })
  end),
  two = (function()
    return maybeIsSideBar(
      maybeIsHorizonal({
        -- too small to have a vertical split
        -- A = '0,0/4x12',
        A1 = maybeSplitXGridCoord('0,0/5x6','0,0/5x12'),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('0,6/5x6', '0,0/5x12'),
          maybeSplitXGridCoord('0,0/5x6', '0,0/5x12')
        ),
        B = '5,0/5x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('0,6/5x6', '0,0/5x12'),
          maybeSplitXGridCoord('0,6/5x6', '0,0/5x12')
        ),
        D = '10,0/2x12',
      },
      {
        -- A = '0,0/10x6',
        A1 = maybeSplitYGridCoord('0,0/5x6', '0,0/10x6'),
        A2 = maybeSplitYGridCoord('5,0/5x6', '0,0/10x6'),
        B = maybeSplitXGridCoord('5,6/5x6', '0,6/10x6'),
        C = maybeSplitXGridCoord('0,6/5x6', maybeSplitYGridCoord('5,0/5x6', '0,0/10x6')),
        D = '10,0/2x12',
      }),
      maybeIsHorizonal({
        A1 = maybeSplitYGridCoord(
          '0,0/3x12',
          maybeSplitXGridCoord('0,0/6x6','0,0/6x12')
        ),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,0/3x6', '3,0/3x12'),
          maybeSplitXGridCoord('0,0/6x6','0,0/6x12')
        ),
        B = '6,0/6x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,6/3x6','3,0/3x12'),
          maybeSplitXGridCoord('0,6/6x6','0,0/6x12')
        ),
        D = '6,0/6x12',
      },
      {
        A1 = maybeSplitYGridCoord('0,0/6x6', '0,0/12x6'),
        A2 = maybeSplitYGridCoord('6,0/6x6', '0,0/12x6'),
        B = maybeSplitXGridCoord('6,6/6x6', '0,6/12x6'),
        C = maybeSplitXGridCoord('0,6/6x6', maybeSplitYGridCoord('6,0/6x6', '0,0/12x6')),
        D = maybeSplitXGridCoord('6,6/6x6', '0,6/12x6'),
      })
    )
  end),
  three = (function()
    return maybeIsSideBar(
      maybeIsHorizonal({
        A1 = maybeSplitYGridCoord(
          '0,0/3x12',
          maybeSplitXGridCoord('0,0/5x6','0,0/5x12')
        ),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,0/3x6', '3,0/3x12'), 
          maybeSplitXGridCoord('0,0/5x6','0,0/5x12')
        ),
        B = '5,0/5x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('3,6/3x6','3,0/3x12'),
          maybeSplitXGridCoord('0,6/5x6','0,0/5x12')
        ),
        D = '10,0/2x12',
      },
      {
        A1 = maybeSplitYGridCoord('0,0/5x8', '0,0/10x8'),
        A2 = maybeSplitYGridCoord('5,0/5x8', '0,0/10x8'),
        B = maybeSplitXGridCoord('5,8/5x5', '0,8/10x5'),
        C = maybeSplitXGridCoord('0,8/5x5', maybeSplitYGridCoord('0,0/5x8', '0,0/10x8')),
        D = '10,0/2x12',
      }),
      maybeIsHorizonal({
        A1 = maybeSplitYGridCoord(
          '0,0/4x12',
          maybeSplitXGridCoord('0,0/8x6','0,0/8x12')
        ),
        A2 = maybeSplitYGridCoord(
          maybeSplitXGridCoord('4,0/4x6', '4,0/4x12'), 
          maybeSplitXGridCoord('0,0/8x6','0,0/8x12')
        ),
        B = '8,0/4x12',
        C = maybeSplitYGridCoord(
          maybeSplitXGridCoord('4,6/4x6','4,0/4x12'),
          maybeSplitXGridCoord('0,6/8x6','0,0/8x12')
        ),
        D = '8,0/4x12',
      },
      {
        A1 = maybeSplitYGridCoord('0,0/6x8', '0,0/12x8'),
        A2 = maybeSplitYGridCoord('6,0/6x8', '0,0/12x8'),
        B = maybeSplitXGridCoord('6,8/6x4', '0,8/12x4'),
        C = maybeSplitXGridCoord('0,8/6x4', maybeSplitYGridCoord('6,0/6x8', '0,0/12x8')),
        D = maybeSplitYGridCoord('6,0/6x8', '0,0/12x8'),
      })
    )
  end),
}

local getAppGroup = (function(layout)
  local appLayouts = {
    default = {
      A1 = tablemerge(
        { chromeWindow.work },
        getBundleWindows({
          bundleIDs.preview,
          -- bundleIDs.sketchbook,
          -- bundleIDs.sketchbookpro,
          -- bundleIDs.unity,
        })
      ),
      A2 = { chromeWindow.home,
            chromeWindow.side },
      B = getBundleWindows({
        bundleIDs.iterm2,
        bundleIDs.vscode,
        bundleIDs.logseq,
        bundleIDs.obsidian,
      }),
      C = getBundleWindows({
          bundleIDs.raindropio,
          bundleIDs.notion,
          bundleIDs.anki,
          bundleIDs.calendar,
          bundleIDs.dayone,
          bundleIDs.finder,
          bundleIDs.mail,
          bundleIDs.postman,
          bundleIDs.slack,
          bundleIDs.spotify,
          bundleIDs.whatsapp,
        }),
      D = getBundleWindows({
         bundleIDs.todoist,
      }),
      -- closeBundleIDs = {
        -- bundleIDs.zoom,
      -- }
    },
  }
  if layout then
    return appLayouts[layout]
  end
  return appLayouts.default
end)

local getGridSettings = (function(layout)
  local _layout
  if layout then
    _layout = layout
    currentLayout = layout
  elseif currentLayout then
    _layout = currentLayout
  else
    return
  end

  return largeGridLayout[_layout]()
end)

local getAppLayout = (function(appLayout)
  local _appLayout
  if appLayout then
    _appLayout = appLayout
    currentAppLayout = appLayout
  elseif currentAppLayout then
    _appLayout = currentAppLayout
  else
    return
  end

  return getAppGroup(_appLayout);
end)

local updateGridLayout = (function(appGroup, gridSettings)
  if appGroup.openBundleIds then
    openApplicationsByBundleID( appGroup.openBundleIds )
  end
  if appGroup.D then
    runOnApplications( appGroup.D, gridSettings.D, internalDisplay() )
  end
  if appGroup.C then
      runOnApplications( appGroup.C, gridSettings.C, internalDisplay() )
  end
  if appGroup.B then
    runOnApplications( appGroup.B, gridSettings.B )
  end
  if appGroup.A2 then
    runOnApplications( appGroup.A2, gridSettings.A2 )
  end
  if appGroup.A1 then
    runOnApplications( appGroup.A1, gridSettings.A1 )
  end
  if appGroup.closeBundleIDs then
    closeApplications( appGroup.closeBundleIDs )
  end
end)

local setGridLayoutInit = (function(layout, appLayout)
  getChromeProfileWindows()
  local windowInFocus = hs.window.frontmostWindow()
  local gridSettings = getGridSettings(layout)
  local appGroup = getAppLayout(appLayout)
  updateGridLayout(appGroup, gridSettings)
  windowInFocus:focus()
end)

local fullScreenInit = (function()
  if toggleFocusFull then
    local windowInFocus = hs.window.frontmostWindow()
    local windowScreen = hs.screen.primaryScreen()
    local gridSettings = maybeIsSideBar('0,0/10x12','0,0/12x12')
    hs.grid.set(windowInFocus, gridSettings, windowScreen)
    windowInFocus:focus()
  else
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
end)

-- Toggle Vertial Mode

local turnOnVerticalMode = (function()
  if isWindowsVertical then
    isWindowsVertical = false
  else
    isWindowsVertical = true
  end
end)

-- Toggle Iterm Split
--
local turnOnSplitX = (function()
  if isSplitX then
    isSplitX = false
  else
    isSplitX = true
  end
end)


-- Toggle Chrome Split

local turnOnSplitYGridCoord = (function()
  if isSplitY then
    isSplitY = false
  else
    isSplitY = true
  end
end)

local turnOnWindowFocus = (function()
  if not toggleFocusFull then
    toggleFocusFull = true
  else
    toggleFocusFull = false
  end
end)

local resetAllFormations = (function()
    isSplitX = false
    isSplitY = false
    isWindowsVertical = true
end)

local tutorialMode = (function()
    isSplitX = true
    isSplitY = true
    isWindowsVertical = true
end)

local fourSquareMode = (function()
    isSplitX = true
    isSplitY = true
    isWindowsVertical = false
end)

local codingFormation = (function()
    isSplitX = true
    isSplitY = false
    isWindowsVertical = true
end)


--
-- Key bindings.
--

-- Mash to be matched to holding down enter
local mash = {'ctrl', 'alt', 'shift','cmd'}

return {
  init = (function()

    getChromeProfileWindows()

    -- APP MASH --
    hs.hotkey.bind(mash, "'", function() hs.application.launchOrFocusByBundleID(bundleIDs.mail) end)
    hs.hotkey.bind(mash, ",", function() hs.application.launchOrFocusByBundleID(bundleIDs.calendar) end)
    hs.hotkey.bind(mash, ".", function() hs.application.launchOrFocusByBundleID(bundleIDs.finder) end)
    --left
    hs.hotkey.bind(mash, "a", function() chrome_switch_to(chromeProfiles.home) end)
    hs.hotkey.bind(mash, "o", function() hs.application.launchOrFocusByBundleID(bundleIDs.iterm2) end)
    hs.hotkey.bind(mash, "e", function() hs.application.launchOrFocusByBundleID(bundleIDs.obsidian) end)
    hs.hotkey.bind(mash, "q", function() hs.application.launchOrFocus('Visual Studio Code') end)
    hs.hotkey.bind(mash, "i", function() hs.application.launchOrFocusByBundleID(bundleIDs.todoist) end)

    hs.hotkey.bind(mash, ";", function() chrome_switch_to(chromeProfiles.home) end)
    hs.hotkey.bind(mash, "u", function() hs.application.launchOrFocusByBundleID(bundleIDs.raindropio) end)
    hs.hotkey.bind(mash, 'j', function() hs.application.launchOrFocusByBundleID(bundleIDs.slack) end)
    hs.hotkey.bind(mash, 'k', function() hs.application.launchOrFocusByBundleID(bundleIDs.spotify) end)
    hs.hotkey.bind(mash, 'x', function() hs.application.launchOrFocusByBundleID(bundleIDs.whatsapp) end)

    -- right
    -- hs.hotkey.bind(mash, 'f', function() hs.application.launchOrFocusByBundleID(bundleIDs.finder) end)
    -- hs.hotkey.bind(mash, 'g', function() hs.application.launchOrFocusByBundleID(bundleIDs.preview) end)
    -- hs.hotkey.bind(mash, 'c', function() hs.application.launchOrFocusByBundleID(bundleIDs.marked2) end)
    -- hs.hotkey.bind(mash, 'r', function() hs.application.launchOrFocusByBundleID(bundleIDs.zoom) end)

    -- only on some computers
    -- hs.hotkey.bind(mash, 'w', function() hs.application.launchOrFocusByBundleID(bundleIDs.sketchbook) end)
    -- hs.hotkey.bind(mash, 'm', function() hs.application.launchOrFocusByBundleID(bundleIDs.unity) end)

    -- FREE MOVE CHAIN --
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

    -- Sound
    hs.hotkey.bind(mash, 'help', function() hs.execute("SwitchAudioSource -s 'CalDigit Thunderbolt 3 Audio'", true) end)
    hs.hotkey.bind(mash, 'home', function() hs.execute("SwitchAudioSource -s 'Logitech BT Adapter'", true) end)
    hs.hotkey.bind(mash, 'pageup', function() hs.execute("SwitchAudioSource -s 'Built-in Output'", true) end)

    -- hs.hotkey.bind(mods, key, pressedfn, releasedfn, repeatfn) ->
    -- hs.hotkey object --
    -- Note: Cannot get the repeartfn to work
    -- FLIPS --
    hs.hotkey.bind(mash, '\\', turnOnSideBar, setGridLayoutInit)
    hs.hotkey.bind(mash, '=', turnOnSplitX, setGridLayoutInit)
    hs.hotkey.bind(mash, '/', turnOnSplitYGridCoord, setGridLayoutInit)
    hs.hotkey.bind(mash, 'l', turnOnVerticalMode, setGridLayoutInit)

    -- LAYOUTS --
    -- hs.hotkey.bind(mash, "`", function()  hs.execute("bash $HOME/Documents/Scripts/stream-deck/linux/rr.sh thought", true) end)
    -- hs.hotkey.bind(mash, "1", function()  hs.execute("bash $HOME/Documents/Scripts/stream-deck/linux/rr.sh seedbox", true) end)
    -- hs.hotkey.bind(mash, "2", function()  hs.execute("bash $HOME/Documents/Scripts/stream-deck/linux/rr.sh", true) end)
    -- hs.hotkey.bind(mash, "3", function()  hs.execute("/usr/local/bin/bash $HOME/Documents/Scripts/stream-deck/linux/rr.sh current end >> $HOME/Documents/Scripts/stream-deck/run.log") end)
    -- hs.hotkey.bind(mash, '1', resetAllFormations, setGridLayoutInit)
    -- hs.hotkey.bind(mash, '2', codingFormation, setGridLayoutInit)
    -- hs.hotkey.bind(mash, '3', tutorialMode, setGridLayoutInit)
    -- hs.hotkey.bind(mash, '4', fourSquareMode, setGridLayoutInit)
    -- hs.hotkey.bind(mash, '9', turnOnWindowFocus, fullScreenInit)
    -- hs.hotkey.bind(mash, '0', (function() setGridLayoutInit('one') end))
    -- hs.hotkey.bind(mash, '[', (function() setGridLayoutInit('two') end))
    -- hs.hotkey.bind(mash, ']', (function() setGridLayoutInit('three') end))

    -- hs.hotkey.bind(mash, '-', function()
    --   local layout
    --   if currentAppLayout == 'default' then
    --     layout = 'zoom'
    --   else
    --     layout = 'default'
    --   end
    --   setGridLayoutInit(nil, layout)
    -- end)
  end)
}
