
/datum/dynamic_ruleset/roundstart/test_traitor
	name = "Test Lone Traitor"
	persistent = 0//if set to 1, the rule won't be discarded after being executed, and the game mode will call update() once in a while
	repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on
	role_category = ROLE_TRAITOR//rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	required_candidates = 1//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	weight = 5//1 -> 9, probability for this rule to be picked against other rules
	cost = 0//threat cost for this rule.
	requirements = list(0,0,0,0,0,0,0,0,0,0)

/datum/dynamic_ruleset/roundstart/test_traitor/execute()
	var/mob/M = pick(candidates)
	assigned += M
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind,1)
	newTraitor.OnPostSetup(FALSE)
	newTraitor.Greet(GREET_ROUNDSTART)
	return 1

/datum/dynamic_ruleset/roundstart/test_cultist
	name = "Test Lone Cultist"
	persistent = 0//if set to 1, the rule won't be discarded after being executed, and the game mode will call update() once in a while
	repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on
	role_category = ROLE_CULTIST//rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	required_candidates = 1//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	weight = 8//1 -> 9, probability for this rule to be picked against other rules
	cost = 0//threat cost for this rule.
	requirements = list(0,0,0,0,0,0,0,0,0,0)

/datum/dynamic_ruleset/roundstart/test_cultist/execute()
	var/mob/M = pick(candidates)
	assigned += M
	var/datum/role/cultist/newCultist = new
	newCultist.AssignToRole(M.mind,1)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
	cult.HandleRecruitedRole(newCultist)
	newCultist.OnPostSetup(FALSE)
	newCultist.Greet(GREET_ROUNDSTART)
	return 1

/datum/dynamic_ruleset/roundstart/test_vampire
	name = "Test Lone Vampire"
	persistent = 0//if set to 1, the rule won't be discarded after being executed, and the game mode will call update() once in a while
	repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on
	role_category = ROLE_VAMPIRE//rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	required_candidates = 1//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	weight = 2//1 -> 9, probability for this rule to be picked against other rules
	cost = 0//threat cost for this rule.
	requirements = list(0,0,0,0,0,0,0,0,0,0)

/datum/dynamic_ruleset/roundstart/test_vampire/execute()
	var/mob/M = pick(candidates)
	assigned += M
	var/datum/role/traitor/newVampire = new
	newVampire.AssignToRole(M.mind,1)
	newVampire.OnPostSetup(FALSE)
	newVampire.Greet(GREET_ROUNDSTART)
	return 1



////////////////////////////




/datum/dynamic_ruleset/latejoin/test_traitor
	name = "Test Latejoin Traitor"
	persistent = 0//if set to 1, the rule won't be discarded after being executed, and the game mode will call update() once in a while
	repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on
	role_category = ROLE_TRAITOR//rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	required_candidates = 1//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	weight = 5//1 -> 9, probability for this rule to be picked against other rules
	cost = 0//threat cost for this rule.
	requirements = list(0,0,0,0,0,0,0,0,0,0)

/datum/dynamic_ruleset/latejoin/test_traitor/execute()
	var/mob/M = pick(candidates)
	assigned += M
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind,1)
	newTraitor.OnPostSetup(FALSE)
	newTraitor.Greet(GREET_ROUNDSTART)
	return 1

