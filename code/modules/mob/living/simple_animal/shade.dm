/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade"
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 8
	melee_damage_upper = 8
	attacktext = "torments"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 1
	stop_automated_movement = TRUE
	faction = "cult"
	status_flags = CANPUSH
	supernatural = TRUE
	flying = TRUE
	meat_type = /obj/item/weapon/ectoplasm
	mob_property_flags = MOB_SUPERNATURAL
	var/space_damage_warned = FALSE
	var/blade_harm = TRUE
	var/mob/master = null

	blooded = FALSE

/mob/living/simple_animal/shade/New()
	..()
	add_language(LANGUAGE_CULT)
	add_language(LANGUAGE_GALACTIC_COMMON)
	default_language = all_languages[LANGUAGE_CULT]
	init_language = default_language

/mob/living/simple_animal/shade/death(var/gibbed = FALSE)
	var/turf/T = get_turf(src)
	if (T)
		playsound(T, get_sfx("soulstone"), 50,1)
	..(gibbed)

/mob/living/simple_animal/shade/Login()
	..()
	if (istype(loc, /obj/item/weapon/melee/soulblade))
		client.CAN_MOVE_DIAGONALLY = 1
	to_chat(src,"<span class='notice'>To be understood by non-cult speaking humans, use :1.</span>")

/mob/living/simple_animal/shade/say(var/message)
	. = ..(message, "C")

/mob/living/simple_animal/shade/gib(var/animation = 0, var/meat = 1)
	if(status_flags & BUDDHAMODE)
		adjustBruteLoss(200)
		return
	if(!isUnconscious())
		forcesay("-")
	death(TRUE)
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/shade/cultify()
	return

/mob/living/simple_animal/shade/Life()
	if(timestopped)
		return FALSE //under effects of time magick
	..()
	regular_hud_updates()
	standard_damage_overlay_updates()
	if(isDead())
		for(var/i=0;i<3;i++)
			new /obj/item/weapon/ectoplasm (src.loc)
		visible_message("<span class='warning'> [src] lets out a contented sigh as their form unwinds.</span>")
		ghostize()
		qdel (src)
		return

	if (istype(loc,/obj/item/weapon/melee/soulblade))
		var/obj/item/weapon/melee/soulblade/SB = loc
		if (istype(SB.loc,/obj/structure/cult/altar))
			if (SB.blood < SB.maxblood)
				SB.blood = min(SB.maxblood,SB.blood+10)//fastest blood regen when planted on an altar
			if (SB.health < SB.maxHealth)
				SB.health = min(SB.maxHealth,SB.health+10)//and health regen on top
		else if (istype(SB.loc,/mob/living))
			var/mob/living/L = SB.loc
			if (iscultist(L) && SB.blood < SB.maxblood)
				SB.blood = min(SB.maxblood,SB.blood+3)//fast blood regen when held by a cultist (stacks with the one below for an effective +5)
		if (SB.linked_cultist && (get_dist(get_turf(SB.linked_cultist),get_turf(src)) <= 5))
			SB.blood = min(SB.maxblood,SB.blood+2)//slow blood regen when near your linked cultist
		if (SB.passivebloodregen < (SB.blood/3))
			SB.passivebloodregen++
		if ((SB.passivebloodregen >= (SB.blood/3)) && (SB.blood < SB.maxblood))
			SB.passivebloodregen = 0
			SB.blood++//very slow passive blood regen that goes slower and slower the more blood you currently have.
		SB.update_icon()
	else
		if (istype(loc,/turf/space))
			if (!space_damage_warned)
				space_damage_warned = TRUE
				to_chat(src,"<span class='danger'>Your ghostly form suffers from the star's radiations. Remaining in space will slowly erase you.</span>")
			adjustBruteLoss(1)

/mob/living/simple_animal/shade/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	user.delayNextAttack(8)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/stone = O
		stone.capture_shade(src, user)
	else if (istype(O, /obj/item/weapon/melee/soulblade))
		var/obj/item/weapon/melee/soulblade/blade = O
		blade.capture_shade(src, user)
	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			if(isholyweapon(O))
				damage *= 2
				purge = 3
			adjustBruteLoss(damage)
			O.on_attack(src, user)
			visible_message("<span class='warning'> <B>[src] has been attacked with [O] by [user].</span></B>")
		else
			to_chat(usr, "<span class='warning'> This weapon is ineffective, it does no damage.</span>")
			visible_message("<span class='warning'> [user] gently taps [src] with [O].</span>")

