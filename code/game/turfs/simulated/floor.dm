//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken", "carpet",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15","arcadecarpet")

var/list/plating_icons = list("plating","platingdmg1","platingdmg2","platingdmg3","asteroid","asteroid_dug",
				"ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5", "ironsand6", "ironsand7",
				"ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")
var/list/wood_icons = list("wood","wood-broken")
var/image/list/w_overlays = list("wet" = image('icons/effects/water.dmi',icon_state = "wet_floor"))
/turf/simulated/floor

	//Note to coders, the 'intact' var can no longer be used to determine if the floor is a plating or not.
	//Use the is_plating(), is_plasteel_floor() and is_light_floor() procs instead. --Errorage
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
	var/mineral = "metal"
	var/obj/item/stack/tile/floor_tile = new/obj/item/stack/tile/plasteel

	melt_temperature = 1643.15 // Melting point of steel

/turf/simulated/floor/New()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state

/turf/simulated/floor/ashify()
	burn_tile()

/turf/simulated/floor/melt() // Melting is different.
	burn_tile()

//turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
//	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if (!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33))
						var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
						M.amount = 1
				if(2)
					src.ChangeTurf(/turf/space)
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
					if(prob(33))
						var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
						M.amount = 1
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
	return

/turf/simulated/floor/blob_act()
	return

