var/list/camera_names=list()
/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	plane = ABOVE_HUMAN_PLANE

	var/datum/wires/camera/wires = null // Wires datum
	var/list/network = list(CAMERANET_SS13)
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1.0
	anchored = 1.0
	var/invuln = null
	var/bugged = 0
	var/obj/item/weapon/camera_assembly/assembly = null
	var/light_on = 0

	machine_flags = SCREWTOGGLE //| WIREJACK Needs work

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/light_disabled = 0
	var/alarm_on = 0
	var/busy = 0

	var/hear_voice = 0

	var/vision_flags = SEE_SELF //Only applies when viewing the camera through a console.

/obj/machinery/camera/update_icon()
	var/EMPd = stat & EMPED
	var/deactivated = !status
	var/camtype = "camera"
	if(assembly)
		camtype = isXRay() ? "xraycam" : "camera" // Thanks to Krutchen for the icons.

	if (deactivated)
		icon_state = "[camtype]1"
	else if (EMPd)
		icon_state = "[camtype]emp"
	else
		icon_state = "[camtype]"

/obj/machinery/camera/proc/update_hear()//only cameras with voice analyzers can hear, to reduce the number of unecessary /mob/virtualhearer
	if(!hear_voice && isHearing())
		hear_voice = 1
		addHear()
	if(hear_voice && !isHearing())
		hear_voice = 0
		removeHear()

/obj/machinery/camera/proc/update_upgrades()//Called when an upgrade is added or removed.
	if(isXRay())
		vision_flags |= SEE_TURFS | SEE_MOBS | SEE_OBJS
	else
		vision_flags &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)

/obj/machinery/camera/New()
	wires = new(src)

	assembly = new(src)
	assembly.state = 4

	if(!src.network || src.network.len < 1)
		if(loc)
			error("[src.name] in [get_area(src)] (x:[src.x] y:[src.y] z:[src.z] has errored. [src.network?"Empty network list":"Null network list"]")
		else
			error("[src.name] in [get_area(src)]has errored. [src.network?"Empty network list":"Null network list"]")
		ASSERT(src.network)
		ASSERT(src.network.len > 0)

	if(!c_tag)
		name_camera()
	..()
	if(adv_camera && adv_camera.initialized && !(src in adv_camera.camerasbyzlevel["[z]"]))
		adv_camera.update(z, TRUE, list(src))

	update_hear()

/obj/machinery/camera/proc/name_camera()
	var/area/A=get_area(src)
	var/basename=A.name
	var/nethash=english_list(network)
	var/suffix = 0
	while(!suffix || (nethash+c_tag in camera_names))
		c_tag = "[basename]"
		if(suffix)
			c_tag += " [suffix]"
		suffix++
	camera_names[nethash+c_tag]=src

/obj/machinery/camera/change_area(var/area/oldarea, var/area/newarea)
	var/nethash=english_list(network)
	camera_names[nethash+c_tag]=null
	..()

/obj/machinery/camera/change_area_name(oldname, oldarea)
	..()
	name_camera()

/obj/machinery/camera/Destroy()
	deactivate(null, 0) //kick anyone viewing out
	if(assembly)
		qdel(assembly)
		assembly = null
	wires = null
	cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	if(adv_camera)
		for(var/key in adv_camera.camerasbyzlevel)
			adv_camera.camerasbyzlevel[key] -= src
	..()

/obj/machinery/camera/emp_act(severity)
	if(isEmpProof())
		return
	if(prob(100/severity))
		var/list/previous_network = network
		network = list()
		cameranet.removeCamera(src)
		stat |= EMPED
		adv_camera.update(z, TRUE, list(src))
		set_light(0)
		triggerCameraAlarm()
		update_icon()
		spawn(900)
			network = previous_network
			stat &= ~EMPED
			cancelCameraAlarm()
			update_icon()
			if(can_use())
				cameranet.addCamera(src)
				adv_camera.update(z, TRUE, list(src))
		for(var/mob/O in mob_list)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					O.unset_machine()
					O.reset_view(null)
					to_chat(O, "The screen bursts into static.")
		..()

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	qdel(src)
	return

