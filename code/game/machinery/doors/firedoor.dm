/var/const/OPEN = 1
/var/const/CLOSED = 2

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

		if(dir == turn(source.dir, 180) && source.flags & ON_BORDER) //[   ][  |][   ] imagine the | is the source (with dir EAST -> facing right), and the brackets are floors. When we try to get the turf to the left's air info, use the middle's turf instead
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
	req_one_access = list(access_atmospherics, access_engine_equip)
	opacity = 0
	density = 0
	layer = BELOW_TABLE_LAYER
	open_layer = BELOW_TABLE_LAYER
	closed_layer = ABOVE_DOOR_LAYER

	dir = 2

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

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

/obj/machinery/door/firedoor/New()
	. = ..()

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
			if(F.flags & ON_BORDER && src.flags & ON_BORDER && F.dir != src.dir) //two border doors on the same tile don't collide
				continue
			spawn(1)
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


/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	. = ..()


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
			o += "<span style='color:blue'>"
		o += "[celsius]°C</span> "
		o += "<span style='color:blue'>"
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
	return 0

/obj/machinery/door/firedoor/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_ai(mob/user)
	if(isobserver(user) || user.stat)
		return
	spawn()
		var/area/A = get_area_master(src)
		ASSERT(istype(A)) // This worries me.
		var/alarmed = A.doors_down || A.fire
		var/old_density = src.density
		if(old_density && alert("Override the [alarmed ? "alarming " : ""]firelock's safeties and open \the [src]?" ,,"Yes", "No") == "Yes")
			open()
		else if(!old_density)
			close()
		else
			return
		investigation_log(I_ATMOS, "[density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	return attackby(null, user)

/obj/machinery/door/firedoor/attack_alien(mob/living/carbon/alien/humanoid/user)
	force_open(user)

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.
	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message("<span class='attack'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].</span>",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			update_icon()
			return

	if( iscrowbar(C) || ( istype(C,/obj/item/weapon/fireaxe) && C.wielded ) )
		force_open(user, C)
		return

	if( isEmag(C) )
		if ( density==1 )
			flick("door_spark", src)
			spawn(6)
			force_open(user, C)
			spawn(8)
			blocked = TRUE
			update_icon()
			return
		else
			blocked = TRUE
			update_icon()
			return

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire

	var/access_granted = 0
	var/users_name
	if(!istype(C, /obj)) //If someone hit it with their hand.  We need to see if they are allowed.
		if(allowed(user))
			access_granted = 1
		if(ishuman(user))
			users_name = FindNameFromID(user)
		else
			users_name = "Unknown"

	if( ishuman(user) &&  !stat && ( istype(C, /obj/item/weapon/card/id) || istype(C, /obj/item/device/pda) ) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			users_name = ID.registered_name

		if(check_access(ID))
			access_granted = 1

	if(alarmed && density && lockdown && !access_granted/* && !( users_name in users_to_open ) */)
		if(horror_force(user))
			return

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
	var/needs_to_close = 0
	if(density)
		if(alarmed)
			needs_to_close = 1
		spawn()
			open()
	else
		spawn()
			close()
	investigation_log(I_ATMOS, "has been [density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")

	if(needs_to_close)
		spawn(50)
			if(alarmed && !density)
				close()

/obj/machinery/door/firedoor/open()
	if(!loc || blocked)
		return
	..()
	latetoggle()
	layer = open_layer
	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire
	if(alarmed)
		spawn(50)
			close()

/obj/machinery/door/firedoor/proc/force_open(mob/user, var/obj/C) //used in mecha/equipment/tools/tools.dm
	var/area/A = get_area_master(src)
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
			open()
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
	layer = closed_layer

/obj/machinery/door/firedoor/update_icon()
	overlays.len = 0
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += image(icon = icon, icon_state = "welded")
		if(pdiff_alert)
			overlays += image(icon = icon, icon_state = "palert")
		if(dir_alerts)
			for(var/d=1;d<=4;d++)
				var/cdir = cardinal[d]
				// Loop while i = [1, 3], incrementing each loop
				for(var/i=1;i<=ALERT_STATES.len;i++) //
					if(dir_alerts[d] & (1<<(i-1)))// Check to see if dir_alerts[d] has the i-1th bit set.

						var/list/state_list = alert_overlays_local["alert_[ALERT_STATES[i]]"]
						if(flags & ON_BORDER)
							overlays += turn(state_list["[turn(cdir, dir2angle(src.dir))]"], dir2angle(src.dir))
						else
							overlays += state_list["[cdir]"]
	else
		icon_state = "door_open"
		if(blocked)
			overlays += image(icon = icon, icon_state = "welded_open")
	return

// CHECK PRESSURE
/obj/machinery/door/firedoor/process()
	..()

	if(density)
		var/changed = 0
		lockdown=0

		// Pressure alerts
		if(flags & ON_BORDER) //For border firelocks, we only need to check front and back, don't check the sides
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
	if(operating || stat & NOPOWER || !nextstate)
		return

	switch(nextstate)
		if(OPEN)
			nextstate = null
			open()
		if(CLOSED)
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
	flags = ON_BORDER

/obj/machinery/door/firedoor/border_only/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && (mover.checkpass(PASSDOOR|PASSGLASS)))
		return 1
	if(get_dir(loc, target) == dir || get_dir(loc, mover) == dir)
		return !density
	return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/firedoor/CanAStarPass()
	return !density

/obj/machinery/door/firedoor/npc_tamper_act(mob/living/L)
	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/border_only/Uncross(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && (mover.checkpass(PASSDOOR|PASSGLASS)))
		return 1
	if(flags & ON_BORDER)
		if(target) //Are we doing a manual check to see
			if(get_dir(loc, target) == dir)
				return !density
		else if(mover.dir == dir) //Or are we using move code
			if(density)
				mover.Bump(src)
			return !density
	return 1


/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2
