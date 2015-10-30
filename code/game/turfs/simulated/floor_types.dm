/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "floor"



/turf/simulated/floor/plating/vox
	icon_state = "plating"
	name = "vox plating"
	//icon = 'icons/turf/shuttle-debug.dmi'
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure

	New()
		..()
		name = "plating"

/turf/simulated/floor/vox
	icon_state = "floor"
	name = "vox floor"
	//icon = 'icons/turf/shuttle-debug.dmi'
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure

	New()
		..()
		name = "floor"

/turf/simulated/floor/vox/wood
	name = "floor"
	icon_state = "wood"
	floor_tile

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

	New()
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

	New()
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

	New()
		floor_tile = getFromPool(/obj/item/stack/tile/wood,null)
		..()

/turf/simulated/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/wall/vault
	icon_state = "rockvault"

	New(location,type)
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
	if(istype(C, /obj/item/weapon/wrench))
		user << "<span class='notice'>Removing rods...</span>"
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 80, 1)
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
				src.ChangeTurf(get_base_turf(src.z))
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
	return

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/cult/attack_construct(mob/user as mob)
	return 0

/turf/simulated/floor/engine/cult/cultify()
	return

/turf/simulated/floor/engine/airless
	oxygen = 0.01
	nitrogen = 0.01

/turf/simulated/floor/engine/n20
	New()
		..()
		if(src.air)
			// EXACTLY the same code as fucking roomfillers.  If this doesn't work, something's fucked.
			var/datum/gas/sleeping_agent/trace_gas = new
			air.trace_gases += trace_gas
			trace_gas.moles = 9*4000
			air.update_values()

/turf/simulated/floor/engine/nitrogen
	name = "nitrogen floor"
	icon_state = "engine"
	oxygen=0
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	temperature = TCMB

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0

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

	New()
		..()
		name = "plating"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"


/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2
	dynamic_lighting = 1 //We dynamic lighting now

	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1
	explosion_block = 2

/turf/simulated/shuttle/wall/shuttle_rotate(angle) //delete this when autosmooth is added
	src.transform = turn(src.transform, angle)

/turf/simulated/shuttle/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!user.dexterity_check())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(istype(W,/obj/item/weapon/solder) && bullet_marks)
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		user << "<span class='notice'>You remove the bullet marks with \the [W].</span>"
		bullet_marks = 0
		icon = initial(icon)
	..()

/turf/simulated/shuttle/wall/cultify()
	ChangeTurf(/turf/simulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1)
	return

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			new/obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				new/obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				new/obj/effect/decal/cleanable/soot(src)
			return
	return

/turf/simulated/shuttle/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/shuttle/floor4/ex_act(severity)
	switch(severity)
		if(1.0)
			new/obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				new/obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				new/obj/effect/decal/cleanable/soot(src)
			return
	return

/turf/simulated/shuttle/floor4/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return

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

/turf/simulated/floor/beach/water
	name = "Water"
	icon_state = "water"

/turf/simulated/floor/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_tile

	New()
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
	New()
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

/turf/simulated/floor/carpet/arcade
	name = "Arcade Carpet"
	icon_state = "arcadecarpet"
	has_siding=0


/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/plating/snow/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

// VOX SHUTTLE SHIT
/turf/simulated/shuttle/floor/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'

/turf/simulated/shuttle/plating/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'

// HERE BEGIN THE SUBTYPES FOR MAPPING, THINGS LIKE DIFFERENT FLOOR SPRITES.

// REINFORCED FLOORING

/turf/simulated/floor/engine/mapping/delivery
	icon_state = "enginedelivery"

/turf/simulated/floor/engine/mapping/bot
	icon_state = "enginebot"

/turf/simulated/floor/engine/mapping/loading_area
	icon_state = "engineloadingarea"

/turf/simulated/floor/engine/mapping/warning
	icon_state = "enginewarn"

/turf/simulated/floor/engine/mapping/warning/corner
	icon_state = "enginewarncorner"

// PLATING

/turf/simulated/floor/plating/mapping/warning
	icon_state = "warnplate"

/turf/simulated/floor/plating/mapping/warning/corner
	icon_state = "warnplatecorner"

// BLACK

/turf/simulated/floor/mapping/black
	icon_state = "black"

/turf/simulated/floor/mapping/black/corner
	icon_state = "blackcorner"

