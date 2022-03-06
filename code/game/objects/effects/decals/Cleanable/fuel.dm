/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or plasma being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	anchored = 1
	amount = 1 //Basically moles.

	reagent = FUEL

	volatility = 0.02

	basecolor = "#6D5757"

	persistence_type = null //Yikes!

	fake_DNA = "fuel splatters"

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

/obj/effect/decal/cleanable/liquid_fuel/getFireFuel()
	return amount

/obj/effect/decal/cleanable/liquid_fuel/burnFireFuel(var/used_fuel_ratio, var/used_reactants_ratio)
	amount -= (amount * used_fuel_ratio * used_reactants_ratio) * 5 // liquid fuel burns 5 times as quick
	if(amount < 0.1)
		qdel(src)

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