/obj/machinery/camera/proc/setViewRange(var/num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/shock(var/mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	if(!status)
		return
	status = 0
	update_icon()
	user.do_attack_animation(src, user)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(get_turf(src), 'sound/weapons/slash.ogg', 100, 1)
	add_hiddenprint(user)
	deactivate(user,0)

var/list/camera_messages = list()

/obj/machinery/camera/attackby(obj/W as obj, mob/living/user as mob)

	// DECONSTRUCTION
	if(isscrewdriver(W))
//		to_chat(user, "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>")
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		togglePanelOpen(W, user, icon_state, icon_state)

	else if(panel_open && iswiretool(W))
		wires.Interact(user)

	else if(istype(W, /obj/item/weapon/weldingtool) && wires.CanDeconstruct())
		if(weld(W, user))
			if(assembly)
				assembly.state = 1
				assembly.forceMove(src.loc)
				assembly = null

			qdel(src)

	// Upgrades!
	else if(is_type_in_list(W, assembly.possible_upgrades)) // Is a possible upgrade
		if (is_type_in_list(W, assembly.upgrades))
			to_chat(user, "The camera already has \a [W] inside!")
			return
		if (!panel_open)
			to_chat(user, "You can't reach into the camera's circuitry while the maintenance panel is closed.")
			return
		/*if (!wires.CanDeconstruct())
			to_chat(user, "You can't reach into the camera's circuitry with the wires on the way.")
			return*/
		if (istype(W, /obj/item/stack))
			var/obj/item/stack/sheet/mineral/plasma/s = W
			s.use(1)
			assembly.upgrades += new /obj/item/stack/sheet/mineral/plasma
		else
			if(!user.drop_item(W, src))
				return
			assembly.upgrades += W
		to_chat(user, "You attach the [W] into the camera's inner circuits.")
		update_upgrades()
		update_icon()
		update_hear()
		cameranet.updateVisibility(src, 0)
		return

	// Taking out upgrades
	else if(iscrowbar(W))
		if (!panel_open)
			to_chat(user, "You can't reach into the camera's circuitry while the maintenance panel is closed.")
			return
		/*if (!wires.CanDeconstruct())
			to_chat(user, "You can't reach into the camera's circuitry with the wires on the way.")
			return*/
		if (assembly.upgrades.len)
			var/obj/U = locate(/obj) in assembly.upgrades
			if(U)
				to_chat(user, "You unattach \the [U] from the camera.")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				U.forceMove(get_turf(src))
				assembly.upgrades -= U
				update_upgrades()
				update_icon()
				update_hear()
				cameranet.updateVisibility(src, 0)
			return
		else //Camera deconned, no upgrades
			to_chat(user, "The camera is firmly welded to the wall.")//User might be trying to deconstruct the camera with a crowbar, let them know what's wrong

			return

	// OTHER
	else if ((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/device/pda)) && isliving(user))
		user.delayNextAttack(5)
		var/mob/living/U = user
		to_chat(U, "You hold \a [W] up to the camera ...")

		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			var/obj/item/weapon/paper/X = W
			info = X.info
		else
			var/obj/item/device/pda/P = W
			info = P.notehtml

		camera_messages["[html_encode(W.name)]"] = info

		for(var/mob/living/silicon/ai/O in living_mob_list)
			if(!O.client)
				continue
			if(U.name == "Unknown")
				to_chat( O, "<span class='name'>[U]</span> holds a <a href='byond://?src=\ref[src];picturename=[html_encode(W.name)]'>[W]</a> up to one of your cameras ...")
			else
				to_chat(O, "<span class='name'><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></span> holds a <a href='byond://?src=\ref[src];picturename=[html_encode(W.name)]'>[W]</a> up to one of your cameras ...")

		for(var/mob/O in player_list)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					to_chat(O, "[U] holds a <a href='byond://?src=\ref[src];picturename=[html_encode(W.name)]'>[W]</a> up to one of the cameras ...")
	else
		..()
	return

/obj/machinery/camera/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["picturename"])
		var/picturename = href_list["picturename"]
		var/pictureinfo = camera_messages[picturename]
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", picturename, pictureinfo), text("window=[]", picturename))

