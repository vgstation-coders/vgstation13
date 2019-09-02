//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	var/role_id = initial(role_category.id)
	var/role_pref = initial(role_category.required_pref)
	for(var/mob/new_player/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if (!P.client.desires_role(role_pref) || jobban_isbanned(P, role_id) || isantagbanned(P) || (role_category_override && jobban_isbanned(P, role_category_override)))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in protected_from_jobs)
			var/probability = initial(role_category.protected_traitor_prob)
			if (prob(probability))
				candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_from_jobs)//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(var/forced = 0)
	if (!forced)
		if(!check_enemy_jobs(TRUE))
			return 0
	return ..()


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
	high_population_requirement = 10
	repeatable = TRUE
	flags = TRAITOR_RULESET

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
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/raginmages/ready(var/forced = 0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return 0

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
//               SPACE NINJA                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/ninja
	name = "Space Ninja Attack"
	role_category = /datum/role/ninja
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 20
	requirements = list(90,90,60,20,10,10,10,10,10,10)
	high_population_requirement = 20
	logo = "ninja-logo"

	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/ninja/execute()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/ninja/newninja = new
	newninja.AssignToRole(M.mind,1)
	newninja.Greet(GREET_DEFAULT)
	newninja.OnPostSetup()
	newninja.AnnounceObjectives()
	spawn(1) //TODO - FIX THE NEED FOR THIS. CHECK PR, CHECK THE REVERTED COMMIT
		if(!newninja.antag.current.ThrowAtStation())
			newninja.antag.current.spawn_rand_maintenance()
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
	high_population_requirement = 50
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/latejoin/provocateur/ready(var/forced=FALSE)
	if (forced)
		required_heads = 1
	if (find_active_faction_by_type(/datum/faction/revolution))
		return FALSE //Never send 2 rev types
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.living_players)
		if (player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/latejoin/provocateur/execute()
	var/mob/M = pick(candidates)
	assigned += M
	var/antagmind = M.mind
	var/datum/faction/F = ticker.mode.CreateFaction(/datum/faction/revolution, null, 1)
	F.forgeObjectives()
	spawn(1 SECONDS)
		var/datum/role/revolutionary/leader/L = new(antagmind,F,HEADREV)
		L.Greet(GREET_LATEJOIN)
		L.OnPostSetup()
		update_faction_icons()
	return 1
