-- GLOBAL VARIABLES
-- tracking statuts: if 1 : tracking, if 0 : no tracking
gtrackingStatus = 0
-- get the keyframe index from a tracked object with auto-initialization
gtrackingKeyFrameIndex = -1

-- scene
local scene = getCurrentScene()
-- get the virtual camera, will be used to send to the MLT
local camera = Camera(scene:getCurrentCamera())
-- get the videocapture, will be used to send to the MLT
local vidCap = VideoCapture(scene:getObjectByName("vidCap"))

-- Tracking
local MLTPlugin = getMLTPluginManager()
-- Error status
local errorStatus = eOk
-- tracking index : the index of the tracker.xml (because we can open more than 1 tracking.xml file).
local trackingIndex = -1
-- the fps of the Tracking engine
local trackingRate = 0
-- vector to put the tracking position
local trackingPosition = Vector3()
-- quaternion to put the tracking orientation
local trackingOrientation = Quaternion()
-- 3D object receiving tracking pose
local trackingObject = Object3D(scene:getObjectByName("ref"))
-- object index from the tracking scenario (0 : first object, 1 : second object...) (this is the index in the "Objects" panel of the CV GUI)
local trackingObjectIndex = 0

-- this is how to start a tracking. the function needs the path to the tracker.xml file, the videocapture id and the camera object.
errorStatus, trackingIndex = MLTPlugin:startTracking("tracker/tracker.xml", vidCap:getVidCapID(), camera)

-- if the tracking has correctly started, we can proceed to an infinite loop
if errorStatus == eOk then
	repeat

	    errorStatus, gtrackingStatus = MLTPlugin:getTargetStatus(trackingIndex, trackingObjectIndex)
		
		errorStatus, gtrackingKeyFrameIndex = MLTPlugin:getRecognizedKeyFrameIndex(trackingIndex, trackingObjectIndex)

		-- if our object is detected...
	    if (gtrackingStatus == 1) then
			--...we can get the position and set it to the "father" object
	        MLTPlugin:getTargetPos(trackingIndex, trackingObjectIndex, trackingPosition, trackingOrientation)
			trackingObject:setPosition(trackingPosition, camera)
	        trackingObject:setOrientation(trackingOrientation, camera)
			-- we change the visibility of the main "father" object
			if not trackingObject:getVisible() then
				trackingObject:setVisible(true)
			end
		else
			if trackingObject:getVisible() then
				trackingObject:setVisible(false)
			end
	    end

	until coroutine.yield()
end