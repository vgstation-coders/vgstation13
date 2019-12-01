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
	floor_tile

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/vox/wood/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/wood, null)
	..()

/turf/simulated/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile

/turf/simulated/floor/light/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/light, null)
	floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
	var/n = name //just in case commands rename it in the ..() call
	..()
	spawn(4)
		if(src)
			update_icon()
			name = n

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/wood/New()
	floor_tile = getFromPool(/obj/item/stack/tile/wood,null)
	..()

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
	thermal_conductivity = 0.025
	heat_capacity = 325000

	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(iswrench(C))
		to_chat(user, "<span class='notice'>Removing rods...</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, src, 30) && istype(src, /turf/simulated/floor/engine)) // Somehow changing the turf does NOT kill the current running proc.
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor)
			var/turf/simulated/floor/F = src
			F.make_plating()
			return

/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(80))
				src.ReplaceWithLattice()
			else if(prob(50))
				src.ChangeTurf(get_underlying_turf())
			else
				var/turf/simulated/floor/F = src
				F.make_plating()
		if(2.0)
			if(prob(50))
				var/turf/simulated/floor/F = src
				F.make_plating()
			else
				return
		if(3.0)
			return

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

/turf/simulated/floor/engine/n20/New()
	..()
	if(src.air)
		air.adjust_gas(GAS_SLEEPING, 9 * 4000) //NO goddamn idea what those numbers mean, but it's what they were before

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

/turf/simulated/floor/engine/accoustic
	name = "accoustic panel"
	desc = "A special floor designed to muffle sound."
	icon_state = "accoustic"
	volume_mult = 0.1

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	plane = PLATING_PLANE

/turf/simulated/floor/plating/deck
	name = "deck"
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

/turf/simulated/floor/plating/New()
	..()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null


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
	floor_tile

/turf/simulated/floor/grass/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/grass, null)
	floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
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
	floor_tile
	var/has_siding=1

/turf/simulated/floor/carpet/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/carpet, null)
	floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
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
	floor_tile

/turf/simulated/floor/arcade/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/arcade, null)
	..()

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
/turf/simulated/shuttle/floor/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'

/turf/simulated/shuttle/plating/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'
