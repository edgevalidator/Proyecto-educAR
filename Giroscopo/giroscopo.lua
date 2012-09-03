-- giroscopo.lua
-- 22:51

Giroscopo = { name = '' , animated = false, direction = 'counterclockwise', precesion = 'quick' }

function Giroscopo:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Giroscopo:getName()
	return self.name
end

function Giroscopo:getAnimated()
	return self.animated
end

function Giroscopo:getAnimated()
	return self.animated
end

function Giroscopo:getDirection()
	return self.direction
end

function Giroscopo:setDirection(value)
	self.direction = value
end

function Giroscopo:getPrecesion()
	return self.precesion
end

function Giroscopo:setPrecesion(value)
	self.precesion = value
end

function Giroscopo:getNameForModel()
	return "model-" .. self:getName()
end

function Giroscopo:getNameForStaticModel()
	return "static-" .. self:getName()
end

function Giroscopo:getNameForAnimatedModel(clockwise, quick)
	local aux = "animated-"
	if clockwise then
		aux = aux .. "clockwise-"
	else
		aux = aux .. "counterclockwise-"
	end
	if quick then
		aux = aux .. "quick-"
	else
		aux = aux .. "slow-"
	end
	return aux .. self:getName()
end

function Giroscopo:getNameForVectors(clockwise, quick)
	local aux = "vectors-"
	if clockwise then
		aux = aux .. "clockwise-"
	else
		aux = aux .. "counterclockwise-"
	end
	if quick then
		aux = aux .. "quick-"
	else
		aux = aux .. "slow-"
	end
	return aux .. self:getName()
end

function Giroscopo:getNameForVectorGroup(clockwise, quick, group_name)
	local aux = "vectorgroup-"
	if clockwise then
		aux = aux .. "clockwise-"
	else
		aux = aux .. "counterclockwise-"
	end
	if quick then
		aux = aux .. "quick-"
	else
		aux = aux .. "slow-"
	end
	return aux .. self:getName() .. "-" .. group_name
end

function Giroscopo:setVisibility(visibility)

	local model_name = self:getNameForModel()
	local model = Object3D(getCurrentScene():getObjectByName(model_name))
	model:setVisible(visibility)
	
end

function Giroscopo:switchVectorsVisibility()

	local f = function(obj_name)
		obj = Object3D(getCurrentScene():getObjectByName(obj_name))
		if obj:getVisible() then
			obj:setVisible(false)
		else
			obj:setVisible(true)
		end
	end

	f(self:getNameForVectors(true, true))
	f(self:getNameForVectors(false, true))
	f(self:getNameForVectors(false, false))
	
end

function Giroscopo:switchVectorGroupVisibility(group)

	local f = function(obj_name)
		local obj = Scenette(getCurrentScene():getObjectByName(obj_name))
		if obj:getVisible() then
			obj:setVisible(false)
		else
			obj:setVisible(true)
		end
	end

	f(self:getNameForVectorGroup(true, true, group))
	f(self:getNameForVectorGroup(false, true, group))
	f(self:getNameForVectorGroup(false, false, group))
	
end

function Giroscopo:switchAnimationState()

	local f = function(obj_name)
		local obj = Scenette(getCurrentScene():getObjectByName(obj_name))
		local animation = obj:getAnimation(0)
		if not animation:isNull() then
			if animation:isPlaying() then
				animation:pause()
			elseif animation:isPaused() then
				animation:resume()
			else
				animation:play()
				animation:setLoop(true)
			end
		end
	end
	
	f(self:getNameForAnimatedModel(true, true))
	f(self:getNameForAnimatedModel(false, true))
	f(self:getNameForAnimatedModel(false, false))
	
	local aux = { "momento_angular", "velocidad_angular", "fuerzas", "torque" }
	for i = 1, 4 do
		f(self:getNameForVectorGroup(true, true, aux[i]))
		f(self:getNameForVectorGroup(false, true, aux[i]))
		f(self:getNameForVectorGroup(false, false, aux[i]))
	end
	
end

function Giroscopo:switchAnimationDirection()

	local f = function(obj_name)
		local obj = Scenette(getCurrentScene():getObjectByName(obj_name))
		if obj:getVisible() then
			obj:setVisible(false)
		else
			obj:setVisible(true)
		end
	end
	
	f(self:getNameForAnimatedModel(true, true))
	f(self:getNameForAnimatedModel(false, true))
	
	if self:getDirection() == 'clockwise' then
		self:setDirection('counterclockwise')
	else
		self:setDirection('clockwise')
	end
	
end

function Giroscopo:switchPrecesion()

	local h = function(obj_name)
		local obj = Scenette(getCurrentScene():getObjectByName(obj_name))
		obj:setVisible(false)
	end
	
	local s = function(obj_name)
		local obj = Scenette(getCurrentScene():getObjectByName(obj_name))
		obj:setVisible(true)
	end
	
	if(self:getPrecesion() == 'quick') then
		h(self:getNameForAnimatedModel(true, true))
		h(self:getNameForAnimatedModel(false, true))
		s(self:getNameForAnimatedModel(false, false))
		self:setPrecesion('slow');
	else
		if(self:getDirection() == 'clockwise') then
			s(self:getNameForAnimatedModel(true, true))
			h(self:getNameForAnimatedModel(false, true))
		else
			h(self:getNameForAnimatedModel(true, true))
			s(self:getNameForAnimatedModel(false, true))		
		end
		h(self:getNameForAnimatedModel(false, false))	
		self:setPrecesion('quick');
	end
	
end

