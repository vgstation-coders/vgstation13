//////////////////////////////////////////////
//                                          //
//            MIDROUND RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround//Can be drafted once in a while during a round
	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

/datum/dynamic_ruleset/midround/from_ghosts/
	weight = 0
	var/makeBody = TRUE

/datum/dynamic_ruleset/midround/trim_candidates()
	//unlike the previous two types, these rulesets are not meant for /mob/new_player
	//and since I want those rulesets to be as flexible as possible, I'm not gonna put much here,
	//but be sure to check dynamic_rulesets_debug.dm for an example.
	//
	//all you need to know is that here, the candidates list contains 4 lists itself, indexed with the following defines:
	//candidates = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	//so for example you can get the list of all current dead players with var/list/dead_players = candidates[CURRENT_DEAD_PLAYERS]
	//make sure to properly typecheck the mobs in those lists, as the dead_players list could contain ghosts, or dead players still in their bodies.
	//we're still gonna trim the obvious (mobs without clients, jobbanned players, etc)
	living_players = trim_list(candidates[CURRENT_LIVING_PLAYERS])
	living_antags = trim_list(candidates[CURRENT_LIVING_ANTAGS])
	dead_players = trim_list(candidates[CURRENT_DEAD_PLAYERS])
	list_observers = trim_list(candidates[CURRENT_OBSERVERS])

