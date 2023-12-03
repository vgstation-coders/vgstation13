/datum/job/assistant
	title = "Assistant"
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

	var/datum/job/officer = job_master.GetJob("Security Officer")
	var/datum/job/warden = job_master.GetJob("Warden")
	var/datum/job/hos = job_master.GetJob("Head of Security")
	var/datum/job/detective = job_master.GetJob("Detective")
// No security roles can be selected, no limit.
	if(isnull(officer) && isnull(warden) && isnull(hos) && isnull(detective))
		return 99
// Additional check to prevent runtimes in case there's zero Security jobs in the round
	var/officer_jobs = officer ? officer.current_positions : 0
	var/warden_jobs = warden ? warden.current_positions : 0
	var/hos_jobs = hos ? hos.current_positions : 0
	var/detective_jobs = detective ? detective.current_positions : 0

	var/sec_jobs = (officer_jobs + warden_jobs + hos_jobs + detective_jobs)

	if(sec_jobs > 5)
		return 99

	return clamp(sec_jobs * config.assistantratio + xtra_positions + FREE_ASSISTANTS, total_positions, 99)
