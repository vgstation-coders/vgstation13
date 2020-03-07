#define GEYSER_TEMP 40
#define GEYSER_POWER 40000
#define GEYSER_HEAT_RANGE 3
#define GEYSER_WARM_RATE 25

/obj/structure/geyser
	name = "thermal geyser"
	desc = "A geyser is a type of spring that is caused by the upward force of heat attemping to escape outward from a mineral body."
	density = 1
	anchored = 1
	icon = 'icons/misc/beach.dmi'
	icon_state = "geyser"

	var/stability = "usual"

	var/heat_range = 3
	var/warm_rate = 25
	var/smoke_probability = 40
	var/preparing_smoke = 0

/obj/structure/geyser/New()
	..()
	if(istype(loc,/turf/simulated/floor/beach) || istype(loc,/turf/unsimulated/beach))
		icon_state = "geyser-sandy"

/obj/structure/geyser/process()
	if (preparing_smoke)
		return // We're about to exhaust smoke
	if(prob(smoke_probability))
		puff_smoke()
	var/turf/T = loc
	if(!istype(T))
		return //Not on a turf
	//If we're on a simulated turf, just heat the air.
	if(istype(T,/turf/simulated))
		var/turf/simulated/L
		var/datum/gas_mixture/env = L.return_air()
		if(env.temperature != GEYSER_TEMP + T0C)
			var/datum/gas_mixture/removed = env.remove_volume(0.25 * CELL_VOLUME)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
					if(removed.temperature < GEYSER_TEMP + T0C)
						removed.temperature = min(removed.temperature + GEYSER_POWER/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
					else
						removed.temperature = max(removed.temperature - GEYSER_POWER/heat_capacity, TCMB)
	//Not simulated? Heat things near us directly.
	else
		for(var/mob/living/M in view(src, heat_range))
			var/adj_temp = 1.5*GEYSER_TEMP/(get_dist(src,M)+1) + T0C
			//Standing on top: heats to 60C
			//1 range: to 30C
			//2 range: to 20C
			//3 range: to 15C
			//Ignore this if they have heat protection above this grade
			if(!(M.get_thermal_protection(M.get_heat_protection_flags(adj_temp))))
				M.bodytemperature = min(adj_temp, M.bodytemperature + (warm_rate * TEMPERATURE_DAMAGE_COEFFICIENT))

/obj/structure/geyser/proc/puff_smoke()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(2, 0, get_turf(src)) //Make 2 drifting clouds of smoke, direction
	smoke.time_to_live = 2 SECONDS //unusually short smoke
	smoke.start()

/obj/structure/geyser/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/device/analyzer))
		to_chat(user, "<span class='notice'>Geyser analysis: [stability]. Thermal power: [warm_rate]K.</span>")
	if (preparing_smoke)
		to_chat(user, "<span class='warning'>Danger. Smoke exhaustion iminent.</span>")
	return ..()

// -- Much bigger puffs of smoke
/obj/structure/geyser/unstable
	heat_range = 4
	warm_rate = 30
	smoke_probability = 5
	stability = "unstable"

/obj/structure/geyser/unstable/puff_smoke()
	preparing_smoke = 1
	..()
	spawn (15 SECONDS)
		var/datum/effect/effect/system/smoke_spread/heat/smoke = new /datum/effect/effect/system/smoke_spread/heat()
		smoke.set_up(4, 0, get_turf(src))
		smoke.time_to_live = 8 SECONDS
		smoke.start()
		preparing_smoke = 0

// -- Termal vent
/obj/structure/geyser/vent
	heat_range = 2
	warm_rate = 15
	smoke_probability = 0
	stability = "very stable"
