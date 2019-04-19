/*
	Gamemode datums
		Used for co-ordinating factions in a round, what factions should be in operation, etc.
	@name: String: The name of the gamemode, e.g. Changelings
	@factions: List(reference): What factions are currently in operation in the gamemode
	@factions_allowed: List(object): what factions will the gamemode start with, or attempt to start with
	@minimum_player_count: Integer: Minimum required players to start the gamemode
	@admin_override: Overrides certain checks such as the one above to force-start a gamemode
	@roles_allowed: List(object): What roles will the gamemode start with, or attempt to start with
	@probability: Integer: How likely it is to roll this gamemode
	@votable: Boolean: If this mode can be voted for
	@orphaned_roles: List(reference): List of faction-less roles currently in the gamemode
*/


/datum/gamemode
	var/name = "Gamemode Parent"
	var/list/factions = list()
	var/list/factions_allowed = list()
	var/minimum_player_count
	var/admin_override //Overrides checks such as minimum_player_count to
	var/list/roles_allowed = list()
	var/probability = 50
	var/votable = TRUE
	var/list/orphaned_roles = list()
	var/dat = ""

/datum/gamemode/proc/can_start()
	if(minimum_player_count && minimum_player_count < get_player_count())
		return 0
	return 1

//For when you need to set factions and factions_allowed not on compile
/datum/gamemode/proc/SetupFactions()

// Infos on the mode.
/datum/gamemode/proc/AdminPanelEntry()
	return

/datum/gamemode/proc/Setup()
	if(minimum_player_count && minimum_player_count < get_player_count())
		TearDown()
		return 0
	SetupFactions()
	var/FactionSuccess = CreateFactions()
	var/RolesSuccess = CreateRoles()
	return FactionSuccess && RolesSuccess

//1 = station, 2 = centcomm
/datum/gamemode/proc/ShuttleDocked(var/state)
	for(var/datum/faction/F in factions)
		F.ShuttleDocked(state)
	for(var/datum/role/R in orphaned_roles)
		R.ShuttleDocked(state)

/*===FACTION RELATED STUFF===*/

/datum/gamemode/proc/CreateFactions(var/list/factions_to_process, var/populate_factions = TRUE)
	if(factions_to_process == null)
		factions_to_process = factions_allowed
	var/pc = get_player_count() //right proc?
	for(var/Fac in factions_to_process)
		if(islist(Fac))
			var/list/L = Fac
			CreateFactions(L, FALSE)
		else
			CreateFaction(Fac, pc)
	if(populate_factions)
		return PopulateFactions()

/datum/gamemode/proc/CreateFaction(var/Fac, var/population, var/override = 0)
	var/datum/faction/F = new Fac
	if(F.can_setup(population) || override)
		factions += F
		factions_allowed -= F
		return F
	else
		warning("Faction ([F]) could not set up properly with given population.")
		qdel(F)
		return null
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
				stack_trace("[P.mind] failed [F] HandleNewMind!")
				continue
	return 1


/*=====ROLE RELATED STUFF=====*/

/datum/gamemode/proc/CreateRoles() //Must return 1 in some way, else the gamemode is scrapped.
	if(!roles_allowed.len) //No roles to handle
		return 1
	for(var/role in roles_allowed)
		if(isnum(roles_allowed[role]))
			return CreateStrictNumOfRoles(role, roles_allowed[role])
		else
			CreateNumOfRoles(role, FilterAvailablePlayers(role))
			return 1

/datum/gamemode/proc/CreateNumOfRoles(var/datum/role/R, var/list/candidates)
	if(!candidates || !candidates.len)
		WARNING("ran out of available players to fill role [R]!")
		return
	for(var/mob/M in candidates)
		CreateRole(R, M)

/datum/gamemode/proc/CreateStrictNumOfRoles(var/datum/role/R, var/num)
	var/number_of_roles = 0
	var/list/available_players = FilterAvailablePlayers(R)
	for(var/i = 0 to num)
		if(!available_players.len)
			WARNING("ran out of available players to fill role [R]!")
			break
		shuffle(available_players)
		var/mob/new_player/P = pick(available_players)
		available_players.Remove(P)
		if(!CreateRole(R, P))
			i--
			continue
		number_of_roles++ // Get the roles we created
	return number_of_roles


/datum/gamemode/proc/CreateBasicRole(var/type_role)
	return new type_role

/datum/gamemode/proc/FilterAvailablePlayers(var/datum/role/R, var/list/players_to_choose = get_ready_players())
	for(var/mob/new_player/P in players_to_choose)
		if(!P.client || !P.mind)
			players_to_choose.Remove(P)
			continue
		if(!P.client.desires_role(initial(R.required_pref)) || jobban_isbanned(P, initial(R.required_pref)))
			players_to_choose.Remove(P)
			continue
	if(!players_to_choose.len)
		warning("No available players for [R]")
	return players_to_choose

/datum/gamemode/proc/CreateRole(var/datum/role/R, var/mob/P)
	var/datum/role/newRole = CreateBasicRole(R)

	if(!newRole)
		warning("Role killed itself or was otherwise missing!")
		return 0

	if(!newRole.AssignToRole(P.mind))
		warning("Role refused mind and dropped!")
		newRole.Drop()
		return 0

	return 1

/datum/gamemode/proc/latespawn(var/mob/mob) //Check factions, see if anyone wants a latejoiner
	var/list/possible_factions = list()
	for(var/datum/faction/F in factions)
		if(F.max_roles && F.members.len >= F.max_roles)
			continue
		if(!mob.client || !mob.mind)
			continue
		if(!mob.client.desires_role(F.required_pref) || jobban_isbanned(mob, F.required_pref))
			continue
		if(F.accept_latejoiners)
			possible_factions.Add(F)
	if(possible_factions.len)
		var/datum/faction/F = pick(possible_factions)
		F.HandleRecruitedMind(mob.mind)

/datum/gamemode/proc/PostSetup()
	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	spawn (rand(INTERCEPT_TIME_LOW , INTERCEPT_TIME_HIGH))
		send_intercept()

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(ticker && ticker.mode)
		feedback_set_details("game_mode","[ticker.mode]")
	if(revdata)
		feedback_set_details("revision","[revdata.revision]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")

	for(var/datum/faction/F in factions)
		F.forgeObjectives()
		F.OnPostSetup()
	for(var/datum/role/R in orphaned_roles)
		R.ForgeObjectives()
		R.AnnounceObjectives()
		R.OnPostSetup()
	return 1

/datum/gamemode/proc/TearDown()
	// This is where the game mode is shut down and cleaned up.

/datum/gamemode/proc/GetScoreboard()
	dat += "<h2>Factions & Roles</h2>"
	var/exist = 0
	for(var/datum/faction/F in factions)
		if (F.members.len > 0)
			exist = 1
			dat += F.GetObjectivesMenuHeader()
			dat += F.GetScoreboard()
			dat += "<HR>"
	if (orphaned_roles.len > 0)
		dat += "<FONT size = 2><B>Independents:</B></FONT><br>"
	for(var/datum/role/R in orphaned_roles)
		exist = 1
		dat += R.GetScoreboard()
	if (!exist)
		dat += "(none)"
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
	for(var/datum/role/R in orphaned_roles)
		R.process()

/datum/gamemode/proc/check_finished()
	for(var/datum/faction/F in factions)
		if (F.check_win())
			return 1
	if(emergency_shuttle.location==2 || ticker.station_was_nuked)
		return 1
	return 0


/datum/gamemode/proc/declare_completion()
	return GetScoreboard()

/datum/gamemode/proc/mob_destroyed(var/mob/M)
	return