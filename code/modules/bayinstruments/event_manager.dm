/datum/musical_event
	var/sound/object
	var/mob/subject
	var/datum/sound_player/source
	var/time = 0
	var/new_volume = 100


/datum/musical_event/New(datum/sound_player/source_, mob/subject_, sound/object_, time_, volume_)
	source = source_
	subject = subject_
	object = object_
	time = time_
	new_volume = volume_


/datum/musical_event/proc/tick()
	if (!(istype(object) && istype(subject) && istype(source))) 
		return
	if (new_volume > 0) 
		update_sound()
	else 
		destroy_sound()


/datum/musical_event/proc/update_sound()
	object.volume = new_volume
	object.status |= SOUND_UPDATE
	if (subject)
		subject << object


/datum/musical_event/proc/destroy_sound()
	if (subject)
		var/sound/null_sound = sound(channel=object.channel, wait=0)
		if (global.musical_config.env_settings_available)
			null_sound.environment = -1
		subject << null_sound
	if (source || source.song)
		source.song.free_channel(object.channel)


