/spell/changeling/absorbdna
	name = "Absorb DNA"
	desc = "Permits us to siphon the DNA from a human. They become one with us, and we become stronger."
	abbreviation = "AD"
	hud_state = "absorbdna"
	spell_flags = NEEDSHUMAN
	horrorallowed = 0

	charge_max = 5 SECONDS
	cooldown_min = 5 SECONDS

/spell/changeling/absorbdna/cast_check(skipcharge = 0,mob/user = usr, var/list/targets)
	. = ..()
	if (!.)
		return FALSE

	var/obj/item/weapon/grab/G = user.get_active_hand() //You need to be grabbing the target

	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return FALSE

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T))					//Humans only
		to_chat(user, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return FALSE
	if(M_HUSK in T.mutations)	//No double-absorbing
		to_chat(user, "<span class='warning'>This creature's DNA is ruined beyond usability!</span>")
		return FALSE
	if(!T.mind)						//No monkeymen
		to_chat(user, "<span class='warning'>This creature's DNA is useless to us!</span>")
		return FALSE
	if(G.state != GRAB_KILL)		//Kill-Grabs only
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return FALSE
	if (T.dna == user.dna)
		to_chat(user, "<span class='warning'>We have already absorbed their DNA.</span>")
		return FALSE
	if(inuse)
		return FALSE

/spell/changeling/absorbdna/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/obj/item/weapon/grab/G = user.get_active_hand() //You need to be grabbing the target
	var/mob/living/carbon/human/T = G.affecting
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	var/absorbtime = 15 SECONDS
	inuse = TRUE
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We extend a proboscis.</span>")
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
				playsound(user, 'sound/effects/lingextends.ogg', 50, 1)
			if(3)
				to_chat(user, "<span class='notice'>We stab [T] with the proboscis.</span>")
				user.visible_message("<span class='danger'>[user] stabs [T] with the proboscis!</span>")
				to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				playsound(user, 'sound/effects/lingstabs.ogg', 50, 1)
				var/datum/organ/external/affecting = T.get_organ(user.zone_sel.selecting)
				if(affecting.take_damage(39,0,1, 0,"large organic needle"))
					T.UpdateDamageIcon(1)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, T, absorbtime))
			to_chat(user, "<span class='warning'>Our absorption of [T] has been interrupted!</span>")
			return
	usr.add_blood(T)

	to_chat(user, "<span class='notice'>We have absorbed [T]!</span>")
	user.visible_message("<span class='danger'>[user] sucks the fluids from [T]!</span>")
	to_chat(T, "<span class='danger'>You have been absorbed by the changeling!</span>")
	playsound(user, 'sound/effects/lingabsorbs.ogg', 50, 1)
	add_attacklogs(user, T, "absorbed")

	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	T.dna.flavor_text = T.flavor_text
	changeling.absorbed_dna |= T.dna

	//Steal their wellbeing!
	if(user.nutrition < 400)
		user.nutrition = min((user.nutrition + T.nutrition), 400)
	user.health = user.maxHealth
	changeling.powerpoints += 3

	//Steal all of their languages!
	changeling.absorbed_languages |= T.languages
	user.changeling_update_languages(changeling.absorbed_languages)

	//Steal their memories! (using this instead of mind.store_memory so the lings own notes and stuff are always at the bottom)
	var/newmemory = "<BR><B>[T.real_name]'s memories:</B><BR><BR>[T.mind.memory]<BR><BR><B>[user.real_name]'s memories:</B><BR><BR>[user.mind.memory]"
	user.mind.memory = newmemory

	//Steal their species!
	if(T.species)
		changeling.absorbed_species |= T.species.name

	if(T.mind)
		var/datum/role/changeling/Tchangeling = T.mind.GetRole(CHANGELING)

		if(Tchangeling)
			if(Tchangeling.absorbed_dna)
				for(var/dna_data in Tchangeling.absorbed_dna)
					if(dna_data in changeling.absorbed_dna)
						continue
					changeling.absorbed_dna += dna_data
					changeling.absorbedcount++
					Tchangeling.absorbed_dna.Remove(dna_data)

			if(Tchangeling.current_powers.len)
				for(var/datum/power/changeling/Tp in Tchangeling.current_powers)
					if(locate(Tp.type) in changeling.current_powers)
						continue
					else
						Tp.add_power(changeling)

			user.make_changeling()
			changeling.chem_charges += Tchangeling.chem_charges
			changeling.powerpoints += Tchangeling.powerpoints
			Tchangeling.chem_charges = 0
			Tchangeling.powerpoints = 0
			Tchangeling.absorbedcount = 0
	changeling.absorbedcount++
	user.updateChangelingHUD()

	T.death(0)
	T.ChangeToHusk()

	..()

/spell/changeling/absorbdna/after_cast(list/targets,var/mob/living/carbon/human/user)
	inuse = FALSE
