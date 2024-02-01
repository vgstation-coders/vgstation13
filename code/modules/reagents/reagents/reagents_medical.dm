//Medical reagents, including toxins

//An OP chemical for admins and detecting exploits
/datum/reagent/adminordrazine
	name = "Adminordrazine"
	id = ADMINORDRAZINE
	description = "It's magic. We don't have to explain it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = ARBITRARILY_LARGE_NUMBER
	specheatcap = ARBITRARILY_LARGE_NUMBER

/datum/reagent/adminordrazine/on_mob_life(var/mob/living/carbon/M)
	if(..())
		return 1

	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.rad_tick = 0
	M.radiation = 0
	M.heal_organ_damage(5,5)
	M.adjustToxLoss(-5)
	if(holder.has_any_reagents(TOXINS))
		holder.remove_reagents(TOXINS, 5)
	if(holder.has_any_reagents(STOXINS))
		holder.remove_reagents(STOXINS, 5)
	if(holder.has_reagent(PLASMA))
		holder.remove_reagent(PLASMA, 5)
	if(holder.has_any_reagents(SACIDS))
		holder.remove_reagents(SACIDS, 5)
	if(holder.has_any_reagents(PACIDS))
		holder.remove_reagent(PACIDS, 5)
	if(holder.has_reagent(CYANIDE))
		holder.remove_reagent(CYANIDE, 5)
	if(holder.has_any_reagents(LEXORINS))
		holder.remove_reagents(LEXORINS, 5)
	if(holder.has_reagent(AMATOXIN))
		holder.remove_reagent(AMATOXIN, 5)
	if(holder.has_reagent(CHLORALHYDRATE))
		holder.remove_reagent(CHLORALHYDRATE, 5)
	if(holder.has_reagent(CARPOTOXIN))
		holder.remove_reagent(CARPOTOXIN, 5)
	if(holder.has_reagent(ZOMBIEPOWDER))
		holder.remove_reagent(ZOMBIEPOWDER, 5)
	if(holder.has_reagent(MINDBREAKER))
		holder.remove_reagent(MINDBREAKER, 5)
	if(holder.has_reagent(SPIRITBREAKER))
		holder.remove_reagent(SPIRITBREAKER, 5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	M.SetKnockdown(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.sleeping = 0
	M.remove_jitter()
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	for(var/A in M.virus2)
		var/datum/disease2/disease/D2 = M.virus2[A]
		D2.stage--
		if(D2.stage < 1)
			D2.cure(M)

/datum/reagent/adminordrazine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(2)
	T.add_waterlevel(2)
	T.add_weedlevel(5)
	T.add_pestlevel(5)
	T.add_toxinlevel(5)
	T.add_planthealth(50)

/datum/reagent/albuterol
	name = "Albuterol"
	id = ALBUTEROL
	description = "A bronchodilator that relaxes muscles in the airways and increases air flow to the lungs."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	overdose_am = REAGENTS_OVERDOSE

/datum/reagent/albuterol/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(holder.has_reagent(MUCUS))
		holder.remove_reagent(MUCUS, 10)

/datum/reagent/alkycosine
	name = "Alkycosine"
	id = ALKYCOSINE
	description = "A mind stablizing brain bleach."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#EDEDED" //rgb: 237, 237, 237
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	pain_resistance = 15
	density = 5.98
	specheatcap = 1.75

/datum/reagent/alkycosine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustBrainLoss(-4 * REM)

/datum/reagent/alkysine
	name = "Alkysine"
	id = ALKYSINE
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	pain_resistance = 10
	density = 2.98
	specheatcap = 0.77

/datum/reagent/alkysine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustBrainLoss(-3 * REM)

//lol homeopathy, surely I'll find somewhere to spawn these
/datum/reagent/antipathogenic
	name = "Placebo"
	id = PLACEBO
	description = "Highly ineffective, don't bet on those to keep you healthy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#006600" //rgb: 000, 102, 000
	custom_metabolism = 0.01
	overdose_am = 0
	density = 1.44
	specheatcap = 0.68
	data = list(
		"threshold" = 0,
		)

/datum/reagent/antipathogenic/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyAntipathogenics(data["threshold"])

//Anticoagulant. Great for helping the body fight off viruses but makes one vulnerable to pain, bleeding, and brute damage.
/datum/reagent/antipathogenic/feverfew
	name = "Feverfew"
	id = FEVERFEW
	description = "Feverfew is a natural anticoagulant useful in fending off viruses, but it leaves one vulnerable to pain and bleeding."
	color = "#b5651d"
	pain_resistance = -25
	data = list ("threshold" = 80)

/datum/reagent/antipathogenic/feverfew/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustBruteLoss(5 * REM) //2.5 per tick, human healing is around 1.5~2 so this is just barely noticable

/datum/reagent/antipathogenic/tomato_soup
	name = "Tomato Soup"
	id = TOMATO_SOUP
	description = "Water, tomato extract, and maybe some other stuff. Great for when you're feeling under the weather."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8
	density = 0.63
	specheatcap = 4.21
	data = list(
		"threshold" = 10,
		)

/datum/reagent/antipathogenic/tomato_soup/on_mob_life(var/mob/living/M)
	..()

	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

//natural antipathogenic, found in garlic and kudzu
/datum/reagent/antipathogenic/allicin
	name = "Allicin"
	id = ALLICIN
	description = "A natural antipathogenic."
	color = "#F1DEB4" //rgb: 241, 222, 180
	custom_metabolism = 0.2
	overdose_am = REAGENTS_OVERDOSE//30u
	data = list(
		"threshold" = 30,
		)

/datum/reagent/antipathogenic/allicin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE), 2 * REM)
	if(holder.has_any_reagents(STOXINS))
		holder.remove_reagents(STOXINS, 2 * REM)
	if(holder.has_reagent(PLASMA))
		holder.remove_reagent(PLASMA, REM)
	if(holder.has_any_reagents(SACIDS))
		holder.remove_reagents(SACIDS, REM)
	if(holder.has_reagent(POTASSIUM_HYDROXIDE))
		holder.remove_reagent(POTASSIUM_HYDROXIDE, 2 * REM)
	if(holder.has_reagent(CYANIDE))
		holder.remove_reagent(CYANIDE, REM)
	if(holder.has_reagent(AMATOXIN))
		holder.remove_reagent(AMATOXIN, 2 * REM)
	if(holder.has_reagent(CHLORALHYDRATE))
		holder.remove_reagent(CHLORALHYDRATE, 5 * REM)
	if(holder.has_reagent(CARPOTOXIN))
		holder.remove_reagent(CARPOTOXIN, REM)
	if(holder.has_reagent(ZOMBIEPOWDER))
		holder.remove_reagent(ZOMBIEPOWDER, 0.5 * REM)
	if(holder.has_reagent(MINDBREAKER))
		holder.remove_reagent(MINDBREAKER, 2 * REM)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1 //3x as effective if they're sleeping, 2x if they're lying down
	M.hallucination = max(0, M.hallucination - 5 * REM * lucidmod)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/antipathogenic/allicin/on_overdose(var/mob/living/M)
	if (prob(30))
		M.say("*cough")
	M.Dizzy(5)

