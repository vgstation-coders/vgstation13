/datum/gamemode
	name = "Gamemode Parent"
	var/list/factions = list()
	var/list/factions_allowed = list()

/datum/gamemode/New()
	Setup()

/datum/gamemode/proc/Setup()
	CreateFactions()
	return

/datum/gamemode/proc/CreateFactions()
	var/pc = get_player_count() //right proc?
	var/fnum = 1
	switch(pc)
		if() //Number of factions needs to depend on player count for most modes
			fnum =
	for(var/i = 1 to fnum)
		var/datum/faction/Fac = pick(factions_allowed)
			new Fac
			factions += Fac
			factions_allowed -= Fac
	for(var/datum/faction/F in factions)
		F.onPostSetup()
	PopulateFactions(pc)

/datum/gamemode/proc/PopulateFactions(var/playercount)
	if(!playercount)
		playercount = get_player_count()
	//probably use a var for antags to make per player

/datum/gamemode/proc/CheckObjectives(var/individuals = FALSE)
	var/dat = ""
	for(var/datum/faction/F in factions)
		dat += F.GetObjectivesMenuHeader()
		dat += F.CheckAllObjectives(individuals)
	return dat

/datum/gamemode/proc/GetScoreboard()
	var/dat =""
	for(var/datum/faction/F in factions)
		dat += F.GetScoreboard()
	return dat