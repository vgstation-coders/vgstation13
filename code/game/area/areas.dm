// Flags for door_alerts.
#define DOORALERT_ATMOS 1
#define DOORALERT_FIRE  2

var/area/space_area

/area
	var/global/global_uid = 0
	var/uid
	var/obj/machinery/power/apc/areaapc = null
	var/list/area_turfs
	plane = ABOVE_LIGHTING_PLANE
	layer = MAPPING_AREA_LAYER
	var/base_turf_type = null
	var/shuttle_can_crush = TRUE
	var/project_shadows = FALSE
	var/obj/effect/narration/narrator = null
	var/holomap_draw_override = HOLOMAP_DRAW_NORMAL

	flags = 0

/area/New()
	area_turfs = list()
	icon_state = ""
	uid = ++global_uid
	if (x) // If we're actually located in the world
		areas |= src

	if(isspace(src))	// override defaults for space. TODO: make space areas of type /area/space rather than /area
		requires_power = 1
		always_unpowered = 1
		dynamic_lighting = 1
		power_light = 0
		power_equip = 0
		power_environ = 0
		space_area = src
		for(var/datum/d in ambient_sounds)//can't think of a better way to do this.
			qdel(d)
		//ambient_sounds = list(/datum/ambience/spaced1,/datum/ambience/spaced2,/datum/ambience/spaced3,/datum/ambience/spacemusic,/datum/ambience/mainmusic,/datum/ambience/traitormusic)
		ambient_sounds = list()
		//lighting_state = 4
		//gravity = 0    // Space has gravity.  Because.. because.

	if(!requires_power)
		power_light = 1
		power_equip = 1
		power_environ = 1

	..()

	update_dynamic_lighting()

//	spawn(15)
	power_change()		// all machines set to current power level, also updates lighting icon

/area/spawned_by_map_element(datum/map_element/ME, list/objects)
	..()

	power_change()

/area/Destroy()
	..()
	areaapc = null

/*
 * Added to fix mech fabs 05/2013 ~Sayu.
 * This is necessary due to lighting subareas.
 * If you were to go in assuming that things in the same logical /area have
 * the parent /area object... well, you would be mistaken.
 * If you want to find machines, mobs, etc, in the same logical area,
 * you will need to check all the related areas.
 * This returns a master contents list to assist in that.
 * NOTE: Due to a new lighting engine this is now deprecated, but we're keeping this because I can't be bothered to relace everything that references this.
 */
/proc/area_contents(const/area/A)
	if (!isarea(A))
		return

	return A.contents

/area/proc/getAreaCenter(var/zLevel=1)
	if(!area_turfs.len)
		return null

	var/center_x = 0
	var/center_y = 0

	for(var/turf/T in area_turfs)
		if(T.z == zLevel)
			center_x += T.x
			center_y += T.y

	center_x = round(center_x / area_turfs.len)
	center_y = round(center_y / area_turfs.len)

	if(!center_x || !center_y)
		return null

	var/turf/T = locate(center_x,center_y,zLevel)

	return T

/area/proc/poweralert(var/state, var/obj/source as obj)
	if (suspend_alert)
		return
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for(var/obj/machinery/camera/C in src)
				cameras += C
				if(state == 1)
					C.network.Remove(CAMERANET_POWERALARMS)
				else
					C.network.Add(CAMERANET_POWERALARMS)
			for (var/mob/living/silicon/aiPlayer in player_list)
				if(aiPlayer.z == source.z)
					if (state == 1)
						aiPlayer.cancelAlarm("Power", src, source)
					else
						aiPlayer.triggerAlarm("Power", src, cameras, source)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(src in (a.covered_areas))
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/send_poweralert(var/obj/machinery/computer/station_alert/a)//sending alerts to newly built Station Alert Computers.
	if(!poweralm)
		a.triggerAlarm("Power", src, null, src)

/////////////////////////////////////////
// BEGIN /vg/ UNFUCKING OF AIR ALARMS
/////////////////////////////////////////

