// Areas.dm


/area
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/map_name // Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.

	var/valid_territory = TRUE // If it's a valid territory for gangs to claim
	var/blob_allowed = TRUE // Does it count for blobs score? By default, all areas count.
	var/clockwork_warp_allowed = TRUE // Can servants warp into this area from Reebe?
	var/clockwork_warp_fail = "The structure there is too dense for warping to pierce. (This is normal in high-security areas.)"

	var/eject = null

	var/fire = null
	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/party = null
	var/lightswitch = TRUE

	var/requires_power = TRUE
	var/always_unpowered = FALSE	// This gets overriden to 1 for space in area/Initialize().

	var/outdoors = FALSE //For space, the asteroid, lavaland, etc. Used with blueprints to determine if we are adding a new area (vs editing a station room)

	var/totalbeauty = 0 //All beauty in this area combined, only includes indoor area.
	var/beauty = 0 // Beauty average per open turf in the area
	var/areasize = 0 //Size of the area in open turfs, only calculated for indoors areas.

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE
	var/music = null
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip
	var/static_light = 0
	var/static_environ

	var/has_gravity = FALSE
	var/noteleport = FALSE			//Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
	var/hidden = FALSE 			//Hides area from player Teleport function.
	var/safe = FALSE 				//Is the area teleport-safe: no space / radiation / aggresive mobs / other dangers

	var/no_air = null
	var/list/related			// the other areas of the same type as this

	var/parallax_movedir = 0

	var/global/global_uid = 0
	var/uid
	var/list/ambientsounds = GENERIC
	flags_1 = CAN_BE_DIRTY_1

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/firedoors_last_closed_on = 0
	var/xenobiology_compatible = FALSE //Can the Xenobio management console transverse this area by default?
	var/list/canSmoothWithAreas //typecache to limit the areas that atoms in this area can smooth with

/*Adding a wizard area teleport list because motherfucking lag -- Urist*/
/*I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game*/
GLOBAL_LIST_EMPTY(teleportlocs)

/proc/process_teleport_locs()
	for(var/V in GLOB.sortedAreas)
		var/area/AR = V
		if(istype(AR, /area/shuttle) || AR.noteleport)
			continue
		if(GLOB.teleportlocs[AR.name])
			continue
		var/turf/picked = safepick(get_area_turfs(AR.type))
		if (picked && is_station_level(picked.z))
			GLOB.teleportlocs[AR.name] = AR

	sortTim(GLOB.teleportlocs, /proc/cmp_text_dsc)

// ===


// Added to fix mech fabs 05/2013 ~Sayu
// This is necessary due to lighting subareas.  If you were to go in assuming that things in
// the same logical /area have the parent /area object... well, you would be mistaken.  If you
// want to find machines, mobs, etc, in the same logical area, you will need to check all the
// related areas.  This returns a master contents list to assist in that.
/proc/area_contents(area/A)
	if(!istype(A))
		return null
	var/list/contents = list()
	for(var/area/LSA in A.related)
		contents += LSA.contents
	return contents




