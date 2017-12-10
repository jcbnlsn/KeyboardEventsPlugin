----------------------------------------------------------------------
--
--  Samplecode for keyboard events plugin
--  Created by Jacob Nielsen 2017
--
----------------------------------------------------------------------

local keyboardEvents = require "plugin.keyboardEvents"
keyboardEvents.init(true) -- pass true to move the stage up with the keyboard

local inspect = require "inspect" -- library for inspecting tables

-- Add a textfield
local textField = native.newTextField( display.contentCenterX, display.contentCenterY, display.contentWidth, 30 )
textField.y = display.contentHeight-display.screenOriginY
textField.anchorY = 1
textField.placeholder = "Write some text..." 

-- Add keyboard event listener
local function keyboardEventListener( event )
	local keyboardHeight = event.keyboardHeight*display.contentScaleY -- convert height to corona screen units 
	print ( inspect(event) )
end
Runtime:addEventListener( "keyboardEvent", keyboardEventListener )

-- Dismiss keyboard when touching outside the textfield
Runtime:addEventListener("touch", function(event)
	if event.phase == "ended" then
		native.setKeyboardFocus( nil )
	end
end)

-- If the view moves up with the keyboard it is necessary to dismiss the keyboard when leaving the app.
local function onSystemEvent(event)
    if event.type == "applicationExit" or event.type == "applicationSuspend" then
        native.setKeyboardFocus( nil ) 
    end
end
Runtime:addEventListener( "system", onSystemEvent )


