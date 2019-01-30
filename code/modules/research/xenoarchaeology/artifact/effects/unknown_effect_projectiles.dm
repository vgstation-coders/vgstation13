/var/list/validartifactprojectiles = list(
	/obj/item/projectile/beam,
	/obj/item/projectile/beam/retro,
	/obj/item/projectile/beam/practice,
	/obj/item/projectile/beam/practice/stormtrooper,
	/obj/item/projectile/beam/lightlaser,
	/obj/item/projectile/beam/heavylaser,
	/obj/item/projectile/beam/xray,
	/obj/item/projectile/beam/pulse,
	/obj/item/projectile/beam/lasertag/omni,
	/obj/item/projectile/beam/bison,
	/obj/item/projectile/beam/mindflayer,
	/obj/item/projectile/energy/electrode,
	/obj/item/projectile/energy/declone,
	/obj/item/projectile/energy/bolt/large,
	/obj/item/projectile/energy/plasma/pistol,
	/obj/item/projectile/energy/plasma/MP40k,
	/obj/item/projectile/energy/rad,
	/obj/item/projectile/energy/buster,
	/obj/item/projectile/ion,
	/obj/item/projectile/temp,
	/obj/item/projectile/kinetic,
	/obj/item/projectile/forcebolt
)

/datum/artifact_effect/projectiles
	effecttype = "projectiles"
	effect = ARTIFACT_EFFECT_PULSE
	effectrange = 7
	var/projectiletype
	var/num_of_shots
	copy_for_battery = list("projectiletype", "num_of_shots")

/datum/artifact_effect/projectiles/New()
	..()
	effect_type = pick(1,3,4,6)
	chargelevelmax = rand(5, 20)
	projectiletype = pick(validartifactprojectiles)
	num_of_shots = pick(100;1, 100;2, 50;3, 25;4, 10;6)

/datum/artifact_effect/projectiles/DoEffectPulse()
	if(holder)
		var/possible_turfs = trange(effectrange, get_turf(holder)) - trange(effectrange - 1, get_turf(holder))
		for(var/i=0, i<num_of_shots, i++)
			var/turf/target = pick(possible_turfs)
			generic_projectile_fire(target, holder, projectiletype)