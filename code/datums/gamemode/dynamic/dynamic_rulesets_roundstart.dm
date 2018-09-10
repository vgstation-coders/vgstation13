
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Syndicate Traitors"
	persistent = 1
	role_category = ROLE_TRAITOR
	restricted_from_jobs = list("Cyborg","Mobile MMI","Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_candidates = 1
	weight = 5
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
		newTraitor.OnPostSetup(FALSE)
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

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	role_category = ROLE_CHANGELING
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI","Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 5
	cost = 15
	requirements = list(80,60,40,20,20,10,10,10,10,10)

/datum/dynamic_ruleset/roundstart/changeling/execute()
	var/num_changelings = min(round(mode.candidates.len / 10) + 1, candidates.len)
	for (var/i = 1 to num_changelings)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/changeling/newChangeling = new
		newChangeling.AssignToRole(M.mind,1)
		newChangeling.OnPostSetup(FALSE)
		newChangeling.Greet(GREET_ROUNDSTART)
	return 1


//////////////////////////////////////////////
//                                          //
//               VAMPIRES                   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampire"
	role_category = ROLE_VAMPIRE
	restricted_from_jobs = list("AI","Cyborg","Mobile MMI","Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain")
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 5
	cost = 18
	requirements = list(80,60,40,20,20,10,10,10,10,10)

/datum/dynamic_ruleset/roundstart/vampire/execute()
	var/num_vampires = min(round(mode.candidates.len / 10) + 1, candidates.len)
	for (var/i = 1 to num_vampires)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		var/datum/role/vampire/newVampire = new
		newVampire.AssignToRole(M.mind,1)
		newVampire.OnPostSetup(FALSE)
		newVampire.Greet(GREET_ROUNDSTART)
	return 1


//////////////////////////////////////////////
//                                          //
//               WIZARDS                    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	role_category = ROLE_WIZARD
	restricted_from_jobs = list("Head of Security", "Captain")//just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,1,0,0)
	required_candidates = 1
	weight = 5
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)

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
		var/datum/faction/wizard/federation = find_active_faction_by_type(/datum/faction/wizard)
		if (!federation)
			federation = ticker.mode.CreateFaction(/datum/faction/wizard, null, 1)
		federation.HandleRecruitedRole(newWizard)//this will give the wizard their icon
		newWizard.OnPostSetup(FALSE)//this will move the wizard to their lair
		newWizard.Greet(GREET_ROUNDSTART)
		return 1
