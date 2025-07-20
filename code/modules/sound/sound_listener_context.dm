
/*
	This is a client datum that tracks which sound channels are in use for the client.
	Previously channel management was serverside and global, meaning that for every single client,
	  a SMES in Engineering and a SMES on some random derelict would be on channel 1, for example.
	This new architecture is designed to offload channel reservation to the client and keep
	  sound_emitters as passive data sources.
	There is also the added benefit of vastly simplified flushing in the event of ckey transfers
	  between mobs. Rather than keeping a /mob/var/list/current_sound_emitters which has to be
	  carefully updated on instances of things like ghosting or being set to a body, this data
	  is maintained at the client level where such transfers are much cleaner to work with.
	It also makes sense because sounds are sent to the client anyway, not to the mob.

	These are constructed in `mob/Login() - if one is already initialised (e.g. if the client is being
	  reassigned to a new mob, such as via ghosting) then `reset_proxy` is called instead.
	  This triggers reregistration with the SZM which itself forces an `on_player_move` call, which
	  flushes old emitters and updates with new ones.
	Lifetime is otherwise tied to the client and so is destructed when the client iself is deleted,
	  such as on disconnect.
*/

/client
	var/datum/sound_listener_context/listener_context = null

/client/Del()
	qdel(listener_context)
	return ..()

/mob/Login()
	if (client.listener_context) // already initialised -> here from mob transfer
		client.listener_context.reset_proxy(src)
	else // client is connecting
		client.listener_context = new /datum/sound_listener_context(client, src)
	return ..()

/datum/sound_listener_context
	var/client/client = null
	var/mob/proxy = null
	var/list/current_channels_by_emitter = list()
	var/list/free_channels = list()
	var/range = null

/datum/sound_listener_context/New(client/C, mob/P, hearing_range)
	client = C
	proxy = P
	current_channels_by_emitter = list()
	free_channels = list()
	for (var/i = CHANNEL_RESERVABLE_MIN, i <= CHANNEL_RESERVABLE_MAX, i++)
		free_channels += i
	range = hearing_range
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/Destroy()
	for (var/datum/sound_emitter/E in current_channels_by_emitter)
		release(E)
	free_channels.Cut()
	current_channels_by_emitter.Cut()
	sound_zone_manager.unregister_listener(src)
	client = null
	proxy = null
	. = ..()

/datum/sound_listener_context/proc/assign_channel(datum/sound_emitter/E)
	if (E in current_channels_by_emitter)
		return current_channels_by_emitter[E]

	var/channel = null
	if (length(free_channels))
		channel = free_channels[1]
		free_channels -= channel
	if (channel)
		current_channels_by_emitter[E] = channel
		return channel

/datum/sound_listener_context/proc/release(datum/sound_emitter/E)
	// which channel this client is using for this emitter
	var/chan = current_channels_by_emitter[E]
	if (!chan)
		CRASH("listener_context attempted to release [E] with no channel, possible double-release or other fuckery")
	// flush it
	var/sound/nullsound = sound(file = null)
	nullsound.channel = chan
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	client << nullsound

	current_channels_by_emitter -= E
	free_channels += chan

	unsubscribe_from(E)

/datum/sound_listener_context/proc/reset_proxy(mob/P)
	sound_zone_manager.unregister_listener(src)
	proxy = P
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/proc/apply_proxymob_effects(sound/S)
	if (proxy.is_deaf())
		S.volume = 0
		return S
	if (!(S.atom in view(range, proxy)))
		S.volume /= 5

	var/p_effect = turf_volume_coeff(proxy)
	S.volume *= p_effect

	return S

/datum/sound_listener_context/proc/subscribe_to(datum/sound_emitter/E)
	E.register_event(/event/sound_updated, src, nameof(src::on_sound_update()))
	E.register_event(/event/sound_started, src, nameof(src::start_hearing()))
	E.register_event(/event/sound_stopped, src, nameof(src::stop_hearing()))
	E.register_event(/event/sound_pushed, src, nameof(src::hear_once()))


/datum/sound_listener_context/proc/unsubscribe_from(datum/sound_emitter/E)
	E.unregister_event(/event/sound_updated, src, nameof(src::on_sound_update()))
	E.unregister_event(/event/sound_started, src, nameof(src::start_hearing()))
	E.unregister_event(/event/sound_stopped, src, nameof(src::stop_hearing()))
	E.unregister_event(/event/sound_pushed, src, nameof(src::hear_once()))

/datum/sound_listener_context/proc/start_hearing(datum/sound_emitter/emitter)
	if (!emitter.is_currently_playing())
		return // start hearing what?
	var/chan = assign_channel(emitter)
	if (!chan)
		CRASH("Sound emitter on [emitter.source] failed to reserve a channel for [src]")
	var/sound/S = emitter.active_sound.get()

	// important note - clearing SOUND_UPDATE means that the sound will play FROM THE BEGINNING.
	// this system was originally built with short repeating sounds in mind (machine hum, etc) however
	// if you try to do something longer and more varied like music then this is very noticeable and unwanted.
	// such support goes beyond scope for v1 but may be solvable using sound.len, tracking playback
	// progress and modifying S.offset to start at the correct point.
	// TODO /datum/managed_sound should do this!
	S.status &= ~SOUND_UPDATE
	S.channel = chan
	apply_proxymob_effects(S)
	client << S

/datum/sound_listener_context/proc/hear_once(sound/S)
	apply_proxymob_effects(S)
	client << S

/datum/sound_listener_context/proc/stop_hearing(datum/sound_emitter/emitter)
	var/chan = assign_channel(emitter)
	if (!chan)
		return
	var/sound/nullsound = sound(file = null)
	nullsound.channel = chan
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	client << nullsound

/datum/sound_listener_context/proc/on_sound_update(datum/sound_emitter/emitter)
	var/chan = current_channels_by_emitter[emitter]
	if (!chan)
		CRASH("Failed to get channel for sound update from [emitter] on [client]")
	if (!emitter.active_sound)
		return // emitter isn't playing anything, get out of here
	var/sound/S = emitter.active_sound.get()
	S.status |= SOUND_UPDATE
	S.channel = chan
	apply_proxymob_effects(S)
	client << S

/datum/sound_listener_context/proc/on_enter_range(datum/sound_emitter/E)
	start_hearing(E) // this can throw if channel reservation fails, subscribe after its safe
	subscribe_to(E)

/datum/sound_listener_context/proc/on_exit_range(datum/sound_emitter/E)
	release(E)
