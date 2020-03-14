/obj/item/device/roganbot
	name = "ROGANbot"
	desc = "A sound synthetizer with 38 preset phrases. To activate, say a number from 1 to 38 out loud."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = W_CLASS_TINY
	flags = HEAR | FPRINT
	var/speak_cooldown = 0.6 SECONDS
	var/tmp/last_speak

/obj/item/device/roganbot/Hear(var/datum/speech/speech, var/rendered_speech="")
	set waitfor = 0 //Should be queued after the original speech completes
	if(last_speak + speak_cooldown >= world.timeofday)
		return
	for(var/index in number2rogansound)
		if(speech.message == "[index]" || dd_hasprefix(speech.message, "[index] "))
			playtaunt(number2rogansound[index])

/obj/item/device/roganbot/proc/playtaunt(var/datum/rogan_sound/S)
	playsound(get_turf(src), S.soundfile, 35, FALSE)
	if(S.transcript)
		say(S.transcript)
	else if(S.emote)
		src.visible_message("<b>\The [src]</b> [S.emote]") //simplified from emotes.dm which is only for mobs
	last_speak = world.timeofday

var/global/list/number2rogansound = list() //populated by /proc/make_datum_references_lists()

/datum/rogan_sound
	var/number
	var/transcript
	var/emote
	var/soundfile

/datum/rogan_sound/taunt1
	number = "1"
	transcript = "Yes."
	soundfile = 'sound/effects/aoe2/01 yes.ogg'

/datum/rogan_sound/taunt2
	number = "2"
	transcript = "No."
	soundfile = 'sound/effects/aoe2/02 no.ogg'

/datum/rogan_sound/taunt3
	number = "3"
	transcript = "Food, please."
	soundfile = 'sound/effects/aoe2/03 food, please.ogg'

/datum/rogan_sound/taunt4
	number = "4"
	transcript = "Wood, please."
	soundfile = 'sound/effects/aoe2/04 wood, please.ogg'

/datum/rogan_sound/taunt5
	number = "5"
	transcript = "Gold, please."
	soundfile = 'sound/effects/aoe2/05 gold, please.ogg'

/datum/rogan_sound/taunt6
	number = "6"
	transcript = "Stone, please."
	soundfile = 'sound/effects/aoe2/06 stone, please.ogg'

/datum/rogan_sound/taunt7
	number = "7"
	transcript = "Ahh!"
	soundfile = 'sound/effects/aoe2/07 ahh.ogg'

/datum/rogan_sound/taunt8
	number = "8"
	transcript = "All hail, king of the losers!"
	soundfile = 'sound/effects/aoe2/08 all hail.ogg'

/datum/rogan_sound/taunt9
	number = "9"
	transcript = "Oooh!"
	soundfile = 'sound/effects/aoe2/09 oooh.ogg'

/datum/rogan_sound/taunt10
	number = "10"
	transcript = "I'll beat you back to Age of Empires."
	soundfile = 'sound/effects/aoe2/10 back to age 1.ogg'

/datum/rogan_sound/taunt11
	number = "11"
	emote = "laughs raucously."
	soundfile = 'sound/effects/aoe2/11 herb laugh.ogg'

/datum/rogan_sound/taunt12
	number = "12"
	transcript = "AHH! Being rushed!"
	soundfile = 'sound/effects/aoe2/12 being rushed.ogg'

/datum/rogan_sound/taunt13
	number = "13"
	transcript = "Sure, blame it on your ISP."
	soundfile = 'sound/effects/aoe2/13 blame your isp.ogg'

/datum/rogan_sound/taunt14
	number = "14"
	transcript = "START THE GAME ALREADY!"
	soundfile = 'sound/effects/aoe2/14 start the game.ogg'

/datum/rogan_sound/taunt15
	number = "15"
	transcript = "Don't point that thing at me!"
	soundfile = 'sound/effects/aoe2/15 dont point that thing.ogg'

/datum/rogan_sound/taunt16
	number = "16"
	transcript = "Enemy sighted."
	soundfile = 'sound/effects/aoe2/16 enemy sighted.ogg'

