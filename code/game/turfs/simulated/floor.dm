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

	plane = FLOOR_PLANE

	holomap_draw_override = HOLOMAP_DRAW_PATH


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
					src.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
					if(prob(33))
						var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
						M.amount = 1
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
	return

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/add_dust()
	if(!(locate(/obj/effect/decal/cleanable/dirt) in contents))
		new /obj/effect/decal/cleanable/dirt(src)

/turf/simulated/floor/update_icon()
	if(lava)
		return
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
		if(T.on)
			set_light(5)
			floor_overlay = T.get_turf_image()
			icon_state = "light_base"
			overlays += floor_overlay
			light_color = floor_overlay.color
		else
			kill_light()
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

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/simulated/floor/is_metal_floor()
	if(istype(floor_tile,/obj/item/stack/tile/metal))
		return 1
	else
		return 0

/turf/simulated/floor/is_light_floor()
	if(istype(floor_tile,/obj/item/stack/tile/light))
		return 1
	else
		return 0

/turf/simulated/floor/is_grass_floor()
	if(istype(floor_tile,/obj/item/stack/tile/grass))
		return 1
	else
		return 0

/turf/simulated/floor/is_wood_floor()
	if(istype(floor_tile,/obj/item/stack/tile/wood))
		return 1
	else
		return 0

/turf/simulated/floor/is_carpet_floor()
	if(istype(floor_tile,/obj/item/stack/tile/carpet))
		return 1
	else
		return 0

/turf/simulated/floor/is_arcade_floor()
	if(istype(floor_tile,/obj/item/stack/tile/arcade))
		return 1
	return 0

/turf/simulated/floor/is_slime_floor()
	if(istype(floor_tile,/obj/item/stack/tile/slime))
		return 1
	else
		return 0

/turf/simulated/floor/is_plating()
	if(!floor_tile)
		return 1
	return 0

/turf/simulated/floor/is_mineral_floor()
	if(istype(floor_tile,/obj/item/stack/tile/mineral))
		return 1
	return 0

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
			make_plating()
		return //slime burns up or completely loses form
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

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine))
		return
	if(istype(src,/turf/unsimulated/floor/asteroid))
		return//Asteroid tiles don't burn
	if(is_metal_floor())
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		burnt = 1
	else if(is_metal_floor())
		src.icon_state = "floorscorched[pick(1,2)]"
		burnt = 1
	else if(is_plating())
		src.icon_state = "panelscorched"
		burnt = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		burnt = 1
	else if((is_carpet_floor()) || (is_arcade_floor()))
		src.icon_state = "carpet-broken"
		burnt = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		burnt = 1
	else if(is_mineral_floor())
		burnt = 1

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
	kill_light()
	floor_tile = null
	intact = 0
	broken = 0
	burnt = 0
	//No longer phazon, not a teleport destination
	if(material=="phazon")
		phazontiles -= src
	material = "metal"
	plane = PLATING_PLANE

	update_icon()
	levelupdate()

//This proc will make the turf a plasteel floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_metal_floor(var/obj/item/stack/tile/metal/T = null)
	if(floor_tile)
		qdel(floor_tile)
	floor_tile = null
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
	update_icon()
	levelupdate()
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
//This proc will make the turf a light floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_light_floor(var/obj/item/stack/tile/light/T = null)
	broken = 0
	burnt = 0
	intact = 1
	plane = TURF_PLANE
	if(floor_tile)
		qdel(floor_tile)
	floor_tile = null
	if(T)
		if(istype(T,/obj/item/stack/tile/light))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new /obj/item/stack/tile/light(null)

	update_icon()
	levelupdate()

//This proc will make a turf into a grass patch. Fun eh? Insert the grass tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_grass_floor(var/obj/item/stack/tile/grass/T = null)
	broken = 0
	burnt = 0
	intact = 1
	plane = TURF_PLANE
	if(floor_tile)
		qdel(floor_tile)
	floor_tile = null
	if(T)
		if(istype(T,/obj/item/stack/tile/grass))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new /obj/item/stack/tile/wood(null)
	update_icon()
	levelupdate()

//This proc will make a turf into a wood floor. Fun eh? Insert the wood tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_wood_floor(var/obj/item/stack/tile/wood/T = null)
	broken = 0
	burnt = 0
	intact = 1
	plane = TURF_PLANE
	if(floor_tile)
		qdel(floor_tile)
	floor_tile = null
	if(T)
		if(istype(T,/obj/item/stack/tile/wood))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new /obj/item/stack/tile/wood(null)
	update_icon()
	levelupdate()

//This proc will make a turf into a carpet floor. Fun eh? Insert the carpet tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_carpet_floor(var/obj/item/stack/tile/carpet/T = null)
	broken = 0
	burnt = 0
	intact = 1
	plane = TURF_PLANE
	if(floor_tile)
		qdel(floor_tile)
	floor_tile = null
	if(T)
		if(istype(T,/obj/item/stack/tile/carpet))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new /obj/item/stack/tile/carpet(null)

	update_icon()
	levelupdate()


/turf/simulated/floor/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(75))
			if(floor_tile && !broken && !burnt)
				floor_tile.forceMove(src)
				floor_tile = null
			make_plating()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			if(floor_tile && !broken && !burnt)
				floor_tile.forceMove(src)
				floor_tile = null
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
				floor_tile.forceMove(src)
				floor_tile = null
			else
				//No longer phazon, not a teleport destination
				if(material=="phazon")
					phazontiles -= src
				to_chat(user, "<span class='notice'>You remove the [floor_tile.name].</span>")
				floor_tile.forceMove(src)
				floor_tile = null

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
		else
			to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return
	else if(istype(C, /obj/item/stack/tile))
		if(istype(C, /obj/item/stack/tile/metal/plasteel))
			to_chat(user, "<span class='warning'>This floor needs something to anchor this kind of tile to, add some rods first.</span>")
		else if(is_plating())
			if(!broken && !burnt)
				var/obj/item/stack/tile/T = C
				if(T.use(1))
					make_metal_floor(T)
			else
				to_chat(user, "<span class='warning'>This section is too damaged to support a tile. Use a welder to fix the damage.</span>")
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
						kill_light()
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
