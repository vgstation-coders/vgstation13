/*
Ambience system.

background music soon:tm:

*/


/area/
	var/list/background_music = list()

/*
Throw these in client defines.dm

	var/ambience_playing= null
	var/background_music_playing = null

	var/last_ambient_sound
	var/last_background_music //no repeats.
	var/ambience_buffer // essentially world.time + the length of the ambience sound file. this is to prevent overlap.
	var/backgroundmusic_buffer //same as the ambience_buffer but for music.
*/

client/proc/handle_ambience()
	var/list/possible_sounds = list()
	if(!mob)//I wouldn't be surprised if BYOND shat itself eventually and caused a runtime. leaving it like this
		return
	var/cancel_active_ambience = TRUE
	var/area/ActiveArea = get_area(src.mob)

	if(ActiveArea.ambient_sounds.len > 0)//fetch a sound

		for(var/datum/ambience/Z in ActiveArea.ambient_sounds)
			if(Z.sound == last_ambient_noise)
				cancel_active_ambience = FALSE

		if(cancel_active_ambience)
			src << sound(null, 0, 0, CHANNEL_AMBIENCE, 18)//cancels the current ambient noise. a fadeout would be better but idk if it's possible


		//add every in the area's ambient sounds to a list. if it's length is greater than one, remove the last played sound from the list.
		possible_sounds = ActiveArea.ambient_sounds.Copy()
		if(possible_sounds.len > 1)
			for(var/datum/ambience/Y in possible_sounds)
				if(Y.sound == last_ambient_noise)
					possible_sounds -= Y

		var/datum/ambience/picked_ambience_datum = pick(possible_sounds)

		//check to see if there's any need to play a sound rn
		if(ambience_buffer > world.timeofday)
			return "buffer > time of day"
		else
			ambience_buffer = world.timeofday+picked_ambience_datum.length
			last_ambient_noise = picked_ambience_datum.sound
			src << sound(picked_ambience_datum.sound, 0, 0, CHANNEL_AMBIENCE, 25)
			return "Played: [picked_ambience_datum.sound]"
	else
		return "No sounds found in area."
/datum/ambience
	var/sound_type = 1//1 = sound, 2 = music.
	var/length = 0 MINUTES //doesn't need to be 100% accurate. should be in the ballpark though.
	var/sound = null //the actual file it points to.