//brewed from cryptobiolins and inaprovaline, wards off from most diseases
/datum/reagent/antipathogenic/spaceacillin
	name = "Spaceacillin"
	description = "A generic antipathogenic agent."
	id = SPACEACILLIN
	color = "#C81040" //rgb: 200, 16, 64
	overdose_am = REAGENTS_OVERDOSE / 2//15u
	data = list(
		"threshold" = 50,
		)

/datum/reagent/antipathogenic/spaceacillin/on_overdose(var/mob/living/M)
	M.adjustToxLoss(0.2)
	M.Dizzy(5)

//brewed from spaceacillin and nanobots, can cure any diseases given enough time, but has to be taken in very low quantities.
/datum/reagent/antipathogenic/nanofloxacin
	name = "Nanofloxacin"
	description = "An extremely powerful antipathogenic. To take in equally extremely small doses, or face a variety of adverse effects."
	id = NANOFLOXACIN
	color = "#969696" //rgb: 189, 189, 189
	overdose_am = REAGENTS_OVERDOSE / 10//3u
	data = list(
		"threshold" = 95,
		)

/datum/reagent/antipathogenic/nanofloxacin/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	M.adjustBrainLoss(5)
	M.hallucination += 100
	M.dizziness += 100

/datum/reagent/anti_toxin
	name = "Dylovene"
	id = ANTI_TOXIN
	description = "Dylovene is a broad-spectrum antitoxin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.49033
	specheatcap = 0.55536
	overdose_am = 60

/datum/reagent/anti_toxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE), 2 * REM)
	if(holder.has_any_reagents(STOXINS))
		holder.remove_reagents(STOXINS, 2 * REM)
	if(holder.has_reagent(PLASMA))
		holder.remove_reagent(PLASMA, REM)
	if(holder.has_any_reagents(SACIDS))
		holder.remove_reagents(SACIDS, REM)
	if(holder.has_reagent(POTASSIUM_HYDROXIDE))
		holder.remove_reagent(POTASSIUM_HYDROXIDE, 2 * REM)
	if(holder.has_reagent(CYANIDE))
		holder.remove_reagent(CYANIDE, REM)
	if(holder.has_reagent(AMATOXIN))
		holder.remove_reagent(AMATOXIN, 2 * REM)
	if(holder.has_reagent(CHLORALHYDRATE))
		holder.remove_reagent(CHLORALHYDRATE, 5 * REM)
	if(holder.has_reagent(SUX))
		holder.remove_reagent(SUX, REM)
	if(holder.has_reagent(CARPOTOXIN))
		holder.remove_reagent(CARPOTOXIN, REM)
	if(holder.has_reagent(ZOMBIEPOWDER))
		holder.remove_reagent(ZOMBIEPOWDER, 0.5 * REM)
	if(holder.has_reagent(MINDBREAKER))
		holder.remove_reagent(MINDBREAKER, 2 * REM)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1 //3x as effective if they're sleeping, 2x if they're lying down
	M.hallucination = max(0, M.hallucination - 5 * REM * lucidmod)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/anti_toxin/on_overdose(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(prob(min(tick / 10, 35)))
			H.vomit()

		switch(volume)
			if(60 to 75)
				H.dizziness = max(H.dizziness, 10)
				if(prob(5))
					to_chat(H,"<span class='warning'>Your stomach grumbles and you feel a little nauseous.</span>")
			if(75 to INFINITY)
				H.dizziness = max(H.dizziness, 20)
				if(prob(10))
					H.custom_pain("You feel a horrible throbbing pain in your stomach!",1)

/datum/reagent/anti_toxin/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(-10)

/datum/reagent/arithrazine
	name = "Arithrazine"
	id = ARITHRAZINE
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	density = 1.67
	specheatcap = 721.98

/datum/reagent/arithrazine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.radiation = max(M.radiation - 7 * REM, 0)
	M.adjustToxLoss(-REM)
	if(prob(15))
		M.take_organ_damage(1, 0, ignore_inorganics = TRUE)

/datum/reagent/bicaridine
	name = "Bicaridine"
	id = BICARIDINE
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	density = 1.96
	specheatcap = 0.57

/datum/reagent/bicaridine/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	if(alien != IS_DIONA)
		M.heal_organ_damage(2 * REM,0)

/datum/reagent/bicaridine/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/datum/organ/external/E in H.organs)
			for(var/datum/wound/W in E.wounds)
				W.heal_damage(0.2, TRUE)

/datum/reagent/bicaridine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(15))
			T.mutate(GENE_ECOLOGY)
			T.reagents.remove_reagent(id, 1)
		if(prob(15))
			T.mutate(GENE_ECOLOGY)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

