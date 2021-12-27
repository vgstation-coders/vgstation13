/obj/item/device/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1

	var/tmp/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
	var/selected_sound = 'sound/items/bikehorn.ogg'
	var/shiftpitch = TRUE
	var/default_shiftpitch = TRUE
	var/volume = 50
	var/default_volume = 50

	var/list/sound_list = list(
		"Honk" = list("selected_sound"='sound/items/bikehorn.ogg'),
		"Applause" = list("selected_sound"='sound/effects/applause.ogg',"volume"=65),
		"Laughter" = list("selected_sound"='sound/effects/laughtrack.ogg',"volume"=65),
		"Rimshot" = list("selected_sound"='sound/effects/rimshot.ogg',"volume"=65),
		"Trombone" = list("selected_sound"='sound/misc/sadtrombone.ogg'),
		"Airhorn" = list("selected_sound"='sound/items/AirHorn.ogg'),
		"Alert" = list("selected_sound"='sound/effects/alert.ogg'),
		"Awooga" = list("selected_sound"='sound/effects/awooga.ogg'),
		"Boom" = list("selected_sound"='sound/effects/Explosion1.ogg'),
		"Boom from Afar" = list("selected_sound"='sound/effects/explosionfar.ogg'),
		"Bubbles" = list("selected_sound"='sound/effects/bubbles.ogg'),
		"Construction Noises" = list("selected_sound"='sound/items/Deconstruct.ogg',"volume"=60),
		"Countdown" = list("selected_sound"='sound/ambience/countdown.ogg',"shiftpitch"=FALSE,"volume"=55),
		"Creepy Whisper" = list("selected_sound"='sound/hallucinations/turn_around1.ogg'),
		"Ding" = list("selected_sound"='sound/machines/ding.ogg'),
		"Double Beep" = list("selected_sound"='sound/machines/twobeep.ogg'),
		"Flush" = list("selected_sound"='sound/machines/disposalflush.ogg',"volume"=40),
		"Kawaii" = list("selected_sound"='sound/AI/animes.ogg',"shiftpitch"=FALSE,"volume"=60),
		"Startup" = list("selected_sound"='sound/mecha/nominal.ogg',"shiftpitch"=FALSE),
		"Welding Noises" = list("selected_sound"='sound/items/Welder.ogg',"volume"=55),
		"Quack" = list("selected_sound"='sound/items/quack.ogg'),
		"Short Slide Whistle" = list("selected_sound"='sound/effects/slide_whistle_short.ogg'),
		"Long Slide Whistle" = list("selected_sound"='sound/effects/slide_whistle_long.ogg'),
		"YEET" = list("selected_sound"='sound/effects/yeet.ogg'),
		"Time Stop" = list("selected_sound"='sound/effects/theworld3.ogg',"shiftpitch"=FALSE,"volume"=80),
		"Click" = list("selected_sound"='sound/effects/kirakrik.ogg',"shiftpitch"=FALSE,"volume"=80),
		"SPS" = list("selected_sound"='sound/items/fake_SPS.ogg',"shiftpitch"=FALSE,"volume"=100)
	)

/obj/item/device/soundsynth/New()
	..()
	shiftpitch = default_shiftpitch
	volume = default_volume

/obj/item/device/soundsynth/verb/pick_sound()
	set category = "Object"
	set name = "Select Sound Playback"
	var/thesoundthatwewant = input("Pick a sound:", null) as null|anything in sound_list
	if(!thesoundthatwewant)
		return
	to_chat(usr, "Sound playback set to: [thesoundthatwewant]!")
	set_sound(thesoundthatwewant)

/obj/item/device/soundsynth/proc/set_sound(var/thesoundthatwewant)
	var/list/assblast = sound_list[thesoundthatwewant]
	if(assblast && assblast["selected_sound"])
		selected_sound = assblast["selected_sound"]
		if(assblast["shiftpitch"])
			shiftpitch = assblast["shiftpitch"]
		else
			shiftpitch = default_shiftpitch
		if(assblast["volume"])
			volume = assblast["volume"]
		else
			volume = default_volume

/obj/item/device/soundsynth/attack_self(mob/user as mob)
	if(spam_flag + 2 SECONDS < world.timeofday)
		play()
		spam_flag = world.timeofday

/obj/item/device/soundsynth/proc/play()
	playsound(src, selected_sound, volume, shiftpitch)

/obj/item/device/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user)
		pick_sound()
	else if(spam_flag + 2 SECONDS < world.timeofday)
		M.playsound_local(get_turf(src), selected_sound, volume, shiftpitch)
		spam_flag = world.timeofday
		//to_chat(M, selected_sound) //this doesn't actually go to their chat very much at all.

/obj/item/device/soundsynth/AltClick()
	if(!usr.incapacitated() && Adjacent(usr))
		pick_sound()
		return
	return ..()
