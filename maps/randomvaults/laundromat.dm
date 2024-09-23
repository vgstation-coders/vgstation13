/obj/abstract/map/spawner/laundromat/clothing
	name = "Laundromat clothing spawner"
	amount = 4
	chance = 25
	jiggle = 10

/obj/abstract/map/spawner/laundromat/clothing/New()
	if (!clothing.len)
		clothing = existing_typesof(/obj/item/clothing)
		for (var/clothing_type in clothing_types_blacklist)
			clothing -= typesof(clothing_type)
		for (var/clothing_type in clothing_blacklist)
			clothing -= clothing_type
	to_spawn = clothing
	return ..()

/area/vault/laundromat
	name = "Laundromat"
	icon_state = "laundromat"

/area/vault/laundromat/drug_lab
	name = "Drug Lab"
	icon_state = "druglab"

/obj/structure/reagent_dispensers/cauldron/laundromat/meth
	name = "meth cauldron"
	desc = "Yeah Mr. Petrov... Yeah, SCIENCE!"

/obj/structure/reagent_dispensers/cauldron/laundromat/meth/New()
	. = ..()
	reagents.add_reagent(METHAMPHETAMINE, 1000)

/obj/structure/reagent_dispensers/cauldron/laundromat/spessdrugs
	name = "space drugs cauldron"
	desc = "HE CAN'T KEEP GETTING AWAY WITH IT!"

/obj/structure/reagent_dispensers/cauldron/laundromat/spessdrugs/New()
	. = ..()
	reagents.add_reagent(SPACE_DRUGS, 1000)

/obj/machinery/chem_dispenser/laundromat
	desc = "A man provides for his family."
	upgraded = 1
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/laundromat/New()
	. = ..()
	update_chem_list() //so they auto update to have the thing
