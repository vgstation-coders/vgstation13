/*
Feel free to fix my code up if it's totally bogus.
- Heredth
*/

/datum/event/rave
	announceWhen	= 1
	var/safe_zones = list(
		/area/maintenance,
		/area/bridge,
		/area/crew_quarters/captain,
		/area/crew_quarters/heads,
		/area/crew_quarters/courtroom,
		/area/crew_quarters/hop,
		/area/lawoffice,
		/area/security,
		/area/shuttle,
		/area/vox_station,
		/area/syndicate_station
	)


/datum/event/rave/announce()
	// Don't do anything, we want to pack the announcement with the actual event

/datum/event/rave/proc/is_safe_zone(var/area/A)
	for(var/szt in safe_zones)
		if(istype(A, szt))
			return 1
	return 0

/datum/event/rave/start()
	spawn()
		//world << sound('sound/AI/radiation.ogg') Needs a new one.
		command_alert("The Annual Intergalactic Party is entering Tau Ceti, dude! If you wish to commit a most henious crime and bail out on the party, head to a registered no-fun zone like maint, command, and the brig.", "Bill & Ted Party Planning Update")

		for(var/area/A in world)
			if(A.z != 1 || is_safe_zone(A))
				continue
			var/area/ma = get_area_master(A)
			ma.partyalert()

		make_maint_all_access()


		sleep(600)


		command_alert("PARTY ON DUDES! THIS IS A MOST EXCELLENT RAVE!", "Bill & Ted Party Planning Update")

		for(var/i = 0, i < 10, i++)
			for(var/mob/living/carbon/human/H in living_mob_list)
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != 1 || is_safe_zone(T.loc))
					continue

				if(istype(H,/mob/living/carbon/human))
					H.reagents = new /datum/reagent/ethanol(65)



			for(var/mob/living/carbon/monkey/M in living_mob_list)
				var/turf/T = get_turf(M)
				if(!T)
					continue
				if(T.z != 1)
					continue
				M.reagents = new /datum/reagent/ethanol(65)

			sleep(100)


		command_alert("Right guys, that party was totally rad. Maintenance access will be like, removed in a little while. See you next time, and remember to stay excellent to eachother!", "Bill & Ted Party Planning Update")

		for(var/area/A in world)
			if(A.z != 1 || is_safe_zone(A))
				continue
			var/area/ma = get_area_master(A)
			ma.partyreset()


		sleep(600) // Want to give them time to get out of maintenance.


		revoke_maint_all_access()
