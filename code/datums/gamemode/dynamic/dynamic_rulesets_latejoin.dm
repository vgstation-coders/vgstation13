
/*
	* Syndicate Infiltrator
	* Ragin' Mages
	* Space Ninja Attack
	* Pulse Demon Infiltration
	* Grue Infestation
	* Provocateur
	* Time Agent Anomaly
	* Changelings
*/

//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	var/role_id = initial(role_category.id)
	var/role_pref = initial(role_category.required_pref)
	for(var/mob/P in candidates)
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
	weight_category = "Traitor"
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
	weight_category = "Wizard"
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/raginmages/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M))
		return 0
	var/datum/faction/wizard/federation = find_active_faction_by_type(/datum/faction/wizard)
	if (!federation)
		federation = ticker.mode.CreateFaction(/datum/faction/wizard, null, 1)
	var/datum/role/wizard/newWizard = new
	M.forceMove(pick(wizardstart))
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
	weight_category = "Ninja"
	cost = 20
	requirements = list(90,90,60,20,10,10,10,10,10,10)
	high_population_requirement = 20
	logo = "ninja-logo"

	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/ninja/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M))
		return 0
	var/datum/faction/spider_clan/spoider = find_active_faction_by_type(/datum/faction/spider_clan)
	if (!spoider)
		spoider = ticker.mode.CreateFaction(/datum/faction/spider_clan, null, 1)
	var/datum/role/ninja/newninja = new
	M.forceMove(pick(ninjastart))
	newninja.AssignToRole(M.mind,1)
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
	weight_category = "Pulse"
	cost = 25
	requirements = list(70,40,20,20,20,20,15,15,5,5)
	high_population_requirement = 10
	logo = "pulsedemon-logo"

	repeatable = TRUE
	var/list/cables_to_spawn_at = list()


/datum/dynamic_ruleset/latejoin/pulse_demon/ready(var/forced = 0)
	for(var/datum/powernet/PN in powernets)
		for(var/obj/structure/cable/C in PN.cables)
			var/turf/simulated/floor/F = get_turf(C)
			// Cable to spawn at must be on a floor, not tiled over, on the main station, powered and in maint
			if(istype(F,/turf/simulated/floor) && !F.floor_tile && C.z == map.zMainStation && istype(get_area(C),/area/maintenance) && C.powernet.avail)
				cables_to_spawn_at.Add(C)
	if(!cables_to_spawn_at.len)
		log_admin("Cannot accept Pulse Demon ruleset, no suitable cables found.")
		message_admins("Cannot accept Pulse Demon ruleset, no suitable cables found.")
		return 0

	return ..()

/datum/dynamic_ruleset/latejoin/pulse_demon/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M))
		return 0
	var/obj/structure/cable/our_cable = pick(cables_to_spawn_at)
	M.forceMove(get_turf(our_cable))
	var/mob/living/simple_animal/hostile/pulse_demon/PD = new(get_turf(our_cable))
	M.Postmorph(PD)
	var/datum/role/pulse_demon/newpd = new
	newpd.AssignToRole(PD.mind,1)
	newpd.Greet(GREET_DEFAULT)
	newpd.ForgeObjectives()
	newpd.AnnounceObjectives()
	return 1

//////////////////////////////////////////////
//                                          //
//                   GRUE                   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/grue
	name = "Grue Infestation"
	role_category = /datum/role/grue
	enemy_jobs = list()
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Grue"
	cost = 20
	requirements = list(70,60,50,40,30,20,10,10,10,10)
	high_population_requirement = 10
	logo = "grue-logo"
	repeatable = TRUE
	var/list/grue_spawn_spots=list()

