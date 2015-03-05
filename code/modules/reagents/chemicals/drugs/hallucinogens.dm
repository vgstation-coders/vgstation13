

/datum/reagent/space_drugs
			name = "Space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as drug."
			reagent_state = LIQUID
			color = "#60A584" // rgb: 96, 165, 132
			overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/space_drugs/on_mob_life(var/mob/living/M as mob)
	if(!holder) return
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			if(prob(10)) step(M, pick(cardinal))
	if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	return



/datum/reagent/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen. Not a thing to be messed with."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233
	custom_metabolism = 0.05

/datum/reagent/mindbreaker/on_mob_life(var/mob/living/M)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.hallucination += 10
	..()
	return

/datum/reagent/spiritbreaker
	name = "Spiritbreaker Toxin"
	id = "spiritbreaker"
	description = "An extremely dangerous hallucinogen often used for torture. Extracted from the leaves of the rare Ambrosia Cruciatus plant."
	reagent_state = LIQUID
	color = "3B0805" // rgb: 59, 8, 5
	custom_metabolism = 0.05

/datum/reagent/spiritbreaker/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	var/sbreak = rand(150,180)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	if(data >= sbreak)
		M.adjustToxLoss(0.2)
		M.adjustBrainLoss(5)
		M.hallucination += 100
		M.dizziness += 100
		M.confused += 2
	data++
	return ..()

/datum/reagent/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231

/datum/reagent/psilocybin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 30)
	if(!data) data = 1
	switch(data)
		if(1 to 5)
			if (!M.stuttering) M.stuttering = 1
			M.Dizzy(5)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(10)
			M.Dizzy(10)
			M.druggy = max(M.druggy, 35)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 40)
			if(prob(30)) M.emote(pick("twitch","giggle"))
	holder.remove_reagent(src.id, 0.2)
	data++
	..()

