
var/list/sent_strike_teams = list()

/datum/striketeam
	var/striketeam_name = "Spec.Ops."
	var/faction_name = "Nanotrasen"
	var/mission = "Clean up the Station of all enemies of Nanotrasen. Avoid damage to Nanotrasen assets, unless you judge it necessary."
	var/team_size = 6
	var/min_size_for_leader = 4//set to 0 so there's always a designated team leader or to -1 so there is no leader.
	var/spawns_name = "Striketeam"
	var/can_customize = FALSE
	var/logo = "nano-logo"
	var/custom = 0

	var/list/applicants = list()
	var/searching = FALSE

	var/leader_key = ""
	var/leader_name = "" //Currently only called by deathsquad striketeam
	var/list/team_composition = list()

	var/list/datum/objective/objectives = list()

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

		if(sentStrikeTeams(striketeam_name) || (custom && sentStrikeTeams(TEAM_CUSTOM)))
			to_chat(user, "Looks like someone beat you to it.")
			qdel(src)
			return

	if (custom)
		sent_strike_teams[TEAM_CUSTOM] = src
	else
		sent_strike_teams[striketeam_name] = src

	if(user)
		to_chat(user, "<span class='notice'>[faction_name] has received your request. Commando applications will be open for the next minute.</span>")

	searching = TRUE

	var/icon/team_logo = icon('icons/logos.dmi', logo)
	for(var/mob/dead/observer/O in dead_mob_list)
		if(!O.client || jobban_isbanned(O, ROLE_STRIKE) || O.client.is_afk())
			continue

		to_chat(O, "[bicon(team_logo)]<span class='recruit'>[faction_name] needs YOU to become part of its upcoming [striketeam_name]. (<a href='?src=\ref[src];signup=\ref[O]'>Apply now!</a>)</span>[bicon(team_logo)]")
		to_chat(O, "[bicon(team_logo)]<span class='recruit'>Their mission: [mission]</span>[bicon(team_logo)]")

	spawn(1 MINUTES)
		searching = FALSE

		for(var/mob/dead/observer/O in dead_mob_list)
			if(!O.client || jobban_isbanned(O, ROLE_STRIKE) || O.client.is_afk())
				continue
			to_chat(O, "[bicon(team_logo)]<span class='recruit'>Applications for [faction_name]'s [striketeam_name] are now closed.</span>[bicon(team_logo)]")

		if(!applicants || applicants.len <= 0)
			log_admin("[striketeam_name] received no applications.")
			message_admins("[striketeam_name] received no applications.")
			failure()
			if (custom)
				sent_strike_teams -= TEAM_CUSTOM
			else
				sent_strike_teams -= striketeam_name
			qdel(src)
			return

		log_admin("[applicants.len] players volunteered for [striketeam_name].")
		message_admins("[applicants.len] players volunteered for [striketeam_name].")

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
			var/selected_key = pick(applicants)
			for(var/mob/M in player_list)
				if(M.key == selected_key)
					applicant = M

			applicants -= selected_key

			if(!isobserver(applicant))
				//Making sure we don't recruit people who got back into the game since they applied
				i++
				continue

			if (leader)
				leader_key = applicant.key
				leader = FALSE

			var/obj/effect/landmark/L = pick(commando_spawns)
			commando_spawns -= L

			spawn()//not waiting for players to customize their characters to move on
				var/isLeader = FALSE
				if(leader_key == applicant.key)
					isLeader = TRUE

				var/mob/living/carbon/human/new_commando = create_commando(L, isLeader, applicant.key)
				team_composition |= new_commando

				new_commando.key = applicant.key

				new_commando.update_action_buttons_icon()

				greet_commando(new_commando)
		extras()

/datum/striketeam/proc/create_commando(var/obj/spawn_location,var/leader_selected=0,var/mob_key = "")
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	return new_commando

/datum/striketeam/proc/greet_commando(var/mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>You are a [striketeam_name] commando, in the service of [faction_name].</span>")
	for (var/role in H.mind.antag_roles)
		var/datum/role/R = H.mind.antag_roles[role]
		R.AnnounceObjectives()

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

	if(jobban_isbanned(O, ROLE_STRIKE))
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

/datum/striketeam/custom
	var/can_customize_name = 0
	var/can_customize_appearance = 0
	var/defaultname = "Commando"

/datum/striketeam/custom/trigger_strike(var/mob/user)
	custom = 1
	var/turf/T = null
	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name == spawns_name)
			T = get_turf(L)
			break
	if (!T)
		to_chat(user,"<span class='danger'>This map has no areas for custom strike teams to set up!</span>")
		return
	striketeam_name = input(user, "Name your strike team.", "Custom Strike Team", "")
	faction_name = input(user, "Name the organization sending this strike team.", "Custom Strike Team", "")
	team_size = input(user, "Set the maximum amount of commandos in your squad", "Custom Strike Team", "") as num
	min_size_for_leader = -1
	spawns_name = "Striketeam"

	if(alert("Let the team members choose their name?",,"Yes", "No") == "Yes")
		can_customize_name = 1

	if(!can_customize_name)
		defaultname = input(user, "What should their names be then? Keep Commando for random names.", "Custom Strike Team", "Commando")

	if(alert("Let the team members choose their appearance?",,"Yes", "No") == "Yes")
		can_customize_appearance = 1
	//logo = input(user, "Got a custom logo for your strike team?", "Custom Strike Team", "nano-logo")
	to_chat(user,"<span class='notice'>Remember to set up your team's spawn and dispensers.(<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)</span>")
	..()

