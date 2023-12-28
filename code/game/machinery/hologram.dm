/* Holograms!
 * Contains:
 *		Holopad
 *		Hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Only one AI may project from a holopad at any given time.
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/

//Holopad
var/list/holopads = list()

/obj/machinery/hologram/holopad
	name = "\improper AI holopad"
	desc = "It's a floor-mounted device for projecting holographic images. It is activated remotely."
	icon_state = "holopad0"
	var/mob/living/silicon/ai/master  //Which AI, if any, is controlling the object? Only one AI may control a hologram at any time.
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 6 // Change to change how far the AI can move away from the holopad before deactivating.
	var/holopad_mode = 0	//0 = RANGE BASED, 1 = AREA BASED
	flags = HEAR
	plane = ABOVE_TURF_PLANE
	layer = ABOVE_TILE_LAYER
	machine_flags = SCREWTOGGLE | CROWDESTROY

	hack_abilities = list(
		/datum/malfhack_ability/create_lifelike_hologram,
		/datum/malfhack_ability/oneuse/overload_quiet,
	)


/obj/machinery/hologram/holopad/New()
	..()
	holopads += src
	component_parts = newlist(
		/obj/item/weapon/circuitboard/holopad,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

/obj/machinery/hologram/holopad/Destroy()
	holopads -= src
	..()

/obj/machinery/hologram/holopad/GhostsAlwaysHear()
	return TRUE

/obj/machinery/hologram/holopad/attack_hand(var/mob/living/carbon/human/user) //Carn: Hologram requests.
	if(!istype(user))
		return
	if(alert(user,"Would you like to request an AI's presence?",,"Yes","No") == "Yes")
		if(last_request + 200 < world.time) //don't spam the AI with requests you jerk!
			last_request = world.time
			to_chat(user, "<span class='notice'>You request an AI's presence.</span>")
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in living_mob_list)
				if(!AI.client)
					continue
				to_chat(AI, "<span class='big info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=\ref[src]'>\the [area]</a>.</span>")
				AI << 'sound/machines/twobeep.ogg'
		else
			to_chat(user, "<span class='notice'>A request for AI presence was already sent recently.</span>")

/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	user.cameraFollow = null // Stops tracking

	if(master && (master==user) && holo)//If there is a hologram, remove it. But only if the user is the master. Otherwise do nothing.
		clear_holo()
	else if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.forceMove(get_turf(src))
	else if (!holo)//If there is no hologram, possibly make one.
		activate_holo(user)
	return

/obj/machinery/hologram/holopad/proc/activate_holo(mob/living/silicon/ai/user)
	if(!(stat & (FORCEDISABLE|NOPOWER)) && user.eyeobj.loc == loc)//If the projector has power and client eye is on it.
		if(!holo)//If there is not already a hologram.
			create_holo(user)//Create one.
			src.visible_message("A holographic image of [user] flicks to life right before your eyes!")
		else
			to_chat(user, "<span class='warning'>ERROR: </span>Image feed in progress.")
	else
		to_chat(user, "<span class='warning'>ERROR: </span>Unable to project hologram.")
	return

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/Hear(var/datum/speech/speech, var/rendered_message="")
	if(speech.speaker && holo && master && !speech.frequency && speech.speaker != master)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		if(!master.say_understands(speech.speaker, speech.language)) //previously if(!master.languages & speaker.languages)//The AI will be able to understand most mobs talking through the holopad.
			rendered_message = speech.render_message()
		rendered_message = "<i><span class='[speech.render_wrapper_classes()]'>Holopad received, <span class='message'>[rendered_message]</span></span></i>"
		master.show_message(rendered_message, 2)

/obj/machinery/hologram/holopad/on_see(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message, atom/A)
	if(!master)
		return
	if(master.eyeobj.high_res && cameranet.checkCameraVis(A)) //visible message is already being picked up by the cameras, avoids duplicate messages
		return
	master.show_message( message, 1, blind_message, 2) //otherwise it's being picked up by the holopad itself

/obj/machinery/hologram/holopad/proc/create_holo(mob/living/silicon/ai/A, turf/T = loc)
	ray = new(T)
	holo = new(T)//Spawn a blank effect at the location.
	// hologram.mouse_opacity = 0 Why would we not want to click on it
	holo.name = "[A.name] (Hologram)"//If someone decides to right click.
	set_light(2, 0, A.holocolor)			//pad lighting
	icon_state = "holopad1"
	var/icon/colored_holo = A.holo_icon
	colored_holo.ColorTone(A.holocolor)
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline")
	colored_holo.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	holo.icon = colored_holo
	
	var/icon/colored_ray = getFlatIcon(ray)
	colored_ray.ColorTone(A.holocolor)
	ray.icon = colored_ray
	
	A.current = src
	master = A//AI is the master.
	use_power = MACHINE_POWER_USE_ACTIVE//Active power usage.
	holo.set_glide_size(DELAY2GLIDESIZE(1))
	move_hologram()
	if(A && A.holopadoverlays.len)
		for(var/image/ol in A.holopadoverlays)
			if(ol.loc == src)
				ol.icon_state = "holopad1"
				break

	return 1

/obj/machinery/hologram/holopad/proc/create_advanced_holo(var/mob/living/silicon/ai/A)
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(holo)
		clear_holo()
		return
	var/obj/machinery/hologram/holopad/H = A.current
	if(istype(H) && H.holo)
		H.clear_holo()
		return
	var/list/available_mobs = generate_appearance_list()
	var/mob_to_copy = input(A, "Who will this hologram look like?", "Creatures") as null|anything in available_mobs
	if(!mob_to_copy)
		return 0
	if(!A.eyeobj)
		A.make_eyeobj()
	A.eyeobj.forceMove(get_turf(src))
	A.current = src
	advancedholo = TRUE
	holo = new /obj/effect/overlay/hologram/lifelike(get_turf(src), available_mobs[mob_to_copy], A.eyeobj, src)
	holo.set_glide_size(DELAY2GLIDESIZE(1))
	master = A
	use_power = 2

	return 1

/obj/machinery/hologram/holopad/proc/generate_appearance_list()
	var/list/L = sortmobs()
	var/list/newlist = list()
	for(var/mob/living/M in L)
		if(M.z != map.zMainStation)
			continue
		newlist["[M.name]"] = M
	return newlist

/obj/machinery/hologram/holopad/proc/clear_holo()
	if(master && master.holopadoverlays.len)
		for(var/image/ol in master.holopadoverlays)
			if(ol.loc == src)
				ol.icon_state = "holopad0"
				break

	set_light(0)			//pad lighting (hologram lighting will be handled automatically since its owner was deleted)
	icon_state = "holopad0"
	use_power = MACHINE_POWER_USE_IDLE//Passive power usage.
	advancedholo = FALSE
	if(master)
		if(master.current == src)
			master.current = null
		master = null //Null the master, since no-one is using it now.
	QDEL_NULL(ray)
	if(holo)
		var/obj/effect/overlay/hologram/H = holo
		visible_message("<span class='warning'>The image of [holo] fades away.</span>")
		holo = null
		animate(H, alpha = 0, time = 5)
		spawn(5)
			qdel(H)//Get rid of hologram.
	return 1

/obj/machinery/hologram/holopad/emp_act()
	if(holo)
		clear_holo()

/obj/machinery/hologram/holopad/process()
	if(holo)//If there is a hologram.
		if(master && !master.stat && master.client && master.eyeobj)//If there is an AI attached, it's not incapacitated, it has a client, and the client eye is centered on the projector.
			if(!(stat & (FORCEDISABLE|NOPOWER)))//If the  machine has power.
				var/turf/T = get_turf(holo)
				if(T.obscured)
					clear_holo()
				if((holopad_mode == 0 && (get_dist(master.eyeobj, src) <= holo_range)) || advancedholo)
					return 1
				else if (holopad_mode == 1)
					var/area/holo_area = get_area(src)
					var/area/eye_area = get_area(master.eyeobj)
					if(eye_area == holo_area || advancedholo)
						return 1
		clear_holo()//If not, we want to get rid of the hologram.
	return 1

/obj/machinery/hologram/holopad/proc/move_hologram(var/forced = 0 )
	if(holo)
		if (get_dist(master.eyeobj, src) <= holo_range || advancedholo)
			holo.set_glide_size(DELAY2GLIDESIZE(1))
			master.eyeobj.set_glide_size(DELAY2GLIDESIZE(1))
			var/turf/T = holo.loc
			var/turf/dest = get_turf(master.eyeobj)
			step_to(holo, master.eyeobj) // So it turns.
			holo.forceMove(dest)
			if(ray)
				var/disty = holo.y - ray.y
				var/distx = holo.x - ray.x
				var/newangle
				if(!disty)
					if(distx >= 0)
						newangle = 90
					else
						newangle = 270
				else
					newangle = arctan(distx/disty)
					if(disty < 0)
						newangle += 180
					else if(distx < 0)
						newangle += 360
				var/matrix/M = matrix()
				if (get_dist(T,dest) <= 1)
					animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
				else
					ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)
		else
			clear_holo()
	return 1

/*
 * Hologram
 */

