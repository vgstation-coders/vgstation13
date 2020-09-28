/datum/role/undead
	name = "undead"
	id = UNDEAD
	logo_state = "undead-logo"

/datum/role/undead/Greet()
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><B><span class='warning'>You are an Undead!</span></B>")
	to_chat(antag.current, "<B><span class='warning'>If you became an undead via necromancy, follow your necromancer's orders. Otherwise, find & consume the flesh of anything that looks tasty.</span></B>")

