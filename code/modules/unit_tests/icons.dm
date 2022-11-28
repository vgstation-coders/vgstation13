// Tests that make sure items have valid sprites.
// If this test fails then you broke some sprite. Shame on you

/datum/unit_test/icons/start()
    return

/datum/unit_test/icons/food/start()
    // basically every food item except those who have a special icon handling. We don't test those
    var/types = subtypesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/multispawner)
    var/turf/centre = locate(100, 100, 1)
    types -= typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)
    types -= /obj/item/weapon/reagent_containers/food/snacks/sliceable
    types -= /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
    types -= /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy // idk what the fuck is this, but it's not broken
    types -= /obj/item/weapon/reagent_containers/food/snacks/snackbar/nutriment
    types -= /obj/item/weapon/reagent_containers/food/snacks/sushi
    types -= /obj/item/weapon/reagent_containers/food/snacks/meat/animal/grue //because of meat recoloring
    for(var/type in types)
        var/obj/item/weapon/reagent_containers/food/snacks/food = new type(centre)
        if(!has_icon(food.icon, food.icon_state))
            fail("FAILED FOR [type] :: \"[food.name]\" with icon state: \"[food.icon_state]\"")
        qdel(food)

/datum/unit_test/icons/seeds/start()
    // basically every seed packet
    var/types = subtypesof(/obj/item/seeds)
    for(var/type in types)
        var/obj/item/seeds/seed = new type()
        if(!has_icon(seed.icon, seed.icon_state))
            fail("FAILED FOR [type] :: \"[seed.name]\" with icon: \"[seed.icon]\" and icon_state: \"[seed.icon_state]\"")
