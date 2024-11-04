/var/const/FD_OPEN = 1
/var/const/FD_CLOSED = 2

var/global/list/alert_overlays_global = list()

/proc/convert_k2c(var/temp)
	return ((temp - T0C)) // * 1.8) + 32

/proc/convert_c2k(var/temp)
	return ((temp + T0C)) // * 1.8) + 32

/proc/getCardinalAirInfo(var/atom/source, var/turf/loc, var/list/stats=list("temperature"))
	var/list/temps = new/list(4)
	for(var/dir in cardinal)
		var/direction
		switch(dir)
			if(NORTH)
				direction = 1
			if(SOUTH)
				direction = 2
			if(EAST)
				direction = 3
			if(WEST)
				direction = 4

		var/turf/simulated/T=get_turf(get_step(loc,dir))

		if(dir == turn(source.dir, 180) && source.flow_flags & ON_BORDER) //[   ][  |][   ] imagine the | is the source (with dir EAST -> facing right), and the brackets are floors. When we try to get the turf to the left's air info, use the middle's turf instead
			if(!(locate(/obj/machinery/door/airlock) in get_turf(source))) //If we're on a door, however, DON'T DO THIS -> doors are airtight, so the result will be innacurate! This is a bad snowflake, but as long as it makes the feature freeze go away...
				T = get_turf(source)

		var/list/rstats = new /list(stats.len)
		if(!source.Adjacent(T)) //Stop reading air contents through windows asshole
			rstats = null
		else
			if(T && istype(T) && T.zone)
				var/datum/gas_mixture/environment = T.return_air()
				for(var/i=1;i<=stats.len;i++)
					rstats[i] = environment.vars[stats[i]]
			else if(istype(T, /turf/simulated))
				rstats = null // Exclude zone (wall, door, etc).
			else if(istype(T, /turf))
				// Should still work.  (/turf/return_air())
				var/datum/gas_mixture/environment = T.return_air()
				for(var/i=1;i<=stats.len;i++)
					rstats[i] = environment.vars[stats[i]]
		temps[direction] = rstats
	return temps

#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
#define FIREDOOR_MAX_TEMP 50 // �C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT      1
#define FIREDOOR_ALERT_COLD     2
// Not used #define FIREDOOR_ALERT_LOWPRESS 4

/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_minor, access_paramedic)
	opacity = 0
	density = 0
	layer = BELOW_TABLE_LAYER

	open_plane = OBJ_PLANE
	open_layer = BELOW_TABLE_LAYER

	closed_plane = ABOVE_HUMAN_PLANE
	closed_layer = CLOSED_FIREDOOR_LAYER

	dir = 2

	animation_delay_predensity_opening = 3
	animation_delay_predensity_closing = 7
	
	machine_flags = SCREWTOGGLE | EMAGGABLE

	var/list/alert_overlays_local

	var/blocked = 0
	var/lockdown = 0 // When the door has detected a problem, it locks.
	var/pdiff_alert = 0
	var/pdiff = 0
	var/nextstate = null
	var/net_id
	var/list/areas_added
	var/list/users_to_open
	var/list/tile_info[4]
	var/list/dir_alerts[4] // 4 dirs, bitflags
	var/obj/machinery/door/firedoor/twin = null // The twin will open alongside the firedoor when opened without an active atmos hazard

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)


/obj/machinery/door/firedoor/New(loc, new_dir)
	. = ..()
	change_dir(new_dir)
	if(!("[src.type]" in alert_overlays_global))
		alert_overlays_global += list("[src.type]" = list("alert_hot" = list(),
														"alert_cold" = list())
									)

		var/list/type_states = alert_overlays_global["[src.type]"]

		for(var/alert_state in type_states)
			var/list/starting = list()
			for(var/cdir in cardinal)
				starting["[cdir]"] = icon(src.icon, alert_state, dir = cdir)
			type_states[alert_state] = starting
		alert_overlays_global["[src.type]"] = type_states
		alert_overlays_local = type_states
	else
		alert_overlays_local = alert_overlays_global["[src.type]"]

	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			if(F.flow_flags & ON_BORDER && src.flow_flags & ON_BORDER && F.dir != src.dir) //two border doors on the same tile don't collide
				continue
			spawn(1)
				new /obj/item/firedoor_frame(get_turf(src))
				qdel(src)
			return .
	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/simulated/floor))
			A = get_area(get_step(src,direction))
			if(A)
				A.all_doors |= src
				areas_added |= A

