/obj/item/device/roganbot
	name = "ROGANbot"
	desc = "A sound synthetizer with 38 preset phrases. To activate, say a number from 1 to 38 out loud."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = HEAR | FPRINT
	flammable = TRUE
	var/speak_cooldown = 0.6 SECONDS
	var/tmp/last_speak
	var/mobsonly = TRUE //Fuck off speaker assemblies

/obj/item/device/roganbot/Hear(var/datum/speech/speech, var/rendered_speech="")
	set waitfor = 0 //Should be queued after the original speech completes
	if(!speech.speaker || (mobsonly && !isliving(speech.speaker)))
		return
	if(last_speak + speak_cooldown >= world.timeofday)
		return
	for(var/index in number2rogansound)
		if(speech.message == "[index]" || dd_hasprefix(speech.message, "[index] "))
			playtaunt(number2rogansound[index])

/obj/item/device/roganbot/proc/playtaunt(var/datum/rogan_sound/S)
	playsound(src, S.soundfile, 35, FALSE)
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

var/static/list/headshot_zones = list(LIMB_HEAD,TARGET_EYES,TARGET_MOUTH)

/obj/item/device/roganbot/killbot
	name = "KILLbot"
	desc = "A sound synthetizer with 38 preset phrases. To activate, say a number from 1 to 38 out loud. This one seems designed for an hero going for the high score."
	mech_flags = MECH_SCAN_ILLEGAL
	var/killcount = 0
	var/time_since_last_kill = 0
	var/fastkillcount = 0
	var/headshots = 0
	var/pickedup = FALSE

/obj/item/device/roganbot/killbot/examine(mob/user, size, show_name)
	. = ..()
	var/spantype = "notice"
	switch(killcount)
		if(1 to 14)
			spantype = "warning"
		if(15 to INFINITY)
			spantype = "danger"
	to_chat(user,"<span class='[spantype]'>The screen shows a kill streak of [killcount]!</span>")

/obj/item/device/roganbot/killbot/pickup(mob/user)
	. = ..()
	user.register_event(/event/kill, src, nameof(src::on_kill()))
	user.register_event(/event/death, src, nameof(src::kill_reset()))
	if(emergency_shuttle)
		emergency_shuttle.register_event(/event/shuttletimer, src, nameof(src::on_shuttle_time()))
	if(!pickedup)
		playsound(user.loc,'sound/effects/2003M/GoodLuckWarrior-3.ogg',100)
		say("Good luck, warrior.")
		pickedup = TRUE

/obj/item/device/roganbot/killbot/dropped(mob/user)
	. = ..()
	user.unregister_event(/event/kill, src, nameof(src::on_kill()))
	user.unregister_event(/event/death, src, nameof(src::kill_reset()))
	kill_reset()
	if(emergency_shuttle)
		emergency_shuttle.unregister_event(/event/shuttletimer, src, nameof(src::on_shuttle_time()))

/obj/item/device/roganbot/killbot/proc/on_kill(mob/killer,mob/victim)
	var/specialsoundplayed = FALSE
	killcount++
	if(!firstblood)
		playsound(killer.loc,'sound/effects/2003M/first_blood.ogg',100)
		say("FIRST BLOOD!")
		specialsoundplayed = TRUE
	if(!specialsoundplayed && istype(get_area(victim),/area/shuttle/arrival))
		playsound(killer.loc,'sound/effects/2003M/Spawn_Killer.ogg',100)
		say("SPAWN KILLER!")
		specialsoundplayed = TRUE
	if(!specialsoundplayed && killer.mind && killer.mind.antag_roles.len)
		for(var/datum/role/R in killer.mind.antag_roles)
			if(R.faction && (victim in R.faction.members))
				playsound(killer.loc,'sound/effects/2003M/Team_Killer.ogg',100)
				say("TEAM KILLER!")
				specialsoundplayed = TRUE
				break
	if(killer.zone_sel && (killer.zone_sel.selecting in headshot_zones) && istype(killer.get_active_hand(),/obj/item/weapon/gun))
		headshots++
		if(!specialsoundplayed)
			if(headshots == 15)
				playsound(killer.loc,'sound/effects/2003M/HeadHunter.ogg',100)
				say("HEAD HUNTER!")
				specialsoundplayed = TRUE
			else if(!fastkillcount && killcount % 5 != 0)
				playsound(killer.loc,'sound/effects/2003M/headshot.ogg',100)
				say("HEADSHOT!")
				specialsoundplayed = TRUE
	if((world.time - victim.timeofdeath < 3 SECONDS && world.time - time_since_last_kill < 3 SECONDS) || !time_since_last_kill)
		fastkillcount++
		if(!specialsoundplayed)
			switch(fastkillcount)
				if(2)
					playsound(killer.loc,'sound/effects/2003M/double_kill.ogg',100)
					say("DOUBLE KILL!")
				if(3)
					playsound(killer.loc,'sound/effects/2003M/triple_kill.ogg',100)
					say("TRIPLE KILL!")
				if(4)
					playsound(killer.loc,'sound/effects/2003M/multikill.ogg',100)
					say("MULTI KILL!")
				if(5)
					playsound(killer.loc,'sound/effects/2003M/ultrakill.ogg',100)
					say("ULTRA KILL!")
				if(6)
					playsound(killer.loc,'sound/effects/2003M/monster_kill.ogg',100)
					say("M-M-M-M-MONSTER KILL!")
				if(7)
					playsound(killer.loc,'sound/effects/2003M/LudicrousKill_F.ogg',100)
					say("L-L-L-L-LUDICROUS KILL!")
				if(8 to INFINITY)
					if(fastkillcount > 30 || fastkillcount % 5 != 0)
						playsound(killer.loc,'sound/effects/2003M/HolyShit_F.ogg',100)
						say("HOLY SHIT!")
			time_since_last_kill = world.time
			if(fastkillcount > 30 || fastkillcount < 8 || fastkillcount % 5 == 0)
				return
	else
		fastkillcount = 0
		time_since_last_kill = 0
	if(!specialsoundplayed)
		switch(killcount)
			if(5)
				playsound(killer.loc,'sound/effects/2003M/killing_spree.ogg',100)
				killer.visible_message("<span class='danger'>[killer] is on a KILLING SPREE!</span>")
			if(10)
				playsound(killer.loc,'sound/effects/2003M/rampage.ogg',100)
				killer.visible_message("<span class='danger'>[killer] is on a RAMPAGE!</span>")
			if(15)
				playsound(killer.loc,'sound/effects/2003M/dominating.ogg',100)
				killer.visible_message("<span class='danger'>[killer] is DOMINATING!</span>")
			if(20)
				playsound(killer.loc,'sound/effects/2003M/unstoppable.ogg',100)
				killer.visible_message("<span class='danger'>[killer] is UNSTOPPABLE!</span>")
			if(25)
				playsound(killer.loc,'sound/effects/2003M/Godlike.ogg',100)
				killer.visible_message("<span class='danger'>[killer] is GODLIKE!</span>")
			if(30)
				playsound(killer.loc,'sound/effects/2003M/WhickedSick.ogg',100)
				killer.visible_message("<span class='danger'>[killer] is WICKED SICK!</span>")

