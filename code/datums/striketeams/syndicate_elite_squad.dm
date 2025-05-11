//ELITE SYNDICATE STRIKE TEAM

/datum/striketeam/syndicate
	striketeam_name = TEAM_ELITE_SYNDIE
	faction_name = "the Syndicate"
	mission = "Purify the station."
	team_size = 6
	min_size_for_leader = -1//set to 0 so there's always a designated team leader or to -1 so there is no leader.
	spawns_name = "Syndicate-Commando"
	can_customize = FALSE
	logo = "synd-logo"
	outfit_datum = /datum/outfit/striketeam/syndie_deathsquad


/datum/striketeam/syndicate/extras()
	var/v = 0
	for (var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Syndicate-Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			if(!v)
				new /obj/item/weapon/gun/gatling/beegun/ss_visceratorgun(L.loc)//i don't want to map in more guns
				v = 1

/datum/striketeam/syndicate/create_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	new_syndicate_commando.setGender(pick(MALE, FEMALE))

	new_syndicate_commando.randomise_appearance_for(new_syndicate_commando.gender)

	new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
	new_syndicate_commando.age = !syndicate_leader_selected ? rand(23,35) : rand(35,45)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = "Syndicate Commando"
	var/datum/faction/syndiesquad = find_active_faction_by_type(/datum/faction/strike_team/syndiesquad)
	var/datum/outfit/striketeam/concrete_outfit = new outfit_datum
	if(syndiesquad)
		syndiesquad.HandleRecruitedMind(new_syndicate_commando.mind)
	else
		syndiesquad = ticker.mode.CreateFaction(/datum/faction/strike_team/syndiesquad)
		syndiesquad.forgeObjectives(mission)
		if(syndiesquad)
			syndiesquad.HandleNewMind(new_syndicate_commando.mind) //First come, first served
	if (syndicate_leader_selected)
		concrete_outfit.is_leader = TRUE
	concrete_outfit.equip(new_syndicate_commando)
	return new_syndicate_commando

/datum/striketeam/syndicate/greet_commando(var/mob/living/carbon/human/H)
	H << 'sound/music/elite_syndie_squad.ogg'
	to_chat(H, "<span class='notice'>You are [H.real_name], an Elite commando, in the service of the Syndicate.</span>")
	for (var/role in H.mind.antag_roles)
		var/datum/role/R = H.mind.antag_roles[role]
		R.AnnounceObjectives()
