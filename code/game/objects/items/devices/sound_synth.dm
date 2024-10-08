/obj/item/device/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	siemens_coefficient = 1
	flammable = TRUE

	var/tmp/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
	var/selected_sound = "sound/items/bikehorn.ogg"
	var/shiftpitch = 1
	var/volume = 50

	var/list/sound_list_emagged = list(
	"Blob Pulse" = "selected_sound=sound/effects/blob_pulse.ogg&shiftpitch=1&volume=100",
	"Conversion" = "selected_sound=sound/effects/convert_start.ogg&shiftpitch=1&volume=50",
	"Absorb" = "selected_sound=sound/effects/lingabsorbs.ogg&shiftpitch=1&volume=100",
	"Energy Sword" = "selected_sound=sound/weapons/blade1.ogg&shiftpitch=1&volume=100",
	"Super Fart" = "selected_sound=sound/effects/superfart.ogg&shiftpitch=1&volume=100",
	"Delamination Imminent" = "selected_sound=sound/AI/supermatter_delam.ogg&shiftpitch=0&volume=100",
	"'elite' Syndie Squad" = "selected_sound=sound/music/elite_syndie_squad.ogg&shiftpitch=0&volume=25",
	"'elite' NT Squad" = "selected_sound=sound/music/deathsquad.ogg&shiftpitch=0&volume=25",
	"Command Report" = "selected_sound=sound/AI/commandreport.ogg&shiftpitch=1&volume=100",
	"Wilhelm" = "selected_sound=sound/vox_sfx/_scream.ogg&shiftpitch=0&volume=100",
	"DOORSTUCK" = "selected_sound=sound/vox_sfx/_doorstuck.ogg&shiftpitch=0&volume=100"
	)

	var/list/sound_list = list( //How I would like to add tabbing to make this not as messy, but BYOND doesn't like that.
	"Honk" = "selected_sound=sound/items/bikehorn.ogg&shiftpitch=1&volume=50",
	"Applause" = "selected_sound=sound/effects/applause.ogg&shiftpitch=1&volume=65",
	"Laughter" = "selected_sound=sound/effects/laughtrack.ogg&shiftpitch=1&volume=65",
	"Rimshot" = "selected_sound=sound/effects/rimshot.ogg&shiftpitch=1&volume=65",
	"Trombone" = "selected_sound=sound/misc/sadtrombone.ogg&shiftpitch=1&volume=50",
	"Airhorn" = "selected_sound=sound/items/AirHorn.ogg&shiftpitch=1&volume=50",
    "Alert" = "selected_sound=sound/effects/alert.ogg&shiftpitch=1&volume=50",
    "Awooga" = "selected_sound=sound/effects/awooga.ogg&shiftpitch=1&volume=50",
    "Boom" = "selected_sound=sound/effects/Explosion1.ogg&shiftpitch=1&volume=50",
	"Boom from Afar" = "selected_sound=sound/effects/explosionfar.ogg&shiftpitch=1&volume=50",
    "Bubbles" = "selected_sound=sound/effects/bubbles.ogg&shiftpitch=1&volume=50",
    "Construction Noises" = "selected_sound=sound/items/Deconstruct.ogg&shiftpitch=1&volume=60",
	"Countdown" = "selected_sound=sound/ambience/countdown.ogg&shiftpitch=0&volume=55",
    "Creepy Whisper" = "selected_sound=sound/hallucinations/turn_around1.ogg&shiftpitch=1&volume=50",
    "Ding" = "selected_sound=sound/machines/ding.ogg&shiftpitch=1&volume=50",
    "Double Beep" = "selected_sound=sound/machines/twobeep.ogg&shiftpitch=1&volume=50",
    "Flush" = "selected_sound=sound/machines/disposalflush.ogg&shiftpitch=1&volume=40",
	"Kawaii" = "selected_sound=sound/AI/animes.ogg&shiftpitch=0&volume=60",
    "Startup" = "selected_sound=sound/mecha/nominal.ogg&shiftpitch=0&volume=50",
    "Welding Noises" = "selected_sound=sound/items/Welder.ogg&shiftpitch=1&volume=55",
	"Quack" = "selected_sound=sound/items/quack.ogg&shiftpitch=1&volume=50",
	"Short Slide Whistle" = "selected_sound=sound/effects/slide_whistle_short.ogg&shiftpitch=1&volume=50",
	"Long Slide Whistle" = "selected_sound=sound/effects/slide_whistle_long.ogg&shiftpitch=1&volume=50",
	"YEET" = "selected_sound=sound/effects/yeet.ogg&shiftpitch=1&volume=50",
	"Time Stop" = "selected_sound=sound/effects/theworld3.ogg&shiftpitch=0&volume=80",
	"Click" = "selected_sound=sound/effects/kirakrik.ogg&shiftpitch=0&volume=80",
	"SPS" = "selected_sound=sound/items/fake_SPS.ogg&shiftpitch=0&volume=100",
	"Dramatic" = "selected_sound=goon/sound/effects/dramatic.ogg&shiftpitch=0&volume=80"
	)

/obj/item/device/soundsynth/verb/pick_sound()
	set category = "Object"
	set name = "Select Sound Playback"
	var/thesoundthatwewant = input("Pick a sound:", null) as null|anything in sound_list
	if(!thesoundthatwewant)
		return
	to_chat(usr, "Sound playback set to: [thesoundthatwewant]!")
	var/list/assblast = params2list(sound_list[thesoundthatwewant])
	selected_sound = assblast["selected_sound"]
	shiftpitch = text2num(assblast["shiftpitch"])
	volume = text2num(assblast["volume"])

/obj/item/device/soundsynth/attack_self(mob/user as mob)
	if(spam_flag + 2 SECONDS < world.timeofday)
		playsound(src, selected_sound, volume, shiftpitch)
		spam_flag = world.timeofday

/obj/item/device/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user)
		pick_sound()
	else if(spam_flag + 2 SECONDS < world.timeofday)
		M.playsound_local(get_turf(src), selected_sound, volume, shiftpitch)
		spam_flag = world.timeofday
		//to_chat(M, selected_sound) //this doesn't actually go to their chat very much at all.

/obj/item/device/soundsynth/emag_act(mob/user)
	spark(src,5,FALSE)
	if(!emagged)
		emagged = 1
		sound_list = sound_list_emagged + sound_list
		selected_sound = "sound/effects/superfart.ogg"
		icon_state = "soundsynth-emagged"

/obj/item/device/soundsynth/examine(mob/user)
	..()
	if(emagged && user.is_holding_item(src))
		to_chat(user, "<span class='warning'>ERR%_m(mo4y corr?pt+d</span>")

/obj/item/device/soundsynth/AltClick()
	if(!usr.incapacitated() && Adjacent(usr))
		pick_sound()
		return
	return ..()
