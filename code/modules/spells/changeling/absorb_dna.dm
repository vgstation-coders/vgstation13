/spell/changeling/absorbdna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human. They become one with us, and we become stronger."
	abbreviation = "AD"
	hud_state = "absorbdna"
	
	spell_flags = NEEDSHUMAN

	

/spell/changeling/absorbdna/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)

	//You need to be grabbing the target
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T))					//Humans only
		to_chat(user, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return
	if(M_NOCLONE in T.mutations)	//No double-absorbing
		to_chat(user, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return
	if(!T.mind)						//No monkeymen
		to_chat(user, "<span class='warning'>This creature's DNA is useless to us!</span>")
		return

	if(G.state != GRAB_KILL)		//Kill-Grabs only
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	if(changeling.isabsorbing)
		to_chat(user, "<span class='warning'>We are already absorbing!</span>")
		return
	changeling.isabsorbing = 1

	for(var/stage = 1, stage<=3, stage++)
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
				if(affecting.take_damage(39,0,1,"large organic needle"))
					T.UpdateDamageIcon(1)


		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, T, 150))
			to_chat(user, "<span class='warning'>Our absorption of [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(user, "<span class='notice'>We have absorbed [T]!</span>")
	user.visible_message("<span class='danger'>[user] sucks the fluids from [T]!</span>")
	to_chat(T, "<span class='danger'>You have been absorbed by the changeling!</span>")
	playsound(user, 'sound/effects/lingabsorbs.ogg', 50, 1)
	add_attacklogs(user, T, "absorbed")

	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	T.dna.flavor_text = T.flavor_text
	changeling.absorbed_dna |= T.dna


	var/avail_blood = T.vessel.get_reagent_amount(BLOOD)
	for(var/datum/reagent/blood/B in user.vessel.reagent_list)
		B.volume = min(BLOOD_VOLUME_MAX, avail_blood + B.volume)

	if(user.nutrition < 400)
		user.nutrition = min((user.nutrition + T.nutrition), 400)

	changeling.chem_charges += 10
	changeling.powerpoints += 2

	//Steal all of their languages!
	changeling.absorbed_languages |= T.languages

	user.changeling_update_languages(changeling.absorbed_languages)

	//Steal their memories! (using this instead of mind.store_memory so the lings own notes and stuff are always at the bottom)
	var/newmemory = "<BR><B>[T.real_name]'s memories:</B><BR><BR>[T.mind.memory]__________________________<BR><BR>[user.mind.memory]"
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
	changeling.isabsorbing = 0
	user.updateChangelingHUD()

	T.death(0)
	T.Drain()

	..()
