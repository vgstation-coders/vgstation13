//Arctic atmospheric defines

#define ARCTIC_ATMOSPHERE 90.13
#define T_ARCTIC 223.65 //- 49.5 Celcius, taken from South Pole averages
#define MOLES_ARCTICSTANDARD (ARCTIC_ATMOSPHERE*CELL_VOLUME/(T_ARCTIC*R_IDEAL_GAS_EQUATION)) //Note : Open air tiles obviously aren't 2.5 meters in height, but abstracted for now with infinite atmos
#define MOLES_O2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*O2STANDARD	//O2 standard value (21%)
#define MOLES_N2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*N2STANDARD	//N2 standard value (79%)
#define SNOW_LAYER_NUMBER 2

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
	var/seed = rand(1,10000)
	switch(seed)
		if(1 to 100)
			new /obj/structure/radial_gen/movable/snow_nature/snow_forest(src)
		if(101 to 110)
			new /obj/structure/radial_gen/movable/snow_nature/snow_forest/dense(src)
		if(110 to 300)
			new /obj/structure/radial_gen/movable/snow_nature/snow_grass(src)
	..()
	if(ticker)
		initialize()

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
	if(locate(/turf/simulated) in oranges)
		update_icon(oranges,snowrand)
		set_light(5, 0.5)
	else if(cached_appearances["[snowrand]0"])
		appearance = cached_appearances["[snowrand]0"]
	else
		update_icon(oranges,snowrand)
	..()

/turf/snow/update_icon(var/list/oranges,var/snowrand)
	var/list/dirlist = list()
	var/dirnum = 0

	for(var/turf/simulated/T in oranges)
		var/direction = get_dir(src,T)
		dirlist += direction
		dirnum &= direction

	if(cached_appearances["[snowrand][dirnum]"])
		appearance = cached_appearances["[snowrand][dirnum]"]
	else
		icon_state = "snow[snowrand]"

		for(var/direction in dirlist)
			overlays += cached_appearances["side[direction]"]

		for(var/i = 1 to SNOW_LAYER_NUMBER) // saves us one (1!) whole lines but I don't like copypasting, plus hopefully one day people will make more (yes this line is copypasted from above, sue me :^) )
			overlays += cached_appearances["snowlayer[i]"]

		cached_appearances["[snowrand][dirnum]"] = appearance


/turf/snow/permafrost/initialize()
	..()
	snowballs = 0
	new /obj/dirtpath(src)

/turf/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)

	..()

	if(istype(W, /obj/item/weapon/pickaxe/shovel) && snowballs)
		user.visible_message("<span class='notice'>[user] starts digging out some snow with \the [W].</span>", \
		"<span class='notice'>You start digging out some snow with \the [W].</span>")
		user.delayNextAttack(20)
		if(do_after(user, src, 20) && extract_snowballs(5, 0, user))
			user.visible_message("<span class='notice'>[user] digs out some snow with \the [W].</span>", \
			"<span class='notice'>You dig out some snow with \the [W].</span>")


/turf/snow/attack_hand(mob/user as mob)
	if(snowballs) //Reach down and make a snowball
		user.visible_message("<span class='notice'>[user] reaches down and starts forming a snowball.</span>", \
		"<span class='notice'>You reach down and start forming a snowball.</span>")
		user.delayNextAttack(10)
		if(do_after(user, src, 5) && extract_snowballs(1, 1, user))
			user.visible_message("<span class='notice'>[user] finishes forming a snowball.</span>", \
			"<span class='notice'>You finish forming a snowball.</span>")

	..()

/turf/snow/proc/extract_snowballs(var/snowball_amount = 0, var/pick_up = 0, var/mob/user)

	if(!snowball_amount || !snowballs)
		return

	var/extract_amount = min(snowballs, snowball_amount)

	for(var/i = 0; i < extract_amount, i++)
		var/obj/item/stack/sheet/snow/snowball = new /obj/item/stack/sheet/snow(user.loc)
		snowball.pixel_x = rand(-16, 16) * PIXEL_MULTIPLIER //Would be wise to move this into snowball New() down the line
		snowball.pixel_y = rand(-16, 16) * PIXEL_MULTIPLIER

		if(pick_up)
			user.put_in_hands(snowball)

		snowballs--

	if(!snowballs) //We're out of snow, get a path.
		new /obj/dirtpath(src)

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
	..()
	if(isliving(user) && !user.locked_to && !user.lying && !user.flying)
		playsound(get_turf(src), pick(snowsound), 10, 1, -1, channel = 123)

/obj/dirtpath
	name = "dirt path"
	desc = "A frozen dirt path."
	icon = 'icons/turf/new_snow.dmi'
	canSmoothWith = "/obj/dirtpath"
	var/list/appearances = list()
	anchored = 1
	density = 0

/obj/dirtpath/New()
	if(!istype(loc,/turf/snow))
		qdel(src)
		return
	..()
	relativewall()
	relativewall_neighbours()

/obj/dirtpath/relativewall_neighbours()
	..()
	for(var/direction in diagonal)
		var/turf/adj_tile = get_step(src, direction)
		for(var/atom/A in adj_tile)
			if(isSmoothableNeighbor(A))
				A.relativewall()

/obj/dirtpath/relativewall()
	if(!appearances.len) // this is awful but because of smoothwall not liking diagonals it's the only way to do this right now. certainly a TODO
		for(var/diagdir in diagonal)
			appearances["diag[diagdir]"] = image('icons/turf/new_snow.dmi', "permafrost_corner", dir = diagdir)
			appearances["snow[diagdir]"] = image('icons/turf/new_snow.dmi', "permafrost", dir = diagdir)
		for(var/dirtdir in cardinal)
			appearances["snow[dirtdir]"] = image('icons/turf/new_snow.dmi', "permafrost_half", dir = dirtdir)
			var/realdir = null
			switch(dirtdir)
				if(NORTH)
					realdir = EAST|SOUTH|WEST
				if(SOUTH)
					realdir = WEST|NORTH|EAST
				if(EAST)
					realdir = SOUTH|WEST|NORTH
				if(WEST)
					realdir = NORTH|EAST|SOUTH
			appearances["snow[realdir]"] = image('icons/turf/new_snow.dmi', "permafrost_tjunction", dir = dirtdir)
		appearances["snow15"] = image('icons/turf/new_snow.dmi', "permafrost_crossroads")
		appearances["snow0"] = image('icons/turf/new_snow.dmi', "permafrost_circle")
		appearances["snow3"] = image('icons/turf/new_snow.dmi', "permafrost", dir = NORTH)
		appearances["snow12"] = image('icons/turf/new_snow.dmi', "permafrost", dir = WEST)

	var/junction = findSmoothingNeighbors()
	var/dircount = 0
	for(var/direction in diagonal)
		if(locate(/obj/dirtpath,get_step(src, direction)))
			if((direction & junction) == direction)
				overlays += appearances["diag[direction]"]
				dircount++
	if(dircount == 4)
		overlays.Cut()
		icon_state = "permafrost_full"
	else if(junction)
		overlays += appearances["snow[junction]"]
	else
		overlays += appearances["snow0"]