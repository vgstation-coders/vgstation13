/datum/reagent/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	description = "Dylovene is a broad-spectrum antitoxin."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/anti_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom

	if(!holder) return
	M.drowsyness = max(M.drowsyness-2*REM, 0)
	if(holder.has_reagent("toxin"))
		holder.remove_reagent("toxin", 2*REM)
	if(holder.has_reagent("stoxin"))
		holder.remove_reagent("stoxin", 2*REM)
	if(holder.has_reagent("plasma"))
		holder.remove_reagent("plasma", 1*REM)
	if(holder.has_reagent("sacid"))
		holder.remove_reagent("sacid", 1*REM)
	if(holder.has_reagent("cyanide"))
		holder.remove_reagent("cyanide", 1*REM)
	if(holder.has_reagent("amatoxin"))
		holder.remove_reagent("amatoxin", 2*REM)
	if(holder.has_reagent("chloralhydrate"))
		holder.remove_reagent("chloralhydrate", 5*REM)
	if(holder.has_reagent("carpotoxin"))
		holder.remove_reagent("carpotoxin", 1*REM)
	if(holder.has_reagent("zombiepowder"))
		holder.remove_reagent("zombiepowder", 0.5*REM)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 2*REM)
	M.hallucination = max(0, M.hallucination - 5*REM)
	M.adjustToxLoss(-2*REM)
	..()
	return

/datum/reagent/phalanximine
	name = "Phalanximine"
	id = "phalanximine"
	description = "Phalanximine is a powerful chemotherapy agent."
	reagent_state = LIQUID
	color = "#1A1A1A" // rgb:idk

/datum/reagent/phalanximine/on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		M.adjustToxLoss(-2*REM)
		M.apply_effect(4*REM,IRRADIATE,0)
		..()
		return



/datum/reagent/srejuvenate
	name = "Soporific Rejuvenant"
	id = "stoxin2"
	description = "Put people to sleep, and heals them."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/srejuvenate/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-10)
	holder.remove_reagent(src.id, 0.2)
	switch(data)
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.sleeping += 1
			M.adjustOxyLoss(-M.getOxyLoss())
			M.SetWeakened(0)
			M.SetStunned(0)
			M.SetParalysis(0)
			M.dizziness = 0
			M.drowsyness = 0
			M.stuttering = 0
			M.confused = 0
			M.jitteriness = 0
	..()
	return

/datum/reagent/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE*2
	shock_reduction = 25

/datum/reagent/inaprovaline/on_mob_life(var/mob/living/M as mob, var/alien)

	if(!holder) return
	if(!M) M = holder.my_atom

	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REAGENTS_METABOLISM)
	else
		if(M.losebreath >= 10)
			M.losebreath = max(10, M.losebreath-5)

	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	return


/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/serotrotium/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(ishuman(M))
		if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
		holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)
	return



/datum/reagent/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/ryetalyn/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom

	var/needs_update = M.mutations.len > 0
	if(ishuman(M))
		M:hulk_time = 0
	for(var/datum/dna/gene/G in dna_genes)
		if(G.is_active(M))
			if(G.name == "Hulk" && ishuman(M))
				G.OnMobLife(M)
			G.deactivate(M)
	M.alpha = 255
	M.mutations = list()
	M.active_genes = list()

	M.disabilities = 0
	M.sdisabilities = 0

	//Makes it more obvious that it worked.
	M.jitteriness = 0

	// Might need to update appearance for hulk etc.
	if(needs_update && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_mutations()

	..()
	return



/datum/reagent/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
	reagent_state = LIQUID
	color = "#C855DC"
	overdose_threshold = 0
	shock_reduction = 50

/datum/reagent/paracetamol/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(ishuman(M))
		M:shock_stage--
		M:traumatic_shock--

/datum/reagent/tramadol
	name = "Tramadol"
	id = "tramadol"
	description = "A simple, yet effective painkiller."
	reagent_state = LIQUID
	color = "#C8A5DC"
	shock_reduction = 80

/datum/reagent/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	description = "An effective and very addictive painkiller."
	reagent_state = LIQUID
	color = "#C805DC"
	shock_reduction = 200

/datum/reagent/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19

/datum/reagent/virus_food/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor*REM
	..()
	return

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
/*
/datum/reagent/sterilizine/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if (method==TOUCH)
		if(istype(M, /mob/living/carbon/human))
			if(M.health >= -100 && M.health <= 0)
				M.crit_op_stage = 0.0
	if (method==INGEST)
		usr << "Well, that was stupid."
		M.adjustToxLoss(3)
	return

/datum/reagent/sterilizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
		M.radiation += 3
		..()
		return
*/



/datum/reagent/leporazine
	name = "Leporazine"
	id = "leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/leporazine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return



/datum/reagent/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/lexorin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	if(prob(33))
		M.take_organ_damage(1*REM, 0)
	M.adjustOxyLoss(3)
	if(prob(20)) M.emote("gasp")
	..()
	return

/datum/reagent/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Kelotane is a drug used to treat burns."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/kelotane/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	M.heal_organ_damage(0,2*REM)
	..()
	return

/datum/reagent/dermaline
	name = "Dermaline"
	id = "dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/dermaline/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
		return
	if(!M) M = holder.my_atom
	M.heal_organ_damage(0,3*REM)
	..()
	return

/datum/reagent/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/dexalin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0)
		return  //See above, down and around. --Agouri
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-2*REM)
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()
	return

