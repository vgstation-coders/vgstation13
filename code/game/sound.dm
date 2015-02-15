var/list/rustle_sound = list('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
var/list/punch_sound = list('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
var/list/swing_hit_sound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
var/list/hiss_sound = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
var/list/mechstep_sound = list('sound/mecha/mechstep1.ogg', 'sound/mecha/mechstep2.ogg')
var/list/gib_sound = list('sound/effects/gib1.ogg', 'sound/effects/gib2.ogg', 'sound/effects/gib3.ogg')
var/list/mommicomment_sound = list('sound/voice/mommi_comment1.ogg', 'sound/voice/mommi_comment2.ogg', 'sound/voice/mommi_comment3.ogg', 'sound/voice/mommi_comment5.ogg', 'sound/voice/mommi_comment6.ogg', 'sound/voice/mommi_comment7.ogg', 'sound/voice/mommi_comment8.ogg')
//var/list/gun_sound = list('sound/weapons/Gunshot.ogg', 'sound/weapons/Gunshot2.ogg','sound/weapons/Gunshot3.ogg','sound/weapons/Gunshot4.ogg')

//gas_modified controls if a sound is affected by how much gas there is in the atmosphere of the source
//space sounds have no gas modification, for example. Though >space sounds
/proc/playsound(var/atom/source, soundin, volume = 100, vary = FALSE, extrarange = 0, falloff = FALSE, gas_modified = TRUE)

	soundin = get_sfx(soundin) // Same sound for everybody.

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = get_rand_frequency() // Same frequency for everybody.
	var/turf/turf_source = get_turf(source)

/* What's going on in this block?
	If the proc isn't set to not be modified by air, the following steps occur:
	- The atmospheric pressure of the turf where the sound is played is determined
	- A calculation is made as to the fraction of one atmosphere that the pressure is at, in tenths e.g. 0.1, 0.3, 0.7, never exceeding 1
	- If the proc has extrarange, the fraction of this extrarange that applies is equal to that of the pressure of the tile
	- If the proc has NO extrarange, the fraction of the 7 range is used, so a sound only trasmits to those in the screen at regular pressure
	- This means that at low or 0 pressure, sound doesn't trasmit from the tile at all! How cool is that?
*/
	if(gas_modified && turf_source && !turf_source.c_airblock(turf_source)) //if the sound is modified by air, and we are on an airflowing tile
		var/atmosphere = 0
		var/datum/gas_mixture/current_air = turf_source.return_air()
		if(current_air)
			atmosphere = current_air.return_pressure()
		else
			atmosphere = 0 //no air

		//message_admins("We're starting off with [atmosphere], [extrarange], and [vol]")
		var/atmos_modifier = round(atmosphere/ONE_ATMOSPHERE, 0.1)
		var/total_range = world.view + extrarange //this must be positive.
		total_range = min ( round( (total_range) * sqrt(atmos_modifier), 1 ), (total_range * 2)  ) //upper range of twice the original range. Range technically falls off with the root of pressure (see Newtonian sound)
		extrarange = total_range - world.view
		volume = min( round( (volume) * atmos_modifier, 1 ), volume * 2) //upper range of twice the volume. Trust me, otherwise you get 10000 volume in a plasmafire
		//message_admins("We've adjusted the sound of [source] at [turf_source.loc] to have a range of [7 + extrarange] and a volume of [vol]")

 	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if(get_dist(M, turf_source) <= world.view + extrarange)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, volume, vary, frequency, falloff, gas_modified)

var/const/FALLOFF_SOUNDS = 1
var/const/SURROUND_CAP = 7

#define MIN_SOUND_PRESSURE	2 //2 kPa of pressure required to at least hear sound
/mob/proc/playsound_local(var/turf/turf_source, soundin, volume = 100, vary = FALSE, frequency = 0, falloff = FALSE, gas_modified = FALSE)
	if(!src.client || ear_deaf > 0)
		return

	if(gas_modified)
		var/turf/current_turf = get_turf(src)
		if(!current_turf)
			return

		var/datum/gas_mixture/environment = current_turf.return_air()
		var/atmosphere = 0
		if(environment)
			atmosphere = environment.return_pressure()

		/// Local sound modifications ///
		if(atmosphere < MIN_SOUND_PRESSURE) //no sound reception in space, boyos
			volume = 0
		else
			volume = min( volume * atmosphere / ONE_ATMOSPHERE, volume) //sound can't be amplified from low to high pressure, but can be reduced
		/// end ///

	if (istext(soundin))
		soundin = get_sfx(soundin)

	var/sound/S = soundin
	S.wait = 0 // No queue.
	S.channel = 0 // Any channel.
	S.volume = volume

	if (vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)
		var/dx = turf_source.x - T.x // Hearing from the right/left

		S.x = round(max(-SURROUND_CAP, min(SURROUND_CAP, dx)), 1)

		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = round(max(-SURROUND_CAP, min(SURROUND_CAP, dz)), 1)

		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	src << S

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(sound_name)
	var/sound = sounds[sound_name]

	if (islist(sound))
		sound = pick(sound)

	return sound
