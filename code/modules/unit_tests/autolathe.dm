/datum/unit_test/autolathe/start()
	return

/datum/unit_test/autolathe/test_recycling/start()
	var/turf/centre = locate(100, 100, 1) // Nice place with a good atmosphere and shit
	var/mob/living/carbon/human/test_subject = new(centre)
	var/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/autolathe = new(centre)
	var/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe/ammolathe = new(centre)
	var/obj/machinery/r_n_d/fabricator/protolathe/protolathe = new(centre)

	var/obj/item/weapon/pickaxe/diamond/test_object = new(centre)
	assert_eq(autolathe.attackby(test_object, test_subject), 1)
	assert_eq(protolathe.attackby(test_object, test_subject), 0)
	test_object = new(centre)
	assert_eq(ammolathe.attackby(test_object, test_subject), 0)
