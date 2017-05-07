/datum/artifact_trigger/reagent
	triggertype = TRIGGER_REAGENT
	scanned_trigger = SCAN_PHYSICAL
	var/reagent_group = 0
	var/key_attackby

/datum/artifact_trigger/reagent/New()
	..()
	reagent_group = pick("WATER", "ACID", "VOLATILE", "TOXIN")
	key_attackby = my_artifact.on_attackby.Add(src, "owner_attackby")

/datum/artifact_trigger/reagent/proc/owner_attackby(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/obj/item = event_args[3]

	if (istype(item, /obj/item/weapon/reagent_containers/glass) && item.is_open_container() ||\
		istype(item, /obj/item/weapon/reagent_containers/dropper))
		if(reagent_group == "WATER" && (item.reagents.has_reagent(HYDROGEN, 1) || item.reagents.has_reagent(WATER, 1)))
			Triggered(toucher, reagent_group, item)
		else if(reagent_group == "ACID" && (item.reagents.has_reagent(SACID, 1) || item.reagents.has_reagent(PACID, 1) || item.reagents.has_reagent(DIETHYLAMINE, 1)))
			Triggered(toucher, reagent_group, item)
		else if(reagent_group == "VOLATILE" && (item.reagents.has_reagent(PLASMA, 1) || item.reagents.has_reagent(THERMITE, 1)))
			Triggered(toucher, reagent_group, item)
		else if(reagent_group == "TOXIN" && (item.reagents.has_reagent(TOXIN, 1) || item.reagents.has_reagent(CYANIDE, 1) || item.reagents.has_reagent(AMATOXIN, 1) || item.reagents.has_reagent(NEUROTOXIN, 1)))
			Triggered(toucher, reagent_group, item)

/datum/artifact_trigger/reagent/Destroy()
	my_artifact.on_attackby.Remove(key_attackby)
	..()