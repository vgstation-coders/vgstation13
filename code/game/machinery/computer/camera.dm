//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/tv_monitors = list()
var/list/obj/machinery/camera/cyborg_cams = list(
	CAMERANET_ROBOTS = list(), // Borgos
	CAMERANET_ENGI	 = list(), // Mommers
	)

/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	circuit = "/obj/item/weapon/circuitboard/security"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list(CAMERANET_SS13)
	var/mapping = 0//For the overview file, interesting bit of code.

	var/list/list/our_actions = list() // assoc list of mob -> list/datum/action
	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/security/proc/init_action_buttons()
	var/datum/action/camera/previous/P = new(src)
	var/datum/action/camera/cancel/C = new(src)
	var/datum/action/camera/cyborg/C1 = new(src)
	var/datum/action/camera/listing/L = new(src)
	var/datum/action/camera/next/N = new(src)
	return list(P, C, C1, L, N)

/obj/machinery/computer/security/New()
	..()

	if (ticker && ticker.current_state  == GAME_STATE_PLAYING)
		init_cams()

	tv_monitors += src

/obj/machinery/computer/security/proc/init_cams()
	var/list/net = cameranet.cameras
	for (var/obj/machinery/camera/C in net)
		var/list/tempnet = C.network & network
		if (tempnet.len)
			current = C
			return

/obj/machinery/computer/security/Destroy()
	tv_monitors -= src
	our_actions.Cut() // removes our actions
	..()

/obj/machinery/computer/security/attack_ai(var/mob/user)
	if(istype(user, /mob/living/silicon/robot) || isMoMMI(user))
		if(Adjacent(user))
			src.add_hiddenprint(user)
			return attack_hand(user)
		else
			to_chat(user, "You need to get closer to the computer first.")
	else
		to_chat(user, "You have your built-in camera systems for this!") //currently too buggy to allow AI to use camera computers
	return //attack_hand(user)


/obj/machinery/computer/security/attack_paw(var/mob/user)
	return attack_hand(user)


/obj/machinery/computer/security/check_eye(var/mob/user)
	if ((!Adjacent(user) || user.isStunned() || user.blinded || !( current ) || !( current.status )))
		user.cancel_camera()
		return null
	user.reset_view(current)
	return 1


/obj/machinery/computer/security/attack_hand(var/mob/user)

	if (isobserver(user))
		return FALSE

	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	if(!is_operational())
		return

	if(!isAI(user))
		user.set_machine(src)

	if (!current || !(current.can_use())) // No suitable active camera
		init_cams()
	start_watching(user)

/obj/machinery/computer/security/proc/start_watching(mob/user)
	if (!current) // Did we find a camera
		to_chat(user, "<span class='warning'>No active cameras found.</span>")
		return

	var/list/user_actions = init_action_buttons()
	our_actions[user] = user_actions
	for(var/datum/action/action_datum in user_actions)
		action_datum.Grant(user)

	user.lazy_register_event(/lazy_event/on_moved, src, .proc/user_moved)

/obj/machinery/computer/security/proc/stop_watching(mob/user)
	user.cancel_camera()
	for(var/datum/action/action_datum in our_actions[user])
		action_datum.Remove(user)
		qdel(action_datum)
	our_actions -= user
	user.lazy_unregister_event(/lazy_event/on_moved, src, .proc/user_moved)

/obj/machinery/computer/security/proc/user_moved(mob/mover)
	if(is_in_range(mover))
		return
	stop_watching(mover)


/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching arena fights and variety shows."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list(CAMERANET_THUNDER)
	density = 0
	circuit = null
	layer = ABOVE_WINDOW_LAYER
	pass_flags = PASSTABLE
	light_color = null

/obj/machinery/computer/security/telescreen/examine(mob/user)
	..()
	if(current?.c_tag)
		to_chat(user, "Looks like the current channel is \"<span class='info'>[current.c_tag]</span>\"")

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have chicken-channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list(CAMERANET_THUNDER, CAMERANET_COURTROOM, CAMERANET_SPESSTV)
	density = 0
	circuit = null
	moody_light_type = /atom/movable/light/moody/statusdisplay
	lighting_flags = FOLLOW_PIXEL_OFFSET
	light_color = "#ffffff"
	light_power = 1
	light_range = 1

