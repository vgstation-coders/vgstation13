

/datum/unit_test/borer/start()

/datum/unit_test/borer/detach_from_slime/start()
    var/turf/some_place = locate(100, 92, 1)
    var/mob/living/carbon/human/slime/test_slime = new(some_place)
    var/mob/living/simple_animal/borer/test_borer = new(some_place)

    test_borer.perform_infestation(test_slime)
    test_slime.death()
    var/obj/item/weapon/gun/hookshot/flesh/test_fleshshot = locate(/obj/item/weapon/gun/hookshot/flesh) in some_place

    assert_eq(test_fleshshot, null)
