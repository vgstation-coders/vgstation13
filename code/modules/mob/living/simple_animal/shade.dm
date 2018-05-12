/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 1
	stop_automated_movement = TRUE
	status_flags = 0
	faction = "cult"
	status_flags = CANPUSH
	supernatural = TRUE
	flying = TRUE
	meat_type = /obj/item/weapon/ectoplasm
	mob_property_flags = MOB_SUPERNATURAL

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


/mob/living/simple_animal/shade/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	user.delayNextAttack(8)
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("SHADE", src, user)
	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			if(istype(O,/obj/item/weapon/nullrod))
				damage *= 2
				purge = 3
			health -= damage
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='warning'> <B>[src] has been attacked with [O] by [user].</span></B>")
		else
			to_chat(usr, "<span class='warning'> This weapon is ineffective, it does no damage.</span>")
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='warning'> [user] gently taps [src] with [O].</span>")
	return

/mob/living/simple_animal/shade/shuttle_act()
	if(!(src.flags & INVULNERABLE))
		health -= rand(5,45) //These guys are like ghosts, a collision with a shuttle wouldn't destroy one outright
	return

////////////////HUD//////////////////////

/mob/living/simple_animal/shade/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()

	regular_hud_updates()

/mob/living/simple_animal/shade/regular_hud_updates()
	update_pull_icon() //why is this here?

	if(purged)
		if(purge > 0)
			purged.icon_state = "purge1"
		else
			purged.icon_state = "purge0"

	if(client)
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
