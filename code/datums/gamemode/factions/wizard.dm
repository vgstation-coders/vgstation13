/datum/faction/wizard
	name = "Wizard Federation"
	ID = WIZFEDERATION
	initial_role = WIZARD
	late_role = WIZARD
	required_pref = WIZARD
	desc = "A conglomeration of magically adept individuals, with no obvious heirachy, instead acting as equal individuals in the pursuit of magic-oriented endeavours.\
	Their motivations for attacking seemingly peaceful enclaves or operations are as yet unknown, but they do so without respite or remorse.\
	This has led to them being identified as enemies of humanity, and should be treated as such."
	initroletype = /datum/role/wizard
	roletype = /datum/role/wizard
	logo_state = "wizard-logo"
	hud_icons = list("wizard-logo","apprentice-logo")

/datum/faction/wizard/civilwar
	var/enemy_faction

/datum/faction/wizard/civilwar/forgeObjectives()
	var/datum/objective/destroyfaction/O = new()
	var/datum/faction/target = find_active_faction_by_type(enemy_faction)
	if(!target)
		target = ticker.mode.CreateFaction(enemy_faction, null, 1)
	O.faction = target
	AppendObjective(O)
	..()

/datum/faction/wizard/civilwar/manajerks
	name = "Manajerks"
	desc = "The Manajerks are a faction within the Wizard Federation known for being able to pull mana from thin air. Their power places them at the top of the Wizard Federation, where their blue arms are seen as a status symbol."
	enemy_faction = /datum/faction/wizard/civilwar/quickvillains

/datum/faction/wizard/civilwar/quickvillains
	name = "Quickvillains"
	desc = "The Quickvillains are a faction within the Wizard Federation known for their blinding speed in spellcasting. They are an insurgency against the Manajerks and willingly don the title of 'villain' as outlaws."
	logo_state = "apprentice-logo" //His hat is NOT blue!
	enemy_faction = /datum/faction/wizard/civilwar/manajerks

/datum/faction/wizard/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Wizard"
	M.original = M.current

/datum/faction/wizard/OnPostSetup()
	if(wizardstart.len == 0)
		for(var/datum/role/wizard in members)
			to_chat(wizard.antag.current, "<span class='danger'>A starting location for you could not be found, please report this bug!</span>")
		log_admin("Failed to set-up a round of wizard. Couldn't find any wizard spawn points.")
		message_admins("Failed to set-up a round of wizard. Couldn't find any wizard spawn points.")
		return 0 //Critical failure.
	..()

/datum/faction/wizard/forgeObjectives()
	for(var/datum/role/R in members)
		R.ForgeObjectives()
		R.AnnounceObjectives()

/datum/faction/wizard/ragin
	accept_latejoiners = TRUE
	var/max_wizards

/datum/faction/wizard/ragin/check_win()
	if(members.len == max_roles)
		return 1