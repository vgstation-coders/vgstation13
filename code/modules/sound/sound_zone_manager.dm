
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
	E.last_hash = h
	if (!buckets[h])
		buckets[h] = list()
	buckets[h] |= E

/datum/sound_zone_manager/proc/unregister_emitter(datum/sound_emitter/E)
	var/h = E.last_hash
	if (!h)
		CRASH("Attempted to unregister an emitter with no prior hash")
	var/bucket = buckets[h]
	if (!bucket)
		CRASH("Failed to find bucket for emitter with prior hash [h]")
	bucket -= E

/datum/sound_zone_manager/proc/update_emitter(datum/sound_emitter/E, newX, newY, newZ)
	var/newHash = hash_coord(newX, newY, newZ)
	if (!E.last_hash)
		CRASH("Tried to update an emitter with no prior hash")
	if (E.last_hash == newHash)
		return // nothing to do

	var/list/old_bucket = buckets[E.last_hash]
	if (!old_bucket)
		CRASH("Failed to find bucket for emitter with prior hash [E.last_hash]")
	old_bucket -= E

	var/list/new_bucket = buckets[newHash]
	if (!buckets[newHash])
		new_bucket = buckets[newHash] = list()
	new_bucket |= E

	E.last_hash = newHash

/datum/sound_zone_manager/proc/register_listener(mob/player)
	player.register_event(/event/moved, src, nameof(src::on_player_move()))

/datum/sound_zone_manager/proc/on_player_move(mob/mover)
	if (!mover || !mover.client)
		return

	var/turf/location = mover.loc
	if (!isturf(location))
		location = get_turf(mover)
	if (!location)
		return

	var/list/current = list()
	for (var/datum/sound_emitter/E in mover.current_sound_emitters)
		current[E] = TRUE
	var/list/fresh = list()

	var/hashes = get_candidate_hashes(location)
	for (var/H in hashes)
		var/list/B = buckets[H]
		for (var/datum/sound_emitter/E in B)
			if (E.contains(location))
				fresh[E] = TRUE
				if (!current[E])
					E.on_enter_range(mover)
				else
					E.update_params_for_player(mover)

	for (var/e in current)
		var/datum/sound_emitter/E = e
		if (!fresh[E])
			E.on_exit_range(mover)

	mover.current_sound_emitters = fresh.Copy()