/datum/reagent/biofoam	//Does exactly what clotting agent does but our reagent system won't let two chems with the same behavior share an ID.
	name = "Biofoam"
	id = BIOFOAM
	description = "A fast-hardening, biocompatible foam used to stem internal bleeding for a short time."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#D9C0E7" //rgb: 217, 192, 231
	custom_metabolism = 0.1

/datum/reagent/charcoal
	//data must contain virus type
	name = "Activated Charcoal"
	id = CHARCOAL
	reagent_state = REAGENT_STATE_LIQUID
	color = "#333333" // rgb: 51, 51, 51
	custom_metabolism = 0.06

var/global/list/charcoal_doesnt_remove=list(
	CHARCOAL,
	BLOOD
)

/datum/reagent/charcoal/on_mob_life(var/mob/living/M)
	if(!M)
		M = holder.my_atom

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H=M
		H.vomit()
		return

	var/found_any = FALSE
	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in charcoal_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 15*REM)
		found_any = TRUE

	if (!found_any)
		holder.remove_reagent(CHARCOAL, volume)

	M.adjustToxLoss(-2*REM)
	..()

/datum/reagent/citalopram
	name = "Citalopram"
	id = CITALOPRAM
	description = "Stabilizes the mind a little."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0
	density = 1.01
	specheatcap = 3.88

/datum/reagent/citalopram/on_mob_life(var/mob/living/M as mob)
	if(..())
		return 1
	if(volume <= 0.1)
		if(data != -1)
			data = -1
			to_chat(M, "<span class='warning'>Your mind feels a little less stable...</span>")
	else
		if(world.time > data + 3000)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels stable... a little stable.</span>")

/datum/reagent/clonexadone
	name = "Clonexadone"
	id = CLONEXADONE
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.22
	specheatcap = 4.27

/datum/reagent/clonexadone/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)

/datum/reagent/clonexadone/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(-5)
	T.add_planthealth(5)
	if(T.seed && !T.dead)
		var/datum/seed/S = T.seed
		var/deviation
		if(T.age > S.maturation)
			deviation = max(S.maturation-1, T.age-rand(7,10))
		else
			deviation = S.maturation/S.growth_stages
		T.age -= deviation
		T.skip_aging++
		T.force_update = 1
		if(prob(25))
			T.mutate(GENE_ECOPHYSIOLOGY)

/datum/reagent/clottingagent
	name = "Clotting Agent"
	id = CLOTTING_AGENT
	description = "Concentrated blood platelets, capable of stemming bleeding."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#a00000" //rgb: 160, 0, 0
	custom_metabolism = 0.1

/datum/reagent/comnanobots
	name = "Combat Nanobots"
	id = COMNANOBOTS
	description = "Microscopic robots intended for use in humans. Configured to grant great resistance to damage."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#343F42" //rgb: 52, 63, 66
	custom_metabolism = 0.01
	var/has_been_armstrong = 0
	var/armstronged_at = 0 //world.time
	density = 134.21
	specheatcap = 5143.18

/datum/reagent/comnanobots/reagent_deleted()
	if(..())
		return 1

	if(!holder)
		return
	var/mob/M =  holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!has_been_armstrong || (!(M_HULK in H.mutations)))
			return
		dehulk(H, 0, 1, 0)

/datum/reagent/comnanobots/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	switch(volume)
		if(1 to 4.5)
			M.Jitter(5)
			if(prob(10))
				to_chat(M, "You feel slightly energized, but nothing happens")
			if(has_been_armstrong>0) //Added in case person metabolizes below 5 units to prevent infinite hulk
				dehulk(M)
		if(4.5 to 15)
			if(ishuman(M)) //Does nothing to non-humans.
				var/mob/living/carbon/human/H = M
				if(H.species.name != "Diona") //Dionae are broken as fuck
					if(H.hulk_time<world.time && !has_been_armstrong)
						H.hulk_time = world.time + (45 SECONDS)
						armstronged_at = H.hulk_time
						if(!(M_HULK in H.mutations))
							has_been_armstrong = 1
							H.mutations.Add(M_HULK)
							H.update_mutations() //Update our mutation overlays
							H.update_body()
							message_admins("[key_name(M)] is hopped up on combat nanobots! ([formatJumpTo(M)])")
							to_chat(H, "The nanobots supercharge your body!")
					else if(H.hulk_time<world.time && has_been_armstrong) //TIME'S UP
						dehulk(H)
		if(15 to INFINITY)
			to_chat(M, "<b><big>The nanobots tear your body apart!</b></big>")
			M.gib()
			message_admins("[key_name(M)] took too many nanobots and gibbed!([formatJumpTo(M)])")

/datum/reagent/comnanobots/proc/dehulk(var/mob/living/carbon/human/H, damage = 0, override_remove = 1, gib = 0)
		H.hulk_time = 0 //Just to be sure.
		H.mutations.Remove(M_HULK)
		holder.remove_reagent("comnanobots", holder.get_reagent_amount("comnanobots"))
		//M.dna.SetSEState(HULKBLOCK,0)
		H.update_mutations()		//update our mutation overlays
		H.update_body()
		to_chat(H, "The nanobots burn themselves out in your body.")

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = CRYOXADONE
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.47
	specheatcap = 3.47

/datum/reagent/cryoxadone/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-1)
		M.heal_organ_damage(1,1)
		M.adjustToxLoss(-1)

/datum/reagent/cryoxadone/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(-3)
	T.add_planthealth(3)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = CRYPTOBIOLIN
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.2
	density = 1.21
	specheatcap = 0.85

/datum/reagent/cryptobiolin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Dizzy(1)
	M.confused = max(M.confused, 20)

/datum/reagent/degeneratecalcium
	name = "Degenerate Calcium"
	id = DEGENERATECALCIUM
	description = "A highly radical chemical derived from calcium that aggressively attempts to regenerate osseus tissues it comes in contact with. In the presence of micro-fractures caused by extensive brute damage it rapidly heals the surrounding tissues, but in healthy limbs the new tissue quickly causes the osseal structure to lose shape and shatter rather graphically."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ccffb3" //rgb: 204, 255, 179
	density = 3.9
	specheatcap = 128.12
	custom_metabolism = 0.1

