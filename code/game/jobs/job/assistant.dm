/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Technical Assistant","Medical Intern","Research Assistant","Security Cadet")

	no_random_roll = 1 //Don't become assistant randomly

/datum/job/assistant/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	switch(H.mind.role_alt_title)
		if("Assistant")
			H.equip_or_collect(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
		if("Technical Assistant")
			H.equip_or_collect(new /obj/item/clothing/under/color/yellow(H), slot_w_uniform)
		if("Medical Intern")
			H.equip_or_collect(new /obj/item/clothing/under/color/white(H), slot_w_uniform)
		if("Research Assistant")
			H.equip_or_collect(new /obj/item/clothing/under/purple(H), slot_w_uniform)
		if("Security Cadet")
			H.equip_or_collect(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	return 1

/datum/job/assistant/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.put_in_hands(new /obj/item/weapon/storage/toolbox/mechanical(get_turf(H)))

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/job/assistant/get_total_positions()
	if(!config.assistantlimit)
		return 99

	var/datum/job/officer = job_master.GetJob("Security Officer")
	var/datum/job/warden = job_master.GetJob("Warden")
	var/datum/job/hos = job_master.GetJob("Head of Security")
	var/sec_jobs = (officer.current_positions + warden.current_positions + hos.current_positions)

	if(sec_jobs > 5)
		return 99

	return Clamp(sec_jobs * config.assistantratio + xtra_positions, total_positions, 99)