/datum/rogan_sound/taunt17
	number = "17"
	transcript = "It is good to be the King."
	soundfile = 'sound/effects/aoe2/17 it is good.ogg'

/datum/rogan_sound/taunt18
	number = "18"
	transcript = "Monk! I need a monk!"
	soundfile = 'sound/effects/aoe2/18 i need a monk.ogg'

/datum/rogan_sound/taunt19
	number = "19"
	transcript = "Long time, no siege."
	soundfile = 'sound/effects/aoe2/19 long time no siege.ogg'

/datum/rogan_sound/taunt20
	number = "20"
	transcript = "My granny could scrap better than that."
	soundfile = 'sound/effects/aoe2/20 my granny.ogg'

/datum/rogan_sound/taunt21
	number = "21"
	transcript = "Nice town. I'll take it."
	soundfile = 'sound/effects/aoe2/21 nice town ill take it.ogg'

/datum/rogan_sound/taunt22
	number = "22"
	transcript = "Quit touchin' me!"
	soundfile = 'sound/effects/aoe2/22 quit touchin.ogg'

/datum/rogan_sound/taunt23
	number = "23"
	transcript = "Raiding party!"
	soundfile = 'sound/effects/aoe2/23 raiding party.ogg'

/datum/rogan_sound/taunt24
	number = "24"
	transcript = "Dadgum."
	soundfile = 'sound/effects/aoe2/24 dadgum.ogg'

/datum/rogan_sound/taunt25
	number = "25"
	transcript = "Ehh, smite me."
	soundfile = 'sound/effects/aoe2/25 smite me.ogg'

/datum/rogan_sound/taunt26
	number = "26"
	transcript = "The wonder... the wonder... the... no!"
	soundfile = 'sound/effects/aoe2/26 the wonder.ogg'

/datum/rogan_sound/taunt27
	number = "27"
	transcript = "You played 2 hours to die like this?"
	soundfile = 'sound/effects/aoe2/27 you play 2 hours.ogg'

/datum/rogan_sound/taunt28
	number = "28"
	transcript = "Yeah, well, you should see the other guy."
	soundfile = 'sound/effects/aoe2/28 you should see the other guy.ogg'

/datum/rogan_sound/taunt29
	number = "29"
	transcript = "Rogan?"
	soundfile = 'sound/effects/aoe2/29 rogan.ogg'

/datum/rogan_sound/taunt30
	number = "30"
	transcript = "Wololo..."
	soundfile = 'sound/effects/aoe2/30 wololo.ogg'

/datum/rogan_sound/taunt31
	number = "31"
	transcript = "Attack an enemy now."
	soundfile = 'sound/effects/aoe2/31 attack an enemy now.ogg'

/datum/rogan_sound/taunt32
	number = "32"
	transcript = "Cease creating extra villagers."
	soundfile = 'sound/effects/aoe2/32 cease creating extra villagers.ogg'

/datum/rogan_sound/taunt33
	number = "33"
	transcript = "Create extra villagers."
	soundfile = 'sound/effects/aoe2/33 create extra villagers.ogg'

/datum/rogan_sound/taunt34
	number = "34"
	transcript = "Build a navy."
	soundfile = 'sound/effects/aoe2/34 build a navy.ogg'

/datum/rogan_sound/taunt35
	number = "35"
	transcript = "Stop building a navy."
	soundfile = 'sound/effects/aoe2/35 stop building a navy.ogg'

/datum/rogan_sound/taunt36
	number = "36"
	transcript = "Wait for my signal to attack."
	soundfile = 'sound/effects/aoe2/36 wait for my signal to attack.ogg'

/datum/rogan_sound/taunt37
	number = "37"
	transcript = "Build a wonder."
	soundfile = 'sound/effects/aoe2/37 build a wonder.ogg'

/datum/rogan_sound/taunt38
	number = "38"
	transcript = "Give me your extra resources."
	soundfile = 'sound/effects/aoe2/38 give me your extra resources.ogg'
