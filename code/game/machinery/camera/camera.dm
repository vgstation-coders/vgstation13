#define CAMERA_MAX_HEALTH 120
#define CAMERA_DEACTIVATE_HEALTH 45
#define CAMERA_MIN_WEAPON_DAMAGE 5

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
	flags = FPRINT

	var/datum/wires/camera/wires = null // Wires datum
	var/list/network = list(CAMERANET_SS13)
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1.0
	anchored = 1.0
	var/invuln = null
	var/bugged = 0
	var/failure_chance = 10
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
	var/health = CAMERA_MAX_HEALTH

/obj/machinery/camera/flawless
	failure_chance = 0

/obj/machinery/camera/initialize()
	..()
	if(prob(failure_chance))
		deactivate()

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

	//allow mappers to use the name field for the camera instead of c_tag
	//this helps organize the camera object list in DreamMaker
	if(name != initial(name) && !c_tag)
		c_tag = name
		name = initial(name)
	if(!c_tag)
		name_camera()
	..()
	update_hear()
	cameranet.cameras += src // This is different from addCamera. addCamera() cares about visibility.
	cameranet.addCamera(src)

/obj/machinery/camera/proc/name_camera()
	var/area/A=get_area(src)
	var/basename=format_text(A.name)
	var/nethash=english_list(network)
	var/suffix = 0
	while(!suffix || ((nethash+c_tag) in camera_names))
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
	cameranet.cameras -= src
	cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	..()

/obj/machinery/camera/emp_act(severity)
	if(isEmpProof())
		return
	if(prob(100/severity))
		var/list/previous_network = network
		network = list()
		cameranet.removeCamera(src)
		stat |= EMPED
		kill_light()
		triggerCameraAlarm()
		update_icon()
		spawn(900)
			network = previous_network
			stat &= ~EMPED
			cancelCameraAlarm()
			update_icon()
			if(can_use())
				cameranet.addCamera(src)
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

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	if(!status)
		return
	status = 0
	update_icon()
	user.do_attack_animation(src, user)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src, 'sound/weapons/slash.ogg', 100, 1)
	add_hiddenprint(user)
	deactivate(user,0)

#define MAX_CAMERA_MESSAGES 15
var/list/camera_messages = list()

/obj/machinery/camera/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damtype == HALLOSS)
		return ..()

	take_damage(Proj.damage)
	return ..()

/obj/machinery/camera/proc/dismantle()
	if(assembly)
		assembly.anchored = TRUE
		assembly.state = 1
		assembly.forceMove(loc)
		transfer_fingerprints(src, assembly)
		assembly.update_icon()
		assembly = null
	qdel(src)

/obj/machinery/camera/attackby(obj/item/W, mob/living/user)

	// DECONSTRUCTION
	if(W.is_screwdriver(user))
//		to_chat(user, "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>")
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		togglePanelOpen(W, user, icon_state, icon_state)

	else if(panel_open && iswiretool(W))
		wires.Interact(user)

	else if(iswelder(W) && wires.CanDeconstruct())
		if(weld(W, user))
			dismantle()

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
				playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
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
		to_chat(U, "You hold [W] up to the camera ...")

		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			var/obj/item/weapon/paper/X = W
			info = X.info
		else
			var/obj/item/device/pda/P = W
			info = P.notehtml

		var/key = "\ref[W]"
		if(camera_messages.len > MAX_CAMERA_MESSAGES)
			camera_messages.Cut(1, 2) // Removes the oldest element
		camera_messages[key] = list("text" = info, "title" = W.name)

		for(var/mob/living/silicon/ai/O in living_mob_list)
			if(!O.client)
				continue
			to_chat(O, "<span class='name'><a href='byond://?src=\ref[O];track=[U.name]'>[U.name]</a></span> holds <a href='byond://?src=\ref[src];message_id=[key]'>[W]</a> up to one of your cameras ...")

		for(var/obj/machinery/computer/security/tv in tv_monitors)
			if(tv.active_camera != src)
				continue
			for(var/datum/tgui/ui in SStgui.open_uis_by_src[tv])
				to_chat(ui.user, "[U] holds <a href='byond://?src=\ref[src];message_id=[key]'>[W]</a> up to one of the cameras ...")
	else
		..()
		add_fingerprint(user)
		user.delayNextAttack(8)
		if(user.a_intent == I_HELP)
			visible_message("<span class='notice'>[user] gently taps [src] with [W].</span>")
			return
		W.on_attack(src, user)
		if(W.force < CAMERA_MIN_WEAPON_DAMAGE)
			to_chat(user, "<span class='danger'>\The [W] does no damage to [src].</span>")
			visible_message("<span class='warning'>[user] hits [src] with [W]. It's not very effective.</span>")
			return
		visible_message("<span class='danger'>[user] hits [src] with [W].</span>")
		take_damage(W.force)

/obj/machinery/camera/proc/take_damage(var/amount)
	if(amount <= 0)
		return
	triggerCameraAlarm()
	health -= amount
	if(health <= CAMERA_DEACTIVATE_HEALTH && status)
		deactivate()
	if(health <= 0)
		spark(src)
		dismantle()

