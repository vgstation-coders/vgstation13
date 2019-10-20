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

/obj/structure/geyser/process()
	if(prob(40))
		var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
		smoke.set_up(2, 0, get_turf(src)) //Make 2 drifting clouds of smoke, direction
		smoke.time_to_live = 2 SECONDS //unusually short smoke
		smoke.start()
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
		for(var/mob/living/M in view(src,GEYSER_HEAT_RANGE))
			var/adj_temp = 1.5*GEYSER_TEMP/(get_dist(src,M)+1) + T0C
			//Standing on top: heats to 60C
			//1 range: to 30C
			//2 range: to 20C
			//3 range: to 15C
			//Ignore this if they have heat protection above this grade
			if(M.get_thermal_protection(M.get_heat_protection_flags(adj_temp)))
				M.bodytemperature = min(adj_temp, M.bodytemperature + (GEYSER_WARM_RATE * TEMPERATURE_DAMAGE_COEFFICIENT))