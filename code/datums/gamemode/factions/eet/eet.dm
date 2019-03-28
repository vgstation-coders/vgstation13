var/global/obj/structure/reagent_dispensers/eet_ship_core/eet_core
var/global/obj/machinery/smartfridge/eet_archive/eet_arch
var/global/obj/structure/eet_continuum/eet_cont
var/global/datum/religion/eet_rel
var/global/datum/seed/eet_seeds
var/global/datum/disease2/eet_virus

/datum/faction/eet
	name = "Enigmatic Extraterrestrials"
	ID = EET
	initial_role = EET
	late_role = EET
	required_pref = ROLE_MINOR
	desc = "The little-understood grey unitary organization. Their actions often seem difficult to understand."
	initroletype = /datum/role/eet
	roletype = /datum/role/eet
	logo_state = "eet-logo"
	hud_icons = list("eet-logo")
	accept_latejoiners = TRUE
	max_roles = 5

/datum/faction/eet/New()
	..()
	spawn(5 MINUTES)
		command_alert(/datum/command_alert/eets)

/datum/faction/eet/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "EET"
	M.original = M.current

/datum/faction/eet/OnPostSetup()
	if(!eet_cont)
		for(var/datum/role/eet in members)
			to_chat(eet.antag.current, "<span class='danger'>A starting location for you could not be found, please report this bug!</span>")
		log_admin("Failed to set-up a round of EET. Couldn't find any EET spawn points.")
		message_admins("Failed to set-up a round of EET. Couldn't find any EET spawn points.")
		return 0 //Critical failure.
	..()

/datum/faction/eet/forgeObjectives()
	AppendObjective(/datum/objective/eet/fuel)
	AppendObjective(/datum/objective/eet/mindescape)
	for(var/datum/role/R in members)
		R.ForgeObjectives()
		R.AnnounceObjectives()