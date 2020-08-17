#define RESULT_RUN      1
#define RESULT_WALK     2
#define RESULT_NOSLIP   3
#define RESULT_MAGBOOTS 4

#define TURF_WET_WATER_STR "1" // Byond doesn't like integers in assoc list :-(
#define TURF_WET_LUBE_STR "2"

/datum/unit_test/slipping


	/*
		We spawn an item, make an human run on it, and check if he slipped or not
		The list is of the form :
		item_to_spawn = list(RESULT_RUN, RESULT_WALK, RESULT_NOSLIP, RESULT_MAGBOOTS)
	*/

	var/list/items_and_result_humans = list(
		/obj/item/weapon/reagent_containers/food/snacks/butter = list(TRUE, FALSE, FALSE, FALSE),
		/obj/item/weapon/bananapeel/ = list(TRUE, TRUE, FALSE, FALSE),
		/obj/item/weapon/soap/ = list(TRUE, TRUE, FALSE, FALSE),
		/obj/item/device/pda/clown = list(TRUE, TRUE, FALSE, FALSE),
		)

	/* overlay_to_spawn = list(RESULT_RUN, RESULT_WALK, RESULT_NOSLIP, RESULT_MAGBOOTS) */

	var/list/overlays_and_results = list(
		TURF_WET_WATER_STR = list(TRUE, FALSE, FALSE, FALSE),
		TURF_WET_LUBE_STR = list(TRUE, TRUE, TRUE, TRUE),
	)

/datum/unit_test/slipping/start()
	// Items

	var/turf/centre = locate(100, 100, 1) // Nice place with a good atmosphere and shit
	var/turf/simulated/T_test = locate(centre.x, centre.y + 1, centre.z)
	for (var/type in items_and_result_humans)
		for (var/i = 1 to 4)
			var/mob/living/carbon/human/H = new(centre)
			sleep(1) // Poor human needs to handle his birth (and the spawn() involved). Be patien
			var/obj/O = new type(T_test)
			switch (i)
				if (RESULT_RUN)
					// Nothing
				if (RESULT_WALK)
					H.m_intent = "walk"
				if (RESULT_NOSLIP)
					var/obj/item/clothing/shoes/syndigaloshes/S = new
					H.equip_or_collect(S, slot_shoes)
				if (RESULT_MAGBOOTS)
					var/obj/item/clothing/shoes/magboots/M = new
					H.equip_or_collect(M, slot_shoes)
					M.togglemagpulse(H)
			H.Move(T_test, NORTH)
			if (H.isStunned() != items_and_result_humans[type][i])
				fail("Slipping test failed at [type], step [i] ; expected [items_and_result_humans[type][i]], got [H.isStunned()]")
			qdel(H)
			qdel(O)
	// Overlays
	for (var/wetness in overlays_and_results)
		for (var/j = 1 to 4)
			var/mob/living/carbon/human/H = new(centre)
			sleep(1) // Poor human needs to handle his birth (and the spawn() involved). Be patient
			var/wet_fac = text2num(wetness)
			T_test.wet(10 SECONDS, wet_fac)
			switch (j)
				if (RESULT_RUN)
					// Nothing
				if (RESULT_WALK)
					H.m_intent = "walk"
				if (RESULT_NOSLIP)
					var/obj/item/clothing/shoes/syndigaloshes/S = new
					H.equip_or_collect(S, slot_shoes)
				if (RESULT_MAGBOOTS)
					var/obj/item/clothing/shoes/magboots/M = new
					H.equip_or_collect(M, slot_shoes)
					M.togglemagpulse(H)
			H.Move(T_test, NORTH)
			if (H.isStunned() != overlays_and_results[wetness][j])
				fail("Slipping test failed at [wetness], step [j] ; expected [overlays_and_results[wetness][j]], got [H.isStunned()]")
			qdel(H)
			T_test.dry(TURF_WET_LUBE)