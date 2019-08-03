/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	update_icon = TRUE

	species_type = /mob/living/carbon/alien/humanoid

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	add_spells_and_verbs()
	..()

/mob/living/carbon/alien/humanoid/proc/add_spells_and_verbs()
	add_spell(new /spell/aoe_turf/alienregurgitate, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/conjure/alienweeds, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/targeted/alienwhisper, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/targeted/alientransferplasma, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(flags & INVULNERABLE)
		return
	if(r_store)
		r_store.emp_act(severity)
	if(l_store)
		l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flash_eyes(visual = TRUE)

	var/shielded = FALSE

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if(1)
			b_loss += 500
			gib()
			return

		if(2)
			if(!shielded)
				b_loss += 60
			f_loss += 60
			ear_damage += 30
			ear_deaf += 120

		if(3)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(TRUE)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/alien/humanoid/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat == DEAD)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	var/shielded = FALSE
	var/damage = null
	if(stat != DEAD)
		damage = rand(30,40)

	if(shielded)
		damage /= 4

	to_chat(src, "<span class='warning'>The blob attacks you!</span>")


	adjustFireLoss(damage)

	return

/mob/living/carbon/alien/humanoid/attack_paw(mob/living/carbon/monkey/M)
	if(!ismonkey(M))
		return//Fix for aliens receiving double messages when attacking other aliens.

	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)
		else
			M.unarmed_attack_mob(src)
	return


/mob/living/carbon/alien/humanoid/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

//using the default attack_animal() in carbon.dm

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)

	..()

	switch(M.a_intent)

		if(I_HELP)
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				return TRUE
			else if(ishuman(M))
				M.perform_cpr(src)

		if(I_GRAB)
			return M.grab_mob(src)

		if(I_HURT)
			return M.unarmed_attack_mob(src)

		if(I_DISARM)
			if(!lying)
				M.do_attack_animation(src, M)
				if(prob(5)) //Very small chance to push an alien down.
					Knockdown(2)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has pushed down \the [src] !</span>")
				else
					if(prob(50))
						drop_item()
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						visible_message("<span class='danger'>[M] has disarmed \the [src] !</span>")
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						visible_message("<span class='danger'>[M] has attempted to disarm \the [src] !</span>")
	return


/mob/living/carbon/alien/humanoid/restrained()
	if(timestopped)
		return TRUE //under effects of time magick
	if (check_handcuffs())
		return TRUE
	return FALSE


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)
	user.set_machine(src)
	var/pickpocket = user.isGoodPickpocket()
	var/dat

	for(var/i = TRUE to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	if(pickpocket)
		dat += "<BR>[HTMLTAB]&#8627;<B>Pouches:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
	else
		dat += "<BR>[HTMLTAB]&#8627;<B>Pouches:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
		dat += "<BR>[HTMLTAB]&#8627;<B>ID:</B> <A href='?src=\ref[src];id=1'>[makeStrippingButton(wear_id)]</A>"

	if(handcuffed || mutual_handcuffs)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/alien/humanoid/Topic(href, href_list)
	. = ..()
	if(href_list["pockets"]) //href_list "pockets" would be "left" or "right"
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_pocket(usr, href_list["pockets"])

/mob/living/carbon/alien/humanoid/attack_icon()
	return image(icon = 'icons/mob/attackanims.dmi', icon_state = "alien")

/mob/living/carbon/alien/humanoid/base_movement_tally()
	. = ..()
	. += move_delay_add
