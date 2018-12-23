
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Syndicate Traitors"
	persistent = 1
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Merchant", "Warden", "Head of Personnel", "Cyborg", "Detective", "Head of Security", "Captain")
	restricted_from_jobs = list("AI","Mobile MMI")
	required_candidates = 1
	weight = 7
	cost = 10
	requirements = list(40,30,20,10,10,10,10,10,10,10)
	var/autotraitor_cooldown = 900//15 minutes

/datum/dynamic_ruleset/roundstart/traitor/execute()
	var/traitor_scaling_coeff = 10 - max(0,round(mode.threat_level/10)-5)//above 50 threat level, coeff goes down by 1 for every 10 levels
	var/num_traitors = min(round(mode.candidates.len / traitor_scaling_coeff) + 1, candidates.len)
	for (var/i = 1 to num_traitors)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/traitor/newTraitor = new
		newTraitor.AssignToRole(M.mind,1)
		newTraitor.Greet(GREET_ROUNDSTART)
	return 1

/datum/dynamic_ruleset/roundstart/traitor/process()
	if (autotraitor_cooldown)
		autotraitor_cooldown--
	else
		autotraitor_cooldown = 900//15 minutes
		message_admins("Dynamic Mode: Checking if we can turn someone into a traitor...")
		mode.picking_specific_rule(/datum/dynamic_ruleset/midround/autotraitor)

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////
/*
/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	role_category = ROLE_CHANGELING
	protected_from_jobs = list("Security Officer", "Warden", "Merchant", "Head of Personnel", "Detective", "Head of Security", "Captain")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI")
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 30
	requirements = list(80,60,40,20,20,10,10,10,10,10)

/datum/dynamic_ruleset/roundstart/changeling/execute()
	var/num_changelings = min(round(mode.candidates.len / 10) + 1, candidates.len)
	for (var/i = 1 to num_changelings)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/changeling/newChangeling = new
		newChangeling.AssignToRole(M.mind,1)
		newChangeling.Greet(GREET_ROUNDSTART)
	return 1

*/
//////////////////////////////////////////////
//                                          //
//               VAMPIRES                   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	role_category = /datum/role/vampire
	protected_from_jobs = list("Security Officer", "Warden","Merchant", "Head of Personnel", "Detective", "Head of Security", "Captain")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI", "Chaplain")
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 18
	requirements = list(80,60,40,20,20,10,10,10,10,10)

/datum/dynamic_ruleset/roundstart/vampire/execute()
	var/num_vampires = min(round(mode.candidates.len / 10) + 1, candidates.len)
	for (var/i = 1 to num_vampires)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/faction/vampire/fac = ticker.mode.CreateFaction(/datum/faction/vampire, null, 1)
		var/datum/role/vampire/newVampire = new(M.mind, fac, override = TRUE)
		newVampire.Greet(GREET_MASTER)
		newVampire.AnnounceObjectives()
	update_faction_icons()
	return 1


//////////////////////////////////////////////
//                                          //
//               WIZARDS                    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	role_category = /datum/role/wizard
	restricted_from_jobs = list("Head of Security", "Captain")//just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 30
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	var/list/roundstart_wizards = list()

