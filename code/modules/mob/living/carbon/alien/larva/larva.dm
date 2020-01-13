/mob/living/carbon/alien/larva
	name = "alien larva" //The alien larva, not 'Alien Larva'
	real_name = "alien larva"
	icon_state = "larva0"
	status_flags = CANSTUN|UNPACIFIABLE
	pass_flags = PASSTABLE

	maxHealth = 25
	health = 25
	plasma = 50
	max_plasma = 50
	size = SIZE_TINY

	var/growth = 0
	var/time_of_birth

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]
	..()

	add_spell(new /spell/aoe_turf/alien_hide, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/evolve/larva, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)

//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [growth]/[LARVA_GROW_TIME]")

/mob/living/carbon/alien/larva/AdjustPlasma(amount)
	if(stat != DEAD)
		growth = min(growth + 1, LARVA_GROW_TIME)
	..(amount)


/mob/living/carbon/alien/larva/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flash_eyes(visual = TRUE)

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if(1)
			b_loss += 500
			gib()
			return
		if(2)
			b_loss += 60
			f_loss += 60
			ear_damage += 30
			ear_deaf += 120
		if(3)
			b_loss += 30
			if(prob(50))
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)
	updatehealth()

/mob/living/carbon/alien/larva/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat == DEAD)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	var/shielded = FALSE

	var/damage = null
	if(stat != DEAD)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	to_chat(src, "<span class='warning'>The blob attacks you !</span>")

	adjustFireLoss(damage)
	updatehealth()
	return

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

//using the default attack_animal() in carbon.dm

/mob/living/carbon/alien/larva/attack_paw(mob/living/carbon/monkey/M)
	if(!(istype(M, /mob/living/carbon/monkey)))
		return //Fix for aliens receiving double messages when attacking other aliens.

	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)
		else
			M.unarmed_attack_mob(src)
	return


/mob/living/carbon/alien/larva/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)

	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)

		if(I_GRAB)
			M.grab_mob(src)

		else
			M.unarmed_attack_mob(src)

/mob/living/carbon/alien/larva/restrained()
	if(timestopped)
		return TRUE //under effects of time magick

	return FALSE

/mob/living/carbon/alien/larva/var/co2overloadtime = null
/mob/living/carbon/alien/larva/var/temperature_resistance = T0C+75

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/alien/larva/show_inv(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(handcuffed)
		dat += "<BR><B>Bodycuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/alien/larva/reset_layer()
	if(stat == DEAD)
		plane = MOB_PLANE

/mob/living/carbon/alien/larva/proc/transfer_personality(var/client/candidate)
	ckey = candidate.ckey
	src << sound('sound/voice/alienspawn.ogg')
	if(src.mind)
		src.mind.assigned_role = "Alien"
