-- -------------------------------------------------------------------------------
--
--  ExpandingTextBox - extends native.newTextBox
--  Created by Jacob Nielsen on 01/12/2017.
--
-- -------------------------------------------------------------------------------

local isSimulator = "simulator" == system.getInfo("environment")
local round = math.round

-- Width/height tweak values
local heightOffset = isSimulator and 1.22 or 1.004
local widthOffset = 8

-- Get height from dummy bitmap text
local function getHeight(t)

	local options =
	{
		text = t.text,
		width = t.width-widthOffset, 
		font = t.font,
		fontSize = t.size,
	}
	
	local dummy = display.newText( options )
	
	local height = (dummy.height*heightOffset)
	dummy:removeSelf()
	dummy = nil
	
	t._deviceOffset = isSimulator and 0 or t.size
	
	return height+t._deviceOffset
end

-- Create new instance
function native.newExpandingTextBox(...)

 	local textBox = native.newTextBox(...) 
 	
	-- Prevent console warning noise in simulator
	if isSimulator then
		textBox.setNativeProperty = function() end
	end
 	
	-- Default values
	textBox.maxLines = textBox.maxLines or 4 				-- maximum 4 lines 
	textBox.isLocked = textBox.isLocked or false 			-- expand active
	textBox.transitionTime = textBox.transitionTime or 50	-- expand one line transition time
	
	textBox.isFontSizeScaled = true
	textBox:setNativeProperty( "scrollEnabled", false )

	timer.performWithDelay( 1, function() 
		
		-- Calculate initial height from font size
		local textBoxText = textBox.text
		textBox.text = " "
		textBox.height = getHeight(textBox)
		textBox._lineHeight = textBox.height-textBox._deviceOffset
		textBox.text = textBoxText
		
		if isSimulator then textBox.maxLines = textBox.maxLines-1 end
		
		local maxHeight = (textBox.maxLines*textBox._lineHeight)-textBox._deviceOffset
		
		-- Workaround for centering text in box
		native.setKeyboardFocus( textBox )
		native.setKeyboardFocus( nil )
		
		-- Update size when editing text
		textBox:addEventListener("userInput", function(e)
			if not textBox.isLocked then
				if e.phase == "editing" then
				
					local t = e.target
					local newHeight = getHeight(t)
			
					if round(newHeight) ~= round(t.height) then
						if newHeight <= maxHeight then
							t:setNativeProperty( "scrollEnabled", false )
							t:dispatchEvent({name="userInput", phase="resize", height=newHeight, target=t})
                            transition.to(t, {time=t.transitionTime, height=newHeight})
						else
							if round(t.height) ~= round(maxHeight+t._deviceOffset) then
								transition.to(t, {time=t.transitionTime, height=maxHeight+t._deviceOffset})
								t:dispatchEvent({name="userInput", phase="resize", height=maxHeight+t._deviceOffset, target=t})
								t:setNativeProperty( "scrollEnabled", true )
							end
						end
					end
				end
			end
		end )
	end )
	
	-- Lock text box size (for maximize textbox feature )
	function textBox:setLocked(enabled)
		self.isLocked = enabled
		if enabled then
			self:setNativeProperty( "scrollEnabled", true )
		else
			local height = getHeight(self)
			local maxHeight = (self.maxLines*self._lineHeight)-self._deviceOffset
			
			if height <= maxHeight then
				self:setNativeProperty( "scrollEnabled", false )
			else
				t:setNativeProperty( "scrollEnabled", true )
			end
		end
	end
	
	-- Clear text
	function textBox:clear()
		self.text = ""
		self:dispatchEvent({name="userInput", phase="editing", target=self})
	end

	return textBox
end

