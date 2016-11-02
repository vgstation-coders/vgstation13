//Arctic atmospheric defines

#define ARCTIC_ATMOSPHERE 90.13
#define T_ARCTIC 223.65 //- 49.5 Celcius, taken from South Pole averages
#define MOLES_ARCTICSTANDARD (ARCTIC_ATMOSPHERE*CELL_VOLUME/(T_ARCTIC*R_IDEAL_GAS_EQUATION)) //Note : Open air tiles obviously aren't 2.5 meters in height, but abstracted for now with infinite atmos
#define MOLES_O2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*O2STANDARD	//O2 standard value (21%)
#define MOLES_N2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*N2STANDARD	//N2 standard value (79%)
#define SNOW_LAYER_NUMBER 2

var/global/list/snow_turfs = list()

/turf/snow
	name = "snow"
	desc = "A layer of frozen water particles, kept solid by temperatures way below freezing."
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "snow"
	temperature = T_ARCTIC
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	light_color = "#e5ffff"
	can_border_transition = 1
	dynamic_lighting = 0
	luminosity = 1
	plane = BELOW_TURF_PLANE

	var/snowballs = 0
	var/global/list/cached_appearances = list()
	var/list/snowsound = list('sound/misc/snow1.ogg', 'sound/misc/snow2.ogg', 'sound/misc/snow3.ogg', 'sound/misc/snow4.ogg', 'sound/misc/snow5.ogg', 'sound/misc/snow6.ogg')

/turf/snow/New()
	if(z != map.zCentcomm)
		snow_turfs += src
	..()
	if(ticker)
		initialize()

/turf/snow/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	snow_turfs -= src
	return ..()

/turf/snow/initialize()
	if(!cached_appearances.len)	// first time running, let's CACHE IMAGES
		for(var/i = 1 to SNOW_LAYER_NUMBER) // saves us two (2!) whole lines but I don't like copypasting, plus hopefully one day people will make more
			var/image/snowfx = image('icons/turf/snowfx.dmi', "snowlayer[i]")
			snowfx.plane = EFFECTS_PLANE
			cached_appearances["snowlayer[i]"] = snowfx
		for(var/dirtdir in alldirs)
			cached_appearances["side[dirtdir]"] = image('icons/turf/new_snow.dmi', "permafrost_side" ,dir = dirtdir)
	var/snowrand = rand(0, 5)
	var/list/oranges = orange(1,src)
	if(locate(/turf/simulated) in oranges || (locate(/turf/unsimulated) in oranges && z != map.zCentcomm))
		update_icon(oranges,snowrand)
		set_light(5, 0.5)
	else if(cached_appearances["[snowrand]-0"])
		appearance = cached_appearances["[snowrand]-0"]
	else
		update_icon(oranges,snowrand)
	..()

/turf/snow/update_icon(var/list/oranges,var/snowrand)
	var/list/dirlist = list()
	var/dirnum = 0

	for(var/turf/simulated/T in oranges)
		var/direction = get_dir(src,T)
		dirlist += direction
		dirnum |= direction

	if(cached_appearances["[snowrand]-[dirnum]"])
		appearance = cached_appearances["[snowrand]-[dirnum]"]
	else
		icon_state = "snow[snowrand]"

		//for(var/direction in dirlist) - temporary measure: readd soon
		//	overlays += cached_appearances["side[direction]"]

		for(var/i = 1 to SNOW_LAYER_NUMBER) // saves us one (1!) whole lines but I don't like copypasting, plus hopefully one day people will make more (yes this line is copypasted from above, sue me :^) )
			overlays += cached_appearances["snowlayer[i]"]

		cached_appearances["[snowrand]-[dirnum]"] = appearance

/turf/snow/permafrost
	icon_state = "permafrost_full"

/turf/snow/permafrost/initialize()
	..()
	snowballs = 0
	new /obj/dirtpath(src)


/turf/snow/attackby(var/obj/item/weapon/W, var/mob/user)
	if(contents.len)
		for(var/obj/structure/flora/flora in contents)
			flora.attackby(W,user)
			return 0
	..()

	if(istype(W, /obj/item/weapon/pickaxe/shovel) && snowballs)
		user.visible_message("<span class='notice'>[user] starts digging out some snow with \the [W].</span>", \
		"<span class='notice'>You start digging out some snow with \the [W].</span>")
		user.delayNextAttack(20)
		if(do_after(user, src, 20) && extract_snowballs(5, user))
			user.visible_message("<span class='notice'>[user] digs out some snow with \the [W].</span>", \
			"<span class='notice'>You dig out some snow with \the [W].</span>")