/datum/dynamic_ruleset/midround/proc/trim_list(var/list/L = list())
	var/list/trimmed_list = L.Copy()
	var/role_id = initial(role_category.id)
	var/role_pref = initial(role_category.required_pref)
	for(var/mob/M in trimmed_list)
		if (!M.client)//are they connected?
			trimmed_list.Remove(M)
			continue
		if (!M.client.desires_role(role_pref) || jobban_isbanned(M, role_id) || isantagbanned(M))//are they willing and not antag-banned?
			trimmed_list.Remove(M)
			continue
		if (M.mind)
			if (M.mind.assigned_role in restricted_from_jobs || M.mind.role_alt_title in restricted_from_jobs)//does their job allow for it?
				trimmed_list.Remove(M)
				continue
			if (M.mind.assigned_role in protected_from_jobs || M.mind.role_alt_title in protected_from_jobs)
				var/probability = initial(role_category.protected_traitor_prob)
				if (prob(probability))
					candidates.Remove(M)
			if ((exclusive_to_jobs.len > 0) && !(M.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
				trimmed_list.Remove(M)
				continue
	return trimmed_list

//You can then for example prompt dead players in execute() to join as strike teams or whatever
//Or autotator someone

//IMPORTANT, since /datum/dynamic_ruleset/midround may accept candidates from both living, dead, and even antag players, you need to manually check whether there are enough candidates
// (see /datum/dynamic_ruleset/midround/autotraitor/ready(var/forced = 0) for example)
/datum/dynamic_ruleset/midround/ready(var/forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_jobs.len > 0)
			for (var/mob/M in living_players)
				if (M.stat == DEAD)
					continue//dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_jobs) && (!(M in candidates) || (M.mind.assigned_role in restricted_from_jobs)))
					job_check++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return 0
	return 1

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
		applicants -= applicant
		if(!isobserver(applicant))
			//Making sure we don't recruit people who got back into the game since they applied
			i++
			continue

		var/mob/living/carbon/human/new_character = applicant

		if (makeBody)
			new_character = makeBody(applicant)
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
	weight = 0
	var/datum/faction/my_fac = null // If the midround lawset will try to add our antag to a faction

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/review_applications()
	var/datum/faction/active_fac = find_active_faction_by_type(my_fac)
	var/new_faction = 0
	if (!active_fac)
		new_faction = 1
		active_fac = ticker.mode.CreateFaction(my_fac, null, 1)
	my_fac = active_fac
	. = ..()
	if (new_faction)
		my_fac.OnPostSetup()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/setup_role(var/datum/role/new_role)
	my_fac.HandleRecruitedRole(new_role)
	new_role.Greet(GREET_MIDROUND)
	new_role.ForgeObjectives()
	new_role.AnnounceObjectives()

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
	cost = 10
	requirements = list(50,40,30,20,10,10,10,10,10,10)
	repeatable = TRUE

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
		if(isAI(player) || isMoMMI(player))
			living_players -= player //Your assigned role doesn't change when you are turned into a MoMMI or AI
			continue
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
//         Malfunctioning AI                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//               Bus Only                   //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/malf
	name = "Malfunctioning AI"
	role_category = /datum/role/malfAI
	enemy_jobs = list("Security Officer", "Warden","Detective","Head of Security", "Captain", "Scientist", "Chemist", "Research Director", "Chief Engineer")
	exclusive_to_jobs = list("AI")
	required_enemies = list(4,4,4,4,4,4,2,2,2,0)
	required_candidates = 1
	weight = 0
	cost = 101
	requirements = list(101,101,101,101,101,101,101,101,101,101)

/datum/dynamic_ruleset/midround/malf/trim_candidates()
	..()
	candidates = candidates[CURRENT_LIVING_PLAYERS]
	for(var/mob/living/player in candidates)
		if(!isAI(player))
			candidates -= player
			continue
		if(player.z == map.zCentcomm)
			candidates -= player//we don't autotator people on Z=2
			continue
		if(player.mind && (player.mind.antag_roles.len > 0))
			candidates -= player//we don't autotator people with roles already

/datum/dynamic_ruleset/midround/malf/execute()
	var/datum/faction/malf/unction = find_active_faction_by_type(/datum/faction/malf)
	if (!unction)
		unction = ticker.mode.CreateFaction(/datum/faction/malf, null, 1)
	if(!candidates || !candidates.len)
		return 0
	var/mob/living/silicon/ai/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/malfAI/AI = new
	AI.AssignToRole(M.mind,1)
	unction.HandleRecruitedRole(AI)
	AI.Greet(GREET_ROUNDSTART)
	for(var/mob/living/silicon/robot/R in M.connected_robots)
		unction.HandleRecruitedMind(R.mind)
	unction.forgeObjectives()
	unction.AnnounceObjectives()
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
	repeatable = TRUE

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages/acceptable(var/population=0,var/threat=0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return 0
	if (locate(/datum/dynamic_ruleset/roundstart/wizard) in mode.executed_rules)
		weight = 5
		cost = 10
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages/setup_role(var/datum/role/new_role)
	..()
	if(!locate(/datum/dynamic_ruleset/roundstart/wizard) in mode.executed_rules)
		new_role.refund_value = BASE_SOLO_REFUND * 4
		//If it's a spontaneous ragin' mage, it costs more, so refund more
	else
		new_role.refund_value = BASE_SOLO_REFUND/2
		//We have plenty of threat to go around

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
	var/operative_cap = list(2,2,3,3,4,5,5,5,5,5)
	logo = "nuke-logo"

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/acceptable(var/population=0,var/threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return 0//unavailable if nuke ops were already sent at roundstart
	var/indice_pop = min(10,round(living_players.len/5)+1)
	required_candidates = operative_cap[indice_pop]
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/finish_setup(var/mob/new_character, var/index)
	var/datum/faction/syndicate/nuke_op/nuclear = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	nuclear.forgeObjectives()
	if (index == 1) // Our first guy is the leader
		var/datum/role/nuclear_operative/leader/new_role = new
		new_role.AssignToRole(new_character.mind,1)
		setup_role(new_role)
	else
		return ..()

//////////////////////////////////////////////
//                                          //
//          BLOB STORM			 (MIDROUND) ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/blob_storm
	name = "Blob Overmind Storm"
	role_category = /datum/role/blob_overmind/
	my_fac = /datum/faction/blob_conglomerate/
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 1
	weight = 5
	cost = 35
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	logo = "blob-logo"

	makeBody = FALSE

// -- The offsets are here so that the cone of meteors always meet the station. Blob meteors shouldn't miss the station, else a blob would spawn outside of the main z-level.

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/blob_storm/finish_setup(var/mob/new_character, var/index)
	var/chosen_dir = meteor_wave(rand(20, 40), types = thing_storm_types["blob storm"], offset_origin = 150, offset_dest = 230)
	var/obj/item/projectile/meteor/blob/core/meteor = spawn_meteor(chosen_dir, /obj/item/projectile/meteor/blob/core, offset_origin = 150, offset_dest = 230)
	meteor.AssignMob(new_character)
	return 1 // The actual role (and faction) are created upon impact.


/datum/dynamic_ruleset/midround/from_ghosts/faction_based/blob_storm/review_applications()
	command_alert(/datum/command_alert/blob_storm/overminds)
	. = ..()
	spawn (60 SECONDS)
		command_alert(/datum/command_alert/blob_storm/overminds/end)

//////////////////////////////////////////////
//                                          //
//            REVSQUAD (MIDROUND)           ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad
	name = "Revolutionary Squad"
	role_category = /datum/role/revolutionary/leader
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 3
	weight = 5
	cost = 45
	requirements = list(101,101,90,60,45,45,45,45,45,45)
	my_fac = /datum/faction/revolution
	logo = "rev-logo"
	var/required_heads = 3

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad/ready(var/forced = 0)
	if (find_active_faction_by_type(/datum/faction/revolution))
		return FALSE //Never send 2 rev types
	if (required_candidates > (dead_players.len + list_observers.len))
		return FALSE
	if(!..())
		return FALSE
	var/head_check = 0
	for (var/mob/player in mode.living_players)
		if(!player.mind)
			continue
		if(player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)


//////////////////////////////////////////////
//                                          //
//         SPACE WEEABOO (MIDROUND)         ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/weeaboo
	name = "crazed weeaboo attack"
	role_category = /datum/role/weeaboo
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 4
	cost = 10
	requirements = list(90,90,60,20,10,10,10,10,10,10)
	logo = "weeaboo-logo"
	repeatable = TRUE

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

/datum/dynamic_ruleset/midround/from_ghosts/grinch/acceptable(var/population=0, var/threat=0)
	if(grinchstart.len == 0)
		log_admin("Cannot accept Grinch ruleset. Couldn't find any grinch spawn points.")
		message_admins("Cannot accept Grinch ruleset. Couldn't find any grinch spawn points.")
		return 0
	if (!..())
		return FALSE
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	var/accepted = (MM == 12 && DD > 15) || (MM == 1 && DD < 9) 	// Between the 15th of December and the 9th of January
	return accepted

//////////////////////////////////////////////
//                                          //
//               LOOSE CATBEAST             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                 Minor Role               //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/catbeast
	name = "Loose Catbeast"
	role_category = /datum/role/catbeast
	required_candidates = 1
	weight = 1
	cost = 0
	requirements = list(0,0,0,0,0,0,0,0,0,0)
	logo = "catbeast-logo"

/datum/dynamic_ruleset/midround/from_ghosts/catbeast/acceptable(var/population=0,var/threat=0)
	if(mode.threat>50) //We're threatening enough!
		message_admins("Rejected catbeast ruleset, [mode.threat] threat was over 50.")
		return FALSE
	if(!..())
		message_admins("Rejected catbeast ruleset. Not enough threat somehow??")
		return FALSE
	return TRUE