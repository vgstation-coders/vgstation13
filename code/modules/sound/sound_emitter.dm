/atom
	var/datum/sound_emitter/sound_emitter

/atom/proc/setup_sound()
	return

/mob
	var/last_sound_zone_hash = null
	// proxy for when the sound needs to be sent to some other mob, e.g. aiEye mob movement needs sounds sent to AI Core mob
	//  this is because the AI Eye client is null and mob/proc/operator<< tries to send to client
	var/mob/sound_endpoint = null
/mob/New()
	sound_endpoint = src

/datum/sound_emitter
	var/atom/source = null
	var/list/sounds = list() // list of managed_sound
	var/datum/managed_sound/active_sound = null
	var/list/client/hearers = list()
	var/range
	var/last_hash = null

	// update driven by subsystem via update_active_sound_param
	var/env_volume_coeff = 1

	var/datum/sound_zone_manager/szm // not strictly necessary but its here for easy debugging in this early stage

// for static things (e.g. machines that must be bolted to work) pass is_static = TRUE
//  this causes the reserved channel to be taken from a shared pool, as static objects won't move close
//  to eachother and won't contend. There is no overlap between the shared and unique pools, so no contention
//  for example if someone carrying something noisy (mobile -> unique pool) walks close to something in the shared pool.
// Dimensional Push is the exception to this (probably), the sound messing up is part of the !!! fun !!!
/datum/sound_emitter/New(atom/A, var/is_static = FALSE)
	..()
	source = A
	range = world.view
	sound_emitter_collection.add(src)
	if (sound_zone_manager)
		szm = sound_zone_manager

/datum/sound_emitter/Destroy()
	sound_emitter_collection.remove(src)
	deactivate();
	if (sounds)
		sounds.Cut()
		sounds = null
	. = ..()

/*
		GENERAL USE INTERFACE - SETUP, PLAY/STOP CONTROL
*/

/datum/sound_emitter/proc/add(sound/s, key)
	if (!s || !istype(s, /sound))
		return
	if (key && (key in sounds))
		return
	s.atom = source
	s.environment = -1 // byond bug(?) if you set this to anything else, it will permanently set the channel environment to it
	s.transform = matrix(1, 0, 0, 0, 1, 0) //dont think theres a good reason for this to be anything else
	sounds[key] = new /datum/managed_sound(s)

/datum/sound_emitter/proc/play(key)
	var/datum/managed_sound/S = sounds[key]
	if (!S)
		CRASH("Sound emitter play called for key [key], but sound does not exist.")

	if (S.base_sound.repeat == 1)
		activate(key)
	else
		play_once(copy_sound(S.base_sound))

/datum/sound_emitter/proc/play_once(sound/S, interrupt = FALSE)
	S.atom = source
	S.repeat = 0 //no repeat - no need for channel reservation
	S.wait = 0
	if (interrupt)
		stop()
	// reduce volume if emitter is in low pressure
	S.volume *= turf_volume_coeff(source)
	if (!S.volume)
		return
	var/vicinity = clients_in_range()
	for (var/client/C in vicinity)
		var/datum/sound_listener_context/context = C.listener_context
		var/sound/PS = apply_player_effects(copy_sound(S), context.proxy)
		if (PS.volume)
			C << PS

/datum/sound_emitter/proc/is_currently_playing()
	return (active_sound != null)

/datum/sound_emitter/proc/update_active_sound_param(volume = null, frequency = null)
	if (!is_currently_playing())
		return
	// update active_sound overrides
	if (volume)
		active_sound.volume_override = volume
	if (frequency)
		active_sound.frequency_override = frequency

	// update environmental effect cache
	env_volume_coeff = turf_volume_coeff(source)
	apply_env_effects(active_sound)

	var/sound/S = active_sound.get()
	S.status |= SOUND_UPDATE
	for (var/client/C in hearers)
		var/datum/sound_listener_context/context = C.listener_context
		S = apply_player_effects(copy_sound(S), context.proxy)
		var/chan = context.assign_channel(src) // TODO safety proc "get_active_channel" with check that src is on that channel
		S.channel = chan
		world.log << "Sending [S.file] to [C] on channel [S.channel], volume [S.volume]"
		C << S

/datum/sound_emitter/proc/stop()
	if (!is_currently_playing())
		return
	deactivate()

/datum/sound_emitter/proc/update_source(atom/new_source)
	sound_emitter_collection.remove(src)
	if (is_currently_playing())
		sound_zone_manager.unregister_emitter(src)
	//old source should no longer fire move events
	source.unregister_event(/event/moved, src, nameof(src::on_source_moved()))

	source = new_source
	for (var/key in sounds)
		var/datum/managed_sound/S = sounds[key]
		S.update_atom(new_source)
	update_active_sound_param()

	sound_emitter_collection.add(src)
	if (is_currently_playing())
		sound_zone_manager.register_emitter(src)
	//new source
	source.register_event(/event/moved, src, nameof(src::on_source_moved()))

/*
		SYSTEMS-FACING INTERFACE
*/

/datum/sound_emitter/proc/on_source_moved(atom/mover)
	if (mover != source)
		CRASH("Called on_source_moved while mover ([mover]) != source ([source])")
	var/turf/T = source.loc
	if (!isturf(T))
		T = get_turf(source)
	if (!T)
		CRASH("Failed to get source turf")
	sound_zone_manager.update_emitter(src, T.x, T.y, T.z)

