/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	idtype = /obj/item/weapon/card/id/rd
	req_admin_notify = 1
	access = list(access_rd, access_heads, access_rnd, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_science, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_mechanic)
	minimal_access = list(access_rd, access_heads, access_rnd, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_science, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_mechanic)
	minimal_player_age = 20

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/heads/rd

/datum/job/rd/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/tox(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/heads/rd(H), slot_ears)
	H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/under/rank/research_director(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/rd(H), slot_wear_suit)
	H.put_in_hands(new /obj/item/weapon/storage/bag/clipboard(H))
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	equip_accessory(H, pick(ties), /obj/item/clothing/under)
	H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Science:</b> [SCI_FREQ]<br/>")
	return 1

/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_robotics, access_rnd, access_tox_storage, access_science, access_xenobiology)
	minimal_access = list(access_rnd, access_tox_storage, access_science, access_xenobiology)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Plasma Researcher", "Xenobiologist", "Research Botanist")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/toxins

/datum/job/scientist/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	if(H.mind.role_alt_title == "Research Botanist")
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_servsci(H), slot_ears)
	else
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_sci(H), slot_ears)
	switch(H.mind.role_alt_title)
		if("Scientist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		if("Plasma Researcher")
			H.equip_or_collect(new /obj/item/clothing/under/rank/plasmares(H), slot_w_uniform)
		if("Xenobiologist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/xenobio(H), slot_w_uniform)
		if("Anomalist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/anomalist(H), slot_w_uniform)
		if("Xenoarcheologist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/xenoarch(H), slot_w_uniform)
		if("Research Botanist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
			H.equip_or_collect(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/tox(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/science(H), slot_wear_suit)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	equip_accessory(H, pick(ties), /obj/item/clothing/under)
	H.mind.store_memory("Frequencies list: <br/><b>Science:</b> [SCI_FREQ]<br/>")
	return 1

/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_robotics, access_tech_storage, access_morgue, access_science, access_rnd) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_science) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/roboticist

/datum/job/roboticist/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/tox(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_sci(H), slot_ears)
	switch(H.mind.role_alt_title)
		if("Roboticist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
		if("Mechatronic Engineer")
			H.equip_or_collect(new /obj/item/clothing/under/rank/mechatronic(H), slot_w_uniform)
		if("Biomechanical Engineer")
			H.equip_or_collect(new /obj/item/clothing/under/rank/biomechanical(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
//	H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.put_in_hands(new /obj/item/weapon/storage/toolbox/mechanical(H))
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	equip_accessory(H, pick(ties), /obj/item/clothing/under)
	H.mind.store_memory("Frequencies list: <br/><b>Science:</b> [SCI_FREQ]<br/>")
	return 1

/datum/job/roboticist/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/device/flash/synthetic(H.back), slot_in_backpack)
