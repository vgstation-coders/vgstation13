
/obj/effect/effect/pathogen_cloud
	name = "pathogenic cloud"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	color = "green"
	alpha = 127
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = -WORLD_ICON_SIZE
	opacity = 0
	anchored = 0
	density = 0
	var/mob/source = null
	var/list/viruses = list()
	var/lifetime = 10 SECONDS//how long until we naturally disappear, humans breath about every 8 seconds, so it has to survive at least this long to have a chance to infect
	var/turf/target = null//when created, we'll slowly move toward this turf

/obj/effect/effect/pathogen_cloud/Destroy()
	source = null
	viruses = list()
	lifetime = 3
	target = null
	..()

/obj/effect/effect/pathogen_cloud/New(var/turf/loc, var/mob/sourcemob, var/list/virus)
	..()
	if (!loc || !virus || virus.len <= 0)
		qdel(src)
		return

	source = sourcemob
	viruses = virus
	spawn (lifetime)
		returnToPool(src)

/obj/effect/effect/pathogen_cloud/core/New(var/turf/loc, var/mob/sourcemob, var/list/virus)
	..()
	var/strength = 0
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		strength += V.infectionchance
	strength = round(strength/viruses.len)
	target = pick(range(max(0,1-(strength/20)),loc))//stronger viruses can reach turfs further away.
	spawn()
		sleep (1 SECONDS)
		while (src && src.loc)
			var/oldloc = loc
			if (prob(75))
				step_towards(src,target)
			else
				step_rand(src)
			if (oldloc != loc)
				getFromPool(/obj/effect/effect/pathogen_cloud,oldloc,source,virus)
			sleep (1 SECONDS)
