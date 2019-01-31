
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/infiltrator
	name = "Syndicate Infiltrator"
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Warden", "Head of Personnel", "Detective", "Head of Security", "Captain", "Merchant")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI")
	required_candidates = 1
	weight = 7
	cost = 5
	requirements = list(40,30,20,10,10,10,10,10,10,10)

/datum/dynamic_ruleset/latejoin/infiltrator/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))//adding traitors if the antag population is getting low
		return ..()
	else
		return 0

/datum/dynamic_ruleset/latejoin/infiltrator/execute()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind,1)
	newTraitor.Greet(GREET_LATEJOIN)
	return 1


//////////////////////////////////////////////
//                                          //
//        RAGIN' MAGES (LATEJOIN)           ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////1.01 - Lowered weight from 3 to 2

/datum/dynamic_ruleset/latejoin/raginmages
	name = "Ragin' Mages"
	role_category = /datum/role/wizard
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 50
	requirements = list(90,90,70,40,30,20,10,10,10,10)

/datum/dynamic_ruleset/latejoin/raginmages/acceptable(var/population=0,var/threat=0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return 0
	if (locate(/datum/dynamic_ruleset/roundstart/wizard) in mode.executed_rules)
		weight = 10
		cost = 10

	return ..()

/datum/dynamic_ruleset/latejoin/raginmages/execute()
	var/datum/faction/wizard/federation = find_active_faction_by_type(/datum/faction/wizard)
	if (!federation)
		federation = ticker.mode.CreateFaction(/datum/faction/wizard, null, 1)
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/wizard/newWizard = new
	newWizard.AssignToRole(M.mind,1)
	federation.HandleRecruitedRole(newWizard)
	newWizard.Greet(GREET_LATEJOIN)
	return 1


//////////////////////////////////////////////
//                                          //
//           CRAZED WEEABOO             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/weeaboo
	name = "Crazed Weeaboo"
	role_category = /datum/role/weeaboo
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 4
	cost = 10
	requirements = list(90,90,60,20,10,10,10,10,10,10)
	logo = "weeaboo-logo"

/datum/dynamic_ruleset/latejoin/weeaboo/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))
		return ..()
	else
		return 0

/datum/dynamic_ruleset/latejoin/weeaboo/execute()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/weeaboo/newWeeaboo = new
	newWeeaboo.AssignToRole(M.mind,1)
	newWeeaboo.Greet(GREET_DEFAULT)
	newWeeaboo.OnPostSetup()
	newWeeaboo.ForgeObjectives()
	newWeeaboo.AnnounceObjectives()
	return 1

//////////////////////////////////////////////
//                                          //
//      CULT GRANDMASTER (SOLOCULT)         ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/grandmaster
	name = "Cult Grandmaster"
	role_category = /datum/role/cultist
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 50
	requirements = list(90,90,70,40,30,20,10,10,10,10)

/datum/dynamic_ruleset/latejoin/grandmaster/acceptable(var/population=0,var/threat=0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Grandmaster ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Grandmaster ruleset. Couldn't find any wizard spawn points.")
		return 0
	if (find_active_faction_by_type(/datum/faction/bloodcult))
		message_admins("Rejected Grandmaster ruleset. There was already a blood cult.")
		return 0

	return ..()

/datum/dynamic_ruleset/latejoin/grandmaster/execute()
	var/datum/faction/bloodcult/cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/cultist/gm = new
	gm.AssignToRole(M.mind,1)
	cult.HandleRecruitedRole(gm)
	gm.Greet(GREET_LATEJOIN)
	return 1