/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/airless/New()
	..()
	name = "floor"


/turf/simulated/floor/plating/vox
	icon_state = "plating"
	name = "vox plating"
	//icon = 'icons/turf/shuttle-debug.dmi'
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure

/turf/simulated/floor/plating/vox/New()
	..()
	name = "plating"

/turf/simulated/floor/vox
	icon_state = "floor"
	name = "vox floor"
	//icon = 'icons/turf/shuttle-debug.dmi'
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure

/turf/simulated/floor/vox/New()
	..()
	name = "floor"

/turf/simulated/floor/vox/wood
	icon_state = "wood"

	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/vox/wood/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/wood(null)

/turf/simulated/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"

/turf/simulated/floor/light/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/light(null)

/turf/simulated/floor/light/New()
	var/n = name //just in case commands rename it in the ..() call
	..()
	spawn(4)
		if(src)
			update_icon()
			name = n

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"

	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/wood/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/wood(null)

/turf/simulated/floor/vault
	icon_state = "rockvault"

/turf/simulated/floor/vault/New(location,type)
	..()
	icon_state = "[type]vault"

/turf/simulated/wall/vault
	icon_state = "rockvault"

/turf/simulated/wall/vault/New(location,type)
	..()
	icon_state = "[type]vault"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	icon_plating = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	protect_infrastructure = TRUE

	soot_type = null
	melt_temperature = 0 // Doesn't melt.
	var/secured = FALSE

/turf/simulated/floor/engine/create_floor_tile()
	return

/turf/simulated/floor/engine/attackby(obj/item/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(C.is_wrench(user) && !floor_tile && !secured)
		to_chat(user, "<span class='notice'>Removing rods...</span>")
		C.playtoolsound(src, 80)
		if(do_after(user, src, 30) && istype(src, /turf/simulated/floor/engine)) // Somehow changing the turf does NOT kill the current running proc.
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor)
			var/turf/simulated/floor/F = src
			F.make_plating()
			return
	if(iscrowbar(C))
		if (user.a_intent != I_HELP) //We assume the user is fighting
			to_chat(user, "<span class='notice'>You swing the crowbar in front of you.</span>")
			return
		else
			if(floor_tile)
				if(secured)
					to_chat(user, "<span class='warning'>Unsecure the [floor_tile.name] first!</span>")
				else
					to_chat(user, "<span class='notice'>You remove the [floor_tile.name].</span>")
					floor_tile.forceMove(src)
					floor_tile = null
					make_plating()
					// Can't play sounds from areas. - N3X
					C.playtoolsound(src, 80)
	if(istype(C, /obj/item/stack/tile/metal/plasteel) && !floor_tile)
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			make_tiled_floor(T)
	if(istype(C, /obj/item/stack/bolts) && !floor_tile)
		var/obj/item/stack/bolts/B = C
		if(B.use(1))
			ChangeTurf(/turf/simulated/floor/engine/bolted)
	if(C.is_screwdriver(user) && floor_tile)
		to_chat(user, "<span class='notice'>You start [secured ? "unsecuring" : "securing"] the [floor_tile.name].</span>")
		C.playtoolsound(src, 80)
		if(do_after(user, src, 30))
			to_chat(user, "<span class='notice'>You [secured ? "unsecure" : "secure"] the [floor_tile.name] in place.</span>")
			secured = !secured
			C.playtoolsound(src, 80)
			update_icon()

/turf/simulated/floor/engine/proc/explode_layers(var/layers = 1)
	if(secured)		//plasteel tile, screwed in
		secured = FALSE
		update_icon()
		layers -= 1
		if(!layers)
			return
	if(floor_tile)	//plasteel tile, unscrewed
		qdel(floor_tile)
		floor_tile = null
		icon_state = "engine"
		update_icon()
		layers -= 1
		if(!layers)
			return
	//reinforced floor
	new /obj/item/stack/rods(src, 1)
	ChangeTurf(/turf/simulated/floor)
	var/turf/simulated/floor/F = src
	F.make_plating()
	layers -= 1

	//normal plating
	if(!layers)
		return

	var/severity = 2
	if(layers > 1)
		severity = 1
	for(var/obj/structure/cable/C in src)
		C.ex_act(severity)
	for(var/obj/machinery/atmospherics/pipe/P in src)
		P.ex_act(severity)
	for(var/obj/structure/disposalpipe/D in src)
		D.ex_act(severity)
	src.ex_act(severity)

/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1.0)
			explode_layers(pick(2,3))
		if(2.0)
			explode_layers(1)
		if(3.0)
			if(prob(10))
				explode_layers(1)

/turf/simulated/floor/engine/make_plating()
	if(floor_tile)
		floor_tile.forceMove(src)
		floor_tile = null
	intact = 0
	broken = 0
	burnt = 0
	material = "metal"

	update_icon()
	levelupdate()

/turf/simulated/floor/engine/update_icon()
	overlays.Cut()
	icon_plating = "engine" //hotfix for now
	..()
	if(floor_tile)
		if(secured)
			overlays.Add(image('icons/turf/floors.dmi', icon_state = "r_floor"))
		else
			overlays.Add(image('icons/turf/floors.dmi', icon_state = "r_floor_unsec"))

/turf/simulated/floor/engine/bolted
	name = "bolted floor"
	desc = "This floor has jutting bolts that would make crawling across it impossible."
	icon_state = "boltedfloor"

/turf/simulated/floor/engine/bolted/attackby(obj/item/C as obj, mob/user as mob)
	if(!user || !C)
		return
	if(!C.is_wrench(user))
		return
	if(user.loc != src)
		to_chat(user, "<span class='warning'>You must stand directly on the bolted floor to unbolt it.</span>")
		return
	C.playtoolsound(src, 80)
	if(do_after(user, src, 6 SECONDS))
		new /obj/item/stack/bolts(src)
		ChangeTurf(/turf/simulated/floor/engine)