/obj/effect/overlay/hologram
	layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	plane = ABOVE_HUMAN_PLANE
	anchored = 1//So space wind cannot drag it.
	alpha = 200

/obj/effect/overlay/hologram/New()
	..()
	set_light(2)

/obj/effect/overlay/holoray
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	layer = FLY_LAYER
	plane = LYING_MOB_PLANE
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32
	alpha = 100

/obj/machinery/hologram
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 100
	var/obj/effect/overlay/hologram/holo 	//The projection itself. If there is one, the instrument is on, off otherwise.
	var/obj/effect/overlay/holoray/ray		//The link between the projection and the projector.
	var/advancedholo = FALSE				//are we projecting an advanced hologram? (malf AI)

/obj/machinery/hologram/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

//Destruction procs.
/obj/machinery/hologram/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/machinery/hologram/blob_act()
	qdel(src)

/obj/machinery/hologram/Destroy()
	if(holo)
		src:clear_holo()
	..()

/*
Holographic project of everything else.

/mob/verb/hologram_test()
	set name = "Hologram Debug New"
	set category = "CURRENT DEBUG"

	var/obj/effect/overlay/hologram = new(loc)//Spawn a blank effect at the location.
	var/icon/flat_icon = icon(getFlatIcon(src,0))//Need to make sure it's a new icon so the old one is not reused.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/input = input("Select what icon state to use in effect.",,"")
	if(input)
		var/icon/alpha_mask = new('icons/effects/effects.dmi', "[input]")
		flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
		hologram.icon = flat_icon

		to_chat(world, "Your icon should appear now.")
	return
*/

