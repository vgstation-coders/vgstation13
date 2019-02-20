
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
	repeatable = TRUE

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
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/raginmages/ready(var/forced = 0)
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

	repeatable = TRUE

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
	newWeeaboo.AnnounceObjectives()
	return 1

//////////////////////////////////////////////
//                                          //
//       REVOLUTIONARY PROVOCATEUR          ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/provocateur
	name = "Provocateur"
	role_category = /datum/role/revolutionary
	restricted_from_jobs = list("Merchant","AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 2
	cost = 20
	var/required_heads = 3
	requirements = list(101,101,70,40,30,20,20,20,20,20)


/datum/dynamic_ruleset/latejoin/provocateur/ready(var/forced=FALSE)
	if (forced)
		required_heads = 1
	if (find_active_faction_by_type(/datum/faction/revolution))
		return FALSE //Never send 2 rev types
	if(!..())
		return FALSE
	var/head_check = 0
	for (var/mob/new_player/player in mode.living_players)
		if (player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/latejoin/provocateur/execute()
	var/mob/M = pick(candidates)
	assigned += M
	var/antagmind = M.mind
	var/datum/faction/F = ticker.mode.CreateFaction(/datum/faction/revolution, null, 1)
	var/datum/role/revolutionary/leader/L = new(null,F,HEADREV)
	spawn(1 SECONDS)
		L.AssignToRole(antagmind,1)
		L.Greet(GREET_LATEJOIN)
		update_faction_icons()
		L.OnPostSetup()
		F.forgeObjectives()
		L.AnnounceObjectives()
	return 1