
// spatial hashing algo based on https://www.beosil.com/download/CollisionDetectionHashing_VMV03.pdf

var/global/datum/sound_zone_manager/sound_zone_manager = new

/datum/sound_zone_manager
	var/list/emitter_buckets = list()
	var/list/listener_buckets = list() // TODO one day split this into parent/child types... maybe
	var/cell_size

/datum/sound_zone_manager/New()
	..()
	emitter_buckets = list()
	listener_buckets = list()
	cell_size = world.view

/datum/sound_zone_manager/proc/hash(x, y, z)
	return "[x],[y],[z]"

/datum/sound_zone_manager/proc/hash_coord(x, y, z)
	return hash(index(x), index(y), z) // not considering multi-z yet (ever)

/datum/sound_zone_manager/proc/index(v)
	return floor(v / cell_size)

/datum/sound_zone_manager/proc/emitter_candidate_hashes(turf/T)
	var/list/hashes = list()
	var/X = index(T.x)
	var/Y = index(T.y)
	for (var/dx in -1 to 1)
		for (var/dy in -1 to 1)
			var/h = hash(X + dx, Y + dy, T.z)
			if (emitter_buckets[h])
				hashes |= h
	return hashes

/datum/sound_zone_manager/proc/listener_candidate_hashes(x, y, z)
	var/list/hashes = list()
	var/X = index(x)
	var/Y = index(y)
	for (var/dx in -1 to 1)
		for (var/dy in -1 to 1)
			var/h = hash(X + dx, Y + dy, z)
			if (listener_buckets[h])
				hashes |= h
	return hashes

/datum/sound_zone_manager/proc/register_emitter(datum/sound_emitter/E)
	if (!E.source)
		CRASH("sound_zone_manager: Attempted to register an emitter with no source")
	var/turf/T = get_turf(E.source)
	if (!T)
		CRASH("sound_zone_manager: Failed to get turf in register_emitter on sound emitter [E]")

	var/X = index(T.x)
	var/Y = index(T.y)
	var/h = hash(X, Y, T.z)
	E.last_hash = h
	if (!emitter_buckets[h])
		emitter_buckets[h] = list()
	emitter_buckets[h] |= E

/datum/sound_zone_manager/proc/unregister_emitter(datum/sound_emitter/E)
	var/h = E.last_hash
	if (!h)
		CRASH("Attempted to unregister emitter [E] with no prior hash")
	var/bucket = emitter_buckets[h]
	if (!bucket)
		CRASH("Failed to find bucket for emitter [E] with prior hash [h]")
	bucket -= E

/datum/sound_zone_manager/proc/update_emitter(datum/sound_emitter/E, newX, newY, newZ)
	var/newHash = hash_coord(newX, newY, newZ)
	if (!E.last_hash)
		CRASH("Tried to update emitter [E] with no prior hash")
	if (E.last_hash != newHash)
		// update emitter hash table
		var/list/old_bucket = emitter_buckets[E.last_hash]
		if (!old_bucket)
			CRASH("Failed to find bucket for emitter with prior hash [E.last_hash]")
		old_bucket -= E

		var/list/new_bucket = emitter_buckets[newHash]
		if (!emitter_buckets[newHash])
			new_bucket = emitter_buckets[newHash] = list()
		new_bucket |= E

		E.last_hash = newHash

	// check for new hearers - inverted on_player_move
	var/hashes = listener_candidate_hashes(newX, newY, newZ)
	for (var/H  in hashes)
		var/list/B = listener_buckets[H]
		for (var/mob/listener in B)
			var/client/client = listener.client
			if (!client) // e.g. AI eye has no client, endpoint must be overridden
				client = listener.sound_endpoint.client
			if (!client || !client.listener_context)
				CRASH("Found a listener with no client or endpoint client")

			if (E in client.listener_context.current_channels_by_emitter)
				if (!E.contains(listener))
					E.on_exit_range(client)
				else
					E.update_params_for_player(client)
			else
				E.on_enter_range(client)

