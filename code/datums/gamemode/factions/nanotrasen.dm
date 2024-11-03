
/datum/faction/strike_team/ert
	name = "Emergency Response Team"
	ID = ERT
	initroletype = /datum/role/emergency_responder
	roletype = /datum/role/emergency_responder
	logo_state = "ert-logo"
	hud_icons = list("ert-logo")
	default_admin_voice = "Nanotrasen Central Command"
	admin_voice_style = "resteamradio"

//________________________________________________

/datum/faction/strike_team/deathsquad
	name = "Nanotrasen Deathsquad"
	ID = DEATHSQUAD
	initroletype = /datum/role/death_commando
	roletype = /datum/role/death_commando
	logo_state = "death-logo"
	hud_icons = list("death-logo","creed-logo")
	default_admin_voice = "Nanotrasen Central Command"
	admin_voice_style = "dsquadradio"

//________________________________________________

/datum/faction/nanotrasen
	name = "Nanotrasen Officials"
	ID = NANOTRASEN
	logo_state = "nano-logo"
	initroletype = /datum/role/nanotrasen_official
	roletype = /datum/role/nanotrasen_official
	default_admin_voice = "Nanotrasen Central Command"
	admin_voice_style = "resteamradio"
	var/delta = FALSE//goes true once the ERT call has been made

/datum/faction/nanotrasen/forgeObjectives()
	for(var/datum/role/R in members)
		R.ForgeObjectives()
		R.AnnounceObjectives()
