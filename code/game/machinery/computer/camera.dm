#define DEFAULT_MAP_SIZE 15

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
	var/obj/machinery/camera/active_camera
	var/list/network = list(CAMERANET_SS13)
	var/mapping = 0//For the overview file, interesting bit of code.
	var/tgui_interface = "CameraConsole"
	light_color = LIGHT_COLOR_RED

	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	// Stuff needed to render the map
	var/map_name
	var/obj/abstract/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/obj/abstract/screen/background/cam_background

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/apcfaker,
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet
	)

/obj/machinery/computer/security/initialize()
	..()
	tv_monitors += src
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	map_name = "camera_console_[ref(src)]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_screen.del_on_map_removal = FALSE
	cam_plane_masters = list()
	var/static/list/darkness_plane_things = list(
		/obj/abstract/screen/plane/master,
		/obj/abstract/screen/plane/dark
	)
	for(var/plane in subtypesof(/obj/abstract/screen/plane_master) + darkness_plane_things)
		var/obj/abstract/screen/instance = new plane()
		instance.assigned_map = map_name
		instance.screen_loc = "[map_name]:CENTER"
		instance.del_on_map_removal = FALSE
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/machinery/computer/security/Destroy()
	tv_monitors -= src
	..()

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/output = list()
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!islist(C.network))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			output["[C.c_tag]"] = C
	return output

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


/obj/machinery/computer/security/attack_hand(var/mob/user)
	if (isobserver(user))
		return FALSE

	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	if(!is_operational())
		return
	tgui_interact(user)

/obj/machinery/computer/security/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, tgui_interface)
		ui.open()

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["title"] = name
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))

	return data

/obj/machinery/computer/security/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/selected_camera = cameras[c_tag]
		active_camera = selected_camera

		if(!selected_camera)
			return TRUE

		active_camera.camera_twitch()

		update_active_camera_screen()

		return TRUE

/obj/machinery/computer/security/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(active_camera)
	if(last_camera_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = get_turf(newturf)

	var/list/visible_things = active_camera.isXRay() ? range(active_camera.view_range, newturf) : view(active_camera.view_range, newturf)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/machinery/computer/security/ui_close(mob/user)
	// Unregister map objects
	user.client.clear_map(map_name)

/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching arena fights and variety shows."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list(CAMERANET_THUNDER)
	density = 0
	circuit = null
	layer = ABOVE_WINDOW_LAYER
	pass_flags = PASSTABLE | PASSRAILING
	light_color = null

/obj/machinery/computer/security/telescreen/New()
	..()
	update_icon()

/obj/machinery/computer/security/telescreen/examine(mob/user)
	..()
	if(active_camera?.c_tag)
		to_chat(user, "Looks like the current channel is \"<span class='info'>[active_camera.c_tag]</span>\"")

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
		kill_moody_light()
	else
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_telescreen")

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have chicken-channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list(CAMERANET_THUNDER, CAMERANET_COURTROOM, CAMERANET_SPESSTV)
	density = 0
	circuit = null

	light_color = null

/obj/machinery/computer/security/telescreen/entertainment/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
		kill_moody_light()
	else
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_entertainment")

/obj/machinery/computer/security/telescreen/entertainment/spesstv
	name = "low-latency Spess.TV CRT monitor"
	desc = "An ancient computer monitor. They don't make them like they used to. A sticker reads: \"Come be their hero\"."
	icon = 'icons/obj/spesstv.dmi'
	icon_state = "crt"
	network = list(CAMERANET_SPESSTV)
	density = TRUE
	tgui_interface = "SpessTVCameraConsole"

/obj/machinery/computer/security/telescreen/entertainment/spesstv/New()
	..()
	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_crt")

/obj/machinery/computer/security/telescreen/entertainment/spesstv/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("follow")
			var/obj/machinery/camera/arena/spesstv/camera = active_camera
			if(!istype(camera))
				return
			var/datum/role/streamer/streamer_role = camera.streamer
			if(!istype(streamer_role))
				return
			streamer_role.try_add_follower(usr.mind)
		if("subscribe")
			var/obj/machinery/camera/arena/spesstv/camera = active_camera
			if(!istype(camera))
				return
			var/datum/role/streamer/streamer_role = camera.streamer
			if(!istype(streamer_role))
				return
			streamer_role.try_add_subscription(usr.mind, src)

/obj/machinery/computer/security/telescreen/entertainment/spesstv/is_operational()
	return TRUE

/obj/machinery/computer/security/telescreen/entertainment/spesstv/update_icon()

/obj/machinery/computer/security/telescreen/entertainment/spesstv/flatscreen
	name = "high-definition Spess.TV telescreen"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	circuit = /obj/item/weapon/circuitboard/security/spesstv

/obj/machinery/computer/security/telescreen/entertainment/spesstv/flatscreen/New()
	..()
	overlays += "spesstv_overlay"
	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_telescreen")

/obj/machinery/computer/security/telescreen/entertainment/wooden_tv
	icon_state = "security_det"
	moody_state = "overlay_security_det"
	icon = 'icons/obj/computer.dmi'

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	moody_state = "overlay_security_det"
	circuit = /obj/item/weapon/circuitboard/security/wooden_tv
	light_color = null
	pass_flags = PASSTABLE | PASSRAILING

/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list(CAMERANET_MINE)
	circuit = "/obj/item/weapon/circuitboard/mining"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor engineering silicons and alarms."
	icon_state = "engineeringcameras"
	network = list(CAMERANET_ENGI,CAMERANET_POWERALARMS,CAMERANET_ATMOSALARMS,CAMERANET_FIREALARMS)
	circuit = "/obj/item/weapon/circuitboard/security/engineering"

	light_color = LIGHT_COLOR_YELLOW

/obj/machinery/computer/security/nukies
	network = list(CAMERANET_SS13,CAMERANET_NUKE)

#undef DEFAULT_MAP_SIZE