// called when an active emitter and player enter audible range of one another
/datum/sound_emitter/proc/on_enter_range(client/C)
	if (!is_currently_playing())
		CRASH("[C] Called on_enter_range on emitter [src] with that was inactive")
	if (!C || !C.listener_context || (C in hearers))
		return //nowhere to send the sound, client can't hear at all or client can already hear it

	var/datum/sound_listener_context/context = C.listener_context
	var/chan = context.assign_channel(src)
	if (!chan)
		CRASH("Sound emitter on [source] failed to reserve a channel for [C]")

	hearers |= C
	var/sound/S = active_sound.get()
	// important note - clearing SOUND_UPDATE means that the sound will play FROM THE BEGINNING.
	// this system was originally built with short repeating sounds in mind (machine hum, etc) however
	// if you try to do something longer and more varied like music then this is very noticeable and unwanted.
	// such support goes beyond scope for v1 but may be solvable using sound.len, tracking playback progress and modifying
	// S.offset to start at the correct point
	S.status &= ~SOUND_UPDATE // clear update status for new hearers, else they cant hear it lmao
	S.channel = chan
	S = apply_player_effects(copy_sound(S), context.proxy)
	C << S

// called when an active emitter and player are no longer in audible range, emitter deactivates while in range or
//   when flushing this emitter from what a client can hear
/datum/sound_emitter/proc/on_exit_range(client/C)
	if (!C || !C.listener_context)
		return

	hearers -= C
	C.listener_context.release(src)

/datum/sound_emitter/proc/contains(turf/T)
	if (!T)
		return FALSE
	var/turf/S = source.loc
	if (!isturf(S))
		S = get_turf(source)
	if (!S)
		CRASH("Failed to get source turf in in_range")
	var/minX = S.x - range
	var/maxX = S.x + range
	var/minY = S.y - range
	var/maxY = S.y + range
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/*
		INTERNAL, DON'T CALL THESE DIRECTLY YOU
*/

// push sounds to any clients in range, register with sound_zone_manager for dynamic updates
/datum/sound_emitter/proc/activate(key)
	active_sound = sounds[key]
	if (!active_sound)
		CRASH("[key] not found in sounds cache for emitter on [source]")
	sound_zone_manager.register_emitter(src)
	init_hearers()
	update_hearers()

// halt sounds to clients in range, unregister from dynamic updates
/datum/sound_emitter/proc/deactivate()
	active_sound = null
	update_hearers()
	hearers.Cut()
	sound_zone_manager.unregister_emitter(src)

/datum/sound_emitter/proc/init_hearers()
	hearers = clients_in_range()

/datum/sound_emitter/proc/update_hearers()
	var/sound/S = null
	if (active_sound)
		S = active_sound.get()
		S.status &= ~SOUND_UPDATE
	else
		S = sound()
		S.file = null
		S.status = SOUND_UPDATE | SOUND_MUTE
	for (var/client/client in hearers)
		if (!client.listener_context)
			continue
		var/datum/sound_listener_context/context = client.listener_context
		var/chan = context.assign_channel(src)
		S.channel = chan
		if (S.file)
			S = apply_player_effects(copy_sound(S), context.proxy) // dont bother doing this for null sounds
		client << S

/datum/sound_emitter/proc/apply_player_effects(sound/s, var/mob/player)
	if (player.is_deaf())
		s.volume = 0
		return s

	// loosely simulate some obstruction muffling the sound
	if (!(source in view(range, player)))
		s.volume /= 5

	// similarly if player is in spaced area and emitter is in non-spaced nearby, shouldn't hear it
	var/p_effect = turf_volume_coeff(player)
	s.volume *= p_effect

	return s

/datum/sound_emitter/proc/apply_env_effects(datum/managed_sound/s)
	s.volume_mutator = env_volume_coeff

/datum/sound_emitter/proc/turf_volume_coeff(atom/a)
	if (!a)
		return 1 // ?:D?
	var/turf/t = get_turf(a)
	if (!t)
		return 0 // no sound for the damned
	if (istype(t, /turf/simulated))
		var/turf/simulated/sim = t
		if (sim.zone?.air?.sound_coeff)
			return sim.zone.air.sound_coeff
	if (istype(t, /turf/unsimulated))
		return 1
	return 0 //damned

/datum/sound_emitter/proc/update_params_for_player(client/C)
	if (!active_sound)
		return
	if (!C || !C.listener_context)
		return

	if (!(C in hearers))
		CRASH("tried to update_params_for_player on [C] on emitter [source] but it wasn't in hearers")
		//return // client can't hear this emitter anyway, why are we even here

	var/sound/S = active_sound.get()
	apply_player_effects(S, C.listener_context.proxy)
	S.status |= SOUND_UPDATE
	var/chan = C.listener_context.assign_channel(src)
	S.channel = chan
	C << S

/datum/sound_emitter/proc/clients_in_range()
	var/list/in_range = list()
	var/turf/t_source = get_turf(source)
	for (var/mob/player in player_list)
		if (!player || !player.sound_endpoint)
			continue // nowhere to send the sound
		var/client/client = player.sound_endpoint.client
		if (!client || !client.listener_context)
			continue // nowhere to send the sound
		var/turf/receiver = get_turf(client.listener_context.proxy)
		if (!receiver)
			continue //player on some invalid turf, CRASH?

		if((get_z_dist(receiver, t_source) <= range))
			in_range += client
	return in_range