/obj/machinery/camera/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["message_id"])
		var/message_id = href_list["message_id"]
		var/list/pictureinfo = camera_messages[message_id]
		usr << browse("<HTML><HEAD><TITLE>[pictureinfo["title"]]</TITLE></HEAD><BODY><TT>[pictureinfo["text"]]</TT></BODY></HTML>", "window=[message_id]")

/obj/machinery/camera/attack_pai(mob/user as mob)
	wirejack(user)

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1, quiet = FALSE)
	vision_flags = SEE_SELF
	if(assembly)
		update_upgrades()
	cameranet.addCamera(src)
	if(choice==1)
		status = !( src.status )
		update_icon()
		if (!(src.status))
			if(user)
				if(!quiet)
					visible_message("<span class='warning'>[user] has deactivated [src]!</span>")
			else
				if(!quiet)
					visible_message("<span class='warning'> \The [src] deactivates!</span>")
		else
			if(user)
				if(!quiet)
					visible_message("<span class='warning'> [user] has reactivated [src]!</span>")
			else
				if(!quiet)
					visible_message("<span class='warning'> \The [src] reactivates!</span>")
		if(!quiet)
			playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
		add_hiddenprint(user)
		cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	var/area/this_area = get_area(src)
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", this_area, list(src), src)


/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	var/area/this_area = get_area(src)
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", this_area, src)

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
			dir = opposite_dirs[direction]
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/proc/near_range_camera(var/mob/M)


	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C

	return null

/obj/machinery/camera/proc/weld(var/obj/item/tool/weldingtool/WT, var/mob/user)


	if(busy)
		return 0

	// Do after stuff here
	to_chat(user, "<span class='notice'>You start to weld the [src].</span>")
	busy = 1
	if(WT.do_weld(user, src, 100, 0))
		busy = 0
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

/obj/machinery/camera/proc/tv_message(var/datum/speech/speech)
	speech.wrapper_classes.Add("tv")
	return speech
	/*
	var/namepart =  "[speaker.GetVoice()][speaker.get_alt_name()] "
	var/messagepart = "<span class='message'>[hearer.lang_treat(speaker, speaking, raw_message)]</span>"
	return "<span class='game say'><span class='name'>[namepart]</span>[messagepart]</span>"
	*/

/obj/machinery/camera/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(isHearing())
		var/datum/speech/copy = speech.clone()
		tv_message(copy)
		for(var/obj/machinery/computer/security/S in tv_monitors)
			if(S.active_camera == src)
				var/range = (istype(S, /obj/machinery/computer/security/telescreen) ? world.view : 1)
				for (var/mob/virtualhearer/VH in viewers(range, S))
					if (!ismob(VH.attached))
						continue
					VH.Hear(copy, "[bicon(S)] [rendered_speech]")

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

/obj/machinery/camera/arena/attackby(obj/item/W as obj, mob/living/user as mob)
	if(W.is_screwdriver(user))
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

/obj/machinery/camera/arena/bullet_act(var/obj/item/projectile/Proj)
	return ..()

/obj/machinery/camera/arena/spesstv
	name = "\improper Spess.TV camera"
	network = list(CAMERANET_SPESSTV)
	var/datum/role/streamer/streamer

/obj/machinery/camera/arena/spesstv/New()
	..()
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/carrot in assembly.upgrades)
		assembly.upgrades -= carrot
	update_upgrades()
	deactivate()

/obj/machinery/camera/arena/spesstv/name_camera()
	var/team_name = streamer?.team
	var/basename = streamer?.antag?.name || "Unknown"
	if(team_name)
		basename = "\[[team_name]\] [basename]"
	var/nethash = english_list(network)
	var/suffix = 0
	while(!suffix || ((nethash+c_tag) in camera_names))
		c_tag = "[basename]"
		if(suffix)
			c_tag += " [suffix]"
		suffix++
	camera_names[nethash+c_tag]=src

/obj/machinery/camera/deactivate(mob/user, choice = TRUE, quiet = TRUE)
	..()

/obj/machinery/camera/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	if(H.foot_impact(src,rand(1,2)))
		to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")
	return SPECIAL_ATTACK_FAILED

/obj/machinery/camera/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/camera/proc/camera_twitch()
	for(var/mob/living/carbon/human/H in view(view_range, src))
		if(H.disabilities & NERVOUS)
			var/list/watching_you = list("Did something just move?","Did that camera move?","The security camera... turned?",
			"Is someone watching you?", "Are you alone?", "Is someone keeping an eye on you?", "Who's there?",
			"Someone is watching...", "The hairs on your neck stand up.", "The station AI is keeping tabs on you.",
			"The whirr of the security camera as it turns to face you...", "Is that camera lens focusing in on you?",
			"The security camera keeps lingering on you...", "The cameras are watching you.", "The security team is observing you.",
			"Someone is watching you in the camera.", "They know. And they're watching.", "They've found you.")
			to_chat(H,"<i>[pick(watching_you)]</i>")

#undef CAMERA_MAX_HEALTH
#undef CAMERA_DEACTIVATE_HEALTH
#undef CAMERA_MIN_WEAPON_DAMAGE
