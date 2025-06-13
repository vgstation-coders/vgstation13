var/datum/subsystem/sounds/SSsounds

/*
    Responsible for updating list of hearers on each sound_emitter within global.sound_controller.
*/

/datum/subsystem/sounds
	name = "Sounds"
	wait = 1
	priority = SS_PRIORITY_SOUNDS
	flags = SS_NO_INIT | SS_KEEP_TIMING

	var/list/sound_emitters = list()

/datum/subsystem/sounds/New()
	NEW_SS_GLOBAL(SSsounds)

/datum/subsystem/sounds/proc/register(datum/sound_emitter/E)
	sound_emitters += E

/datum/subsystem/sounds/proc/unregister(datum/sound_emitter/E)
	sound_emitters -= E

/datum/subsystem/sounds/fire(resumed = FALSE)
	//world.log << "Sound subsystem processing [sound_emitters.len] sound emitters."
	for (var/datum/sound_emitter/E in sound_emitters)
		if (!E.channel)
			//world.log << "Sound emitter [E] has no channel, skipping."
			continue
		var/list/in_range = list()
		var/turf/source = get_turf(E.source)
		var/emitter_range = E.range
		for (var/mob/player in player_list)
			if (!player || !player.client)
				continue
			//world.log << "Checking sound emitter [E] for player [player]."
			var/turf/receiver = get_turf(player)
			// lovingly stolen from sound.dm
			//var/list/oczl = GetOpenConnectedZlevels(source)
			for(var/z0 in GetOpenConnectedZlevels(source))
				if (receiver && source && receiver.z == z0)
					var/turf/portal/P1 = locate(/turf/portal) in receiver.vis_locs
					var/turf/portal/P2 = locate(/turf/portal) in source.vis_locs
					//var/zdist = get_z_dist(receiver, source)
					//world.log << "zdist between player and emitter is [zdist]."
					if((get_z_dist(receiver, source) <= emitter_range) || (P1 && get_z_dist(P1, source) <= emitter_range) || (P2 && get_z_dist(receiver, P2) <= emitter_range) || (P1 && P2 && get_z_dist(P1, P2) <= emitter_range))
						//world.log << "Sound emitter [E] in range of player [player] at [receiver]."
						in_range += player
		//world.log << "Sound emitter [E] has [in_range.len] hearers in range."
		E.update_hearers(in_range) // send sounds to new hearers, stop sounds on lost hearers
		E.update_sound_params() // apply any environmental/deafness/whatever related attenuation and update hearers
