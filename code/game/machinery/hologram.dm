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
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images. It is activated remotely."
	icon_state = "holopad0"
	var/mob/master  //Which AI, if any, is controlling the object? Only one AI may control a hologram at any time.
	var/obj/machinery/hologram/holopad/target //Which holopad are projections sent to if used by a person?
	var/obj/machinery/hologram/holopad/last_target //For convenience of accessing in the selection list again
	var/obj/machinery/hologram/holopad/source //Source of above
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 6 // Change to change how far the AI can move away from the holopad before deactivating.
	var/holopad_mode = 0	//0 = RANGE BASED, 1 = AREA BASED
	var/user_holocolor = "#0099ff" //Color for holopad talkers
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
	var/area/A = get_area(src)
	if(A)
		name = "\improper [A.name] holopad"
	component_parts = newlist(
		/obj/item/weapon/circuitboard/holopad,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

/obj/machinery/hologram/holopad/examine(mob/user)
	..()
	if(source)
		to_chat(user, "<span class='notice'>It's currently transmitting from [source].</span>")
	if(target)
		to_chat(user, "<span class='notice'>It's currently transmitting to [target].</span>")

/obj/machinery/hologram/holopad/Destroy()
	holopads -= src
	..()

/obj/machinery/hologram/holopad/GhostsAlwaysHear()
	return TRUE

/obj/machinery/hologram/holopad/attack_hand(var/mob/living/carbon/human/user) //Carn: Hologram requests.
	if(!istype(user))
		return
	if(target)
		to_chat(user, "<span class='notice'>You stop transmitting to [target].</span>")
		target.clear_holo()
		return
	if(master && isAIEye(master))
		to_chat(user, "<span class='notice'>[master] is using \the [src], you cannot interact with it until it is done.</span>")
		return
	if(holo)
		to_chat(user, "<span class='notice'>You stop transmitting [holo][source ? " from [source]" : ""].</span>")
		clear_holo()
		return
	switch(alert(user,"Would you like to request an AI's presence or transmit to another holopad?","Holopad functions","Request AI presence","Transmit to other","Cancel"))
		if("Request AI presence")
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
		if("Transmit to other")
			var/list/other_holopads = list()
			for(var/obj/machinery/hologram/holopad/H in holopads)
				if(H == src)
					continue
				if(H.stat & (FORCEDISABLE|NOPOWER))
					continue
				other_holopads += H
			if(other_holopads.len)
				target = input(user,"Select a holopad to transmit to","Holopad transmission",last_target) as null|anything in other_holopads
				last_target = target
				if(target)
					target.source = src
					if(!target.activate_holo(user))
						target.source = null
						target = null

			else
				to_chat(user, "<span class='warning'>ERROR: </span>No other AI holopads were found to transmit to.")

/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/

	//If there is a hologram, remove it. But only if the user is the master, or the master isn't another AI. Otherwise do nothing.
	if(master && (master == user || master == user.eyeobj || !isAIEye(master)) && holo)
		clear_holo()
	else if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.forceMove(get_turf(src))
	else if (!holo)//If there is no hologram, possibly make one.
		activate_holo(user.eyeobj)
	return

// For when an AI bounces between one holopad to another - it should look seamless by reusing the same hologram. Returns whether the transfer was successful.
/obj/machinery/hologram/holopad/proc/transfer_ai(obj/machinery/hologram/holopad/source_pad)
	if(stat & (FORCEDISABLE|NOPOWER))
		return FALSE
	if(master || holo)
		return FALSE

	var/transferred_master = source_pad.master
	var/transferred_holo = source_pad.holo
	source_pad.clear_holo(FALSE)
	source_pad.holo = null
	transfer_holo(transferred_master, transferred_holo)
	return TRUE

/obj/machinery/hologram/holopad/AltClick(var/mob/living/carbon/human/user)
	set_holocolor(user)

/obj/machinery/hologram/holopad/verb/set_holocolor(mob/user)
	set category = "Object"
	set name = "Set Holocolor"
	set src in oview(1)
	if(ishuman(user) && !user.stat && user.Adjacent(src))
		user_holocolor = input(user, "Please select the user hologram colour.", "Hologram colour") as color

/obj/machinery/hologram/holopad/proc/activate_holo(mob/user)
	if(!(stat & (FORCEDISABLE|NOPOWER)) && (!isAIEye(user) || user.loc == loc))//If the projector has power and AI eye is on it. (if applicable)
		if(!holo)//If there is not already a hologram.
			create_holo(user)//Create one.
			src.visible_message("A holographic image of [user] flicks to life right before your eyes!")
			return 1
		to_chat(user, "<span class='warning'>ERROR: </span>Image feed in progress.")
	else
		to_chat(user, "<span class='warning'>ERROR: </span>Unable to project hologram.")
	return 0

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/Hear(var/datum/speech/speech, var/rendered_message="")
	if(speech.speaker && !speech.frequency)//Radio_freq so AIs dont hear holopad stuff through radios.
		if(holo && master && speech.speaker != master)//Master is mostly a safety in case lag hits or something.
			if(!master.say_understands(speech.speaker, speech.language)) //previously if(!master.languages & speaker.languages)//The AI will be able to understand most mobs talking through the holopad.
				rendered_message = speech.render_message()
			rendered_message = "<i><span class='[speech.render_wrapper_classes()]'>Holopad received, <span class='message'>[rendered_message]</span></span></i>"
			if(isAIEye(master))
				master.show_message(rendered_message, 2)
			else if(source)
				source.visible_message(rendered_message)
		if(target && target.master && target.holo && speech.speaker == target.master)
			target.holo.say(speech.message)

/obj/machinery/hologram/holopad/on_see(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message, atom/A)
	if(isAIEye(master))
		var/mob/camera/aiEye/eye = master
		if(eye.high_res && cameranet.checkCameraVis(A)) //visible message is already being picked up by the cameras, avoids duplicate messages
			return
		master.show_message( message, 1, blind_message, 2) //otherwise it's being picked up by the holopad itself
	else if(target && target.holo && target.master && A == target.master)
		message = replacetext(message,"[target.master]","[target.holo]")
		target.holo.visible_message(message, blind_message, drugged_message, blind_drugged_message)

/obj/machinery/hologram/holopad/proc/create_holo(mob/user, turf/T = loc)
	var/mob/camera/aiEye/eye = user
	var/mob/living/silicon/ai/AI = istype(eye) ? eye.ai : null
	ray = new(T)
	holo = new(T)//Spawn a blank effect at the location.
	// hologram.mouse_opacity = 0 Why would we not want to click on it
	holo.name = "[user.name] (Hologram)"//If someone decides to right click.
	var/holocolor = AI ? AI.holocolor : (source ? source.user_holocolor : user_holocolor)

	if(AI)
		AI.current = src
	master = user
	set_light(2, 0, holocolor)			//pad lighting
	icon_state = "holopad1"
	update_holo()

	var/icon/colored_ray = getFlatIcon(ray)
	colored_ray.ColorTone(holocolor)
	ray.icon = colored_ray

	use_power = MACHINE_POWER_USE_ACTIVE//Active power usage.
	holo.set_glide_size(DELAY2GLIDESIZE(1))
	if(source)
		source.scanray = new(source.loc)
		colored_ray = getFlatIcon(source.scanray)
		colored_ray.ColorTone(holocolor)
		source.scanray.icon = colored_ray
	if(!istype(eye)) // to stop unforeseen consequences with these colliding and overriding the hologram bumps
		master.register_event(/event/face, src, nameof(src::move_hologram()))
		master.register_event(/event/moved, src, nameof(src::move_hologram()))
		master.register_event(/event/equipped, src, nameof(src::update_holo()))
		master.register_event(/event/unequipped, src, nameof(src::update_holo()))
		master.register_event(/event/damaged, src, nameof(src::update_holo()))
	move_hologram()
	if(AI && AI.holopadoverlays.len)
		for(var/image/ol in AI.holopadoverlays)
			if(ol.loc == src)
				ol.icon_state = "holopad1"
				break

	return 1

/obj/machinery/hologram/holopad/proc/update_holo(atom/item, slot, kind, amount)
	if(holo && master)
		var/icon/colored_holo
		var/holocolor
		if(isAIEye(master))
			var/mob/camera/aiEye/eye = master
			var/mob/living/silicon/ai/AI = eye.ai
			colored_holo = AI.holo_icon
			holocolor = AI.holocolor
		else
			var/icon/I = icon('icons/effects/32x32.dmi', "blank")
			colored_holo = icon(I, "")
			colored_holo.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(master)), override_dir = SOUTH, ignore_spawn_items = TRUE),  "", dir = SOUTH)
			colored_holo.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(master)), override_dir = NORTH, ignore_spawn_items = TRUE),  "", dir = NORTH)
			colored_holo.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(master)), override_dir = EAST, ignore_spawn_items = TRUE),  "", dir = EAST)
			colored_holo.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(master)), override_dir = WEST, ignore_spawn_items = TRUE),  "", dir = WEST)
			colored_holo.Crop(1,1,32,32)
			holocolor = source ? source.user_holocolor : user_holocolor
		colored_holo.ColorTone(holocolor)
		var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline")
		colored_holo.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
		holo.icon = colored_holo

