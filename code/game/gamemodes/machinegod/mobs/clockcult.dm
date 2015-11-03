#define MA_INACTIVE 0
#define MA_ACTIVE   1

#define MA_OWNER contractor.current

#define CM_ATK 0
#define CM_DEF 1

/mob/living/simple_animal/clockcult
	name = "Construct"
	real_name = "Construct"
	desc = ""
	speak_emote = list("clicks")
	emote_hear = list("groans","ticks")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon_dead = "shade_dead"
	speed = -1
	a_intent = I_HURT
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/spiderlunge.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	show_stat_health = 0
	faction = "clockcult"
	supernatural = 1
	var/nullblock = 0

	mob_swap_flags = HUMAN|SIMPLE_ANIMAL|SLIME|MONKEY
	mob_push_flags = ALLMOBS

	var/list/clockcult_spells = list()

/mob/living/simple_animal/clockcult/proc/clockcult_chat_check(var/setting)
	if(!mind) return

	if(mind in ticker.mode.clockcult)
		return 1

/mob/living/simple_animal/clockcult/handle_inherent_channels(message, message_mode, var/datum/language/speaking)
	if(..())
		return 1
	if(message_mode == MODE_HEADSET && clockcult_chat_check(0))
		var/turf/T = get_turf(src)
		log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Clockcult channel: [message]")
		for(var/mob/M in mob_list)
			if(M.clockcult_chat_check(2) /*receiving check*/ || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
				M << "<span class='clockcult'><b>[src.name]:</b> [message]</span>"
		return 1

/mob/living/simple_animal/clockcult/cultify()
	return

/mob/living/simple_animal/clockcult/New()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	add_language(LANGUAGE_CLOCKCULT)
	default_language = all_languages[LANGUAGE_CLOCKCULT]
	for(var/spell in clockcult_spells)
		src.add_spell(new spell, "clock_spell_ready")
	updateicon()

/mob/living/simple_animal/clockcult/Die()
	..()
	//new refuse item (src.loc)
	for(var/mob/M in viewers(src, null))
		if((M.client && !( M.blinded )))
			M.show_message("<span class='warning'>[src] collapses in a shattered heap. </span>")
	ghostize()
	del src
	return

/mob/living/simple_animal/clockcult/examine(mob/user)
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] <EM>Revenant Warrior [src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It appears somewhat exhausted.\n"
		else
			msg += "<B>It looks about ready to collapse!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/clockcult/attack_animal(mob/living/simple_animal/M as mob)
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.attacktext] [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.attacktext] by [M.name] ([M.ckey])</font>")
	if(M.melee_damage_upper <= 0)
		M.emote("[M.friendly] \the <EM>[src]</EM>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
		add_logs(M, src, "attacked", admin=1)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)

/mob/living/simple_animal/clockcult/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	//if(istype(O, replicafabricator))
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		if(istype(O,/obj/item/weapon/nullrod))
			damage *= 2
			purge = 3
		adjustBruteLoss(damage)
		visible_message("<span class='danger'>[src] has been attacked with [O] by [user].</span>")
	else
		usr << "<span class='warning'>This weapon is ineffective, it does no damage.</span>"
		visible_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")



/mob/living/simple_animal/clockcult/bound_revenant
	name = "bound revenant"
	real_name = "bound revenant"
	desc = ""
	response_help  = "nudges"
	response_disarm = "uses its shield to swat"
	response_harm   = "cuts"

	icon = 'code\WorkInProgress\VelardAmakar\mobs.dmi'
	icon_state = "revenant_atk"
	icon_living = "revenant_atk"
	health = 180
	maxHealth = 180
	faction = "machinegod"
	attacktext = "slashes"
	melee_damage_lower = 15
	melee_damage_upper = 15
	speed = 2
	attack_sound = 'sound/weapons/bladeslice.ogg'

	var/list/revnames = list("Thneq", "Fuvryq", "Qrsraq", "Xavtug", "Svtugre", "Nezberq-Ureb", "Ehfu", "Uhagre", "Znegle", "Punfre", "Chavfu", "Urnil")
	var/cmrate = 5	//chance for combat mastery to proc
	var/cmtype = 1	//0=offensive(bash), 1=defensive(counter)
	var/datum/mind/contractor = null
	var/contractor_dying = 0 //prevents warning spam

/mob/living/simple_animal/clockcult/bound_revenant/New()
	..()
	name = text("[rand(revnames)]")
	real_name = name