/obj/machinery/computer/security/telescreen/entertainment/spesstv
	name = "low-latency Spess.TV CRT monitor"
	desc = "An ancient computer monitor. They don't make them like they used to. A sticker reads: \"Come be their hero\"."
	icon = 'icons/obj/spesstv.dmi'
	icon_state = "crt"
	network = list(CAMERANET_SPESSTV)
	density = TRUE
	moody_light_type = null

/obj/machinery/computer/security/telescreen/entertainment/spesstv/is_operational()
	return TRUE

/obj/machinery/computer/security/telescreen/entertainment/spesstv/update_icon()

/obj/machinery/computer/security/telescreen/entertainment/spesstv/init_action_buttons()
	var/datum/action/camera/previous/P = new(src)
	var/datum/action/camera/cancel/C = new(src)
	var/datum/action/camera/listing/L = new(src)
	var/datum/action/camera/next/N = new(src)
	var/datum/action/camera/follow/F = new(src)
	var/datum/action/camera/subscribe/S = new(src)
	return list(P, C, L, N, F, S)

/obj/machinery/computer/security/telescreen/entertainment/spesstv/flatscreen
	name = "high-definition Spess.TV telescreen"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	circuit = /obj/item/weapon/circuitboard/security/spesstv

/obj/machinery/computer/security/telescreen/entertainment/spesstv/flatscreen/New()
	..()
	overlays += "spesstv_overlay"

/obj/machinery/computer/security/telescreen/entertainment/wooden_tv
	icon_state = "security_det"
	icon = 'icons/obj/computer.dmi'

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	circuit = /obj/item/weapon/circuitboard/security/wooden_tv
	light_color = null
	pass_flags = PASSTABLE

/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list(CAMERANET_MINE)
	circuit = "/obj/item/weapon/circuitboard/mining"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/security/proc/set_camera(var/mob/living/user, var/obj/machinery/camera/C)
	if(C)
		if ((!Adjacent(user) || user.machine != src || user.blinded || user.isStunned() || !( C.can_use() )) && (!istype(user, /mob/living/silicon/ai)))
			if(!C.can_use() && !isAI(user))
				src.current = null
			user.cancel_camera()
			return 0
		else
			if(isAI(user))
				var/mob/living/silicon/ai/A = user
				A.eyeobj.forceMove(get_turf(C))
				A.client.eye = A.eyeobj
			else
				src.current = C
				use_power(50)

	user.set_machine(src)
	user.reset_view(current)

/obj/machinery/computer/security/proc/next(var/mob/living/user)

	var/list/net = cameranet.cameras

	var/place = net.Find(current)
	if (!place) // Couldn't find the camera in the net ; it may have been destroyed
		user.cancel_camera()
		return FALSE
	var/place_0 = place // Prevent infinite loops if there is litteraly no next camera usuable.
	++place
	var/found = FALSE
	var/obj/machinery/camera/D

	while (!found && (place != place_0))
		D = net[place]
		var/list/tempnetwork = (D.network & network)
		if (tempnetwork.len && D.can_use()) // D.can_use() is false if the camera is EMP or whatever
			found = TRUE
		++place
		if (place > net.len)
			place = 1
	set_camera(user, D)

/obj/machinery/computer/security/proc/previous(var/mob/living/user)

	var/list/net = cameranet.cameras

	var/place = net.Find(current)
	if (!place) // Couldn't find the camera in the net ; it may have been destroyed
		user.cancel_camera()
		return FALSE
	var/place_0 = place // Prevent infinite loops if there is litteraly no next camera usuable.
	place--
	var/found = FALSE
	var/obj/machinery/camera/D

	while (!found  && (place != place_0))
		D = net[place]
		var/list/tempnetwork = (D.network & network)
		if (tempnetwork.len && D.can_use())
			found = TRUE
		place--
		if (place <= 0)
			place = net.len
	set_camera(user, D)


