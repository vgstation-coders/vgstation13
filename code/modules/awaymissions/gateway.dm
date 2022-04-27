var/list/gateways = list() //List containing all gateway parts
var/list/gateway_centers_away = list() //List containing the gateways on away missions

/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1
	anchored = 1
	pixel_y = WORLD_ICON_SIZE
	bound_x = -WORLD_ICON_SIZE
	bound_y = 2 * WORLD_ICON_SIZE
	bound_width = 3 * WORLD_ICON_SIZE
	bound_height = 2 * WORLD_ICON_SIZE
	var/active = 0

/obj/machinery/gateway/New()
	..()
	gateways.Add(src)

/obj/machinery/gateway/Destroy()
	gateways.Remove(src)
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

//this is da important part wot makes things go
/obj/machinery/gateway/center
	density =
	icon = 'icons/obj/machines/gatewaycenter.dmi'
	icon_state = "off"
	use_power = 1

	//warping vars
	var/obj/machinery/gateway/linked = null
	var/ready = 0				//have we got a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/center/away/awaygate = null

/obj/machinery/gateway/center/proc/admin_active()
	detect()
	initialize()
	wait = 0
	toggleon()

/obj/machinery/gateway/center/initialize()
	update_icon()
	wait = world.time + config.gateway_delay	//+ thirty minutes default
	awaygate = locate(/obj/machinery/gateway/center/away)

/obj/machinery/gateway/center/process()
	if(stat & (NOPOWER|FORCEDISABLE))
		if(active)
			toggleoff()
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/center/proc/detect()
	linked = null	//clear this
	var/turf/T= get_step(loc, SOUTH)
	var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
	if(G)
		linked = G
		ready = 1
	else
		//this is only done if we fail to find a part
		ready = 0
		toggleoff()

/obj/machinery/gateway/center/proc/toggleon(mob/user as mob)
	if(!ready)
		return
	if(!linked)
		return
	if(!powered())
		return
	if(!gateway_centers_away.len)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return
	if(world.time < wait)
		to_chat(user, "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>")
		return

	linked.active = 1
	linked.update_icon()
	active = 1
	update_icon()

/obj/machinery/gateway/center/proc/toggleoff()
	linked.active = 0
	linked.update_icon()
	active = 0
	update_icon()

/obj/machinery/gateway/center/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/center/Bumped(atom/movable/M as mob|obj)
	if(!ready)
		return
	if(!active)
		return
	if(!gateway_centers_away.len)
		return

	var/obj/machinery/gateway/center/away/dest = pick(gateway_centers_away) //Pick a random gateway from an away mission
	if(dest.calibrated) //If it's calibrated, move to it
		M.forceMove(get_step(dest.loc, SOUTH))
		M.dir = SOUTH
		return
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


/obj/machinery/gateway/center/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		to_chat(user, "\black The gate is already calibrated, there is no work for you to do here.")
		return

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/center/away
	density = 1
	icon = 'icons/obj/machines/gatewaycenter.dmi'
	icon_state = "off"
	use_power = 0
	var/calibrated = 1
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0
	var/obj/machinery/gateway/center/away/stationgate = null

/obj/machinery/gateway/center/away/New()
	..()
	gateway_centers_away.Add(src)

/obj/machinery/gateway/center/away/Destroy()
	gateway_centers_away.Remove(src)
	..()

/obj/machinery/gateway/center/away/initialize()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/center)

/obj/machinery/gateway/center/away/toggleon(mob/user as mob)
	if(!ready)
		return
	if(!linked)
		return
	if(!stationgate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return

	linked.active = 1
	linked.update_icon()
	active = 1
	update_icon()

/obj/machinery/gateway/center/away/Bumped(atom/movable/M as mob|obj)
	if(!ready)
		return
	if(!active)
		return
	if(istype(M, /mob/living/carbon))
		for(var/obj/item/weapon/implant/exile/E in M)//Checking that there is an exile implant in the contents
			if(E.imp_in == M)//Checking that it's actually implanted vs just in their pocket
				to_chat(M, "\black The station gate has detected your exile implant and is blocking your entry.")
				return
	M.forceMove(get_step(stationgate.loc, SOUTH))
	M.dir = SOUTH


/obj/machinery/gateway/center/away/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		if(calibrated)
			to_chat(user, "\black The gate is already calibrated, there is no work for you to do here.")
			return
		else
			to_chat(user, "<span class='notice'><b>Recalibration successful!</b>: </span>This gate's systems have been fine tuned.  Travel to this gate will now be on target.")
			calibrated = 1
			return

/obj/machinery/gateway/center/attack_ghost(mob/user)
	if (isAdminGhost(user) && existing_away_missions.len)
		admin_active()
		return
	return src.Bumped(user)

/obj/machinery/gateway/center/away/attack_ghost(mob/user as mob)
	return src.Bumped(user)
