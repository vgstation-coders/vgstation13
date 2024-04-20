//Plant-related chemicals

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = DIETHYLAMINE
	description = "A secondary amine, mildly corrosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#604030" //rgb: 96, 64, 48
	density = 0.65
	specheatcap = 35.37

/datum/reagent/diethylamine/ammoniumnitrate
	name = "Ammonium Nitrate"
	id = AMMONIUMNITRATE

/datum/reagent/diethylamine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	T.reagents.remove_reagent(id, 0.1)
	if(T.reagents.get_reagent_amount(id) > 0)
		T.add_nutrientlevel(1)
		T.add_planthealth(1)
		if(prob(10))
			T.add_pestlevel(-1)
		if(T.seed && !T.dead)
			if(prob(20))
				T.affect_growth(1)
			if(!T.seed.immutable)
				var/chance
				chance = unmix(T.seed.lifespan, 15, 125)*20
				if(prob(chance))
					T.check_for_divergence(1)
					T.seed.lifespan ++
				chance = unmix(T.seed.lifespan, 15, 125)*20
				if(prob(chance))
					T.check_for_divergence(1)
					T.seed.endurance++

/datum/reagent/fertilizer
	name = "Fertilizer"
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

/datum/reagent/fertilizer/eznutrient/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(10)

/datum/reagent/fertilizer/left4zed
	name = "Left-4-Zed"
	id = LEFT4ZED
	description = "A cocktail of mutagenic compounds, which cause plant life to become highly unstable."
	color = "#5B406C" // rgb: 91, 64, 108
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/left4zed/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	T.add_nutrientlevel(10)
	if(T.reagents.get_reagent_amount(id) >= 1)
		if(prob(1))
			T.mutate(GENE_PHYTOCHEMISTRY)
		if(prob(1))
			T.mutate(GENE_MORPHOLOGY)
		if(prob(1))
			T.mutate(GENE_BIOLUMINESCENCE)
		if(prob(1))
			T.mutate(GENE_ECOLOGY)
		if(prob(1))
			T.mutate(GENE_ECOPHYSIOLOGY)
		if(prob(1))
			T.mutate(GENE_METABOLISM)
		if(prob(1))
			T.mutate(GENE_DEVELOPMENT)
		if(prob(1))
			T.mutate(GENE_XENOPHYSIOLOGY)
		if(prob(5))
			T.reagents.remove_reagent(id, 1)

/datum/reagent/fertilizer/robustharvest
	name = "Robust Harvest"
	id = ROBUSTHARVEST
	description = "Plant-enhancing hormones, good for increasing potency."
	color = "#3E901C" // rgb: 62, 144, 28
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/robustharvest/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	T.reagents.remove_reagent(id, 0.1)
	if(T.reagents.get_reagent_amount(id) > 0)
		T.add_nutrientlevel(1)
		if(prob(3))
			T.add_weedlevel(10)
		if(T.seed && !T.dead)
			if(prob(3))
				T.add_pestlevel(10)
			var/chance = unmix(T.seed.potency, 15, 150)*35
			if(!T.seed.immutable && prob(chance))
				T.check_for_divergence(1)
				T.seed.potency++

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
			dmg -= 20*K.seed.toxin_affinity
		for(var/obj/effect/plantsegment/KV in orange(O,1))
			KV.health -= dmg*0.4
			KV.try_break()
			SSplant.add_plant(KV)
		K.health -= dmg
		K.try_break()
		SSplant.add_plant(K)
	else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = O
		tray.die()
	else if(istype(O, /obj/structure/cable/powercreeper))
		var/obj/structure/cable/powercreeper/PC = O
		if(prob(1*(PC.powernet.avail/1000))) //The less there is, the hardier it gets
			PC.die()

/datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
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

/datum/reagent/toxin/plantbgone/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.die()

/datum/reagent/toxin/insecticide
	name = "Insecticide"
	id = INSECTICIDE
	description = "A broad pesticide. Do not ingest!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#49002E" //rgb: 73, 0, 46
	density = 1.08
	specheatcap = 4.18

/datum/reagent/toxin/insecticide/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) //If not wearing a mask
			C.adjustToxLoss(REM) //4 toxic damage per application, doubled for some reason
		if(isinsectoid(C) || istype(C, /mob/living/carbon/monkey/roach)) //Insecticide being poisonous to bugmen, who'd've thunk
			M.adjustToxLoss(10 * REM)

/datum/reagent/toxin/insecticide/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_pestlevel(-8)

//Plant-specific reagents

/datum/reagent/kelotane/tannic_acid
	name = "Tannic Acid"
	id = TANNIC_ACID
	description = "Tannic acid is a natural burn remedy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#150A03" //rgb: 21, 10, 3

/datum/reagent/kelotane/tannic_acid/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()

/datum/reagent/dermaline/kathalai
	name = "Kathalai"
	id = KATHALAI
	description = "Kathalai is an exceptional natural burn remedy, it performs twice as well as tannic acid."
	color = "#32BD08" //rgb: 50, 189, 8

/datum/reagent/bicaridine/opium
	name = "Opium"
	id = OPIUM
	description = "Opium is an exceptional natural analgesic."
	pain_resistance = 80
	color = "#AE9260" //rgb: 174, 146, 96

/datum/reagent/bicaridine/opium/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()

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

/datum/reagent/hyperzine/cocaine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()

/datum/reagent/imidazoline/zeaxanthin
	name = "Zeaxanthin"
	id = ZEAXANTHIN
	description = "Zeaxanthin is a natural pigment which purportedly supports eye health."
	color = "#CC4303" //rgb: 204, 67, 3
	flags = CHEMFLAG_PIGMENT

/datum/reagent/stoxin/valerenic_acid
	name = "Valerenic Acid"
	id = VALERENIC_ACID
	description = "An herbal sedative used to treat insomnia."
	color = "#EAB160" //rgb: 234, 177, 96

/datum/reagent/sacid/formic_acid
	name = "Formic Acid"
	id = FORMIC_ACID
	description = "A weak natural acid which causes a burning sensation upon contact."
	color = "#9B3D00" //rgb: 155, 61, 0

/datum/reagent/pacid/phenol
	name = "Phenol"
	id = PHENOL
	description = "Phenol is a corrosive acid which can cause chemical burns."
	color = "#C71839" //rgb: 199, 24, 57

/datum/reagent/ethanol/drink/neurotoxin/curare
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

/datum/reagent/dexalin/thymol/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()

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

//End of plant-specific reagents