/datum/reagent/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/dexalinp/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-M.getOxyLoss())
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()
	return

/datum/reagent/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/tricordrazine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	if(M.getOxyLoss() && prob(80)) M.adjustOxyLoss(-1*REM)
	if(M.getBruteLoss() && prob(80)) M.heal_organ_damage(1*REM,0)
	if(M.getFireLoss() && prob(80)) M.heal_organ_damage(0,1*REM)
	if(M.getToxLoss() && prob(80)) M.adjustToxLoss(-1*REM)
	..()
	return

/datum/reagent/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/adminordrazine/on_mob_life(var/mob/living/carbon/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom ///This can even heal dead people.
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_organ_damage(5,5)
	M.adjustToxLoss(-5)
	if(holder.has_reagent("toxin"))
		holder.remove_reagent("toxin", 5)
	if(holder.has_reagent("stoxin"))
		holder.remove_reagent("stoxin", 5)
	if(holder.has_reagent("plasma"))
		holder.remove_reagent("plasma", 5)
	if(holder.has_reagent("sacid"))
		holder.remove_reagent("sacid", 5)
	if(holder.has_reagent("pacid"))
		holder.remove_reagent("pacid", 5)
	if(holder.has_reagent("cyanide"))
		holder.remove_reagent("cyanide", 5)
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 5)
	if(holder.has_reagent("amatoxin"))
		holder.remove_reagent("amatoxin", 5)
	if(holder.has_reagent("chloralhydrate"))
		holder.remove_reagent("chloralhydrate", 5)
	if(holder.has_reagent("carpotoxin"))
		holder.remove_reagent("carpotoxin", 5)
	if(holder.has_reagent("zombiepowder"))
		holder.remove_reagent("zombiepowder", 5)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
//				M.disabilities &= ~NEARSIGHTED		//doesn't even do anythig cos of the disabilities = 0 bit
//				M.sdisabilities &= ~BLIND			//doesn't even do anythig cos of the sdisabilities = 0 bit
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.sleeping = 0
	M.jitteriness = 0
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	..()
	return

/datum/reagent/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat various diseases."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose_threshold = REAGENTS_OVERDOSE
	shock_reduction = 40

/datum/reagent/synaptizine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(60))	M.adjustToxLoss(1)
	..()
	return

/datum/reagent/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/impedrezene/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80)) M.adjustBrainLoss(1*REM)
	if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
	if(prob(10)) M.emote("drool")
	..()
	return

/datum/reagent/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/hyronalin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.radiation = max(M.radiation-3*REM,0)
	..()
	return

/datum/reagent/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/arithrazine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.stat == 2.0)
		return  //See above, down and around. --Agouri
	if(!M) M = holder.my_atom
	M.radiation = max(M.radiation-7*REM,0)
	M.adjustToxLoss(-1*REM)
	if(prob(15))
		M.take_organ_damage(1, 0)
	..()
	return

/datum/reagent/alkysine
	name = "Alkysine"
	id = "alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_threshold = REAGENTS_OVERDOSE
	shock_reduction = 10

/datum/reagent/alkysine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustBrainLoss(-3*REM)
	..()
	return

/datum/reagent/imidazoline
	name = "Imidazoline"
	id = "imidazoline"
	description = "Heals eye damage"
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/imidazoline/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.eye_blurry = max(M.eye_blurry-5 , 0)
	M.eye_blind = max(M.eye_blind-5 , 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if(E && istype(E))
			if(E.damage > 0)
				E.damage -= 1
	..()
	return

/datum/reagent/inacusiate
	name = "Inacusiate"
	id = "inacusiate"
	description = "Rapidly heals ear damage"
	reagent_state = LIQUID
	color = "#6600FF" // rgb: 100, 165, 255
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/inacusiate/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.ear_damage = 0
	M.ear_deaf = 0
	..()
	return

/datum/reagent/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 10

/datum/reagent/peridaxon/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/chest/C = H.get_organ("chest")
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.damage > 0)
				I.damage -= 0.20
	..()
	return

/datum/reagent/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/bicaridine/on_mob_life(var/mob/living/M as mob, var/alien)

	if(!holder) return
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	if(alien != IS_DIONA)
		M.heal_organ_damage(2*REM,0)
	..()
	return



/datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/cryoxadone/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-1)
		M.heal_organ_damage(1,1)
		M.adjustToxLoss(-1)
	..()
	return

/datum/reagent/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/clonexadone/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)
	..()
	return

/datum/reagent/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/rezadone/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	switch(data)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_organ_damage(1,1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_organ_damage(2,1)
			M.status_flags &= ~DISFIGURED
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)

	..()
	return

/datum/reagent/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antiviral agent."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/spaceacillin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	return



/datum/reagent/ethylredoxrazine						// FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72

/datum/reagent/ethylredoxrazine/on_mob_life(var/mob/living/M as mob)
	if(!holder) return
	if(!M) M = holder.my_atom
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	..()
	return

/datum/reagent/lipozine
	name = "Lipozine" // The anti-nutriment.
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#BBEDA4" // rgb: 187, 237, 164

/datum/reagent/lipozine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.nutrition -= nutriment_factor
	M.overeatduration = 0
	if(M.nutrition < 0)//Prevent from going into negatives.
		M.nutrition = 0
	..()
	return