/mob/living/simple_animal/clockcult/bound_revenant/Life()

	//Health
	if(active == MA_INACTIVE)
		health += 2
	else
		health -= 1
	if(!src in range(7,contractor.current))
		health -= 5

	if(health < 1 && stat != DEAD)
		desummon()

	if(health > maxHealth)
		health = maxHealth

	if(stunned)
		AdjustStunned(-1)
	if(weakened)
		AdjustWeakened(-1)
	if(paralysis)
		AdjustParalysis(-1)

	if(contractor.current.stat == UNCONSCIOUS && !contractor_dying)
		src << "<span class='sinister'>You feel the bond between you and [contractor.current] grow weak.</span>"
		contractor_dying = 1
	else if(contractor.current.stat == CONSCIOUS)
		contractor_dying = 0

	return 1

/mob/living/simple_animal/bound_revenant/proc/desummon(var/expelled = 0)
	health = min(0, health)
	//return to sender

/mob/living/simple_animal/bound_revenant/Die()
	return

/mob/living/simple_animal/bound_revenant/gib()
	return

/mob/living/simple_animal/bound_revenant/verb/toggle_mastery()
	set name = "Toggle Combat Mastery"
	set desc = "Switches between offensive and defensive states."
	set category = "Cult"

	if(cm_type == CM_ATK)
		cm_type = CM_DEF
		//flick(src, atk -> def)
	else
		cm_type = CM_ATK
		//flick(src, def -> ark)

	cm_rate = 5
	icon_state = "revenant_[cm_type ? def : atk]"
	src << "<span class='[cmtype ? bnotice : danger]'>You switch into \a [cmtype ? defensive : offensive] fighting stance.</span>"

/mob/living/simple_animal/bound_revenant/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		var/damage = O.force
		if(O.damtype == HALLOSS)
			damage = 0
		if(istype(O,/obj/item/weapon/nullrod))
			damage *= 2
			purge = 3
		adjustBruteLoss(damage)
		visible_message("<span class='danger'>[src] has been attacked with [O] by [user].</span>")
		if(cmtype == 2 && !purge)
			cmastery(2)
	else
		usr << "<span class='warning'>This weapon is ineffective, it does no damage.</span>"
		visible_message("<span class='warning'>[user] gently taps [src] with \the [O].</span>")

/mob/living/simple_animal/bound_revenant/examine()
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] <EM>Revenant Warrior [src.name]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It appears somewhat exhausted.\n"
		else
			msg += "<B>It looks about ready to collapse!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/bound_revenant/ex_act(severity)
	..()
	switch (severity)
		if(1.0)
			if(cmtype == CM_DEF && prob(5+cmrate))
				adjustBruteLoss(100)
				src << "<span class='warning'>You manage to partially block the intense blastwave!</span>"
				cmrate = 5
			else
				adjustBruteLoss(300)
				src << "<span class='danger'>The explosion disrupts your physical manifestation!</span>"

		if(2.0)
			if(cmtype == CM_DEF && prob(45+cmrate))
				adjustBruteLoss(25)
				src << "<span class='warning'>You manage to partially block the blastwave!</span>"
				cmrate = 5
			else
				adjustBruteLoss(60)
				src << "<span class='danger'>The explosion greatly disrupts your physical manifestation!</span>"

		if(3.0)
			if(cmtype == CM_DEF && prob(65+cmrate))
				adjustBruteLoss(10)
				src << "<span class='warning'>You manage to partially block the blastwave!</span>"
				cmrate = 5
			else
				adjustBruteLoss(30)
				src << "<span class='danger'>The explosion slightly disrupts your physical manifestation!</span>"

/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	if(cmtype == CM_DEF && prob(65 - round(P.damage/2)))
		adjustBruteLoss(P.damage * 0.5)
		visible_message("<span class='danger'>[src] deflects \the [P.name] with its shield!</span>", \
						"<span class='userdanger'>[src] deflects \the [P.name] with its shield!</span>")

		// Find a turf near or on the original location to bounce to
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
			var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
			var/turf/curloc = get_turf(src)

			// redirect the projectile
			P.original = locate(new_x, new_y, P.z)
			P.starting = curloc
			P.current = curloc
			P.firer = src
			P.yo = new_y - curloc.y
			P.xo = new_x - curloc.x

		return -1 // complete projectile permutation

	return (..(P))

#undef MA_INACTIVE
#undef MA_ACTIVE

#undef MA_OWNER

#undef CM_ATK
#undef CM_DEF