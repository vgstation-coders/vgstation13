#define GEYSER_POWER 120000

/obj/structure/geyser
	name = "thermal geyser"
	desc = "A geyser is a type of spring that is caused by the upward force of heat attemping to escape outward from a mineral body."
	density = 1
	anchored = 1
	icon = 'icons/misc/beach.dmi'
	icon_state = "geyser"

	var/stability = "usual"

	var/heat_range = 3
	var/warm_rate = 6
	var/max_temperature = 60
	var/smoke_probability = 40
	var/preparing_smoke = 0
	var/busy = FALSE //used for filling in geysers

/obj/structure/geyser/New()
	..()
	if(istype(loc,/turf/simulated/floor/beach) || istype(loc,/turf/unsimulated/beach))
		icon_state = "geyser-sandy"
	processing_objects += src

/obj/structure/geyser/Destroy()
	processing_objects -= src
	..()

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
		var/turf/simulated/L = loc
		var/datum/gas_mixture/env = L.return_air()
		if(env.temperature != max_temperature + T0C)
			var/datum/gas_mixture/removed = env.remove_volume(0.25 * CELL_VOLUME)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity)
					if(removed.temperature < max_temperature + T0C)
						removed.temperature = min(removed.temperature + warm_rate*GEYSER_POWER/heat_capacity, 1000)
				env.merge(removed)
	//Not simulated? Heat things near us directly.
	else
		for(var/mob/living/M in view(heat_range,src))
			var/adj_temp = (max_temperature-((get_dist(src,M))**3)) + T0C
			//Examples given for normal geyser
			//Standing on top: heats to 60C
			//1 range: to 59C
			//2 range: to 52C
			//3 range: to 33C
			//Ignore this if they have heat protection above this grade
			if(!(M.get_thermal_protection(M.get_heat_protection_flags(adj_temp))))
				M.bodytemperature = min(adj_temp, M.bodytemperature + warm_rate)
		for(var/turf/unsimulated/floor/snow/S in circleview(src,heat_range))
			if(S.snowballs && prob(warm_rate-2-get_dist(src,S))) //vents won't melt snow, but other geysers do
				S.snowballs--

/obj/structure/geyser/proc/puff_smoke()
	var/datum/effect/system/smoke_spread/smoke = new /datum/effect/system/smoke_spread()
	smoke.set_up(2, 0, get_turf(src)) //Make 2 drifting clouds of smoke, direction
	smoke.time_to_live = 2 SECONDS //unusually short smoke
	smoke.start()

/obj/structure/geyser/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/device/analyzer))
		to_chat(user, "<span class='notice'>Geyser analysis: [stability]. Thermal power: [warm_rate]K.</span>")
		if (preparing_smoke)
			to_chat(user, "<span class='warning'>Danger. Smoke exhaustion iminent.</span>")
	if(isshovel(W) && !busy)
		busy = TRUE
		to_chat(user, "<span class='notice'>You start piling rocks into the mouth of \the [src].</span>")
		if(do_after(user,src, 8 SECONDS))
			warm_rate = max(0, warm_rate-3)
			if(!warm_rate)
				to_chat(user, "<span class='notice'>You finish sealing \the [src].</span>")
				new /obj/structure/sealedgeyser(loc)
				qdel(src)
			else
				to_chat(user, "<span class='notice'>You seal off some of the heat from the [src].</span>")
		busy = FALSE
	return ..()

/obj/structure/geyser/ex_act(severity)
	if(prob(max_temperature - (100/severity)))
		//examples: vent (50); heavy or dev: 0%; light: 17%
		//geyser (60); dev: 0%; heavy: 10%; light: 27%
		//unstable (140): dev: 40%; heavy: 90%; light: 100%
		new /obj/structure/geyser/critical(loc)
	else
		new /obj/structure/sealedgeyser(loc)
	qdel(src)

// -- Much bigger puffs of smoke
/obj/structure/geyser/unstable
	heat_range = 3
	warm_rate = 15
	smoke_probability = 5
	max_temperature = 140
	stability = "unstable"

/obj/structure/geyser/unstable/puff_smoke()
	preparing_smoke = 1
	..()
	spawn (15 SECONDS)
		var/datum/effect/system/smoke_spread/heat/smoke = new /datum/effect/system/smoke_spread/heat()
		smoke.set_up(4, 0, get_turf(src))
		smoke.time_to_live = 8 SECONDS
		smoke.start()
		preparing_smoke = 0

/obj/structure/geyser/critical
	warm_rate = 35
	max_temperature = 1800
	smoke_probability = 0
	stability = "critical"

/obj/structure/geyser/critical/New()
	..()
	overlays += image(icon = icon, icon_state = "geyser-critical")

// -- Termal vent
/obj/structure/geyser/vent
	heat_range = 2
	warm_rate = 3
	max_temperature = 50 //50, 49, 42, 33
	smoke_probability = 0
	stability = "very stable"

/obj/structure/sealedgeyser
	name = "sealed geyser"
	desc = "A once-active geyser sealed away, preventing heat from escaping."
	density = 1
	anchored = 1
	icon = 'icons/misc/beach.dmi'
	icon_state = "geyser"

/obj/structure/sealedgeyser/New()
	..()
	overlays += image(icon = icon, icon_state = "geyser-sealed")

/obj/structure/sealedgeyser/attackby(var/obj/item/W, var/mob/user)
	if(isshovel(W))
		to_chat(user, "<span class='notice'>You start leveling out the rocky surface.</span>")
		if(do_after(user,src, 4 SECONDS))
			to_chat(user, "<span class='notice'>You finish dismantling \the [src].</span>")
			qdel(src)
	else
		..()