turf/simulated/floor/proc/update_icon()
	if(lava)
		return
	else if(is_plasteel_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
	else if(is_plating())
		if(!broken && !burnt)
			icon_state = icon_plating //Because asteroids are 'platings' too.
	else if(is_light_floor())
		var/obj/item/stack/tile/light/T = floor_tile
		if(T.on)
			switch(T.state)
				if(0)
					icon_state = "light_on"
					SetLuminosity(5)
				if(1)
					var/num = pick("1","2","3","4")
					icon_state = "light_on_flicker[num]"
					SetLuminosity(5)
				if(2)
					icon_state = "light_on_broken"
					SetLuminosity(5)
				if(3)
					icon_state = "light_off"
					SetLuminosity(0)
		else
			SetLuminosity(0)
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

	else if(is_wood_floor())
		if(!broken && !burnt)
			if( !(icon_state in wood_icons) )
				icon_state = "wood"
				//world << "[icon_state]y's got [icon_state]"
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
	..()

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/simulated/floor/is_plasteel_floor()
	if(istype(floor_tile,/obj/item/stack/tile/plasteel))
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

/turf/simulated/floor/is_catwalk()
	return 0

/turf/simulated/floor/is_plating()
	if(!floor_tile && !is_catwalk())
		return 1
	return 0

/turf/simulated/floor/proc/break_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(broken) return
	if(is_plasteel_floor())
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
	else if(is_carpet_floor())
		src.icon_state = "carpet-broken"
		broken = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(istype(src,/turf/unsimulated/floor/asteroid)) return//Asteroid tiles don't burn
	if(is_plasteel_floor())
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		burnt = 1
	else if(is_plasteel_floor())
		src.icon_state = "floorscorched[pick(1,2)]"
		burnt = 1
	else if(is_plating())
		src.icon_state = "panelscorched"
		burnt = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		burnt = 1
	else if(is_carpet_floor())
		src.icon_state = "carpet-broken"
		burnt = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		burnt = 1

//This proc will delete the floor_tile and the update_iocn() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding.
/turf/simulated/floor/proc/make_plating()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(is_catwalk()) return

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

	if(!floor_tile) return
	qdel(floor_tile)
	icon_plating = "plating"
	SetLuminosity(0)
	floor_tile = null
	intact = 0
	broken = 0
	burnt = 0

	update_icon()
	levelupdate()

//This proc will make the turf a plasteel floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_plasteel_floor(var/obj/item/stack/tile/plasteel/T = null)
	broken = 0
	burnt = 0
	intact = 1
	SetLuminosity(0)
	if(T)
		if(istype(T,/obj/item/stack/tile/plasteel))
			floor_tile = T
			if (icon_regular_floor)
				icon_state = icon_regular_floor
			else
				icon_state = "floor"
				icon_regular_floor = icon_state
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/plasteel
	icon_state = "floor"
	icon_regular_floor = icon_state

	update_icon()
	levelupdate()

//This proc will make the turf a light floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_light_floor(var/obj/item/stack/tile/light/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/light))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/light

	update_icon()
	levelupdate()

//This proc will make a turf into a grass patch. Fun eh? Insert the grass tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_grass_floor(var/obj/item/stack/tile/grass/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/grass))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/grass

	update_icon()
	levelupdate()

//This proc will make a turf into a wood floor. Fun eh? Insert the wood tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_wood_floor(var/obj/item/stack/tile/wood/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/wood))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/wood

	update_icon()
	levelupdate()

//This proc will make a turf into a carpet floor. Fun eh? Insert the carpet tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_carpet_floor(var/obj/item/stack/tile/carpet/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/carpet))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/carpet

	update_icon()
	levelupdate()

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)

	if(!C || !user)
		return 0

	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(is_light_floor())
			var/obj/item/stack/tile/light/T = floor_tile
			if(T.state)
				user.drop_item(C)
				del(C)
				T.state = C //fixing it by bashing it with a light bulb, fun eh?
				update_icon()
				user << "<span class='notice'>You replace \the [C].</span>"
			else
				user << "<span class='notice'>\The [C] seems fine, no need to replace it.</span>"

	if(istype(C, /obj/item/weapon/crowbar) && (!(is_plating())))
		if(broken || burnt)
			user << "<span class='warning'>You remove the broken plating.</span>"
		else
			if(is_wood_floor())
				user << "<span class='warning'>You forcefully pry off the planks, destroying them in the process.</span>"
			else
				user << "<span class='notice'>You remove the [floor_tile.name].</span>"
				new floor_tile.type(src)

		make_plating()
		// Can't play sounds from areas. - N3X
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)

		return

	if(istype(C, /obj/item/weapon/screwdriver))
		if(is_wood_floor())
			if(broken || burnt)
				return
			else
				if(is_wood_floor())
					user << "<span class='notice'>You unscrew the planks.</span>"
					new floor_tile.type(src)

			make_plating()
			playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
		if(is_catwalk())
			if(broken) return
			ReplaceWithLattice()
			user << "<span class='notice'>You begin dismantling the catwalk.</span>"
			playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
		return

	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (is_plating())
			if (R.amount >= 2)
				user << "<span class='notice'>Reinforcing the floor...</span>"
				if(do_after(user, 30) && R && R.amount >= 2 && is_plating())
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					return
			else
				user << "<span class='warning'>You need more rods.</span>"
		else if (is_catwalk())
			user << "<span class='warning'>The entire thing is 100% rods already, it doesn't need any more.</span>"
		else
			user << "<span class='warning'>You must remove the plating first.</span>"
		return

	if(istype(C, /obj/item/stack/tile))
		if (is_catwalk())
			user << "<span class='warning'>The catwalk is too primitive to support tiling.</span>"
		if(is_plating())
			if(!broken && !burnt)
				var/obj/item/stack/tile/T = C
				if(T.use(1))
					floor_tile = new T.type
					intact = 1
					if(istype(T,/obj/item/stack/tile/light))
						var/obj/item/stack/tile/light/L = T
						var/obj/item/stack/tile/light/F = floor_tile
						F.state = L.state
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
			else
				user << "<span class='warning'>This section is too damaged to support a tile. Use a welder to fix the damage.</span>"


	if(istype(C, /obj/item/weapon/cable_coil))
		if(is_plating() || is_catwalk())
			var/obj/item/weapon/cable_coil/coil = C
			coil.turf_place(src, user)
		else
			user << "<span class='warning'>You must remove the plating first.</span>"

	if(istype(C, /obj/item/weapon/pickaxe/shovel))
		if(is_grass_floor())
			new /obj/item/weapon/ore/glass(src)
			new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
			user << "<span class='notice'>You shovel the grass.</span>"
			make_plating()
		else
			user << "<span class='warning'>You cannot shovel this.</span>"

	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = C
		if(welder.isOn() && (is_plating()))
			if(broken || burnt)
				if(welder.remove_fuel(0,user))
					user << "<span class='warning'>You fix some dents on the broken plating.</span>"
					playsound(src, 'sound/items/Welder.ogg', 80, 1)
					icon_state = "plating"
					burnt = 0
					broken = 0
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"

/turf/simulated/proc/wet(delay = 800)
	if(wet >= 1) return
	wet = 1
	if(wet_overlay)
		overlays -= wet_overlay
		wet_overlay = null
	wet_overlay = w_overlays["wet"]
	overlays += wet_overlay
	spawn() dry(delay)

/turf/simulated/proc/dry(delay = 800)
	if(drying || wet >= 2)
		return
	drying = 1
	spawn(delay)
		if (!istype(src)) return
		if(wet >= 2) return
		wet = 0
		drying = 0
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null

/turf/simulated/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return
