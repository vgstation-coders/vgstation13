// -- General rulesets types --

/datum/dynamic_ruleset/midround/from_ghosts
	var/flags

/datum/dynamic_ruleset/midround/from_ghosts/execute()
	var/list/possible_candidates = list()
	possible_candidates.Add(dead_players)
	possible_candidates.Add(list_observers)
	send_applications(possible_candidates)
	return 1

/datum/dynamic_ruleset/midround/from_ghosts/review_applications()
	for (var/i = required_candidates, i > 0, i--)
		if(applicants.len <= 0)
			break
		var/mob/applicant = pick(applicants)
		if(!isobserver(applicant))
			//Making sure we don't recruit people who got back into the game since they applied
			i++
			continue

		var/mob/living/carbon/human/new_character = makeBody(applicant)
		new_character.dna.ResetSE()

		finish_setup(new_character, i)

	applicants.Cut()

/datum/dynamic_ruleset/midround/from_ghosts/proc/finish_setup(var/mob/new_character, var/index)
	var/datum/role/new_role = new role_category
	new_role.AssignToRole(new_character.mind,1)
	setup_role(new_role)

/datum/dynamic_ruleset/midround/from_ghosts/proc/setup_role(var/datum/role/new_role)
	new_role.OnPostSetup()
	new_role.Greet(GREET_MIDROUND)
	new_role.ForgeObjectives()
	new_role.AnnounceObjectives()

// -- Faction based --

/datum/dynamic_ruleset/midround/from_ghosts/faction_based
	var/datum/faction/my_fac = null // If the midround lawset will try to add our antag to a faction

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/review_applications()
	var/datum/faction/active_fac = find_active_faction_by_type(my_fac)
	if (!my_fac)
		active_fac = ticker.mode.CreateFaction(my_fac, null, 1)
	my_fac = active_fac
	. = ..()
	my_fac.OnPostSetup()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/setup_role(var/datum/role/new_role)
	my_fac.HandleRecruitedRole(new_role)
	return ..()

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Cyborg", "Merchant")
	restricted_from_jobs = list("AI","Mobile MMI")
	required_candidates = 1
	weight = 7
	cost = 5
	requirements = list(50,40,30,20,10,10,10,10,10,10)

/datum/dynamic_ruleset/midround/autotraitor/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))//adding traitors if the antag population is getting low
		return ..()
	else
		return 0

/datum/dynamic_ruleset/midround/autotraitor/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(player.z == map.zCentcomm)
			living_players -= player//we don't autotator people on Z=2
			continue
		if(player.mind && (player.mind.antag_roles.len > 0))
			living_players -= player//we don't autotator people with roles already

/datum/dynamic_ruleset/midround/autotraitor/ready(var/forced = 0)
	if (required_candidates > living_players.len)
		return 0
	return ..()

/datum/dynamic_ruleset/midround/autotraitor/execute()
	var/mob/M = pick(living_players)
	assigned += M
	living_players -= M
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind,1)
	newTraitor.OnPostSetup()
	newTraitor.Greet(GREET_AUTOTATOR)
	newTraitor.ForgeObjectives()
	newTraitor.AnnounceObjectives()
	return 1

//////////////////////////////////////////////
//                                          //
//              RAGIN' MAGES                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////1.01 - Disabled because it caused a bit too many wizards in rounds

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages
	name = "Ragin' Mages"
	role_category = /datum/role/wizard
	my_fac = /datum/faction/wizard
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 50
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	logo = "raginmages-logo"

/datum/dynamic_ruleset/midround/raginmages/from_ghosts/faction_based/acceptable(var/population=0,var/threat=0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return 0
	if (locate(/datum/dynamic_ruleset/roundstart/wizard) in mode.executed_rules)
		weight = 5
		cost = 10

	return ..()

/datum/dynamic_ruleset/midround/raginmages/from_ghosts/faction_based/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear
	name = "Nuclear Assault"
	role_category = /datum/role/nuclear_operative
	my_fac = /datum/faction/syndicate/nuke_op/
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 5
	weight = 5
	cost = 35
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	logo = "nuke-logo"

/datum/dynamic_ruleset/midround/nuclear/from_ghosts/faction_based/nuclear/acceptable(var/population=0,var/threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return 0//unavailable if nuke ops were already sent at roundstart
	return ..()

/datum/dynamic_ruleset/midround/nuclear/from_ghosts/faction_based/nuclear/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/finish_setup(var/mob/new_character, var/index)
	if (index == 1) // Our first guy is the leader
		var/datum/role/new_role = new role_category
		new_role.AssignToRole(new_character.mind,1)
		setup_role(new_role)
	else
		return ..()


	
//////////////////////////////////////////////
//                                          //
//         SPACE WEEABOO (MIDROUND)                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/weeabo
	name = "crazed weeaboo attack"
	role_category = /datum/role/weeaboo
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 10
	requirements = list(90,90,80,70,60,50,40,30,20,10)
	logo = "weeaboo-logo"

/datum/dynamic_ruleset/midround/from_ghosts/weeaboo/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))
		return ..()
	else
		return 0

/datum/dynamic_ruleset/midround/from_ghosts/weeaboo/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

//////////////////////////////////////////////
//                                          //
//               THE GRINCH (holidays)      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/grinch
	name = "The Grinch"
	role_category = /datum/role/grinch
	restricted_from_jobs = list()
	enemy_jobs = list()
	required_enemies = list(0,0,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 10
	requirements = list(40,20,10,10,10,10,10,10,10,10) // So that's not possible to roll it naturally

/datum/dynamic_ruleset/midround/grinch/from_ghosts/acceptable(var/population=0, var/threat=0)
	if(grinchstart.len == 0)
		log_admin("Cannot accept Grinch ruleset. Couldn't find any grinch spawn points.")
		message_admins("Cannot accept Grinch ruleset. Couldn't find any grinch spawn points.")
		return 0
	if (!..())
		return FALSE
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	var/accepted = (MM == 12 && DD > 15) || (MM == 1 && DD < 15) 	// Between the 15th of December and the 15th of January
	return accepted