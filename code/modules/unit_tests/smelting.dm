/datum/unit_test/smelting/start()
/datum/unit_test/smelting/forge/start()
	var/turf/centre = locate(101, 101, 1)

	var/obj/item/stack/ore/gold/gold = new(centre, 20)
	var/mob/living/carbon/human/human = new(centre)
	var/obj/structure/forge/forge = new(centre)

	human.put_in_active_hand(gold)
	assert_eq(forge.attackby(gold, human), 1)

	forge.fuel_time = 100
	forge.current_temp = TEMPERATURE_PLASMA
	forge.toggle_lit()
	assert_eq(forge.status, TRUE)
	assert_eq(forge.heating, gold)

	forge.process()
	assert_eq(forge.heating, null)
	assert_eq(gold.gcDestroyed, "Bye, world!")
