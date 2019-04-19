/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or plasma being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	anchored = 1
	amount = 1 //Basically moles.

	volatility = 0.02

	basecolor = "#6D5757"

	persistence_type = null //Yikes!

/obj/effect/decal/cleanable/liquid_fuel/New(newLoc,amt=1)
	src.amount = amt

	//Be absorbed by any other liquid fuel in the tile.
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in newLoc)
		if(other != src)
			other.amount += src.amount
			spawn other.Spread()
			returnToPool(src)
			return

	Spread()
	. = ..()

/obj/effect/decal/cleanable/liquid_fuel/getFireFuel()
	return amount

/obj/effect/decal/cleanable/liquid_fuel/burnFireFuel(var/used_fuel_ratio, var/used_reactants_ratio)
	amount -= (amount * used_fuel_ratio * used_reactants_ratio) * 5 // liquid fuel burns 5 times as quick
	if(amount < 0.1)
		returnToPool(src)

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
					getFromPool(/obj/effect/decal/cleanable/liquid_fuel, target, amount*0.25)
					amount *= 0.75

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel
		icon_state = "mustard"
		anchored = 1 //Why the fuck was this set to 0
		volatility = 0.01

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/New(newLoc, amt = 1, d = 0)
	dir = d //Setting this direction means you won't get torched by your own flamethrower.
	var/turf/T = newLoc
	if(istype(T))
		T.hotspot_expose(70000, 50000, 1, surfaces=1)
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
			var/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/FF = getFromPool(/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel, O, amount*0.25, d)

			if(amount + FF.amount > 0.4) //if we make a patch with not enough fuel, we balance it out properly to ensure even burn
				if(amount < 0.2 || FF.amount < 0.2) //one of these is too small, so let's average
					var/balanced = (amount + FF.amount) / 2
					amount = balanced
					FF.amount = balanced
			else
				returnToPool(FF) //otherwise, we can't actually make a new patch and we bin the idea completely
				return

			spawn(1)
				O.hotspot_expose(7000, 500, 1, 1)
				//O.hotspot_expose((T20C*2) + 380, 500, surfaces = 1)

			if(FF)
				transferred_amount += FF.amount
	amount = max(amount - transferred_amount, 0)
	if(amount == 0)
		returnToPool(src)
