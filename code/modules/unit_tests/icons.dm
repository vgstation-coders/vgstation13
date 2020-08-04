// Tests that make sure items have valid sprites.
// If this test fails then you broke some sprite. Shame on you

/datum/unit_test/icons/start()
    return

/datum/unit_test/icons/food/start()
    // basically every food item except those who have a special icon handling. We don't test those
    var/types = subtypesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/multispawner)
    types -= typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)
    types -= /obj/item/weapon/reagent_containers/food/snacks/sliceable
    types -= /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
    types -= /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy // idk what the fuck is this, but it's not broken
    types -= /obj/item/weapon/reagent_containers/food/snacks/snackbar/nutriment
    types -= /obj/item/weapon/reagent_containers/food/snacks/sushi
    for(var/F in types)
        var/obj/item/weapon/reagent_containers/food/snacks/food = new F()
        if(!has_icon(food.icon, food.icon_state))
            fail("FAILED FOR [F] :: [food.name] with icon state: [food.icon_state]")