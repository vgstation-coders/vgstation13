
// spatial hashing algo based on https://www.beosil.com/download/CollisionDetectionHashing_VMV03.pdf

var/global/datum/sound_zone_manager/sound_zone_manager = new

/datum/sound_zone_manager
	var/list/buckets = list()
	var/cell_size

/datum/sound_zone_manager/New()
	..()
	buckets = list()
	cell_size = world.view

/datum/sound_zone_manager/proc/hash(x, y, z)
	return "[x],[y],[z]"

/datum/sound_zone_manager/proc/hash_coord(x, y, z)
	return hash(index(x), index(y), z) // not considering multi-z yet (ever)

/datum/sound_zone_manager/proc/index(v)
	return (v - (v % cell_size)) / cell_size // floor integer division - is this retarded, does floor(a/b) or round(a/b, -1) do a faster job

/datum/sound_zone_manager/proc/get_candidate_zones(turf/T)
	var/list/zones = list()
	var/X = index(T.x)
	var/Y = index(T.y)
	for (var/dx in -1 to 1)
		for (var/dy in -1 to 1)
			var/h = hash(X + dx, Y + dy, T.z)
			if (buckets[h])
				for (var/datum/sound_zone/Z in buckets[h])
					zones |= Z
	return zones

/datum/sound_zone_manager/proc/get_candidate_hashes(turf/T)
	var/list/hashes = list()
	var/X = index(T.x)
	var/Y = index(T.y)
	for (var/dx in -1 to 1)
		for (var/dy in -1 to 1)
			var/h = hash(X + dx, Y + dy, T.z)
			if (buckets[h])
				hashes |= h
	return hashes

/datum/sound_zone_manager/proc/register_emitter(datum/sound_emitter/E)
	if (!E.source)
		CRASH("sound_zone_manager: Attempted to register an emitter with no source")
	var/turf/T = get_turf(E.source)
	if (!T)
		CRASH("sound_zone_manager: Failed to get turf in register_emitter")

	var/X = index(T.x)
	var/Y = index(T.y)
	var/h = hash(X, Y, T.z)
	var/datum/sound_zone/Z = new /datum/sound_zone(E)
	Z.last_hash = h
	if (!buckets[h])
		buckets[h] = list()
	buckets[h] |= Z

/datum/sound_zone_manager/proc/move_sound_zone(datum/sound_zone/Z, x, y, z)
	var/h = hash_coord(x, y, z)
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

	var/turf/location = mover.loc //apparently get_turf called extremely often can be expensive?
	if (!isturf(location))
		location = get_turf(mover)
	if (!location)
		return


	var/list/current = list()
	for (var/datum/sound_zone/Z in mover.current_sound_zones)
		current[Z] = TRUE // evil assoc list level hacking
	var/list/fresh = list()

	var/hashes = get_candidate_hashes(location)
	for (var/H in hashes)
		var/B = buckets[H]
		for (var/datum/sound_zone/Z in B)
			if (Z.contains(location))
				fresh[Z] = TRUE
				if (!current[Z])	// what the fuck?
					Z.on_enter(mover)

	for (var/z in current)
		var/datum/sound_zone/Z = z
		if (!fresh[Z])
			Z.on_leave(mover)

	mover.current_sound_zones = fresh.Copy()
