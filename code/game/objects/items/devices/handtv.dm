#define DEFAULT_MAP_SIZE 15

var/global/list/camera_bugs = list()
/obj/item/device/handtv
	name = "handheld tv"
	desc = "A handheld tv meant for remote viewing."
	icon_state = "handtv"
	w_class = W_CLASS_TINY
	var/network
	var/tgui_interface = "CameraConsole"
	var/list/cameras
	var/obj/item/device/camera_bug/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	// Stuff needed to render the map
	var/map_name
	var/obj/abstract/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/obj/abstract/screen/background/cam_background

/obj/item/device/handtv/New()
	..()
	if(world.has_round_started())
		initialize()

/obj/item/device/handtv/initialize()
	..()
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

/obj/item/device/handtv/attack_self(mob/user as mob)
	if(!network && user.mind)
		network = "\ref[user.mind]"
	cameras = list()
	for(var/obj/item/device/camera_bug/C in camera_bugs)
		if(C.network == network)
			cameras[ref(C)] = C
	if(!cameras.len)
		to_chat(user, "<span class='warning'>No camera bugs found.</span>")
		return
	tgui_interact(user)

/obj/item/device/handtv/tgui_interact(mob/user, datum/tgui/ui)
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

	if(loc != user)
		ui.close()

/obj/item/device/handtv/ui_data()
	var/list/data = list()
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			"name" = active_camera.c_tag,
			"ref" = ref(active_camera),
			"status" = active_camera.active,
		)
	return data

/obj/item/device/handtv/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/item/device/camera_bug/C = cameras[i]
		data["cameras"] += list(list(
			"name" = C.c_tag,
			"ref" = ref(C),
		))

	return data

/obj/item/device/handtv/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_ref = params["camera"]
		var/obj/item/device/camera_bug/selected_camera = cameras[c_ref]
		active_camera = selected_camera

		if(!selected_camera)
			return TRUE

		update_active_camera_screen()
		SStgui.update_uis(src) // Why do I have to this every time ?!

		return TRUE

/obj/item/device/handtv/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.active)
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

	for(var/turf/visible_turf in view(world.view, newturf))
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/item/device/handtv/ui_close(mob/user)
	// Unregister map objects
	user.client?.clear_map(map_name)

/obj/item/device/handtv/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

#undef DEFAULT_MAP_SIZE
