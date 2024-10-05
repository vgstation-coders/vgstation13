//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7", "carpet",
				"carpetcorner", "carpetside", "carpet", "arcade", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15","engine")

var/list/plating_icons = list("plating","platingdmg1","platingdmg2","platingdmg3","asteroid","asteroid_dug",
				"ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5", "ironsand6", "ironsand7",
				"ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")
var/list/wood_icons = list("wood","wood-broken")

//For phazon tile teleportation
var/global/list/turf/simulated/floor/phazontiles = list()

/turf/simulated/floor

	//Note to coders, the 'intact' var can no longer be used to determine if the floor is a plating or not.
	//Use the is_plating(), is_metal_floor() and is_light_floor() procs instead. --Errorage
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	var/lava = 0
	var/broken = 0
	var/burnt = 0
	var/material = "metal"
	var/spam_flag = 0 //For certain interactions, like bananium floors honking when stepped on
	var/enter_sound = "clownstep"
	var/attack_sound = 'sound/items/bikehorn.ogg'
	var/obj/item/stack/tile/floor_tile
	var/image/floor_overlay

	melt_temperature = 1643.15 // Melting point of steel
	thermal_mass = 1

	plane = TURF_PLANE

	holomap_draw_override = HOLOMAP_DRAW_PATH

	var/datum/paint_overlay/plating_paint = null

	//plated catwalk vars
	var/hatch_installed = FALSE
	var/hatch_open = FALSE

/turf/simulated/floor/New()
	create_floor_tile()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state

/turf/simulated/floor/proc/create_floor_tile()
	if(!floor_tile)
		floor_tile = new /obj/item/stack/tile/metal(null)
		floor_tile.amount = 1

/turf/simulated/floor/Destroy()
	//No longer phazon, not a teleport destination
	if(material=="phazon")
		phazontiles -= src
	..()

/turf/simulated/floor/ashify()
	burn_tile()

/turf/simulated/floor/melt() // Melting is different.
	burn_tile()

//turf/simulated/floor/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
//	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if (!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ChangeTurf(get_underlying_turf())
		if(2.0)
			switch(pick(1,75;2,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33))
						var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
						M.amount = 1
				if(2)
					src.ChangeTurf(get_underlying_turf())
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(500,FULL_FLAME,1)
					if(prob(33))
						var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
						M.amount = 1
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(500,FULL_FLAME,1)
	return

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/add_dust()
	if(!(locate(/obj/effect/decal/cleanable/dirt) in contents))
		new /obj/effect/decal/cleanable/dirt(src)

