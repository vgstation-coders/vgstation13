/*
	Gamemode datums
		Used for co-ordinating factions in a round, what factions should be in operation, etc.
	@name: String: The name of the gamemode, e.g. Changelings
	@factions: List(reference): What factions are currently in operation in the gamemode
	@factions_allowed: List(object): what factions will the gamemode start with, or attempt to start with
	@minimum_player_count: Integer: Minimum required players to start the gamemode
	@admin_override: Overrides certain checks such as the one above to force-start a gamemode
	@available_roles: List of all roles the ticker can draft players into
	@probability: How likely it is to roll this gamemode
	@votable: If this mode can be voted for
	@orphaned_roles: List of faction-less roles currently in the gamemode
*/


/datum/gamemode
	var/name = "Gamemode Parent"
	var/list/factions = list()
	var/list/factions_allowed = list()
	var/minimum_player_count
	var/admin_override //Overrides checks such as minimum_player_count to
	var/probability = 50
	var/votable = TRUE
	var/list/orphaned_roles = list()

	//'Oh dear we accidentally destroyed the station/universe' variables
	var/station_was_nuked
	var/explosion_in_progress


/datum/gamemode/proc/can_start()
	if(minimum_player_count && minimum_player_count < get_player_count())
		return 0
	return 1

//For when you need to set factions and factions_allowed not on compile
/datum/gamemode/proc/SetupFactions()

/datum/gamemode/proc/Setup()
	if(minimum_player_count && minimum_player_count < get_player_count())
		TearDown()
		return 0
	SetupFactions()
	return CreateFactions()


/datum/gamemode/proc/CreateFactions()
	var/pc = get_player_count() //right proc?
	for(var/Fac in factions_allowed)
		CreateFaction(Fac, pc)
	return PopulateFactions()

/datum/gamemode/proc/CreateFaction(var/Fac, var/population)
	var/datum/faction/F = new Fac
	if(F.can_setup(population))
		factions += F
		factions_allowed -= F
	else
		qdel(F)

/*
	Get list of available players
	Get list of active factions
	Loop through the players to see if they're available for certain factions
		Not available if they
			don't have their preferences set accordingly
			already in another faction
*/

/datum/gamemode/proc/PopulateFactions()
	var/list/available_players = get_ready_players()

	for(var/datum/faction/F in factions)
		for(var/mob/new_player/P in available_players)
			if(F.max_roles && F.members.len >= F.max_roles)
				break
			if(!P.client || !P.mind)
				continue
			if(!P.client.desires_role(F.required_pref) || jobban_isbanned(P, F.required_pref))
				continue
			if(!F.HandleNewMind(P.mind))
				WARNING("[P.mind] failed [F] HandleNewMind!")
				return 0
	return 1

/datum/gamemode/proc/latespawn(var/mob/mob) //Check factions, see if anyone wants a latejoiner
	var/list/possible_factions = list()
	for(var/datum/faction/F in factions)
		if(F.accept_latejoiners)
			possible_factions.Add(F)
	if(possible_factions.len)
		var/datum/faction/F = pick(possible_factions)
		F.HandleRecruitedMind(mob.mind)

/datum/gamemode/proc/PostSetup()
	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(ticker && ticker.mode)
		feedback_set_details("game_mode","[ticker.mode]")
	if(revdata)
		feedback_set_details("revision","[revdata.revision]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")

	for(var/datum/faction/F in factions)
		F.OnPostSetup()
	return 1

/datum/gamemode/proc/TearDown()
	// This is where the game mode is shut down and cleaned up.

/datum/gamemode/proc/GetScoreboard()
	var/dat =""
	for(var/datum/faction/F in factions)
		dat += F.GetScoreboard()
		dat += "\n\n"
	return dat

/datum/gamemode/proc/get_player_count()
	var/players = 0
	for(var/mob/new_player/P in player_list)
		if(P.client && P.ready)
			players++

	return players

/datum/gamemode/proc/get_ready_players()
	var/list/players = list()
	for(var/mob/new_player/P in player_list)
		if(P.client && P.ready)
			players.Add(P)

	return players


/datum/gamemode/proc/process()
	for(var/datum/faction/F in factions)
		F.process()

/datum/gamemode/proc/check_finished()
	for(var/datum/faction/F in factions)
		if(F.check_win())
			return 1

/datum/gamemode/proc/declare_completion()

/datum/gamemode/proc/AdminPanelEntry()
	var/list/dat = list("<h2>Factions</h2><br>")
	if(factions.len)
		for(var/datum/faction/F in factions)
			dat += F.AdminPanelEntry()
	else
		dat += "No faction is currently active."
	dat += "<br><h2>Roles</h2><br>"
	if(orphaned_roles.len)
		for(var/datum/role/R in orphaned_roles)
			dat += R.AdminPanelEntry()
	else
		dat += "No orphaned role is currently active."
	return dat