/obj/machinery/hologram/holopad/proc/transfer_holo(mob/user, obj/effect/overlay/hologram/transferred_holo)
	ray = new(loc)
	holo = transferred_holo

	var/mob/camera/aiEye/eye = user
	var/mob/living/silicon/ai/AI = istype(eye) ? eye.ai : null
	var/holocolor = AI ? AI.holocolor : user_holocolor

	set_light(2, 0, holocolor)
	icon_state = "holopad1"

	var/icon/colored_ray = getFlatIcon(ray)
	colored_ray.ColorTone(holocolor)
	ray.icon = colored_ray

	if(AI)
		AI.current = src
	master = user
	use_power = MACHINE_POWER_USE_ACTIVE
	holo.set_glide_size(DELAY2GLIDESIZE(1))
	move_hologram()
	if(AI && AI.holopadoverlays.len)
		for(var/image/ol in AI.holopadoverlays)
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

/obj/machinery/hologram/holopad/proc/clear_holo(var/delete_holo = TRUE)
	var/mob/camera/aiEye/eye = master
	var/mob/living/silicon/ai/AI = istype(eye) ? eye.ai : master
	if(istype(AI) && AI.holopadoverlays.len)
		for(var/image/ol in AI.holopadoverlays)
			if(ol.loc == src)
				ol.icon_state = "holopad0"
				break

	set_light(0)			//pad lighting (hologram lighting will be handled automatically since its owner was deleted)
	icon_state = "holopad0"
	use_power = MACHINE_POWER_USE_IDLE//Passive power usage.
	if(master)
		if(!advancedholo && !isAIEye(master))
			master.unregister_event(/event/face, src, nameof(src::move_hologram()))
			master.unregister_event(/event/moved, src, nameof(src::move_hologram()))
			master.unregister_event(/event/equipped, src, nameof(src::update_holo()))
			master.unregister_event(/event/unequipped, src, nameof(src::update_holo()))
			master.register_event(/event/damaged, src, nameof(src::update_holo()))
		if(istype(AI) && AI.current == src)
			AI.current = null
		master = null //Null the master, since no-one is using it now.
	advancedholo = FALSE
	QDEL_NULL(ray)
	if(delete_holo && holo)
		var/obj/effect/overlay/hologram/H = holo
		visible_message("<span class='warning'>The image of [holo] fades away.</span>")
		holo = null
		animate(H, alpha = 0, time = 5)
		spawn(5)
			qdel(H)//Get rid of hologram.
	if(source)
		QDEL_NULL(source.scanray)
		source.target = null
		source = null
	return 1