/obj/machinery/camera/attack_pai(mob/user as mob)
	wirejack(user)

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1)
	if(choice==1)
		status = !( src.status )
		update_icon()
		if (!(src.status))
			if(user)
				visible_message("<span class='warning'>[user] has deactivated [src]!</span>")
				add_hiddenprint(user)
			else
				visible_message("<span class='warning'> \The [src] deactivates!</span>")
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			add_hiddenprint(user)
		else
			if(user)
				visible_message("<span class='warning'> [user] has reactivated [src]!</span>")
				add_hiddenprint(user)
			else
				visible_message("<span class='warning'> \The [src] reactivates!</span>")
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			add_hiddenprint(user)
		cameranet.updateVisibility(src, 0)
	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
		if (istype(O.machine, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/S = O.machine
			if (S.current == src)
				O.unset_machine()
				O.reset_view(null)
				to_chat(O, "The screen bursts into static.")
	adv_camera.update(z, TRUE, list(src))

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", areaMaster, list(src), src)
	adv_camera.update(z, TRUE, list(src))


/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", areaMaster, src)
	adv_camera.update(z, TRUE, list(src))

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = get_hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null

	for (var/direction in cardinal)
		T = get_ranged_target_turf(src, direction, 1)

		if (istype(T))
			dir = reverse_direction(direction)
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(var/mob/M)


	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

/obj/machinery/camera/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)


	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	to_chat(user, "<span class='notice'>You start to weld the [src].</span>")
	playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, src, 100))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0

/obj/machinery/camera/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		P.set_machine(P)
		P.current = src
		P.reset_view(src)
		return 1
	return 0

/obj/machinery/camera/proc/tv_message(var/atom/movable/hearer, var/datum/speech/speech)
	speech.wrapper_classes.Add("tv")
	hearer.Hear(speech)

	/*
	var/namepart =  "[speaker.GetVoice()][speaker.get_alt_name()] "
	var/messagepart = "<span class='message'>[hearer.lang_treat(speaker, speaking, raw_message)]</span>"

	return "<span class='game say'><span class='name'>[namepart]</span>[messagepart]</span>"
	*/

/obj/machinery/camera/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(isHearing())
		for(var/obj/machinery/computer/security/S in tv_monitors)
			if(S.current == src)
				if(istype(S, /obj/machinery/computer/security/telescreen))
					for(var/mob/M in viewers(world.view,S))
						to_chat(M, "<span style='color:grey'>[bicon(S)][tv_message(M, speech, rendered_speech)]</span>")
				else
					for(var/mob/M in viewers(1,S))
						to_chat(M, "<span style='color:grey'>[bicon(S)][tv_message(M, speech, rendered_speech)]</span>")

/obj/machinery/camera/arena
	name = "arena camera"
	desc = "A camera anchored to the floor, designed to survive hits and explosions of any size. What's it made of anyway?"
	icon_state = "camerarena"
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	layer = DECAL_LAYER
	plane = ABOVE_TURF_PLANE

/obj/machinery/camera/arena/New()
	..()
	pixel_x = 0
	pixel_y = 0
	upgradeXRay()
	upgradeHearing()

/obj/machinery/camera/arena/attackby(W as obj, mob/living/user as mob)
	if(isscrewdriver(W))
		to_chat(user, "<span class='warning'>There aren't any visible screws to unscrew.</span>")
	else
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W] but it doesn't seem to affect it in the least.</span>","<span class='warning'>You hit \the [src] with \the [W] but it doesn't seem to affect it in the least</span>")
	return

/obj/machinery/camera/arena/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	user.visible_message("<span class='warning'>\The [user] slashes at \the [src], but that didn't affect it at all.</span>","<span class='warning'>You slash at \the [src], but that didn't affect it at all.</span>")
	return

/obj/machinery/camera/arena/update_icon()
	return

/obj/machinery/camera/arena/emp_act(severity)
	return

/obj/machinery/camera/arena/ex_act(severity)
	return

/obj/machinery/camera/arena/blob_act(severity)
	return

/obj/machinery/camera/arena/singularity_act(severity)//those are really good cameras
	return

/obj/structure/planner/arena/cultify()
	return

/obj/machinery/camera/arena/attack_pai(mob/user as mob)
	return

/obj/machinery/camera/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

	H.apply_damage(rand(1,2), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
	return SPECIAL_ATTACK_FAILED

/obj/machinery/camera/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)
