/datum/reagent/creatine
	name = "Creatine"
	id = "creatine"
	description = "Highly toxic substance that grants the user enormous strength, before their muscles seize and tear their own body to shreds."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255
	var/has_been_hulk=0
	var/has_ripped_and_torn=0 // We've applied permanent damage.
	var/hulked_at = 0 // World.time

	custom_metabolism=0.1

/datum/reagent/creatine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(volume)
		if(1 to 25)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)
			if(prob(5))
				M << "<span class='warning'>Oh god, the pain!</span>"
		if(25 to INFINITY)
			if(ishuman(M)) // Does nothing to non-humans.
				var/mob/living/carbon/human/H=M
				if(H.species.name!="Dionae") // Dionae are broken as fuck
					if(H.hulk_time<world.time && !has_been_hulk)
						H.hulk_time = world.time + (30 SECONDS)
						hulked_at = H.hulk_time
						if(!(M_HULK in H.mutations))
							has_been_hulk=1
							has_ripped_and_torn=0 // Fuck them UP after they dehulk.
							H.mutations.Add(M_HULK)
							H.update_mutations()		//update our mutation overlays
							H.update_body()
							message_admins("[key_name(M)] is TOO SWOLE TO CONTROL (on creatine)! ([formatJumpTo(M)])")
					else if(H.hulk_time<world.time && has_been_hulk) // TIME'S UP
						dehulk(H)
					else if(prob(1))
						H.say(pick("YOU TRYIN' BUILD SUM MUSSLE?","TOO SWOLE TO CONTROL","HEY MANG","HEY MAAAANG"))

	data++
	..()
	return

/datum/reagent/creatine/proc/dehulk(var/mob/living/carbon/human/H)
	if(has_been_hulk && !has_ripped_and_torn)
		H << "<span class='warning'>You feel like your muscles are ripping apart!</span>"
		has_ripped_and_torn=1
		holder.remove_reagent(src.id) // Clean them out
		H.adjustBruteLoss(200)        // Crit

		for(var/datum/organ/external/E in H.organs)
			if(istype(E, /datum/organ/external/chest))
				continue
			if(istype(E, /datum/organ/external/head))
				continue // Permit basket cases.
			if(prob(50))
				// Override the current limb status and don't cause an explosion
				E.droplimb(1,1)

		if(H.species)
			hgibs(H.loc, H.viruses, H.dna, H.species.flesh_color, H.species.blood_color)
		else
			hgibs(H.loc, H.viruses, H.dna)

		H.hulk_time=0 // Just to be sure.
		H.mutations.Remove(M_HULK)
		//M.dna.SetSEState(HULKBLOCK,0)
		H.update_mutations()		//update our mutation overlays
		H.update_body()