//What the fuck are these things made of?

/obj/item/weapon/reagent_containers/glass/replenishing
	mech_flags = MECH_SCAN_FAIL
	var/reagent_list = list(BLOOD,HOLYWATER,CLEANER,LUBE,NOTHING,FROSTOIL,CAPSAICIN,WATER,FUEL,PLASMA,MOONROCKS,CARPPHEROMONES,ETHANOL,DRINK,ZOMBIEPOWDER,HIPPIESDELIGHT,PWINE,MANLYDORF,CHANGELINGSTING,CITALOPRAM,PAROXETINE)
	var/spawning_id = null
	var/artifact = TRUE
	var/artifact_id = null
	var/units_per_tick = 0.3

/obj/item/weapon/reagent_containers/glass/replenishing/New()
	..()
	processing_objects.Add(src)
	spawning_id = pick(reagent_list)
	if(artifact)
		artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"
		src.investigation_log(I_ARTIFACT, " [src.artifact_id] spawned with the ability to replenish itself with [spawning_id].")

/obj/item/weapon/reagent_containers/glass/replenishing/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/reagent_containers/glass/replenishing/process()
	reagents.add_reagent(spawning_id, units_per_tick)


/obj/item/weapon/reagent_containers/glass/xenoviral
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/reagent_containers/glass/xenoviral/New()
	..()
	var/virus_choice = pick(subtypesof(/datum/disease2/disease))
	var/datum/disease2/disease/new_virus = new virus_choice

	var/list/anti = list(
		ANTIGEN_BLOOD	= 0,
		ANTIGEN_COMMON	= 0,
		ANTIGEN_RARE	= 0,
		ANTIGEN_ALIEN	= 1,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 1,
		EFFECT_DANGER_FLAVOR	= 0,
		EFFECT_DANGER_ANNOYING	= 0,
		EFFECT_DANGER_HINDRANCE	= 0,
		EFFECT_DANGER_HARMFUL	= 0,
		EFFECT_DANGER_DEADLY	= 0,
		)//always helpful

	new_virus.origin = "Xenoarch Urn/Bowl"

	new_virus.makerandom(list(40,60),list(20,90),anti,bad,null)

	var/list/blood_data = list(
		"donor" = null,
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = "O-",
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = list()
	)
	blood_data["virus2"]["[new_virus.uniqueID]-[new_virus.subID]"] = new_virus
	reagents.add_reagent(BLOOD, volume, blood_data)