/obj/machinery/hologram/holopad/emp_act()
	if(holo)
		clear_holo()

/obj/machinery/hologram/holopad/process()
	if(holo)//If there is a hologram.
		if(master)//If there is a master attached
			if(isAIEye(master))
				var/mob/camera/aiEye/eye = master
				if(!eye.ai || eye.ai.stat || !eye.ai.client)//If there is no AI eye or client for the AI or AI is incapacitated
					clear_holo()
					return 1
			else if (master.stat || !master.client) //If anything else doesn't have a client or is incapacitated
				clear_holo()
				return 1
			if(!(stat & (FORCEDISABLE|NOPOWER)))//If the  machine has power.
				var/turf/T = get_turf(holo)
				if(isAIEye(master) && T.obscured)
					clear_holo()
				if(holopad_mode == 0 && is_in_projection_range())
					return 1
				else if (holopad_mode == 1)
					var/area/holo_area = get_area(src)
					var/area/eye_area = get_area(master)
					if(eye_area == holo_area || advancedholo)
						return 1
		clear_holo()//If not, we want to get rid of the hologram.
	return 1

/obj/machinery/hologram/holopad/proc/is_in_projection_range()
	return (isAIEye(master) && get_dist(master, src) <= holo_range) || (source && !isAIEye(master) && get_dist(master, source) <= holo_range) || advancedholo

/obj/machinery/hologram/holopad/proc/move_hologram(var/forced = 0,var/atom/movable/mover)
	if(holo)
		if (is_in_projection_range())
			holo.set_glide_size(DELAY2GLIDESIZE(1))
			if(isAIEye(master))
				master.set_glide_size(DELAY2GLIDESIZE(1))
			var/turf/dest = loc
			if(source)
				holo.dir = master.dir
				var/x_offset = master.x - source.x
				var/y_offset = master.y - source.y
				dest = locate(src.x + x_offset, src.y + y_offset, src.z)
				if(source.scanray)
					source.project_ray(master,source.scanray)
			else
				dest = get_turf(master)
				step_to(holo, master) // So it turns.
			var/turf/old = holo.loc
			holo.forceMove(dest)
			if(ray)
				project_ray(holo,ray,old)
		else
			var/transferred = FALSE
			for(var/obj/machinery/hologram/holopad/other_holopad in range(holo_range, master.loc))
				if(other_holopad != src && other_holopad.transfer_ai(src))
					transferred = TRUE
					break
			if(!transferred)
				clear_holo()

	return 1

/obj/machinery/hologram/holopad/proc/project_ray(var/atom/movable/target,var/obj/effect/overlay/targetray,var/turf/oldLoc)
	var/disty = target.y - targetray.y
	var/distx = target.x - targetray.x
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
	var/turf/T = target.loc
	if (get_dist(oldLoc,T) <= 1)
		animate(targetray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
	else
		targetray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)

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
	var/obj/effect/overlay/holoray/scanray	//For scanning someone to project.
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
