
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

/datum/dynamic_ruleset/midround/raginmages
	name = "Ragin' Mages"
	role_category = /datum/role/wizard
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 50
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	logo = "raginmages-logo"

/datum/dynamic_ruleset/midround/raginmages/acceptable(var/population=0,var/threat=0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return 0
	if (locate(/datum/dynamic_ruleset/roundstart/wizard) in mode.executed_rules)
		weight = 5
		cost = 10

	return ..()

/datum/dynamic_ruleset/midround/raginmages/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

/datum/dynamic_ruleset/midround/raginmages/execute()
	var/list/possible_candidates = list()
	possible_candidates.Add(dead_players)
	possible_candidates.Add(list_observers)
	send_applications(possible_candidates)
	return 1

/datum/dynamic_ruleset/midround/raginmages/review_applications()
	var/datum/faction/wizard/federation = find_active_faction_by_type(/datum/faction/wizard)
	if (!federation)
		federation = ticker.mode.CreateFaction(/datum/faction/wizard, null, 1)
	for (var/i = required_candidates, i > 0, i--)
		if(applicants.len <= 0)
			break
		var/mob/applicant = null
		var/selected_key = pick(applicants)
		for(var/mob/M in player_list)
			if(M.key == selected_key)
				applicant = M
		if(!applicant || !applicant.key)
			i++
			continue
		applicants -= applicant.key
		if(!isobserver(applicant))
			//Making sure we don't recruit people who got back into the game since they applied
			i++
			continue

		var/mob/living/carbon/human/new_character= makeBody(applicant)
		new_character.dna.ResetSE()

		assigned += new_character
		var/datum/role/wizard/newWizard = new
		newWizard.AssignToRole(new_character.mind,1)
		federation.HandleRecruitedRole(newWizard)
		newWizard.OnPostSetup()
		newWizard.Greet(GREET_MIDROUND)
		newWizard.ForgeObjectives()
		newWizard.AnnounceObjectives()


//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/nuclear
	name = "Nuclear Assault"
	role_category = /datum/role/nuclear_operative
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 5
	weight = 5
	cost = 35
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	logo = "nuke-logo"

/datum/dynamic_ruleset/midround/nuclear/acceptable(var/population=0,var/threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return 0//unavailable if nuke ops were already sent at roundstart
	return ..()

/datum/dynamic_ruleset/midround/nuclear/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return 0
	return ..()

/datum/dynamic_ruleset/midround/nuclear/execute()
	var/list/possible_candidates = list()
	possible_candidates.Add(dead_players)
	possible_candidates.Add(list_observers)
	send_applications(possible_candidates)
	return 1

/datum/dynamic_ruleset/midround/nuclear/review_applications()
	var/datum/faction/syndicate/nuke_op/nuclear = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	if (!nuclear)
		nuclear = ticker.mode.CreateFaction(/datum/faction/syndicate/nuke_op, null, 1)
	for (var/i = required_candidates, i > 0, i--)
		if(applicants.len <= 0)
			break
		var/mob/applicant = null
		var/selected_key = pick(applicants)
		for(var/mob/M in player_list)
			if(M.key == selected_key)
				applicant = M
		if(!applicant || !applicant.key)
			i++
			continue
		applicants -= applicant.key
		if(!isobserver(applicant))
			//Making sure we don't recruit people who got back into the game since they applied
			i++
			continue

		var/mob/living/carbon/human/new_character= makeBody(applicant)
		new_character.dna.ResetSE()

		assigned += new_character
		if (i == required_candidates)
			var/datum/role/nuclear_operative/leader/newCop = new
			newCop.AssignToRole(new_character.mind,1)
			nuclear.HandleRecruitedRole(newCop)
			newCop.Greet(GREET_MIDROUND)
		else
			var/datum/role/nuclear_operative/newCop = new
			newCop.AssignToRole(new_character.mind,1)
			nuclear.HandleRecruitedRole(newCop)
			newCop.Greet(GREET_MIDROUND)
	nuclear.OnPostSetup()
