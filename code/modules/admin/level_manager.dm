/datum/level_manager
	var/mob/user
	var/datum/station_holomap/active_holomap = null
	var/active_holomap_z = null  // Only tracks holomaps (z <= 6), not MindUI

/datum/level_manager/New(mob/M)
	user = M

/datum/level_manager/Destroy()
	close_holomap()
	..()

/datum/level_manager/proc/close_holomap()
	if(active_holomap && user && user.client)
		user.client.images -= active_holomap.station_map
		animate(active_holomap.station_map, alpha = 0, time = 5, easing = LINEAR_EASING)
		QDEL_NULL(active_holomap)
		active_holomap_z = null

/datum/level_manager/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LevelManager")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/level_manager/ui_data(mob/user)
	var/list/data = list()
	data["zLevels"] = list()

	for(var/z_index = 1 to map.zLevels.len)
		var/datum/zLevel/Z = map.zLevels[z_index]
		if(!Z)
			continue

		var/list/z_data = list()
		z_data["index"] = z_index
		z_data["name"] = Z.name
		z_data["ref"] = "\ref[Z]"
		z_data["vLevelCount"] = Z.virtual_z_levels.len
		z_data["hasHolomap"] = ((HOLOMAP_EXTRA_STATIONMAP + "_[Z.z]") in extraMiniMaps)
		z_data["usesHolomap"] = !istype(Z, /datum/zLevel/dynamic)

		// Check if map is active - holomap for static z-levels, MindUI for dynamic
		var/map_active = FALSE
		if(z_data["usesHolomap"])
			map_active = (active_holomap_z == Z.z)
		else if(user && user.mind && ("zlevel_map" in user.mind.activeUIs))
			var/datum/mind_ui/zlevel_map/zmap = user.mind.activeUIs["zlevel_map"]
			// Only consider it active if it's actually showing AND it's showing this z-level
			// We check the first virtual_z_display element to see which z it's displaying
			if(zmap && zmap.active)
				for(var/obj/abstract/mind_ui_element/hoverable/virtual_z_display/vz_disp in zmap.elements)
					if(vz_disp.v && vz_disp.v.parent_z.z == Z.z)
						map_active = TRUE
						break

		z_data["holomapActive"] = map_active
		z_data["vLevels"] = list()

		for(var/datum/virtual_z/V in Z.virtual_z_levels)
			var/list/v_data = list()
			v_data["id"] = V.id
			v_data["name"] = V.name
			v_data["ref"] = "\ref[V]"
			v_data["active"] = V.active
			v_data["sizeX"] = V.size_x
			v_data["sizeY"] = V.size_y

			// Get mobs and count processing/paused
			var/list/mob/mobs_list = V.get_mobs()
			var/list/mob/players_list = V.get_players()
			var/processing_mobs = 0
			var/paused_mobs = 0

			for(var/mob/living/L in mobs_list)
				if(L.paused)
					paused_mobs++
				else
					processing_mobs++

			v_data["players"] = players_list.len
			v_data["processingMobs"] = processing_mobs
			v_data["pausedMobs"] = paused_mobs

			// Planet and shuttle data
			if(V.planet)
				v_data["planetRef"] = "\ref[V.planet]"
				v_data["planetName"] = V.planet.name
			if(V.linked_shuttle)
				v_data["shuttleRef"] = "\ref[V.linked_shuttle]"
				v_data["shuttleName"] = V.linked_shuttle.name

			// Settings data
			v_data["movementJammed"] = V.movementJammed
			v_data["gpsAllowed"] = V.gps_allowed
			v_data["teleJammed"] = V.teleJammed
			v_data["transitionLoops"] = V.transitionLoops
			v_data["transitionChannel"] = V.transition_channel

			// Transition crosswrap data
			if(V.transition_crosswrap_v && V.transition_crosswrap_v.len >= 4)
				v_data["crosswrapNorth"] = V.transition_crosswrap_v[1]
				v_data["crosswrapSouth"] = V.transition_crosswrap_v[2]
				v_data["crosswrapEast"] = V.transition_crosswrap_v[3]
				v_data["crosswrapWest"] = V.transition_crosswrap_v[4]
				v_data["hasCrosswrap"] = TRUE
			else
				v_data["hasCrosswrap"] = FALSE

			z_data["vLevels"] += list(v_data)

		data["zLevels"] += list(z_data)

	return data

