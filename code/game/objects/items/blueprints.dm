# define AREA_ERRNONE	0
# define AREA_STATION	1
# define AREA_SPACE		2
# define AREA_SPECIAL	3
# define AREA_BLUEPRINTS 4
# define AREA_CONSTRUCT 5

# define BORDER_ERROR   0
# define BORDER_NONE    1 //add, and continue branching
# define BORDER_BETWEEN 2 //nothing
# define BORDER_2NDTILE 3 //add, but do not continue searching in this direction
# define BORDER_SPACE   4 //reject room, space

# define ROOM_ERR_LOLWAT    0
# define ROOM_ERR_SPACE    -1
# define ROOM_ERR_TOOLARGE -2

var/global/list/blueprint_archives = list()

/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacks", "baps", "hits")
	w_type = RECYK_WOOD
	flammable = TRUE

	var/header = "<small>property of Nanotrasen. For heads of staff only. Store in high-secure storage.</small>"
	var/shows_archives = TRUE
	var/last_shown_archive

	var/can_create_areas_in = list(AREA_SPACE,AREA_CONSTRUCT)
	var/can_rename_areas = list(AREA_STATION, AREA_BLUEPRINTS)
	var/can_edit_areas = list(AREA_BLUEPRINTS)
	var/can_delete_areas = list(AREA_BLUEPRINTS)

	var/area/currently_edited
	var/image/edited_overlay

	//Maximum amount of turfs
	var/max_room_size = 300

	//Radius of the circle around APCs and air alarms, inside of which area editing can't be done
	var/area_protection_buffer = 4

	var/mob/editor

// below is non functional, uncomment if you want to have a go at this being available from a roundstart snapshot
/*/obj/item/blueprints/initialize()
	. = ..()
	if(shows_archives && !blueprint_archives.len)
		for(var/area/A in areas)
			if(get_area_type(A) == AREA_STATION)
				for(var/turf/T in A.area_turfs)
					update_turf_image(T)*/

/obj/item/blueprints/proc/update_turf_image(var/turf/T)
	var/image/overlay = image(T.icon,T,T.icon_state,T.layer,T.dir,T.pixel_x,T.pixel_y)
	overlay.plane = NARSIE_PLANE
	overlay.alpha = 128
	overlay.color = "#06f"
	blueprint_archives["[T.x],[T.y],[T.z]"] = list(overlay)
	for(var/atom/AM in T.contents)
		if(AM.type == /atom/movable/lighting_overlay)
			continue
		overlay = image(AM.icon,T,AM.icon_state,AM.layer,AM.dir,AM.pixel_x,AM.pixel_y)
		overlay.plane = NARSIE_PLANE
		overlay.alpha = 128
		overlay.color = "#0af"
		blueprint_archives["[T.x],[T.y],[T.z]"] += overlay

//MoMMI blueprints
/obj/item/blueprints/mommiprints
	name = "MoMMI station blueprints"
	desc = "Blueprints of the station, designed for the passive aggressive spider bots aboard."

	can_rename_areas = list(AREA_BLUEPRINTS)
	can_delete_areas = list(AREA_BLUEPRINTS)

	header = "<small>These blueprints are for the creation of new rooms only; you cannot change existing rooms.</small>"

/* construction permits. Think blueprints but accessible to all engies and does NOT count as the antag steal objective
these cannot rename rooms that are in by default BUT can rename rooms that are created via blueprints/permit  */
/obj/item/blueprints/construction_permit
	name = "construction permit"
	desc = "An electronic permit designed to register a room for the use of APC and air alarms."
	icon = 'icons/obj/items.dmi'
	icon_state = "permit"

	w_class = W_CLASS_TINY
	shows_archives = FALSE

	can_rename_areas = list(AREA_BLUEPRINTS)
	can_delete_areas = list(AREA_BLUEPRINTS)

	header = "<small>This permit is for the creation of new rooms only; you cannot change existing rooms.</small>"

//Special blueprints that can edit station areas
/obj/item/blueprints/admin
	name = "universe blueprints"
	desc = "Blueprints of the universe. There is a \"Classified\" stamp and several coffee stains on it."

	can_rename_areas = list(AREA_STATION, AREA_BLUEPRINTS, AREA_SPECIAL)
	can_edit_areas = list(AREA_BLUEPRINTS, AREA_STATION, AREA_SPECIAL)
	can_delete_areas = list(AREA_BLUEPRINTS, AREA_STATION, AREA_SPECIAL)
	area_protection_buffer = -1

//Chief engineer's blueprints
/obj/item/blueprints/primary
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."

	can_edit_areas = list(AREA_BLUEPRINTS, AREA_STATION)
	can_delete_areas = list(AREA_BLUEPRINTS, AREA_STATION)