/area/proc/updateDangerLevel()
	var/danger_level = 0

	// Determine what the highest DL reported by air alarms is
	for(var/obj/machinery/alarm/AA in src)
		if((AA.stat & (NOPOWER|BROKEN)) || AA.shorted || AA.buildstage != 2)
			continue
		var/reported_danger_level=AA.local_danger_level
		if(AA.alarmActivated)
			reported_danger_level=2
		if(reported_danger_level>danger_level)
			danger_level=reported_danger_level
		//testing("Danger level at [AA.name]: [AA.local_danger_level] (reported [reported_danger_level])")

	//testing("Danger level decided upon in [name]: [danger_level] (from [atmosalm])")

	// Danger level change?
	if(danger_level != atmosalm)
		// Going to danger level 2 from something else
		if (danger_level == 2)
			var/list/cameras = list()
			//updateicon()
			for(var/obj/machinery/camera/C in src)
				cameras += C
				C.network.Add(CAMERANET_ATMOSALARMS)
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(src in (a.covered_areas))
					a.triggerAlarm("Atmosphere", src, cameras, src)
			door_alerts |= DOORALERT_ATMOS
			UpdateFirelocks()
		// Dropping from danger level 2.
		else if (atmosalm == 2)
			for(var/obj/machinery/camera/C in src)
				C.network.Remove(CAMERANET_ATMOSALARMS)
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(src in (a.covered_areas))
					a.cancelAlarm("Atmosphere", src, src)
			door_alerts &= ~DOORALERT_ATMOS
			UpdateFirelocks()
		atmosalm = danger_level
		for (var/obj/machinery/alarm/AA in src)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.update_icon()
		return 1
	return 0

/area/proc/sendDangerLevel(var/obj/machinery/computer/station_alert/a)//sending alerts to newly built Station Alert Computers.
	var/danger_level = 0

	// Determine what the highest DL reported by air alarms is
	for(var/obj/machinery/alarm/AA in src)
		if((AA.stat & (NOPOWER|BROKEN)) || AA.shorted || AA.buildstage != 2)
			continue
		var/reported_danger_level=AA.local_danger_level
		if(AA.alarmActivated)
			reported_danger_level=2
		if(reported_danger_level>danger_level)
			danger_level=reported_danger_level

	if (danger_level == 2)
		a.triggerAlarm("Atmosphere", src, null, src)


/area/proc/UpdateFirelocks()
	if(door_alerts != 0 && !doors_overridden)
		CloseFirelocks()
	else
		OpenFirelocks()

/area/proc/CloseFirelocks()
	if(doors_down)
		return
	doors_down=1
	for(var/obj/machinery/door/firedoor/D in all_doors)
		if(!D.blocked)
			if(D.operating)
				D.nextstate = FD_CLOSED
			else if(!D.density)
				spawn()
					D.close()

/area/proc/OpenFirelocks()
	if(!doors_down)
		return
	doors_down=0
	for(var/obj/machinery/door/firedoor/D in all_doors)
		if(!D.blocked)
			if(D.operating)
				D.nextstate = FD_OPEN
			else if(D.density)
				spawn()
					D.open()

//////////////////////////////////////////////
// END UNFUCKING
//////////////////////////////////////////////

/area/proc/firealert()
	if(isspace(src)) //no fire alarms in space
		return
	if( !fire )
		fire = 1
		updateicon()
		mouse_opacity = 0
		door_alerts |= DOORALERT_FIRE
		UpdateFirelocks()
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras.Add(C)
			C.network.Add(CAMERANET_FIREALARMS)
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			if(src in (a.covered_areas))
				a.triggerAlarm("Fire", src, cameras, src)

/area/proc/send_firealert(var/obj/machinery/computer/station_alert/a)//sending alerts to newly built Station Alert Computers.
	if(fire)
		a.triggerAlarm("Fire", src, null, src)

/area/proc/firereset()
	if (fire)
		fire = 0
		mouse_opacity = 0
		updateicon()
		for (var/obj/machinery/camera/C in src)
			C.network.Remove(CAMERANET_FIREALARMS)
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			if(src in (a.covered_areas))
				a.cancelAlarm("Fire", src, src)
		door_alerts &= ~DOORALERT_FIRE
		UpdateFirelocks()

/area/proc/radiation_alert()
	if(isspace(src))
		return

	if(!radalert)
		radalert = 1
		updateicon()
	return

/area/proc/reset_radiation_alert()
	if(isspace(src))
		return

	if(radalert)
		radalert = 0
		updateicon()
	return

