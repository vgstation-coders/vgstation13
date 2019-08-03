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


/datum/striketeam/syndicate/extras()
	for (var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Syndicate-Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)

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
	if(syndiesquad)
		syndiesquad.HandleRecruitedMind(new_syndicate_commando.mind)
	else
		syndiesquad = ticker.mode.CreateFaction(/datum/faction/strike_team/syndiesquad)
		syndiesquad.forgeObjectives(mission)
		if(syndiesquad)
			syndiesquad.HandleNewMind(new_syndicate_commando.mind) //First come, first served
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)
	return new_syndicate_commando

/datum/striketeam/syndicate/greet_commando(var/mob/living/carbon/human/H)
	H << 'sound/music/elite_syndie_squad.ogg'
	to_chat(H, "<span class='notice'>You are [H.real_name], an Elite commando, in the service of the Syndicate.</span>")
	for (var/role in H.mind.antag_roles)
		var/datum/role/R = H.mind.antag_roles[role]
		R.AnnounceObjectives()

/mob/living/carbon/human/proc/equip_syndicate_commando(leader = 0)
	//Special radio setup
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, slot_ears)

	//Basic Uniform
	var/obj/item/clothing/under/syndicate/uni = new /obj/item/clothing/under/syndicate(src)
	uni.attach_accessory(new/obj/item/clothing/accessory/holomap_chip/elite(src))
	equip_to_slot_or_del(uni, slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/weapon/grenade/empgrenade(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/silenced(src), slot_belt)

	//Shoes & gloves
	equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), slot_gloves)

	//Glasses)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), slot_glasses)

	//Mask & Armor
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/syndicate_elite(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/syndicate_elite(src), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)

	//Backpack
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/ammo_storage/box/c45(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/osipr_core(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/gun/osipr(src), slot_in_backpack)
	if (leader)
		equip_to_slot_or_del(new /obj/item/weapon/pinpointer(src), slot_in_backpack)
		equip_to_slot_or_del(new /obj/item/weapon/disk/nuclear(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_in_backpack)
		equip_to_slot_or_del(new /obj/item/energy_magazine/osipr(src), slot_in_backpack)

	var/obj/item/weapon/card/id/syndicate/W = new(src) //Untrackable by AI
	W.name = "[real_name]'s ID Card"
	W.icon_state = "syndie"
	W.access = get_all_accesses()//They get full station access because obviously the syndicate has HAAAX, and can make special IDs for their most elite members.
	W.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage, access_syndicate)//Let's add their forged CentCom access and syndicate access.
	W.assignment = "Syndicate Commando"
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive/nuclear(src) //no loyalty implant because you're already syndicate scum
	E.imp_in = src
	E.implanted = 1
	var/datum/organ/external/affected = get_organ(LIMB_HEAD)
	affected.implants += E
	E.part = affected
	src.update_icons()

	return 1