/area/Initialize()
	icon_state = ""
	layer = AREA_LAYER
	uid = ++global_uid
	related = list(src)
	map_name = name // Save the initial (the name set in the map) name of the area.
	canSmoothWithAreas = typecacheof(canSmoothWithAreas)

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else if(dynamic_lighting != DYNAMIC_LIGHTING_IFSTARLIGHT)
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	if(dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
		dynamic_lighting = CONFIG_GET(flag/starlight) ? DYNAMIC_LIGHTING_ENABLED : DYNAMIC_LIGHTING_DISABLED

	. = ..()

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

	if(contents.len)
		var/list/areas_in_z = SSmapping.areas_in_z
		var/z
		update_areasize()
		for(var/i in 1 to contents.len)
			var/atom/thing = contents[i]
			if(!thing)
				continue
			z = thing.z
			break
		if(!z)
			WARNING("No z found for [src]")
			return
		if(!areas_in_z["[z]"])
			areas_in_z["[z]"] = list()
		areas_in_z["[z]"] += src

	return INITIALIZE_HINT_LATELOAD

/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon
	update_beauty()

/area/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/area/proc/poweralert(state, obj/source)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				if (state == 1)
					aiPlayer.cancelAlarm("Power", src, source)
				else
					aiPlayer.triggerAlarm("Power", src, cameras, source)

			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				if(state == 1)
					a.cancelAlarm("Power", src, source)
				else
					a.triggerAlarm("Power", src, cameras, source)

			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				if(state == 1)
					D.cancelAlarm("Power", src, source)
				else
					D.triggerAlarm("Power", src, cameras, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				if(state == 1)
					p.cancelAlarm("Power", src, source)
				else
					p.triggerAlarm("Power", src, cameras, source)

/area/proc/atmosalert(danger_level, obj/source)
	if(danger_level != atmosalm)
		if (danger_level==2)
			var/list/cameras = list()
			for(var/area/RA in related)
				for (var/item in RA.cameras)
					var/obj/machinery/camera/C = item
					cameras += C

			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, source)
			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				a.triggerAlarm("Atmosphere", src, cameras, source)
			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				D.triggerAlarm("Atmosphere", src, cameras, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.triggerAlarm("Atmosphere", src, cameras, source)

		else if (src.atmosalm == 2)
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				aiPlayer.cancelAlarm("Atmosphere", src, source)
			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				a.cancelAlarm("Atmosphere", src, source)
			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				D.cancelAlarm("Atmosphere", src, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.cancelAlarm("Atmosphere", src, source)

		src.atmosalm = danger_level
		return 1
	return 0

/area/proc/ModifyFiredoors(opening)
	if(firedoors)
		firedoors_last_closed_on = world.time
		for(var/FD in firedoors)
			var/obj/machinery/door/firedoor/D = FD
			var/cont = !D.welded
			if(cont && opening)	//don't open if adjacent area is on fire
				for(var/I in D.affecting_areas)
					var/area/A = I
					if(A.fire)
						cont = FALSE
						break
			if(cont && D.is_operational())
				if(D.operating)
					D.nextstate = opening ? FIREDOOR_OPEN : FIREDOOR_CLOSED
				else if(!(D.density ^ opening))
					INVOKE_ASYNC(D, (opening ? /obj/machinery/door/firedoor.proc/open : /obj/machinery/door/firedoor.proc/close))

/area/proc/firealert(obj/source)
	if(always_unpowered == 1) //no fire alarms in space/asteroid
		return

	var/list/cameras = list()

	for(var/area/RA in related)
		if (!( RA.fire ))
			RA.set_fire_alarm_effect()
			RA.ModifyFiredoors(FALSE)
			for(var/item in RA.firealarms)
				var/obj/machinery/firealarm/F = item
				F.update_icon()
		for (var/item in RA.cameras)
			var/obj/machinery/camera/C = item
			cameras += C

	for (var/item in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/a = item
		a.triggerAlarm("Fire", src, cameras, source)
	for (var/item in GLOB.silicon_mobs)
		var/mob/living/silicon/aiPlayer = item
		aiPlayer.triggerAlarm("Fire", src, cameras, source)
	for (var/item in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = item
		D.triggerAlarm("Fire", src, cameras, source)
	for(var/item in GLOB.alarmdisplay)
		var/datum/computer_file/program/alarm_monitor/p = item
		p.triggerAlarm("Fire", src, cameras, source)

	START_PROCESSING(SSobj, src)

/area/proc/firereset(obj/source)
	for(var/area/RA in related)
		if (RA.fire)
			RA.fire = 0
			RA.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			RA.updateicon()
			RA.ModifyFiredoors(TRUE)
			for(var/item in RA.firealarms)
				var/obj/machinery/firealarm/F = item
				F.update_icon()

	for (var/item in GLOB.silicon_mobs)
		var/mob/living/silicon/aiPlayer = item
		aiPlayer.cancelAlarm("Fire", src, source)
	for (var/item in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/a = item
		a.cancelAlarm("Fire", src, source)
	for (var/item in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = item
		D.cancelAlarm("Fire", src, source)
	for(var/item in GLOB.alarmdisplay)
		var/datum/computer_file/program/alarm_monitor/p = item
		p.cancelAlarm("Fire", src, source)

	STOP_PROCESSING(SSobj, src)

/area/process()
	if(firedoors_last_closed_on + 100 < world.time)	//every 10 seconds
		for(var/area/RA in related)
			RA.ModifyFiredoors(FALSE)

/area/proc/close_and_lock_door(obj/machinery/door/DOOR)
	set waitfor = FALSE
	DOOR.close()
	if(DOOR.density)
		DOOR.lock()

/area/proc/burglaralert(obj/trigger)
	if(always_unpowered == 1) //no burglar alarms in space/asteroid
		return

	var/list/cameras = list()

	for(var/area/RA in related)
		//Trigger alarm effect
		RA.set_fire_alarm_effect()
		//Lockdown airlocks
		for(var/obj/machinery/door/DOOR in RA)
			close_and_lock_door(DOOR)
		for (var/item in RA.cameras)
			var/obj/machinery/camera/C = item
			cameras += C

	for (var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/SILICON = i
		if(SILICON.triggerAlarm("Burglar", src, cameras, trigger))
			//Cancel silicon alert after 1 minute
			addtimer(CALLBACK(SILICON, /mob/living/silicon.proc/cancelAlarm,"Burglar",src,trigger), 600)

/area/proc/set_fire_alarm_effect()
	fire = 1
	updateicon()
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/area/proc/readyalert()
	if(name == "Space")
		return
	if(!eject)
		eject = 1
		updateicon()

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()

/area/proc/partyalert()
	if(src.name == "Space") //no parties in space!!!
		return
	if (!( src.party ))
		src.party = 1
		src.updateicon()
		src.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/area/proc/partyreset()
	if (src.party)
		src.party = 0
		src.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.welded)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					INVOKE_ASYNC(D, /obj/machinery/door/firedoor.proc/open)

/area/proc/updateicon()
	if ((fire || eject || party) && (!requires_power||power_environ))//If it doesn't require power, can still activate this proc.
		if(fire && !eject && !party)
			icon_state = "blue"
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else
		var/weather_icon
		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.stage != END_STAGE && (src in W.impacted_areas))
				W.update_areas()
				weather_icon = TRUE
		if(!weather_icon)
			icon_state = null

/area/space/updateicon()
	icon_state = null

/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(chan)		// return true if the area has power to given channel

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

/area/space/powered(chan) //Nope.avi
	return 0

// called when power status changes

/area/proc/power_change()
	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)
		RA.updateicon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
		if(STATIC_EQUIP)
			used += static_equip
		if(STATIC_LIGHT)
			used += static_light
		if(STATIC_ENVIRON)
			used += static_environ
	return used

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

/area/proc/use_power(amount, chan)

	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount


/area/Entered(atom/movable/M)
	set waitfor = FALSE
	SendSignal(COMSIG_AREA_ENTERED, M)
	M.SendSignal(COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return

	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = CHANNEL_BUZZ))

	if(!(L.client && (L.client.prefs.toggles & SOUND_AMBIENCE)))
		return //General ambience check is below the ship ambience so one can play without the other

	if(prob(35))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/area/Exited(atom/movable/M)
	SendSignal(COMSIG_AREA_EXITED, M)
	M.SendSignal(COMSIG_EXIT_AREA, src) //The atom that exits the area

/client/proc/ResetAmbiencePlayed()
	played = FALSE

/atom/proc/has_gravity(turf/T)
	if(!T || !isturf(T))
		T = get_turf(src)
	var/area/A = get_area(T)
	if(isspaceturf(T)) // Turf never has gravity
		return FALSE
	else if(A && A.has_gravity) // Areas which always has gravity
		return TRUE
	else
		// There's a gravity generator on our z level
		if(T && GLOB.gravity_generators["[T.z]"] && length(GLOB.gravity_generators["[T.z]"]))
			return TRUE
	return FALSE

/area/proc/setup(a_name)
	name = a_name
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE
	always_unpowered = FALSE
	valid_territory = FALSE
	blob_allowed = FALSE
	addSorted()

/area/proc/update_beauty()
	if(!areasize)
		return FALSE
	beauty = totalbeauty / areasize

/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	for(var/turf/open/T in contents)
		areasize++

/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/area/drop_location()
	CRASH("Bad op: area/drop_location() called")