/obj/item/device/roganbot/killbot/proc/kill_reset(mob/user, body_destroyed)
	if(killcount)
		playsound(loc,'sound/effects/2003M/Reset.ogg',100)
		visible_message("<span class='danger'>[src] kill count reset!</span>")
	killcount = 0
	fastkillcount = 0
	time_since_last_kill = 0
	headshots = 0

/obj/item/device/roganbot/killbot/proc/on_shuttle_time(time,direction)
	switch(time)
		if(SHUTTLEGRACEPERIOD)
			playsound(loc,'sound/effects/2003M/5_minute_warning.ogg',100)
			say("Five minute warning!")
		if(240)
			playsound(loc,'sound/effects/2003M/4_minutes_remain.ogg',100)
			say("Four minutes remain!")
		if(SHUTTLELEAVETIME)
			playsound(loc,'sound/effects/2003M/3_minutes_remain.ogg',100)
			say("Three minutes remain!")
		if(SHUTTLEGRACEPERIOD)
			playsound(loc,'sound/effects/2003M/2_minutes_remain.ogg',100)
			say("Two minutes remain!")
		if(60)
			playsound(loc,'sound/effects/2003M/1_minute_remains.ogg',100)
			say("One minute remains!")
		if(30)
			playsound(loc,'sound/effects/2003M/30_seconds_remain.ogg',100)
			say("Thirty seconds remain!")
		if(20)
			playsound(loc,'sound/effects/2003M/20_seconds.ogg',100)
			say("Twenty seconds!")
		if(10)
			playsound(loc,'sound/effects/2003M/Ten.ogg',100)
			say("Ten!")
		if(9)
			playsound(loc,'sound/effects/2003M/Nine.ogg',100)
			say("Nine!")
		if(8)
			playsound(loc,'sound/effects/2003M/Eight.ogg',100)
			say("Eight!")
		if(7)
			playsound(loc,'sound/effects/2003M/Seven.ogg',100)
			say("Sever!")
		if(6)
			playsound(loc,'sound/effects/2003M/Six.ogg',100)
			say("Six!")
		if(5)
			playsound(loc,'sound/effects/2003M/Five.ogg',100)
			say("Five!")
		if(4)
			playsound(loc,'sound/effects/2003M/Four.ogg',100)
			say("Four!")
		if(3)
			playsound(loc,'sound/effects/2003M/Three.ogg',100)
			say("Three!")
		if(2)
			playsound(loc,'sound/effects/2003M/Two.ogg',100)
			say("Two!")
		if(1)
			playsound(loc,'sound/effects/2003M/One.ogg',100)
			say("One!")
		/*if(0)
			var/mob/M = get_holder_of_type(/mob)
			var/flawless_victory = FALSE
			var/failed_jectie = FALSE
			var/teamwon = FALSE
			if(M && M.mind && M.mind.antag_roles.len)
				for(var/datum/role/R in M.mind.antag_roles)
					if(R.faction && R.faction.IsSuccessful())
						teamwon = TRUE
					for(var/datum/objective/objective in R.objectives.GetObjectives())
						if(objective.flags & FREEFORM_OBJECTIVE)
							continue
						if(objective.IsFulfilled())
							flawless_victory = TRUE
						else
							flawless_victory = FALSE
							failed_jectie = TRUE
							break
					if(failed_jectie)
						break
			if(flawless_victory)
				playsound(loc,'sound/effects/2003M/Flawless_victory.ogg',100)
			else if(teamwon)
				playsound(loc,'sound/effects/2003M/You_have_won_the_match.ogg',100)
			else
				playsound(loc,'sound/effects/2003M/You_have_lost_the_match.ogg',100)*/