/datum/reagent/degeneratecalcium/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.anatomy_flags & NO_BONES)
			return

		//if you have 30 or more brute damage: rapidly heals, makes your bones stronk
		//if you have less than 30 brute damage: rapidly heals, breaks all your bones one by one
		//(the rapid healing is likely to land you in that "less than 30" club real quick if you're not careful...)
		H.heal_organ_damage(3 * REM, 0)

		if(H.getBruteLoss(TRUE) >= 30)
			for(var/datum/organ/external/E in H.organs) //"organs" list only contains external organs aka limbs
				if((E.status & ORGAN_BROKEN) || !E.is_organic() || (E.min_broken_damage >= E.max_damage))
					continue
				E.min_broken_damage += rand(4,8) * REM
				if(E.min_broken_damage >= E.max_damage)
					E.min_broken_damage = E.max_damage
					to_chat(H, "Your [E.display_name] feels [pick("sturdy", "hardy")] as it can be!") //todo unfunny skeleton jokes (someone will probably comment them in the PR)
		else if(prob((100 - H.getBruteLoss() * 100 / 30)/3)) //33% at 0 damage, 16.6% at 15 damage, 1.1% at 29 damage etc
			var/datum/organ/external/E = pick(H.organs) //"organs" list only contains external organs aka limbs
			E.fracture()

/datum/reagent/dermaline
	name = "Dermaline"
	id = DERMALINE
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.75
	specheatcap = 0.36

/datum/reagent/dermaline/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.heal_organ_damage(0, 3 * REM)

/datum/reagent/dexalin
	name = "Dexalin"
	id = DEXALIN
	description = "Dexalin is used in the treatment of oxygen deprivation."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 2.28
	specheatcap = 0.91

/datum/reagent/dexalin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustOxyLoss(-2 * REM)

	if(holder.has_any_reagents(LEXORINS))
		holder.remove_reagents(LEXORINS, 2 * REM)

/datum/reagent/dexalin/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(15))
			T.mutate(GENE_XENOPHYSIOLOGY)
			T.reagents.remove_reagent(id, 1)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

/datum/reagent/dexalinp
	name = "Dexalin Plus"
	id = DEXALINP
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 4.14
	specheatcap = 0.29

/datum/reagent/dexalinp/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustOxyLoss(-M.getOxyLoss())

	if(holder.has_any_reagents(LEXORINS))
		holder.remove_reagents(LEXORINS, 2 * REM)

/datum/reagent/dietine
	name = "Dietine"
	id = DIETINE
	description = "An uncommon makeshift weight loss aid. Mildly toxic, moreso in larger doses."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#BBEDA4" //rgb: 187, 237, 164
	density = 1.44
	specheatcap = 60
	overdose_am = 5

	var/on_a_diet
	var/oldmetabolism

/datum/reagent/dietine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		M.adjustToxLoss(1)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!on_a_diet)
			oldmetabolism = H.calorie_burn_rate
			on_a_diet = TRUE
			H.calorie_burn_rate += H.calorie_burn_rate * 3
		if(prob(8))
			H.vomit(0,1)

/datum/reagent/dietine/reagent_deleted()
	if(ishuman(holder.my_atom))
		var/mob/living/carbon/human/H = holder.my_atom
		H.calorie_burn_rate -= oldmetabolism / 3
		on_a_diet = FALSE

/datum/reagent/dietine/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(0,1)

/datum/reagent/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = ETHYLREDOXRAZINE
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = REAGENT_STATE_SOLID
	color = "#605048" //rgb: 96, 80, 72
	density = 1.63
	specheatcap = 0.36

/datum/reagent/ethylredoxrazine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.slurring = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	holder.convert_some_of_type(/datum/reagent/ethanol, /datum/reagent/water, 2 * REM) //booze-b-gone

/datum/reagent/hyronalin
	name = "Hyronalin"
	id = HYRONALIN
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	density = 3.25
	specheatcap = 52.20

/datum/reagent/hyronalin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.radiation = max(M.radiation - 3 * REM, 0)

/datum/reagent/imidazoline
	name = "Imidazoline"
	id = IMIDAZOLINE
	description = "Heals eye damage"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.92
	specheatcap = 5.45

/datum/reagent/imidazoline/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.eye_blurry = max(M.eye_blurry - 5, 0)
	M.eye_blind = max(M.eye_blind - 5, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if(istype(E) && !E.robotic)
			if(E.damage > 0)
				E.damage = max(0, E.damage - 1)

/datum/reagent/imidazoline/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
			if(eyes_covered)
				return
			else //eyedrops, why not
				var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
				if(istype(E) && !E.robotic)
					M.eye_blurry = 0
					M.eye_blind = 0
					if(E.damage > 0)
						E.damage = 0 //cosmic technologies
					to_chat(H,"<span class='notice'>Your eyes feel better.</span>")

/datum/reagent/imidazoline/reaction_dropper_mob(var/mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
		if(eyes_covered)
			return
		else //eyedrops, why not
			var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
			if(istype(E) && !E.robotic)
				M.eye_blurry = 0
				M.eye_blind = 0
				if(E.damage > 0)
					E.damage = 0 //cosmic technologies
				to_chat(H,"<span class='notice'>Your eyes feel better.</span>")

/datum/reagent/inacusiate
	name = "Inacusiate"
	id = INACUSIATE
	description = "Rapidly heals ear damage"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6600FF" //rgb: 100, 165, 255
	overdose_am = REAGENTS_OVERDOSE
	density = 1.58
	specheatcap = 1.65

/datum/reagent/inacusiate/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.ear_damage = 0
	M.ear_deaf = 0

/datum/reagent/inaprovaline
	name = "Inaprovaline"
	id = INAPROVALINE
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.2
	pain_resistance = 25
	density = 1.66
	specheatcap = 0.8

/datum/reagent/inaprovaline/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REM)
	else
		if(M.losebreath >= 10)
			M.losebreath = max(10, M.losebreath - 5)

/datum/reagent/kelotane
	name = "Kelotane"
	id = KELOTANE
	description = "Kelotane is a drug used to treat burns."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 2.3
	specheatcap = 0.51

/datum/reagent/kelotane/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.heal_organ_damage(0, 2 * REM)

/datum/reagent/kelotane/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(15))
			T.mutate(GENE_ECOPHYSIOLOGY)
			T.reagents.remove_reagent(id, 1)
		if(prob(15))
			T.mutate(GENE_ECOPHYSIOLOGY)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

