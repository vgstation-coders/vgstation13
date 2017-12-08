//What the fuck are these things made of?

/obj/item/weapon/reagent_containers/glass/replenishing
	mech_flags = MECH_SCAN_FAIL
	var/reagent_list = list(BLOOD,HOLYWATER,CLEANER,LUBE,NOTHING,FROSTOIL,CAPSAICIN,WATER,FUEL,PLASMA,MOONROCKS,CARPPHEROMONES,ETHANOL,DRINK,ZOMBIEPOWDER,HIPPIESDELIGHT,PWINE,MANLYDORF,CHANGELINGSTING,CITALOPRAM,PAROXETINE)
	var/spawning_id = null
	var/artifact = TRUE
	var/artifact_id = null

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
	reagents.add_reagent(spawning_id, 0.3)
