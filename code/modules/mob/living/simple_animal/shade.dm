/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 40
	health = 40
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

/mob/living/simple_animal/shade/New()
	..()
	add_language(LANGUAGE_CULT)

/mob/living/simple_animal/shade/death(var/gibbed = FALSE)
	var/turf/T = get_turf(src)
	if (T)
		playsound(T, get_sfx("soulstone"), 50,1)
	..(gibbed)

/mob/living/simple_animal/shade/Login()
	..()
	hud_used.shade_hud()
	if (istype(loc, /obj/item/weapon/melee/soulblade))
		client.CAN_MOVE_DIAGONALLY = 1
		client.screen += list(
			gui_icons.soulblade_bgLEFT,
			gui_icons.soulblade_coverLEFT,
			gui_icons.soulblade_bloodbar,
			)

/mob/living/simple_animal/shade/say(var/message)
	. = ..(message, "C")

/mob/living/simple_animal/shade/gib()
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
				SB.blood = min(SB.maxblood,SB.blood+5)//faster blood regen when planted on an altar
			if (SB.health < SB.maxHealth)
				SB.health = min(SB.maxHealth,SB.health+5)//and health regen on top
		else if (istype(SB.loc,/mob/living))
			var/mob/living/L = SB.loc
			if (iscultist(L) && SB.blood < SB.maxblood)
				SB.blood++//no cap on blood regen when held by a cultist, no blood regen when held by a non-cultist (but there's a spell to take care of that)
		else if (SB.blood < SB.maxregenblood)
			SB.blood++


/mob/living/simple_animal/shade/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	user.delayNextAttack(8)
	if(istype(O, /obj/item/device/soulstone) || istype(O, /obj/item/weapon/melee/soulblade))
		O.transfer_soul("SHADE", src, user)
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
	return

/mob/living/simple_animal/shade/shuttle_act()
	if(!(src.flags & INVULNERABLE))
		health -= rand(5,45) //These guys are like ghosts, a collision with a shuttle wouldn't destroy one outright
	return

/mob/living/simple_animal/shade/examine(mob/user)
	..()
	if(!client)
		to_chat(user, "<span class='warning'>It appears to be dormant.</span>")

////////////////HUD//////////////////////

/mob/living/simple_animal/shade/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()

	regular_hud_updates()

/mob/living/simple_animal/shade/regular_hud_updates()
	update_pull_icon() //why is this here?

	if(istype(loc, /obj/item/weapon/melee/soulblade) && hud_used && gui_icons && gui_icons.soulblade_bloodbar)
		var/obj/item/weapon/melee/soulblade/SB = loc
		if(fire)
			switch(SB.health)
				if (-INFINITY to 18)
					fire.icon_state = "blade_reallynotok"
				if (18 to 36)
					fire.icon_state = "blade_notok"
				if (36 to INFINITY)
					fire.icon_state = "blade_ok"
		var/matrix/M = matrix()
		M.Scale(1,SB.blood/SB.maxblood)
		var/total_offset = (60 + (100*(SB.blood/SB.maxblood))) * PIXEL_MULTIPLIER
		hud_used.mymob.gui_icons.soulblade_bloodbar.transform = M
		hud_used.mymob.gui_icons.soulblade_bloodbar.screen_loc = "WEST,CENTER-[8-round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE]"
		hud_used.mymob.gui_icons.soulblade_coverLEFT.maptext = "[SB.blood]"

	if(purged)
		if(purge > 0)
			purged.icon_state = "purge1"
		else
			purged.icon_state = "purge0"

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

/mob/living/simple_animal/shade/happiest/death(var/gibbed = FALSE)
	..(TRUE)
	transmogrify()
	if(!gcDestroyed)
		qdel(src)

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

	if(suicide_set)
		suiciding = TRUE

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
