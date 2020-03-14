/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	wage_payout = 105
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 30

	species_whitelist = list("Human")

	pdaslot=slot_l_store
	pdatype=/obj/item/device/pda/captain

/datum/job/captain/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	H.equip_or_collect(new /obj/item/device/radio/headset/heads/captain(H), slot_ears)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/captain(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_cap(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/com(H), slot_back)
	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/clothing/under/rank/captain(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/head/caphat(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new /obj/item/weapon/storage/box/ids(H))
		H.put_in_hand(GRASP_LEFT_HAND, new /obj/item/weapon/gun/energy/gun(H))
	else
		H.equip_or_collect(new /obj/item/weapon/storage/box/ids(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/gun/energy/gun(H), slot_in_backpack)
	equip_accessory(H, /obj/item/clothing/accessory/medal/gold/captain, /obj/item/clothing/under)
	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	to_chat(world, "<b>[H.real_name] is the captain!</b>")
	var/datum/organ/external/affected = H.get_organ(LIMB_HEAD)
	affected.implants += L
	L.part = affected
	H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/>")
	return 1

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/reject_new_slots()
	if(security_level == SEC_LEVEL_RED)
		return FALSE
	else
		return "Red Alert"

/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	minimal_player_age = 20

	species_whitelist = list("Human")

	access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_science, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_science, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway)

	pdaslot=slot_l_store
	pdatype=/obj/item/device/pda/heads/hop

/datum/job/hop/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	H.equip_or_collect(new /obj/item/device/radio/headset/heads/hop(H), slot_ears)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/clothing/under/rank/head_of_personnel(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	//H.equip_or_collect(new /obj/item/device/pda/heads/hop(H), slot_belt)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new /obj/item/weapon/storage/box/ids(H))
	else
		H.equip_or_collect(new /obj/item/weapon/storage/box/ids(H.back), slot_in_backpack)
	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	var/datum/organ/external/affected = H.get_organ(LIMB_HEAD)
	affected.implants += L
	L.part = affected
	H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/>")
	return 1
