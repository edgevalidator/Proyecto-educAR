-- giroscopo.lua







Giroscopo = { name = '' , animated = false, direction = 'counterclockwise', precesion = 'quick' }







function Giroscopo:new(o)



	o = o or {}



	setmetatable(o, self)



	self.__index = self



	o:loadModel()



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



		LOG(obj_name)



		local obj = Scenette(getCurrentScene():getObjectByName(obj_name))



		local animation = obj:getAnimation(0)



		if not animation:isNull() then



			if animation:isPaused() then



				LOG("paused")



				animation:resume()



			elseif animation:isPlaying() then



				LOG("playing")



				animation:pause()



			else



				LOG("stopped")



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



	



	if self:getPrecesion() == 'quick' then



		f(self:getNameForAnimatedModel(true, true))



		f(self:getNameForAnimatedModel(false, true))



		



		if self:getDirection() == 'clockwise' then



			self:setDirection('counterclockwise')



		else



			self:setDirection('clockwise')



		end



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



		animated_model:setVisible(((clockwise and self:getDirection() == 'clockwise') or (not clockwise and self:getDirection() == 'counterclockwise')) and ((quick and self:getPrecesion() == 'quick') or (not quick and self:getPrecesion() == 'slow')))



		



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











--  ECUACIONES







Ecuaciones = { }







function Ecuaciones:new(o)



	o = o or {}



	setmetatable(o, self)



	self.__index = self



	o:loadModel()



	return o



end







function Ecuaciones:getNameForModel()



	return "equations"



end







function Ecuaciones:setVisibility(visibility)







	local model_name = self:getNameForModel()



	local model = Scenette(getCurrentScene():getObjectByName(model_name))



	model:setVisible(visibility)



	



end







function Ecuaciones:loadModel()







	local scene = getCurrentScene()



	local ref = Object3D(scene:getObjectByName("ref"))



	



	local model = Scenette(scene:createObject(CID_SCENETTE))



	ref:addChild(model)



	model:setName(self:getNameForModel())



	model:setResource("ecuaciones/ecuaciones.scene")	



	model:setVisible(false)



	model:setOrientationEuler(90.0, 0.0, 0.0)



	model:setScale(0.245)



	



end







--  NOTAS







Notas = { length = 1, current = 1 }




function Notas:new(o)



	o = o or {}



	setmetatable(o, self)



	self.__index = self



	o:loadModel()



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







function Notas:isVisible()







	local model_name = self:getNameForModel()



	local model = Scenette(getCurrentScene():getObjectByName(model_name))



	return model:getVisible()







end







function Notas:showPrevious()







	if self.length > 0 then



		self.current = self.current - 1



	end



	



	if self.current < 1 then



		self.current = self.length



	end







	self:changeMaterial(self.current)



	



end







function Notas:showNext()







	if self.length > 0 then



		self.current = self.current + 1



	end



	



	if self.current > self.length then



		self.current = 1



	end



	



	self:changeMaterial(self.current)







end







function Notas:changeMaterial(i)







	local scene = getCurrentScene()



	



	local texture = Texture(scene:createObject(CID_TEXTURE))



	texture:setResource("notas/nota/nota_" .. i .. ".png")



	



	local material = getMaterial("nota/Material26")



	material:setTexture(texture)







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



	



	if self.length > 0 then



		self:changeMaterial(self.current)



	end



	



end











-- BOTONES







Boton = { id = "", filename = "" }







function Boton:new(o)



	o = o or {}



	setmetatable(o, self)



	self.__index = self



	o:loadModel()



	return o



end







function Boton:getNameForModel()



	return self.id



end







function Boton:playAnimation(state)



	



	local obj = Scenette(getCurrentScene():getObjectByName(self:getNameForModel()))



	local animation = obj:getAnimation(0)



	if not animation:isNull() then



		if ((state == "on") and (animation:getTimePosition() == 0 or animation:getTimePosition() == 1)) then



			animation:play(0,0.5)			



		elseif ((state == "off") and (animation:getTimePosition() == 0.5)) then



			animation:play(0.5,1)



		elseif (not state == "on" and not state == "off") then



			-- Esto se da en botones que bajan y suben en seguida



			animation:play(0,0.5)



		end



	end



		



end







function Boton:switchAnimation()







	local obj = Scenette(getCurrentScene():getObjectByName(self:getNameForModel()))



	local animation = obj:getAnimation(0)



	



	if not animation:isNull() then



		if animation:getTimePosition() == 0 or animation:getTimePosition() == 1 then



			animation:play(0,0.5)			



		else



			animation:play(0.5,1)



		end



	end



	



end







function Boton:loadModel()







	local scene = getCurrentScene()



	local ref = Object3D(scene:getObjectByName("ref"))



	



	local model = Scenette(scene:createObject(CID_SCENETTE))



	ref:addChild(model)



	model:setName(self:getNameForModel())



	model:setResource("tablero/" .. self.filename .. "/" .. self.filename .. ".scene")	



	model:setVisible(true)



	model:setOrientationEuler(90.0, 0.0, 0.0)



	model:setPosition(0.0, -10.0, 0.0)



	model:setScale(0.300)



end







-- CONTROL



UScenette = {}







function UScenette:new(o)



	o = o or {}



	setmetatable(o, self)



	self.__index = self



	return o



end







