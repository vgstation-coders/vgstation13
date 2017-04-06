/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/clothing/head/head = null			//
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	update_icon = 1

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
	add_spell(new /spell/aoe_turf/alienregurgitate, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/conjure/alienweeds, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/targeted/alienwhisper, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/targeted/alientransferplasma, "alien_spell_ready", /obj/screen/movable/spell_master/alien)

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	if(wear_suit)
		wear_suit.emp_act(severity)
	if(head)
		head.emp_act(severity)
	if(r_store)
		r_store.emp_act(severity)
	if(l_store)
		l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flash_eyes(visual = 1)

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if(1.0)
			b_loss += 500
			gib()
			return

		if(2.0)
			if(!shielded)
				b_loss += 60
			f_loss += 60
			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(1)
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
	var/shielded = 0
	var/damage = null
	if(stat != 2)
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
				return 1
			else if(ishuman(M))
				M.perform_cpr(src)

		if(I_GRAB)
			return M.grab_mob(src)

		if(I_HURT)
			return M.unarmed_attack_mob(src)

		if(I_DISARM)
			if(!lying)
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
		return 1 //under effects of time magick
	if (handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)
	user.set_machine(src)
	var/pickpocket = user.isGoodPickpocket()
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>"}

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(head)]</A>"
	dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=[slot_wear_suit]'>[makeStrippingButton(wear_suit)]</A>"
	if(pickpocket)
		dat += "<BR><B>Left pouch:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
	else
		dat += "<BR><B>Right pouch:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
	dat += "<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A><BR>"

	user << browse(dat, text("window=mob\ref[src];size=340x480"))
	onclose(user, "mob\ref[src]")
	return

/mob/living/carbon/alien/humanoid/Topic(href, href_list)
	. = ..()
	if(href_list["pockets"]) //href_list "pockets" would be "left" or "right"
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_pocket(usr, href_list["pockets"])
