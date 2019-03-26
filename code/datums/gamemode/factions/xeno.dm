/datum/faction/xeno_hive
	name = "Xenomorph hivemind"
	ID = ROLE_ALIEN
	initroletype = /datum/role/xeno
	roletype = /datum/role/xeno
	logo_state = "xeno-logo"
	hud_icons = list("xeno-logo")

/datum/faction/xeno_hive/make_leader()
	.=..()
	if(.)
		message_all_members("<b>We have a new queen!</b>")

/datum/role/xeno
	name = XENO
	id = XENO
	logo_state = "xeno-logo"

/datum/role/xeno/Greet()
	to_chat(antag.current, "<b>You are a xenomorph!</b><br>You must do what you can to propogate your race. Secure a nest, create and serve a queen, secure new hosts.")
	to_chat(antag.current, "Speak to the hivemind through :a. Lurk inside alien weed to regenerate plasma. Some xenos can ventcrawl through alt-clicking a vent or scrubber.")