/datum/faction/wizard_contract
	name = "Wizard Apprenticeship"
	ID = WIZARD_CONTRACT
	initial_role = WIZAPP_MASTER
	late_role = WIZAPP
	initroletype = /datum/role/wizard_master
	roletype = /datum/role/wizard_apprentice
	logo_state = "apprentice-logo"
	hud_icons = list("wizard-logo", "apprentice-logo")

/datum/faction/wizard_contract/HandleNewMind(var/datum/mind/M)
	. = ..()
	var/datum/role/newRole = .
	if(!newRole)
		return
	if(leader)
		message_admins("[type]/HandleNewMind([M.key]/[M.name]) was called but there was already a leader ([leader.antag?.key]/[leader.antag?.name]).")
	leader = newRole

/datum/faction/wizard_contract/forgeObjectives()
	var/datum/objective/target/protect/any_target/wizard/P = new(auto_target = FALSE)
	P.set_target(leader.antag)
	AppendObjective(P)