/turf/snow/attack_hand(var/mob/user)
	if(snowballs) //Reach down and make a snowball
		user.visible_message("<span class='notice'>[user] reaches down and starts forming a snowball.</span>", \
		"<span class='notice'>You reach down and start forming a snowball.</span>")
		user.delayNextAttack(5)
		if(do_after(user, src, 5) && extract_snowballs(1,user,1))
			user.visible_message("<span class='notice'>[user] finishes forming a snowball.</span>", \
			"<span class='notice'>You finish forming a snowball.</span>")

	..()

/turf/snow/proc/extract_snowballs(var/snowball_amount = 0, var/mob/user, var/pick_up = 0)

	if(!snowball_amount || !snowballs)
		return

	var/extract_amount = min(snowballs, snowball_amount)

	for(var/i = 0; i < extract_amount, i++)
		var/obj/item/stack/sheet/snow/snowball = new

		if(pick_up)
			user.put_in_hands(snowball)

		snowballs--

	if(!snowballs) //We're out of snow, get a path.
		new /obj/dirtpath(src)
	return 1

//In the future, catwalks should be the base to build in the arctic, not lattices
//This would however require a decent rework of floor construction and deconstruction
/turf/snow/canBuildCatwalk()
	return BUILD_FAILURE

/turf/snow/canBuildLattice()
	if(snowballs)
		return BUILD_FAILURE
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/snow/canBuildPlating()
	if(snowballs)
		return BUILD_FAILURE
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/snow/Entered(mob/user)
	if(!ticker)
		return
	..()
	if(isliving(user) && !user.locked_to && !user.lying && !user.flying)
		playsound(get_turf(src), pick(snowsound), 10, 1, -1, channel = 123)

/obj/dirtpath
	name = "dirt path"
	desc = "A frozen dirt path."
	icon = 'icons/turf/new_snow.dmi'
	canSmoothWith = "/obj/dirtpath=0&/turf/simulated"
	var/global/list/diags = list()
	anchored = 1
	density = 0
	plane = PLATING_PLANE

/obj/dirtpath/New()
	if(!istype(loc,/turf/snow))
		qdel(src)
		return
	..()
	relativewall()
	relativewall_neighbours()

/obj/dirtpath/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pickaxe/shovel) && !locate(/obj/machinery/portable_atmospherics/hydroponics/soil,src))
		user.visible_message("<span class='notice'>[user] begins to dig away at the dirt path.</span>", \
		"<span class='notice'>You begin to dig away at the dirt path.</span>")
		user.delayNextAttack(5)
		if(do_after(user, src, 5))
			user.visible_message("<span class='notice'>[user] finishes digging at the dirt path.</span>", \
			"<span class='notice'>You finish digging at the dirt path.</span>")
			new /obj/machinery/portable_atmospherics/hydroponics/soil/snow(src)
	else ..()

/obj/dirtpath/relativewall_neighbours()
	..()
	for(var/direction in diagonal)
		var/turf/adj_tile = get_step(src, direction)
		if(isSmoothableNeighbor(adj_tile))
			adj_tile.relativewall()
		for(var/atom/A in adj_tile)
			if(isSmoothableNeighbor(A))
				A.relativewall()

/obj/dirtpath/relativewall()
	overlays.Cut()
	if(!diags.len)
		for(var/diagdir in diagonal)
			diags["diag[diagdir]"] = image('icons/turf/new_snow.dmi', "permafrost_corner", dir = diagdir)
	var/junction = findSmoothingNeighbors()
	var/dircount = 0
	for(var/direction in diagonal)
		var/turf/adj_tile = get_step(src, direction)
		if(isSmoothableNeighbor(adj_tile) || locate(/obj/dirtpath,adj_tile))
			if((direction & junction) == direction)
				overlays += diags["diag[direction]"]
				dircount++

	switch(dircount)
		if(4)
			overlays.Cut()
			junction = "_full"
		if(0)
			if(!junction)
				junction = "_circle"
	icon_state = "permafrost[junction]"