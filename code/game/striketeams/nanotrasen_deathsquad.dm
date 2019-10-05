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
	new_commando.equip_death_commando(leader_selected)

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

/mob/living/carbon/human/proc/equip_death_commando(leader = 0)
	//Special radio setup
	equip_to_slot_or_del(new /obj/item/device/radio/headset/deathsquad(src), slot_ears)

	//Adding Camera Network
	var/obj/machinery/camera/camera = new /obj/machinery/camera(src) //Gives all the commandos internals cameras.
	camera.network = list(CAMERANET_CREED)
	camera.c_tag = real_name

	//Basic Uniform
	if (leader)
		var/obj/item/clothing/under/rank/centcom_officer/uni = new /obj/item/clothing/under/rank/centcom_officer(src)
		uni.attach_accessory(new/obj/item/clothing/accessory/holomap_chip/deathsquad(src))
		equip_to_slot_or_del(uni, slot_w_uniform)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/deathsquad(src), slot_w_uniform)

	//Shoes & gloves
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/deathsquad(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), slot_gloves)

	//Glasses
	equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), slot_glasses)

	//Mask & Armor
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/deathsquad(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/deathsquad(src), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(src), slot_s_store)

	//Backpack
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/ammo_storage/speedloader/a357(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/pinpointer(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/shield/energy(src), slot_in_backpack)
	if (leader)
		equip_to_slot_or_del(new /obj/item/weapon/disk/nuclear(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_in_backpack)

	//Other equipment and accessories
	equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(src), slot_belt)
	equip_accessory(src, /obj/item/clothing/accessory/holster/handgun/preloaded/mateba, /obj/item/clothing/under, 5)
	equip_accessory(src, /obj/item/clothing/accessory/holster/knife/boot/preloaded/energysword, /obj/item/clothing/shoes, 5)


	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)//Here you go Deuryn
	L.imp_in = src
	L.implanted = 1
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive/nuclear(src)
	E.imp_in = src
	E.implanted = 1
	var/datum/organ/external/affected = get_organ(LIMB_HEAD)
	affected.implants += L
	L.part = affected
	affected.implants += E
	E.part = affected
	src.update_icons()



	var/obj/item/weapon/card/id/W = new(src)
	W.name = "[real_name]'s ID Card"
	if(leader)
		W.access = get_centcom_access("Creed Commander")
		W.icon_state = "creed"
		W.assignment = "Death Commander"
	else
		W.access = get_centcom_access("Death Commando")
		W.icon_state = "deathsquad"
		W.assignment = "Death Commando"
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
