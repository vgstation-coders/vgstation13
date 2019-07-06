client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"
	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()


	var/dat = {"<B>One-click Antagonist</B><br>
		<a href='?src=\ref[src];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=\ref[src];makeAntag=2'>Make Changlings</a><br>
		<a href='?src=\ref[src];makeAntag=3'>Make Revs</a><br>
		<a href='?src=\ref[src];makeAntag=4'>Make Cult</a><br>
		<a href='?src=\ref[src];makeAntag=5'>Make Malf AI</a><br>
		<a href='?src=\ref[src];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=7'>Make Vampires</a><br>
		<a href='?src=\ref[src];makeAntag=8'>Make Aliens (Requires Ghosts)</a><br>
		"}

	usr << browse(dat, "window=oneclickantag;size=400x400")
	return


/datum/admins/proc/makeMalfAImode()


	var/list/mob/living/silicon/AIs = list()
	var/mob/living/silicon/malfAI = null
	var/datum/mind/themind = null

	for(var/mob/living/silicon/ai/ai in player_list)
		if(ai.client)
			AIs += ai

	var/malf_made = FALSE
	while(!malf_made && AIs.len)
		malfAI = pick(AIs)
		AIs.Remove(malfAI)
		if(malfAI)
			themind = malfAI.mind
			malf_made = themind.make_AI_Malf()


	return malf_made

/datum/admins/proc/makeAntag(var/datum/role/R, var/datum/faction/F, var/count = 1, var/recruitment_source = FROM_PLAYERS)
	var/role_req
	var/role_name
	if(F)
		role_req = initial(F.required_pref)
		role_name = initial(F.name)
	else if(R)
		role_req = initial(R.required_pref)
		role_name = initial(R.name)
	var/list/candidates = get_candidates(role_req, recruitment_source, role_name)
	var/recruit_count = 0
	if(!candidates.len)
		return 0

	candidates = shuffle(candidates)

	if(F)
		var/datum/faction/FF = find_active_faction_by_type(F)
		if(!FF)
			FF = ticker.mode.CreateFaction(F, 0, 1)
			if(!FF)
				return 0
			var/mob/H = pick(candidates)
			candidates.Remove(H)
			if(isobserver(H))
				H = makeBody(H)
			var/datum/mind/M = H.mind
			if(FF.HandleNewMind(M))
				var/datum/role/RR = FF.get_member_by_mind(M)
				RR.OnPostSetup()
				RR.Greet(GREET_LATEJOIN)
				message_admins("[key_name(H)] has been recruited as leader of [FF.name] via create antagonist verb.")
				recruit_count++
				count--

		while(count > 0 && candidates.len)
			count--
			var/mob/living/carbon/human/H = pick(candidates)
			candidates.Remove(H)
			if (initial(F.initial_role) in H.mind.antag_roles) // Ex: a head rev being made a revolutionary.
				continue
			if(isobserver(H))
				H = makeBody(H)
			var/datum/mind/M = H.mind
			message_admins("polling if [key_name(H)] wants to become a member of [FF.name]")
			if(FF.HandleRecruitedMind(M))
				var/datum/role/RR = FF.get_member_by_mind(M)
				RR.OnPostSetup()
				RR.Greet(GREET_LATEJOIN)
				message_admins("[key_name(H)] has been recruited as recruit of [F.name] via create antagonist verb.")
				recruit_count++

		FF.OnPostSetup()
		FF.forgeObjectives()

		return recruit_count

	else if(R)
		while(count > 0 && candidates.len)
			count--
			var/mob/H = pick(candidates)
			candidates.Remove(H)
			if(isobserver(H))
				H = makeBody(H)
			var/datum/mind/M = H.mind
			if(M.GetRole(initial(R.id)))
				continue
			var/datum/role/newRole = new R
			message_admins("polling if [key_name(H)] wants to become a [newRole.name]")
			if(!newRole)
				continue

			if(!newRole.AssignToRole(M))
				newRole.Drop()
				continue
			newRole.OnPostSetup()
			newRole.ForgeObjectives()
			newRole.Greet(GREET_LATEJOIN)
			message_admins("[key_name(H)] has been made into a [newRole.name] via create antagonist verb.")
			recruit_count++

	return recruit_count


/datum/admins/proc/get_candidates(var/role, var/source, var/role_name)
	var/list/candidates = list()
	switch(source)
		if(FROM_GHOSTS)
			for(var/mob/dead/observer/G in get_active_candidates(role, poll="Do you wish to be considered for [role_name]?"))
				candidates.Add(G)
		if(FROM_PLAYERS)
			for(var/mob/living/carbon/human/H in player_list)
				if(!H.client || !H.mind)
					continue
				candidates.Add(H)
	for(var/mob/M in candidates)
		if(isantagbanned(M))
			candidates.Remove(M)
		if(!M.client.desires_role(role) || jobban_isbanned(M, role))
			candidates.Remove(M)
	message_admins("[candidates.len] potential candidates.")
	return candidates


/datum/admins/proc/makeAliens()
	return alien_infestation(3)


/datum/admins/proc/makeDeathsquad()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/input = "Purify the station."
	if(prob(10))
		input = "Save Runtime and any other cute things on the station."

	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_STRIKE, poll="Do you wish to be considered for an elite syndicate strike team being sent in?"))
		if(!jobban_isbanned(G, "operative") && !isantagbanned(G))
			candidates += G

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len)
		var/numagents = 6
		//Spawns commandos and equips them.
		for (var/obj/effect/landmark/L in /area/syndicate_mothership/elite_squad)
			if(numagents<=0)
				break
			if (L.name == "Syndicate-Commando")
				syndicate_leader_selected = numagents == 1?1:0

				var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, syndicate_leader_selected)


				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					qdel(new_syndicate_commando)
					break

				new_syndicate_commando.key = theghost.key
				new_syndicate_commando.internal = new_syndicate_commando.s_store
				new_syndicate_commando.internals.icon_state = "internal1"

				//So they don't forget their code or mission.


				to_chat(new_syndicate_commando, "<span class='notice'>You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: <span class='danger'> [input]</span></span>")

				numagents--
		if(numagents >= 6)
			return 0

		for (var/obj/effect/landmark/L in /area/shuttle/syndicate_elite)
			if (L.name == "Syndicate-Commando-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)

	return 1


/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	new_character.gender = pick(MALE,FEMALE)

	new_character.randomise_appearance_for(new_character.gender)
	new_character.generate_name()
	new_character.age = rand(17,45)

	new_character.dna.ready_dna(new_character)
	new_character.key = G_found.key

	return new_character

/datum/admins/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	new_syndicate_commando.gender = pick(MALE, FEMALE)

	new_syndicate_commando.randomise_appearance_for(new_syndicate_commando.gender)

	new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
	new_syndicate_commando.name = new_syndicate_commando.real_name
	new_syndicate_commando.age = !syndicate_leader_selected ? rand(23,35) : rand(35,45)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = "Syndicate Commando"

	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)

	return new_syndicate_commando

/datum/admins/proc/makeVoxRaiders()



/datum/admins/proc/create_vox_raider(obj/spawn_location, leader_chosen = 0)
	var/mob/living/carbon/human/new_vox = new(spawn_location.loc)

	new_vox.setGender(pick(MALE, FEMALE))
	new_vox.my_appearance.h_style = "Short Vox Quills"
	new_vox.regenerate_icons()

	new_vox.age = rand(12,20)

	new_vox.dna.ready_dna(new_vox) // Creates DNA.
	new_vox.dna.mutantrace = "vox"
	new_vox.set_species("Vox") // Actually makes the vox! How about that.
	new_vox.generate_name()
	//new_vox.add_language(LANGUAGE_VOX)
	new_vox.mind_initialize()
	new_vox.mind.assigned_role = "MODE"
	new_vox.mind.special_role = "Vox Raider"
	new_vox.mutations |= M_NOCLONE //Stops the station crew from messing around with their DNA.

	new_vox.equip_vox_raider()

	return new_vox
