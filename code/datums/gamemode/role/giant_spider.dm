
/datum/role/giant_spider
	name = GIANTSPIDER
	id = GIANTSPIDER
	special_role = GIANTSPIDER
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "spider-logo"
	greets = list(GREET_DEFAULT)
	default_admin_voice = "Your Spider Senses"
	admin_voice_style = "skeleton"

/datum/role/giant_spider/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are a spiderling!</B><BR>Hide until you can evolve into a giant spider and terrorize the crew!</span>")