/datum/reagent/leporazine
	name = "Leporazine"
	id = LEPORAZINE
	description = "Leporazine can be use to stabilize an individuals body temperature."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 5.65
	specheatcap = ARBITRARILY_LARGE_NUMBER //Good luck heating something with leporazine in it

/datum/reagent/leporazine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/lexorin
	name = "Lexorin"
	id = LEXORIN
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 0.655293
	specheatcap = 7.549

/datum/reagent/lexorin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(33))
		M.take_organ_damage(REM, 0, ignore_inorganics = TRUE)
	M.adjustOxyLoss(3)
	if(prob(20))
		M.emote("gasp", null, null, TRUE)

/datum/reagent/lithotorcrazine
	name = "Lithotorcrazine"
	id = LITHOTORCRAZINE
	description = "A derivative of Arithrazine. Rather than reducing radiation in a host, actively impedes the host from being irradiated instead."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C0C0C0"
	custom_metabolism = 0.2
	density = 4.92
	specheatcap = 150.53

//The anti-nutriment
/datum/reagent/lipozine
	name = "Lipozine"
	id = LIPOZINE
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = -10 * REAGENTS_METABOLISM
	color = "#BBEDA4" //rgb: 187, 237, 164
	density = 2.63
	specheatcap = 381.13

/datum/reagent/lipozine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.overeatduration = 0

//Great healing powers. Metabolizes extremely slowly, but gets used up when it heals damage.
//Dangerous in amounts over 5 units, healing that occurs while over 5 units adds to a counter. That counter affects gib chance. Guaranteed gib over 20 units.
/datum/reagent/mednanobots
	name = "Medical Nanobots"
	id = MEDNANOBOTS
	description = "Microscopic robots intended for use in humans. Configured for rapid healing upon infiltration into the body."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#593948" //rgb: 89, 57, 72
	custom_metabolism = 0.005 //One unit every two hundred ticks, or 400-500 seconds.
	var/spawning_horror = 0
	var/percent_machine = 0
	density = 96.64
	specheatcap = 199.99

/datum/reagent/mednanobots/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M)) //Human type mob, so it has a wound system.
		var/mob/living/carbon/human/H = M
		for(var/datum/organ/external/E in H.organs)
			for(var/datum/wound/internal_bleeding/W in E.wounds)
				W.heal_damage(0.8, TRUE)
				holder.remove_reagent(MEDNANOBOTS, 0.25)
		for(var/datum/organ/internal/I in H.internal_organs)
			if(I.damage)
				I.damage = max(0, I.damage - 5) //Heals a whooping 5 organ damage.
				holder.remove_reagent(MEDNANOBOTS, 0.10) //Less so it doesn't vanish the nanobot supply
			I.status &= ~ORGAN_BROKEN //What do I owe you?
			I.status &= ~ORGAN_SPLINTED //Nothing, it's for free!
			I.status &= ~ORGAN_BLEEDING //FOR FREE?!
	if(M.getOxyLoss() || M.getBruteLoss(TRUE) || M.getToxLoss() || M.getFireLoss(TRUE) || M.getCloneLoss())
		M.adjustOxyLoss(-5)
		M.heal_organ_damage(5, 5) //Heals Brute and Burn. It heals the mob, not individual organs.
		M.adjustToxLoss(-5)
		M.adjustCloneLoss(-5) //Repairs DNA!
		holder.remove_reagent(MEDNANOBOTS, 0.25) //Consumes a quarter of an unit every time it heals.
	if(M.dizziness)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused)
		M.remove_confused(5)
	for(var/datum/disease/D in M.viruses) //Diseases that work under the second rework of viruses, or "Viro 3"
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	if(iscarbon(M)) //Can we support "Viro 2" diseases?
		var/mob/living/carbon/C = M
		for(var/A in C.virus2)
			var/datum/disease2/disease/D2 = C.virus2[A]
			D2.stage--
			if(D2.stage < 1)
				D2.cure(M)
	switch(volume)
		if(0.1 to 5)
			if(percent_machine>5) //Slowly lowers the percent machine to a minimum of 5 when you aren't above 5 units.
				percent_machine -= 1
				if(prob(20))
					to_chat(M, pick("You feel more like yourself again."))

		if(5 to 20)	//Processing above 5 units runs the risk of getting a big enough dose of nanobots to turn you into a cyberhorror.
			percent_machine += 0.5 //The longer it metabolizes at this stage the more likely.
			if(prob(20))
				to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>",
								"<span class='warning'>You feel different, somehow...</span>"))
			if(prob(percent_machine))
				holder.add_reagent(MEDNANOBOTS, 20)
				to_chat(M, pick("<b><span class='warning'>Your body lurches!</b></span>"))
		if(20 to INFINITY) //Now you've done it.
			if(istype(M, /mob/living/simple_animal/hostile/monster/cyber_horror))
				return
			spawning_horror = 1
			to_chat(M, pick("<b><span class='warning'>Something doesn't feel right...</span></b>", "<b><span class='warning'>Something is growing inside you!</span></b>", "<b><span class='warning'>You feel your insides rearrange!</span></b>"))
			spawn(60)
				if(spawning_horror == 1)
					to_chat(M, "<b><span class='warning'>Something bursts out from inside you!</span></b>")
					message_admins("[key_name(M)] [M] has gibbed and spawned a new cyber horror due to nanobots. ([formatJumpTo(M)])")
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/typepath
						typepath = text2path("/mob/living/simple_animal/hostile/monster/cyber_horror/[H.species.name]")
						if(ispath(typepath))
							new typepath(M.loc)
						else
							new /mob/living/simple_animal/hostile/monster/cyber_horror(M.loc)
					else
						new /mob/living/simple_animal/hostile/monster/cyber_horror/monster(M.loc,M)
					spawning_horror = 0
					M.gib()

