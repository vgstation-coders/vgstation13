/mob
	var/list/current_sound_zones = list()

/datum/sound_zone
	var/datum/sound_emitter/sound_emitter // the emitter that this zone covers
	var/minX
	var/minY
	var/maxX
	var/maxY
	var/last_hash

/datum/sound_zone/New(var/datum/sound_emitter/E)
	if (!E.source)
		CRASH("Attempted to create a sound zone for a sound_emitter with no source")
	sound_emitter = E
	var/turf/T = get_turf(E.source)
	var/r = E.range
	minX = T.x - r
	minY = T.y - r
	maxX = T.x + r
	maxY = T.y + r
	sound_zone_manager.add_sound_zone(src)

/datum/sound_zone/proc/contains(mob/M)
	if (!M)
		return
	var/turf/T = get_turf(M)
	if (!T)
		return
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y < maxY )

/datum/sound_zone/proc/on_enter(mob/player/P)
	sound_emitter.add_hearer(P)
	P.current_sound_zones |= src

/datum/sound_zone/proc/on_leave(mob/player/P)
	sound_emitter.remove_hearer(P)
	P.current_sound_zones -= src