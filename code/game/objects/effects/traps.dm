/obj/effect/trap
	name = "trap"

	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	var/delete_on_trigger = 1
	var/activated = 0

/obj/effect/trap/proc/activate(atom/movable/AM)
	return

/obj/effect/trap/proc/can_activate(atom/movable/AM)
	return (istype(AM, /mob/living/carbon) || istype(AM, /mob/living/silicon))

/obj/effect/trap/Crossed(atom/movable/AM)
	..()
	if(activated)
		return

	if(can_activate(AM))
		activated = 1
		activate(AM)

		if(delete_on_trigger)
			qdel(src)

/obj/effect/trap/New()
	..()
	invisibility = 101


//There are two ways to create an invisible object that plays a sound when you step on it
//First way is to use a narrator (/obj/effect/narration) and set its 'play_sound' var to the sound
//This will play the sound locally to everybody who steps on it, once

//The other way is to create a sound trap that only works once. The sound made by it will be heard by everybody nearby
/obj/effect/trap/sound
	name = "sound trap"
	desc = "JUMPSCARES best scares"

	var/sound_to_play
	var/volume = 50
	var/vary = 1

/obj/effect/trap/sound/activate(atom/movable/AM)
	if(sound_to_play)
		var/S

		if(istype(sound_to_play, /list))
			S = pick(sound_to_play)
		else
			S = sound_to_play

		playsound(src, S, volume, vary)
