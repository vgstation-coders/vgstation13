
/datum/role/plague_mouse
	name = PLAGUEMOUSE
	id = PLAGUEMOUSE
	special_role = PLAGUEMOUSE
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "plague-logo"
	greets = list(GREET_DEFAULT)

datum/role/plague_mouse/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are a [name]! Carrier of a dangerous Bacteria!</B><BR>Try and spread your contagion across the station!</span>")

