/var/global/sent_aliens_to_station = 0

/datum/event/alien_infestation
	announceWhen	= 450

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.
	var/player_factor = 1

/datum/event/alien_infestation/can_start(var/list/active_with_role)
	if(aliens_allowed && !sent_aliens_to_station && active_with_role["Security"] > 1)
		return 10
	return 0


/datum/event/alien_infestation/setup()
	announceWhen = rand(1500, 3000)
	player_factor = round(player_list.len/10) //One bonus starting alium for 10 players
	spawncount = rand(1, 2)+player_factor
	sent_aliens_to_station = 1

/datum/event/alien_infestation/announce()
	if(successSpawn)
		command_alert(/datum/command_alert/xenomorphs)


/datum/event/alien_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in atmos_machines)
		if(temp_vent.loc.z == map.zMainStation && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_active_candidates(ROLE_ALIEN, buffer=ALIEN_SELECT_AFK_BUFFER, poll="HEY KID, YOU WANNA BE AN ALIEN LARVA?")

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick(vents)
		var/mob/candidate = pick(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = candidate.key
		new_xeno << sound('sound/voice/alienspawn.ogg')

		candidates -= candidate
		vents -= vent
		spawncount--
		successSpawn = 1
	return successSpawn
