local scene = getCurrentScene()
local giroscopo_01 = Scenette(scene:getObjectByName("giroscopo_01"))
local giroscopo_02 = Scenette(scene:getObjectByName("giroscopo_02"))
local giroscopo_04 = Scenette(scene:getObjectByName("giroscopo_04"))
local giroscopo_04_velocidadangular = Scenette(scene:getObjectByName("giroscopo_04_velocidadangular"))
local giroscopo_04_momentoangular = Scenette(scene:getObjectByName("giroscopo_04_momentoangular"))
local giroscopo_04_torque = Scenette(scene:getObjectByName("giroscopo_04_torque"))
local giroscopo_04_fuerzas = Scenette(scene:getObjectByName("giroscopo_04_fuerzas"))
local giroscopo_04_vectores = Object3D(scene:getObjectByName("giroscopo_04_vectores"))

function load_model(option)
	if option == 1 then
		_show(giroscopo_01)
		_hide(giroscopo_02)
		_hide(giroscopo_04)		
	elseif option == 2 then	
		_hide(giroscopo_01)
		_show(giroscopo_02)
		_hide(giroscopo_04)		
	elseif option == 4 then	
		_hide(giroscopo_01)
		_hide(giroscopo_02)
		_show(giroscopo_04)		
	end	
end

function toggle_animations()
	_switch_animation_state(giroscopo_02:getAnimation(0))
	_switch_animation_state(giroscopo_04:getAnimation(0))
	_switch_animation_state(giroscopo_04_velocidadangular:getAnimation(0)) 
	_switch_animation_state(giroscopo_04_momentoangular:getAnimation(0)) 
	_switch_animation_state(giroscopo_04_torque:getAnimation(0)) 
	_switch_animation_state(giroscopo_04_fuerzas:getAnimation(0)) 
end

function toggle_vectors()
	_switch_visibility(giroscopo_04_vectores)
end

function toggle_vector_group(group)
	if group == 'velocidad_angular' then
		_switch_visibility(giroscopo_04_velocidadangular)
	elseif group == 'momento_angular' then
		_switch_visibility(giroscopo_04_momentoangular)
	elseif group == 'fuerzas' then
		_switch_visibility(giroscopo_04_fuerzas)
	elseif group == 'torque' then
		_switch_visibility(giroscopo_04_torque)
	end
end

function _switch_animation_state(animation)
	if animation:isPlaying() then
		animation:pause()
	elseif animation:isPaused() then
		animation:resume()
	else
		animation:play()
		animation:setLoop(true)
	end
end

function _show(object)
	if not object:getVisible() then
		object:setVisible(true)
	end		
end

function _hide(object)
	if object:getVisible() then
		object:setVisible(false)
	end		
end

function _switch_visibility(object)
	if object:getVisible() then
		object:setVisible(false)
	else
		object:setVisible(true)
	end
end