// most of the time we want to send to client C sounds relevant to C.mob
//  however for things like the AI eye we want to send to client AICore the sounds relevant to AIEye
// typically this will be called as register_listener(client, client.mob)
/datum/sound_zone_manager/proc/register_listener(client/C, mob/proxy)
	if (!C || !proxy)
		return // nothing to register
	if (!C.mob)
		CRASH("Tried to register_listener client [C] with no mob")

	if (C.listener_context)
		var/datum/sound_listener_context/context = C.listener_context
		if (context.proxy != proxy)
			context.reset_proxy(proxy)
	else
		C.listener_context = new /datum/sound_listener_context(C, proxy)

	var/turf/T = get_turf(proxy)
	if (!T)
		CRASH("sound_zone_manager: Failed to get turf in register_listener for target mob [proxy] for client [C]")

	var/X = index(T.x)
	var/Y = index(T.y)
	var/h = hash(X, Y, T.z)
	proxy.last_sound_zone_hash = h
	if (!listener_buckets[h])
		listener_buckets[h] = list()
	listener_buckets[h] |= proxy

	proxy.sound_endpoint = C.mob
	proxy.register_event(/event/moved, src, nameof(src::on_player_move()))
	on_player_move(proxy)

/datum/sound_zone_manager/proc/unregister_listener(client/C)
	if (!C || !C.listener_context)
		return
	var/mob/M = C.listener_context.proxy
	if (!M)
		CRASH("Tried to unregister a client with no proxy")
	var/H = M.last_sound_zone_hash
	if (H)
		var/bucket = listener_buckets[H]
		if (bucket)
			bucket -= M

	// stop them from picking up new emitters
	M.unregister_event(/event/moved, src, nameof(src::on_player_move()))
	// stop everything they can hear and clear out their current emitters list
	var/list/emitters = C.listener_context.current_channels_by_emitter.Copy()
	for (var/datum/sound_emitter/E in emitters)
		E.on_exit_range(C)
	M.sound_endpoint = null
	C.listener_context.Destroy()
	C.listener_context = null

/datum/sound_zone_manager/proc/update_listener(mob/player)
	var/newHash = hash_coord(player.x, player.y, player.z)
	if (!player.last_sound_zone_hash)
		CRASH("Tried to update listener [player] with no prior hash")
	if (player.last_sound_zone_hash == newHash)
		return // nothing to do

	var/list/old_bucket = listener_buckets[player.last_sound_zone_hash]
	if (!old_bucket)
		CRASH("Failed to find bucket for listener with prior hash [player.last_sound_zone_hash]")
	old_bucket -= player

	var/list/new_bucket = listener_buckets[newHash]
	if (!listener_buckets[newHash])
		new_bucket = listener_buckets[newHash] = list()
	new_bucket |= player

	player.last_sound_zone_hash = newHash

/datum/sound_zone_manager/proc/on_player_move(mob/mover)
	if (!mover)
		return
	if (!mover.sound_endpoint)
		return // nowhere to send the sound

	var/turf/location = mover.loc
	if (!isturf(location))
		location = get_turf(mover)
	if (!location)
		return

	update_listener(mover)

	var/client/receive_client = mover.sound_endpoint.client
	if (!receive_client || !receive_client.listener_context)
		return

	var/datum/sound_listener_context/context = receive_client.listener_context

	var/list/current = list()
	for (var/datum/sound_emitter/E in context.current_channels_by_emitter)
		current[E] = TRUE
	var/list/fresh = list()

	var/hashes = emitter_candidate_hashes(location)
	for (var/H in hashes)
		var/list/B = emitter_buckets[H]
		for (var/datum/sound_emitter/E in B)
			if (E.contains(location))
				fresh[E] = TRUE
				if (!current[E])
					E.on_enter_range(receive_client)
				else
					E.update_params_for_player(receive_client)

	for (var/e in current)
		var/datum/sound_emitter/E = e
		if (!fresh[E])
			E.on_exit_range(receive_client)
