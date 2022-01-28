
local composer = require( "composer" )
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
local inspect = require "inspect"
local isSimulator = "simulator" == system.getInfo("environment")
local widget = require "widget"
require "expandingTextBox"

local keyboardEvents 
if not isSimulator then
	keyboardEvents = require "plugin.keyboardEvents"
	keyboardEvents.init(true)
	--keyboardEvents.setKeyboardAppearance("light")
end

-- iPhone X safe areas
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
local isIPhoneX = system.getInfo("model") == "iPhone" and bottomInset ~= 0

-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local g = self.view
    
	local textBox
	local maximize, send -- buttons

    -- Message view
    local messages = require("messageView").new()
    g:insert(messages)
    
    -- Close button handler
    local function closeButtonHandler(e)
    	if e.phase == "ended" then
			native.showAlert( "X button tapped", "Close something...", {"OK"} )
		end
		return true
	end
    
    -- Header
    local header = display.newGroup()
    header.bg = display.newRect(header, 0, 0, display.contentWidth-(2*display.screenOriginX), 36+topInset)
    header.bg:setFillColor(.3, 0.44, 0.68)
    header.text = display.newText( header, "Worktribe", 0, header.bg.y+(topInset*0.5), "Lato-Black", 20 )
    header.close = display.newText( header, "X", (display.contentWidth*0.5)-display.screenOriginX-20, header.bg.y+(topInset*0.5), "Lato-Black", 18 )
    g:insert(header)
    header.x, header.y = display.contentCenterX, (header.bg.height*0.5)+display.screenOriginY
    
    header.close:addEventListener("touch", closeButtonHandler)
 
    -- Capture and show header on top when keyboard is active
    function header:setCapture(bool)
    	if bool then
    		display.save( self, {filename = "header.png", baseDir = system.TemporaryDirectory} )
			keyboardEvents.setHeader(system.pathForFile( "header.png", system.TemporaryDirectory ))
		else
			keyboardEvents.setHeader()
			local filename = system.pathForFile( "header.png", system.TemporaryDirectory )
			os.remove( filename )
		end
    end
    
    -- ButtonHandler
    local isMaximized = false
    local function maximizeHandler()
    	print ("TODO: Maximize text box")
    end
    
    local function sendHandler()
		if textBox.text:gsub("%s+", "") ~= "" then
			messages:addMessage(textBox.text)
			textBox:clear()
		end
    end
    
	-- Send button    
    send = widget.newButton {
    	parent = g,
        label = "Send",
        font = "Lato-Bold",
        fontSize = 15,
        labelColor = { default={ .4, 0.54, 0.78, 1 }, over={ .4, 0.54, 0.78, 1 } },
        shape = "roundedRect",
        width = 40,
        height = 25,
        cornerRadius = 3,
        fillColor = { default={1}, over={0.85,0.85,0.85,.5} },
        onRelease = sendHandler
    }
    send.x = display.contentWidth-display.screenOriginX-28
    send.y = display.contentHeight-display.screenOriginY-20-(bottomInset/1.5)

    
    -- Maximize text box button    
    maximize = widget.newButton {
    	parent = g,
        defaultFile = "assets/maximizeUp.png",
        overFile = "assets/maximizeDown.png",
        onRelease = maximizeHandler
    }
    maximize:scale(.4,.4)
    maximize.x = display.contentWidth-display.screenOriginX-24
    
	-- Bottom bar background
    local bg = display.newRect(g, display.contentCenterX, display.contentHeight, display.contentWidth-(2*display.screenOriginX)+4, display.contentHeight-(2*display.screenOriginY))
	bg.anchorY = 0
    bg:setFillColor(1)
    bg:setStrokeColor(.9)
    bg.strokeWidth = 1
    --bg.isVisible = false
    
    -- Dummy buttons
    local buttons = display.newImage( g, "assets/dummyButtons.png", display.screenOriginX+58, send.y-2 )
    buttons:scale(.4,.4)

	-- Expanding textbox listener 
	local function textBoxListener( event )
		local t = event.target
		if ( event.phase == "began" ) then
		elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		elseif ( event.phase == "editing" ) then
		elseif ( event.phase == "resize" ) then -- custom expanding textbox event thrown when box resizes
			--print(inspect(event))
			local _y = bg.initY-event.height
			transition.to(bg, {time=t.transitionTime, y=_y-5})
			transition.to(maximize, {time=t.transitionTime, y=_y+15})
			transition.to(messages, {time=t.transitionTime, y=_y-5})
		end
	end

	-- Expanding text box extends native.newTextBox (use same parameters and properties)
	textBox = native.newExpandingTextBox( 0, 0, display.contentWidth-display.screenOriginX-40, 20 )
	textBox.anchorX = 0
	textBox.anchorY = 1 -- expands upwards
	textBox.x = display.screenOriginX+10
	textBox.y = display.contentHeight-display.screenOriginY-38-(bottomInset/1.5)
	textBox.initHeight = textBox.height
	g:insert(textBox)
	textBox.hasBackground = false
	textBox.font = native.newFont( "Lato-Regular", 13.5 )
	textBox.placeholder = "Message #general"
	if isSimulator then textBox.text = "Message #general" end -- placeholder not supported in simulator
	textBox.isEditable = true
	textBox:addEventListener( "userInput", textBoxListener )

	-- Custom property for expanding text box
	textBox.maxLines = 4
	
	-- Set height/positions of elements from textbox
	bg.y = textBox.y-textBox.height-15
	bg.initY = textBox.y
	maximize.y = bg.y+24
	messages.y = bg.y
	
	if not isSimulator then
		-- Turn off auto-correction, spell-checking and emojies on textBox
		keyboardEvents.setAutocorrectionType("UITextAutocorrectionTypeNo")
		keyboardEvents.setSpellCheckingType("UITextSpellCheckingTypeNo")
		keyboardEvents.setKeyboardTypeASCIICapable(true)
		keyboardEvents.setKeyboardAppearance("dark")
		
		-- Set iPhone X offset to compensate for safe area when moving corona view  
		if isIPhoneX then 
			keyboardEvents.setMoveViewOffsetY(bottomInset-5)
		end
	end

	-- Listen for keyboard events
	local function keyboardEventListener( e )

		local keyboardHeight = e.keyboardHeight*display.contentScaleY
		--print ( inspect(e))
		
		if e.phase == "willShow" then
			header:setCapture(true)
		elseif e.phase == "didShow" then
		elseif  e.phase == "willHide" then
		elseif  e.phase == "didHide" then
			header:setCapture(false)
		end
	end
	Runtime:addEventListener( "keyboardEvent", keyboardEventListener )	

	-- Listen for header tap events
	local function headerEventListener( e )
		--print ( inspect(e) )
		if e.phase == "tap" then
			local tapPosition = display.contentCenterX+(e.x*display.contentScaleY) -- Tap position in corona units
			print ( "tapPosition: "..tapPosition)
			if tapPosition > 300 then -- X button tapped
				native.setKeyboardFocus( nil )
				timer.performWithDelay( 400, function()  
					closeButtonHandler({phase="ended"})
				end )
			end
		end
	end
	Runtime:addEventListener( "headerEvent", headerEventListener )
end
 
 
-- show()
function scene:show( event )
 
    local g = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local g = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
    	native.setKeyboardFocus( nil )
    elseif ( phase == "did" ) then
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local g = self.view
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene
