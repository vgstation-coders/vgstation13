

/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

/datum/reagent/thermite/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		if(istype(T, /turf/simulated/wall))
			T:thermite = 1
			T.overlays.len = 0
			T.overlays = image('icons/effects/effects.dmi',icon_state = "thermite")
	return

/datum/reagent/thermite/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
	..()
	return



/datum/reagent/plasma
	name = "Plasma"
	id = "plasma"
	description = "Plasma in its liquid form."
	reagent_state = LIQUID
	color = "#500064" // rgb: 80, 0, 100

/datum/reagent/plasma/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(holder.has_reagent("inaprovaline"))
		holder.remove_reagent("inaprovaline", 2*REM)
	M.adjustToxLoss(3*REM)
	..()
	return

/datum/reagent/plasma/reaction_obj(var/obj/O, var/volume)
	src = null
	/*if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/slime))
		var/obj/item/weapon/reagent_containers/food/snacks/egg/slime/egg = O
		if (egg.grown)
			egg.Hatch()*/
	if((!O) || (!volume))	return 0
	var/turf/the_turf = get_turf(O)
	if(!the_turf) return 0
	var/datum/gas_mixture/napalm = new
	var/datum/gas/volatile_fuel/fuel = new
	fuel.moles = 5
	napalm.trace_gases += fuel
	the_turf.assume_air(napalm)

/datum/reagent/plasma/reaction_turf(var/turf/T, var/volume)
	src = null
	var/datum/gas_mixture/napalm = new
	var/datum/gas/volatile_fuel/fuel = new
	fuel.moles = 5
	napalm.trace_gases += fuel
	T.assume_air(napalm)
	return



/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for welders. Flamable."
	reagent_state = LIQUID
	color = "#660000" // rgb: 102, 0, 0


/datum/reagent/fuel/reaction_obj(var/obj/O, var/volume)
	var/turf/the_turf = get_turf(O)
	if(!the_turf)
		return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
	new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)

/datum/reagent/fuel/reaction_turf(var/turf/T, var/volume)
	new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
	return

/datum/reagent/fuel/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1)
	..()
	return