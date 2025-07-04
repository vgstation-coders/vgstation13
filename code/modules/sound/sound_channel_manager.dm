var/global/datum/sound_channel_manager/sound_channel_manager = new

/datum/sound_channel_manager
	var/list/datum/sound_channel/unique/free_unique_channels = list()
	var/list/datum/sound_channel/shared/free_shared_channels = list()
	var/list/datum/sound_channel/shared/inuse_shared_channels = list()

/datum/sound_channel_manager/New()
	..()
	free_unique_channels = list()
	free_shared_channels = list()
	inuse_shared_channels = list()
	for (var/i = CHANNEL_SHARED_MIN, i <= CHANNEL_SHARED_MAX, i++)
		var/datum/sound_channel/shared/C = new
		C.value = i
		free_shared_channels += C
	for (var/i = CHANNEL_UNIQUE_MIN, i <= CHANNEL_UNIQUE_MAX, i++)
		var/datum/sound_channel/unique/C = new
		C.value = i
		free_unique_channels += C

// prioritise shared if possible
// recommend using `get_unique` if its a mobile source so it wont contend by accident when moving near a sharing emitter
/datum/sound_channel_manager/proc/reserve_channel(datum/sound_emitter/emitter, get_unique = TRUE)
	var/channel = null
	if (!get_unique)
		channel = try_get_shared(emitter)
	if (!channel)
		// fallback to unique pool if we wanted a shared channel but couldnt get one
		channel = try_get_unique()
	return channel

/datum/sound_channel_manager/proc/try_get_shared(datum/sound_emitter/emitter)
	// first try to use an existing channel
	for (var/datum/sound_channel/shared/inuse in inuse_shared_channels)
		if (!sound_zone_manager.conflict(emitter.source, inuse))
			inuse.users += emitter
			return inuse
	// fallback - use a new shareable
	if (length(free_shared_channels))
		var/datum/sound_channel/shared/free = free_shared_channels[1]
		free_shared_channels -= free
		inuse_shared_channels += free
		free.users += emitter
		return free

/datum/sound_channel_manager/proc/try_get_unique()
	var/channel = null
	if (length(free_unique_channels))
		channel = free_unique_channels[1]
		free_unique_channels -= channel
	return channel

/datum/sound_channel_manager/proc/release_channel(datum/sound_channel/channel, datum/sound_emitter/emitter)
	if (is_shared_channel(channel))
		release_shared(channel, emitter)
	else if (is_unique_channel(channel))
		release_unique(channel)
	else
		CRASH("Attempted to free an unmanaged channel")

/datum/sound_channel_manager/proc/release_shared(datum/sound_channel/c, datum/sound_emitter/E)
	var/datum/sound_channel/shared/C = c
	C.users -= E
	if (!length(C.users))
		inuse_shared_channels -= C
		free_shared_channels += C

/datum/sound_channel_manager/proc/release_unique(datum/sound_channel/c)
	var/datum/sound_channel/unique/C = c
	C.user = null
	free_unique_channels += C

/proc/is_shared_channel(datum/sound_channel/C)
	return (CHANNEL_SHARED_MIN <= C.value && C.value <= CHANNEL_SHARED_MAX)

/proc/is_unique_channel(datum/sound_channel/C)
	return (CHANNEL_UNIQUE_MIN <= C.value && C.value <= CHANNEL_UNIQUE_MAX)

/datum/sound_channel
	var/value = null

/datum/sound_channel/unique
	var/datum/sound_emitter/user = null

/datum/sound_channel/shared
	var/list/datum/sound_emitter/users = list()
