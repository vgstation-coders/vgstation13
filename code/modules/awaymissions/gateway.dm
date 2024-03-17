var/list/gateways = list() //List containing all gateway parts
var/list/gateway_centers_station = list() //List containing the gateways on the station
var/list/gateway_centers_away = list() //List containing the gateways on away missions

/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1
	anchored = 1
	pixel_x = -WORLD_ICON_SIZE
	bound_x = -WORLD_ICON_SIZE
	bound_y = WORLD_ICON_SIZE
	bound_width = 3 * WORLD_ICON_SIZE
	bound_height = 2 * WORLD_ICON_SIZE
	var/active = 0
	var/centertype = /obj/machinery/gateway/center
	var/obj/machinery/gateway/center/thecenter = null

/obj/machinery/gateway/New()
	..()
	gateways.Add(src)

/obj/machinery/gateway/Destroy()
	gateways.Remove(src)
	detect()
	if(thecenter)
		thecenter.linked = null
		qdel(thecenter)
	..()

/obj/machinery/gateway/initialize()
	update_icon()

/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
	else
		icon_state = "off"

/obj/machinery/gateway/map_element_rotate()
	return

/obj/machinery/gateway/proc/detect()
	var/turf/T= get_step(loc, NORTH)
	thecenter = locate(centertype) in T
	if(!thecenter)
		thecenter = new centertype(T)

/obj/machinery/gateway/away
	centertype = /obj/machinery/gateway/center/away

//this is da important part wot makes things go
/obj/machinery/gateway/center
	icon = 'icons/obj/machines/gatewaycenter.dmi'
	icon_state = "off"
	use_power = MACHINE_POWER_USE_IDLE
	pixel_x = 0
	bound_x = 0
	bound_y = 0
	bound_width = WORLD_ICON_SIZE
	bound_height = WORLD_ICON_SIZE
	flow_flags = ON_BORDER // So collision even works

	//warping vars
	var/obj/machinery/gateway/linked = null
	var/wait = 0				//this just grabs world.time at world start

/obj/machinery/gateway/center/New()
	..()
	gateway_centers_station.Add(src)

/obj/machinery/gateway/center/Destroy()
	gateway_centers_station.Remove(src)
	if(linked)
		linked.detect()
	..()

/obj/machinery/gateway/center/proc/admin_active(mob/user)
	detect()
	update_icon()
	wait = 0
	toggleon(user)

/obj/machinery/gateway/center/initialize()
	..()
	wait = world.time + config.gateway_delay	//+ thirty minutes default

/obj/machinery/gateway/center/process()
	if(stat & (NOPOWER|FORCEDISABLE))
		if(active)
			toggleoff()
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/center/detect()
	linked = null	//clear this
	var/turf/T= get_step(loc, SOUTH)
	var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
	if(G)
		linked = G
		linked.detect()
	else
		//this is only done if we fail to find a part
		toggleoff()

/obj/machinery/gateway/center/proc/toggleon(mob/user as mob)
	if(!linked)
		return
	if(!powered())
		return
	if(!gateway_centers_away.len)
		to_chat(user, "<span class='warning'>Error: No destination found.</span>")
		return
	if(world.time < wait)
		to_chat(user, "<span class='warning'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>")
		return

	linked.active = 1
	linked.update_icon()
	active = 1
	update_icon()

/obj/machinery/gateway/center/proc/toggleoff()
	if(linked)
		linked.active = 0
		linked.update_icon()
	active = 0
	update_icon()

/obj/machinery/gateway/center/attack_hand(mob/user as mob)
	if(!linked)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/center/Bumped(atom/movable/M as mob|obj)
	if(!linked)
		return
	if(!active)
		return
	if(!gateway_centers_away.len)
		return

	var/obj/machinery/gateway/center/away/dest = pick(gateway_centers_away) //Pick a random gateway from an away mission
	if(dest.calibrated) //If it's calibrated, move to it
		M.forceMove(get_step(dest.loc, SOUTH))
		M.dir = SOUTH
	else //Otherwise teleport to a landmark on the same z-level
		var/list/good_landmarks = list()

		for(var/obj/effect/landmark/L in awaydestinations)
			if(L.z == dest.z)
				good_landmarks.Add(L)

		if(!good_landmarks.len)
			return
		var/obj/effect/landmark/L_dest = pick(good_landmarks)
		M.forceMove(get_turf(L_dest))
		M.dir = SOUTH
	use_power(5000)
	if(ismob(M))
		var/datum/map_element/away_mission/AM = get_mission_by_z(dest.z)
		AM.onArrive(M)


/obj/machinery/gateway/center/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		to_chat(user, "<span class='warning'>The gate is already calibrated, there is no work for you to do here.</span>")
		return

/////////////////////////////////////Away////////////////////////

/obj/machinery/gateway/center/away
	use_power = MACHINE_POWER_USE_NONE
	var/calibrated = 1

/obj/machinery/gateway/center/away/New()
	..()
	gateway_centers_station.Remove(src)
	gateway_centers_away.Add(src)

/obj/machinery/gateway/center/away/Destroy()
	gateway_centers_away.Remove(src)
	..()

/obj/machinery/gateway/center/away/toggleon(mob/user as mob)
	if(!linked)
		return
	if(!gateway_centers_station.len)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return

	linked.active = 1
	linked.update_icon()
	active = 1
	update_icon()

/obj/machinery/gateway/center/away/Bumped(atom/movable/M as mob|obj)
	if(!linked)
		return
	if(!active)
		return
	if(istype(M, /mob/living/carbon))
		for(var/obj/item/weapon/implant/exile/E in M)//Checking that there is an exile implant in the contents
			if(E.imp_in == M)//Checking that it's actually implanted vs just in their pocket
				to_chat(M, "<span class='warning'>The station gate has detected your exile implant and is blocking your entry.</span>")
				return
	if(gateway_centers_station.len)
		var/obj/machinery/gateway/center/dest = pick(gateway_centers_station) //Pick a random gateway from the station
		if(dest)
			M.forceMove(get_step(dest.loc, SOUTH))
			M.dir = SOUTH

/obj/machinery/gateway/center/away/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		if(calibrated)
			to_chat(user, "<span class='warning'>The gate is already calibrated, there is no work for you to do here.</span>")
			return
		else
			to_chat(user, "<span class='notice'>Recalibration successful: This gate's systems have been fine tuned. Travel to this gate will now be on target.</span>")
			calibrated = 1
			return

/obj/machinery/gateway/center/attack_ghost(mob/user)
	if (isAdminGhost(user) && existing_away_missions.len && !active)
		admin_active(user)
		return
	return src.Bumped(user)
