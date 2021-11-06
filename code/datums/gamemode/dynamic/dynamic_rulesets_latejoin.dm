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
		if ((P.mind.assigned_role && (P.mind.assigned_role in protected_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in protected_from_jobs)))
			var/probability = initial(role_category.protected_traitor_prob)
			if (prob(probability))
				candidates.Remove(P)
			continue
		if ((P.mind.assigned_role && (P.mind.assigned_role in restricted_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in restricted_from_jobs)))//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(var/forced = 0)
	if (!forced)
		if(!check_enemy_jobs(TRUE,TRUE))
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
	protected_from_jobs = list("Security Officer", "Warden", "Head of Personnel", "Detective", "Head of Security",
							"Captain", "Merchant", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Medic")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI")
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 5
	requirements = list(40,30,20,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE
	flags = TRAITOR_RULESET

/datum/dynamic_ruleset/latejoin/infiltrator/execute()
	var/mob/M = pick(assigned)
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind,1)
	newTraitor.Greet(GREET_LATEJOIN)
	return 1

/datum/dynamic_ruleset/latejoin/infiltrator/previous_rounds_odds_reduction(var/result)
	return result


//////////////////////////////////////////////
//                                          //
//        RAGIN' MAGES (LATEJOIN)           ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////1.01 - Lowered weight from 3 to 2

/datum/dynamic_ruleset/latejoin/raginmages
	name = "Ragin' Mages"
	role_category = /datum/role/wizard
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_pop = list(15,15,10,10,10,10,10,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT/2
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
	var/mob/M = pick(assigned)
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
	required_pop = list(15,15,10,10,10,10,10,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 20
	requirements = list(90,90,60,20,10,10,10,10,10,10)
	high_population_requirement = 20
	logo = "ninja-logo"

	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/ninja/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M,src))
		message_admins("[M.key] has opted out of becoming a ninja.")
		return 0
	var/datum/role/ninja/newninja = new
	newninja.AssignToRole(M.mind,1)
	var/datum/faction/spider_clan/spoider = find_active_faction_by_type(/datum/faction/spider_clan)
	if (!spoider)
		spoider = ticker.mode.CreateFaction(/datum/faction/spider_clan, null, 1)
	spoider.HandleRecruitedRole(newninja)
	newninja.Greet(GREET_DEFAULT)
	return 1


//////////////////////////////////////////////
//                                          //
//                PULSE DEMON               ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/pulse_demon
	name = "Pulse Demon Infiltration"
	role_category = /datum/role/pulse_demon
	enemy_jobs = list("Station Engineer","Chief Engineer")
	required_enemies = list(1,1,1,1,1,1,1,1,1,1)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 25
	requirements = list(5,5,15,15,20,20,20,20,40,70)
	high_population_requirement = 10
	logo = "pulsedemon-logo"
	
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/pulse_demon/execute()
	var/mob/M = pick(assigned)
	var/turf/oldloc = get_turf(M)
	M.forceMove(null)
	if(!latejoinprompt(M,src))
		message_admins("[M.key] has opted out of becoming a pulse demon.")
		M.forceMove(oldloc)
		return 0
	var/list/cables_to_spawn_at = list()
	for(var/datum/powernet/PN in powernets)
		for(var/obj/structure/cable/C in PN.cables)
			var/turf/simulated/floor/F = get_turf(C)
			if(istype(F,/turf/simulated/floor) && !F.floor_tile)
				cables_to_spawn_at.Add(C)
	var/obj/structure/cable/our_cable = pick(cables_to_spawn_at)
	M.forceMove(get_turf(our_cable))
	var/mob/living/simple_animal/hostile/pulse_demon/PD = new(get_turf(our_cable))
	PD.key = M.key
	qdel(M)
	var/datum/role/pulse_demon/newpd = new
	newpd.AssignToRole(PD.mind,1)
	newpd.Greet(GREET_DEFAULT)
	newpd.ForgeObjectives()
	newpd.AnnounceObjectives()
	return 1


//////////////////////////////////////////////
//                                          //
//       REVOLUTIONARY PROVOCATEUR          ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/provocateur
	name = "Provocateur"
	role_category = /datum/role/revolutionary
	restricted_from_jobs = list("Merchant", "Brig Medic", "AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_pop = list(20,20,15,15,15,15,15,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
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
	var/mob/M = pick(assigned)
	var/antagmind = M.mind
	var/datum/faction/F = ticker.mode.CreateFaction(/datum/faction/revolution, null, 1)
	F.forgeObjectives()
	spawn(1 SECONDS)
		var/datum/role/revolutionary/leader/L = new(antagmind,F,HEADREV)
		L.Greet(GREET_LATEJOIN)
		L.OnPostSetup()
		update_faction_icons()
	return 1
