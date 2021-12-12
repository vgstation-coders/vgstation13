// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/camera/aiEye
	name = "Inactive AI Eye"
	anchored = TRUE

	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	var/high_res = 0
	glide_size = WORLD_ICON_SIZE //AI eyes are hyperspeed, who knows
	flags = HEAR_ALWAYS | TIMELESS

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/aiEye/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0)
	if(ai)
		if(!isturf(ai.loc))
			return
		var/turf/destination = NewLoc
		if(!isturf(NewLoc))
			destination = get_turf(NewLoc)

		forceEnter(destination)

		cameranet.visibility(src)
		if(ai.client && ai.client.eye != src) // Set the eye to us and give the AI the sight & visibility flags it needs.
			ai.client.eye = src
			ai.change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
			ai.see_in_dark = 8
			ai.see_invisible = SEE_INVISIBLE_LEVEL_TWO

		//Holopad
		if(istype(ai.current, /obj/machinery/hologram/holopad))
			var/obj/machinery/hologram/holopad/H = ai.current
			H.move_hologram()

		if(ai.camera_light_on)
			ai.light_cameras()

		if (ai.station_holomap)
			ai.station_holomap.update_holomap()

/mob/camera/aiEye/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	return 0

/mob/camera/aiEye/on_see(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message, atom/A) //proc for eye seeing visible messages from atom A, only possible with the high_res camera module
	if(!high_res)
		return
	if(ai && cameranet.checkCameraVis(A)) //check it's actually in view of a camera
		ai.show_message( message, 1, blind_message, 2)

//An AI eyeobj mob cant hear unless it updates high_res with a Malf Module
/mob/camera/aiEye/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(!high_res)
		return
	if(speech.frequency) //HOW CAN IT POSSIBLY READ LIPS THROUGH RADIOS
		return

	var/mob/M = speech.speaker
	if(istype(M))
		if(ishuman(M))
			var/mob/living/carbon/human/H = speech.speaker
			if(H.check_body_part_coverage(MOUTH)) //OR MASKS
				return
		ai.Hear(speech, rendered_speech) //He can only read the lips of mobs, I cant think of objects using lips


// AI MOVEMENT


/mob/living/silicon/ai/Destroy()
	if(eyeobj)
		eyeobj.ai = null
		qdel(eyeobj) // No AI, no Eye
		eyeobj = null
	..()

/atom/proc/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && AI.client.eye == AI.eyeobj)
			AI.cameraFollow = null
			//AI.eyeobj.forceMove(src)
			if (isturf(src.loc) || isturf(src))
				AI.eyeobj.forceMove(src)

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, var/mob/living/silicon/ai/user)

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			if (user.client.prefs.stumble && ((world.time - user.last_movement) > 4))
				user.delayNextMove(3)	//if set, delays the second step when a mob starts moving to attempt to make precise high ping movement easier
			user.eyeobj.forceMove(step)
	user.last_movement=world.time

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	user.cameraFollow = null

	//user.unset_machine() //Uncomment this if it causes problems.
	//user.lightNearbyCamera()

/mob/living/silicon/ai/proc/view_core()


	current = null
	cameraFollow = null
	unset_machine()

	if(!loc)
		return

	if(!eyeobj)
		make_eyeobj()
	else
		eyeobj.forceMove(loc)

	if(client && client.eye) // Reset these things so the AI can't view through walls and stuff.
		client.eye = src
		change_sight(removing = SEE_TURFS | SEE_MOBS | SEE_OBJS)
		see_in_dark = 0
		see_invisible = SEE_INVISIBLE_LIVING

	for(var/datum/camerachunk/c in eyeobj.visibleCameraChunks)
		c.remove(eyeobj)

/mob/living/silicon/ai/proc/make_eyeobj()
	eyeobj = new(loc)
	eyeobj.ai = src
	refresh_eyeobj_name()
	eyeobj.forceMove(loc)

/mob/living/silicon/ai/proc/refresh_eyeobj_name()
	eyeobj.name = "[name] (AI Eye)"

/mob/living/silicon/ai/proc/jump_to_area(var/area/A)
	if(!A)
		return
	if(!eyeobj)
		make_eyeobj()
	var/list/turfs = list()
	for(var/turf/T in A)
		turfs.Add(T)
	var/turf/T = pick(turfs)
	if(!T)
		to_chat(src, "<span class='danger'>Nowhere to jump to!</span>")
		return
	cameraFollow = null
	eyeobj.forceMove(T)

/mob/living/silicon/ai/proc/toggleholopadoverlays() //shows holopads above all static
	if (!holopadoverlays.len)
		for(var/obj/machinery/hologram/holopad/holopads in machines)
			var/image/holopadoverlay = image('icons/obj/stationobjs.dmi',holopads,"holopad0", ABOVE_HUD_PLANE)
			holopadoverlay.plane = ABOVE_HUD_PLANE
			if(client)
				client.images += holopadoverlay
				holopadoverlays += holopadoverlay
	else
		if(client)
			for(var/image/ol in holopadoverlays)
				client.images -= ol
			holopadoverlays.Cut()


/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")