/datum/reagent/methylin
	name = "Methylin"
	id = METHYLIN
	description = "An intelligence enhancer, also used in the treatment of attention deficit hyperactivity disorder. Also known as Ritalin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CC1122"
	custom_metabolism = 0.03
	overdose_am = REAGENTS_OVERDOSE/2
	density = 4.09
	specheatcap = 45.59

/datum/reagent/methylin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		M.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/methylin/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	M.adjustBrainLoss(1)

/datum/reagent/nanobots
	name = "Nanobots"
	id = NANOBOTS
	description = "Microscopic robots intended for use in humans. Must be loaded with further chemicals to be useful."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#3E3959" //rgb: 62, 57, 89
	density = 236.6
	specheatcap = 199.99

/datum/reagent/oxycodone
	name = "Oxycodone"
	id = OXYCODONE
	description = "An effective and very addictive painkiller."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C805DC"
	custom_metabolism = 0.05
	density = 1.26
	specheatcap = 24.59

/datum/reagent/oxycodone/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.pain_numb = max(5, C.pain_numb)
		C.pain_shock_stage -= 3 //We don't FEEL the shock now, but make it go away quick in case we run out of oxycodone.
		if(!M.sleeping && prob(2))
			to_chat(M, pick("<span class='numb'>You feel like you're floating...</span>", \
							"<span class='numb'>You feel a little lightheaded... but it's okay.</span>", \
							"<span class='numb'>Your face itches a little bit... and it feels so good to scratch it...</span>", \
							"<span class='numb'>Your whole body buzzes slightly, but it doesn't seem to bother you...</span>", \
							"<span class='numb'>You feel a little high of energy, and it makes you smile...</span>", \
							"<span class='numb'>You nod to yourself... it's nothing, it just feels good to nod a little...</span>", \
							"<span class='numb'>Hello?... Is there anybody in there?...</span>", \
							"<span class='numb'>You feel... comfortably numb.</span>"))

/datum/reagent/paracetamol
	name = "Paracetamol"
	id = PARACETAMOL
	description = "Most commonly know this as Tylenol, but this chemical is a mild, simple painkiller."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C855DC"
	pain_resistance = 60
	density = 1.26

/datum/reagent/paroxetine
	name = "Paroxetine"
	id = PAROXETINE
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0
	density = 1.19
	specheatcap = 3.99

/datum/reagent/paroxetine/on_mob_life(var/mob/living/M as mob)
	if(..())
		return 1
	if(volume <= 0.1)
		if(data != -1)
			data = -1
			to_chat(M, "<span class='warning'>Your mind feels much less stable.</span>")
	else
		if(world.time > data + 3000)
			data = world.time
			if(prob(90))
				to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
			else
				to_chat(M, "<span class='warning'>Your mind breaks apart.</span>")
				M.hallucination += 200
	if(M.mind && M.mind.suiciding)
		M.mind.suiciding = FALSE
		to_chat(M, "<span class='numb'>Whoah... You feel like this life is worth living after all!</span>")

/datum/reagent/peptobismol
	name = "Peptobismol"
	id = PEPTOBISMOL
	description = "Jesus juice." //You're welcome, guy in the thread that rolled a 69.
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 22.25
	specheatcap = 10.55

/datum/reagent/peptobismol/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	if(holder.has_reagent("discount"))
		holder.remove_reagent("discount", 2 * REM)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1
	M.hallucination = max(0, M.hallucination - 5 * REM * lucidmod)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/peridaxon
	name = "Peridaxon"
	id = PERIDAXON
	description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = 10

/datum/reagent/peridaxon/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/chest/C = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.damage > 0)
				I.damage = max(0,I.damage-0.2)

/datum/reagent/peridaxon/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/item/organ/internal))
		var/obj/item/organ/internal/I = O
		if(I.health <= 0)
			I.revive()
		if(I.health < initial(I.health))
			I.health = min(I.health+rand(1,3), initial(I.health))
		if(I.organ_data)
			var/datum/organ/internal/OD = I.organ_data
			if(OD.damage > 0)
				OD.damage = max(0, OD.damage-0.4)

/datum/reagent/piccolyn
	name = "Piccolyn"
	id = PICCOLYN
	description = "Prescribed daily."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#00FF00"
	custom_metabolism = 0.01

/datum/reagent/phalanximine
	name = "Phalanximine"
	id = PHALANXIMINE
	description = "Phalanximine is a powerful chemotherapy agent."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#1A1A1A" //rgb: 26, 26, 26
	density = 2.46
	specheatcap = 12439.3 //Good fucking luck

/datum/reagent/phalanximine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(-2 * REM)
	M.apply_radiation(4 * REM,RAD_INTERNAL)

