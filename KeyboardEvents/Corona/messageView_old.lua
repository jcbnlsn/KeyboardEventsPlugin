-- -------------------------------------------------------------------------------
--
--  messageView.lua - Corona
--  Created by jcb on 13/12/2017.
--
-- -------------------------------------------------------------------------------

local widget = require "widget"
local inspect = require "inspect"
local abs = math.abs

local _M = {}

function _M.new()

	local widget = require( "widget" )
	
	local messages = {}
	local scrollView
	
	-- Dismiss keyboard if tap on scrollview
	local function scrollListener(e)
		if e.phase == "ended" then
			if abs(e.xStart-e.x) < 5 and abs(e.yStart-e.y) < 5 then
				native.setKeyboardFocus( nil )
			end
		end
	end
 
	scrollView = widget.newScrollView(
		{
			width = display.contentWidth-(2*display.screenOriginX),
			height = display.contentHeight-(2*display.screenOriginY),
			scrollWidth = 600,
			scrollHeight = 800,
			listener = scrollListener
		}
	)
	scrollView.x = display.contentCenterX
	scrollView.anchorY = 1
	
	function scrollView:addMessage(text)
		
		local g = display.newGroup()
		
		-- Avatar image
		local avatar = display.newImage( g, "assets/avatar.png" )
		avatar:scale(.6,.6)
		avatar.anchorX, avatar.anchorY = 0, 0
		avatar.x, avatar.y = 10, 20
		
		local name = display.newText( g, "Tom Price", avatar.x+(avatar.width/2)+17, avatar.y-2, "Lato-Bold", 15 )
		name.anchorX, name.anchorY = 0, 0
		name:setFillColor(0)
		
		local options = {
			parent = g,
			text = text,
			x = name.x, y = name.y+20,
			width = display.contentWidth-avatar.width-20,
			font = "Lato-regular",
			fontSize = 13.5
		}
		
		local message = display.newText( options )
		message.anchorX, message.anchorY = 0, 0
		message:setFillColor(0)
		g.alpha = 0.01
		g:insert(message)
		self:insert(g)

		local posY = display.contentHeight-(2*display.screenOriginY)-(g.height)-30
		self:setScrollHeight(self:getView().height)
		
		for i=1, #messages do
			local _y = messages[i].y
			local offsetY = (g.height/2)+(messages[#messages].height/2)
			transition.to(messages[i], {time=200, y=_y-g.height-10})
		end
		
		transition.to(g, {time=150, delay=250, alpha=1})
		messages[#messages+1] = g
		g.y = posY
	end
	
	return scrollView
end

return _M
