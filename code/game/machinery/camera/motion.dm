/obj/machinery/motion_sensor
	name = "motion sensor"
	desc = "An ugly little thing that sets off alarms whenever it senses movement."

	icon = 'icons/obj/monitors.dmi'
	icon_state = "motion"

	var/list/motionTargets = list()
	var/detectTime = 0
	var/area/area_motion = null
	var/alarm_delay = 100 // Don't forget, there's another 10 seconds in queueAlarm()

	var/alarming=0
	flags = FPRINT | PROXMOVE

/obj/machinery/motion_sensor/process()
	// Check for motion capability was here.
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > alarm_delay)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/mob/target in motionTargets)
			if (target.stat == 2) lostTarget(target)
			// If not detecting with motion camera...
			if (!area_motion)
				// See if the camera is still in range
				if(!in_range(src, target))
					// If they aren't in range, lose the target.
					lostTarget(target)

/obj/machinery/motion_sensor/proc/newTarget(var/mob/target)
	if (istype(target, /mob/living/silicon/ai))
		return 0
	if (detectTime == 0)
		detectTime = world.time // start the clock
	if (!(target in motionTargets))
		motionTargets += target
	return 1

/obj/machinery/motion_sensor/proc/lostTarget(var/mob/target)
	if (target in motionTargets)
		motionTargets -= target
	if (motionTargets.len == 0)
		cancelAlarm()

/obj/machinery/motion_sensor/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/mob/living/silicon/aiPlayer in player_list)
			if (alarming)
				aiPlayer.cancelAlarm("Motion", areaMaster)
	detectTime = 0
	return 1

/obj/machinery/motion_sensor/proc/triggerAlarm()
	if (!detectTime) return 0
	for (var/mob/living/silicon/aiPlayer in player_list)
		if (alarming)
			aiPlayer.triggerAlarm("Motion", areaMaster, src)
	detectTime = -1
	return 1

/obj/machinery/motion_sensor/HasProximity(atom/movable/AM as mob|obj)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if (!area_motion)
		if(isliving(AM))
			newTarget(AM)

