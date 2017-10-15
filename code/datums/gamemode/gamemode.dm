/*
	Gamemode datums
		Used for co-ordinating factions in a round, what factions should be in operation, etc.

	@name: String: The name of the gamemode, e.g. Changelings
	@factions: List(reference): What factions are currently in operation in the gamemode
	@factions_allowed: List(object): what factions will the gamemode start with, or attempt to start with
	@minimum_player_count: Integer: Minimum required players to start the gamemode
	@admin_override: Overrides certain checks such as the one above to force-start a gamemode



*/


/datum/gamemode
	var/name = "Gamemode Parent"
	var/list/factions = list()
	var/list/factions_allowed = list()
	var/minimum_player_count
	var/admin_override //Overrides checks such as minimum_player_count to

/datum/gamemode/New()
	Setup()

/datum/gamemode/proc/Setup()
	if(minimum_player_count < get_player_count())
		TearDown()
	CreateFactions()

/datum/gamemode/proc/CreateFactions()
	var/pc = get_player_count() //right proc?
	for(var/datum/faction/Fac in factions_allowed)
		new Fac
		if(Fac.can_setup(pc))
			factions += Fac
			factions_allowed -= Fac
		else
			message_admins("Unable to start [Fac.name]")
			qdel(Fac)
	for(var/datum/faction/F in factions)
		F.onPostSetup()
	PopulateFactions()

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
			if(!P.client /*|| Other bullshit*/)
				return
			//TODO PREFERENCE FUCKERY AND ROLE CHECKING -- NO ROLE DATUMS AS OF THIS TIME

/datum/gamemode/proc/CheckObjectives(var/individuals = FALSE)
	var/dat = ""
	for(var/datum/faction/F in factions)
		dat += F.GetObjectivesMenuHeader()
		dat += F.CheckAllObjectives(individuals)
		dat += "\n\n"
	return dat

/datum/gamemode/proc/TearDown()
	//No idea what this is supposed to do

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