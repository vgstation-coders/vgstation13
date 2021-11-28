
/proc/alien_infestation(var/spawncount = 1)
	var/list/vents = list()
	var/success = FALSE
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in atmos_machines)
		if(temp_vent.loc.z == map.zMainStation && !temp_vent.welded && temp_vent.network && temp_vent.canSpawnMice)
			if(temp_vent.network.normal_members.len > 50) // Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/mob/dead/observer/candidates = get_active_candidates(ROLE_ALIEN, buffer=ALIEN_SELECT_AFK_BUFFER, poll="HEY KID, YOU WANNA BE AN ALIEN LARVA?")

	if(candidates.len)
		shuffle(candidates)
		if(prob(40))
			spawncount++ //sometimes, have two larvae spawn instead of one
		while((spawncount >= 1) && vents.len && candidates.len)
			var/obj/vent = pick(vents)
			var/mob/dead/observer/candidate = pick(candidates)

			if(istype(candidate) && candidate.client && candidate.key)
				var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
				new_xeno.transfer_personality(candidate.client)
				success = TRUE

			candidates -= candidate
			vents -= vent
			spawncount--

		if(success)
			spawn(rand(5000, 6000)) //Delayed announcements to keep the crew on their toes.
				command_alert(/datum/command_alert/xenomorphs)

		return success
