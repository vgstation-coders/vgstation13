var/global/datum/sound_channel_manager/sound_channel_manager = new

/datum/sound_channel_manager
	var/list/free_channels = list()
	var/list/reserved_channels = list()

/datum/sound_channel_manager/New()
	..()
	free_channels = list()
	reserved_channels = list()
	for (var/i = CHANNEL_RESERVABLE_MIN, i <= CHANNEL_RESERVABLE_MAX, i++)
		free_channels += i

/datum/sound_channel_manager/proc/reserve_channel(var/datum/sound_emitter/emitter)
	if (!length(free_channels))
		return
	var/channel = free_channels[1]
	free_channels -= channel
	reserved_channels += channel
	return channel

/datum/sound_channel_manager/proc/release_channel(var/channel, var/datum/sound_emitter/emitter)
	if (!channel || !isnum(channel) || channel < CHANNEL_RESERVABLE_MIN || channel > CHANNEL_RESERVABLE_MAX)
		return
	if (!(channel in reserved_channels))
		return
	reserved_channels -= channel
	free_channels += channel
	// free_channels.Sort() // probably not necessary