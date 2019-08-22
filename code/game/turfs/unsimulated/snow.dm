#define SNOW_CALM 0
#define SNOW_AVERAGE 1
#define SNOW_HARD 2
#define SNOW_BLIZZARD 3

//This file includes all associated code with snow tiles, snowprints, and blizzards on them.

var/list/global_snowtiles = list()
var/list/snow_state_to_texture = list()
var/snowtiles_setup = 0
var/snow_intensity = SNOW_CALM
var/blizzard_ready = 1 //Whether a new blizzard can be started.
var/list/snowstorm_ambience = list('sound/misc/snowstorm/snowfall_calm.ogg','sound/misc/snowstorm/snowfall_average.ogg','sound/misc/snowstorm/snowfall_hard.ogg','sound/misc/snowstorm/snowfall_blizzard.ogg')
var/list/snowstorm_ambience_volumes = list(30,40,60,80)



var/blizzard_cooldown = 3000 //5 minutes minimum

/datum/event/blizzard/start() //Fuck using event code, we'll code all of this here
	if(blizzard_ready)
		blizzard_ready = 0
		command_alert(/datum/command_alert/blizzard_start)
		sleep(rand(20 SECONDS, 2 MINUTES))
		greaten_snowfall()
		sleep(rand(3 MINUTES, 6 MINUTES))
		greaten_snowfall()
		sleep(rand(8 MINUTES, 13 MINUTES))
		lessen_snowfall()
		sleep(rand(3 MINUTES, 6 MINUTES))
		lessen_snowfall()
		sleep(rand(20 SECONDS, 40 SECONDS))
		command_alert(/datum/command_alert/blizzard_end)
		spawn(blizzard_cooldown)
			blizzard_ready = 1

/datum/event/omega_blizzard
	oneShot = 1

/datum/event/omega_blizzard/start() //Oh god oh fuck
	if(blizzard_ready)
		blizzard_ready = 0
		command_alert(/datum/command_alert/omega_blizzard)
		sleep(rand(20 SECONDS, 30 SECONDS))
		greaten_snowfall()
		sleep(rand(50 SECONDS, 2 MINUTES))
		greaten_snowfall()
		sleep(rand(3 MINUTES, 5 MINUTES))
		greaten_snowfall() //Never-ending MISERY

/proc/force_update_snowfall_sfx() //Since the vision blocking UI only updates on Entered, let's call it.
	for(var/mob/M in player_list)
		if(M && M.client)
			var/turf/unsimulated/floor/snow/snow = get_turf(M)
			if(snow && istype(snow))
				snow.Entered(M)
				M << sound(snowstorm_ambience[snow_intensity+1], repeat = 1, wait = 0, channel = CHANNEL_WEATHER, volume = snowstorm_ambience_volumes[snow_intensity+1])





/proc/greaten_snowfall()
	if(snow_intensity == SNOW_BLIZZARD)
		return
	snow_intensity++
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		tile.snow_state = snow_intensity
		tile.update_environment()
	force_update_snowfall_sfx()

/proc/lessen_snowfall()
	if(snow_intensity == SNOW_CALM)
		return
	snow_intensity--
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		tile.snow_state = snow_intensity
		tile.update_environment()
	force_update_snowfall_sfx()

/proc/snowfall_tick()
	switch(snow_intensity)
		if(SNOW_CALM)
			snowfall_calm_tick()
		if(SNOW_AVERAGE)
			snowfall_average_tick()
		if(SNOW_HARD)
			snowfall_hard_tick()
		if(SNOW_BLIZZARD)
			snowfall_blizzard_tick()

/proc/snowfall_calm_tick()
	var/tile_interval = 5
	if(prob(3))
		var/i = rand(1,tile_interval) //Efficiently selects a set of random tiles to melt snow on. 
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(-1,0)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++
/proc/snowfall_average_tick()
	var/tile_interval = 5
	if(prob(5))
		var/i = rand(1,tile_interval)
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(1,8)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++


/proc/snowfall_hard_tick()
	var/tile_interval = 5
	if(prob(8))
		var/i = rand(1,tile_interval)
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(2,15)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++


/proc/snowfall_blizzard_tick()
	var/tile_interval = 3
	if(prob(12))
		var/i = rand(1,tile_interval)
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(3,20)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++





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
	var/real_snow_tile = TRUE //Set this to false if you want snowfall/blizzard overlay but no texture updating nor ability to pick up snowballs.
	var/initial_snowballs = -1 //-1 means random.
	var/snowballs = 0
	var/snow_state = SNOW_CALM
	var/obj/effect/snowprint_holder/snowprint_parent
	var/obj/effect/blizzard_holder/blizzard_parent
	turf_speed_multiplier = 1
	gender = PLURAL
	
/turf/unsimulated/floor/snow/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	if(snowprint_parent)
		qdel(snowprint_parent)
	if(blizzard_parent)
		qdel(blizzard_parent)	
	..()

