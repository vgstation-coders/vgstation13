var/list/current_prisoners = list()

/datum/role/prisoner
	name = PRISONER
	id = PRISONER
	special_role = PRISONER
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "prisoner-logo"
	default_admin_voice = "The Syndicate"
	admin_voice_style = "secradio"

	var/moneyBonus = 100

/datum/role/prisoner/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a Syndicate prisoner!</span></B>")
	to_chat(antag.current, "You were transferred to this station from Alcatraz IV. You know nothing about this station or the people aboard it.")
	to_chat(antag.current, "<span class='danger'>Do your best to survive and escape, but remember that every move you make could be your last.</span>")

/datum/role/prisoner/ForgeObjectives()
	AppendObjective(/datum/objective/survive)
	AppendObjective(/datum/objective/escape_prisoner)
	AppendObjective(/datum/objective/minimize_casualties)
