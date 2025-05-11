/datum/job/ai
	title = "AI"
	info_flag = JINFO_SILICON
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = 2
	minimal_player_age = 30
	species_blacklist = list() //for shrooms

/datum/job/ai/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	return 1

/datum/job/ai/is_disabled()
	return !config.allow_ai

/datum/job/cyborg
	title = "Cyborg"
	info_flag = JINFO_SILICON
	faction = "Station"
	total_positions = 0
	spawn_positions = 2
	supervisors = "your laws and the AI"
	selection_color = "#ddffdd"
	minimal_player_age = 10
	species_blacklist = list() //for shrooms

/datum/job/cyborg/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	return 1

/datum/job/mommi
	title = "Mobile MMI"
	info_flag = JINFO_SILICON
	faction = "Station"
	total_positions = 0
	spawn_positions = 2
	supervisors = "your laws and the AI"
	selection_color = "#ddffdd"
	species_blacklist = list() //for shrooms

/datum/job/mommi/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	return 1