/*
 * Other Stuff: Is this even used?
 */

/obj/effect/overlay/hologram/lifelike
	plane = HUMAN_PLANE
	layer = 0
	icon = 'icons/mob/AI.dmi'
	icon_state = "holo1"
	density = 1
	anchored = 0
	var/mob/camera/aiEye/eye
	var/obj/machinery/hologram/holopad/parent

/obj/effect/overlay/hologram/lifelike/New(var/loc, var/mob/living/mob_to_copy, var/mob/eyeobj, var/obj/machinery/hologram/holopad/H)
	..()
	steal_appearance(mob_to_copy)
	eye = eyeobj
	parent = H
	register_event(/event/after_move, src, /obj/effect/overlay/hologram/lifelike/proc/UpdateEye)
	set_light(0)

/obj/effect/overlay/hologram/lifelike/proc/steal_appearance(var/mob/living/M)
	name = M.name
	appearance = M.appearance
	if(M.lying)  // make them stand up if they were lying down
		pixel_y += 6 * PIXEL_MULTIPLIER
		transform = transform.Turn(-90)
	var/datum/log/L = new
	M.examine(L)
	desc = L.log
	qdel(L)

/obj/effect/overlay/hologram/lifelike/examine(mob/user, var/size = "")
	if(desc)
		to_chat(user, desc)


/obj/effect/overlay/hologram/lifelike/attack_hand(var/mob/living/M)
	M.visible_message(\
	"<span class='warning'>[M]'s hand passes straight through [src]!</span>", \
	"<span class='warning'>Your hand passes straight through [src]!</span>", \
	)
	parent.clear_holo()

/obj/effect/overlay/hologram/lifelike/attackby(var/obj/O)
	visible_message("<span class='warning'>\The [O] passes straight through [src]!</span>")
	parent.clear_holo()

/obj/effect/overlay/hologram/lifelike/bullet_act(var/obj/item/projectile/Proj)
	visible_message("<span class='warning'>\The [Proj] passes straight through [src]!</span>")
	parent.clear_holo()

/obj/effect/overlay/hologram/lifelike/proc/UpdateEye()
	if(eye && eye.loc != loc)
		eye.forceMove(loc, holo_bump = TRUE)
