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
		<a href='?src=\ref[src];makeAntag=11'>Make Vox Raiders (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=7'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=9'>Make Aliens (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=10'>Make Deathsquad (Syndicate) (Requires Ghosts)</a><br>
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

	if(AIs.len)
		malfAI = pick(AIs)

	if(malfAI)
		themind = malfAI.mind
		themind.make_AI_Malf()
		return 1

	return 0


/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.desires_role(ROLE_TRAITOR))
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "traitor") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								candidates += applicant

	if (candidates.len)
		candidates = shuffle(candidates)

		var/mob/living/carbon/human/candidate

		for (var/i = 1 to min(candidates.len, 3))
			candidate = pick_n_take(candidates)

			if (candidate)
				var/datum/mind/candidate_mind = candidate.mind

				if (candidate_mind)
					if (candidate_mind.make_traitor())
						log_admin("[key_name(owner)] has traitor'ed [key_name(candidate)] via create antagonist verb.")

		return 1

	return 0


/datum/admins/proc/makeChanglings()


	var/datum/game_mode/changeling/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.desires_role(ROLE_CHANGELING))
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "changeling") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								candidates += applicant

	if(candidates.len)
		var/numChanglings = min(candidates.len, 3)

		for(var/i = 0, i<numChanglings, i++)
			H = pick(candidates)
			H.mind.make_Changling()
			candidates.Remove(H)

		return 1

	return 0

/datum/admins/proc/makeRevs()


	var/datum/game_mode/revolution/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(!applicant.client) continue
		if(applicant.client.desires_role(ROLE_REV))
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "revolutionary") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								candidates += applicant

	if(candidates.len)
		var/numRevs = min(candidates.len, 3)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H.mind.make_Rev()
			candidates.Remove(H)
		return 1

	return 0

/datum/admins/proc/makeWizard()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null

	for(var/mob/dead/observer/G in get_active_candidates(ROLE_WIZARD,poll="Do you wish to be considered for the Space Wizard Federation \"Ambassador\"?"))
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			candidates += G

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Wizard()
		return 1

	return 0


/datum/admins/proc/makeCult()


	var/datum/game_mode/cult/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in get_active_candidates(ROLE_CULTIST))
		if(applicant.stat == CONSCIOUS)
			if(applicant.mind)
				if(!applicant.mind.special_role)
					if(!jobban_isbanned(applicant, "cultist") && !jobban_isbanned(applicant, "Syndicate"))
						if(!(applicant.job in temp.restricted_jobs))
							candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
			H.mind.make_Cultist()
			candidates.Remove(H)
			temp.grant_runeword(H)

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()


	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/list/mob/dead/observer/picked = list()

	for(var/mob/dead/observer/G in get_active_candidates(ROLE_OPERATIVE,poll="Do you wish to be considered for a nuke team being sent in?"))
		if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
			candidates += G

	if(candidates.len)
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = j
				candidates.Remove(theghost)
/* Seeing if we have enough agents before we make the nuke team
				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Nuke()
*/
				picked += theghost
				agentcount++
				break
//This is so we don't get a nuke team with only 1 or 2 people
		if(agentcount < 3)
			return 0
		else
			for(var/mob/j in picked)
				theghost = j
				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Nuke()

		var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
		var/obj/effect/landmark/closet_spawn = locate("landmark*Syndicate-Uplink")

		var/nuke_code = "[rand(10000, 99999)]"

		if(nuke_spawn)
			var/obj/item/weapon/paper/P = new
			P.info = "Sadly, the Syndicate could not get you a nuclear bomb.  We have, however, acquired the arming code for the station's onboard nuke.  The nuclear authorization code is: <b>[nuke_code]</b>"
			P.name = "nuclear bomb code and instructions"
			P.loc = nuke_spawn.loc

		if(closet_spawn)
			new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

		for (var/obj/effect/landmark/A in /area/syndicate_station/start)//Because that's the only place it can BE -Sieve
			if (A.name == "Syndicate-Gear-Closet")
				new /obj/structure/closet/syndicate/personal(A.loc)
				del(A)
				continue

			if (A.name == "Syndicate-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(A.loc)
				del(A)
				continue

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							//del(I)
							synd_mind.current.client.images -= I

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in ticker.mode.syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

		for (var/obj/machinery/nuclearbomb/bomb in machines)
			bomb.r_code = nuke_code						// All the nukes are set to this code.
	return 1





/datum/admins/proc/makeAliens()
	alien_infestation(3)
	return 1
/datum/admins/proc/makeDeathsquad()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/input = "Purify the station."
	if(prob(10))
		input = "Save Runtime and any other cute things on the station."

	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_COMMANDO, poll="Do you wish to be considered for an elite syndicate strike team being sent in?"))
		if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
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
					del(new_syndicate_commando)
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
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	new_character.gender = pick(MALE,FEMALE)

	var/datum/preferences/A = new()
	A.randomize_appearance_for(new_character)
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

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	A.randomize_appearance_for(new_syndicate_commando)

	new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
	new_syndicate_commando.name = new_syndicate_commando.real_name
	new_syndicate_commando.age = !syndicate_leader_selected ? rand(23,35) : rand(35,45)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = "Syndicate Commando"

	//Adds them to current traitor list. Which is really the extra antagonist list.
	ticker.mode.traitors += new_syndicate_commando.mind
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)

	return new_syndicate_commando

/datum/admins/proc/makeVoxRaiders()


	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/input = "Disregard shinies, acquire hardware."

	var/leader_chosen = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of candidates from active ghosts.
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_VOXRAIDER, poll="Do you wish to be considered for a vox raiding party arriving on the station?"))
		candidates += G

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len)
		var/max_raiders = 1
		var/raiders = max_raiders
		//Spawns vox raiders and equips them.
		for (var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "voxstart")
				if(raiders<=0)
					break

				var/mob/living/carbon/human/new_vox = create_vox_raider(L, leader_chosen)

				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					del(new_vox)
					break

				new_vox.key = theghost.key
				to_chat(new_vox, "<span class='notice'>You are a Vox Primalis, fresh out of the Shoal. Your ship has arrived at the Tau Ceti system hosting the NSV Exodus... or was it the Luna? NSS? Utopia? Nobody is really sure, but everyong is raring to start pillaging! Your current goal is: <span class='danger'> [input]</span></span>")
				to_chat(new_vox, "<span class='warning'>Don't forget to turn on your nitrogen internals!</span>")

				raiders--
			if(raiders > max_raiders)
				return 0
	else
		return 0
	return 1

/datum/admins/proc/create_vox_raider(obj/spawn_location, leader_chosen = 0)


	var/mob/living/carbon/human/new_vox = new(spawn_location.loc)

	new_vox.setGender(pick(MALE, FEMALE))
	new_vox.h_style = "Short Vox Quills"
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

	ticker.mode.traitors += new_vox.mind
	new_vox.equip_vox_raider()

	return new_vox