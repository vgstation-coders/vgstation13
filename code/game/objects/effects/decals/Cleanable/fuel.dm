/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or plasma being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	anchored = 1
	amount = 1 //Basically moles.

	reagent = FUEL

	basecolor = "#6D5757"

	persistence_type = null //Yikes!

	fake_DNA = "fuel splatters"
	stain_name = "fuel"

/obj/effect/decal/cleanable/liquid_fuel/New(newLoc,amt=1)
	src.amount = amt

	//Be absorbed by any other liquid fuel in the tile.
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in newLoc)
		if(other != src)
			other.amount += src.amount
			spawn other.Spread()
			qdel(src)
			return

	Spread()
	. = ..()

/obj/effect/decal/cleanable/liquid_fuel/proc/Spread()
	//Allows liquid fuels to sometimes flow into other tiles.
	if(amount < 0.5)
		return

	var/turf/simulated/origin = get_turf(src)
	if (!istype(origin))
		return

	for(var/d in cardinal)
		if(rand(25))
			var/turf/simulated/target = get_step(src, d)
			if (!istype(target)) // Avoid spreading to unsimulated/space/etc. turfs
				continue

			if(origin.Cross(null, target, 0, 0) && target.Cross(null, origin, 0, 0))
				if(!locate(/obj/effect/decal/cleanable/liquid_fuel) in target)
					new /obj/effect/decal/cleanable/liquid_fuel(target, amount*0.25)
					amount *= 0.75

/obj/effect/decal/cleanable/liquid_fuel/flammable_reagent_check()
	return TRUE

/obj/effect/decal/cleanable/liquid_fuel/burnLiquidFuel()
	//Setup
	var/turf/T = get_turf(src)
	if(!T)
		extinguish()
		return

	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols
	var/co2_prod = 0 //mols (some reagents consume co2 when they burn)
	var/max_temperature = 0 //K
	var/consumption_rate = 0 //units per tick

	//Check if a fire is present at the current location.
	var/in_fire = FALSE
	if(locate(/obj/effect/fire) in T)
		in_fire = TRUE

	if(amount > 0)
		var/list/fuel_stats = possible_fuels[reagent]
		max_temperature = max(max_temperature,fuel_stats["max_temperature"])
		heat_out = fuel_stats["thermal_energy_transfer"]
		consumption_rate = fuel_stats["consumption_rate"]
		oxy_used = fuel_stats["o2_cons"]
		co2_prod = -fuel_stats["co2_cons"]
		amount -= consumption_rate
	else
		qdel(src)

	//Start a fire on the tile if a burning object is present without an underlying fire effect.
	if(!in_fire)
		try_hotspot_expose(max_temperature, FULL_FLAME, 1)

	return list("heat_out"=heat_out,"oxy_used"=oxy_used,"co2_prod"=co2_prod,"max_temperature"=max_temperature)

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel
		icon_state = "mustard"
		anchored = 1 //Why the fuck was this set to 0

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/New(newLoc, amt = 1, d = 0)
	dir = d //Setting this direction means you won't get torched by your own flamethrower.
	var/turf/T = newLoc
	if(istype(T))
		try_hotspot_expose(70000, FULL_FLAME, 1)
	//. = ..()

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/Spread()
	//The spread for flamethrower fuel is much more precise, to create a wide fire pattern.
	if(amount < 0.1)
		return
	var/turf/simulated/S = loc
	if(!istype(S))
		return

	var/transferred_amount = 0
	for(var/d in list(turn(dir,90),turn(dir,-90), dir))
		var/turf/simulated/O = get_step(S,d)
		if(locate(/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel) in O)
			continue
		if(O.Cross(null, S, 0, 0) && S.Cross(null, O, 0, 0))
			var/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/FF = new /obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(O, amount*0.25, d)

			if(amount + FF.amount > 0.4) //if we make a patch with not enough fuel, we balance it out properly to ensure even burn
				if(amount < 0.2 || FF.amount < 0.2) //one of these is too small, so let's average
					var/balanced = (amount + FF.amount) / 2
					amount = balanced
					FF.amount = balanced
			else
				qdel(FF) //otherwise, we can't actually make a new patch and we bin the idea completely
				return

			spawn(1)
				try_hotspot_expose(7000, FULL_FLAME, 1)
				//O.hotspot_expose((T20C*2) + 380, 500, surfaces = 1)

			if(FF)
				transferred_amount += FF.amount
	amount = max(amount - transferred_amount, 0)
	if(amount == 0)
		qdel(src)
