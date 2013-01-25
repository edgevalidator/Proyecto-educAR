-- touch.lua
-- 20:32

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
					obj = viewport:pick(t.position.x, t.position.y, false)
				end
				touched = true
			else
				touched = false
			end
			
		else
		
			if mouse:wasButtonReleased(TIMOUSE_RIGHTBUTTON) then
				err, RWX, RWY = window:getLocalCursorCoordinates()
				obj = viewport:pick(RWX, RWY, false)
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
		elseif action == 'boton_ecuaciones' then
			show_equations()
		elseif action == 'boton_nota_siguiente' then
			next_note()
		elseif action == 'boton_nota_anterior' then
			previous_note()
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
		elseif action == 'boton_videos' then
			show_videos()
		elseif action == 'boton_solucion' then
			show_solution()
		elseif action == 'boton_ejercicios' then
			show_excercises()
		elseif action == 'boton_ej_anterior' then
			previous_excercise()
		elseif action == 'boton_ej_siguiente' then
			next_excercise()
		elseif action == 'boton_videos_pp' then
			toggle_video_state()
		elseif action == 'solutions' then
			disclose_solution()
		else
			LOG(action)
		end
	end

until coroutine.yield()