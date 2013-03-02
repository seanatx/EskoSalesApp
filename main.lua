-- 
-- Abstract: Tab Bar sample app
--  
-- Version: 2.0
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
--
-- Demonstrates how to create a tab bar that allows the user to navigate between screens,
-- using the Widget & Storyboard libraries.

local widget = require ( "widget" )
--local rotationfix = require( "rotationfix" )
local SysEvents = require( "SysEvents" )
local storyboard = require ( "storyboard" )
widget.setTheme( "theme_ios" )
local bgrp = require("BgdGroup")

-- Background Width/Height/Alignment

--iPhone
--local backgroundWidth = 320
--local backgroundHeight = 480

--Android
local backgroundWidth = 360
local backgroundHeight = 570

-- iPhone5
--local backgroundWidth = 640
--local backgroundHeight = 1136

-- iPad
--local backgroundWidth = 768
--local backgroundHeight = 1024
--local backgroundAlignment = "center"

-- create a display group
--local VisualGroup = display.newGroup()

-- Background Pic
--bgrp.backgroundMain()



--VisualGroup:insert(background)

--display.setDefault( "background", 255, 255, 255 )



--Create a tab-bar and place it at the bottom of the screen
local demoTabs = widget.newTabBar{
	top = display.contentHeight - 50 - display.screenOriginY,
	buttons = bgrp.tabButtons
}


-- load first scene
storyboard.gotoScene( "sceneQuotes", "fade", 400 )