function Giroscopo:loadModel()
	local scene = getCurrentScene()
	local ref = Object3D(scene:getObjectByName("ref"))
	
	local model = Object3D(scene:createObject(CID_OBJECT3D))
	ref:addChild(model)
	model:setName(self:getNameForModel())
	model:setVisible(false)
	model:setOrientationEuler(90.0, 0.0, 0.0)
	
	local fLoadStaticModel = function(model)
		local static_model = Scenette(scene:createObject(CID_SCENETTE))	
		model:addChild(static_model)
		static_model:setName(self:getNameForStaticModel())
		static_model:setResource("modelos/" .. self:getName() .. "/" .. self:getName() .. ".scene")	
		static_model:setVisible(true)
	end
	
	local fLoadAnimatedModel = function(model, clockwise, quick)
		local animated_model = Scenette(scene:createObject(CID_SCENETTE))
		model:addChild(animated_model)
		animated_model:setName(self:getNameForAnimatedModel(clockwise, quick))
		local resource = "modelos/" .. self:getName() .. "/"
		if clockwise then
			resource = resource .. "horario/"
		else
			resource = resource .. "antihorario/"
		end
		if quick then
			resource = resource .. "rapido/"
		else
			resource = resource .. "lento/"
		end
		resource = resource .. self:getName() .. "/" .. self:getName() .. ".scene"
		animated_model:setResource(resource)
		animated_model:setVisible(clockwise and self:getDirection() == 'clockwise' and quick and self:getPrecesion() == 'quick')
		
		-- Load vectors
		local vectors = Object3D(scene:createObject(CID_OBJECT3D))
		animated_model:addChild(vectors)
		vectors:setName(self:getNameForVectors(clockwise, quick))
		vectors:setVisible(false)
		vectors:setOrientationEuler(90.0, 0.0, 0.0)
		
		-- Load vector groups
		local aux = { "momento_angular", "velocidad_angular", "fuerzas", "torque" }
		for i = 1, 4 do
			local vector_group = Scenette(scene:createObject(CID_SCENETTE))
			vectors:addChild(vector_group)
			vector_group:setName(self:getNameForVectorGroup(clockwise, quick, aux[i]))
			local resource = "modelos/" .. self:getName() .. "/"
			if clockwise then
				resource = resource .. "horario/"
			else
				resource = resource .. "antihorario/"
			end
			if quick then
				resource = resource .. "rapido/"
			else
				resource = resource .. "lento/"
			end
			resource = resource .. aux[i] .. "/" .. aux[i] .. ".scene"
			vector_group:setResource(resource)
			vector_group:setVisible(true)		
		end
	end
	
	if not self:getAnimated() then
		fLoadStaticModel(model)
	else
		fLoadAnimatedModel(model, true, true)
		fLoadAnimatedModel(model, false, true)
		fLoadAnimatedModel(model, false, false)
	end
	
end

--  NOTAS

Notas = { length = 0 }

function Notas:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Notas:getNameForModel()
	return "notes"
end

function Notas:setVisibility(visibility)

	local model_name = self:getNameForModel()
	local model = Scenette(getCurrentScene():getObjectByName(model_name))
	model:setVisible(visibility)
	
end

function Notas:showPrevious()

end

function Notas:showNext()

end

function Notas:loadModel()

	local scene = getCurrentScene()
	local ref = Object3D(scene:getObjectByName("ref"))
	
	local model = Scenette(scene:createObject(CID_SCENETTE))
	ref:addChild(model)
	model:setName(self:getNameForModel())
	model:setResource("notas/nota/nota.scene")	
	model:setVisible(false)
	model:setOrientationEuler(90.0, 0.0, 0.0)
	model:setScale(0.245)
	
end


-- CONTROL

local giroscopo_01 = Giroscopo:new{name="giroscopo_01", animated=false}
local giroscopo_02 = Giroscopo:new{name="giroscopo_02", animated=true}
local giroscopo_04 = Giroscopo:new{name="giroscopo_04", animated=true}
local notas = Notas:new{length=0}

giroscopo_01:loadModel()
giroscopo_02:loadModel()
giroscopo_04:loadModel()
notas:loadModel()

function show_model(option)
	if option == 1 then
		giroscopo_01:setVisibility(true)
		giroscopo_02:setVisibility(false)
		giroscopo_04:setVisibility(false)
	elseif option == 2 then	
		giroscopo_01:setVisibility(false)
		giroscopo_02:setVisibility(true)
		giroscopo_04:setVisibility(false)
	elseif option == 4 then	
		giroscopo_01:setVisibility(false)
		giroscopo_02:setVisibility(false)
		giroscopo_04:setVisibility(true)
	end
	notas:setVisibility(false)
end

function show_notes()
	giroscopo_01:setVisibility(false)
	giroscopo_02:setVisibility(false)
	giroscopo_04:setVisibility(false)
	notas:setVisibility(true)
end

function toggle_animations()
	giroscopo_02:switchAnimationState()
	giroscopo_04:switchAnimationState()
end

function toggle_vectors()
	giroscopo_02:switchVectorsVisibility()
	giroscopo_04:switchVectorsVisibility()
end

function toggle_vector_group(group)
	giroscopo_02:switchVectorGroupVisibility(group)
	giroscopo_04:switchVectorGroupVisibility(group)
end

function toggle_animation_direction()
	giroscopo_02:switchAnimationDirection()
	giroscopo_04:switchAnimationDirection()
end

function toggle_precesion()
	giroscopo_02:switchPrecesion()
	giroscopo_04:switchPrecesion()
end