//DEATH SQUAD

/datum/striketeam/deathsquad
	striketeam_name = TEAM_DEATHSQUAD
	faction_name = "Nanotrasen"
	mission = "Clean up the Station of all enemies of Nanotrasen. Avoid damage to Nanotrasen assets, unless you judge it necessary."
	team_size = 6
	min_size_for_leader = 4//set to 0 so there's always a designated team leader or to -1 so there is no leader.
	spawns_name = "Commando"
	can_customize = FALSE
	logo = "death-logo"

	outfit_datum = /datum/outfit/striketeam/nt_deathsquad

/datum/striketeam/deathsquad/create_commando(obj/spawn_location, leader_selected = 0)
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	var/commando_leader_rank = pick("Major", "Rescue Leader", "Commander")
	var/commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/commando_name = pick(last_names)
	var/commando_leader_name = pick("Creed", "Dahl")

	new_commando.gender = pick(MALE, FEMALE)

	new_commando.randomise_appearance_for(new_commando.gender)

	new_commando.real_name = "[!leader_selected ? commando_rank : commando_leader_rank] [!leader_selected ? commando_name : commando_leader_name]"
	new_commando.age = !leader_selected ? rand(23,35) : rand(35,45)

	new_commando.dna.ready_dna(new_commando)//Creates DNA.

	//Creates mind stuff.
	new_commando.mind_initialize()
	new_commando.mind.assigned_role = "MODE"
	new_commando.mind.special_role = "Death Commando"
	var/datum/faction/deathsquad = find_active_faction_by_type(/datum/faction/strike_team/deathsquad)
	var/datum/outfit/striketeam/concrete_outfit = new outfit_datum
	if(deathsquad)
		deathsquad.HandleRecruitedMind(new_commando.mind)
	else
		deathsquad = ticker.mode.CreateFaction(/datum/faction/strike_team/deathsquad)
		deathsquad.forgeObjectives(mission)
		if(deathsquad)
			deathsquad.HandleNewMind(new_commando.mind) //First come, first served
	if (leader_selected)
		var/datum/role/death_commando/D = new_commando.mind.GetRole(DEATHSQUADIE)
		D.logo_state = "creed-logo"
	else
		leader_name = new_commando.real_name
		concrete_outfit.is_leader = TRUE
	concrete_outfit.equip(new_commando)

	new_commando.add_language(LANGUAGE_DEATHSQUAD)
	new_commando.default_language = all_languages[LANGUAGE_DEATHSQUAD]

	return new_commando

/datum/striketeam/deathsquad/greet_commando(var/mob/living/carbon/human/H)
	H << 'sound/music/deathsquad.ogg'
	if(H.key == leader_key)
		to_chat(H, "<span class='notice'>You are [H.real_name], a tactical genius and the leader of the Death Squad, in the service of Nanotrasen.</span>")
	else
		to_chat(H, "<span class='notice'>You are [H.real_name], a Death Squad commando, in the service of Nanotrasen.</span>")
		if (leader_key != "")
			to_chat(H, "<span class='notice'>Follow directions from your superior, [leader_name].</span>")
	//to_chat(H, "<span class='notice'>Your mission is: <span class='danger'>[mission]</span></span>")
	for (var/role in H.mind.antag_roles)
		var/datum/role/R = H.mind.antag_roles[role]
		R.AnnounceObjectives()
