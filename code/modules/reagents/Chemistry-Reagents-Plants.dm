//////////////////////
//					//
//     PLANT CHEMS	//
//					//
//////////////////////




/datum/reagent/fertilizer
	name = "fertilizer"
	id = FERTILIZER
	description = "A chemical mix good for growing plants with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664330" // rgb: 102, 67, 48
	density = 5.4
	specheatcap = 15

/datum/reagent/fertilizer/eznutrient
	name = "EZ Nutrient"
	id = EZNUTRIENT
	color = "#A4AF1C" // rgb: 164, 175, 28
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/left4zed
	name = "Left-4-Zed"
	id = LEFT4ZED
	description = "A cocktail of mutagenic compounds, which cause plant life to become highly unstable."
	color = "#5B406C" // rgb: 91, 64, 108
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/robustharvest
	name = "Robust Harvest"
	id = ROBUSTHARVEST
	description = "Plant-enhancing hormones, good for increasing potency."
	color = "#3E901C" // rgb: 62, 144, 28
	density = 1.32
	specheatcap = 0.60

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = PLANTBGONE
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#49002E" //rgb: 73, 0, 46
	density = 1.08
	specheatcap = 4.18

//Clear off wallrot fungi
/datum/reagent/toxin/plantbgone/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		if(W.rotting)
			W.remove_rot()
			W.visible_message("<span class='notice'>The fungi are burned away by the solution!</span>")

/datum/reagent/toxin/plantbgone/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/effect/alien/weeds/))
		var/obj/effect/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15, 35) //Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment)) //Kills kudzu too.
		var/obj/effect/plantsegment/K = O
		var/dmg = 200
		if(K.seed)
			dmg -= K.seed.toxins_tolerance*20
		for(var/obj/effect/plantsegment/KV in orange(O,1))
			KV.health -= dmg*0.4
			KV.check_health()
			SSplant.add_plant(KV)
		K.health -= dmg
		K.check_health()
		SSplant.add_plant(K)
	else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = O
		if(tray.seed)
			tray.health -= rand(30,50)
		tray.pestlevel -= 2
		tray.weedlevel -= 3
		tray.toxins += 15
		tray.check_level_sanity()
	else if(istype(O, /obj/structure/cable/powercreeper))
		var/obj/structure/cable/powercreeper/PC = O
		if(prob(1*(PC.powernet.avail/1000))) //The less there is, the hardier it gets
			PC.die()

/datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) //If not wearing a mask
			C.adjustToxLoss(REM) //4 toxic damage per application, doubled for some reason
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.dna)
				if(H.species.flags & IS_PLANT) //Plantmen take a LOT of damage //aren't they toxin-proof anyways?
					H.adjustToxLoss(10 * REM)


/datum/reagent/diethylamine
	name = "Diethylamine"
	id = DIETHYLAMINE
	description = "A secondary amine, mildly corrosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#604030" //rgb: 96, 64, 48
	density = 0.65
	specheatcap = 35.37


/datum/reagent/ammonia
	name = "Ammonia"
	id = AMMONIA
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = REAGENT_STATE_GAS
	color = "#404030" //rgb: 64, 64, 48
	density = 0.51
	specheatcap = 14.38

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
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, SOLANINE), 2 * REM)
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



//Plant-specific reagents

/datum/reagent/kelotane/tannic_acid
	name = "Tannic acid"
	id = TANNIC_ACID
	description = "Tannic acid is a natural burn remedy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#150A03" //rgb: 21, 10, 3

/datum/reagent/dermaline/kathalai
	name = "Kathalai"
	id = KATHALAI
	description = "Kathalai is an exceptional natural burn remedy, it performs twice as well as tannic acid."
	color = "#32BD08" //rgb: 50, 189, 8

/datum/reagent/bicaridine/opium
	name = "Opium"
	id = OPIUM
	description = "Opium is an exceptional natural analgesic."
	color = "#AE9260" //rgb: 174, 146, 96