// NEUTRAL

/turf/simulated/floor/mapping/neutral
	icon_state = "neutral"

/turf/simulated/floor/mapping/neutral/corner
	icon_state = "neutralcorner"

/turf/simulated/floor/mapping/neutral/full
	icon_state = "neutralfull"

// WHITE

/turf/simulated/floor/mapping/white
	icon_state = "white"

/turf/simulated/floor/mapping/white/hall
	icon_state = "whitehall"

/turf/simulated/floor/mapping/white/corner
	icon_state = "whitecorner"

/turf/simulated/floor/mapping/white/delivery
	icon_state = "whitedelivery"

/turf/simulated/floor/mapping/white/bot
	icon_state = "whitebot"

/turf/simulated/floor/mapping/white/warning
	icon_state = "warnwhite"

/turf/simulated/floor/mapping/white/warning/corner
	icon_state = "warnwhitecorner"

// RED

/turf/simulated/floor/mapping/red
	icon_state = "red"

/turf/simulated/floor/mapping/red/full
	icon_state = "redfull"

/turf/simulated/floor/mapping/red/corner
	icon_state = "redcorner"

// GREEN

/turf/simulated/floor/mapping/green
	icon_state = "green"

/turf/simulated/floor/mapping/green/full
	icon_state = "greenfull"

/turf/simulated/floor/mapping/green/corner
	icon_state = "greencorner"

// BLUE

/turf/simulated/floor/mapping/blue
	icon_state = "blue"

/turf/simulated/floor/mapping/blue/full
	icon_state = "bluefull"

/turf/simulated/floor/mapping/blue/corner
	icon_state = "bluecorner"

// YELLOW

/turf/simulated/floor/mapping/yellow
	icon_state = "yellow"

/turf/simulated/floor/mapping/yellow/full
	icon_state = "vfull"

/turf/simulated/floor/mapping/yellow/corner
	icon_state = "yellowcorner"

// PURPLE

/turf/simulated/floor/mapping/purple
	icon_state = "purple"

/turf/simulated/floor/mapping/purple/full
	icon_state = "purplefull"

/turf/simulated/floor/mapping/purple/corner
	icon_state = "purplecorner"

// ORANGE

/turf/simulated/floor/mapping/orange
	icon_state = "orange"

/turf/simulated/floor/mapping/red/full
	icon_state = "orangefull"

/turf/simulated/floor/mapping/red/corner
	icon_state = "orangecorner"

// BROWN

/turf/simulated/floor/mapping/brown
	icon_state = "brown"

/turf/simulated/floor/mapping/brown/full
	icon_state = "brownfull"

/turf/simulated/floor/mapping/brown/corner
	icon_state = "browncorner"

// RED AND YELLOW

/turf/simulated/floor/mapping/red_yellow
	icon_state = "redyellow"

/turf/simulated/floor/mapping/red_yellow/full
	icon_state = "redyellowfull"

// RED AND BLUE

/turf/simulated/floor/mapping/red_blue
	icon_state = "redblue"

/turf/simulated/floor/mapping/red_blue/full
	icon_state = "redbluefull"

// RED AND GREEN

/turf/simulated/floor/mapping/red_green
	icon_state = "redgreen"

/turf/simulated/floor/mapping/red_green/full
	icon_state = "redgreenfull"

// GREEN AND YELLOW

/turf/simulated/floor/mapping/green_yellow
	icon_state = "greenyellow"

/turf/simulated/floor/mapping/green_yellow/full
	icon_state = "greenyellowfull"

// GREEN AND BLUE

/turf/simulated/floor/mapping/green_blue
	icon_state = "greenblue"

/turf/simulated/floor/mapping/green_blue/full
	icon_state = "greenbluefull"

// BLUE AND YELLOW

/turf/simulated/floor/mapping/green_blue
	icon_state = "blueyellow"

/turf/simulated/floor/mapping/green_blue/full
	icon_state = "blueyellowfull"

// WHITE RED

/turf/simulated/floor/mapping/white_red
	icon_state = "whitered"

/turf/simulated/floor/mapping/white_red/full
	icon_state = "whiteredfull"

/turf/simulated/floor/mapping/white_red/corner
	icon_state = "whiteredcorner"

// WHITE GREEN