/area/proc/readyalert()
	if(isspace(src))
		return

	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/partyalert()
	if(isspace(src))
		return

	if (!( party ))
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if (party)
		party = 0
		mouse_opacity = 0
		updateicon()
	return

/area/proc/get_ambience_list()
	//Check if the area has an AI and add the appropriate ambience
	var/list/ambience_list = list()
	ambience_list.Add(ambient_sounds)
	for(var/mob/living/silicon/ai/AI in player_list)
		if(get_area(AI) == src && !find_active_faction_by_type(/datum/faction/malf))
			ambience_list.Add(/datum/ambience/AI, /datum/ambience/AI/safe, /datum/ambience/AI/back)
			if(AI?.laws.name == "Asimov's Three Laws of Robotics")
				ambience_list.Add(/datum/ambience/AI/harmonica)
			break
	if(ambience_list.len > 0)
		return ambience_list

/area/proc/updateicon()
	if (!areaapc)
		icon_state = null
		return
	if ((fire || eject || party || radalert) && ((!requires_power)?(!requires_power):power_environ))//If it doesn't require power, can still activate this proc.
		// Highest priority at the top.
		if(radalert && !fire)
			icon_state = "radiation"
		else if(fire && !radalert && !eject && !party)
			icon_state = "blue"
		/*else if(atmosalm && !fire && !eject && !party)
			icon_state = "bluenew"*/
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else
	//	new lighting behaviour with obj lights
		icon_state = null


/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel


	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

/*
 * Called when power status changes.
 */
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()				// reverify power status (to update icons etc.)
	if (fire || eject || party)
		updateicon()

/area/proc/usage(const/chan)
	switch (chan)
		if (LIGHT)
			return used_light
		if (EQUIP)
			return used_equip
		if (ENVIRON)
			return used_environ
		if (TOTAL)
			return used_light + used_equip + used_environ
		if(STATIC_EQUIP)
			return static_equip
		if(STATIC_LIGHT)
			return static_light
		if(STATIC_ENVIRON)
			return static_environ
	return 0

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(const/amount, const/chan)
	switch (chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/Entered(atom/movable/Obj, atom/OldLoc)
	var/area/oldArea = get_area(OldLoc)

	if(oldArea == src)
		return 1
	if(project_shadows)
		Obj.update_shadow()
	else if(istype(oldArea) && oldArea.project_shadows)
		Obj.underlays -= Obj.shadow

	Obj.area_entered(src)
	for(var/atom/movable/thing in get_contents_in_object(Obj))
		thing.area_entered(src)

	for(var/mob/mob_in_obj in Obj.contents)
		CallHook("MobAreaChange", list("mob" = mob_in_obj, "new" = src, "old" = oldArea))

	INVOKE_EVENT(src, /event/area_entered, "enterer" = Obj)
	var/mob/M = Obj
	if(istype(M))
		CallHook("MobAreaChange", list("mob" = M, "new" = src, "old" = oldArea)) // /vg/ - EVENTS!
		if(narrator)
			narrator.Crossed(M)

/area/Exited(atom/movable/Obj)
	INVOKE_EVENT(src, /event/area_exited, "exiter" = Obj)
	..()

/area/proc/subjectDied(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat)
			src.Exited(L)

/area/proc/gravitychange(var/gravitystate = 0, var/area/A)


	A.gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/H in A)
			if(istype(get_turf(H), /turf/space)) //You can't fall on space
				continue
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.clothing_flags & NOSLIP))
				continue
			if(H.locked_to) //Locked to something, anything
				continue

			H.AdjustStunned(5)
			to_chat(H, "<span class='warning'>Gravity!</span>")

/area/proc/set_apc(var/obj/machinery/power/apc/apctoset)
	areaapc = apctoset

/area/proc/remove_apc(var/obj/machinery/power/apc/apctoremove)
	poweralert(1, apctoremove) //CANCEL THE POWER ALERT PLEASE
	if(areaapc == apctoremove)
		areaapc = null

/area/proc/get_atoms()
	var/list/L = list()
	for(var/atom/A in contents)
		L |= A

	return L

/area/proc/get_shuttle()
	for(var/datum/shuttle/S in shuttles)
		if(S.linked_area == src)
			return S
	return null

