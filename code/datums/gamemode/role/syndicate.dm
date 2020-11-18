/datum/role/traitor
	name = TRAITOR
	id = TRAITOR
	required_pref = TRAITOR
	logo_state = "synd-logo"
	wikiroute = TRAITOR
	var/can_be_smooth = TRUE //Survivors can't be smooth because they get nothing.

/datum/role/traitor/OnPostSetup()
	..()
	share_syndicate_codephrase(antag.current)
	if(istype(antag.current, /mob/living/silicon))
		can_be_smooth = FALSE //Can't buy anything
		add_law_zero(antag.current)
		antag.current << sound('sound/voice/AISyndiHack.ogg')
	else
		equip_traitor(antag.current, 20)
		antag.current << sound('sound/voice/syndicate_intro.ogg')

/datum/role/traitor/Drop()
	if(isrobot(antag.current))
		var/mob/living/silicon/robot/S = antag.current
		to_chat(S, "<b>Your laws have been changed!</b>")
		S.set_zeroth_law("")
		S.laws.zeroth_lock = FALSE
		to_chat(S, "Law 0 has been purged.")
	else if(isAI(antag.current))
		var/mob/living/silicon/ai/KAI = antag.current
		to_chat(KAI, "<b>Your laws have been changed!</b>")
		KAI.set_zeroth_law("","")
		KAI.laws.zeroth_lock = FALSE
		KAI.notify_slaved()
	else if(ishuman(antag.current))
		antag.take_uplink()

	.=..()

/datum/role/traitor/ForgeObjectives()
	if(!antag.current.client.prefs.antag_objectives)
		AppendObjective(/datum/objective/freeform/syndicate)
		return
	if(istype(antag.current, /mob/living/silicon))
		AppendObjective(/datum/objective/target/delayed/assassinate)

		AppendObjective(/datum/objective/survive)

		if(prob(10))
			AppendObjective(/datum/objective/block)

	else
		AppendObjective(/datum/objective/target/delayed/assassinate)
		AppendObjective(/datum/objective/target/steal)
		switch(rand(1,100))
			if(1 to 30) // Die glorious death
				if(!(locate(/datum/objective/die) in objectives.GetObjectives()) && !(locate(/datum/objective/target/steal) in objectives.GetObjectives()))
					AppendObjective(/datum/objective/die)
				else
					if(prob(85))
						if (!(locate(/datum/objective/escape) in objectives.GetObjectives()))
							AppendObjective(/datum/objective/escape)
					else
						if(prob(50))
							if (!(locate(/datum/objective/hijack) in objectives.GetObjectives()))
								AppendObjective(/datum/objective/hijack)
						else
							if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
								AppendObjective(/datum/objective/minimize_casualties)
			if(31 to 90)
				if (!(locate(/datum/objective/escape) in objectives.objectives))
					AppendObjective(/datum/objective/escape)
			else
				if(prob(50))
					if (!(locate(/datum/objective/hijack) in objectives.objectives))
						AppendObjective(/datum/objective/hijack)
				else // Honk
					if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
						AppendObjective(/datum/objective/minimize_casualties)

/datum/role/traitor/extraPanelButtons()
	var/dat = ""
	var/obj/item/device/uplink/hidden/guplink = antag.find_syndicate_uplink()
	if(guplink)
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];telecrystalsSet=1;'>Telecrystals: [guplink.uses](Set telecrystals)</a><br>"
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a><br>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a><br>"
	return dat

/datum/role/traitor/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	if(href_list["giveuplink"])
		equip_traitor(antag.current, 20)
	if(href_list["telecrystalsSet"])
		var/obj/item/device/uplink/hidden/guplink = M.find_syndicate_uplink()
		var/amount = input("What would you like to set their crystal count to?", "Their current count is [guplink.uses]") as null|num
		if(isnum(amount) && amount >= 0)
			to_chat(usr, "<span class = 'notice'>You have set [M]'s uplink telecrystals to [amount].</span>")
			guplink.uses = amount

	if(href_list["removeuplink"])
		M.take_uplink()
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")

/datum/role/traitor/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Syndicate agent, a Traitor.</span>")
		if (GREET_AUTOTATOR)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are now a Traitor.<br>Your memory clears up as you remember your identity as a sleeper agent of the Syndicate. It's time to pay your debt to them. </span>")
		if (GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.<br>As a Syndicate agent, you are to infiltrate the crew and accomplish your objectives at all cost.</span>")
		if (GREET_SYNDBEACON)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You have joined the ranks of the Syndicate and become a traitor to Nanotrasen!</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/datum/role/traitor/GetScoreboard()
	. = ..()
	if(can_be_smooth)
		if(uplink_items_bought)
			. += "The traitor bought:<BR>"
			for(var/entry in uplink_items_bought)
				. += "[entry]<BR>"
		else
			. += "The traitor was a smooth operator this round.<BR>"

//________________________________________________


/datum/role/traitor/rogue//double agent
	name = ROGUE
	id = ROGUE
	wikiroute = ROGUE
	logo_state = "synd-logo"
	var/datum/role/traitor/rogue/assassination_target = null

/datum/role/traitor/rogue/ForgeObjectives()
	if (assassination_target && assassination_target.antag)
		var/datum/objective/target/assassinate/kill_target = new(auto_target = FALSE)
		if(kill_target.set_target(assassination_target.antag))
			AppendObjective(kill_target)
			return
		else
			qdel(kill_target)
	to_chat(antag.current, "<span class='danger'>It would appear that your enemies never in fact made it to the station. Looks like you're safe this time around.</span>")
	//that should never appear though since the ruleset requires 2 players minimum but you know just in case

/datum/role/traitor/rogue/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Rogue Syndicate agent. Relations with the other groups in the Syndicate Coalition have gone south, take the other agents out before they do the same to you.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Rogue Syndicate agent.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

//________________________________________________

/datum/role/nuclear_operative
	name = NUKE_OP
	id = NUKE_OP
	required_pref = NUKE_OP
	disallow_job = TRUE
	logo_state = "nuke-logo"

/datum/role/nuclear_operative/leader
	name = NUKE_OP_LEADER
	id = NUKE_OP_LEADER
	required_pref = NUKE_OP
	disallow_job = TRUE
	logo_state = "nuke-logo-leader"

/datum/role/nuclear_operative/leader/OnPostSetup()
	if(antag)
		var/datum/action/play_ops_music/go_loud = new /datum/action/play_ops_music(antag)
		go_loud.linkedfaction = faction
		go_loud.Grant(antag.current)
	..()

/datum/action/play_ops_music
	name = "Go Loud"
	desc = "For the operative who prefers style over subtlety."
	icon_icon = 'icons/obj/device.dmi'
	button_icon_state = "megaphone"
	var/datum/faction/linkedfaction

/datum/action/play_ops_music/Trigger()
	var/mob/living/M = owner
	if(!linkedfaction)
		qdel(src)
		return
	var/confirm = alert(M, "Are you sure you want to announce your presence? Doing so will display a command announcement and start the Nuclear Assault playlist.", "Are you sure?", "No", "Yes")
	if (confirm == "Yes" && M.stat == CONSCIOUS)
		ticker.StartThematic(linkedfaction.playlist)
		command_alert(/datum/command_alert/nuclear_operatives)
		qdel(src)