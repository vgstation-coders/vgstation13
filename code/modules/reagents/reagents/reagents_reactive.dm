//Reagents whose primary purpose is to cause a specific reaction or are only useful to cause a reaction

/datum/reagent/aminomicin
	name = "Aminomicin"
	id = AMINOMICIN
	description = "An experimental and unstable chemical, said to be able to create life. Potential reaction detected if mixed with nutriment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#634848" //rgb: 99, 72, 72
	density = 13.49 //our ingredients are pretty dense
	specheatcap = 0.2084
	custom_metabolism = 0.01 //oh shit what are you doin

/datum/reagent/aminomician
	name = "Aminomician"
	id = AMINOMICIAN
	description = "An experimental and unstable chemical, said to be able to create companionship. Potential reaction detected if mixed with nutriment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#634848" //rgb: 99, 72, 72
	density = 13.49 //our ingredients are pretty dense
	specheatcap = 0.2084
	custom_metabolism = 0.01 //oh shit what are you doin

/datum/reagent/aminocyprinidol
	name = "Aminocyprinidol"
	id = AMINOCYPRINIDOL
	description = "An extremely dangerous, flesh-replicating material, mutated by exposure to God-knows-what. Do not mix with nutriment under any circumstances."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#cb42f4" //rgb: 203, 66, 244
	density = 0.11175 //our ingredients are extremely dense, especially carppheromones
	specheatcap = ARBITRARILY_LARGE_NUMBER //Is partly made out of leporazine, so you're not heating this up.
	custom_metabolism = 0.01 //oh shit what are you doin

/datum/reagent/aminoblatella
	name = "Aminoblatella"
	id = AMINOBLATELLA
	description = "Developed in the darkest halls of maintenance by the Elder Greytide council, it is said to be able to create untold gunk. Potential reaction detected if mixed with equal parts nutriment or ten parts mutagen."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#634848" //rgb: 99, 72, 72
	density = 15.49 //our ingredients are pretty dense
	specheatcap = 0.2084
	custom_metabolism = 0.01 //oh shit what are you doin

//Foam precursor
/datum/reagent/fluorosurfactant
	name = "Fluorosurfactant"
	id = FLUOROSURFACTANT
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#9E6B38" //rgb: 158, 107, 56
	density = 1.95
	specheatcap = 0.81

//Metal foaming agent
//This is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually
/datum/reagent/foaming_agent
	name = "Foaming Agent"
	id = FOAMING_AGENT
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = REAGENT_STATE_SOLID
	color = "#664B63" //rgb: 102, 75, 99
	density = 0.62
	specheatcap = 49.23

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = NITROGLYCERIN
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080" //rgb: 128, 128, 128
	density = 4.33
	specheatcap = 2.64

/datum/reagent/nitroglycerin/on_mob_life(var/mob/living/M)
	M.adjustToxLoss(2 * REM)
	if(prob(80))
		M.adjustOxyLoss(2 * REM)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/E = H.internal_organs_by_name["heart"]
		if(istype(E) && !E.robotic)
			if(E.damage > 0)
				E.damage = max(0, E.damage - 0.2)
		if(prob(15))
			H.custom_pain("You feel a throbbing pain in your head", 1)
			M.adjustBrainLoss(2 * REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 4)

/datum/reagent/paismoke
	name = "Smoke"
	id = PAISMOKE
	description = "A chemical smoke synthesized by personal AIs."
	reagent_state = REAGENT_STATE_GAS
	color = "#FFFFFF" //rgb: 255, 255, 255

//When inside a person, instantly decomposes into the ingredients for smoke
/datum/reagent/paismoke/on_mob_life(var/mob/living/M)
	M.reagents.del_reagent(src.id)
	M.reagents.add_reagent("potassium", 5)
	M.reagents.add_reagent("sugar", 5)
	M.reagents.add_reagent("phosphorus", 5)
