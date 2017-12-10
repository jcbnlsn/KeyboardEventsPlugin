----------------------------------------------------------------------
--
--  Samplecode for keyboard events plugin 
--	Turn off auto-correction and spell checking example 
--  Created by Jacob Nielsen (c) 2017
--
----------------------------------------------------------------------

local keyboardEvents = require "plugin.keyboardEvents"
keyboardEvents.init()

local textBox = native.newTextBox( display.contentCenterX, display.contentCenterY, display.contentWidth-40, 100 )
textBox.placeholder = "Write some text..." 
textBox.isEditable = true
textBox.size = 20

keyboardEvents.setAutocorrectionType("UITextAutocorrectionTypeNo")
keyboardEvents.setSpellCheckingType("UITextSpellCheckingTypeNo")



