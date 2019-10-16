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

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/> <b>AI private:</b> [AIPRIV_FREQ]<br/>")
		return 1

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
		H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/><b>AI private:</b> [AIPRIV_FREQ]<br/>")
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
