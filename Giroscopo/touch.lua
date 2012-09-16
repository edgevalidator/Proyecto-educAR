-- touch.lua
-- 22:51

local im = getInputManager()
local scene = getCurrentScene()
local viewport = Viewport(scene:getObjectByName("viewport"))
local window = RenderWindow(scene:getMainView())
local touchscreen = nil
local touched = false
local mouse = nil

if isTouchScreenDeviceAvailable() then
	touchscreen = TouchScreen(im:getDevice(TIINPUT_TOUCHSCREENDEVICE))
	touchscreen:acquire()
else
	mouse = Mouse(im:getDevice(TIINPUT_MOUSEDEVICE))
end

repeat

	local action = ''

	isCommand, command = getComponentInterface():pullCommand()
	
	if isCommand then
	
		action = command["CommandName"]
		
	elseif (gtrackingStatus == 1) then			
		
		local obj = nil
		
		if touchscreen then
		
			local touches = touchscreen:getTouches()
			if (#touches > 0) then
				if not touched then
					local t = touches[1]
					obj = viewport:pick(t.position.x, t.position.y)
				end
				touched = true
			else
				touched = false
			end
			
		else
		
			if mouse:wasButtonReleased(TIMOUSE_RIGHTBUTTON) then
				LOG("rel")
				err, RWX, RWY = window:getLocalCursorCoordinates()
				obj = viewport:pick(RWX, RWY)
			end
			
		end
		
		if obj and not obj:isNull() then
			action = obj:getName()
		end
		
	end
	
	if not (action == '') then
		if action == 'boton_01' then
			show_model(1)
		elseif action == 'boton_02' then
			show_model(2)
		elseif action == 'boton_04' then
			show_model(4)
		elseif action == 'boton_notas' then
			show_notes()
		elseif action == 'boton_velocidadangular' then
			toggle_vector_group('velocidad_angular')
		elseif action == 'boton_momentoangular' then
			toggle_vector_group('momento_angular')
		elseif action == 'boton_torque' then
			toggle_vector_group('torque')
		elseif action == 'boton_fuerzas' then
			toggle_vector_group('fuerzas')
		elseif action == 'boton_vectores' then
			toggle_vectors()
		elseif action == 'boton_animaciones' then
			toggle_animations()
		elseif action == 'boton_direccion' then
			toggle_animation_direction()
		elseif action == 'boton_precesion' then
			toggle_precesion()
		end
	end

until coroutine.yield()