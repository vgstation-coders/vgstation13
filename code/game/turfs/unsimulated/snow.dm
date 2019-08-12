#define SNOW_CALM 0
#define SNOW_AVERAGE 1
#define SNOW_HARD 2
#define SNOW_BLIZZARD 3 

//This file includes all associated code with snow tiles, snowprints, and blizzards on them.

var/list/global_snowtiles = list()
var/list/snow_state_to_texture = list()
var/snow_intensity = SNOW_CALM

/proc/greaten_snowfall()
	if(snow_intensity == SNOW_BLIZZARD)
		return
	snow_intensity++
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		tile.snow_state++
		tile.update_environment()
		
/proc/lessen_snowfall()
	if(snow_intensity == SNOW_CALM)
		return
	snow_intensity--
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		tile.snow_state--
		tile.update_environment()
	
	
	
	
/obj/effect/decal/cleanable/snowprint
	name = "snowprint"
	desc = "Brrr."
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = ""
	var/obj/effect/decal/cleanable/blood/tracks/footprints/sprite_source //Apparently all footprints are bloodprints, so we can rip the sprites for each print there.
	

	
	
/turf/unsimulated/floor/snow
	name = "snow"
	desc = "A layer of frozen water particles, kept solid by temperatures way below freezing."
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "snow0"
	temperature = T_ARCTIC
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	can_border_transition = 1
	plane = PLATING_PLANE
	var/snowball_tile = TRUE
	var/snowballs = 0
	var/snow_state = SNOW_CALM	

	
/turf/unsimulated/floor/snow/New()
	..()
	snow_state = snow_intensity
	if(snowball_tile)
		icon_state = "snow[rand(0, 6)]"
		snowballs = rand(5, 10) //Used to be (30, 50). A quick way to overload the server with atom instances.
	update_environment()
	global_snowtiles += src
	
/turf/unsimulated/floor/snow/Destroy()	
	global_snowtiles -= src
	
/turf/unsimulated/floor/snow/proc/update_environment()
	switch(snow_state)
		if(SNOW_CALM)
			temperature = T0C
		if(SNOW_AVERAGE)
			temperature = T0C-10
		if(SNOW_HARD)
			temperature = T0C-25
		if(SNOW_BLIZZARD)
			temperature = T0C-40 //233.15 Kelvin, average temperature during a snowstorm
	if(!snow_state_to_texture["[icon_state]-[snow_state]"])
		cache_snowtile()
	else
		appearance = snow_state_to_texture["[icon_state]-[snow_state]"]
		
/turf/unsimulated/floor/snow/proc/cache_snowtile()
	overlays.Cut()
	var/list/snowfall_overlays = list("snowfall_calm","snowfall_average","snowfall_hard","snowfall_blizzard")
	var/list/overlay_counts = list(2,1,1,1) 
	for(var/i = 1 to 1)
		var/image/snowfx = image('icons/turf/snowfx.dmi', "[snowfall_overlays[snow_state+1]][i]",SNOW_OVERLAY_LAYER)
		snowfx.plane = EFFECTS_PLANE
		overlays += snowfx			
	snow_state_to_texture["[icon_state]-[snow_state]"] = appearance
	
/*
/turf/unsimulated/floor/snow/Entered(atom/A, atom/OL)	
	if(istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		AddTracks(H.get_foot print_type(),bloodDNA,0,H.dir,bloodcolor)
	
/turf/unsimulated/floor/snow/proc/AddSnowprint(var/footprint_type,var/bloodDNA,var/comingdir,var/goingdir,var/bloodcolor=DEFAULT_BLOOD)
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = getFromPool(typepath, src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)
	*/
/turf/unsimulated/floor/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)

	..()

	if(snowballs && isshovel(W))
		user.visible_message("<span class='notice'>[user] starts digging out some snow with \the [W].</span>", \
		"<span class='notice'>You start digging out some snow with \the [W].</span>")
		user.delayNextAttack(20)
		if(do_after(user, src, 20))
			user.visible_message("<span class='notice'>[user] digs out some snow with \the [W].</span>", \
			"<span class='notice'>You dig out some snow with \the [W].</span>")
			extract_snowballs(5, FALSE, user)

