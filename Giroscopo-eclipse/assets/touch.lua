local im = getInputManager()
local scene = getCurrentScene()
local viewport = Viewport(scene:getObjectByName("viewport"))
local window = RenderWindow(scene:getMainView())
local giroscopo_01 = Scenette(scene:getObjectByName("giroscopo_01"))
local giroscopo_02 = Scenette(scene:getObjectByName("giroscopo_02"))
local giroscopo_04 = Scenette(scene:getObjectByName("giroscopo_04"))
local touchscreen = nil
local mouse = nil

if isTouchScreenDeviceAvailable() then
	touchscreen = TouchScreen(im:getDevice(TIINPUT_TOUCHSCREENDEVICE))
	touchscreen:acquire()
else
	mouse = Mouse(im:getDevice(TIINPUT_MOUSEDEVICE))
end

repeat

	if (gtrackingStatus == 1) then			
		
		local obj = nil
		
		if touchscreen then
		
			local touches = touchscreen:getTouches()
			if (#touches > 0) then
				local t = touches[1]
				obj = viewport:pick(t.position.x, t.position.y)
			end
			
		else
		
			if mouse:wasButtonReleased(TIMOUSE_RIGHTBUTTON) then
				err, RWX, RWY = window:getLocalCursorCoordinates()
				obj = viewport:pick(RWX, RWY)
			end
			
		end
		
		if obj and not obj:isNull() then
			if obj:getName() == "boton_01" then
				if not giroscopo_01:getVisible() then
					giroscopo_01:setVisible(true)
				end
				if giroscopo_02:getVisible() then
					giroscopo_02:setVisible(false)
				end
				if giroscopo_04:getVisible() then
					giroscopo_04:setVisible(false)
				end
			elseif obj:getName() == "boton_02" then
				if not giroscopo_02:getVisible() then
					giroscopo_02:setVisible(true)
				end
				if giroscopo_01:getVisible() then
					giroscopo_01:setVisible(false)
				end
				if giroscopo_04:getVisible() then
					giroscopo_04:setVisible(false)
				end
				local animation = giroscopo_02:getAnimation(0)
				if not animation:isPlaying() then
					animation:play(0)
					animation:setLoop(true)
				end
			elseif obj:getName() == "boton_04" then
				if not giroscopo_04:getVisible() then
					giroscopo_04:setVisible(true)
				end
				if giroscopo_01:getVisible() then
					giroscopo_01:setVisible(false)
				end
				if giroscopo_02:getVisible() then
					giroscopo_02:setVisible(false)
				end
				local animation = giroscopo_04:getAnimation(0)
				if not animation:isPlaying() then
					animation:play(0)
					animation:setLoop(true)
				end				
			end
		end
		
	end

until coroutine.yield()