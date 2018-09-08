
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
	var/num_traitors = min(round(mode.candidates.len / 10) + 1, candidates.len)
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
