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

	outfit_datum = /datum/outfit/assistant

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

	return clamp(sec_jobs * config.assistantratio + xtra_positions, total_positions, 99)