/datum/reagent/piccolyn/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.stat || M.health < 90 || M.getBrainLoss() >= 10)
		return 1

	var/list/nearest_doctor = null
	for(var/mob/living/L in view(M))
		if(L == M)
			continue
		if(L.stat)
			continue
		if(nearest_doctor && get_dist(L,M)>=get_dist(nearest_doctor,M))
			continue //We already have a closer living target
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/list/medical_uniforms_list = list(/obj/item/clothing/under/rank/chief_medical_officer,
													/obj/item/clothing/under/rank/medical,
													/obj/item/clothing/under/rank/nursesuit,
													/obj/item/clothing/under/rank/nurse,
													/obj/item/clothing/under/rank/orderly,
													/obj/item/clothing/under/rank/chemist,
													/obj/item/clothing/under/rank/pharma,
													/obj/item/clothing/under/rank/geneticist,
													/obj/item/clothing/under/rank/virologist)
			if(H.is_wearing_any(medical_uniforms_list,slot_w_uniform))
				//Check to see if it's wearing the right stuff
				nearest_doctor = H
		else if(isrobot(L))
			var/mob/living/silicon/robot/R = L
			if(HAS_MODULE_QUIRK(R, MODULE_CAN_HANDLE_MEDICAL))
				nearest_doctor = R
	if(!nearest_doctor)
		return 1
	var/D = "doctor"
	if(ishuman(nearest_doctor))
		var/mob/living/carbon/human/H = nearest_doctor
		D = get_first_word(H.name)
	else
		D = pick("bot","borg","borgo","autodoc","roboticist","cyborg","robot")
	var/list/thanks = list("Thanks, doc.",
							"You're alright, doc.",
							"'Preciate it, doc.",
							"Cheers, doctor.",
							"Thank you, doctor.",
							"Much appreciated, doctor.",
							"Thanks, mate!",
							"Thanks, doc!",
							"Zank you, Herr Doktor!",
							"Danke, Herr Doktor!",
							"Thank you doctor!",
							"You are great doctor!",
							"I love this doctor!",
							"Aye, thanks doc!",
							"Thank ye, doctor!",
							"You deserve a medal, doc.",
							"Thanks for the aid.",
							"Yeah, thanks doc!",
							"All right, [D], I feel good!",
							"Thanks, [D].",
							"Thank you, [D].",
							"'Preciate it, [D].",
							"Thanks for the aid, [D]."
							)
	M.say(pick(thanks))
	holder.del_reagent(PICCOLYN)

/datum/reagent/preslomite
	name = "Preslomite"
	id = PRESLOMITE
	description = "A stabilizing chemical used in industrial relief efforts."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	custom_metabolism = 0.05

/datum/reagent/preslomite/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	if(M.losebreath>10)
		M.losebreath = max(10, M.losebreath - 5)
	if(!iscarbon(M))
		return //We can't do anything else for you
	var/mob/living/carbon/C = M
	if(C.health < config.health_threshold_crit + 10)
		C.adjustToxLoss(-2 * REM)
		C.heal_organ_damage(0, 2 * REM)

/datum/reagent/rezadone
	name = "Rezadone"
	id = REZADONE
	description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	reagent_state = REAGENT_STATE_SOLID
	color = "#669900" //rgb: 102, 153, 0
	overdose_am = REAGENTS_OVERDOSE
	overdose_tick = 35
	density = 109.81
	specheatcap = 13.59

/datum/reagent/rezadone/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	switch(tick)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_organ_damage(1, 1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_organ_damage(2, 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.disfigured)
					head_organ.disfigured = FALSE
					if(H.get_face_name() != "Unknown")
						H.visible_message("<span class='notice'>[H]'s face shifts and knits itself back into shape!</span>","<span class='notice'>You feel your face shifting and repairing itself!</span>")
					else if(!H.isUnconscious())
						to_chat(H,"<span class='notice'>You feel your face shifting and repairing itself!</span>")

/datum/reagent/rezadone/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	M.Dizzy(5)
	M.Jitter(5)

/datum/reagent/ryetalyn
	name = "Ryetalyn"
	id = RYETALYN
	description = "Ryetalyn can cure all genetic abnomalities."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	density = 1.97
	specheatcap = 512.61

/datum/reagent/ryetalyn/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	var/needs_update = M.mutations.len > 0

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hulk_time = 0
		for(var/gene_type in H.active_genes)
			var/datum/dna/gene/gene = dna_genes[gene_type]
			var/tempflag = 0
			if(H.species && (gene.block in H.species.default_blocks))
				tempflag |= GENE_NATURAL
			if(gene.name == "Hulk")
				gene.OnMobLife(H)
			if(gene.can_deactivate(H, tempflag))
				gene.deactivate(H, 0, tempflag)
	else
		for(var/gene_type in M.active_genes)
			if(gene_type == /datum/dna/gene/monkey)
				continue
			var/datum/dna/gene/gene = dna_genes[gene_type]
			if(gene.can_deactivate(M, 0))
				gene.deactivate(M, 0, 0)

	M.alpha = 255
	M.disabilities = 0
	M.sdisabilities = 0

	//Makes it more obvious that it worked.
	M.remove_jitter()

	//Might need to update appearance for hulk etc.
	if(needs_update)
		M.update_mutations()

/datum/reagent/simpolinol
	name = "Simpolinol"
	id = SIMPOLINOL
	description = "An experimental medication which has shown promising results in animal tests. Has not yet advanced to human trials."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A5A5FF" //rgb: 165, 165, 255
	density = 1.58
	specheatcap = 0.44

/datum/reagent/simpolinol/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(isanimal(M))
		M.health = min(M.maxHealth, M.health + REM)
		return

	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M

	if(!H.ckey)
		H.adjustToxLoss(5)
	if((!H.client) || H.client.is_afk())
		if(prob(30))
			H.vomit(0,1)
		return

	randomized_reagents[SIMPOLINOL].on_human_life(H, tick)

/datum/reagent/srejuvenate
	name = "Soporific Rejuvenant"
	id = STOXIN2
	description = "Puts people to sleep, and heals them."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	custom_metabolism = 0.2
	density = 1.564
	specheatcap = 1.725

/datum/reagent/srejuvenate/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	//Always happens, regardless if patient is in the sleeper
	//Slows down massive suffocation
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath - 10)
	//Immediate eye blurriness/drowsiness indicate that you may have been drugged
	switch(tick)
		if(1 to 5)
			M.eye_blurry = max(M.eye_blurry, 10) //Eyes get blurry immediately
		if(5 to INFINITY)
			M.drowsyness  = max(M.drowsyness, 10) //Drowsiness even outside of the sleeper

	//This handles sleeper/cryo vs out of sleeper/cryo behaviors
	if (istype(M.loc,/obj/machinery/sleeper) || M.bodytemperature < 170)
		//If the patient is in a sleeper/cryo and it's been at least 20 seconds...
		if(tick >= 10)
			M.sleeping = max(M.sleeping, 15) //Put to sleep, lasts 30 seconds from exiting the sleeper/running out
			M.adjustOxyLoss(-M.getOxyLoss())
			M.heal_organ_damage(REM, REM) //Tricord-level healing
			M.adjustToxLoss(-REM)
			M.SetKnockdown(0)
			M.SetStunned(0)
			M.SetParalysis(0)
			M.dizziness = 0
			M.drowsyness = 0 //Wake-up function/Natural wearing off inside sleeper prevents drowsiness on waking up
			M.stuttering = 0
			M.confused = 0
			M.remove_jitter()
			M.hallucination = 0
	else
		tick = min(tick, 5) //Getting kicked out of the sleeper requires additional time to restart healing when returned