function loadTablero()



	local scene = getCurrentScene()



	local ref = Object3D(scene:getObjectByName("ref"))



	



	local model = Scenette(scene:createObject(CID_SCENETTE))



	ref:addChild(model)



	model:setName("tablero")



	model:setResource("tablero/tablero/tablero.scene")	



	model:setVisible(true)



	model:setOrientationEuler(90.0, 0.0, 0.0)



	model:setPosition(0.0, -10.0, 0.0)



	model:setScale(0.300)



end







loadTablero()







local giroscopo_01 = Giroscopo:new{name="giroscopo_01", animated=false}



local giroscopo_02 = Giroscopo:new{name="giroscopo_02", animated=true}



local giroscopo_04 = Giroscopo:new{name="giroscopo_04", animated=true}



local notas = Notas:new{}



local ecuaciones = Ecuaciones:new{}







local boton_01 = Boton:new{id="boton_01", filename="btn_g01" }



local boton_02 = Boton:new{id="boton_02", filename="btn_g02" }



local boton_04 = Boton:new{id="boton_04", filename="btn_g03" }



local boton_e01 = Boton:new{id="boton_ej1", filename="btn_e01" }



local boton_e02 = Boton:new{id="boton_ej2", filename="btn_e02" }



local boton_vectores = Boton:new{id="boton_vectores", filename="llave_Vectores" }



local boton_notas = Boton:new{id="boton_notas", filename="btn_Notas" }



local boton_videos = Boton:new{id="boton_videos", filename="btn_Videos" }



local boton_nota_siguiente = Boton:new{id="boton_nota_siguiente", filename="btn_Next" }



local boton_nota_anterior = Boton:new{id="boton_nota_anterior", filename="btn_Back"}



local boton_animaciones = Boton:new{id="boton_animaciones", filename="btn_PlayPause" }



local boton_ecuaciones = Boton:new{id="boton_ecuaciones", filename="btn_Ecuaciones" }



local boton_precesion = Boton:new{id="boton_precesion", filename="btn_Velocidad" }



local boton_direccion = Boton:new{id="boton_direccion", filename="btn_Sentido" }



local boton_velocidadangular = Boton:new{id="boton_velocidadangular", filename="llave_Velocidad"}



local boton_momentoangular = Boton:new{id="boton_momentoangular", filename="llave_Momento"}



local boton_torque = Boton:new{id="boton_torque", filename="llave_Torque"}



local boton_fuerzas = Boton:new{id="boton_fuerzas", filename="llave_Fuerzas"}











function show_model(option)



	if option == 1 then



		boton_01:playAnimation("on")



		boton_02:playAnimation("off")



		boton_04:playAnimation("off")



		giroscopo_01:setVisibility(true)



		giroscopo_02:setVisibility(false)



		giroscopo_04:setVisibility(false)



	elseif option == 2 then	



		boton_01:playAnimation("off")



		boton_02:playAnimation("on")



		boton_04:playAnimation("off")



		giroscopo_01:setVisibility(false)



		giroscopo_02:setVisibility(true)



		giroscopo_04:setVisibility(false)



	elseif option == 4 then	



		boton_01:playAnimation("off")



		boton_02:playAnimation("off")



		boton_04:playAnimation("on")



		giroscopo_01:setVisibility(false)



		giroscopo_02:setVisibility(false)



		giroscopo_04:setVisibility(true)



	end



	boton_notas:playAnimation("off")



	boton_ecuaciones:playAnimation("off")



	notas:setVisibility(false)



	ecuaciones:setVisibility(false)



end







function show_notes()



	boton_01:playAnimation("off")



	boton_02:playAnimation("off")



	boton_04:playAnimation("off")



	boton_notas:playAnimation("on")



	boton_ecuaciones:playAnimation("off")



	giroscopo_01:setVisibility(false)



	giroscopo_02:setVisibility(false)



	giroscopo_04:setVisibility(false)



	ecuaciones:setVisibility(false)



	notas:setVisibility(true)



end







function show_equations()



	boton_01:playAnimation("off")



	boton_02:playAnimation("off")



	boton_04:playAnimation("off")



	boton_notas:playAnimation("off")



	boton_ecuaciones:playAnimation("on")



	giroscopo_01:setVisibility(false)



	giroscopo_02:setVisibility(false)



	giroscopo_04:setVisibility(false)



	ecuaciones:setVisibility(true)



	notas:setVisibility(false)



end







function next_note()



	boton_nota_siguiente:playAnimation()



	notas:showNext()



end







function previous_note()



	boton_nota_anterior:playAnimation()



	notas:showPrevious()



end







function toggle_animations()



	boton_animaciones:switchAnimation()



	giroscopo_02:switchAnimationState()



	giroscopo_04:switchAnimationState()



end







function toggle_vectors()



	boton_vectores:switchAnimation()



	giroscopo_02:switchVectorsVisibility()



	giroscopo_04:switchVectorsVisibility()



end







function toggle_vector_group(group)



	if group == 'velocidad_angular' then



		boton_velocidadangular:switchAnimation()	



	elseif group == 'momento_angular' then



		boton_momentoangular:switchAnimation()



	elseif group == 'torque' then



		boton_torque:switchAnimation()



	elseif group == 'fuerzas' then



		boton_fuerzas:switchAnimation()



	end



	giroscopo_02:switchVectorGroupVisibility(group)



	giroscopo_04:switchVectorGroupVisibility(group)



end







function toggle_animation_direction()



	boton_direccion:switchAnimation()



	giroscopo_02:switchAnimationDirection()



	giroscopo_04:switchAnimationDirection()



end







function toggle_precesion()



	boton_precesion:switchAnimation()



	giroscopo_02:switchPrecesion()



	giroscopo_04:switchPrecesion()



end