/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor engineering silicons and alarms."
	icon_state = "engineeringcameras"
	network = list(CAMERANET_ENGI,CAMERANET_POWERALARMS,CAMERANET_ATMOSALARMS,CAMERANET_FIREALARMS)
	circuit = "/obj/item/weapon/circuitboard/security/engineering"

	light_color = LIGHT_COLOR_YELLOW

/datum/action/camera
	var/obj/machinery/computer/security/our_computer
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS

/datum/action/camera/New(var/obj/machinery/computer/security/our_computer)
	. =..()
	src.our_computer = our_computer

/datum/action/camera/next
	name = "Next camera"
	desc = "Cycle to the next camera in the camera net."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "next"

/datum/action/camera/next/Trigger()
	our_computer.next(owner)

/datum/action/camera/previous
	name = "Previous camera"
	desc = "Cycle to the previous camera in the camera net."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "previous"

/datum/action/camera/previous/Trigger()
	our_computer.previous(owner)

/datum/action/camera/listing
	name = "Camera listing"
	desc = "List all the cameras in the net, then let you choose between them."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "listing"

/datum/action/camera/listing/Trigger()
	var/mob/living/user = owner
	if(!isAI(user))
		user.set_machine(our_computer)

	var/list/D = list()

	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(!istype(C.network, /list))
			var/turf/T = get_turf(C)
			WARNING("[C] - Camera at ([T.x],[T.y],[T.z]) has a non list for network, [C.network]")
			C.network = list(C.network)
		var/list/tempnetwork = C.network & our_computer.network
		if(tempnetwork.len)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D
	if(!t)
		user.cancel_camera()
		return 0
	user.set_machine(our_computer)

	var/obj/machinery/camera/C = D[t]

	our_computer.set_camera(user, C)

/datum/action/camera/cancel
	name = "Cancel camera view"
	desc = "Cancels the camera view."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "cancel"

/datum/action/camera/cancel/Trigger()
	var/obj/machinery/computer/security/console = target
	console.stop_watching(owner)

/datum/action/camera/follow
	name = "Follow!"
	desc = "Follow this streamer to be notified when they go online."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "follow"

/datum/action/camera/follow/Trigger()
	if(usr.incapacitated())
		return
	var/obj/machinery/computer/security/telescreen/entertainment/spesstv/tv = target
	if (!istype(tv))
		return
	if(!in_range(tv, usr))
		return
	var/obj/machinery/camera/arena/spesstv/camera = tv.current
	var/datum/role/streamer/streamer_role = camera.streamer

	streamer_role.try_add_follower(usr.mind)

/datum/action/camera/subscribe
	name = "Subscribe! ($250)"
	desc = "Support this streamer and get a subscriber badge and a loot box!"
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "subscribe"

/datum/action/camera/subscribe/Trigger()
	if(usr.incapacitated())
		return
	var/obj/machinery/computer/security/telescreen/entertainment/spesstv/tv = target
	if (!istype(tv))
		return
	if(!in_range(tv, usr))
		return
	var/obj/machinery/camera/arena/spesstv/camera = tv.current
	var/datum/role/streamer/streamer_role = camera.streamer

	streamer_role.try_add_subscription(usr.mind, tv)
/datum/action/camera/cyborg
	name = "Cyborg camera listing"
	desc = "List all the cyborg cameras conected to this network."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "robot"

/datum/action/camera/cyborg/Trigger()
	var/mob/living/user = owner
	if(!isAI(user))
		user.set_machine(our_computer)

	var/list/L = list()

	for (var/net in cyborg_cams)
		for(var/obj/machinery/camera/C in cyborg_cams[net])
			var/list/temp_network = (C.network & our_computer.network)
			if (temp_network.len)
				L[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	if (!L.len)
		to_chat(user, "<span class='warning'>No robots connected.</span>")

	var/t = input(user, "Which camera should you change to?") as null|anything in L
	if(!t || t == "Cancel")
		user.cancel_camera()
		return 0
	user.set_machine(our_computer)

	var/obj/machinery/camera/C = L[t]

	our_computer.set_camera(user, C)