/datum/level_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("jump")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				to_chat(usr, "<span class='warning'>Invalid virtual z-level reference.</span>")
				return FALSE
			var/center_x = round((V.x_min + V.x_max) / 2)
			var/center_y = round((V.y_min + V.y_max) / 2)
			var/turf/T = locate(center_x, center_y, V.parent_z.z)
			if(T)
				usr.forceMove(T)
				log_admin("[key_name(usr)] jumped to vZ-[V.id] ([V.name]) at [center_x],[center_y],[V.parent_z.z].")
				message_admins("<span class='notice'>[key_name_admin(usr)] jumped to vZ-[V.id] ([V.name]).</span>", 1)
			return TRUE

		if("toggle_pause")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				to_chat(usr, "<span class='warning'>Invalid virtual z-level reference.</span>")
				return FALSE
			V.set_status(!V.active)
			log_admin("[key_name(usr)] [V.active ? "activated" : "paused"] vZ-[V.id] ([V.name]).")
			message_admins("<span class='notice'>[key_name_admin(usr)] [V.active ? "activated" : "paused"] vZ-[V.id] ([V.name]).</span>", 1)
			return TRUE

		if("vv_zlevel")
			var/datum/zLevel/Z = locate(params["ref"])
			if(!Z || !istype(Z))
				return FALSE
			usr.client.debug_variables(Z)
			return TRUE

		if("vv_vlevel")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE
			usr.client.debug_variables(V)
			return TRUE

		if("vv_planet")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V) || !V.planet)
				return FALSE
			usr.client.debug_variables(V.planet)
			return TRUE

		if("vv_shuttle")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V) || !V.linked_shuttle)
				return FALSE
			usr.client.debug_variables(V.linked_shuttle)
			return TRUE

		if("toggle_movement_jam")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE
			V.movementJammed = !V.movementJammed
			V.update_settings()
			log_admin("[key_name(usr)] [V.movementJammed ? "enabled" : "disabled"] movement jamming for vZ-[V.id] ([V.name]).")
			return TRUE

		if("toggle_gps")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE
			V.gps_allowed = !V.gps_allowed
			log_admin("[key_name(usr)] [V.gps_allowed ? "enabled" : "disabled"] GPS for vZ-[V.id] ([V.name]).")
			return TRUE

		if("cycle_teleport")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE
			// Cycle through: ALLOWED -> EXPENSIVE -> FORBIDDEN -> ALLOWED
			switch(V.teleJammed)
				if(VZ_TELEPORTATION_ALLOWED)
					V.teleJammed = VZ_TELEPORTATION_EXPENSIVE
				if(VZ_TELEPORTATION_EXPENSIVE)
					V.teleJammed = VZ_TELEPORTATION_FORBIDDEN
				if(VZ_TELEPORTATION_FORBIDDEN)
					V.teleJammed = VZ_TELEPORTATION_ALLOWED
				else
					V.teleJammed = VZ_TELEPORTATION_FORBIDDEN
			var/tele_text
			switch(V.teleJammed)
				if(VZ_TELEPORTATION_ALLOWED)
					tele_text = "allowed"
				if(VZ_TELEPORTATION_EXPENSIVE)
					tele_text = "expensive (requires crystals)"
				if(VZ_TELEPORTATION_FORBIDDEN)
					tele_text = "forbidden"
			log_admin("[key_name(usr)] set teleportation to [tele_text] for vZ-[V.id] ([V.name]).")
			return TRUE

		if("toggle_transition_loops")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE
			V.transitionLoops = !V.transitionLoops
			log_admin("[key_name(usr)] [V.transitionLoops ? "enabled" : "disabled"] transition loops for vZ-[V.id] ([V.name]).")
			return TRUE

		if("change_transition_channel")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE

			// Build list of existing channels
			var/list/channel_choices = list()
			for(var/channel_name in accessable_v_levels)
				channel_choices += channel_name
			channel_choices += "Create New Channel..."

			var/old_channel = V.transition_channel
			var/channel_choice = input(usr, "Select transition channel for vZ-[V.id] ([V.name]):\n(Current: [old_channel])", "Transition Channel") as null|anything in channel_choices
			if(!channel_choice)
				return FALSE

			var/new_channel = channel_choice
			if(channel_choice == "Create New Channel...")
				new_channel = input(usr, "Enter name for new transition channel:", "New Channel") as null|text
				if(!new_channel)
					return FALSE
				// Create the new channel if it doesn't exist
				if(!(new_channel in accessable_v_levels))
					accessable_v_levels[new_channel] = list()

			// Remove from old channel if not movement jammed
			if(!V.movementJammed && (old_channel in accessable_v_levels))
				accessable_v_levels[old_channel] -= "[V.id]"

			// Update the channel
			V.transition_channel = new_channel

			// Add to new channel if not movement jammed
			if(!V.movementJammed)
				if(!(new_channel in accessable_v_levels))
					accessable_v_levels[new_channel] = list()
				accessable_v_levels[new_channel] += list("[V.id]" = V.movementChance)

			log_admin("[key_name(usr)] changed transition channel for vZ-[V.id] ([V.name]) from '[old_channel]' to '[new_channel]'.")
			return TRUE

		if("configure_crosswrap")
			var/datum/virtual_z/V = locate(params["ref"])
			if(!V || !istype(V))
				return FALSE

			// Build list of available vLevels for selection
			var/list/vlevel_choices = list("None" = null)
			for(var/datum/virtual_z/vz in map.getAllVLevels())
				if(vz.id != V.id) // Don't allow self-reference
					vlevel_choices["vZ-[vz.id]: [vz.name]"] = vz.id

			// Get current values
			var/current_north = null
			var/current_south = null
			var/current_east = null
			var/current_west = null
			if(V.transition_crosswrap_v && V.transition_crosswrap_v.len >= 4)
				current_north = V.transition_crosswrap_v[1]
				current_south = V.transition_crosswrap_v[2]
				current_east = V.transition_crosswrap_v[3]
				current_west = V.transition_crosswrap_v[4]

			// Ask for each direction
			var/north_choice = input(usr, "Select vLevel to crosswrap NORTH edge to:\n(Current: [current_north ? "vZ-[current_north]" : "None"])", "Crosswrap North") as null|anything in vlevel_choices
			var/south_choice = input(usr, "Select vLevel to crosswrap SOUTH edge to:\n(Current: [current_south ? "vZ-[current_south]" : "None"])", "Crosswrap South") as null|anything in vlevel_choices
			var/east_choice = input(usr, "Select vLevel to crosswrap EAST edge to:\n(Current: [current_east ? "vZ-[current_east]" : "None"])", "Crosswrap East") as null|anything in vlevel_choices
			var/west_choice = input(usr, "Select vLevel to crosswrap WEST edge to:\n(Current: [current_west ? "vZ-[current_west]" : "None"])", "Crosswrap West") as null|anything in vlevel_choices

			// Get the vLevel IDs from the choices
			var/north_id = vlevel_choices[north_choice]
			var/south_id = vlevel_choices[south_choice]
			var/east_id = vlevel_choices[east_choice]
			var/west_id = vlevel_choices[west_choice]

			// Check if all are null - if so, clear the crosswrap
			if(!north_id && !south_id && !east_id && !west_id)
				V.transition_crosswrap_v = null
				log_admin("[key_name(usr)] cleared transition crosswraps for vZ-[V.id] ([V.name]).")
			else
				V.transition_crosswrap_v = list(north_id, south_id, east_id, west_id)
				log_admin("[key_name(usr)] set transition crosswraps for vZ-[V.id] ([V.name]): N=[north_id], S=[south_id], E=[east_id], W=[west_id].")

			return TRUE

		if("create_zlevel")
			// Build list of available zLevel types
			var/list/zlevel_types = list(
				"Dynamic" = /datum/zLevel/dynamic,
				"Space" = /datum/zLevel/space,
				"Mining" = /datum/zLevel/mining,
				"Away" = /datum/zLevel/away
			)
			var/type_choice = input(usr, "Select Z-Level type:", "New Z-Level") as null|anything in list("Dynamic", "Space", "Mining", "Away")
			if(!type_choice)
				return FALSE
			var/zlevel_type = zlevel_types[type_choice]

			var/name = input(usr, "Enter a name for the new Z-Level:", "New Z-Level") as null|text
			if(!name)
				return FALSE

			// Increment world.maxz and create the new zLevel
			skip_turf_init = TRUE
			world.maxz++
			skip_turf_init = FALSE

			var/datum/zLevel/new_z = new zlevel_type()
			new_z.name = name
			new_z.z = world.maxz
			map.zLevels += new_z

			log_admin("[key_name(usr)] created a new Z-Level: [name] (Z: [world.maxz], Type: [type_choice]).")
			message_admins("<span class='notice'>[key_name_admin(usr)] created a new Z-Level: [name] (Z: [world.maxz], Type: [type_choice]).</span>", 1)
			return TRUE

		if("show_map")
			var/datum/zLevel/Z = locate(params["ref"])
			if(!Z || !istype(Z))
				to_chat(usr, "<span class='warning'>Invalid z-level reference.</span>")
				return FALSE

			// Static z-levels use holomap, dynamic z-levels use MindUI
			if(!istype(Z, /datum/zLevel/dynamic))
				// Toggle holomap for base z-levels
				if(active_holomap_z == Z.z)
					// Close currently active holomap
					close_holomap()
					to_chat(usr, "<span class='notice'>Closed holomap for Z-Level [Z.z]: [Z.name]</span>")
					log_admin("[key_name(usr)] closed holomap for Z-[Z.z] ([Z.name]).")
					return TRUE

				// Show holomap for base z-levels
				if(!usr.client || !usr.hud_used || !usr.hud_used.holomap_obj)
					to_chat(usr, "<span class='warning'>Cannot display holomap - HUD not available.</span>")
					return FALSE

				// Check if holomap exists for this z-level
				var/holomap_key = HOLOMAP_EXTRA_STATIONMAP + "_[Z.z]"
				if(!(holomap_key in extraMiniMaps))
					to_chat(usr, "<span class='warning'>No holomap available for Z-Level [Z.z].</span>")
					return FALSE

				// Close any existing holomap first
				close_holomap()

				// Create new holomap datum
				active_holomap = new()
				active_holomap_z = Z.z
				var/turf/target_turf = locate(round(world.maxx/2), round(world.maxy/2), Z.z)
				if(!target_turf)
					to_chat(usr, "<span class='warning'>Failed to find valid location on Z-Level [Z.z].</span>")
					close_holomap()
					return FALSE

				active_holomap.initialize_holomap(target_turf, FALSE, usr)
				active_holomap.station_map.loc = usr.hud_used.holomap_obj
				active_holomap.station_map.alpha = 0
				animate(active_holomap.station_map, alpha = 255, time = 5, easing = LINEAR_EASING)

				usr.client.images |= active_holomap.station_map
				to_chat(usr, "<span class='notice'>Displaying holomap for Z-Level [Z.z]: [Z.name]</span>")
				log_admin("[key_name(usr)] opened holomap for Z-[Z.z] ([Z.name]).")

			else
				// Toggle MindUI for virtual z-levels
				if(!usr.mind)
					to_chat(usr, "<span class='warning'>You need a mind to view the virtual z-level map.</span>")
					return FALSE

				// Check if it's already open for this z-level
				var/datum/mind_ui/zlevel_map/existing_zmap
				var/showing_this_z = FALSE
				if("zlevel_map" in usr.mind.activeUIs)
					existing_zmap = usr.mind.activeUIs["zlevel_map"]
					// Check if it's showing this specific z-level
					if(existing_zmap.active)
						for(var/obj/abstract/mind_ui_element/hoverable/virtual_z_display/vz_disp in existing_zmap.elements)
							if(vz_disp.v && vz_disp.v.parent_z.z == Z.z)
								showing_this_z = TRUE
								break

				// If already showing this z-level, hide it
				if(showing_this_z)
					existing_zmap.Hide()
					to_chat(usr, "<span class='notice'>Closed virtual z-level map for Z-[Z.z] ([Z.name]).</span>")
					log_admin("[key_name(usr)] closed virtual z-level map for Z-[Z.z] ([Z.name]).")
					return TRUE

				// Get or create the zlevel_map UI
				var/datum/mind_ui/zlevel_map/zmap
				if(existing_zmap)
					zmap = existing_zmap
				else
					// Create new UI by calling DisplayUI, which will instantiate it
					usr.DisplayUI("zlevel_map")
					if("zlevel_map" in usr.mind.activeUIs)
						zmap = usr.mind.activeUIs["zlevel_map"]

				if(!zmap)
					to_chat(usr, "<span class='warning'>Failed to initialize z-level map interface.</span>")
					return FALSE

				// Display with the specific z-level (don't set active_holomap_z - that's only for holomaps)
				zmap.Display(Z.z)
				log_admin("[key_name(usr)] opened virtual z-level map for Z-[Z.z] ([Z.name]).")

			return TRUE

		if("create_vlevel")
			var/list/vlevel_options = list(
				"Generate Planet",
				"Generate Encounter",
				"Load Map Element",
				"Create Transit Level",
				"Manual Creation"
			)
			var/vlevel_choice = input(usr, "Select vLevel creation method:", "New vLevel") as null|anything in vlevel_options
			if(!vlevel_choice)
				return FALSE

			switch(vlevel_choice)
				if("Generate Encounter")
					// Get list of available shuttles
					var/list/shuttle_names = list()
					for(var/datum/shuttle/S in shuttles)
						shuttle_names[S.name] = S

					if(!shuttle_names.len)
						to_chat(usr, "<span class='warning'>No shuttles available!</span>")
						return FALSE

					var/shuttle_choice = input(usr, "Select a shuttle for the encounter:", "Generate Encounter") as null|anything in shuttle_names
					if(!shuttle_choice)
						return FALSE

					var/datum/shuttle/chosen_shuttle = shuttle_names[shuttle_choice]

					if(!chosen_shuttle.linked_port)
						to_chat(usr, "<span class='warning'>Shuttle has no linked docking port!</span>")
						return FALSE

					if(!chosen_shuttle.linked_area)
						to_chat(usr, "<span class='warning'>Shuttle has no linked area!</span>")
						return FALSE

					var/datum/encounter/enc = SSmapping.generate_scanner_encounter(chosen_shuttle)
					if(enc)
						log_admin("[key_name(usr)] generated encounter '[enc.encounter_name]' for shuttle '[shuttle_choice]' (vZ: [enc.v.id]).")
						message_admins("<span class='notice'>[key_name_admin(usr)] generated encounter '[enc.encounter_name]' for shuttle '[shuttle_choice]' (vZ: [enc.v.id]).</span>", 1)
					else
						to_chat(usr, "<span class='warning'>Failed to generate encounter!</span>")
					return TRUE

				if("Generate Planet")
					// Open the procedural generation panel
					var/datum/admins/admin_holder = usr.client?.holder
					if(admin_holder)
						admin_holder.procedural_generation_panel()
					return TRUE

				if("Load Map Element")
					// Get list of available map elements
					var/list/map_element_types = subtypesof(/datum/map_element) - /datum/map_element/dungeon - /datum/map_element/ruin - /datum/map_element/fixedvault
					var/list/map_element_names = list()
					for(var/path in map_element_types)
						var/datum/map_element/ME = path
						var/element_name = initial(ME.name)
						if(element_name)
							map_element_names[element_name] = path

					if(!map_element_names.len)
						to_chat(usr, "<span class='warning'>No map elements available!</span>")
						return FALSE

					var/element_choice = input(usr, "Select a map element to load:", "Load Map Element") as null|anything in map_element_names
					if(!element_choice)
						return FALSE

					var/element_path = map_element_names[element_choice]
					var/datum/map_element/ME = new element_path()
					ME.assign_dimensions()

					var/buffer_size = 0
					var/turf_type = /turf/space
					var/teleport_choice = VZ_TELEPORTATION_FORBIDDEN
					var/gps_allowed = FALSE
					var/movement_jammed = TRUE
					var/transition_loops = FALSE
					var/list/transition_crosswrap = null
					var/list/adv_settings_opt = list("Yes", "No")
					var/adv_settings = input(usr, "Configure advanced settings (buffer size, base turf type, teleportation blocking, etc)?", "Advanced Settings", "No") as null|anything in adv_settings_opt
					if(adv_settings == "Yes")
						// Buffer size
						buffer_size = input(usr, "Enter buffer size (tiles around map element, 0-50):\n(0 = no buffer, vLevel matches map element size)", "Buffer Size", 10) as null|num
						if(isnull(buffer_size) || buffer_size < 0 || buffer_size > 50)
							buffer_size = 0

						// Base turf type
						turf_type = null
						if(alert(usr, "Set a base turf type for the vLevel?", "Base Turf", "Yes", "No") == "Yes")
							turf_type = input(usr, "Select base turf type:", "Turf Type") as null|anything in typesof(/turf)
							if(!turf_type)
								turf_type = /turf/space

						// Teleportation blocking
						var/teleport_options = list(
							"Allowed" = VZ_TELEPORTATION_ALLOWED,
							"Requires Natural Bluespace Crystals" = VZ_TELEPORTATION_EXPENSIVE,
							"Forbidden" = VZ_TELEPORTATION_FORBIDDEN
						)
						teleport_choice = input(usr, "Select teleportation setting for the vLevel:", "Teleportation Setting") as null|anything in teleport_options
						if(!teleport_choice)
							teleport_choice = VZ_TELEPORTATION_FORBIDDEN

						// GPS allowance
						if(alert(usr, "Allow regular GPS functions in this vLevel?", "GPS Functionality", "Yes", "No") == "Yes")
							gps_allowed = TRUE

						// Movement jamming
						if(alert(usr, "Prevent access to this vLevel by drifting?", "Movement Jamming", "Yes", "No") == "No")
							movement_jammed = FALSE

						// Transition loops
						if(alert(usr, "Should hitting this vLevel's border send you back to this vLevel?", "Transition Loops", "Yes", "No") == "Yes")
							transition_loops = TRUE

						// Transition crosswraps
						if(alert(usr, "Configure transition crosswraps?\n(Define specific vLevels to transition to when hitting each edge)", "Transition Crosswraps", "Yes", "No") == "Yes")
							// Build list of existing vLevels for selection
							var/list/vlevel_choices = list("None" = null)
							for(var/datum/virtual_z/vz in map.getAllVLevels())
								vlevel_choices["vZ-[vz.id]: [vz.name]"] = vz.id

							var/north_choice = input(usr, "Select vLevel to crosswrap NORTH edge to:", "Crosswrap North") as null|anything in vlevel_choices
							var/south_choice = input(usr, "Select vLevel to crosswrap SOUTH edge to:", "Crosswrap South") as null|anything in vlevel_choices
							var/east_choice = input(usr, "Select vLevel to crosswrap EAST edge to:", "Crosswrap East") as null|anything in vlevel_choices
							var/west_choice = input(usr, "Select vLevel to crosswrap WEST edge to:", "Crosswrap West") as null|anything in vlevel_choices

							var/north_id = vlevel_choices[north_choice]
							var/south_id = vlevel_choices[south_choice]
							var/east_id = vlevel_choices[east_choice]
							var/west_id = vlevel_choices[west_choice]

							if(north_id || south_id || east_id || west_id)
								transition_crosswrap = list(north_id, south_id, east_id, west_id)

					// Re-fetch dimensions fresh to avoid any caching issues
					var/list/fresh_dims = ME.get_dimensions()
					var/map_width = fresh_dims[1]
					var/map_height = fresh_dims[2]

					// Validate dimensions
					if(!map_width || !map_height || map_width < 1 || map_height < 1)
						to_chat(usr, "<span class='warning'>Could not determine map element dimensions! (Got [map_width]x[map_height])</span>")
						return FALSE

					// Create vLevel with explicit size calculation
					var/vlevel_width = map_width + (buffer_size * 2)
					var/vlevel_height = map_height + (buffer_size * 2)
					var/datum/virtual_z/new_vz = map.addVLevel(vlevel_width, vlevel_height, FALSE, turf_type)
					if(new_vz)
						new_vz.name = "Map Element: [ME.name]"
						new_vz.level_type = VZ_PROTECTED
						// Load the actual map element content into the vLevel
						// The maploader adds 1 to these offsets, so we subtract 1 to compensate
						var/load_x = new_vz.x_min + buffer_size - 1
						var/load_y = new_vz.y_min + buffer_size - 1
						UNTIL(ME.load(load_x, load_y, new_vz.parent_z.z, 0, TRUE))

						if(adv_settings == "Yes")
							new_vz.gps_allowed = gps_allowed
							new_vz.teleJammed = teleport_choice
							new_vz.movementJammed = movement_jammed
							new_vz.transitionLoops = transition_loops
							new_vz.transition_crosswrap_v = transition_crosswrap
							new_vz.update_settings()

						for(var/turf/T in new_vz.get_turfs())
							T.v = new_vz
						log_admin("[key_name(usr)] loaded map element '[element_choice]' as vLevel (vZ: [new_vz.id], MapSize: [map_width]x[map_height], vLevelSize: [vlevel_width]x[vlevel_height], Buffer: [buffer_size], LoadPos: [load_x],[load_y]).")
						message_admins("<span class='notice'>[key_name_admin(usr)] loaded map element '[element_choice]' as vLevel (vZ: [new_vz.id], Size: [map_width]x[map_height]).</span>", 1)
					return TRUE

				if("Create Transit Level")
					// Get list of available shuttles
					var/list/shuttle_names = list()
					for(var/datum/shuttle/S in shuttles)
						shuttle_names[S.name] = S

					if(!shuttle_names.len)
						to_chat(usr, "<span class='warning'>No shuttles available!</span>")
						return FALSE

					var/shuttle_choice = input(usr, "Select a shuttle for transit level:", "Transit Level") as null|anything in shuttle_names
					if(!shuttle_choice)
						return FALSE

					var/datum/shuttle/chosen_shuttle = shuttle_names[shuttle_choice]

					// Check if shuttle has a linked port
					if(!chosen_shuttle.linked_port)
						to_chat(usr, "<span class='warning'>Shuttle has no linked docking port!</span>")
						return FALSE

					// Get shuttle dimensions and direction
					var/list/shuttle_size = chosen_shuttle.get_size()
					if(!shuttle_size || shuttle_size.len < 2)
						to_chat(usr, "<span class='warning'>Could not determine shuttle size!</span>")
						return FALSE

					var/shuttle_width = shuttle_size[1]
					var/shuttle_height = shuttle_size[2]

					// Use shuttle's current direction
					var/direction = chosen_shuttle.dir

					// Calculate transit area size: shuttle dimensions + 10 on each side
					var/padding = 10
					var/transit_width = shuttle_width + (padding * 2)
					var/transit_height = shuttle_height + (padding * 2)

					var/datum/virtual_z/new_vz = map.addTransitVLevel(chosen_shuttle)
					if(new_vz)
						// Create the transit docking port
						// Get the shuttle docking port's offset from the shuttle's lower left corner
						var/list/offsets = chosen_shuttle.get_docking_port_offset()
						if(offsets && offsets.len >= 2)
							var/port_x = offsets[1]
							var/port_y = offsets[2]

							// Calculate destination turf for the docking port
							var/dest_x = new_vz.x_min + padding + port_x
							var/dest_y = new_vz.y_min + padding + port_y
							var/turf/destination_turf = get_step(locate(dest_x, dest_y, new_vz.parent_z.z), chosen_shuttle.linked_port.dir)

							// Create the transit docking port
							var/obj/docking_port/destination/transit/transit_dock = new(destination_turf)
							transit_dock.dir = turn(chosen_shuttle.linked_port.dir, 180)
							transit_dock.areaname = "[chosen_shuttle.name] transit"
							transit_dock.generate_borders = TRUE

							// Link the transit port to the shuttle
							chosen_shuttle.transit_port = transit_dock
							new_vz.level_type = VZ_TRANSIT

							log_admin("[key_name(usr)] created transit vLevel for shuttle '[shuttle_choice]' (vZ: [new_vz.id], Size: [transit_width]x[transit_height], Dir: [dir2text(direction)]).")
							message_admins("<span class='notice'>[key_name_admin(usr)] created transit vLevel for shuttle '[shuttle_choice]' (vZ: [new_vz.id]).</span>", 1)
						else
							to_chat(usr, "<span class='warning'>Could not determine shuttle docking port offset!</span>")
							return FALSE
					return TRUE

				if("Manual Creation")
					var/name = input(usr, "Enter a name for the new vLevel:", "New vLevel") as null|text
					if(!name)
						return FALSE

					var/width = input(usr, "Enter width (tiles, 10-255):", "vLevel Width", 50) as null|num
					if(!width || width < 10 || width > 255)
						return FALSE

					var/height = input(usr, "Enter height (tiles, 10-255):", "vLevel Height", 50) as null|num
					if(!height || height < 10 || height > 255)
						return FALSE

					var/turf_type = null
					if(alert(usr, "Set a base turf type for the vLevel?", "Base Turf", "Yes", "No") == "Yes")
						turf_type = input(usr, "Select base turf type:", "Turf Type") as null|anything in typesof(/turf)
						if(!turf_type)
							return FALSE

					// Advanced settings for manual creation
					var/teleport_choice = VZ_TELEPORTATION_FORBIDDEN
					var/gps_allowed = FALSE
					var/movement_jammed = TRUE
					var/transition_loops = FALSE
					var/list/transition_crosswrap = null

					if(alert(usr, "Configure advanced settings (teleportation, GPS, movement jamming, crosswraps)?", "Advanced Settings", "Yes", "No") == "Yes")
						// Teleportation blocking
						var/teleport_options = list(
							"Allowed" = VZ_TELEPORTATION_ALLOWED,
							"Requires Natural Bluespace Crystals" = VZ_TELEPORTATION_EXPENSIVE,
							"Forbidden" = VZ_TELEPORTATION_FORBIDDEN
						)
						teleport_choice = input(usr, "Select teleportation setting for the vLevel:", "Teleportation Setting") as null|anything in teleport_options
						if(!teleport_choice)
							teleport_choice = VZ_TELEPORTATION_FORBIDDEN

						// GPS allowance
						if(alert(usr, "Allow regular GPS functions in this vLevel?", "GPS Functionality", "Yes", "No") == "Yes")
							gps_allowed = TRUE

						// Movement jamming
						if(alert(usr, "Prevent access to this vLevel by drifting?", "Movement Jamming", "Yes", "No") == "No")
							movement_jammed = FALSE

						// Transition loops
						if(alert(usr, "Should hitting this vLevel's border send you back to this vLevel?", "Transition Loops", "Yes", "No") == "Yes")
							transition_loops = TRUE

						// Transition crosswraps
						if(alert(usr, "Configure transition crosswraps?\\n(Define specific vLevels to transition to when hitting each edge)", "Transition Crosswraps", "Yes", "No") == "Yes")
							// Build list of existing vLevels for selection
							var/list/vlevel_choices = list("None" = null)
							for(var/datum/virtual_z/vz in map.getAllVLevels())
								vlevel_choices["vZ-[vz.id]: [vz.name]"] = vz.id

							var/north_choice = input(usr, "Select vLevel to crosswrap NORTH edge to:", "Crosswrap North") as null|anything in vlevel_choices
							var/south_choice = input(usr, "Select vLevel to crosswrap SOUTH edge to:", "Crosswrap South") as null|anything in vlevel_choices
							var/east_choice = input(usr, "Select vLevel to crosswrap EAST edge to:", "Crosswrap East") as null|anything in vlevel_choices
							var/west_choice = input(usr, "Select vLevel to crosswrap WEST edge to:", "Crosswrap West") as null|anything in vlevel_choices

							var/north_id = vlevel_choices[north_choice]
							var/south_id = vlevel_choices[south_choice]
							var/east_id = vlevel_choices[east_choice]
							var/west_id = vlevel_choices[west_choice]

							if(north_id || south_id || east_id || west_id)
								transition_crosswrap = list(north_id, south_id, east_id, west_id)

					var/datum/virtual_z/new_vz = map.addVLevel(width, height, fill_turf_type = turf_type)
					if(new_vz)
						new_vz.name = name
						new_vz.level_type = VZ_SPACE
						new_vz.gps_allowed = gps_allowed
						new_vz.teleJammed = teleport_choice
						new_vz.movementJammed = movement_jammed
						new_vz.transitionLoops = transition_loops
						new_vz.transition_crosswrap_v = transition_crosswrap
						new_vz.update_settings()
						log_admin("[key_name(usr)] created manual vLevel '[name]' (vZ: [new_vz.id], Size: [width]x[height], Turf: [turf_type]).")
						message_admins("<span class='notice'>[key_name_admin(usr)] created manual vLevel '[name]' (vZ: [new_vz.id], Size: [width]x[height]).</span>", 1)
					return TRUE

			return TRUE

	return FALSE

/datum/level_manager/ui_state(mob/user)
	return global.admin_state

/datum/admins/proc/level_manager()
	if (!map.zLevels.len)
		alert("This map has no z-levels!")
		return

	var/datum/level_manager/LM = new(usr)
	LM.tgui_interact(usr)
