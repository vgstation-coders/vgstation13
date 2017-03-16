//What the fuck are these things made of?

/obj/item/weapon/reagent_containers/glass/replenishing
	mech_flags = MECH_SCAN_ILLEGAL
	var/spawning_id
	var/artifact_id

/obj/item/weapon/reagent_containers/glass/replenishing/New()
	..()
	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"
	processing_objects.Add(src)
	spawning_id = pick(BLOOD,HOLYWATER,CLEANER,LUBE,NOTHING,FROSTOIL,CAPSAICIN,WATER,FUEL,PLASMA,MOONROCKS,CARPPHEROMONES,ETHANOL,DRINK,ZOMBIEPOWDER,HIPPIESDELIGHT,PWINE,MANLYDORF,CHANGELINGSTING,CITALOPRAM,PAROXETINE)
	src.investigation_log(I_ARTIFACT, " [src.artifact_id] spawned with the ability to replenish itself with [spawning_id].")

/obj/item/weapon/reagent_containers/glass/replenishing/process()
	reagents.add_reagent(spawning_id, 0.3)
