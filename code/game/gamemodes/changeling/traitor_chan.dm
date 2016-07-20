/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI")
	required_players = 1
	required_players_secret = 15
	required_enemies = 2
	recommended_enemies = 3

/datum/game_mode/traitor/changeling/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Changeling!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")


/datum/game_mode/traitor/changeling/pre_setup()
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	for(var/datum/mind/player in possible_changelings)
		if(mixed && (player in ticker.mode.modePlayer))
			possible_changelings -= player
			continue
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	if(possible_changelings.len>0)
		var/datum/mind/changeling = pick(possible_changelings)
		possible_changelings -= changeling
		changeling.special_role = "Changeling"
		changelings += changeling
		modePlayer += changelings
		if(mixed)
			ticker.mode.modePlayer += changelings
			ticker.mode.changelings += changelings
		. = ..()
		if(!. && mixed)
			for(var/datum/mind/P in modePlayer)
				ticker.mode.modePlayer -= P
				ticker.mode.changelings -= P
		else
			ticker.mode.modePlayer += traitors
			ticker.mode.traitors += traitors
		return .
	else
		return 0

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	..()
	return