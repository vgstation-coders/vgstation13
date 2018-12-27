/datum/role/weeaboo
	name = WEEABOO 
	id = WEEABOO
	required_pref = ROLE_WEEABOO
	special_role = WEEABOO
	logo_state = "weeaboo-logo"

/datum/role/weeaboo/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		antag.current << sound('sound/effects/gong.ogg')
		equip_weeaboo(antag.current)
		name_weeaboo(antag.current)

/datum/role/weeaboo/ForgeObjectives()
	AppendObjective(/datum/objective/target/steal)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/target/skulls)
	AppendObjective(/datum/objective/escape)

/datum/role/weeaboo/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Space Weeaboo.<br>The crew has insulted glorious Space Nippon. Equipped with your authentic Space Kimono, your Space Katana that was folded over a million times, and your honobru bushido code, you must implore them to reconsider!</span>")

	to_chat(antag.current, "<span class='danger'>Remember that guns are not honobru, and that your katana has an ancient power imbued within it. Take a closer look at it if you've forgotten how it works.</span>")
