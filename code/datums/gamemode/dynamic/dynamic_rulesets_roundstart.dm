
/*
	* Syndicate Traitors
	* Syndicate Challengers
	* Changelings
	* Vampires
	* Wizard
	* Civil War of Casters
	* Blood Cult
	* Nuclear Emergency
	* Malfunctioning AI
	* Blob Conglomerate
	* Extended
	* Revolution
	* The Grinch
	* Tag mode
	* Antag Madness
*/


//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Syndicate Traitors"
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Merchant", "Warden", "Head of Personnel", "Cyborg", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Medic")
	restricted_from_jobs = list("AI","Mobile MMI")
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Traitor"
	cost = 10
	var/traitor_threshold = 3
	var/additional_cost = 5
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10

/datum/dynamic_ruleset/roundstart/traitor/choose_candidates()
	var/traitor_scaling_coeff = 10 - max(0,round(mode.threat_level/10)-5)//above 50 threat level, coeff goes down by 1 for every 10 levels
	var/num_traitors = min(round(mode.roundstart_pop_ready / traitor_scaling_coeff) + 1, candidates.len)
	for (var/i = 1 to num_traitors)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		if (i > traitor_threshold)
			if ((mode.threat > additional_cost))
				mode.spend_threat(additional_cost)
			else
				break
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/traitor/execute()
	for (var/mob/M in assigned)
		var/datum/role/traitor/newTraitor = new
		newTraitor.AssignToRole(M.mind,1)
		newTraitor.Greet(GREET_ROUNDSTART)
		// Above 3 traitors, we start to cost a bit more.
	return 1

/datum/dynamic_ruleset/roundstart/traitor/previous_rounds_odds_reduction(var/result)
	return result

//////////////////////////////////////////////
//                                          //
//               CHALLENGERS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/challengers
	name = "Syndicate Challengers"
	role_category = /datum/role/traitor/challenger
	role_category_override = TRAITOR
	protected_from_jobs = list("Security Officer", "Merchant", "Warden", "Head of Personnel", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Medic")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI")
	required_candidates = 3
	weight = BASE_RULESET_WEIGHT
	weight_category = "Traitor"
	cost = 15
	var/traitor_threshold = 4
	var/additional_cost = 5
	requirements = list(101,101,101,101,10,10,10,10,10,10)
	high_population_requirement = 15

// -- Currently a copypaste of traitors. Could be fixed to be less copy & paste.
/datum/dynamic_ruleset/roundstart/challengers/choose_candidates()
	var/traitor_scaling_coeff = 10 - max(0,round(mode.threat_level/10)-5)//above 50 threat level, coeff goes down by 1 for every 10 levels
	var/num_traitors = clamp(round(mode.roundstart_pop_ready / traitor_scaling_coeff) + 1, required_candidates, candidates.len)
	for (var/i = 1 to num_traitors)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		if (i > traitor_threshold)
			if ((mode.threat > additional_cost))
				mode.spend_threat(additional_cost)
			else
				break
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/challengers/execute()
	var/traitor_scaling_coeff = 10 - max(0,round(mode.threat_level/10)-5)//above 50 threat level, coeff goes down by 1 for every 10 levels
	var/num_traitors = min(round(mode.roundstart_pop_ready / traitor_scaling_coeff) + 1, candidates.len)
	num_traitors = max(required_candidates,num_traitors)

	var/list/double_agents = list()

	for (var/mob/M in assigned)
		var/datum/role/traitor/challenger/newTraitor = new
		double_agents += newTraitor
		newTraitor.AssignToRole(M.mind,1)
		newTraitor.Greet(GREET_ROUNDSTART)

	if (double_agents.len > 1)
		for (var/i = 1 to (double_agents.len - 1))
			var/datum/role/traitor/challenger/myAgent = double_agents[i]
			var/datum/role/traitor/challenger/myTarget = double_agents[i+1]

			myAgent.assassination_target = myTarget

		var/datum/role/traitor/challenger/myAgent = double_agents[double_agents.len]
		var/datum/role/traitor/challenger/myTarget = double_agents[1]

		myAgent.assassination_target = myTarget

		//the objectives are properly created during ForgeObjectives() on the mode's PostSetup()

	return 1

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
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
	cost = 18
	requirements = list(80,70,60,60,30,20,10,10,10,10)
	high_population_requirement = 30

