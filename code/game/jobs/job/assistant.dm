/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = -1
	supervisors = "absolutely everyone"
	wage_payout = 10
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Technical Assistant","Medical Intern","Research Assistant","Security Cadet")

	no_random_roll = 1 //Don't become assistant randomly

	outfit_datum = /datum/outfit/assistant

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/job/assistant/get_total_positions()
	if(!config.assistantlimit)
		return 99

	var/count = job_master.getCommandPlusSecCount()

	if(count > 5)
		return 99

	return clamp(count * config.assistantratio + xtra_positions, total_positions, 99)