/datum/striketeam/custom/Topic(var/href, var/list/href_list)
	..()
	if(href_list["jump"])
		var/mob/dead/observer/O = usr
		if(!O || !istype(O))
			return

/datum/striketeam/custom/create_commando(var/obj/spawn_location,var/leader_selected=0,var/mob_key = "")
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)

	var/mob/user = null
	for(var/mob/MO in player_list)
		if(MO.key == mob_key)
			user = MO

	to_chat(user, "<span class='notice'>Congratulations, you've been selected to be part of \the [striketeam_name]. You can customize your character, but don't take too long, time is of the essence!</span>")

	var/commando_name = defaultname

	if(can_customize_name)
		var/new_name = copytext(sanitize(input(user, "Pick a name","Name") as null|text), 1, MAX_MESSAGE_LEN)
		if(!new_name)
			new_name = defaultname
		commando_name = new_name
	else if (defaultname == "Commando")
		var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
		var/commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
		commando_name = pick(last_names)
		commando_name = "[!leader_selected ? commando_rank : commando_leader_rank] [commando_name]"

	new_commando.real_name = commando_name
	new_commando.name = commando_name

	if(can_customize_appearance)
		var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
		if(new_facial)
			new_commando.my_appearance.r_facial = hex2num(copytext(new_facial, 2, 4))
			new_commando.my_appearance.g_facial = hex2num(copytext(new_facial, 4, 6))
			new_commando.my_appearance.b_facial = hex2num(copytext(new_facial, 6, 8))

		var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
		if(new_facial)
			new_commando.my_appearance.r_hair = hex2num(copytext(new_hair, 2, 4))
			new_commando.my_appearance.g_hair = hex2num(copytext(new_hair, 4, 6))
			new_commando.my_appearance.b_hair = hex2num(copytext(new_hair, 6, 8))

		var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
		if(new_eyes)
			new_commando.my_appearance.r_eyes = hex2num(copytext(new_eyes, 2, 4))
			new_commando.my_appearance.g_eyes = hex2num(copytext(new_eyes, 4, 6))
			new_commando.my_appearance.b_eyes = hex2num(copytext(new_eyes, 6, 8))

		var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

		if (!new_tone)
			new_tone = 35
		new_commando.my_appearance.s_tone = max(min(round(text2num(new_tone)), 220), 1)
		new_commando.my_appearance.s_tone =  -new_commando.my_appearance.s_tone + 35

		// hair
		var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
		var/list/hairs = list()

		// loop through potential hairs
		for(var/x in all_hairs)
			var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
			hairs.Add(H.name) // add hair name to hairs
			qdel(H) // delete the hair after it's all done
			H = null

		//hair
		var/new_hstyle = input(user, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
		if(new_hstyle)
			new_commando.my_appearance.h_style = new_hstyle

		// facial hair
		var/new_fstyle = input(user, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
		if(new_fstyle)
			new_commando.my_appearance.f_style = new_fstyle

		var/new_gender = alert(user, "Please select gender.", "Character Generation", "Male", "Female")
		if (new_gender)
			if(new_gender == "Male")
				new_commando.setGender(MALE)
			else
				new_commando.setGender(FEMALE)
	else
		new_commando.setGender(pick(MALE, FEMALE))
		new_commando.randomise_appearance_for(new_commando.gender)

	//M.rebuild_appearance()
	new_commando.update_hair()
	new_commando.update_body()
	new_commando.check_dna(new_commando)

	new_commando.age = !leader_selected ? rand(23,35) : rand(35,45)

	new_commando.dna.ready_dna(new_commando)//Creates DNA.

	//Creates mind stuff.
	new_commando.mind = new
	new_commando.mind.current = new_commando
	new_commando.mind.original = new_commando
	new_commando.mind.assigned_role = "MODE"
	new_commando.mind.special_role = "Custom Team"
	if(!(new_commando.mind in ticker.minds))
		ticker.minds += new_commando.mind//Adds them to regular mind list.

	var/datum/faction/customsquad = find_active_faction_by_type(/datum/faction/strike_team/custom)
	if(customsquad)
		customsquad.HandleRecruitedMind(new_commando.mind)
	else
		customsquad = ticker.mode.CreateFaction(/datum/faction/strike_team/custom)
		customsquad.name = striketeam_name
		customsquad.forgeObjectives(mission)
		if(customsquad)
			customsquad.HandleNewMind(new_commando.mind) //First come, first served

	return new_commando