/obj/item/blueprints/primary/photography_act(var/obj/item/device/camera/camera)
	camera.blueprints = 1

/obj/item/blueprints/attack_self(mob/living/M)
	if (!ishigherbeing(M) && !issilicon(M))
		to_chat(M, "This stack of blue paper means nothing to you.")//monkeys cannot into projecting
		return

	if(currently_edited)
		if(editor && editor.client)
			stop_editing()
			return

	interact()
	return

/obj/item/blueprints/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["action"])
		if("show_room")
			show_room(usr)

		if("update_room")
			update_room(usr)

		if("create_room")
			create_room(usr)

		if("create_area")
			create_area(usr)

		if("rename_area")
			rename_area(usr)

		if("edit_area")
			edit_area(usr)

		if("delete_area")
			delete_area(usr)

/obj/item/blueprints/interact()
	var/area/A = get_area(src)
	var/text = {"<HTML><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<hr>
"}

	var/area_type = get_area_type()
	switch (area_type)
		if (AREA_SPACE)
			text += "<p>According to the blueprints, you are now in <b>outer space</b>.  Hold your breath.</p>"
		if (AREA_CONSTRUCT)
			text += "<p>According to the blueprints, you are now in <b>\"[A.name]\"</b>. Time to build!</p>"
		if (AREA_STATION)
			text += "<p>According to the blueprints, you are now in <b>\"[A.name]\"</b>.</p>"
		if (AREA_SPECIAL)
			text += "<p>This place isn't noted on the blueprint.</p>"
		if (AREA_BLUEPRINTS)
			text += "<p>According to the blueprints, you are now in <b>\"[A.name]\"</b> This drawing seems to be relatively new.</p>"

		else
			return

	text += "<br>"

	if(shows_archives)
		text += "<p><a href='?src=\ref[src];action=show_room'>Show archive of surroundings</a></p>"
		text += "<p><a href='?src=\ref[src];action=update_room'>Update archive of surroundings</a></p>"
	if(area_type in can_create_areas_in)
		text += "<p><a href='?src=\ref[src];action=create_room'>Create a new room</a></p>"
		text += "<p><a href='?src=\ref[src];action=create_area'>Start a new drawing</a></p>"
	if(area_type in can_rename_areas)
		text += "<p><a href='?src=\ref[src];action=rename_area'>Change the drawing's name</a></p>"
	if(area_type in can_edit_areas)
		text += "<p><a href='?src=\ref[src];action=edit_area'>Move an amendment to the drawing</a></p>"
	if(area_type in can_delete_areas)
		text += "<p><a href='?src=\ref[src];action=delete_area'>Erase this drawing</a></p>"

	text += "</BODY></HTML>"
	usr << browse(text, "window=blueprints")
	onclose(usr, "blueprints")

/obj/item/blueprints/proc/get_area_type(var/area/A)
	if(!A)
		A = get_area(src)
	if (isspace(A))
		return AREA_SPACE
	else if(A.construction_zone)
		return AREA_CONSTRUCT
	else if(istype(A, /area/station/custom))
		return AREA_BLUEPRINTS

	var/list/SPECIALS = list(
		/area/shuttle,
		/area/admin,
		/area/arrival,
		/area/centcom,
		/area/asteroid,
		/area/tdome,
		/area/wizard_station,
		/area/prison,
		/area/vault,
		/area/surface/blizzard
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION


/obj/item/blueprints/process()
	//Blueprints must be in hands to be usable
	//Editor must be in the edited area
	var/turf/turf_loc = get_turf(editor)
	if(!istype(editor) || !editor.client || !currently_edited || (loc != editor) || turf_loc.loc != currently_edited )
		if(editor)
			to_chat(editor, "<span class='info'>You finish modifying \the [src].</span>")

		return stop_editing()


/obj/item/blueprints/proc/stop_editing()
	if(editor && editor.client)
		editor.client.images.Remove(edited_overlay)

	editor = null
	edited_overlay = null
	currently_edited = null
	processing_objects.Remove(src)

//Air alarms and APCs have a zone around them, in which turfs can't be removed from the area
//This proc returns either the air alarm, or the APC that obstruct the editing
/obj/item/blueprints/proc/get_removal_obstruction(turf/T, area/A)
	if(area_protection_buffer >= 0)
		//Check for nearby air alarms
		for(var/obj/machinery/alarm/air_alarm in A)
			if(get_dist(T, air_alarm) <= area_protection_buffer)
				return air_alarm

		//Check for nearby APCs
		for(var/obj/machinery/power/apc/apc in A)
			if(get_dist(T, apc) <= area_protection_buffer)
				return apc

	return null

/obj/item/blueprints/afterattack(atom/A, mob/user, proximity)
	if(!currently_edited)
		return

	//Click on a turf = add it to the edited area or remove it from the edited area
	var/turf/T = get_turf(A)
	if(isturf(T))
		var/area/fill_area = get_base_area(A.z)
		var/area/target_area = T.loc
		var/area_type = get_area_type(target_area)

		if(target_area == currently_edited) //Removing the turf from the current area
			//Check if there are any APCs or air alarms nearby
			var/atom/obstacle = get_removal_obstruction(T, target_area)
			if(!obstacle)
				T.set_area(fill_area)
			else
				to_chat(user, "<span class='notice'>A nearby [obstacle.name] prevents you from doing that.</span>")

		else if(area_type == AREA_SPACE || area_type == AREA_CONSTRUCT)
			T.set_area(currently_edited) //Add to current area
		else
			#define error_flash_dur 30
			//Create a temporary image that marks the conflicting area's borders
			var/image/bad_area = image('icons/turf/areas.dmi', target_area, "purple")
			animate(bad_area, alpha = 0, time = error_flash_dur)

			var/client/C = editor.client
			C.images.Add(bad_area)
			//The 'editor' might change in two seconds. This will pretty much guarantee the image is removed
			spawn(error_flash_dur)
				C.images.Remove(bad_area)

			#undef error_flash_dur

//Shows an archive of surrounding tiles
/obj/item/blueprints/proc/show_room(mob/user)
	if(shows_archives && user.client)
		var/list/shown_images = list()
		var/tstring = ""
		for(var/turf/T in spiral_block(get_turf(user),user.client.view))
			tstring = "[T.x],[T.y],[T.z]"
			if(tstring in blueprint_archives)
				for(var/I in blueprint_archives[tstring])
					shown_images += I
					user.client.images += I
		last_shown_archive = world.time
		spawn(10 SECONDS)
			if(world.time - last_shown_archive >= 99) // sanity for mass clicking of this
				user.client.images -= shown_images

/obj/item/blueprints/proc/update_room(mob/user)
	if(shows_archives)
		if(blueprint_archives.len)
			if(alert(usr,"This will overwrite any archives, continue?","Overwriting","Yes","No") == "No")
				return
		for(var/turf/T in view(user.client.view))
			update_turf_image(T)

//Creates a new area and spreads it to cover the current room
/obj/item/blueprints/proc/create_room(mob/user)
	if(!(get_area_type() in can_create_areas_in))
		to_chat(user, "There is no space on \the [src] for another drawing.")
		return

	var/res = detect_room(get_turf(usr))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				to_chat(usr, "<span class='warning'>The new area must be completely airtight!</span>")
				return
			if(ROOM_ERR_TOOLARGE)
				to_chat(usr, "<span class='warning'>The new area too large!</span>")
				return
			else
				to_chat(usr, "<span class='warning'>Error! Please notify administration!</span>")
				return

	create_area(user, res)

//Creates a new area
/obj/item/blueprints/proc/create_area(mob/user, list/new_turfs = null)
	if(!(get_area_type() in can_create_areas_in))
		to_chat(user, "There is no space on \the [src] for another drawing.")
		return

	var/str = trim(stripped_input(usr,"New area name:","Blueprint Editing", "", MAX_NAME_LEN))
	if(!str || !length(str) || !Adjacent(user)) //cancel
		return
	if(length(str) > 50)
		to_chat(usr, "<span class='warning'>Name too long.</span>")
		return

	var/area/station/custom/newarea = new
	newarea.name = str
	newarea.tag = "[newarea.type]/[md5(str)]"

	if(islist(new_turfs))
		for(var/turf/T in new_turfs)
			T.set_area(newarea)
	else
		//Enter editing mode immediately, if not given an initial list of turfs
		var/turf/T = get_turf(user)
		T.set_area(newarea)

		edit_area(user)

	ghostteleportlocs[newarea.name] = newarea

	sleep(5)
	interact()

/obj/item/blueprints/proc/edit_area(mob/user)
	if(!user || !user.client)
		return
	if(currently_edited)
		stop_editing()
		return
	if(!(get_area_type() in can_edit_areas))
		to_chat(user, "You can't edit this drawing.")
		return

	if(currently_edited)
		stop_editing()

	editor = user

	currently_edited = get_area(src)
	processing_objects.Add(src)

	//Create a visual effect over the edited area
	edited_overlay = image('icons/turf/areas.dmi', currently_edited, "yellow")
	edited_overlay.plane = ABOVE_LIGHTING_PLANE
	editor.client.images.Add(edited_overlay)

	to_chat(editor, "<span class='info'>In this mode, you can add or modify tiles to the [currently_edited] area. When you're done, bring up the blueprints or leave the area.</span>")

/obj/item/blueprints/proc/rename_area(mob/user)
	if(!(get_area_type() in can_rename_areas))
		to_chat(user, "This drawing was already signed, and can't be renamed.")
		return

	var/area/A = get_area(src)

	if(!istype(A) || !istype(user))
		return

	var/prevname = "[A.name]"
	var/str = trim(stripped_input(user, "New area name:","Blueprint Editing", prevname, MAX_NAME_LEN))
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(!istype(A) || !istype(user))
		return
	if(!Adjacent(user))
		return

	if(length(str) > 50)
		to_chat(user, "<span class='warning'>Name too long.</span>")
		return

	A.name = str
	for(var/atom/allthings in A.contents)
		allthings.change_area_name(prevname,str)

	to_chat(user, "<span class='notice'>You change \the [prevname]'s title to '[str]'.</span>")

/obj/item/blueprints/proc/delete_area(var/mob/user)
	if(!(get_area_type() in can_delete_areas))
		to_chat(user, "This drawing can't be erased.")
		return

	var/area/areadeleted = get_area(src)

	if(area_protection_buffer >= 0)
		for(var/obj/machinery/alarm/air_alarm in areadeleted)
			to_chat(user, "<span class='notice'>You can't erase an area with an air alarm in it!</span>")
			return
		for(var/obj/machinery/power/apc/apc in areadeleted)
			to_chat(user, "<span class='notice'>You can't erase an area with an APC in it!</span>")
			return

	if(alert(usr,"Are you sure you want to erase \"[areadeleted]\" from the blueprints?","Blueprint Editing","Yes","No") != "Yes")
		return
	if(!Adjacent(user))
		return
	if(!(areadeleted == get_area(src)))
		return //if the blueprints are no longer in the area, return

	var/area/fill_area
	for(var/turf/T in areadeleted)
		if(!fill_area)
			fill_area = get_base_area(T.z)
		T.set_area(fill_area)

	to_chat(usr, "You've erased the \"[areadeleted]\" from the blueprints.")

//Room auto-fill procs

/obj/item/blueprints/proc/check_tile_is_border(var/turf/T2,var/dir)
	if (istype(T2, /turf/space))
		return BORDER_SPACE //omg hull breach we all going to die here
	if (isshuttleturf(T2))
		return BORDER_SPACE
	var/areatype = get_area_type(T2.loc)
	if (areatype != AREA_SPACE && areatype != AREA_CONSTRUCT)
		return BORDER_BETWEEN //found something part of a non-buildable area, like a preexisting structure
	if (istype(T2, /turf/simulated/wall))
		return BORDER_2NDTILE
	if (!istype(T2, /turf/simulated))
		return BORDER_BETWEEN

	for (var/obj/structure/window/W in T2)
		if(turn(dir,180) == W.dir)
			return BORDER_BETWEEN
		if (W.is_fulltile)
			return BORDER_2NDTILE
	for(var/obj/machinery/door/window/D in T2)
		if(turn(dir,180) == D.dir)
			return BORDER_BETWEEN
	if (locate(/obj/machinery/door) in T2)
		return BORDER_2NDTILE
	if (locate(/obj/structure/falsewall) in T2)
		return BORDER_2NDTILE

	return BORDER_NONE

/obj/item/blueprints/proc/detect_room(var/turf/first)
	var/list/turf/found = new
	var/list/turf/pending = list(first)
	while(pending.len)
		if (found.len+pending.len > max_room_size)
			return ROOM_ERR_TOOLARGE
		var/turf/T = pending[1] //why byond havent list::pop()?
		pending -= T
		for (var/dir in cardinal)
			var/skip = 0
			for (var/obj/structure/window/W in T)
				if(dir == W.dir || W.is_fulltile)
					skip = 1; break
			if (skip)
				continue
			for(var/obj/machinery/door/window/D in T)
				if(dir == D.dir)
					skip = 1; break
			if (skip)
				continue

			var/turf/NT = get_step(T,dir)
			if (!isturf(NT) || (NT in found) || (NT in pending))
				continue

			switch(check_tile_is_border(NT,dir))
				if(BORDER_NONE)
					pending+=NT
				if(BORDER_BETWEEN)
					//do nothing, may be later i'll add 'rejected' list as optimization
				if(BORDER_2NDTILE)
					found+=NT //tile included to new area, but we dont seek more
				if(BORDER_SPACE)
					return ROOM_ERR_SPACE
		found+=T
	return found


/**
	Turns the area the person is currently in into a shuttle if it meets to certian standards
		- Is a custom area. No players turning the bar into a shuttle
		- Has enough engines that are active
			- 2 engines minimum
			- 1 engine for every 15 tiles of area.
			- Engines must be of the DIY variety, and have a connected heater.
		- The point they are facing is outwards on the edge of the area
*/

#define CUSTOM_SHUTTLE_TILES_PER_ENGINE 15 // centralized config thingy. #de[B]ines 4 lyfe, performance forever


/obj/item/shuttle_license
	name = "shuttle verification license"
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	desc = "Required for turning a dull room with some engines in the back into something that can move through space!"
	var/area_requirement_override = FALSE //so admins can allow a licence to turn any area into a shuttle

/obj/item/shuttle_license/attack_self(mob/user)
	to_chat(user, "<span class = 'notice'>Checking current area...</span>")
	var/area/A = get_area(user)
	if(!area_requirement_override && !istype(A, /area/station/custom))
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: Custom areas only.</span>")
		return

	var/datum/shuttle/conflict = A.get_shuttle()

	if(conflict)
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: This area is already marked as a shuttle.</span>")
		return

	var/area_size = A.area_turfs.len
	var/active_engines = 0
	for(var/obj/structure/shuttle/engine/propulsion/DIY/D in A)
		if(D.anchored)
			if(D.heater) // it has a heater, great, count it
				active_engines++
			else // fix for engines getting their internal state desyncronized from what is actually happening
				if(D.try_connect())
					active_engines++
				else if (D.retard_checks() && D.try_connect())
					active_engines++

	if(active_engines < 2 || area_size/active_engines > CUSTOM_SHUTTLE_TILES_PER_ENGINE) // 1 engine per 15 tiles, with a minimum of 2 engines.
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: Insufficient engine count.</span>")
		to_chat(user, "<span class = 'notice'> Detected [active_engines] of [max(2, Ceiling(area_size/CUSTOM_SHUTTLE_TILES_PER_ENGINE))] engines required for a [area_size] square meter shuttle.<br>1 engine required for every [CUSTOM_SHUTTLE_TILES_PER_ENGINE] square meters, 2 engines minimum.</span>")
		return

	var/turf/check_turf = get_step(user, user.dir)

	if(get_area(check_turf) == A)
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: Unable to create docking port at current user location.</span>")
		return

	to_chat(user, "<span class = 'notice'>Checks complete. Turning area into shuttle.</span>")

	var/name = copytext(sanitize(input(user, "Please name the new shuttle", "Shuttlify", A.name) as text|null),1,MAX_NAME_LEN)

	if(!name)
		to_chat(user, "Shuttlifying cancelled.")
		return

	var/obj/docking_port/shuttle/DP = new /obj/docking_port/shuttle(get_turf(src))
	DP.dir = user.dir
	// Link the custom shuttle to a basic homing port to return to.
	var/turf/home_base = get_step(get_turf(DP), DP.dir)
	var/obj/docking_port/destination/my_shuttle_home_base = new(home_base)
	my_shuttle_home_base.name = "[name] home port"
	my_shuttle_home_base.dir = opposite_dirs[DP.dir]

	var/datum/shuttle/custom/S = new(starting_area = A)
	S.initialize()
	S.name = name
	S.linked_port.docked_with = my_shuttle_home_base

	to_chat(user, "<span class='notice'>Shuttle created!</span>")
	var/obj/item/weapon/disk/shuttle_coords/my_docking_port_dest = new(get_turf(src))
	my_docking_port_dest.destination = my_shuttle_home_base
	my_docking_port_dest.name = "[name] home port"
	my_docking_port_dest.desc = "This disc links to the home base of [user]'s custom shuttle, [name]."
	my_docking_port_dest.header = "[name] home port"
	user.put_in_hands(my_docking_port_dest)
	to_chat(user, "<span class='notice'>Congratulations! You have succesfully created a shuttle. You will find in your hands the destination disk linked to your home base, which is where you created the shuttle. Don't lose it, it cannot be replaced!</span>")
	to_chat(user, "<span class='notice'><h3>Happy hunting!</h3></span>")

	message_admins("<span class='notice'>[key_name_admin(user)] has turned [A.name] into a shuttle named [S.name]. [formatJumpTo(get_turf(user))]</span>")
	log_admin("[key_name(user)]  has turned [A.name] into a shuttle named [S.name].")
	qdel(src)
#undef CUSTOM_SHUTTLE_TILES_PER_ENGINE
