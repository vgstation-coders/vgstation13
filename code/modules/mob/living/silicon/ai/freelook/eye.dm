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

/mob/camera/aiEye/forceMove(var/atom/destination)
	if(ai)
		if(!isturf(ai.loc))
			return
		if(!isturf(destination))
			for(destination = destination.loc; !isturf(destination); destination = destination.loc);
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
	if (user.camera_light_on)
		user.light_cameras()

/mob/living/silicon/ai/proc/view_core()


	current = null
	cameraFollow = null
	unset_machine()

	if(src.eyeobj && src.loc)
		//src.eyeobj.loc = src.loc
		src.eyeobj.forceMove(src.loc)
	else
		src.eyeobj = new(src.loc)
		src.eyeobj.ai = src
		src.eyeobj.name = "[src.name] (AI Eye)" // Give it a name
		src.eyeobj.forceMove(src.loc)

	if(client && client.eye) // Reset these things so the AI can't view through walls and stuff.
		client.eye = src
		change_sight(removing = SEE_TURFS | SEE_MOBS | SEE_OBJS)
		see_in_dark = 0
		see_invisible = SEE_INVISIBLE_LIVING

	for(var/datum/camerachunk/c in eyeobj.visibleCameraChunks)
		c.remove(eyeobj)

/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")
