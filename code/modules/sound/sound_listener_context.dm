
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

	These are constructed and destructed from sound_zone_manager's registration procs.
*/

/client
	var/datum/sound_listener_context/listener_context = null

/datum/sound_listener_context
	var/client/client = null
	var/mob/proxy = null
	var/list/current_channels_by_emitter = list()
	var/list/free_channels = list()

/datum/sound_listener_context/New(client/C, mob/P)
	client = C
	proxy = P
	current_channels_by_emitter = list()
	free_channels = list()
	for (var/i = CHANNEL_RESERVABLE_MIN, i <= CHANNEL_RESERVABLE_MAX, i++)
		free_channels += i

/datum/sound_listener_context/proc/assign_channel(datum/sound_emitter/E)
	if (E in current_channels_by_emitter)
		var/chan = current_channels_by_emitter[E]
		world.log << "client [client] emitter [E] already on channel [chan]"
		return current_channels_by_emitter[E]

	var/channel = null
	if (length(free_channels))
		channel = free_channels[1]
		free_channels -= channel
	if (channel)
		current_channels_by_emitter[E] = channel
		world.log << "client [client] assigned emitter [E] to channel [channel]"
		return channel

/datum/sound_listener_context/proc/release(datum/sound_emitter/E)
	// which channel this client is using for this emitter
	var/chan = current_channels_by_emitter[E]
	// flush it
	var/sound/nullsound = sound(file = null)
	nullsound.channel = chan
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	client << nullsound

	current_channels_by_emitter -= E
	free_channels += chan

/datum/sound_listener_context/proc/reset_proxy(mob/P)
	sound_zone_manager.unregister_listener(client)
	proxy = P
	sound_zone_manager.register_listener(client, proxy)