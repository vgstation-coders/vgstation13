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
	logo_state = "synd-logo"

/datum/role/traitor/rogue/ForgeObjectives()
	var/datum/role/traitor/rogue/rival
	var/list/potential_rivals = list()
	if(faction && faction.members)
		potential_rivals = faction.members-src
	else
		for(var/datum/role/traitor/rogue/R in ticker.mode.orphaned_roles) //It'd be awkward if you ended up with your rival being a vampire.
			if(R != src)
				potential_rivals.Add(R)
	if(potential_rivals.len)
		rival = pick(potential_rivals)
	if(!rival) //Fuck it, you're now a regular traitor
		return ..()

	var/datum/objective/target/assassinate/kill_rival = new(auto_target = FALSE)
	if(kill_rival.set_target(rival.antag))
		AppendObjective(kill_rival)
	else
		qdel(kill_rival)

	if(prob(70)) //Your target knows!
		var/datum/objective/target/assassinate/kill_new_rival = new(auto_target = FALSE)
		if(kill_new_rival.set_target(antag))
			rival.AppendObjective(kill_new_rival)
		else
			qdel(kill_new_rival)

	if(prob(50)) //Spy v Spy
		var/datum/objective/target/assassinate/A = new()
		if(A.target)
			AppendObjective(A)

			var/datum/objective/target/protect/P = new(auto_target = FALSE)
			if(P.set_target(A.target))
				rival.AppendObjective(P)

	if(prob(30))
		AppendObjective(/datum/objective/target/steal)

	switch(rand(1,3))
		if(1)
			if(!locate(/datum/objective/target/steal) in objectives.GetObjectives())
				AppendObjective(/datum/objective/die)
			else
				AppendObjective(/datum/objective/escape)
		if(2)
			AppendObjective(/datum/objective/hijack)
		else
			AppendObjective(/datum/objective/escape)

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