/turf/simulated/floor/mapping/white_green
	icon_state = "whitegreen"

/turf/simulated/floor/mapping/white_green/full
	icon_state = "whitegreenfull"

/turf/simulated/floor/mapping/white_green/corner
	icon_state = "whitegreencorner"

// WHITE BLUE

/turf/simulated/floor/mapping/white_blue
	icon_state = "whiteblue"

/turf/simulated/floor/mapping/white_blue/full
	icon_state = "whitebluefull"

/turf/simulated/floor/mapping/white_blue/corner
	icon_state = "whitebluecorner"

// WHITE YELLOW

/turf/simulated/floor/mapping/white_yellow
	icon_state = "whiteyellow"

/turf/simulated/floor/mapping/white_yellow/full
	icon_state = "whiteyellowfull"

/turf/simulated/floor/mapping/white_yellow/corner
	icon_state = "whiteyellowcorner"

// WHITE PURPLE

/turf/simulated/floor/mapping/white_purple
	icon_state = "whitepurple"

/turf/simulated/floor/mapping/white_purple/full
	icon_state = "whitepurplefull"

/turf/simulated/floor/mapping/white_purple/corner
	icon_state = "whitepurplecorner"

// ARRIVAL

/turf/simulated/floor/mapping/arrival
	icon_state = "arrival"

// ESCAPE

/turf/simulated/floor/mapping/escape
	icon_state = "escape"

// DARK

/turf/simulated/floor/mapping/dark
	icon_state = "dark floor stripe"

/turf/simulated/floor/mapping/dark/full
	icon_state = "dark"

/turf/simulated/floor/mapping/dark/corner
	icon_state = "dark floor corner"

// DARK RED

/turf/simulated/floor/mapping/dark_red
	icon_state = "dark red stripe"

/turf/simulated/floor/mapping/dark_red/full
	icon_state = "dark red full"

/turf/simulated/floor/mapping/dark_red/corner
	icon_state = "dark red corner"

// DARK GREEN

/turf/simulated/floor/mapping/dark_green
	icon_state = "dark green stripe"

/turf/simulated/floor/mapping/dark_green/full
	icon_state = "dark green full"

/turf/simulated/floor/mapping/dark_green/corner
	icon_state = "dark green corner"

// DARK BLUE

/turf/simulated/floor/mapping/dark_blue
	icon_state = "dark blue stripe"

/turf/simulated/floor/mapping/dark_blue/full
	icon_state = "dark blue full"

/turf/simulated/floor/mapping/dark_blue/corner
	icon_state = "dark blue corner"

// DARK PURPLE

/turf/simulated/floor/mapping/dark_purple
	icon_state = "dark purple stripe"

/turf/simulated/floor/mapping/dark_purple/full
	icon_state = "dark purple full"

/turf/simulated/floor/mapping/dark_purple/corner
	icon_state = "dark purple corner"

// DARK YELLOW

/turf/simulated/floor/mapping/dark_yellow
	icon_state = "dark yellow stripe"

/turf/simulated/floor/mapping/dark_yellow/full
	icon_state = "dark yellow full"

/turf/simulated/floor/mapping/dark_yellow/corner
	icon_state = "dark yellow corner"

// DARK YELLOW

/turf/simulated/floor/mapping/dark_orange
	icon_state = "dark orange stripe"

/turf/simulated/floor/mapping/dark_orange/full
	icon_state = "dark orange full"

/turf/simulated/floor/mapping/dark_orange/corner
	icon_state = "dark orange corner"

// DARK VAULT

/turf/simulated/floor/mapping/dark_vault
	icon_state = "dark vault stripe"

/turf/simulated/floor/mapping/dark_vault/full
	icon_state = "dark vault full"

/turf/simulated/floor/mapping/dark_vault/corner
	icon_state = "dark vault corner"

/turf/simulated/floor/mapping/dark_vault/markings
	icon_state = "dark-markings"

// MARKINGS

/turf/simulated/floor/mapping/markings/delivery
	icon_state = "delivery"

/turf/simulated/floor/mapping/markings/bot
	icon_state = "bot"

/turf/simulated/floor/mapping/markings/plaque
	icon_state = "plaque"

/turf/simulated/floor/mapping/markings/loading_area
	icon_state = "loadingarea"

// WARNING

/turf/simulated/floor/mapping/warning
	icon_state = "warning"

