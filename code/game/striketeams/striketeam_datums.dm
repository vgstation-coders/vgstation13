
var/list/sent_strike_teams = list()

/datum/striketeam
	var/striketeam_name = "Spec.Ops."
	var/faction_name = "Nanotrasen"
	var/mission = "Clean up the Station of all enemies of Nanotrasen. Avoid damage to Nanotrasen assets, unless you judge it necessary."
	var/team_size = 6
	var/min_size_for_leader = 4//set to 0 so there's always a designated team leader or to -1 so there is no leader.
	var/spawns_name = "Commando"
	var/can_customize = FALSE
	var/logo = "nano-logo"

	var/list/applicants = list()
	var/searching = FALSE

	var/leader_key = ""
	var/list/team_composition = list()


/datum/striketeam/proc/trigger_strike(var/mob/user)
	//Is the game started
	if(!ticker)
		if(user)
			to_chat(user, "<span class='warning'>The game hasn't started yet!</span>")
		qdel(src)
		return

	//Has someone already sent a strike team of this type
	if(sentStrikeTeams(striketeam_name))
		if(user)
			to_chat(user, "<span class='warning'>[faction_name] has already sent \a [striketeam_name].</span>")
		qdel(src)
		return

	//Logging
	message_admins("<span class='notice'>[key_name(user)] is preparing a [striketeam_name].</span>", 1)

	if(user)
		if(alert("Do you really want [faction_name] to send in the [striketeam_name]?",,"Yes","No")!="Yes")
			qdel(src)
			return

		mission = input(user, "Please specify which mission the [striketeam_name] shall undertake.", "Specify Mission", "")

		if(!mission)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				qdel(src)
				return
			else
				mission = initial(mission)

		if(sentStrikeTeams(striketeam_name))
			to_chat(user, "Looks like someone beat you to it.")
			qdel(src)
			return

	sent_strike_teams[striketeam_name] = src

	if(user)
		to_chat(user, "<span class='notice'>[faction_name] has received your request. Commando applications will be open for the next minute.</span>")

	searching = TRUE

	var/icon/team_logo = icon('icons/mob/mob.dmi', logo)
	for(var/mob/dead/observer/O in dead_mob_list)
		if(!O.client || jobban_isbanned(O, "Strike Team") || O.client.is_afk())
			continue

		to_chat(O, "[bicon(team_logo)]<span class='recruit'>[faction_name] needs YOU to become part of its upcoming [striketeam_name]. (<a href='?src=\ref[src];signup=\ref[O]'>Apply now!</a>)</span>[bicon(team_logo)]")

	spawn(1 MINUTES)
		searching = FALSE

		for(var/mob/dead/observer/O in dead_mob_list)
			if(!O.client || jobban_isbanned(O, "Strike Team") || O.client.is_afk())
				continue
			to_chat(O, "[bicon(team_logo)]<span class='recruit'>Applications for [faction_name]'s [striketeam_name] are now closed.</span>[bicon(team_logo)]")

		if(!applicants || applicants.len <= 0)
			log_admin("[striketeam_name] received no applications.")
			message_admins("[striketeam_name] received no applications.")
			failure()
			qdel(src)
			return

		var/list/commando_spawns = list_commando_spawns()
		var/commando_count = min(applicants.len,team_size)
		var/leader = FALSE

		if(min_size_for_leader >= 0 && applicants.len >= min_size_for_leader)
			leader = TRUE

		for (var/i = commando_count, i > 0, i--)
			if (commando_spawns.len <= 0)
				commando_spawns = list_commando_spawns()
				//The point here is to try not having commandos spawn atop each others.

			if(applicants.len <= 0)
				break

			var/mob/applicant = null
			for(var/mob/M in player_list)
				if(M.key == pick(applicants))
					applicant = M
			applicants -= applicant.key

			if(!isobserver(applicant))
				//Making sure we don't recruit people who got back into the game since they applied
				continue

			var/obj/effect/landmark/L = pick(commando_spawns)
			commando_spawns -= L

			spawn()//not waiting for players to customize their characters to move on
				var/mob/living/carbon/human/new_commando = create_commando(L, leader, applicant.key)
				team_composition |= new_commando
				new_commando.key = applicant.key

				if (leader)
					leader_key = new_commando.key
					leader = FALSE

				new_commando.mind.store_memory("<B>Mission:</B> <span class='warning'>[mission].</span>")

				greet_commando(new_commando)
		extras()

/datum/striketeam/proc/create_commando(var/obj/spawn_location,var/leader_selected=0,var/mob_key = "")
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	return new_commando

/datum/striketeam/proc/greet_commando(var/mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>You are a [striketeam_name] commando, in the service of [faction_name].</span>")
	to_chat(H, "<span class='notice'>Your current mission is: <span class='danger'>[mission]</span></span>")

/datum/striketeam/Topic(var/href, var/list/href_list)
	if(href_list["signup"])
		var/mob/dead/observer/O = usr
		if(!O || !istype(O))
			return

		volunteer(O)

/datum/striketeam/proc/failure()

/datum/striketeam/proc/extras()

/datum/striketeam/proc/volunteer(var/mob/dead/observer/O)
	if(!searching || !istype(O))
		return

	if(jobban_isbanned(O, "Strike Team"))
		to_chat(O, "<span class='danger'>Banned from Strike Teams.</span>")
		to_chat(O, "<span class='warning'>Your application to the [striketeam_name] has been discarded due to past conduct..</span>")
		return

	if(O.key in applicants)
		to_chat(O, "<span class='notice'>Removed from the [striketeam_name] registration list.</span>")
		applicants -= O.key
		return

	else
		to_chat(O, "<span class='notice'>Added to the [striketeam_name] registration list.</span>")
		applicants |= O.key
		return


/datum/striketeam/proc/list_commando_spawns()
	var/list/commando_spawns = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name == spawns_name)
			commando_spawns |= L
	return commando_spawns

///////////////////////////////////////CUSTOM STRIKE TEAMS///////////////////////////////////

/datum/striketeam/custom/trigger_strike(var/mob/user)
	striketeam_name = input(user, "Name your strike team.", "Custom Strike Team", "")
	faction_name = input(user, "Name the organization sending this strike team.", "Custom Strike Team", "")
	team_size = input(user, "Set the maximum amount of commandos in your squad", "Custom Strike Team", "") as num
	min_size_for_leader = -1
	spawns_name = input(user, "What are named the landmarks you want your squadies to spawn at?", "Custom Strike Team", "")
	can_customize = FALSE
	logo = input(user, "Got a custom logo for your strike team?", "Custom Strike Team", "nano-logo")
	..()
