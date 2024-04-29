-- main.lua

display.setStatusBar(display.HiddenStatusBar)
native.setProperty("preferredScreenEdgesDefferingSystemGestures",true)

--Create composer
local composer = require("composer")
composer.recycleOnsceneChange = true
composer.gotoScene("scenes.menu")