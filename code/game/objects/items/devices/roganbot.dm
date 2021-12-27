/obj/item/device/soundsynth/roganbot
	name = "ROGANbot"
	desc = "A sound synthetizer with 38 preset phrases. To activate, say a number from 1 to 38 out loud."
	flags = HEAR | FPRINT
	selected_sound = 'sound/effects/aoe2/29 rogan.ogg'
	default_shiftpitch = FALSE
	default_volume = 35
	var/current_phrase = "Rogan?"
	var/emote_phrase = FALSE
	var/default_emote = FALSE
	var/speak_cooldown = 0.6 SECONDS
	var/tmp/last_speak
	var/mobsonly = TRUE //Fuck off speaker assemblies

	sound_list = list(
		"Yes." = list("say"=1,"selected_sound"='sound/effects/aoe2/01 yes.ogg'),
		"No." = list("say"=2,"selected_sound"='sound/effects/aoe2/02 no.ogg'),
		"Food, please." = list("say"=3,"selected_sound"='sound/effects/aoe2/03 food, please.ogg'),
		"Wood, please." = list("say"=4,"selected_sound"='sound/effects/aoe2/04 wood, please.ogg'),
		"Gold, please." = list("say"=5,"selected_sound"='sound/effects/aoe2/05 gold, please.ogg'),
		"Stone, please." = list("say"=6,"selected_sound"='sound/effects/aoe2/06 stone, please.ogg'),
		"Ahh!" = list("say"=7,"selected_sound"='sound/effects/aoe2/07 ahh.ogg'),
		"All hail, king of the losers!" = list("say"=8,"selected_sound"='sound/effects/aoe2/08 all hail.ogg'),
		"Oooh!" = list("say"=9,"selected_sound"='sound/effects/aoe2/09 oooh.ogg'),
		"I'll beat you back to Age of Empires." = list("say"=10,"selected_sound"='sound/effects/aoe2/10 back to age 1.ogg'),
		"laughs raucously." = list("say"=11,"emote"=TRUE,"selected_sound"='sound/effects/aoe2/11 herb laugh.ogg'),
		"AHH! Being rushed!" = list("say"=12,"selected_sound"='sound/effects/aoe2/12 being rushed.ogg'),
		"Sure, blame it on your ISP." = list("say"=13,"selected_sound"='sound/effects/aoe2/13 blame your isp.ogg'),
		"START THE GAME ALREADY!" = list("say"=14,"selected_sound"='sound/effects/aoe2/14 start the game.ogg'),
		"Don't point that thing at me!" = list("say"=15,"selected_sound"='sound/effects/aoe2/15 dont point that thing.ogg'),
		"Enemy sighted." = list("say"=16,"selected_sound"='sound/effects/aoe2/16 enemy sighted.ogg'),
		"It is good to be the King." = list("say"=17,"selected_sound"='sound/effects/aoe2/17 it is good.ogg'),
		"Monk! I need a monk!" = list("say"=18,"selected_sound"='sound/effects/aoe2/18 i need a monk.ogg'),
		"Long time, no siege." = list("say"=19,"selected_sound"='sound/effects/aoe2/19 long time no siege.ogg'),
		"My granny could scrap better than that." = list("say"=20,"selected_sound"='sound/effects/aoe2/20 my granny.ogg'),
		"Nice town. I'll take it." = list("say"=21,"selected_sound"='sound/effects/aoe2/21 nice town ill take it.ogg'),
		"Quit touchin' me!" = list("say"=22,"selected_sound"='sound/effects/aoe2/22 quit touchin.ogg'),
		"Raiding party!" = list("say"=23,"selected_sound"='sound/effects/aoe2/23 raiding party.ogg'),
		"Dadgum." = list("say"=24,"selected_sound"='sound/effects/aoe2/24 dadgum.ogg'),
		"Ehh, smite me." = list("say"=25,"selected_sound"='sound/effects/aoe2/25 smite me.ogg'),
		"The wonder... the wonder... the... no!" = list("say"=26,"selected_sound"='sound/effects/aoe2/26 the wonder.ogg'),
		"You played 2 hours to die like this?" = list("say"=27,"selected_sound"='sound/effects/aoe2/27 you play 2 hours.ogg'),
		"Yeah, well, you should see the other guy." = list("say"=28,"selected_sound"='sound/effects/aoe2/28 you should see the other guy.ogg'),
		"Rogan?" = list("say"=29,"selected_sound"='sound/effects/aoe2/29 rogan.ogg'),
		"Wololo..." = list("say"=30,"selected_sound"='sound/effects/aoe2/30 wololo.ogg'),
		"Attack an enemy now." = list("say"=31,"selected_sound"='sound/effects/aoe2/31 attack an enemy now.ogg'),
		"Cease creating extra villagers." = list("say"=32,"selected_sound"='sound/effects/aoe2/32 cease creating extra villagers.ogg'),
		"Create extra villagers." = list("say"=33,"selected_sound"='sound/effects/aoe2/33 create extra villagers.ogg'),
		"Build a navy." = list("say"=34,"selected_sound"='sound/effects/aoe2/34 build a navy.ogg'),
		"Stop building a navy." = list("say"=35,"selected_sound"='sound/effects/aoe2/35 stop building a navy.ogg'),
		"Wait for my signal to attack." = list("say"=36,"selected_sound"='sound/effects/aoe2/36 wait for my signal to attack.ogg'),
		"Build a wonder." = list("say"=37,"selected_sound"='sound/effects/aoe2/37 build a wonder.ogg'),
		"Give me your extra resources." = list("say"=38,"selected_sound"='sound/effects/aoe2/38 give me your extra resources.ogg'),
	)


/obj/item/device/soundsynth/roganbot/New()
	..()
	emote_phrase = default_emote

/obj/item/device/soundsynth/roganbot/Hear(var/datum/speech/speech, var/rendered_speech="")
	set waitfor = 0 //Should be queued after the original speech completes
	if(!speech.speaker || (mobsonly && !isliving(speech.speaker)))
		return
	if(last_speak + speak_cooldown >= world.timeofday)
		return
	for(var/phrase in sound_list)
		var/list/USA = sound_list[phrase]
		if(USA && USA["say"] && (speech.message == "[USA["say"]]" || dd_hasprefix(speech.message, "[USA["say"]] ")))
			set_sound(phrase)
			play()

/obj/item/device/soundsynth/roganbot/set_sound(var/thesoundthatwewant)
	..()
	var/list/USA = sound_list[thesoundthatwewant]
	if(USA && USA["selected_sound"] && USA["say"])
		current_phrase = thesoundthatwewant
		if(USA["emote"])
			emote_phrase = USA["emote"]
		else
			emote_phrase = default_emote

/obj/item/device/soundsynth/roganbot/play()
	..()
	if(emote_phrase)
		src.visible_message("<b>\The [src]</b> [current_phrase]") //simplified from emotes.dm which is only for mobs
	else
		say(current_phrase)
	last_speak = world.timeofday