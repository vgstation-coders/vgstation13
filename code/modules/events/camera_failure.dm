//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/datum/event/camera_failure
	announceWhen = 500

/datum/event/camera_failure/setup()
	announceWhen = rand(250, 750)

/datum/event/camera_failure/announce()

	command_alert(/datum/command_alert/ion_storm_large) //Same as ion storm. It is AI-controlled equipment that failed, afterall

/datum/event/camera_failure/start()

	for(var/obj/machinery/camera/camera in cameranet.cameras)
		if(prob(camera.failure_chance))
			camera.triggerCameraAlarm()
			camera.deactivate()
