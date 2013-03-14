

local widget = require ( "widget" )
--local rotationfix = require( "rotationfix" )
local SysEvents = require( "SysEvents" )
local storyboard = require ( "storyboard" )
widget.setTheme( "theme_ios" )
local bgrp = require("BgdGroup")
local YOUR_API_KEY = "e00eed6fb2714d55aa40aa542d4f9fd7"

-- If there is a better way to get APP_BUNDLE and APP_VERSION runtime, please drop us a line at coronasdk@krooshal.com

-- iOS: This should match the value you specify for 'CFBundleIdentifier' field in build.settings
-- Android: This should match the value you specify for 'Package' field when building the app for device.
-- for Krooshal
local APP_BUNDLE = "com.workinsoft.EskoDealer"
local APP_VERSION = "1.0"

-- Require Krooshal
local krslInstallation = require('KrslInstallation')

-- Install Krooshal
krslInstallation.getCurrent:install(APP_BUNDLE, APP_VERSION, YOUR_API_KEY, function()

  -- Optionally persist installationId in your app logic
  print ("Installed with " .. krslInstallation.getCurrent:getInstallationId())

  -- Associate attributes with this installation
  krslInstallation.getCurrent:tag({'green', 'blue'})

  -- Check for update
  krslInstallation.getCurrent:checkForUpdate()
end)


local onSystem = function(event)
    if event.type == "applicationStart" then
    elseif event.type == "applicationExit" then
    elseif event.type == "applicationSuspend" then
    elseif event.type == "applicationResume" then
      krslInstallation.getCurrent:checkForUpdate()
    end
end



-- Background Width/Height/Alignment

--iPhone
--local backgroundWidth = 320
--local backgroundHeight = 480

--Android
local backgroundWidth = 360
local backgroundHeight = 570

--Create a tab-bar and place it at the bottom of the screen
local demoTabs = widget.newTabBar{
	top = display.contentHeight - 50 - display.screenOriginY,
	buttons = bgrp.tabButtons
}

-- load first scene
storyboard.gotoScene( "sceneSplash", "fade", 400 )

Runtime:addEventListener("system", onSystem)