// -- Currently a copypaste of traitors. Could be fixed to be less copy & paste.
/datum/dynamic_ruleset/roundstart/changeling/choose_candidates()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/changeling/execute()
	for (var/mob/M in assigned)
		var/datum/role/changeling/newChangeling = new
		newChangeling.AssignToRole(M.mind,1)
		//Assign to the hivemind faction
		var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
		if(!hivemind)
			hivemind = ticker.mode.CreateFaction(/datum/faction/changeling)
			hivemind.OnPostSetup()
		hivemind.HandleRecruitedRole(newChangeling)

		newChangeling.ForgeObjectives()
		newChangeling.Greet(GREET_ROUNDSTART)
	return 1


//////////////////////////////////////////////
//                                          //
//               VAMPIRES                   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	role_category = /datum/role/vampire
	protected_from_jobs = list("Security Officer", "Warden","Merchant", "Head of Personnel", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Medic")
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI", "Chaplain")
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain", "Chaplain")
	required_pop = list(15,15,15,10,10,10,10,5,5,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Vampire"
	cost = 15
	requirements = list(80,70,60,60,30,20,10,10,10,10)
	high_population_requirement = 30
	var/vampire_threshold = 2

// -- Currently a copypaste of traitors. Could be fixed to be less copy & paste.
/datum/dynamic_ruleset/roundstart/vampire/choose_candidates()
	var/num_vampires = min(round(mode.roundstart_pop_ready / 10) + 1, candidates.len)
	for (var/i = 1 to num_vampires)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		// Above 2 vampires, we start to cost a bit more.
		if (i > vampire_threshold)
			if ((mode.threat > cost))
				mode.spend_threat(cost)
			else
				break
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/vampire/execute()
	for (var/mob/M in assigned)
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
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_pop = list(15,15,15,10,10,10,10,5,5,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT/2
	weight_category = "Wizard"
	cost = 30
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	var/list/roundstart_wizards = list()

/datum/dynamic_ruleset/roundstart/wizard/execute()
	var/mob/new_player/M = pick(assigned)
	if (M)
		var/datum/role/wizard/newWizard = new
		var/datum/faction/wizard/federation = find_active_faction_by_type(/datum/faction/wizard)
		if (!federation)
			federation = ticker.mode.CreateFaction(/datum/faction/wizard, null, 1)
		var/mob/living/carbon/human/H = M.create_human(M.client.prefs)
		H.forceMove(pick(wizardstart))
		H.key = M.client.ckey
		qdel(M)
		newWizard.AssignToRole(H.mind,1)
		roundstart_wizards += newWizard
		federation.HandleRecruitedRole(newWizard)//this will give the wizard their icon
		newWizard.Greet(GREET_ROUNDSTART)
	return 1

//////////////////////////////////////////////
//                                          //
//         CIVIL WAR OF CASTERS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/cwc
	name = "Civil War of Casters"
	role_category = /datum/role/wizard
	restricted_from_jobs = list("Head of Security", "Captain")//just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_jobs = list("Security Officer","Detective","Warden","Head of Security", "Captain")
	required_pop = list(25,25,20,20,20,20,15,15,15,5)
	required_candidates = 4
	weight = BASE_RULESET_WEIGHT/2
	weight_category = "CWC"
	cost = 45
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	flags = HIGHLANDER_RULESET
//	var/wizard_cd = 210 //7 minutes
	var/total_wizards = 4


/datum/dynamic_ruleset/roundstart/cwc/choose_candidates()
	for(var/wizards_number = 1 to total_wizards)
		var/mob/new_player/M = pick(candidates)
		assigned += M
		candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/cwc/execute()
	var/datum/faction/wizard/civilwar/wpf/WPF = ticker.mode.CreateFaction(/datum/faction/wizard/civilwar/wpf, null, 1)
	var/datum/faction/wizard/civilwar/wpf/PFW = ticker.mode.CreateFaction(/datum/faction/wizard/civilwar/pfw, null, 1)
	for(var/mob/new_player/M in assigned)
		var/datum/role/wizard/newWizard = new
		if (WPF.members.len < PFW.members.len)
			WPF.HandleRecruitedRole(newWizard)
		else if (WPF.members.len > PFW.members.len)
			PFW.HandleRecruitedRole(newWizard)
		else if(prob(50))
			WPF.HandleRecruitedRole(newWizard)
		else
			PFW.HandleRecruitedRole(newWizard)
		var/mob/living/carbon/human/H = M.create_human(M.client.prefs)
		H.forceMove(pick(wizardstart))
		H.key = M.client.ckey
		qdel(M)
		newWizard.AssignToRole(H.mind,1)
		newWizard.Greet(GREET_MIDROUND)
	return 1

//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	role_category = /datum/role/cultist
	restricted_from_jobs = list("Merchant","AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective",
							"Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent",
							"Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Medic")
	enemy_jobs = list("Security Officer","Warden", "Detective","Head of Security", "Captain")
	required_pop = list(25,25,20,20,20,20,20,15,15,10)
	required_candidates = 4
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	weight = BASE_RULESET_WEIGHT
	weight_category = "Cult"
	cost = 30
	requirements = list(90,80,60,30,20,10,10,10,10,10)
	high_population_requirement = 40
	var/cultist_cap = list(2,2,3,4,4,4,4,4,4,4)
	//Readd this once proper round ending rituals are added
	//flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/bloodcult/ready(var/forced = 0)
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	required_candidates = cultist_cap[indice_pop]
	if (forced)
		required_candidates = 1
	. = ..()

/datum/dynamic_ruleset/roundstart/bloodcult/choose_candidates()
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	var/cultists = cultist_cap[indice_pop]
	for (var/i = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	//if ready() did its job, candidates should have 4 or more members in it
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
	for(var/mob/M in assigned)
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

NB IF UNCOMMENTING : setting `assigned` in execute() should not be done.
Assign your candidates in choose_candidates() instead.

/datum/dynamic_ruleset/roundstart/cult_legacy
	name = "Cult (Legacy)"
	role_category = /datum/role/legacy_cultist
	role_category_override = CULTIST // H-ha
	protected_from_jobs = list("Merchant")
	restricted_from_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent", "Chaplain")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Chaplain")
	required_pop = list(25,25,20,20,20,20,20,15,15,10)
	required_candidates = 4
	weight = BASE_RULESET_WEIGHT
	cost = 25
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40

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
	role_category_override = "Nuke Operative" // this is what is used on the ban page
	restricted_from_jobs = list("Head of Security", "Captain") //Just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_pop = list(25,25,20,20,20,20,20,15,15,10)
	required_candidates = 5 //This value is useless, see operative_cap
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	weight = BASE_RULESET_WEIGHT
	weight_category = "Nuke"
	cost = 30
	requirements = list(90, 80, 60, 30, 20, 10, 10, 10, 10, 10)
	high_population_requirement = 40
	var/operative_cap = list(2, 2, 3, 3, 4, 5, 5, 5, 5, 5)
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/nuclear/ready(var/forced = 0)
	var/indice_pop = min(10, round(mode.roundstart_pop_ready/5) + 1)
	required_candidates = operative_cap[indice_pop]
	if (forced)
		required_candidates = 1
	. = ..()

/datum/dynamic_ruleset/roundstart/nuclear/choose_candidates()
	var/indice_pop = min(10, round(mode.roundstart_pop_ready/5) + 1)
	var/operatives = operative_cap[indice_pop]
	message_admins("[name]: indice_pop = [indice_pop], operatives = [operatives]")
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/new_player/M = pick(candidates)
		assigned += M
		candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	//If ready() did its job, candidates should have 5 or more members in it
	var/datum/faction/syndicate/nuke_op/nuclear = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	if(!nuclear)
		nuclear = ticker.mode.CreateFaction(/datum/faction/syndicate/nuke_op, null, 1)
	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			continue

	var/spawnpos = 1
	var/leader = 1
	for(var/mob/new_player/M in assigned)
		if(spawnpos > synd_spawn.len)
			spawnpos = 1
		var/mob/living/carbon/human/H = M.create_human(M.client.prefs)
		H.forceMove(synd_spawn[spawnpos])
		H.key = M.client.ckey
		qdel(M)
		if(leader)
			leader = 0
			var/datum/role/nuclear_operative/leader/newCop = new
			newCop.AssignToRole(H.mind, 1)
			nuclear.HandleRecruitedRole(newCop)
			newCop.Greet(GREET_ROUNDSTART)
		else
			var/datum/role/nuclear_operative/newCop = new
			newCop.AssignToRole(H.mind, 1)
			nuclear.HandleRecruitedRole(newCop)
			newCop.Greet(GREET_ROUNDSTART)
		spawnpos++
	for(var/obj/effect/spawner/newbomb/timer/syndicate/bomb in syndicate_bomb_spawners)
		bomb.spawnbomb()
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
	restricted_from_jobs = list("Security Officer", "Warden","Detective","Head of Security", "Captain", "Research Director", "Chief Engineer")
	job_priority = list("AI","Cyborg")
	required_pop = list(25,25,25,20,20,20,15,15,15,15)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Malf"
	cost = 40
	requirements = list(90,80,70,60,50,40,40,30,30,20)
	high_population_requirement = 60
	flags = HIGHLANDER_RULESET

// NB : `M` will never be empty as `ready` made sure we have at least one candidate with malf AI on.
// This candidate will become an AI upon roundstart, eventually replacing other AIs candidates who do not have the preference.
// You should `not` perform any null checks on M. M being null is a sign of a problem and should runtime.
/datum/dynamic_ruleset/roundstart/malf/choose_candidates()
	var/mob/M = progressive_job_search() //dynamic_rulesets.dm. Handles adding the guy to assigned.
	if(M.mind.assigned_role != "AI")
		for(var/mob/living/silicon/ai/player in player_list) //mode.candidates is everyone readied up, not to be confused with candidates
			if(player != M)	// This should always be true but in case something goes terribly terribly wrong we definitely do not want to end up displacing the malf AI
				displace_AI(player)
				break		// There will only be one roundstart AI normally. In case of a triple-AI round we only need to displace one AI anyway.

	//Now that we've replaced the eventual other AIs, we make sure this chosen candidate has the proper roles.
	M.mind.assigned_role = "AI"
	if(!isAI(M))
		assigned.Remove(M)
		M = M.AIize()
		assigned.Add(M)
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/malf/execute()
	var/datum/faction/malf/unction = find_active_faction_by_type(/datum/faction/malf)
	if (!unction)
		unction = ticker.mode.CreateFaction(/datum/faction/malf, null, 1)
	var/mob/M = pick(assigned)
	unction.HandleNewMind(M.mind)
	var/datum/role/malfAI/MAI = M.mind.GetRole(MALF)
	MAI.Greet()
	return 1

/datum/dynamic_ruleset/roundstart/malf/proc/displace_AI(var/mob/displaced)
	var/mob/new_player/old_AI = new
	old_AI.ckey = displaced.ckey
	old_AI.name = displaced.ckey
	qdel(displaced)
	old_AI.mind.assigned_role = null
	var/list/shuffledoccupations = shuffle(job_master.occupations)
	for(var/level = 3 to 1 step -1)
		if(old_AI.mind.assigned_role)
			break
		for(var/datum/job/job in shuffledoccupations)
			if(job_master.TryAssignJob(old_AI,level,job))
				break
	if(!old_AI.mind.assigned_role) // still no job
		if(old_AI.client.prefs.alternate_option == GET_RANDOM_JOB)
			job_master.GiveRandomJob(old_AI)
		else if(old_AI.client.prefs.alternate_option == BE_ASSISTANT)
			job_master.AssignRole(old_AI, "Assistant")
	if(!old_AI.mind.assigned_role)
		to_chat(old_AI, "<span class='danger'>You have been returned to lobby due to your job preferences being filled.")
		log_admin("([old_AI.ckey]) was displaced by a malf AI and sent back to lobby.")
		message_admins("([old_AI.ckey]) was displaced by a malf AI and started the game as a [old_AI.mind.assigned_role].")
		old_AI.ready = 0
		return

	if(old_AI.mind.assigned_role=="AI" || old_AI.mind.assigned_role=="Cyborg" || old_AI.mind.assigned_role=="Mobile MMI")
		old_AI.create_roundstart_silicon(old_AI.mind.assigned_role)
	else
		var/mob/living/carbon/human/new_character = old_AI.create_human(old_AI.client.prefs)
		job_master.PostJobSetup(new_character)
		EquipCustomItems(new_character)
	log_admin("([old_AI.ckey]) was displaced by a malf AI and started the game as a [old_AI.mind.assigned_role].")
	message_admins("([old_AI.ckey]) was displaced by a malf AI and started the game as a [old_AI.mind.assigned_role].")
	qdel(old_AI)

//////////////////////////////////////////////
//                                          //
//         BLOB					            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/blob
	name = "Blob Conglomerate"
	role_category = /datum/role/blob_overmind/
	restricted_from_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	enemy_jobs = list("AI", "Cyborg", "Warden", "Head of Security", "Captain", "Quartermaster", "Head of Personnel", "Station Engineer", "Chief Engineer", "Atmospheric Technician")
	required_pop = list(30,25,25,20,20,20,15,15,15,15)
	required_enemies = list(4,4,4,4,4,4,4,3,2,1)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Blob"
	weekday_rule_boost = list("Tue")
	cost = 45
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	high_population_requirement = 70
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/blob/execute()
	var/datum/faction/blob_conglomerate/blob_fac = find_active_faction_by_type(/datum/faction/blob_conglomerate)
	if (!blob_fac)
		blob_fac = ticker.mode.CreateFaction(/datum/faction/blob_conglomerate, null, 1)
	var/blob_number = 1 + round(mode.roundstart_pop_ready/25) // + 1 Blob per 25 pop. ready.
	for (var/i = 1 to min(blob_number, assigned.len))
		var/mob/M = pick(assigned)
		blob_fac.HandleNewMind(M.mind)
		var/datum/role/blob = M.mind.GetRole(BLOBOVERMIND)
		blob.Greet(GREET_ROUNDSTART)
		switch(M.mind.assigned_role)
			if("Clown")
				blob_looks_player["clownscape"] = 32
			if("Station Engineer","Atmospheric Technician","Chief Engineer")
				blob_looks_player["AME"] = 32
				blob_looks_player["AME_new"] = 64
			if("Chaplain")
				blob_looks_player["skelleton"] = 64
			if("Security Officer","Detective","Head of Security","Warden")
				blob_looks_player["secblob"] = 32
		if (calledBy == "antag madness")//one core is plenty on antag madness
			break
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
	required_candidates = 0
	weight = BASE_RULESET_WEIGHT * 0.5
	weight_category = "Extended"
	cost = 0
	requirements = list(0,0,0,0,0,0,0,0,0,0)
	high_population_requirement = 101


// 70% chance of allowing extended at 0-30 threat, then (100-threat)% chance. Requires 30 pop still.
/datum/dynamic_ruleset/roundstart/extended/ready(var/forced=0)
	if (mode.roundstart_pop_ready < 30)
		return FALSE
	var/probability = clamp(mode.threat_level, 30, 100)
	return !prob(probability)

/datum/dynamic_ruleset/roundstart/extended/choose_candidates()
	return TRUE

/datum/dynamic_ruleset/roundstart/extended/execute()
	message_admins("Starting a round of extended.")
	log_admin("Starting a round of extended.")
	admin_disable_rulesets = TRUE
	log_admin("Dynamic rulesets are disabled in Extended.")
	message_admins("Dynamic rulesets are disabled in Extended.")
	return TRUE

//////////////////////////////////////////////
//                                          //
//               REVS		                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/delayed/revs
	name = "Revolution"
	role_category = /datum/role/revolutionary
	restricted_from_jobs = list("Merchant","AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent", "Brig Medic")
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_pop = list(25,25,25,20,20,20,15,15,15,15)
	required_candidates = 3
	weight = BASE_RULESET_WEIGHT
	weight_category = "Revolution"
	cost = 40
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	high_population_requirement = 50
	delay = 5 MINUTES
	var/required_heads = 3
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/delayed/revs/ready(var/forced = 0)
	if (forced)
		required_heads = 1
		required_candidates = 1
	if (!..())
		return FALSE
	var/head_check = 0
	for (var/mob/player in player_list)
		if (player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/roundstart/delayed/revs/choose_candidates()
	var/max_canditates = 4
	for(var/i = 1 to max_canditates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		assigned_ckeys += M.ckey
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/delayed/revs/execute()
	var/datum/faction/revolution/R = find_active_faction_by_type(/datum/faction/revolution)
	if (!R)
		R = ticker.mode.CreateFaction(/datum/faction/revolution, null, 1)
	for (var/rev_ckey in assigned_ckeys)
		var/mob/M = find_player_by_ckey(rev_ckey)
		var/datum/role/revolutionary/leader/lenin = new
		lenin.AssignToRole(M.mind, 1, 1)
		R.HandleRecruitedRole(lenin)
		lenin.Greet(GREET_ROUNDSTART)
	update_faction_icons()
	R.OnPostSetup()
	return 1

//////////////////////////////////////////////
//                                          //
//               THE GRINCH (holidays)      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/grinch
	name = "The Grinch"
	role_category = /datum/role/grinch
	restricted_from_jobs = list()
	enemy_jobs = list()
	required_pop = list(0,0,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Special"//Admin only
	cost = 10
	requirements = list(101,101,101,101,101,101,101,101,101,101) // So that's not possible to roll it naturally
	high_population_requirement = 10
	flags = MINOR_RULESET

/datum/dynamic_ruleset/roundstart/grinch/ready(var/forced=0)
	if(grinchstart.len == 0)
		log_admin("Cannot accept Grinch ruleset. Couldn't find any grinch spawn points.")
		message_admins("Cannot accept Grinch ruleset. Couldn't find any grinch spawn points.")
		return 0
	if (!..())
		return FALSE
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	var/accepted = (MM == 12 && DD > 15) || (MM == 1 && DD < 9) 	// Between the 15th of December and the 9th of January
	return (accepted || forced)


/datum/dynamic_ruleset/roundstart/grinch/execute()
	var/mob/new_player/M = pick(assigned)
	if (M)
		var/datum/role/grinch/newGrinch = new
		var/mob/living/simple_animal/hostile/gremlin/grinch/G = new (pick(grinchstart))
		G.key = M.client.ckey
		qdel(M)
		newGrinch.AssignToRole(G.mind,1)
		newGrinch.Greet(GREET_ROUNDSTART)
		G << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)// MAD JAMS cant last forever yo
	return 1

//////////////////////////////////////////////
//                                          //
//               TAG MODE (speical)      	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/tag_mode
	name = "Tag mode"
	role_category = /datum/role/changeling/changeling_clown
	restricted_from_jobs = list()
	enemy_jobs = list()
	required_pop = list(0,0,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	weight_category = "Special"//Admin only
	cost = 10
	requirements = list(101,101,101,101,101,101,101,101,101,101) // So that's not possible to roll it naturally
	high_population_requirement = 101
	flags = MINOR_RULESET

/datum/dynamic_ruleset/roundstart/tag_mode/execute()

	// Populate tagmode spawn list
	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name in valid_landmark_lists)
			tag_mode_spawns += get_turf(A)
			QDEL_NULL(A)
			continue

	init_tag_mode_spawns()

	// Spawn the clown...
	var/mob/M = pick(assigned)
	var/datum/role/changeling/changeling_clown/clown = new
	clown.AssignToRole(M.mind,1)
	clown.Greet(GREET_ROUNDSTART)

	// And everyone else as mimes.
	for (var/mob/M2 in (living_mob_list - M))
		if (!M2.mind || !M2.client)
			continue
		var/datum/role/tag_mode_mime/mime = new
		mime.AssignToRole(M2.mind,1)
		mime.Greet(GREET_ROUNDSTART)
	return 1


//////////////////////////////////////////////
//                                          //
//             ANTAG MADNESS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

var/antag_madness = ANTAG_MADNESS_OFF

/datum/dynamic_ruleset/roundstart/antag_madness
	name = "Antag Madness"
	role_category = /datum/role/nanotrasen_official
	role_category_override = HEAD
	protected_from_jobs = list()
	restricted_from_jobs = list()
	cost = 0
	weight_category = "Special"//Admin only
	requirements = list(101,101,101,101,101,101,101,101,101,101) // Adminbus only
	high_population_requirement = 101
	persistent = TRUE//latejoiners will either be heads of staff or traitors (unless traitor is deactivated/antagbanned)
	var/list/nanotrasen_staff = list("Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent")
	var/escalation_delay = 18 MINUTES

/datum/dynamic_ruleset/roundstart/antag_madness/trim_candidates()//All the heads of staff get the role, the rest of the players will get trimmed by the other rulesets
	for(var/mob/P in candidates)
		if (P.mind.assigned_role && (P.mind.assigned_role in nanotrasen_staff))
			assigned.Add(P)
			candidates.Remove(P)

/datum/dynamic_ruleset/roundstart/antag_madness/choose_candidates()
	message_admins("DYNAMIC MODE: starting [name] with [assigned.len] heads of staff out of [candidates.len] players.")
	log_admin("DYNAMIC MODE:  starting [name] with [assigned.len] heads of staff out of [candidates.len] players.")
	return TRUE

/datum/dynamic_ruleset/roundstart/antag_madness/ready(var/forced = 0)
	return TRUE

/datum/dynamic_ruleset/roundstart/antag_madness/execute()
	antag_madness = ANTAG_MADNESS_EARLY
	//first we initialize the nanotrasen faction, even if there are no heads currently there
	var/datum/faction/nanotrasen/nanotrasen = find_active_faction_by_type(/datum/faction/nanotrasen)
	if (!nanotrasen)
		nanotrasen = ticker.mode.CreateFaction(/datum/faction/nanotrasen, null, 1)

	//next we throw every head currently there in it
	for(var/mob/M in assigned)
		var/datum/role/nanotrasen_official/head = new
		head.name = M.mind.assigned_role
		head.AssignToRole(M.mind,1)
		nanotrasen.HandleRecruitedRole(head)
		head.Greet(GREET_ROUNDSTART)

	//and now we manipulate Dynamic to force a bunch of other rulesets. It just works...
	var/list/the_madness = list(
		"Malfunctioning AI",
		"Blob Conglomerate",
		"Blood Cult",
		"Nuclear Emergency",
		"Wizard",
		"Revolution",
		"Vampires",
		"Changelings",
		"Syndicate Traitors",
		)//The order matters. As a rule of thumb, rarer rulesets should have their chance come first, while more common ones will fill the spots

	if (assigned.len < 5)
		the_madness -= "Revolution"//No revs unless there's at least 5 roundstart heads, because that'd be overkill

	for (var/madness_ruleset in the_madness)
		for (var/datum/dynamic_ruleset/roundstart/rule in mode.roundstart_rules)
			if (madness_ruleset == rule.name)
				rule.candidates = candidates.Copy()
				rule.trim_candidates()
				if (rule.ready(TRUE))
					rule.calledBy = "antag madness"
					rule.required_candidates = 1//because we're funny
					if (madness_ruleset == "Syndicate Traitors")//no traitor limits
						rule.protected_from_jobs = list()
						rule.restricted_from_jobs = list("Mobile MMI")
						for (var/mob/M in candidates)
							rule.assigned += M
							rule.candidates -= M
					else
						rule.choose_candidates()
					if (rule.assigned.len)
						message_admins("ANTAG MADNESS: <font size='3'>[rule.name]</font> OK!")
						log_admin("ANTAG MADNESS: <font size='3'>[rule.name]</font> OK!")
						mode.threat_log += "[worldtime2text()]: Roundstart [rule.name] forced by antag madness"

						if (istype(rule, /datum/dynamic_ruleset/roundstart/delayed/))
							var/datum/dynamic_ruleset/roundstart/delayed/delayed_ruleset = rule
							message_admins("ANTAG MADNESS: with a delay of [delayed_ruleset.delay/10] seconds.")
							log_admin("ANTAG MADNESS: with a delay of [delayed_ruleset.delay/10] seconds.")
							mode.pick_delay(rule)

						if (rule.execute())
							rule.stillborn = IsRoundAboutToEnd()
							mode.executed_rules += rule
							if (rule.persistent)
								mode.current_rules += rule
							for(var/mob/M in rule.assigned)
								candidates -= M
					else
						message_admins("ANTAG MADNESS: <font size='3'>[rule.name]</font> FAILED!")
						log_admin("ANTAG MADNESS: <font size='3'>[rule.name]</font> FAILED!")
				else
					message_admins("ANTAG MADNESS: <font size='3'>[rule.name]</font> FAILED!")
					log_admin("ANTAG MADNESS: <font size='3'>[rule.name]</font> FAILED!")

	spawn(10)
		message_admins("<span class='danger'>Antag Madness is now underway. In this very chaotic mode, admins are encouraged to proactively interfere with the round to keep things interesting, and help it reach a conclusion if necessary. Rev may no longer cause the round to suddenly end if all heads are dead, Malf, Blob and Nuke Ops still can if they destroy the station. If things get stale after 30 minutes and there are lots of dead players, consider bringing the round to a conclusion by either forcing a shuttle call, sending either the deathsquad or elite syndies to destroy the station, or trigger a supermatter cascade (or combination of those).</span>")
		log_admin("<span class='danger'>Antag Madness is now underway. In this very chaotic mode, admins are encouraged to proactively interfere with the round to keep things interesting, and help it reach a conclusion if necessary. Rev may no longer cause the round to suddenly end if all heads are dead, Malf, Blob and Nuke Ops still can if they destroy the station. If things get stale after 30 minutes and there are lots of dead players, consider bringing the round to a conclusion by either forcing a shuttle call, sending either the deathsquad or elite syndies to destroy the station, or trigger a supermatter cascade (or combination of those).</span>")


	spawn(escalation_delay)//ERT calling is automated after 18 minutes. Any further developments will have to be manually enacted by the badmin who forced this terrible ruleset in the first place. have fun!
		antag_madness = ANTAG_MADNESS_LATE
		var/datum/striketeam/ert/response_team = new()
		response_team.trigger_strike(null,"Nanotrasen officials have been misled to a dummy Space Station filled with antagonistic forces. You must find, protect, and retrieve the various Heads of Staff and Internal Affair Agents aboard the station. Anyone else is a potential threat that must be dealt with extreme prejudice.")
		for(var/mob/living/player in player_list)
			if (!player.client)
				continue
			if (player.stat == DEAD)
				continue
			if (isMoMMI(player))
				continue
			if (!isanyantag(player))
				var/datum/role/survivor/R = new
				R.AssignToRole(player.mind,1)
				R.Greet(GREET_MADNESSSURVIVOR)
				R.OnPostSetup()
				R.ForgeObjectives()
				R.AnnounceObjectives()
	return 1

/datum/dynamic_ruleset/roundstart/antag_madness/latespawn_interaction(var/mob/living/newPlayer)
	var/datum/faction/nanotrasen/nanotrasen = find_active_faction_by_type(/datum/faction/nanotrasen)
	if (!nanotrasen)
		nanotrasen = mode.CreateFaction(/datum/faction/nanotrasen, null, 1)
	if (newPlayer.mind.assigned_role && (newPlayer.mind.assigned_role in nanotrasen_staff))//latejoining as a head? better start running
		var/datum/role/nanotrasen_official/head = new
		head.name = newPlayer.mind.assigned_role
		head.AssignToRole(newPlayer.mind,1)
		nanotrasen.HandleRecruitedRole(head)
		switch(nanotrasen.delta)
			if (0)
				head.Greet(GREET_LATEJOIN)
			if (1)
				head.Greet(GREET_LATEJOIN_ERT_COMING)
			if (2)
				head.Greet(GREET_LATEJOIN_ERT_NOT_COMING)
		return TRUE
	else
		for (var/datum/dynamic_ruleset/latejoin/rule in mode.latejoin_rules)//otherwise, you may become a traitor
			if (rule.name == "Syndicate Infiltrator")
				rule.candidates = list(newPlayer)
				rule.protected_from_jobs = list()
				rule.restricted_from_jobs = list("Mobile MMI")
				rule.trim_candidates()//if you have it enabled/aren't traitorbanned
				for (var/mob/M in rule.candidates)
					var/datum/role/traitor/newTraitor = new
					newTraitor.AssignToRole(M.mind,1)
					if (nanotrasen.delta)
						newTraitor.Greet(GREET_LATEJOINMADNESS)
					else
						newTraitor.Greet(GREET_LATEJOIN)
					return TRUE
	//tator disabled? tator banned? whatever you'll be a survivor if the round has gone on long enough
	if (antag_madness == ANTAG_MADNESS_LATE)
		var/datum/role/survivor/R = new
		R.AssignToRole(newPlayer.mind,1)
		R.Greet(GREET_MADNESSSURVIVOR)
		R.OnPostSetup()
		R.ForgeObjectives()
		R.AnnounceObjectives()
		return TRUE

	return FALSE