/turf/simulated/floor/mapping/warning/corner
	icon_state = "warningcorner"

// CHAPEL

/turf/simulated/floor/mapping/chapel
	icon_state = "chapel"

// SS13 LOGO

/turf/simulated/floor/mapping/logo
	icon_state = "L1"

/turf/simulated/floor/mapping/logo/L1
	icon_state = "L1"

/turf/simulated/floor/mapping/logo/L2
	icon_state = "L2"

/turf/simulated/floor/mapping/logo/L3
	icon_state = "L3"

/turf/simulated/floor/mapping/logo/L4
	icon_state = "L4"

/turf/simulated/floor/mapping/logo/L5
	icon_state = "L5"

/turf/simulated/floor/mapping/logo/L6
	icon_state = "L6"

/turf/simulated/floor/mapping/logo/L7
	icon_state = "L7"

/turf/simulated/floor/mapping/logo/L8
	icon_state = "L8"

/turf/simulated/floor/mapping/logo/L9
	icon_state = "L9"

/turf/simulated/floor/mapping/logo/L10
	icon_state = "L10"

/turf/simulated/floor/mapping/logo/L11
	icon_state = "L11"

/turf/simulated/floor/mapping/logo/L12
	icon_state = "L12"

/turf/simulated/floor/mapping/logo/L13
	icon_state = "L13"

/turf/simulated/floor/mapping/logo/L14
	icon_state = "L14"

/turf/simulated/floor/mapping/logo/L15
	icon_state = "L15"

/turf/simulated/floor/mapping/logo/L16
	icon_state = "L16"

/turf/simulated/floor/mapping/logo/derelict/L1
	icon_state = "derelict1"

/turf/simulated/floor/mapping/logo/derelict/L2
	icon_state = "derelict2"

/turf/simulated/floor/mapping/logo/derelict/L3
	icon_state = "derelict3"

/turf/simulated/floor/mapping/logo/derelict/L4
	icon_state = "derelict4"

/turf/simulated/floor/mapping/logo/derelict/L5
	icon_state = "derelict5"

/turf/simulated/floor/mapping/logo/derelict/L6
	icon_state = "derelict6"

/turf/simulated/floor/mapping/logo/derelict/L7
	icon_state = "derelict7"

/turf/simulated/floor/mapping/logo/derelict/L8
	icon_state = "derelict8"

/turf/simulated/floor/mapping/logo/derelict/L9
	icon_state = "derelict9"

/turf/simulated/floor/mapping/logo/derelict/L10
	icon_state = "derelict10"

/turf/simulated/floor/mapping/logo/derelict/L11
	icon_state = "derelict11"

/turf/simulated/floor/mapping/logo/derelict/L12
	icon_state = "derelict12"

/turf/simulated/floor/mapping/logo/derelict/L13
	icon_state = "derelict13"

/turf/simulated/floor/mapping/logo/derelict/L14
	icon_state = "derelict14"

/turf/simulated/floor/mapping/logo/derelict/L15
	icon_state = "derelict15"

/turf/simulated/floor/mapping/logo/derelict/L16
	icon_state = "derelict16"

// OTHER

/turf/simulated/floor/mapping/bar
	icon_state = "bar"

/turf/simulated/floor/mapping/cafeteria
	icon_state = "cafeteria"

/turf/simulated/floor/mapping/checker
	icon_state = "checker"

/turf/simulated/floor/mapping/barber
	icon_state = "barber"

/turf/simulated/floor/mapping/grimy
	icon_state = "grimy"

/turf/simulated/floor/mapping/hydro
	icon_state = "hydrofloor"

/turf/simulated/floor/mapping/showroom
	icon_state = "showroomfloor"

/turf/simulated/floor/mapping/freezer
	icon_state = "freezerfloor"

/turf/simulated/floor/mapping/bcircuit
	icon_state = "bcircuit"

/turf/simulated/floor/mapping/gcircuit
	icon_state = "gcircuit"

/turf/simulated/floor/mapping/solarpanel
	icon_state = "solarpanel"

/turf/simulated/floor/mapping/solarpanel/airless
	icon_state = "solarpanel"
	name = "airless floor"
	
	oxygen = 0.01
	nitrogen = 0.01

/turf/simulated/floor/mapping/solarpanel/airless/New()
	..()
	name = "floor"