/turf/unsimulated/floor/snow/New()
	..()
	blizzard_parent = new /obj/effect/blizzard_holder(src)
	blizzard_parent.parent = src
	if(!snowtiles_setup)
		for(var/i = 0 to 3)
			snow_state = i 
			blizzard_parent.UpdateSnowfall()
		snowtiles_setup = 1
	snow_state = snow_intensity
	if(real_snow_tile)
		if(initial_snowballs == -1)
			snowballs = rand(5, 10)
		else
			snowballs = initial_snowballs
		icon_state = "snow[rand(0, 6)]"
		snowprint_parent = new /obj/effect/snowprint_holder(src)
	update_environment()
	global_snowtiles += src

/turf/unsimulated/floor/snow/Destroy()
	global_snowtiles -= src
	if(snowprint_parent)
		qdel(snowprint_parent)
	if(blizzard_parent)
		qdel(blizzard_parent)

/turf/unsimulated/floor/snow/proc/update_environment()
	if(real_snow_tile)
		if(snowballs)
			icon_state = "snow[rand(0,6)]"
		else
			icon_state = "permafrost_full"
			if(snowprint_parent)
				snowprint_parent.ClearSnowprints()
	blizzard_parent.UpdateSnowfall()
	switch(snow_state)
		if(SNOW_CALM)
			temperature = T_ARCTIC
			turf_speed_multiplier = 1
		if(SNOW_AVERAGE)
			temperature = T_ARCTIC-5
			turf_speed_multiplier = 1.15 //For some reason, higher numbers mean slower.
		if(SNOW_HARD)
			temperature = T_ARCTIC-10
			turf_speed_multiplier = 1.6
		if(SNOW_BLIZZARD)
			temperature = T_ARCTIC-20
			turf_speed_multiplier = 2.9
	turf_speed_multiplier *= 1+(snowballs/10)

