
/datum/role/pulse_demon
	name = PULSEDEMON
	id = PULSEDEMON
	special_role = PULSEDEMON
	required_pref = PULSEDEMON
	wikiroute = PULSEDEMON
	logo_state = "pulsedemon-logo"
	greets = list(GREET_DEFAULT)
	default_admin_voice = "The Currents"
	admin_voice_style = "skeleton"
	var/list/obj/machinery/power/apc/controlled_apcs = list()
	var/charge_absorbed = 0

/datum/role/pulse_demon/extraPanelButtons()
	if(istype(antag.current,/mob/living/simple_animal/hostile/pulse_demon))
		var/mob/living/simple_animal/hostile/pulse_demon/PD = antag.current
		var/dat = ""
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];setCharge=1;'>Charge: [PD.charge/1000]kW (Set charge)</a>"
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];setMaxCharge=1;'>Max charge: [PD.maxcharge/1000]kW (Set max charge)</a><br>"
		return dat

/datum/role/pulse_demon/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	..()
	if(istype(antag.current,/mob/living/simple_animal/hostile/pulse_demon))
		var/mob/living/simple_animal/hostile/pulse_demon/PD = antag.current
		if(href_list["setCharge"])
			var/amount = input("What would you like to set their charge to, in watts?", "Their current charge is [PD.charge/1000]kW") as null|num
			if(isnum(amount) && amount >= 0)
				to_chat(usr, "<span class = 'notice'>You have set [PD]'s charge to [amount/1000]kW.</span>")
				PD.charge = amount
		if(href_list["setMaxCharge"])
			var/amount = input("What would you like to set their max charge to, in watts?", "Their current max charge is [PD.maxcharge/1000]kW") as null|num
			if(isnum(amount) && amount >= 0)
				to_chat(usr, "<span class = 'notice'>You have set [PD]'s max charge to [amount/1000]kW.</span>")
				PD.maxcharge = amount

/datum/role/pulse_demon/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are a pulse demon, a being of pure electrical energy that travels along the station's wires and infests machinery!</B></span>")
			to_chat(antag.current, "<BR><B>Travel along power cables to visit APCs or power machinery such as rad collectors and SMEs. Once in an APC, you can spend time in it to hijack it and control any machinery in the visible area as you please! Other power machinery allows you to take advantage of power stored within them to upgrade your charge and refill it.</B>")
			to_chat(antag.current, "<BR><B>Don't let your charge run out! If the powernet blacks out you'll start losing health and eventually die off! You are immune to all forms of damage and obstacles in the way of cables, but are also extremely weak to EMPs, so avoid those at all costs.</B>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/datum/role/pulse_demon/ForgeObjectives()
	if(prob(50))
		AppendObjective(/datum/objective/pulse_demon/infest)
	if(prob(50))
		AppendObjective(/datum/objective/pulse_demon/drain)
	AppendObjective(/datum/objective/pulse_demon/tamper)

/datum/role/pulse_demon/GetScoreboard()
	. = ..()
	if(istype(antag.current,/mob/living/simple_animal/hostile/pulse_demon))
		var/mob/living/simple_animal/hostile/pulse_demon/PD = antag.current
		var/bought_nothing = TRUE
		if(PD.spell_list.len > 1)
			bought_nothing = FALSE
			. += "<BR>The pulse demon knew:<BR>"
			for(var/spell/S in PD.spell_list)
				if(!istype(PD,/spell/pulse_demon/abilities))
					var/icon/tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
					. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"
		if(bought_nothing)
			. += "The pulse demon did not use any abilities this round.<BR>"
		. += "The pulse demon hijacked [controlled_apcs.len] APCs with a takeover time of [PD.takeover_time] seconds and a health of [PD.maxHealth], absorbing [PD.charge_absorb_amount]W per second.<BR>"
