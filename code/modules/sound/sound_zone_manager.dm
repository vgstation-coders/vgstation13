var/global/datum/sound_zone_manager/sound_zone_manager = new

/datum/sound_zone_manager
	var/list/buckets = list()
	var/cell_size

/datum/sound_zone_manager/New()
	..()
	buckets = list()
	cell_size = world.view

/datum/sound_zone_manager/proc/hash(x, y, z)
	return num2text(z << 42 | y << 21 | x)

/datum/sound_zone_manager/proc/get_candidate_zones(x, y, z)
	var/list/zones = list()
	for (var/dx in -1 to 1)
		for (var/dy in -1 to 1)
			var/h = hash(x + dx * cell_size, y + dy * cell_size, z)
			if (buckets[h])
				for (var/datum/sound_zone/Z in buckets[h])
					zones |= Z
	return zones

/datum/sound_zone_manager/proc/register_emitter(datum/sound_emitter/E)
	if (!E.source)
		CRASH("sound_zone_manager: Attempted to register an emitter with no source")
	var/turf/T = get_turf(E.source)
	if (!T)
		CRASH("sound_zone_manager: Failed to get turf in register_emitter")

	var/h = hash(T.x, T.y, T.z)
	var/datum/sound_zone/Z = new /datum/sound_zone(E)
	Z.last_hash = h
	if (!buckets[h])
		buckets[h] = list()
	buckets[h] |= Z

/datum/sound_zone_manager/proc/move_sound_zone(datum/sound_zone/Z, x, y, z)
	var/h = hash(x, y, z)
	if (Z.last_hash != null && Z.last_hash != h)
		var/list/old_bucket = buckets[Z.last_hash]
		if (old_bucket)
			old_bucket -= Z

	var/list/new_bucket = buckets[h]
	if (!buckets[h])
		new_bucket = buckets[h] = list()

	if (!(Z in new_bucket))
		new_bucket |= Z

	Z.last_hash = h

/datum/sound_zone_manager/proc/remove_sound_zone(datum/sound_zone/Z)
	if (Z.last_hash != null)
		var/list/bucket = buckets[Z.last_hash]
		if (bucket)
			bucket -= Z

/datum/sound_zone_manager/proc/register_listener(mob/player)
	player.register_event(/event/moved, src, nameof(src::on_player_move()))

/datum/sound_zone_manager/proc/on_player_move(mob/mover)
	if (!mover || !mover.client)
		return

	var/turf/T = get_turf(mover)
	if (!T)
		return

	var/list/candidate_zones = get_candidate_zones(T.x, T.y, T.z)
	for (var/datum/sound_zone/Z in candidate_zones)
		if (Z.contains(mover) && !(Z in mover.current_sound_zones))
			Z.on_enter(mover)

	for (var/datum/sound_zone/Z in mover.current_sound_zones)
		if (!Z.contains(mover))
			Z.on_leave(mover)
