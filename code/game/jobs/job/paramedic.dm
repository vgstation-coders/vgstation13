/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/medical

/datum/job/paramedic/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/med(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
	H.equip_or_collect(new /obj/item/clothing/under/rank/medical/paramedic(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	//H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/mask/cigarette(H), slot_wear_mask)
	H.equip_or_collect(new /obj/item/clothing/head/soft/paramedic(H), slot_head)
	H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
	H.equip_or_collect(new /obj/item/clothing/glasses/hud/health(H), slot_glasses)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector(H), slot_l_store)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new /obj/item/weapon/storage/box/survival/engineer(H))
		H.put_in_hand(GRASP_LEFT_HAND, new /obj/item/device/healthanalyzer(H))
	else
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival/engineer(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/device/healthanalyzer(H.back), slot_in_backpack)
	H.mind.store_memory("Frequencies list: <br/><b>Medical:</b> [MED_FREQ] <br/>")
	return 1

/datum/job/paramedic/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/storage/belt/medical(H.back), slot_in_backpack)