/datum/dynamic_ruleset/latejoin/grue/ready(var/forced = 0)
	grue_spawn_spots=list()
	var/list/found_vents = list()
	var/turf/thisturf
	var/vent_visible=0 //used to check if vent is visible by a living player
	for(var/obj/machinery/atmospherics/unary/vent_pump/thisvent in atmos_machines)
		thisturf=get_turf(thisvent)
		if(!thisvent.welded && thisvent.z == map.zMainStation && thisvent.canSpawnMice==1&&thisturf.get_lumcount()<=0.1 && thisvent.network) // Check that the vent isn't welded, is on the main z-level, can spawn mice, is in the dark, and is connected to a pipe network.
			if(thisvent.network.normal_members.len > 50) //only accept vents with suitably large networks
				found_vents.Add(thisvent)
	if(found_vents.len)
		while(found_vents.len > 0)
			var/obj/machinery/atmospherics/unary/vent_pump/thisvent = pick(found_vents)
			found_vents -= thisvent
			vent_visible=0
			for (var/mob/M in player_list)
				if (isliving(M) && (get_dist(M,thisvent) <= 7)) //make sure vent is not in default view range of any living player
					vent_visible=1
			if(!vent_visible)
				grue_spawn_spots+=get_turf(thisvent)
	if(!grue_spawn_spots.len)
		log_admin("Cannot accept Grue ruleset, no suitable spawn locations found.")
		message_admins("Cannot accept Grue ruleset, no spawn locations found.")
		return 0
	return ..()

/datum/dynamic_ruleset/latejoin/grue/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M))
		return 0
	var/our_spawnspot = pick(grue_spawn_spots)
	M.forceMove(our_spawnspot)
	var/mob/living/simple_animal/hostile/grue/gruespawn/ourgrue = new(our_spawnspot)
	M.Postmorph(ourgrue)
	var/datum/role/grue/newgrue = new
	newgrue.AssignToRole(ourgrue.mind,1)
	newgrue.Greet(GREET_DEFAULT)
	newgrue.ForgeObjectives(ourgrue.hatched) //Assign it grue_basic objectives if its a hatched grue (likely wont be here but just in case)
	newgrue.AnnounceObjectives()
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
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_pop = list(20,20,15,15,15,15,15,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Revolution"
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
	if (head_check < required_heads)
		log_admin("Cannot accept Provocateur ruleset, not enough heads of staff.")
		message_admins("Cannot accept Provocateur ruleset, not enough heads of staff.")
		return FALSE
	return TRUE

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

//////////////////////////////////////////////
//                                          //
//               TIME AGENT                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/time_agent
	name = "Time Agent Anomaly"
	role_category = /datum/role/time_agent
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT * 0.4
	cost = 10
	requirements = list(70, 60, 50, 40, 30, 20, 10, 10, 10, 10)
	logo = "time-logo"
	weight_category = "Time"


/datum/dynamic_ruleset/latejoin/time_agent/ready(var/forced=0)
	if (forced)
		return ..()
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if(required_candidates > (mode.dead_players.len + mode.list_observers.len) || antag_count >= max_traitors)
		return 0
	return ..()

/datum/dynamic_ruleset/latejoin/time_agent/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M))
		return 0
	var/datum/faction/time_agent/agency = find_active_faction_by_type(/datum/faction/time_agent)
	if (!agency)
		agency = ticker.mode.CreateFaction(/datum/faction/time_agent, null, 1)
	var/datum/role/time_agent/newagent = new
	M.forceMove(pick(timeagentstart))
	newagent.AssignToRole(M.mind,1)
	agency.HandleRecruitedRole(newagent)
	newagent.Greet(GREET_DEFAULT)
	return 1

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/changeling
	name = "Changelings"
	role_category = /datum/role/changeling
	protected_from_jobs = list("Security Officer", "Warden","Merchant", "Head of Personnel", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Medic")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI")
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_pop = list(15,15,15,10,10,10,10,5,5,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Changeling"
	cost = 20
	requirements = list(80,70,60,60,30,20,10,10,10,10)
	high_population_requirement = 30
	repeatable = FALSE

/datum/dynamic_ruleset/latejoin/changeling/execute()
	var/mob/M = pick(assigned)
	var/datum/role/changeling/newChangeling = new
	newChangeling.AssignToRole(M.mind,1)
	newChangeling.Greet(GREET_LATEJOIN)
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		hivemind = ticker.mode.CreateFaction(/datum/faction/changeling)
		hivemind.OnPostSetup()
	hivemind.HandleRecruitedRole(newChangeling)
	return 1

/datum/dynamic_ruleset/latejoin/changeling/previous_rounds_odds_reduction(var/result)
	return result
