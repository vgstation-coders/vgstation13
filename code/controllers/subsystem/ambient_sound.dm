var/datum/subsystem/ambientsound/SSambience
//ambient sound subsystem.
//at the very least it's not a switch right


/datum/subsystem/ambientsound
	name = "Ambient Sound"
	wait = 5 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND | SS_NO_TICK_CHECK
	priority = SS_PRIORITY_AMBIENCE


/datum/subsystem/ambientsound/New()
	NEW_SS_GLOBAL(SSambience)


/datum/subsystem/ambientsound/fire(resumed = FALSE)
	if(config.no_ambience)
		return
	for (var/client/C in clients)
		if(C && (C.prefs.toggles & SOUND_AMBIENCE))
			C.handle_ambience()

/*
Ambience system.
	var/last_ambient_noise //no repeats.
	var/ambience_buffer // essentially world.time + the length of the ambience sound file. this is to prevent overlap.
*/

client/proc/handle_ambience()
	if(!mob)//I have no trust for Byond.
		return

	var/list/possible_ambience = get_ambience()
	if(!possible_ambience)
		return
	if(last_ambient_noise)
		var/cancel_ambience = TRUE
		for(var/amb in possible_ambience)
			var/datum/ambience/A = amb
			if(last_ambient_noise == initial(A.sound))
				cancel_ambience = FALSE
				break
		if(cancel_ambience)
			src << sound(null, 0, 0, CHANNEL_AMBIENCE)//I can't think of a sane way to have this be less abrupt. I don't think you can do anything like animating sounds and having a loop for it is gay.
			ambience_buffer = null//no delay on starting a new sound.

	if(ambience_buffer > world.timeofday)
		return //sound's playing. don't bother.

	if(possible_ambience.len)
		for(var/datum/ambience/ambie in possible_ambience)
			if(last_ambient_noise == ambie.sound)
				possible_ambience -= ambie
				break
		var/datum/ambience/picked_ambience_datum = pick(possible_ambience) //this is a type, not an instance.
		if(prob(initial(picked_ambience_datum.prob_fire)))
			ambience_buffer = world.timeofday+initial(picked_ambience_datum.length)
			last_ambient_noise = initial(picked_ambience_datum.sound)
			src << sound(last_ambient_noise, 0, 0, CHANNEL_AMBIENCE, prefs.ambience_volume)

/client/proc/get_ambience()
	var/area/a = get_area(mob)//other overrides can go in here. eg: overrides for weather. or for cult.
	if(a && a.ambient_sounds)
		return a.ambient_sounds

/datum/ambience
	var/length = 0 MINUTES //doesn't need to be 100% accurate. should be in the ballpark though.
	var/sound = null //the actual file it points to.
	var/prob_fire = 35 //The chance we play this ambience