// For mappers
/turf/simulated/floor/engine/plated
	icon_state = "floor"
	secured = TRUE

/turf/simulated/floor/engine/plated/create_floor_tile()
	if(!floor_tile)
		floor_tile = new /obj/item/stack/tile/metal/plasteel(null)
		floor_tile.amount = 1
	update_icon()

/turf/simulated/floor/engine/plated/airless
	oxygen = 0.01
	nitrogen = 0.01

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/cult/attack_construct(mob/user as mob)
	return 0

/turf/simulated/floor/engine/cult/cultify()
	return

/turf/simulated/floor/engine/cult/clockworkify()
	return

/turf/simulated/floor/engine/airless
	oxygen = 0.01
	nitrogen = 0.01

/turf/simulated/floor/engine/n20
	oxygen = 0
	nitrogen = 0
	misc_gases = list(GAS_SLEEPING = 36000)

/turf/simulated/floor/engine/nitrogen
	name = "nitrogen floor"
	icon_state = "engine"
	oxygen=0
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure


/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/engine/acoustic
	name = "acoustic panel"
	desc = "A special floor designed to muffle sound."
	icon_state = "acoustic"
	volume_mult = 0.1

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	plane = PLATING_PLANE

/turf/simulated/floor/plating/deck
	name = "deck"
	icon_state = "deck"
	icon_plating = "deck"
	desc = "Children love to play on this deck."

/turf/simulated/floor/plating/deck/New()
	..()
	icon_state = "deck"

/turf/simulated/floor/plating/deck/update_icon()
	icon_plating = "deck"
	..()
	if(!floor_tile)
		name = "deck"
		icon_state = "deck"
		desc = "Children love to play on this deck."
	else
		name = "floor"
		desc = null

/turf/simulated/floor/plating/deck/airless
	name = "airless deck"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/deck/airless/New()
	..()
	name = "deck"

/turf/simulated/floor/plating/create_floor_tile()
	return


/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/airless/New()
	..()
	name = "plating"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"

/turf/simulated/floor/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/coastline/north
	icon_state = "sandwater_north"

/turf/simulated/floor/beach/coastline/east
	icon = 'icons/misc/beach3.dmi'
	icon_state = "sandwater_east"

/turf/simulated/floor/beach/coastline/west
	icon = 'icons/misc/beach3.dmi'
	icon_state = "sandwater_west"

/turf/simulated/floor/beach/water
	name = "Water"
	icon_state = "water"

/turf/simulated/floor/beach/water/New()
	..()
	var/image/water = image("icon"='icons/misc/beach.dmi',"icon_state"="water5")
	water.plane = ABOVE_HUMAN_PLANE
	overlays += water

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"

/turf/simulated/floor/grass/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/grass(null)

/turf/simulated/floor/grass/New()
	icon_state = "grass[pick("1","2","3","4")]"
	..()
	spawn(4)
		if(src)
			update_icon()
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	var/has_siding=1

/turf/simulated/floor/carpet/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/carpet(null)

/turf/simulated/floor/carpet/New()
	if(!icon_state)
		icon_state = initial(icon_state)
	..()
	if(has_siding)
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in alldirs)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet/cultify()
	return

/turf/simulated/floor/arcade
	name = "Arcade Carpet"
	icon_state = "arcade"

/turf/simulated/floor/arcade/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/arcade(null)
	..()

/turf/simulated/floor/carpet/shag
	name = "Shag Carpet"
	icon_state = "shagcarpet-dark"
	has_siding = FALSE

/turf/simulated/floor/carpet/shag/update_icon()
	if(broken || burnt)
		icon_state = "carpet-broken"
	else if(is_plating())
		icon_state = icon_plating
	else
		icon_state = initial(icon_state)

/turf/simulated/floor/carpet/shag/create_floor_tile()
	floor_tile = new /obj/item/stack/tile/carpet/shag(null)

/turf/simulated/floor/damaged
	icon_state = "damaged1"

/turf/simulated/floor/damaged/New()
	broken = prob(71) // 5 of the icon states are "damaged" icons, 2 are burned.
	burnt  = !broken

	if(broken)
		icon_state = pick("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

	else // Burnt states.
		icon_state = pick("floorscorched1", "floorscorched2")

	. = ..()

/turf/simulated/floor/damaged/airless
	name        = "airless floor"
	oxygen      = 0.01
	nitrogen    = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/airless/damaged
	icon_state = "platingdmg1"

/turf/simulated/floor/plating/airless/damaged/New()
	broken = prob(75) // 3 of the icon states are "damaged" icons, 1 is burned.
	burnt  = !broken

	if(broken)
		icon_state = pick("platingdmg1", "platingdmg2", "platigndmg3")

	else // Burnt state.
		icon_state = "panelscorched"

	. = ..()

//syndie themed
/turf/simulated/floor/dark
	icon_state = "dark"

//Server rooms, supercooled nitrogen atmosphere
/turf/simulated/floor/server
	icon_state = "dark"
	oxygen = 0
	temperature = 90
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD

/turf/simulated/floor/server/bluegrid
	icon_state = "bcircuit"

/turf/simulated/floor/server/one_atmosphere
	nitrogen = (ONE_ATMOSPHERE*CELL_VOLUME/(90*R_IDEAL_GAS_EQUATION))

/turf/simulated/floor/server/one_atmosphere/bluegrid
	icon_state = "bcircuit"

// VOX SHUTTLE SHIT
/turf/simulated/floor/shuttle/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'

/turf/simulated/floor/shuttle/plating/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'
