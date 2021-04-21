/datum/unit_test/supermatter/start()

/datum/unit_test/supermatter/airflow_hit/start()
	var/turf/pos = locate(101, 100, 1) // Nice place with a good atmosphere
	var/mob/living/carbon/human/human = new(pos)
	var/obj/machinery/power/supermatter/shard/shard = new(pos)
	shard.airflow_hit(human)
	assert_eq(human.stat, DEAD)
	human = new(pos)
	human.airflow_hit(shard)
	assert_eq(human.stat, DEAD)