/datum/dynamic_ruleset/roundstart/wizard/acceptable(var/population=0,var/threat=0)
	if(wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return 0
	return ..()

/datum/dynamic_ruleset/roundstart/wizard/execute()
	var/mob/M = pick(candidates)
	if (M)
		assigned += M
		candidates -= M
		var/datum/role/wizard/newWizard = new
		newWizard.AssignToRole(M.mind,1)
		roundstart_wizards += newWizard
		var/datum/faction/wizard/federation = find_active_faction_by_type(/datum/faction/wizard)
		if (!federation)
			federation = ticker.mode.CreateFaction(/datum/faction/wizard, null, 1)
		federation.HandleRecruitedRole(newWizard)//this will give the wizard their icon
		newWizard.Greet(GREET_ROUNDSTART)
		return 1


//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	role_category = /datum/role/cultist
	protected_from_jobs = list("Merchant")
	restricted_from_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Warden", "Detective","Head of Security", "Captain", "Chaplain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 4
	weight = 3
	cost = 25
	requirements = list(90,80,60,30,20,10,10,10,10,10)
	var/cultist_cap = list(2,2,3,4,4,4,4,4,4,4)

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	//if ready() did its job, candidates should have 4 or more members in it
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)

	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	var/cultists = cultist_cap[indice_pop]

	for(var/cultists_number = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/cultist/newCultist = new
		newCultist.AssignToRole(M.mind,1)
		cult.HandleRecruitedRole(newCultist)
		newCultist.Greet(GREET_ROUNDSTART)
	return 1


//////////////////////////////////////////////
//                                          //
//               CULT (LEGACY)              ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////
/*
/datum/dynamic_ruleset/roundstart/cult_legacy
	name = "Cult (Legacy)"
	role_category = /datum/role/legacy_cultist
	role_category_override = ROLE_CULTIST // H-ha
	protected_from_jobs = list("Merchant")
	restricted_from_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent", "Chaplain")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Chaplain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 4
	weight = 3
	cost = 25
	requirements = list(90,90,70,40,30,20,10,10,10,10)

/datum/dynamic_ruleset/roundstart/cult_legacy/execute()
	//if ready() did its job, candidates should have 4 or more members in it
	var/datum/faction/cult/narsie/legacy = find_active_faction_by_type(/datum/faction/cult/narsie)
	if (!legacy)
		legacy = ticker.mode.CreateFaction(/datum/faction/cult/narsie, null, 1)

	for(var/cultists_number = 1 to required_candidates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/legacy_cultist/newCultist = new
		newCultist.AssignToRole(M.mind,1)
		legacy.HandleRecruitedRole(newCultist)
		newCultist.Greet(GREET_ROUNDSTART)
	return 1
*/

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES              ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	role_category = /datum/role/nuclear_operative
	restricted_from_jobs = list("Head of Security", "Captain")//just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 5
	weight = 5
	cost = 30
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	var/operative_cap = list(2,2,3,3,4,5,5,5,5,5)

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	//if ready() did its job, candidates should have 5 or more members in it
	var/datum/faction/syndicate/nuke_op/nuclear = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	if (!nuclear)
		nuclear = ticker.mode.CreateFaction(/datum/faction/syndicate/nuke_op, null, 1)

	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	var/operatives = operative_cap[indice_pop]
	var/leader = 1
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		if (leader)
			leader = 0
			var/datum/role/nuclear_operative/leader/newCop = new
			newCop.AssignToRole(M.mind,1)
			nuclear.HandleRecruitedRole(newCop)
			newCop.Greet(GREET_ROUNDSTART)
		else
			var/datum/role/nuclear_operative/newCop = new
			newCop.AssignToRole(M.mind,1)
			nuclear.HandleRecruitedRole(newCop)
			newCop.Greet(GREET_ROUNDSTART)
	return 1


//////////////////////////////////////////////
//                                          //
//            AI MALFUNCTION                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/malf
	name = "Malfunctioning AI"
	role_category = /datum/role/malfAI
	enemy_jobs = list("Security Officer", "Warden","Detective","Head of Security", "Captain", "Scientist", "Chemist", "Research Director", "Chief Engineer")
	exclusive_to_jobs = list("AI")
	required_enemies = list(4,4,4,4,4,4,2,2,2,0)
	required_candidates = 1
	weight = 3
	cost = 35
	requirements = list(90,90,90,90,80,70,50,30,20,10)

/datum/dynamic_ruleset/roundstart/malf/execute()
	var/datum/faction/malf/unction = find_active_faction_by_type(/datum/faction/malf)
	if (!unction)
		unction = ticker.mode.CreateFaction(/datum/faction/malf, null, 1)
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/role/malfAI/AI = new
	AI.AssignToRole(M.mind,1)
	unction.HandleRecruitedRole(AI)
	AI.Greet(GREET_ROUNDSTART)
	return 1

//////////////////////////////////////////////
//                                          //
//               EXTENDED                   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	role_category = null
	restricted_from_jobs = list()
	enemy_jobs = list()
	required_enemies = list(0,0,0,0,0,0,0,0,0,0)
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101) // So that's not possible to roll it naturally

/datum/dynamic_ruleset/roundstart/extended/execute()
	message_admins("Starting a round of extended.")
	log_admin("Starting a round of extended.")
	return TRUE

//////////////////////////////////////////////
//                                          //
//               REVS		                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/revs
	name = "Revolution"
	role_category = /datum/role/revolutionary
	protected_from_jobs = list("Merchant")
	restricted_from_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 3
	weight = 2
	cost = 45
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	var/required_heads = 3

/datum/dynamic_ruleset/roundstart/revs/ready(var/forced = 0)
	if (!..())
		return FALSE
	var/head_check = 0
	for (var/mob/new_player/player in player_list)
		if (player.mind.assigned_role in command_positions)
			head_check++
	if (forced)
		required_heads = 1
		required_candidates = 1
	return (head_check >= required_heads)

/datum/dynamic_ruleset/roundstart/revs/execute()
	var/datum/faction/revolution/R = find_active_faction_by_type(/datum/faction/revolution)
	if (!R)
		R = ticker.mode.CreateFaction(/datum/faction/revolution, null, 1)

	var/max_canditates = 4
	for(var/i = 1 to max_canditates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/revolutionary/leader/lenin = new
		lenin.AssignToRole(M.mind, 1, 1)
		R.HandleRecruitedRole(lenin)
		lenin.Greet(GREET_ROUNDSTART)
	update_faction_icons()
	return 1
