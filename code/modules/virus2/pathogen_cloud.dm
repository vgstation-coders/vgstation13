var/list/pathogen_clouds = list()

/obj/effect/pathogen_cloud
	name = "pathogenic cloud"
	icon = 'icons/effects/96x96.dmi'
	icon_state = ""
	color = "green"
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = -WORLD_ICON_SIZE
	opacity = 0
	anchored = 0
	density = 0
	invisibility = 101
	throwforce = 0
	var/mob/source = null
	var/sourceIsCarrier = TRUE
	var/list/viruses = list()
	var/lifetime = 10 SECONDS//how long until we naturally disappear, humans breath about every 8 seconds, so it has to survive at least this long to have a chance to infect
	var/turf/target = null//when created, we'll slowly move toward this turf
	var/image/pathogen
	var/core = TRUE
	var/modified = FALSE
	var/moving = TRUE

/obj/effect/pathogen_cloud/New(var/turf/loc, var/mob/sourcemob, var/list/virus, var/isCarrier = TRUE)
	..()
	if (!loc || !virus || virus.len <= 0)
		qdel(src)
		return

	sourceIsCarrier = isCarrier
	pathogen_clouds += src

	pathogen = image('icons/effects/96x96.dmi',src,"pathogen_airborne")
	pathogen.plane = HUD_PLANE
	pathogen.layer = UNDER_HUD_LAYER
	pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
	for (var/mob/L in science_goggles_wearers)
		if (L.client)
			L.client.images |= pathogen

	source = sourcemob
	viruses = virus
	spawn (lifetime)
		qdel(src)

/obj/effect/pathogen_cloud/Destroy()
	if (pathogen)
		for (var/mob/L in science_goggles_wearers)
			if (L.client)
				L.client.images -= pathogen
		pathogen = null
	pathogen_clouds -= src
	source = null
	viruses = list()
	lifetime = 3
	target = null
	..()

/obj/effect/pathogen_cloud/core/New(var/turf/loc, var/mob/sourcemob, var/list/virus)
	..()
	if (!loc || !virus || virus.len <= 0)
		return

	var/strength = 0
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		strength += V.infectionchance
	strength = round(strength/viruses.len)
	var/list/possible_turfs = list()
	for (var/turf/T in range(max(0,(strength/20)-1),loc))//stronger viruses can reach turfs further away.
		possible_turfs += T
	target = pick(possible_turfs)
	spawn()
		sleep (1 SECONDS)
		while (src && src.loc)
			if (src.loc != target)

				//If we come across other pathogenic clouds, we absorb their diseases that we don't have, then delete those clouds
				//This should prevent mobs breathing in hundreds of clouds at once
				for (var/obj/effect/pathogen_cloud/other_C in src.loc)
					if (!other_C.core)
						for (var/ID in other_C.viruses)
							if (!(ID in viruses))
								var/datum/disease2/disease/V = other_C.viruses[ID]
								viruses[ID] = V.getcopy()
								modified = TRUE
						qdel(other_C)

				var/obj/effect/pathogen_cloud/C = new /obj/effect/pathogen_cloud(src.loc, source, viruses, sourceIsCarrier)
				C.core = FALSE
				C.modified = modified
				C.moving = FALSE

				if (prob(75))
					step_towards(src,target)
				else
					step_rand(src)
				sleep (1 SECONDS)
			else
				for (var/obj/effect/pathogen_cloud/core/other_C in src.loc)
					if (!other_C.moving)
						for (var/ID in other_C.viruses)
							if (!(ID in viruses))
								var/datum/disease2/disease/V = other_C.viruses[ID]
								viruses[ID] = V.getcopy()
								modified = TRUE
						qdel(other_C)
				moving = FALSE