/area/proc/displace_contents()
	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in src)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

	// hey you, get out of the way!
	for(var/turf/T in dstturfs)
			// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

//This proc adds all turfs in the list to the parent area, calling change_area on everything
//Returns nothing
/area/proc/add_turfs(var/list/L)
	for(var/turf/T in L)
		if(T in L)
			continue
		var/area/old_area = get_area(T)

		L += T

		T.change_area(old_area,src)
		for(var/atom/movable/AM in T.contents)
			AM.change_area(old_area,src)

var/list/ignored_keys = list("loc", "locs", "parent_type", "vars", "verbs", "type", "x", "y", "z", "group", "contents", "air", "zone", "light", "underlays", "lighting_overlay", "corners", "affecting_lights", "has_opaque_atom", "lighting_corners_initialised", "light_sources")
var/list/moved_landmarks = list(latejoin, wizardstart) //Landmarks that are moved by move_area_to and move_contents_to

/area/proc/move_contents_to(var/area/A, var/turftoleave=null, var/direction = null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0

	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for (var/turf/T in refined_src)
			var/area/AA = get_area(T)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon
					var/image/undlay = image("icon"=B.icon,"icon_state"=B.icon_state,"dir"=B.dir)
					undlay.overlays = B.overlays
					var/prevtype = B.type

					var/turf/X = B.ChangeTurf(T.type, allow = 1)
					for(var/key in T.vars)
						if(key in ignored_keys)
							continue
						if(istype(T.vars[key],/list))
							var/list/L = T.vars[key]
							X.vars[key] = L.Copy()
						else
							X.vars[key] = T.vars[key]
					if(ispath(prevtype,/turf/space))//including the transit hyperspace turfs
						/*if(ispath(AA.type, /area/syndicate_station/start) || ispath(AA.type, /area/syndicate_station/transit))//that's the snowflake to pay when people map their ships over the snow.
							X.underlays += undlay
						else
							*/if(T.underlays.len)
							X.underlays = T.underlays
						else
							X.underlays += undlay
					else
						X.underlays += undlay
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					var/turf/simulated/ST = T

					if(istype(ST) && ST.zone)
						var/turf/simulated/SX = X

						if(!SX.air)
							SX.make_air()

						SX.air.copy_from(ST.zone.air)
						ST.zone.remove(ST)

					/* Quick visual fix for transit space tiles */
					if(direction && (locate(/obj/structure/shuttle/diag_wall) in X))
						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(X, direction)
						if(!nextturf || !istype(nextturf, /turf/space))
							nextturf = get_step(X, turn(direction, 180))

						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state

					for(var/obj/O in T)
						O.forceMove(X)
					for(var/mob/M in T)
						if(!M.can_shuttle_move())
							continue
						M.forceMove(X)

//					var/area/AR = X.loc

//					if(AR.dynamic_lighting)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.SetOpacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						fromupdate += T.ChangeTurf(turftoleave, allow = 1)
					else
						if(ispath(AA.type, /area/shuttle/nuclearops))
							T.ChangeTurf(/turf/unsimulated/floor, allow = 1)
							T.icon = 'icons/turf/snow.dmi'
							T.icon_state = "snow"
						else
							T.ChangeTurf(get_base_turf(T.z), allow = 1)
							if(istype(T, /turf/space))
								switch(universe.name)	//for some reason using OnTurfChange doesn't actually do anything in this case.
									if("Hell Rising")
										T.overlays += image(icon = T.icon, icon_state = "hell01")
									if("Supermatter Cascade")
										T.overlays += image(icon = T.icon, icon_state = "end01")


					refined_src -= T
					refined_trg -= B
					continue moving

	var/list/doors = new/list()

	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			for(var/obj/machinery/door/D2 in T1)
				doors += D2
			/*if(T1.parent)
				SSair.groups_to_rebuild += T1.parent
			else
				SSair.mark_for_update(T1)*/

	if(fromupdate.len)
		for(var/turf/simulated/T2 in fromupdate)
			for(var/obj/machinery/door/D2 in T2)
				doors += D2
			/*if(T2.parent)
				SSair.groups_to_rebuild += T2.parent
			else
				SSair.mark_for_update(T2)*/

	for(var/obj/machinery/door/D in doors)
		D.update_nearby_tiles()

/area/proc/make_geyser(turf/T)
	return
