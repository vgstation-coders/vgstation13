/obj/item/device/assembly/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = 1.0
	flags = FPRINT
	siemens_coefficient = 1

	starting_materials = list(MAT_IRON = 550, MAT_GLASS = 750)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"

	var/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.

	var/sound_flag = 0
	var/list/sounds = list(
		"Honk" = 'sound/items/bikehorn.ogg',
		"Bubbles" = 'sound/effects/bubbles.ogg',
		"Explosion" = 'sound/effects/Explosion1.ogg',
		"Startup" = 'sound/mecha/nominal.ogg',
		"Alert" = 'sound/effects/alert.ogg',
		"Airhorn" = 'sound/items/AirHorn.ogg',
		"Trombone" = 'sound/misc/sadtrombone.ogg',
		"Construction noises" = 'sound/items/Deconstruct.ogg',
		"Welding noises" = 'sound/items/Welder.ogg',
		"Creepy whisper" = 'sound/hallucinations/turn_around1.ogg',
		"Ding" = 'sound/machines/ding.ogg',
		"Awooga" = 'sound/effects/awooga.ogg',
		"Flush" = 'sound/machines/disposalflush.ogg',
		"Double beep" = 'sound/machines/twobeep.ogg',
		"Rimshot" = 'sound/effects/rimshot.ogg',
		"Laughter" = 'sound/effects/laughtrack.ogg',
		"Applause" = 'sound/effects/applause.ogg')
/*
This is to cycle sounds forward
*/
/obj/item/device/assembly/soundsynth/verb/CycleForward()
	set category = "Object"
	set name = "Cycle Sound Forward"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/device/soundsynth/verb/CycleForward()  called tick#: [world.time]")
	sound_flag++
	if(sound_flag >= sounds.len)
		sound_flag = 0

	if(sounds[sound_flag+1])
		usr << "Sound switched to [sounds[sound_flag+1]]!"
	else
		usr << "<span class='notice'>[src]'s screen displays ERROR #[sound_flag]</span>"

/*
And backwards
*/
/obj/item/device/assembly/soundsynth/verb/CycleBackward()
	set category = "Object"
	set name = "Cycle Sound Backward"

	sound_flag--
	if(sound_flag < 0)
		sound_flag = sounds.len - 1

	if(sounds[sound_flag+1])
		usr << "Sound switched to [sounds[sound_flag+1]]!"
	else
		usr << "<span class='notice'>[src]'s screen displays ERROR #[sound_flag]</span>"

/obj/item/device/assembly/soundsynth/proc/play()
	if(spam_flag + 20 < world.timeofday)
		if(sounds[sound_flag+1])
			var/sound_to_play = sounds[sound_flag+1]

			spam_flag = world.timeofday
			playsound(get_turf(src), sounds[sound_to_play], 50, 1)


/obj/item/device/assembly/soundsynth/activate()
	return play()



/obj/item/device/assembly/soundsynth/attack_self(mob/user as mob)
	return play()

/obj/item/device/assembly/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user) //If you target yourself, cycle sound forward
		return src.CycleForward()
	else
		if(spam_flag + 20 < world.timeofday)
			if(sounds[sound_flag+1])
				var/sound_to_play = sounds[sound_flag+1]

				spam_flag = world.timeofday
				M << sound(sounds[sound_to_play])

			user << "<span class='notice'>You hold up \the [src] up to [M]'s ear and hit \"Play\"!</span>"
			M.show_message("<span class='notice'>[user] holds up \the [src] up to your ear and plays a sound.</span>", 1)
