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

local screenCount = #hs.screen.allScreens()

local grid = {
  topHalf = '0,0 12x6',
  topThird = '0,0 12x4',
  topTwoThirds = '0,0 12x8',
  rightHalf = '6,0 6x12',
  rightThird = '8,0 4x12',
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
  centeredSmall = '4,4 4x4',
}

layoutMap = {
  {1,
    { '0,0 12x12' } --fullscreen
  },
  {2,
    { '0,0 6x12', '6,0 6x12'}, -- split vertical
    { '0,0 9x12', '9,0 3x12' }, -- right toolbar
    { '0,0 9x12', '9,0 3x12' }, -- split horizontal (bottom small)
  },
  {3,
    { '0,0 6x12', '6,0 6x12'}, --- split vertical (with right split horzontal)
    { '0,0 9x12', '9,0 3x12' }, -- split hoizontal (with bottom split vertical small)
    { '0,0 9x12', '9,0 3x12' }, -- three vertical split
  },
  {4,
    { '0,0 6x12', '6,0 6x12'}, --- 3[0] with righttoolbar
    { '0,0 9x12', '9,0 3x12' }, -- split hoizontal (with bottom split vertical and smaller)
    { '0,0 9x12', '9,0 3x12' }, -- split hoizontal (with bottom three way split vertical small)
    { '0,0 9x12', '9,0 3x12' }, -- four squares (split horizotal / split vertical)
  },
}

local _grid = {
  full         =  {x=0, y=0, w=12, h=12},
  leftSide     =  {x=0, y=0, w=6, h=12},
  rightSide    =  {x=6, y=0, w=6, h=12},
  topRight     =  {x=6, y=0, w=6, h=8},
  bottomRight  =  {x=6, y=6, w=6, h=4},
  bottomLeft   =  {x=0, y=6, w=6, h=4},
  topFull      =  {x=0, y=0, w=12, h=8},
  toolbar      =  {x=9, y=0, w=3, h=12},
}

local generate_grid = (function(grid)
  -- '0,0 12x12'
 return _grid['y'].. ','.. _grid['x'].. ' '.. _grid['w'].. 'x'.. _grid['h']
end)

local deduct_toolbar = (function(args)
  count = #args
  if count == 1 then
    args[1]['w'] = args[1]['w'] - 3
  elseif count == 2 then
    args[1]['w'] = args[1]['w'] - 2
    args[2]['w'] = args[2]['w'] - 1
    args[2]['y'] = args[2]['y'] - 1
  elseif count == 3 then
    args[1]['w'] = args[1]['w'] - 2
    args[2]['w'] = args[2]['w'] - 1
    args[2]['y'] = args[2]['y'] - 1
    args[3]['w'] = args[3]['w'] - 1
    args[3]['y'] = args[3]['y'] - 1
  end
  return args
end)

local appMap = {
  {
    work = {
      'com.google.Chrome'
    },
    gtd = {
      'com.odoist.mac.Todoist'
    },
    browsing = {
      'com.google.Chrome'
    },
    writing = {
      'com.brettterpstra.marked2',
      'com.googlecode.iterm2',
      'com.bloombuilt.dayone-mac',
      'notion.id'
    },
    alternative = {
      'com.tinyspeck.slackmacgap',
      'com.deezer.deezer-desktop'
    },
    toolbar = {
      'com.todoist.mac.Todoist'
    },
  }
}

local layoutMapping = {
  {
    _grid.full
  },
  {
    _grid.leftSide,
    _grid.rightSide
  },
  {
    _grid.leftSide,
    _grid.topRight,
    _grid.bottomRight
  },
  {
    _grid.topFull,
    _grid.bottomLeft,
    _grid.bottomRight
  }
}

local layoutConfig = {
  _before_ = (function()
    -- hide('com.deezer.deezer-desktop')
  end),

  _after_ = (function()
    local app = hs.application.get('com.google.Chrome')
    app:selectMenuItem({ 'Window', 'Bring All to Front' })
    local app = hs.application.get('com.googlecode.iterm2')
    app:selectMenuItem({ 'Window', 'Bring All to Front' })
    local app = hs.application.get('com.todoist.mac.Todoist')
    app:selectMenuItem({ 'Window', 'Bring All to Front' })
  end),

  ['com.apple.iCal'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    elseif count == 2 then
      hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
    end
  end),

  ['com.tinyspeck.slackmacgap'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.fullScreen, internalDisplay())
    end
  end),

  ['com.todoist.mac.Todoist'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.rightToolBar, hs.screen.primaryScreen())
    else
      hs.grid.set(window, grid.fullScreen, internalDisplay())
    end
  end),

  ['com.deezer.deezer-desktop'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
  end),

  ['WhasApp'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    hs.grid.set(window, grid.bottomRight, hs.screen.primaryScreen())
  end),

  ['notion.id'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    else
      hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
    end
  end),

  ['com.google.Chrome'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    else
      hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
    end
  end),

  ['com.googlecode.iterm2'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.leftNoToolBar, hs.screen.primaryScreen())
    else
      hs.grid.set(window, grid.rightHalf, hs.screen.primaryScreen())
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

  layoutConfig._after_()
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
    end
end

chromeAlien = (function()
  -- get alien chrome --
  local chrome = hs.appfinder.appFromName('Google Chrome')
  if not chrome then
    return
  end
  local str_menu_item = {"People", "Alien"}
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
hs.hotkey.bind(mash, "'", function() hs.application.launchOrFocus('Insomnia') end)
hs.hotkey.bind(mash, ',', function() hs.application.launchOrFocus('Harvest') end)
hs.hotkey.bind(mash, ".", function() hs.application.launchOrFocus('Numi') end)
-- "p" for 1pass
hs.hotkey.bind(mash, 'f', function() hs.application.launchOrFocus('Figma') end)

hs.hotkey.bind(mash, "a", chrome_switch_to('Cam'))
hs.hotkey.bind(mash, "o", chrome_switch_to('Alien'))
hs.hotkey.bind(mash, 'e', function() hs.application.launchOrFocus('iTerm') end)
hs.hotkey.bind(mash, 'u', function() hs.application.launchOrFocus('Todoist') end)
hs.hotkey.bind(mash, "i", function() hs.application.launchOrFocus('Slack') end)
-- hs.hotkey.bind(mash, 'd', function() hs.application.launchOrFocus('Day One') end)

hs.hotkey.bind(mash, ';', function() hs.application.launchOrFocus('Notion') end)
hs.hotkey.bind(mash, 'q', function() hs.application.launchOrFocus('Calendar') end)
hs.hotkey.bind(mash, 'j', function() hs.application.launchOrFocus('Deezer') end)
hs.hotkey.bind(mash, 'k', function() hs.application.launchOrFocus('WhatsApp') end)
hs.hotkey.bind(mash, 'x', function() hs.application.launchOrFocus('Anki') end) 

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

hs.hotkey.bind(mash, '1', switchTo({ 1, 2 }, activateLayout))
hs.hotkey.bind(mash, '2', switchTo({ 3, 4 }, activateLayout))
hs.hotkey.bind(mash, '3', switchTo({ 5, 10  }, activateLayout))
hs.hotkey.bind(mash, '4', switchTo({ 6, 7, 8, 9 }, activateLayout))

-- iterm.init()
karabiner.init()
reloader.init()
initEventHandling()
events.subscribe('reload', tearDownEventHandling)

log.i('Config loaded')
