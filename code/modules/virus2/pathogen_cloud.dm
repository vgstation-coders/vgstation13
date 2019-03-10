
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
	var/list/viruses = null
	var/lifetime = 3//how long until we naturally disappear
	var/turf/target = null//when created, we'll slowly move toward this turf

/obj/effect/effect/pathogen_cloud/New(var/turf/loc, var/mob/sourcemob, var/list/virus)
	..()
	if (!loc || !virus || virus.len <= 0)
		qdel(src)
		return

	source = sourcemob
	viruses = virus

	var/strength = 0
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		strength += V.infectionchance

	strength = round(strength/viruses.len)

	lifetime = 1 + round(strength/20)
	target = pick(orange(lifetime,loc))

	spawn()
		while (src && src.loc && lifetime > 0)
			lifetime--
			if (prob(75))
				step_towards(src,target)
			else
				step_rand(src)
			sleep (1 SECONDS)
		qdel(src)
