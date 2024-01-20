/datum/artifact_trigger/reagent
	triggertype = TRIGGER_REAGENT
	scanned_trigger = SCAN_PHYSICAL
	var/reagent_group = 0

/datum/artifact_trigger/reagent/New()
	..()
	reagent_group = pick("WATER", "ACID", "VOLATILE", "TOXIN")
	my_artifact.register_event(/event/attackby, src, nameof(src::owner_attackby()))

/datum/artifact_trigger/reagent/proc/owner_attackby(mob/living/attacker, obj/item/item)
	if (istype(item, /obj/item/weapon/reagent_containers/glass) && item.is_open_container() ||\
		istype(item, /obj/item/weapon/reagent_containers/dropper))
		if(reagent_group == "WATER" && (item.reagents.has_reagent(HYDROGEN, 1) || item.reagents.has_reagent(WATER, 1)))
			Triggered(attacker, reagent_group, item)
		else if(reagent_group == "ACID" && (item.reagents.has_reagent(SACID, 1) || item.reagents.has_reagent(PACID, 1) || item.reagents.has_reagent(DIETHYLAMINE, 1)))
			Triggered(attacker, reagent_group, item)
		else if(reagent_group == "VOLATILE" && (item.reagents.has_reagent(PLASMA, 1) || item.reagents.has_reagent(THERMITE, 1)))
			Triggered(attacker, reagent_group, item)
		else if(reagent_group == "TOXIN" && (item.reagents.has_reagent(TOXIN, 1) || item.reagents.has_reagent(CYANIDE, 1) || item.reagents.has_reagent(AMATOXIN, 1) || item.reagents.has_reagent(NEUROTOXIN, 1)))
			Triggered(attacker, reagent_group, item)

/datum/artifact_trigger/reagent/Destroy()
	my_artifact.unregister_event(/event/attackby, src, nameof(src::owner_attackby()))
	..()
