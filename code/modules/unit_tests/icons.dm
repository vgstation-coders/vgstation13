// Tests that make sure items have valid sprites.
// If this test fails then you broke some sprite. Shame on you

/datum/unit_test/icons
	var/types

/datum/unit_test/icons/start()
	var/turf/centre = locate(100, 100, 1)
	for(var/type in types)
		var/atom/A = new type(centre)
		if(!has_icon(A.icon, A.icon_state))
			fail("FAILED FOR [type] :: \"[A.name]\" with icon: \"[A.icon]\" and icon_state: \"[A.icon_state]\"")
		qdel(A)

/datum/unit_test/icons/food/start()
	// basically every food item except those who have a special icon handling. We don't test those
	types = subtypesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/multispawner)
	types -= typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)
	types -= /obj/item/weapon/reagent_containers/food/snacks/sliceable
	types -= /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	types -= /obj/item/weapon/reagent_containers/food/snacks/snackbar/nutriment
	types -= /obj/item/weapon/reagent_containers/food/snacks/sushi
	types -= /obj/item/weapon/reagent_containers/food/snacks/meat/animal/grue //because of meat recoloring
	..()

/datum/unit_test/icons/drinks/start()
	// basically every drink
	types = subtypesof(/obj/item/weapon/reagent_containers/food/drinks)
	..()

/datum/unit_test/icons/seeds/start()
	// basically every seed packet
	types = subtypesof(/obj/item/seeds)
	..()
