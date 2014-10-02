/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Technical Assistant","Medical Intern","Research Assistant","Security Cadet")

/datum/job/assistant/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	return 1

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/job/scavenger
	title = "Scavenger"
	flag = SCAVENGER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 5
	supervisors = "Factions"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels)
	minimal_access = list(access_maint_tunnels)

/datum/job/scavenger/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/color/black(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_or_collect(new /obj/item/clothing/mask/balaclava(H), slot_wear_mask) //YEAH
	if(H.backbag == 1)
		H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/u40ag(H), slot_l_hand)
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/u40ag(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/clothing/tie/storage/black_vest(H), slot_in_backpack)
	return 1

