/datum/job/ai
	title = "AI"
	flag = AI
	info_flag = JINFO_SILICON
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = 2
	minimal_player_age = 30
	alt_titles = list("Computer")

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		return 1

/datum/job/ai/is_disabled()
	return !config.allow_ai

/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	info_flag = JINFO_SILICON
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 2
	supervisors = "your laws and the AI"
	selection_color = "#ddffdd"
	no_id = 1
	minimal_player_age = 10

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		return 1

/datum/job/mommi
	title = "Mobile MMI"
	flag = MOMMI
	info_flag = JINFO_SILICON
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 2
	supervisors = "your laws and the AI"
	selection_color = "#ddffdd"
	no_id = 1

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		return 1