/turf/unsimulated/floor/snow/attack_hand(mob/user as mob)

	if(snowballs)
		//Reach down and make a snowball
		user.visible_message("<span class='notice'>[user] reaches down and starts forming a snowball.</span>", \
		"<span class='notice'>You reach down and start forming a snowball.</span>")
		user.delayNextAttack(10)
		if(do_after(user, src, 5))
			user.visible_message("<span class='notice'>[user] finishes forming a snowball.</span>", \
			"<span class='notice'>You finish forming a snowball.</span>")
			extract_snowballs(1, TRUE, user)

	..()

/turf/unsimulated/floor/snow/proc/extract_snowballs(var/snowball_amount = 0, var/pick_up = FALSE, var/mob/user)

	if(!snowball_amount)
		return

	var/extract_amount = min(snowballs, snowball_amount)

	for(var/i = 0; i < extract_amount, i++)
		var/obj/item/stack/sheet/snow/snowball = new /obj/item/stack/sheet/snow(user.loc)
		snowball.pixel_x = rand(-16, 16) * PIXEL_MULTIPLIER //Would be wise to move this into snowball New() down the line
		snowball.pixel_y = rand(-16, 16) * PIXEL_MULTIPLIER

		if(pick_up)
			user.put_in_hands(snowball)

		snowballs--

	if(!snowballs)
		return

//In the future, catwalks should be the base to build in the arctic, not lattices
//This would however require a decent rework of floor construction and deconstruction
/turf/unsimulated/floor/snow/canBuildCatwalk()
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/canBuildLattice()
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/canBuildPlating()
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/Entered(mob/user)
	..()
	if(isliving(user) && !user.locked_to && !user.lying && !user.flying)
		playsound(src, pick(snowsound), 10, 1, -1, channel = 123)

/turf/unsimulated/floor/snow/permafrost
	icon_state = "permafrost_full"
	snowball_tile = FALSE
	name = "permafrost"
	desc = "Soil that never unfreezes."

/obj/glacier
	desc = "A frozen lake kept solid by temperatures way below freezing."
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice1"
	anchored = 1
	density = 0
	plane = PLATING_PLANE
	var/isedge
	var/hole = 0

/obj/glacier/canSmoothWith()
	return list(/obj/glacier)

/obj/glacier/New(var/icon_update_later = 0)
	var/turf/unsimulated/floor/snow/T = loc
	if(!istype(T))
		qdel(src)
		return
	..()
	T.snowballs = -1
	if(icon_update_later)
		relativewall()
		relativewall_neighbours()

/obj/glacier/relativewall()
	overlays.Cut()
	var/junction = 0
	isedge = 0
	var/edgenum = 0
	var/edgesnum = 0
	for(var/direction in alldirs)
		var/turf/adj_tile = get_step(src, direction)
		var/obj/glacier/adj_glacier = locate(/obj/glacier) in adj_tile
		if(adj_glacier)
			junction |= dir_to_smoothingdir(direction)
			if(adj_glacier.isedge && direction in cardinal)
				edgenum |= direction
				edgesnum = adj_glacier.isedge
	if(junction == SMOOTHING_ALLDIRS) // you win the not-having-to-smooth-lotterys
		icon_state = "ice[rand(1,6)]"
	else
		switch(junction)
			if(SMOOTHING_L_CURVES)
				isedge = junction
				relativewall_neighbours()
		icon_state = "junction[junction]"
	if(edgenum && !isedge)
		icon_state = "edge[edgenum]-[edgesnum]"

	if(hole)
		overlays += image(icon,"hole_overlay")

/obj/glacier/relativewall_neighbours()
	..()
	for(var/direction in diagonal)
		var/turf/adj_tile = get_step(src, direction)
		if(isSmoothableNeighbor(adj_tile))
			adj_tile.relativewall()
		for(var/atom/A in adj_tile)
			if(isSmoothableNeighbor(A))
				A.relativewall()

/obj/glacier/attackby(var/obj/item/W, mob/user)
	if(!hole && prob(W.force*5))
		to_chat(user,"<span class='notice'>You smash a hole in the ice with \the [W].</span>") // todo: better
		hole = TRUE
		relativewall()
	..()