/obj/machinery/door/firedoor/initialize()
	if (twin) // Already paired with something
		return
	for (var/i = 1 to 3) // Try to find a firelock up to 3 tiles ahead
		switch (dir)
			if (NORTH, SOUTH) // North south, going by the y axis
				var/turf/T = locate(x, y + i, z)
				var/obj/machinery/door/firedoor/DF = locate() in T
				if (DF)
					twin = DF
					DF.twin = src
					return
			if (EAST, WEST)
				var/turf/T = locate(x + i, y, z)
				var/obj/machinery/door/firedoor/DF = locate() in T
				if (DF)
					twin = DF
					DF.twin = src
					return

/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	if (istype(twin))
		twin.twin = null
		twin = null
	. = ..()

/obj/machinery/door/firedoor/proc/is_fulltile()
	return 1

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		to_chat(user, "<span class='danger'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>")

	to_chat(user, "<b>Sensor readings:</b>")
	for(var/index = 1; index <= tile_info.len; index++)
		var/o = "&nbsp;&nbsp;"
		switch(index)
			if(1)
				o += "NORTH: "
			if(2)
				o += "SOUTH: "
			if(3)
				o += "EAST: "
			if(4)
				o += "WEST: "
		if(tile_info[index] == null)
			o += "<span class='warning'>DATA UNAVAILABLE</span>"
			to_chat(usr, o)
			continue
		var/celsius = convert_k2c(tile_info[index][1])
		var/pressure = tile_info[index][2]
		if(dir_alerts[index] & (FIREDOOR_ALERT_HOT|FIREDOOR_ALERT_COLD))
			o += "<span class='warning'>"
		else
			o += "<span class='notice'>"
		o += "[celsius]°C</span> "
		o += "<span class='notice'>"
		o += "[pressure]kPa</span></li>"
		to_chat(user, o)

	if( islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		to_chat(user, "These people have opened \the [src] during an alert: [users_to_open_string].")


/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if (mecha.occupant)
			var/mob/M = mecha.occupant
			attack_hand(M)
	if(ismob(AM))
		var/mob/M = AM
		var/obj/item/I = M.get_active_hand()
		if((iscrowbar(I)||istype(I,/obj/item/weapon/fireaxe)) && M.a_intent == I_HURT)
			attackby(I,M)
	return 0

/obj/machinery/door/firedoor/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_ai(mob/user,var/override=FALSE)
	if(!isAdminGhost(user) && (isobserver(user) || user.stat))
		return
	spawn()
		var/area/A = get_area(src)
		ASSERT(istype(A)) // This worries me.
		var/alarmed = A.doors_down || A.fire
		var/old_density = src.density
		if(old_density)
			if(override || alert("Override the [alarmed ? "alarming " : ""]firelock's safeties and open \the [src]?" ,,"Yes", "No") == "Yes")
				open()
		else if(!old_density)
			close()
		else
			return
		investigation_log(I_ATMOS, "[density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")

/obj/machinery/door/firedoor/CtrlClick(mob/user)
	if(isrobot(user) || isAdminGhost(user))
		attack_ai(user, TRUE)
	else
		..()

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	return do_interaction(user)

/obj/machinery/door/firedoor/attack_alien(mob/living/carbon/alien/humanoid/user)
	force_open(user)

/obj/machinery/door/firedoor/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(user, 'sound/weapons/heavysmash.ogg', 75, 1)
		to_chat(user, "<span class = 'warning'>You smash with all your strength but \the [src] doesn't budge. If only your arms were sharp enough to pry the door open.</span>")
	if(istype(user,/mob/living/simple_animal/construct/wraith))
		force_open(user)
		return 1
	return 0

/obj/machinery/door/firedoor/attackby(var/obj/item/weapon/C, var/mob/user)
	if(operating)
		return//Already doing something.

	if(istype(C, /obj/item/weapon/batteringram))
		var/obj/item/weapon/batteringram/ram = C
		if(!ram.can_ram(user))
			return
		user.delayNextAttack(3 SECONDS)
		var/breaktime = 4 SECONDS
		visible_message("<span class='warning'>[user] is battering down [src]!</span>", "<span class='warning'>You begin to batter [src].</span>")
		if(!do_after(user, src, breaktime, 2, custom_checks = new /callback(ram, /obj/item/weapon/batteringram/proc/on_do_after)))
			return
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		visible_message("<span class='warning'>[user] breaks down \the [src]!</span>", "<span class='warning'>You broke \the [src]!</span>")
		var/obj/item/firedoor_frame/frame = new(get_turf(src))
		frame.add_fingerprint(user)
		qdel(src)
		return

	if(iswelder(C))
		var/obj/item/tool/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message("<span class='attack'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].</span>",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			update_icon()
			return

	if(iscrowbar(C) || (istype(C,/obj/item/weapon/fireaxe) && C.wielded))
		force_open(user, C)
		return

	if(C && (C.sharpness_flags & (CUT_AIRLOCK)) && user.a_intent == I_HURT)
		if(!density)
			return
		if(blocked)
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]!</span>", \
								"<span class='notice'>You begin slicing through \the [src].</span>", \
								"<span class='warning'>You hear slicing noises.</span>")
			playsound(src, 'sound/items/Welder2.ogg', 100, 1)
			if(do_after(user, src, 50))
				if(!istype(src))
					return
				user.visible_message("<span class='warning'>[user] slices through \the [src]!</span>", \
									"<span class='notice'>You slice through \the [src].</span>", \
									"<span class='warning'>You hear slicing noises.</span>")
				playsound(src, 'sound/items/Welder2.ogg', 100, 1)
				blocked = !blocked
				force_open(user, C)
				sleep(8)
				blocked = TRUE
				update_icon()
			return
		else
			user.visible_message("<span class='warning'>[user] swiftly slices \the [src] open!</span>",\
								"You slice \the [src] open in one clean cut!",\
								"You hear the sound of a swift, sharp slice.")
			force_open(user, C)
			sleep(8)
			blocked = TRUE
			update_icon()
			return

	if(C.is_wrench(user))
		if(blocked)
			user.visible_message("<span class='attack'>\The [user] starts to deconstruct \the [src] with \a [C].</span>",\
			"You begin to deconstruct \the [src] with \the [C].")
			if(do_after(user, src, 5 SECONDS))
				var/obj/item/firedoor_frame/frame = new(get_turf(src))
				frame.add_fingerprint(user)
				qdel(src)
			return
		else
			to_chat(user, "<span class = 'attack'>\The [src] is not welded or otherwise blocked.</span>")

	if(emag_check(C,user))
		return

	do_interaction(user, C)

/obj/machinery/door/firedoor/door_animate(var/animation)
	switch (animation)
		if ("opening")
			flick("door_opening", src)
		if ("closing")
			flick("door_closing", src)
		if("spark")
			flick("door_spark", src)
			var/area/here = get_area(src)
			if (here && here.dynamic_lighting)
				anim(target = src, a_icon = icon, flick_anim = "door_spark-moody", sleeptime = 10, plane = LIGHTING_PLANE, blend = BLEND_ADD)
		if("deny")
			flick("door_deny", src)
			var/area/here = get_area(src)
			if (here && here.dynamic_lighting)
				anim(target = src, a_icon = icon, flick_anim = "door_deny-moody", sleeptime = 5, plane = LIGHTING_PLANE, blend = BLEND_ADD)

/obj/machinery/door/firedoor/emag_act(mob/user)
	if(density)
		door_animate("spark")
		sleep(6)
		if(isAI(user) || ispulsedemon(user))
			open()
		else
			force_open(user)
		sleep(8)
	blocked = TRUE
	update_icon()

/obj/machinery/door/firedoor/attack_animal(var/mob/living/simple_animal/M as mob)
	M.delayNextAttack(8)
	if(M.melee_damage_upper == 0)
		return
	M.do_attack_animation(src, M)
	M.visible_message("<span class='warning'>[M] smashes against \the [src].</span>", \
					  "<span class='warning'>You smash against \the [src].</span>", \
					  "You hear twisting metal.")
	if(prob(33))
		new /obj/item/firedoor_frame(get_turf(src))
		qdel(src)

/obj/machinery/door/firedoor/proc/do_interaction(var/mob/user, var/obj/item/weapon/C, var/no_reruns = FALSE)
	if(operating)
		return//Already doing something.

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	var/area/A = get_area(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire

	var/access_granted = FALSE
	var/users_name

	if(allowed(user))
		access_granted = TRUE
	if(ishuman(user))
		users_name = FindNameFromID(user)
	else
		users_name = "Unknown"

	if(ishuman(user) && !stat && (isID(C) || isPDA(C)))
		var/obj/item/weapon/card/id/ID = C

		if(isPDA(C))
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			users_name = ID.registered_name

		if(check_access(ID))
			access_granted = 1

	if(alarmed && density && lockdown && !access_granted)
		if(horror_force(user))
			return
		door_animate("deny")
		to_chat(user, "<span class='warning'>Access denied. Please wait for authorities to arrive, or for the alert to clear.</span>")
		return

	else
		user.visible_message("<span class='notice'>\The [src] [density ? "open" : "close"]s for \the [user].</span>",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")
		// Accountability!
		if(!users_to_open)
			users_to_open = list()
		users_to_open += users_name
		if(twin && !no_reruns && !alarmed) // if it's alarmed, we don't want both to open, so that firelocks can still play their role.
			twin.do_interaction(user, C, TRUE)
	var/needs_to_close = 0
	if(density)
		if(alarmed)
			needs_to_close = 1
		spawn()
			open(user)
	else
		spawn()
			close()
	investigation_log(I_ATMOS, "has been [density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")

	if(needs_to_close)
		spawn(50)
			alarmed = A.doors_down || A.fire
			if(alarmed && !density)
				close()

/obj/machinery/door/firedoor/open(mob/user)
	if(user)
		add_fingerprint(user)
	if(!loc || blocked)
		return
	..()
	latetoggle()
	plane = open_plane
	layer = open_layer
	var/area/A = get_area(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire
	if(alarmed)
		spawn(50)
			close()

/obj/machinery/door/firedoor/proc/force_open(mob/user, var/obj/C) //used in mecha/equipment/tools/tools.dm
	var/area/A = get_area(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire

	if( blocked )
		user.visible_message("<span class='attack'>\The [istype(user.loc,/obj/mecha) ? "[user.loc.name]" : "[user]"] pries at \the [src][istype(C) ? " with \a [C]" : ""], but \the [src] is welded in place!</span>",\
		"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
		"You hear someone struggle and metal straining.")
		return

	//thank you Tigercat2000
	user.visible_message("<span class='attack'>\The [istype(user.loc,/obj/mecha) ? "[user.loc.name]" : "[user]"] forces \the [src] [density ? "open" : "closed"][istype(C) ? " with \a [C]" : ""]!</span>",\
		"You force \the [src] [density ? "open" : "closed"][istype(C) ? " with \the [C]" : ""]!",\
		"You hear metal strain, and a door [density ? "open" : "close"].")

	if(density)
		spawn(0)
			open(user)
	else
		spawn(0)
			close()
	investigation_log(I_ATMOS, "has been [density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")
	return TRUE

/obj/machinery/door/firedoor/horror_force(var/mob/living/carbon/human/H)
	if(!ishorrorform(H))
		return FALSE
	return force_open(H)

/obj/machinery/door/firedoor/close()
	if(blocked || !loc)
		return
	..()
	latetoggle()
	plane = closed_plane
	layer = closed_layer

/obj/machinery/door/firedoor/update_icon()
	overlays.len = 0
	kill_moody_light_all()
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += image(icon = icon, icon_state = "welded")
		if(pdiff_alert)
			var/image/I = image(icon = icon, icon_state = "palert")
			I.plane = ABOVE_LIGHTING_PLANE
			I.layer = ABOVE_LIGHTING_LAYER
			overlays += I
			update_moody_light_index("palert", icon, "palert")
		if(dir_alerts)
			for(var/d=1;d<=4;d++)
				var/cdir = cardinal[d]
				// Loop while i = [1, 3], incrementing each loop
				for(var/i=1;i<=ALERT_STATES.len;i++) //
					if(dir_alerts[d] & (1<<(i-1)))// Check to see if dir_alerts[d] has the i-1th bit set.

						var/list/state_list = alert_overlays_local["alert_[ALERT_STATES[i]]"]
						if(flow_flags & ON_BORDER)
							var/image/I = image(turn(state_list["[turn(cdir, dir2angle(src.dir))]"], dir2angle(src.dir)))
							overlays += I
							update_moody_light_index("alert_[ALERT_STATES[i]]", image_override = I)
						else
							var/image/I = image(state_list["[cdir]"])
							overlays += I
							update_moody_light_index("alert_[ALERT_STATES[i]]", image_override = I)
	else
		icon_state = "door_open"
		if(blocked)
			overlays += image(icon = icon, icon_state = "welded_open")

// CHECK PRESSURE
/obj/machinery/door/firedoor/process()
	..()

	if(density)
		var/changed = 0
		lockdown=0

		// Pressure alerts
		if(flow_flags & ON_BORDER) //For border firelocks, we only need to check front and back, don't check the sides
			var/turf/T1 = get_step(loc,dir)
			var/turf/T2
			if(locate(/obj/machinery/door/airlock) in get_turf(src)) //If this firelock is in the same tile as an airlock, we want to check the OTHER SIDE of the airlock, not the airlock turf itself.
				T2 = get_step(loc,turn(dir, 180))
			else
				T2 = get_turf(src)

			pdiff = getPressureDifferentialFromTurfList(list(T1, T2))

		else
			pdiff = getOPressureDifferential(src.loc)

		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			lockdown = 1
			if(!pdiff_alert)
				pdiff_alert = 1
				changed = 1 // update_icon()
		else
			if(pdiff_alert)
				pdiff_alert = 0
				changed = 1 // update_icon()

		tile_info = getCardinalAirInfo(src,src.loc,list("temperature","pressure"))
		var/old_alerts = dir_alerts
		for(var/index = 1; index <= 4; index++)
			var/list/tileinfo=tile_info[index]
			if(tileinfo==null)
				continue // Bad data.
			var/celsius = convert_k2c(tileinfo[1])

			var/alerts=0

			// Temperatures
			if(celsius >= FIREDOOR_MAX_TEMP)
				alerts |= FIREDOOR_ALERT_HOT
				lockdown = 1
			else if(celsius <= FIREDOOR_MIN_TEMP)
				alerts |= FIREDOOR_ALERT_COLD
				lockdown = 1

			dir_alerts[index]=alerts

		if(dir_alerts != old_alerts)
			changed = 1
		if(changed)
			update_icon()

/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || stat & (FORCEDISABLE|NOPOWER) || !nextstate)
		return

	switch(nextstate)
		if(FD_OPEN)
			nextstate = null
			open()
		if(FD_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/border_only
//These are playing merry hell on ZAS.  Sorry fellas :(
//Or they were, until you disable their inherent air-blocking

	icon = 'icons/obj/doors/edge_DoorHazard.dmi'
	glass = 1 //There is a glass window so you can see through the door
			  //This is needed due to BYOND limitations in controlling visibility
	heat_proof = 1
	air_properties_vary_with_direction = 1
	flow_flags = ON_BORDER
	pass_flags_self = PASSDOOR|PASSGLASS

/obj/machinery/door/firedoor/border_only/New()
	..()
	setup_border_dummy()

/obj/machinery/door/firedoor/border_only/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return TRUE
	if(!density)
		return TRUE
	if(locate(/obj/effect/unwall_field) in loc) //Annoying workaround for this -kanef
		return TRUE
	if(istype(mover))
		return bounds_dist(border_dummy, mover) >= 0
	else if(get_dir(loc, target) == dir)
		return FALSE
	return TRUE

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/firedoor/CanAStarPass()
	return !density

/obj/machinery/door/firedoor/npc_tamper_act(mob/living/L)
	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/border_only/is_fulltile()
	return 0


/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2


/obj/item/firedoor_frame
	name = "firedoor frame"
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "firedoor_frame"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/electronics.dmi', "right_hand" = 'icons/mob/in-hand/right/electronics.dmi')
	desc = "The frame for a firedoor, strangely easy to set up considering its application."

/obj/item/firedoor_frame/attack_self(mob/user)
	if(!user)
		return 0
	if(!isturf(user.loc))
		return 0
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0

	switch(alert("What do you want?", "Firedoor Frame", "Directional", "Full Tile", "Cancel", null))
		if("Directional")
			if(!src)
				return 1
			if(loc != user)
				return 1
			var/current_turf = get_turf(src)
			for(var/obj/machinery/door/firedoor/FD in current_turf)
				if (FD.is_fulltile())
					to_chat(user, "<span class='warning'>That would overlap another firedoor.</span>")
					return 1
				if(FD.dir == user.dir)
					to_chat(user, "<span class = 'warning'>There is already a firedoor facing that direction.</span>")
					return 1
			user.visible_message("<span class='warning'>[user] starts building a firedoor.</span>", \
			"<span class='notice'>You start building a firedoor.</span>")
			if(do_after(user, user, 5 SECONDS))
				to_chat(user, "<span class='notice'>You finish the firedoor.</span>")
				new /obj/machinery/door/firedoor/border_only(current_turf, user.dir)
				qdel(src)

		if("Full Tile")
			if(!src)
				return 1
			if(loc != user)
				return 1
			var/current_turf = get_turf(src)
			if(locate(/obj/machinery/door/firedoor) in current_turf)
				to_chat(user, "<span class='warning'>That would overlap another firedoor.</span>")
				return 1
			user.visible_message("<span class='warning'>[user] starts building a firedoor.</span>", \
			"<span class='notice'>You start building a firedoor.</span>")
			if(do_after(user, user, 5 SECONDS))
				to_chat(user, "<span class='notice'>You finish the firedoor.</span>")
				new /obj/machinery/door/firedoor(current_turf)
				qdel(src)

/obj/item/firedoor_frame/attackby(var/obj/item/weapon/C, var/mob/user)
	if(C.is_wrench(user))
		user.visible_message("<span class='notice'>\The [user] deconstructs \the [src] with \a [C].</span>",\
		"You deconstruct \the [src] with \the [C]!")
		drop_stack(/obj/item/stack/sheet/metal, get_turf(src), 5, user)
		qdel(src)

/obj/machinery/door/firedoor/AICtrlClick(mob/user)
	attack_ai(user,TRUE)

//Removed pending a fix for atmos issues caused by full tile firelocks.
/*
	switch(alert("firedoor construction", "Would you like to construct a full tile firedoor or one direction?", "One Direction", "Full Firedoor", "Cancel", null))
		if("One Direction")
			if(!user.is_holding_item(src))
				return 1
			var/current_turf = get_turf(src)
			var/turf_face = get_step(current_turf,user.dir)
			if(SSair.air_blocked(current_turf, turf_face))
				to_chat(user, "<span class = 'warning'>That way is blocked already.</span>")
				return 1
			var/obj/machinery/door/firedoor/border_only/F = locate(/obj/machinery/door/firedoor) in get_turf(user)
			if(F && F.dir == user.dir)
				to_chat(user, "<span class = 'warning'>There is already a firedoor facing that direction.</span>")
				return 1
			if(do_after(user, src, 5 SECONDS))
				var/obj/machinery/door/firedoor/border_only/B = new(get_turf(src))
				B.change_dir(user.dir)
				qdel(src)
		if("Full Firedoor")
			if(!user.is_holding_item(src))
				return 1
			if(locate(/obj/machinery/door/firedoor) in get_turf(user))
				to_chat(user, "<span class='warning'>There is a firedoor already here.</span>")
				return 1
			if(do_after(user, src, 5 SECONDS))
				new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
*/