/turf/unsimulated/floor/snow/Exited(atom/A, atom/newloc)
	..()
	if(istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(snowprint_parent && snowballs)
			snowprint_parent.AddSnowprintGoing(H.get_footprint_type(),H.dir)
		if(!istype(newloc,/turf/unsimulated/floor/snow))
			H.clear_fullscreen("snowfall_average",0)
			H.clear_fullscreen("snowfall_hard",0)
			H.clear_fullscreen("snowfall_blizzard",0)
			H << sound(null, 0, 0, channel = CHANNEL_WEATHER)
	

/turf/unsimulated/floor/snow/Entered(atom/A, atom/OL)	
	..()
	if(istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(snowprint_parent && snowballs)
			snowprint_parent.AddSnowprintComing(H.get_footprint_type(),H.dir)
		switch(snow_state)
			if(SNOW_CALM)
				H.clear_fullscreen("snowfall_average",0)
				H.clear_fullscreen("snowfall_hard",0)
				H.clear_fullscreen("snowfall_blizzard",0)
			if(SNOW_AVERAGE)
				H.overlay_fullscreen("snowfall_average", /obj/abstract/screen/fullscreen/snowfall_average)
				H.clear_fullscreen("snowfall_hard",0)
				H.clear_fullscreen("snowfall_blizzard",0)
			if(SNOW_HARD)
				H.clear_fullscreen("snowfall_average",0)
				H.overlay_fullscreen("snowfall_hard", /obj/abstract/screen/fullscreen/snowfall_hard)
			if(SNOW_BLIZZARD)
				H.clear_fullscreen("snowfall_average",0)
				H.clear_fullscreen("snowfall_hard",0)
				H.overlay_fullscreen("snowfall_blizzard", /obj/abstract/screen/fullscreen/snowfall_blizzard)
		if(H.client)
			if(!istype(OL,/turf/unsimulated/floor/snow))
				H << sound(snowstorm_ambience[snow_state+1], repeat = 1, wait = 0, channel = CHANNEL_WEATHER, volume = snowstorm_ambience_volumes[snow_state+1])
			if(isliving(H) && !H.locked_to && !H.lying && !H.flying)
				playsound(src, pick(snowsound), 10, 1, -1, channel = 123)

/turf/unsimulated/floor/snow/cultify()
	return //It's already pretty red out in nar-sie universe.

/obj/effect/blizzard_holder //Exists to make it unclickable 
	name = "blizzard"
	desc = "Brrr."
	density = 0
	anchored = 1
	plane = ABOVE_TURF_PLANE	
	mouse_opacity = 0 
	var/turf/unsimulated/floor/snow/parent
	
/obj/effect/blizzard_holder/proc/UpdateSnowfall()
	if(!snow_state_to_texture["[parent.snow_state]"])
		cache_snowtile()
	appearance = snow_state_to_texture["[parent.snow_state]"]

/obj/effect/blizzard_holder/proc/cache_snowtile()
	overlays.Cut()
	var/list/snowfall_overlays = list("snowfall_calm","snowfall_average","snowfall_hard","snowfall_blizzard")
	var/list/overlay_counts = list(2,2,2,3)
	for(var/i = 1 to overlay_counts[parent.snow_state+1])
		var/image/snowfx = image('icons/turf/snowfx.dmi', "[snowfall_overlays[parent.snow_state+1]][i]",SNOW_OVERLAY_LAYER)
		snowfx.plane = EFFECTS_PLANE
		overlays += snowfx			
	snow_state_to_texture["[parent.snow_state]"] = appearance



/obj/effect/snowprint_holder
	name = "snowprint"
	desc = "Brrr."
	density = 0
	anchored = 1
	plane = ABOVE_TURF_PLANE
	mouse_opacity = 0 //Unclickable
	var/snowprint_color = "#BEBEBE"
	var/list/existing_prints = list()
	
/obj/effect/snowprint_holder/proc/AddSnowprintComing(var/obj/effect/decal/cleanable/blood/tracks/footprints/footprint_type, var/dir)
	if(existing_prints["[initial(footprint_type.coming_state)]-[dir]"])
		return
	existing_prints["[initial(footprint_type.coming_state)]-[dir]"] = 1
	var/icon/footprint = icon('icons/effects/fluidtracks.dmi', initial(footprint_type.coming_state), dir)
	footprint.SwapColor("#FFFFFF",snowprint_color)
	overlays += footprint

/obj/effect/snowprint_holder/proc/AddSnowprintGoing(var/obj/effect/decal/cleanable/blood/tracks/footprints/footprint_type, var/dir)
	if(existing_prints["[initial(footprint_type.going_state)]-[dir]"])
		return
	existing_prints["[initial(footprint_type.going_state)]-[dir]"] = 1
	var/icon/footprint = icon('icons/effects/fluidtracks.dmi', initial(footprint_type.going_state), dir)
	footprint.SwapColor("#FFFFFF",snowprint_color)
	overlays += footprint

/obj/effect/snowprint_holder/proc/ClearSnowprints()
	overlays.Cut()
	existing_prints.len = 0



/turf/unsimulated/floor/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)

	..()

	if(snowballs && isshovel(W))
		user.visible_message("<span class='notice'>[user] digs out some snow with \the [W].</span>", \
		"<span class='notice'>You dig out some snow with \the [W].</span>")
		user.delayNextAttack(20)
		extract_snowballs(5, FALSE, user)
	else if(snowballs && istype(W,/obj/item/stack/sheet/snow))
		user.visible_message("<span class='notice'>[user] reaches down and gathers more snow.</span>", \
		"<span class='notice'>You reach down and bolster your snowball.</span>")
		user.delayNextAttack(10)
		extract_snowballs(1, TRUE, user, W)


/turf/unsimulated/floor/snow/attack_hand(mob/user as mob)

	if(snowballs)
		//Reach down and make a snowball
		user.visible_message("<span class='notice'>[user] reaches down and forms a snowball.</span>", \
		"<span class='notice'>You reach down and form a snowball.</span>")
		user.delayNextAttack(10)
		extract_snowballs(1, TRUE, user)

	..()

/turf/unsimulated/floor/snow/examine(var/mob/user)
	..()
	if(real_snow_tile)
		if(snowballs)
			to_chat(user,"<span class='info'>It seems to be [snowballs*2]cm high.</span>")
		else
			to_chat(user,"<span class='info'>It seems almost entirely devoid of snow, exposing the permafrost below.</span>")

/turf/unsimulated/floor/snow/proc/change_snowballs(var/delta, var/limit) //Changes snowball count by delta, but to be no lower/greater than limit. Updates texture, too.
	if(delta >= 0)
		snowballs += delta
		if(snowballs > limit)
			snowballs = limit
	else
		snowballs -= delta
		if(snowballs < limit)
			snowballs = limit
		else if(snowballs < 0)
			snowballs = 0
	update_environment()

/turf/unsimulated/floor/snow/proc/extract_snowballs(var/snowball_amount = 0, var/pick_up = FALSE, var/mob/user, var/obj/item/stack/sheet/snow/snowball_stack = null)

	if(!snowball_amount)
		return

	var/extract_amount = min(snowballs, snowball_amount)

	for(var/i = 0; i < extract_amount, i++)
		if(snowball_stack)
			snowball_stack.add(1)
			snowballs--
			break
		var/obj/item/stack/sheet/snow/snowball = new /obj/item/stack/sheet/snow(user.loc)
		snowball.pixel_x = rand(-16, 16) * PIXEL_MULTIPLIER //Would be wise to move this into snowball New() down the line
		snowball.pixel_y = rand(-16, 16) * PIXEL_MULTIPLIER

		if(pick_up)
			user.put_in_hands(snowball)

		snowballs--

	update_environment()

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

	
	
	
/turf/unsimulated/floor/snow/asphalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"
	real_snow_tile = FALSE
	name = "asphalt"
	desc = "Specially treated Centcomm asphalt, designed to disintegrate all snow that touches it."	
	
/turf/unsimulated/floor/snow/permafrost
	icon_state = "permafrost_full"
	real_snow_tile = FALSE
	name = "permafrost"
	desc = "Soil that never unfreezes."
	
/turf/unsimulated/floor/noblizz_permafrost
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "permafrost_full"
	name = "permafrost"
	desc = "Soil that never unfreezes."
	gender = PLURAL
	temperature = T_ARCTIC
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	can_border_transition = 1
	plane = PLATING_PLANE
	
	
	
	
	
	
	
	
	
	
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