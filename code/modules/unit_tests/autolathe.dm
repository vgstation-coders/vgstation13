/datum/unit_test/autolathe/start()
    var/turf/centre = locate(100, 100, 1) // Nice place with a good atmosphere and shit
    var/mob/living/carbon/human/test_subject = new(centre)
    var/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/autolathe = new(centre)
    var/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe/ammolathe = new(centre)
    
    var/obj/item/weapon/light/tube/large/test_object = new(centre)
    assert_eq(autolathe.attackby(test_object, test_subject), 1)
    assert_eq(ammolathe.attackby(test_object, test_subject), 0)