/mob/living/simple_animal/shade/shuttle_act()
	if(!(src.flags & INVULNERABLE))
		health -= rand(5,45) //These guys are like ghosts, a collision with a shuttle wouldn't destroy one outright

/mob/living/simple_animal/shade/examine(mob/user)
	..()
	if(!client)
		to_chat(user, "<span class='warning'>It appears to be dormant.</span>")

////////////////HUD//////////////////////

/mob/living/simple_animal/shade/regular_hud_updates()
	update_pull_icon() //why is this here?

	if(istype(loc, /obj/item/weapon/melee/soulblade) && hud_used)
		var/obj/item/weapon/melee/soulblade/SB = loc
		if(healths2)
			switch(SB.health)
				if(-INFINITY to 18)
					healths2.icon_state = "blade_reallynotok"
				if(18 to 36)
					healths2.icon_state = "blade_notok"
				if(36 to INFINITY)
					healths2.icon_state = "blade_ok"

		DisplayUI("Soulblade")

	if(client && hud_used && healths)
		switch(health)
			if(50 to INFINITY)
				healths.icon_state = "shade_health0"
			if(41 to 49)
				healths.icon_state = "shade_health1"
			if(33 to 40)
				healths.icon_state = "shade_health2"
			if(25 to 32)
				healths.icon_state = "shade_health3"
			if(17 to 24)
				healths.icon_state = "shade_health4"
			if(9 to 16)
				healths.icon_state = "shade_health5"
			if(1 to 8)
				healths.icon_state = "shade_health6"
			else
				healths.icon_state = "shade_health7"

/mob/living/simple_animal/shade/noncult/happiest/death(var/gibbed = FALSE)
	..(TRUE)
	transmogrify()
	if(!gcDestroyed)
		qdel(src)

/mob/living/simple_animal/shade/gondola
	name = "Gondola Shade"
	real_name = "Gondola Shade"
	desc = "A wandering spirit."
	icon = 'icons/mob/gondola.dmi'
	icon_state = "gondola_shade"
	icon_living = "gondola_shade"
	icon_dead = "gondola_skull"

/mob/living/simple_animal/shade/gondola/say()
	return



///////////////////////////////CHAOS SWORD STUFF///////////////////////////////////////////////////

/mob/living/simple_animal/shade/sword/attempt_suicide(forced = FALSE, suicide_set = TRUE)
	if(!forced)
		var/confirm = alert("Are you sure you want to seal your ego? This action cannot be undone and your current knowledge will be lost forever.", "Confirm Suicide", "Yes", "No")

		if(!confirm == "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't perform the sealing ritual in this state!</span>")
			return

		log_attack("<span class='danger'>[key_name(src)] has sealed itself via the suicide verb.</span>")

	if(suicide_set && mind)
		mind.suiciding = TRUE

	visible_message("<span class='danger'>[src] shudders violently for a moment, then becomes motionless, its aura fading and eyes slowly darkening.</span>")
	death()

/mob/living/simple_animal/shade/sword/death(var/gibbed = FALSE)
	if(istype(loc, /obj/item/weapon/nullrod/sword/chaos))
		var/obj/item/weapon/nullrod/sword/chaos/C = loc
		C.possessed = FALSE
		C.icon_state = "talking_sword"
	..(gibbed)

////////////////////////////////SOUL BLADE STUFF//////////////////////////////////////////////////////
/mob/living/simple_animal/shade/ClickOn(var/atom/A, var/params)
	if (istype(loc, /obj/item/weapon/melee/soulblade))
		var/obj/item/weapon/melee/soulblade/SB = loc
		SB.dir = get_dir(get_turf(SB), A)
		var/spell/soulblade/blade_spin/BS = locate() in spell_list
		if (BS)
			BS.perform(src)
			return
	..()

/mob/living/simple_animal/shade/noncult
	desc = "A bound spirit. This one appears more in tune with the realm of the dead."
	universal_understand = 1 //They're closer to their observer selves, hence can understand any language
	faction = "neutral"
	icon_state = "ghost-narsie"
	icon_living = "ghost-narsie"

/mob/living/simple_animal/shade/noncult/New()
	..()
	remove_language(LANGUAGE_CULT)
