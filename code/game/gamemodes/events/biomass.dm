/**
 * Biomass (note that this code is very similar to Space Vine code)
 */
/obj/effect/biomass
	name = "biomass"
	desc = "Space barf from another dimension. It just keeps spreading!"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "stage1"
	anchored = 1
	density = 0
	plane = ABOVE_HUMAN_PLANE
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/biomass_controller/master = null
	var/health = 15

/obj/effect/biomass/Destroy()
	unreferenceMaster()
	..()

/obj/effect/biomass/proc/unreferenceMaster()
	if(master)
		master.growth_queue -= src
		master.vines -= src
		master = null

/obj/effect/biomass/attackby(var/obj/item/weapon/W, mob/user)
	if(W.sharpness_flags & SHARP_BLADE && prob(50)) //Not a guarantee
		if(prob(30))
			user.visible_message("<span class = 'warning'>\The [user] cuts through \the [src] with \the [W]'s sharp edge.</span>",\
			"<span class = 'notice'>You cut through \the [src] with \the [W]'s sharp edge.</span>")
		adjust_health(rand(5,15))
		return
	if(W.sharpness_flags & (SERRATED_BLADE|CHOPWOOD)) //Guaranteed, but takes some work
		if(do_after(user, src, rand(10,30)))
			if(prob(30))
				user.visible_message("<span class = 'warning'>\The [user] chops through \the [src] with \the [W].</span>",\
				"<span class = 'notice'>You saw through \the [src].</span>")
			adjust_health(rand(25,50))
			return
	if(W.sharpness_flags & HOT_EDGE)
		if(do_after(user, src, rand(5,15))) //Guaranteed, rarer sharpness flag so less time taken
			if(prob(30))
				user.visible_message("<span class = 'warning'>\The [user] sears through \the [src] with \the [W].</span>",\
				"<span class = 'notice'>You use \the [W]'s hot edge to burn through \the [src].</span>")
			adjust_health(rand(20,35))
			return
	var/weapon_temp = W.is_hot()
	if(weapon_temp >= AUTOIGNITION_WOOD)//Yes it's not technically wood, but fibrous chitin's pretty close when held above a flame
		var/coeff = 1*weapon_temp/AUTOIGNITION_WOOD //The hotter it is, the less time it takes
		if(do_after(user, src, (rand(30,60)/coeff)))
			if(prob(30))
				user.visible_message("<span class = 'warning'>\The [user] burns away \the [src] with \the [W].</span>",\
				"<span class = 'notice'>You use \the [W] to burn away \the [src].</span>")
			adjust_health(rand(40,70))
			return
	..()

/obj/effect/biomass/proc/grow()
	if(energy <= 0)
		icon_state = "stage2"
		energy = 1
		adjust_health(-30)
	else
		icon_state = "stage3"
		setDensity(TRUE)
		energy = 2
		adjust_health(-30)

/obj/effect/biomass/proc/adjust_health(var/amount)
	health -= amount
	if(health <= 0)
		qdel(src)

/obj/effect/biomass/proc/spread()
	var/location = get_step(src, pick(alldirs))

	if(istype(location, /turf/simulated/floor))
		var/turf/simulated/floor/Floor = location

		if(isnull(locate(/obj/effect/biomass) in Floor))
			if(Floor.Enter(src, loc))
				if(master)
					master.spawn_biomass_piece(Floor)
					return 1
	return 0

/obj/effect/biomass/ex_act(severity)
	switch(severity)
		if(1.0)
			adjust_health(100)
		if(2.0)
			adjust_health(65)
		if(3.0)
			adjust_health(25)

/obj/effect/biomass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume) //hotspots kill biomass
	if(exposed_temperature >= AUTOIGNITION_WOOD)
		adjust_health(70)

/obj/effect/biomass_controller
	invisibility = 60 // ghost only

	var/list/obj/effect/biomass/vines = new
	var/list/growth_queue = new

	// what this does is that instead of having the grow minimum of 1,
	// required to start growing, the minimum will be 0,
	// meaning if you get the biomasssss..s' size to something less than 20 plots,
	// it won't grow anymore.
	var/reached_collapse_size = FALSE
	var/reached_slowdown_size = FALSE

/obj/effect/biomass_controller/New(loc)
	..(loc)

	if(!istype(loc, /turf/simulated/floor))
		qdel(src)

	spawn_biomass_piece(loc)
	processing_objects += src

/obj/effect/biomass_controller/Destroy() // controller is kill, no!!!111
	if(vines && vines.len > 0)
		for(var/obj/effect/biomass/Biomass in vines)
			Biomass.unreferenceMaster()

	processing_objects -= src
	..()

/obj/effect/biomass_controller/proc/spawn_biomass_piece(var/turf/location)
	var/obj/effect/biomass/Biomass = new(location)
	Biomass.master = src
	vines += Biomass
	growth_queue += Biomass

/obj/effect/biomass_controller/process()
	if(isnull(vines) || vines.len == 0) // sanity and existing biomass check
		qdel(src)
		return

	if(isnull(growth_queue)) // sanity check
		qdel(src)
		return

	if(vines.len >= 250 && !reached_collapse_size)
		reached_collapse_size = TRUE

	if(vines.len >= 30 && !reached_slowdown_size)
		reached_slowdown_size = TRUE

	var/maxgrowth = 0

	if(reached_collapse_size)
		maxgrowth = 0
	else if(reached_slowdown_size)
		if(prob(25))
			maxgrowth = 1
		else
			maxgrowth = 0
	else
		maxgrowth = 4

	var/length = min(30, vines.len / 5)
	var/i = 0
	var/growth = 0
	var/list/obj/effect/biomass/queue_end = new

	for(var/obj/effect/biomass/Biomass in growth_queue)
		i++
		growth_queue -= Biomass
		queue_end += Biomass

		if(Biomass.energy < 2) // if biomass isn't fully grown
			if(prob(20))
				Biomass.grow()

		if(Biomass.spread())
			growth++

			if(growth >= maxgrowth)
				break

		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/proc/biomass_infestation()
	set waitfor = 0

	// list of all the empty floor turfs in the hallway areas
	var/list/turf/simulated/floor/Floors = new

	for(var/type in typesof(/area/hallway))
		var/area/Hallway = locate(type)

		for(var/turf/simulated/floor/Floor in Hallway.contents)
			if(!is_blocked_turf(Floor))
				Floors += Floor

	if(Floors.len) // pick a floor to spawn at
		var/turf/simulated/floor/Floor = pick(Floors)
		new/obj/effect/biomass_controller(Floor) // spawn a controller at floor
		log_admin("Event: Biomass spawned at [Floor.loc] ([Floor.x],[Floor.y],[Floor.z]).")
		message_admins("<span class='notice'>Event: Biomass spawned at [Floor.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[Floor.x];Y=[Floor.y];Z=[Floor.z]'>(JMP)</a></span>")