/datum/reagent/space_drugs/mescaline
	name = "Mescaline"
	id = MESCALINE
	description = "Known to cause mild hallucinations, mescaline is often used recreationally."
	color = "#B8CD93" //rgb: 184, 205, 147

/datum/reagent/synaptizine/cytisine
	name = "Cytisine"
	id = CYTISINE
	description = "Cytisine is an alkaloid which mimics the effects of nicotine."
	color = "#A49B50" //rgb: 164, 155, 80

/datum/reagent/hyperzine/cocaine
	name = "Cocaine"
	id = COCAINE
	description = "Cocaine is a powerful nervous system stimulant."
	color = "#FFFFFF" //rgb: 255, 255, 255

/datum/reagent/imidazoline/zeaxanthin
	name = "Zeaxanthin"
	id = ZEAXANTHIN
	description = "Zeaxanthin is a natural pigment which purportedly supports eye health."
	color = "#CC4303" //rgb: 204, 67, 3

/datum/reagent/stoxin/valerenic_acid
	name = "Valerenic acid"
	id = VALERENIC_ACID
	description = "An herbal sedative used to treat insomnia."
	color = "#EAB160" //rgb: 234, 177, 96

/datum/reagent/sacid/formic_acid
	name = "Formic acid"
	id = FORMIC_ACID
	description = "A weak natural acid which causes a burning sensation upon contact."
	color = "#9B3D00" //rgb: 155, 61, 0

/datum/reagent/pacid/phenol
	name = "Phenol"
	id = PHENOL
	description = "Phenol is a corrosive acid which can cause chemical burns."
	color = "#C71839" //rgb: 199, 24, 57

/datum/reagent/ethanol/deadrum/neurotoxin/curare
	name = "Curare"
	id = CURARE
	description = "An alkaloid plant extract which causes weakness of the skeletal muscles."
	color = "#94DC76" //rgb: 148, 220, 118

/datum/reagent/toxin/solanine
	name = "Solanine"
	id = SOLANINE
	description = "A glycoalkaloid poison."
	color = "#6C8347" //rgb: 108, 131, 71

/datum/reagent/cryptobiolin/physostigmine
	name = "Physostigmine"
	id = PHYSOSTIGMINE
	description = "Physostigmine causes confusion and dizzyness."
	color = "#0098D7" //rgb: 0, 152, 215

/datum/reagent/impedrezene/hyoscyamine
	name = "Hyoscyamine"
	id = HYOSCYAMINE
	description = "Hyoscyamine is a tropane alkaloid which can disrupt the central nervous system."
	color = "#BBD0C9" //rgb: 187, 208, 201

/datum/reagent/lexorin/coriamyrtin
	name = "Coriamyrtin"
	id = CORIAMYRTIN
	description = "Coriamyrtin is a toxin which causes respiratory problems."
	color = "#FB6892" //rgb: 251, 104, 146

/datum/reagent/dexalin/thymol
	name = "Thymol"
	id = THYMOL
	description = "Thymol is used in the treatment of respiratory problems."
	color = "#790D27" //rgb: 121, 13, 39

/datum/reagent/synthocarisol/phytocarisol
	name = "Phytocarisol"
	id = PHYTOCARISOL
	description = "A plant based alternative to carisol, a medicine made from rhino horn dust."
	color = "#34D3B6" //rgb: 52, 211, 182

/datum/reagent/heartbreaker/defalexorin
	name = "Defalexorin"
	id = DEFALEXORIN
	description = "Defalexorin is used for getting a mild high in low amounts."
	color = "#000000" //rgb: 0, 0, 0

/datum/reagent/alkycosine/phytosine
	name = "Phytosine"
	id = PHYTOSINE
	description = "Neurological medication made from mutated herbs."
	color = "#9000ff" //rgb: 144, 0 255