/datum/reagent/stabilizine
	name = "Stabilizine"
	id = STABILIZINE
	description = "A stabilizing chemical produced by alien nests to keep their occupants barely alive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#833484" //rgb: 131, 52, 132
	custom_metabolism = 0.1

/datum/reagent/stabilizine/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		for(var/datum/organ/external/temp in H.organs)
			if(temp.status & ORGAN_BLEEDING)
				temp.clamp_wounds()

	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath - 5)

	M.adjustOxyLoss(-2 * REM)

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = STERILIZINE
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.83
	specheatcap = 1.83

/datum/reagent/sterilizine/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if (isitem(O))
		var/obj/item/I = O
		I.sterility = min(100,initial(I.sterility)+30)
	O.clean_blood()
	if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else if(O.color && istype(O, /obj/item/weapon/paper))
		O.color = null

/datum/reagent/synaptizine
	name = "Synaptizine"
	id = SYNAPTIZINE
	description = "Synaptizine is used to treat various diseases."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose_am = REAGENTS_OVERDOSE
	pain_resistance = 40
	density = 1.04
	specheatcap = 18.53

/datum/reagent/synaptizine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.drowsyness = max(M.drowsyness-  5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustKnockdown(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1
	M.hallucination = max(0, M.hallucination - 10 * lucidmod)
	if(prob(60))
		M.adjustToxLoss(1)

/datum/reagent/synthocarisol
	name = "Synthocarisol"
	id = SYNTHOCARISOL
	description = "Synthocarisol is a synthetic version of Carisol, a powerful analgesic that used to be found in traditional medicines made from the horn of the now-extinct Space African Rhino. Tragically, the horns also contained an equal amount of Anticarisol, which led to the medical community dismissing the remedies as nothing more than placebo and overlooking this reagent for several centuries."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#580082" //rgb: 88, 0, 130
	overdose_am = REAGENTS_OVERDOSE
	density = 4.67
	specheatcap = 0.57

/datum/reagent/synthocarisol/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.heal_organ_damage(2 * REM)

/datum/reagent/tramadol
	name = "Tramadol"
	id = TRAMADOL
	description = "A simple, yet effective painkiller."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	pain_resistance = 80
	custom_metabolism = 0.1
	density = 1.2
	specheatcap = 1.79

/datum/reagent/tramadol/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.pain_level < BASE_CARBON_PAIN_RESIST) //If we're already recovering from shock, let's speed the process up
			C.pain_shock_stage--

/datum/reagent/tricordrazine
	name = "Tricordrazine"
	id = TRICORDRAZINE
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.58
	specheatcap = 0.44

/datum/reagent/tricordrazine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.getOxyLoss())
		M.adjustOxyLoss(-REM)
	if(M.getBruteLoss())
		M.heal_organ_damage(REM, 0)
	if(M.getFireLoss())
		M.heal_organ_damage(0, REM)
	if(M.getToxLoss())
		M.adjustToxLoss(-REM)

/datum/reagent/trinitrine
	name = "Trinitrine"
	id = TRINITRINE
	description = "Glyceryl Trinitrate, also known as diluted nitroglycerin, is a medication used for heart failure and to treat and prevent chest pain due to hyperzine."
	reagent_state = REAGENT_STATE_LIQUID
	overdose_tick = 50
	color = "#CED7D5" //rgb: 206, 215, 213
	alpha = 142
	density = 1.33
	specheatcap = 3.88

/datum/reagent/trinitrine/on_mob_life(var/mob/living/M)
	if(prob(10))
		M.adjustOxyLoss(REM)
	if(prob(50))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/heart/E = H.internal_organs_by_name["heart"]
			if(prob(5))
				H.custom_pain("You feel a pain in your head", 0)
			if(istype(E) && !E.robotic)
				if(E.damage > 0)
					E.damage = max(0, E.damage - 0.2)
	if(prob(10))
		M.drowsyness = max(M.drowsyness, 2)

/datum/reagent/vaccine
	name = "Vaccine"
	description = "A subunit vaccine. Introduces antigens without pathogenic particles to the body, allowing the immune system to produce enough antibodies to prevent any current or future infection."
	id = VACCINE
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A6A6A6" //rgb: 166, 166, 166
	alpha = 200
	density = 1.05
	specheatcap = 3.49
	custom_metabolism = 1
	data = list(
		"antigen" = list(),
		)

/datum/reagent/vaccine/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["antigen"] |= added_data["antigen"]

/datum/reagent/vaccine/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data = added_data.Copy()
	else
		data = list("antigen" = list())

/datum/reagent/vaccine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyVaccine(data["antigen"])

/datum/reagent/virus_food
	name = "Virus Food"
	id = VIRUSFOOD
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#899613" //rgb: 137, 150, 19
	density = 0.67
	specheatcap = 4.18