/turf/simulated/floor/update_icon()
	if(lava)
		return
	else if(is_plated_catwalk())
		icon = 'icons/turf/catwalks.dmi'
		plane = TURF_PLANE
		layer = PAINT_LAYER
		relativewall()
		relativewall_neighbours()
	else if(is_metal_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
	else if(is_plating())
		if(!broken && !burnt)
			icon_state = icon_plating //Because asteroids are 'platings' too.
	else if(is_slime_floor())
		icon_state = "tile-slime"
	else if(is_light_floor())
		var/obj/item/stack/tile/light/T = floor_tile
		overlays -= floor_overlay //Removes overlay without removing other overlays. Replaces it a few lines down if on.
		advanced_graffiti_overlay = null
		overlays -= advanced_graffiti_overlay
		qdel(advanced_graffiti)
		if(T.on)
			set_light(5)
			floor_overlay = T.get_turf_image()
			icon_state = "light_base"
			overlays += floor_overlay
			light_color = floor_overlay.color
		else
			set_light(0)
			icon_state = "light_off"
	else if(is_grass_floor())
		if(!broken && !burnt)
			if(!(icon_state in list("grass1","grass2","grass3","grass4")))
				icon_state = "grass[pick("1","2","3","4")]"
	else if(is_carpet_floor())
		if(!broken && !burnt)
			var/connectdir = 0
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					if(FF.is_carpet_floor())
						connectdir |= direction

			//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
			var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

			//Northeast
			if(connectdir & NORTH && connectdir & EAST)
				if(istype(get_step(src,NORTHEAST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,NORTHEAST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 1

			//Southeast
			if(connectdir & SOUTH && connectdir & EAST)
				if(istype(get_step(src,SOUTHEAST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,SOUTHEAST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 2

			//Northwest
			if(connectdir & NORTH && connectdir & WEST)
				if(istype(get_step(src,NORTHWEST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,NORTHWEST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 4

			//Southwest
			if(connectdir & SOUTH && connectdir & WEST)
				if(istype(get_step(src,SOUTHWEST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,SOUTHWEST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 8

			icon_state = "carpet[connectdir]-[diagonalconnect]"

	else if(is_arcade_floor())
		if(!broken && !burnt)
			icon_state = "arcade"
	else if(is_wood_floor())
		if(!broken && !burnt)
			if( !(icon_state in wood_icons) )
				icon_state = "wood"
//				to_chat(world, "[icon_state]y's got [icon_state]")
	else if(is_mineral_floor())
		if(!broken && !burnt)
			icon_state = floor_tile.material
	/*spawn(1)
		if(istype(src,/turf/simulated/floor)) //Was throwing runtime errors due to a chance of it changing to space halfway through.
			if(air)
				update_visuals(air)*/
	update_paint_overlay()

/turf/simulated/floor/return_siding_icon_state()
	..()
	if(is_grass_floor())
		var/dir_sum = 0
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(!(T.is_grass_floor()))
				dir_sum += direction
		if(dir_sum)
			return "wood_siding[dir_sum]"
		else
			return 0


/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_animal(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user as mob)
	if (is_light_floor())
		var/obj/item/stack/tile/light/T = floor_tile
		T.on = !T.on
		update_icon()

	switch(material)
		if("bananium")
			if(!spam_flag)
				spam_flag = 1
				playsound(src, attack_sound, 50, 1)
				spawn(20)
					spam_flag = 0
		//Phazon tiles teleport to another random one in the world when clicked
		if("phazon")
			if(!spam_flag)
				spam_flag = 1
				var/turf/simulated/floor/destination = pick(phazontiles)
				do_teleport(user, destination)
				spawn(20)
					spam_flag = 0
	..()

// -- Advanced painting stuff...
/turf/simulated/floor/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/toy/crayon))
		if (advanced_graffiti)
			var/datum/painting_utensil/p = new(user, W)
			advanced_graffiti.interact(user, p)

/turf/simulated/Topic(href, href_list)
	if (..())
		return
	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (advanced_graffiti?.Topic(href, href_list))
		render_advanced_graffiti(usr)

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/simulated/floor/is_metal_floor()
	return istype(floor_tile,/obj/item/stack/tile/metal)

/turf/simulated/floor/is_light_floor()
	return istype(floor_tile,/obj/item/stack/tile/light)

/turf/simulated/floor/is_grass_floor()
	return istype(floor_tile,/obj/item/stack/tile/grass)

/turf/simulated/floor/is_wood_floor()
	return istype(floor_tile,/obj/item/stack/tile/wood)

/turf/simulated/floor/is_carpet_floor()
	return istype(floor_tile,/obj/item/stack/tile/carpet)

/turf/simulated/floor/is_arcade_floor()
	return istype(floor_tile,/obj/item/stack/tile/arcade)

/turf/simulated/floor/is_slime_floor()
	return istype(floor_tile,/obj/item/stack/tile/slime)

/turf/simulated/floor/is_plating()
	return !floor_tile

/turf/simulated/floor/is_plated_catwalk()
	return istype(floor_tile,/obj/item/stack/tile/plated_catwalk)

/turf/simulated/floor/is_mineral_floor()
	return istype(floor_tile,/obj/item/stack/tile/mineral)

/turf/simulated/floor/proc/break_tile()
	if(istype(src,/turf/simulated/floor/engine))
		return
	if(broken)
		return
	if(is_metal_floor())
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else if(is_light_floor())
		src.icon_state = "light_broken"
		broken = 1
	else if(is_plating())
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		broken = 1
	else if((is_carpet_floor()) || (is_arcade_floor()))
		src.icon_state = "carpet-broken"
		broken = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		broken = 1
	else if(is_slime_floor())
		spawn(rand(2,10))
			make_plating()//slime burns up or completely loses form
	else if(is_mineral_floor())
		if(material=="diamond")
			return //diamond doesn't break
		if(material=="plastic")
			return //you can't break legos
		if(material=="phazon") //Phazon shatters
			spawn(rand(2,10))
				playsound(src, "shatter", 70, 1)
				make_plating()
			return

		src.icon_state = "[material]_broken"
	update_paint_overlay()

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine))
		return//Reinforced floors don't burn
	if(istype(src,/turf/unsimulated/floor/asteroid))
		return//Asteroid tiles don't burn
	if(istype(src,/turf/simulated/floor/shuttle))
		if(!(locate(/obj/effect/decal/cleanable/soot) in src))
			new /obj/effect/decal/cleanable/soot(src)
		burnt = 1
	else if(is_metal_floor())
		icon_state = "damaged[pick(1,2,3,4,5)]"
		burnt = 1
	else if(is_plating())
		icon_state = "panelscorched"
		burnt = 1
	else if(is_wood_floor())
		icon_state = "wood-broken"
		burnt = 1
	else if((is_carpet_floor()) || (is_arcade_floor()))
		icon_state = "carpet-broken"
		burnt = 1
	else if(is_grass_floor())
		icon_state = "sand[pick("1","2","3")]"
		burnt = 1
	else if(is_mineral_floor())
		burnt = 1
	update_paint_overlay()
	extinguish()

//This proc will delete the floor_tile and the update_iocn() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding.
/turf/simulated/floor/proc/make_plating()
	if(is_grass_floor())
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding get updated properly
	else if(is_carpet_floor())
		spawn(5)
			if(src)
				for(var/direction in alldirs)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

	if(floor_tile)
		qdel(floor_tile)
	icon_plating = "plating"
	set_light(0)
	floor_tile = null
	intact = 0
	broken = 0
	burnt = 0
	remove_paint_overlay()
	paint_overlay = plating_paint
	//No longer phazon, not a teleport destination
	if(material=="phazon")
		phazontiles -= src
	material = "metal"
	plane = PLATING_PLANE

	for(var/obj/item/I in contents)
		if(I.level == LEVEL_BELOW_FLOOR && !istype(I,/obj/item/projectile))
			I.hide(intact)
	update_icon()
	update_paint_overlay()
	levelupdate()

//This proc will make the turf from a floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_tiled_floor(var/obj/item/stack/tile/metal/T = null)
	if(floor_tile)
		QDEL_NULL(floor_tile)
	plating_paint = paint_overlay
	remove_paint_overlay()
	paint_overlay = T.paint_overlay
	if (paint_overlay)
		paint_overlay.my_turf = src
	T.paint_overlay = null
	if (T.stacked_paint.len > 0)
		var/datum/paint_overlay/paint = T.stacked_paint[1]
		T.stacked_paint -= paint
		T.paint_overlay = paint
	T.update_icon()
	floor_tile = new T.type(null)
	material = floor_tile.material
	//Becomes a teleport destination for other phazon tiles
	if(material=="phazon")
		phazontiles += src
	intact = 1
	plane = TURF_PLANE
	if(istype(T,/obj/item/stack/tile/light))
		var/obj/item/stack/tile/light/L = T
		var/obj/item/stack/tile/light/F = floor_tile
		F.color_r = L.color_r
		F.color_g = L.color_g
		F.color_b = L.color_b
		F.on = L.on
	if(istype(T,/obj/item/stack/tile/grass))
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding gets updated properly
	else if(istype(T,/obj/item/stack/tile/carpet))
		for(var/direction in alldirs)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding gets updated properly
	// Placement sanity
	if(!(locate(/obj/structure/table) in contents) && !(locate(/obj/structure/rack) in contents) && !(locate(/obj/structure/closet) in contents))
		for(var/obj/item/I in contents)
			// Hiding things under the tiles!
			if(I.w_class == W_CLASS_TINY && !istype(I,/obj/item/projectile))
				I.hide(intact)
	update_icon()
	update_paint_overlay()
	levelupdate()
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/simulated/floor/proc/remove_floor_tile()
	if(floor_tile)
		floor_tile.forceMove(src)
		if (paint_overlay)
			floor_tile.overlays.len = 0
			floor_tile.paint_overlay = paint_overlay.Copy()
			floor_tile.update_icon()
		floor_tile = null

/turf/simulated/floor/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(75))
			if(floor_tile && !broken && !burnt)
				remove_floor_tile()
			make_plating()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			if(floor_tile && !broken && !burnt)
				remove_floor_tile()
			make_plating()

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0

	if(iscrowbar(C) && (!(is_plating())))
		if (user.a_intent != I_HELP) //We assume the user is fighting
			to_chat(user, "<span class='notice'>You swing the crowbar in front of you.</span>")
			return
		if(broken || burnt)
			to_chat(user, "<span class='warning'>You remove the broken plating.</span>")
		else
			if(is_wood_floor())
				to_chat(user, "<span class='warning'>You forcefully pry off the planks, destroying them in the process.</span>")
			else if(is_light_floor())
				to_chat(user, "<span class='notice'>You remove the light floor.</span>")
				var/obj/item/stack/tile/light/T = floor_tile
				floor_overlay = T.get_turf_image()
				overlays -= floor_overlay // This removes the light floor overlay, but not other floor overlays.
				overlays -= advanced_graffiti_overlay
				advanced_graffiti_overlay = null
				qdel(advanced_graffiti)
				remove_floor_tile()
			else if(is_plated_catwalk())
				if(hatch_installed)
					to_chat(user, "<span class='notice'>The hatch falls apart after removing \the [src].</span>")
					new /obj/item/stack/rods(src,2)
				icon = 'icons/turf/floors.dmi'
				overlays.Cut()
			else
				//No longer phazon, not a teleport destination
				if(material=="phazon")
					phazontiles -= src
				to_chat(user, "<span class='notice'>You remove the [floor_tile.name].</span>")
				remove_floor_tile()

		make_plating()
		// Can't play sounds from areas. - N3X
		C.playtoolsound(src, 80)

		return
	else if(C.is_screwdriver(user))
		if(is_wood_floor())
			if(broken || burnt)
				return
			else
				if(is_wood_floor())
					to_chat(user, "<span class='notice'>You unscrew the planks.</span>")
					new floor_tile.type(src)

			make_plating()
			C.playtoolsound(src, 80)
		else if(is_plated_catwalk())
			toggle_hatch(C,user)
		return
	else if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (is_plating())
			if (R.amount >= 2)
				to_chat(user, "<span class='notice'>Reinforcing the floor...</span>")
				if(do_after(user, src, 30) && R && R.amount >= 2 && is_plating())
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					return
			else
				to_chat(user, "<span class='warning'>You need more rods.</span>")
		else if (is_plated_catwalk())
			install_hatch(C,user)
		else
			to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return
	else if(istype(C, /obj/item/stack/tile))
		var/obj/item/offhand = user.get_inactive_hand()
		if(istype(C, /obj/item/stack/tile/metal/plasteel))
			to_chat(user, "<span class='warning'>This floor needs something to anchor this kind of tile to, add some rods first.</span>")
		else if(is_plating())
			if(!broken && !burnt)
				var/obj/item/stack/tile/T = C
				if(T.use(1))
					make_tiled_floor(T)
			else
				to_chat(user, "<span class='warning'>This section is too damaged to support a tile. Use a welder to fix the damage.</span>")
		else if(iscrowbar(offhand))
			var/obj/item/stack/tile/T = C
			if(istype(T))
				if(T.type == floor_tile.type)
					return
				if(T.use(1))
					if(is_wood_floor())
						qdel(floor_tile)
						make_tiled_floor(T)
						return
					else
						floor_tile.forceMove(src)
						floor_tile = null
						make_tiled_floor(T)
						return
			return
		else if(istype(offhand, /obj/item) && offhand.is_screwdriver(user))
			if(is_wood_floor())
				var/obj/item/stack/tile/T = C
				if(istype(T))
					if(T.type == floor_tile.type)
						return
					if(T.use(1))
						floor_tile.forceMove(src)
						floor_tile = null
						make_tiled_floor(T)
			return
	else if(isshovel(C))
		if(is_grass_floor())
			playsound(src, 'sound/items/shovel.ogg', 50, 1)
			drop_stack(/obj/item/stack/ore/glass, src, 2) //Make some sand if you shovel grass
			to_chat(user, "<span class='notice'>You shovel the grass.</span>")
			if(prob(10))
				var/to_spawn = pick(
					/obj/item/seeds/carrotseed,
					/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
					/obj/item/seeds/potatoseed,
					/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
					/obj/item/seeds/whitebeetseed,
					/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,)
				new to_spawn(src)
				to_chat(user, "<span class='notice'>Something falls out of the grass!</span>")
			make_plating()
	else if(iswelder(C))
		var/obj/item/tool/weldingtool/welder = C
		if(welder.isOn() && (is_plating()))
			if(broken || burnt)
				if(welder.remove_fuel(1,user))
					to_chat(user, "<span class='warning'>You fix some dents on the broken plating.</span>")
					welder.playtoolsound(src, 80)
					icon_state = "plating"
					burnt = 0
					broken = 0
				else
					return

/turf/simulated/floor/Entered(var/atom/movable/AM)
	.=..()

	if(AM && istype(AM,/mob/living))
		switch(material)
			if("bananium")
				if(!spam_flag)
					spam_flag = 1
					playsound(src, enter_sound, 50, 1)
					spawn(20)
						spam_flag = 0
			if("uranium")
				if(!spam_flag)
					spam_flag = 1
					set_light(3)
					icon_state = "uranium_inactive"
					emitted_harvestable_radiation(src, 2, range = 5)
					for(var/mob/living/L in range(2,src)) //Weak radiation
						L.apply_radiation(3,RAD_EXTERNAL)
					flick("uranium_active",src)
					spawn(20)
						set_light(0)
					spawn(200)
						spam_flag = 0
						update_icon()


/turf/simulated/proc/is_wet() //Returns null if no puddle, otherwise returns the puddle
	return locate(/obj/effect/overlay/puddle) in src

/turf/simulated/proc/wet(delay = 800, slipperiness = TURF_WET_WATER)
	var/obj/effect/overlay/puddle/P = is_wet()
	if(P)
		if(slipperiness > P.wet)
			P.wet = slipperiness
			P.lifespan = max(delay, P.lifespan)
	else
		new /obj/effect/overlay/puddle(src, slipperiness, delay)

/turf/simulated/proc/dry(slipperiness = TURF_WET_WATER)
	var/obj/effect/overlay/puddle/P = is_wet()
	if(P)
		if(P.wet > slipperiness)
			return
		qdel(P)

/turf/simulated/floor/attack_construct(var/mob/user)
	if(istype(src,/turf/simulated/floor/carpet))
		return//carpets are cool
	if(istype(user,/mob/living/simple_animal/construct/builder))
		if((icon_state != "cult")&&(icon_state != "cult-narsie"))
			var/spell/aoe_turf/conjure/floor/S = locate() in user.spell_list
			S.perform(user, 0, list(src))
			return 1
	return 0

/turf/simulated/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		//No longer phazon, not a teleport destination
		if(material=="phazon")
			phazontiles -= src
		name = "engraved floor"
		icon = 'icons/turf/floors.dmi'
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1,anim_plane = OBJ_PLANE)

/turf/simulated/floor/clockworkify()
	ChangeTurf(/turf/simulated/floor/mineral/clockwork)
	turf_animation('icons/effects/effects.dmi',CLOCKWORK_GENERIC_GLOW, 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)

/turf/simulated/floor/adjust_slowdown(mob/living/L, current_slowdown)
	//Phazon floors make movement faster
	if(floor_tile)
		current_slowdown = floor_tile.adjust_slowdown(L, current_slowdown)

	return ..()

/turf/simulated/floor/levelupdate()
	if(is_plated_catwalk())
		return
	else
		..()

/turf/simulated/floor/proc/install_hatch(obj/item/stack/rods/R, mob/user)
	if(is_plated_catwalk())
		if(hatch_installed)
			to_chat(user, "<span class='warning'>\The [src] already has a hatch installed.</span>")
			return
		if (R.amount >= 2)
			to_chat(user, "<span class='notice'>You place the rods inside the catwalk frame.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
			R.use(2)
			hatch_installed = TRUE
			hatch_open = FALSE
			update_icon()

/turf/simulated/floor/proc/toggle_hatch(obj/item/C, mob/user)
	if(is_plated_catwalk())
		if(!hatch_installed)
			to_chat(user, "<span class='warning'>\The [src] is missing a maintenance hatch!</span>")
			return
		to_chat(user, "<span class='notice'>You [hatch_open ? "replace" : "remove"] the [src]'s maintenance hatch.</span>")
		C.playtoolsound(src, 80)
		hatch_open = !hatch_open
		update_icon()

/turf/simulated/floor/canSmoothWith()
	return is_plated_catwalk()

/turf/simulated/floor/relativewall()
	if(is_plated_catwalk())
		icon_state = "pcat[..()]"
		overlays.Cut()
		overlays += mutable_appearance(icon='icons/turf/floors.dmi', icon_state="plating", layer = CATWALK_LAYER, plane = ABOVE_PLATING_PLANE)
		if(!hatch_open && hatch_installed)
			overlays += mutable_appearance(icon='icons/turf/catwalks.dmi', icon_state="[icon_state]_olay", layer = PAINT_LAYER, plane = TURF_PLANE)
	else
		..()

/turf/simulated/floor/isSmoothableNeighbor(atom/A)
	if(istype(A, /turf/simulated/floor))
		var/turf/simulated/floor/F = A
		return F.is_plated_catwalk()

/turf/simulated/floor/examine(mob/user)
	..()
	if(is_plated_catwalk())
		if(hatch_installed)
			to_chat(user, "<span class='notice'>The maintenance hatch has been installed.</span>")
		else
			to_chat(user, "<span class='warning'>\The [src] is missing a maintenance hatch!</span>")
