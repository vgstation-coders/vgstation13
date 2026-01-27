#define RAIDERS_RISK_MINIMUM 	1
#define RAIDERS_RISK_LOW			2
#define RAIDERS_RISK_MEDIUM		3
#define RAIDERS_RISK_HIGH		4
#define RAIDERS_RISK_MAXIMUM		5

#define RAIDERS_THREAT_MINIMUM	1
#define RAIDERS_THREAT_LOW		2
#define RAIDERS_THREAT_MEDIUM	3
#define RAIDERS_THREAT_HIGH		4
#define RAIDERS_THREAT_MAXIMUM	5



/datum/objective/raider
	name = "Bring profit to the Vox Shoal."

	// RISK refers to the risk to the raiders themselves.		(How likely are raiders to die?)
	// THREAT refers to the problems caused by this objective 	(How many problems will the raiders cause for the crew trying to complete this objective?)
	var/risk = RAIDERS_RISK_MEDIUM
	var/threat = RAIDERS_THREAT_MEDIUM

	// What crew jobs are required for this objective to be picked, and how many?
	var/list/required_jobs = list()
	var/required_job_count = 0

/datum/objective/raider/New()
	..()
	explanation_text = format_explanation()

/datum/objective/raider/format_explanation()
	return explanation_text

/datum/objective/raider/proc/CanBePicked()
	if(!CheckRequiredJobs())
		return FALSE
	if(!AdditionalRequirements())
		return FALSE
	return TRUE

/datum/objective/raider/proc/CheckRequiredJobs()
	if(!required_job_count || !required_jobs.len)
		return TRUE
	var/num_jobs
	for (var/mob/M in player_list)
		if (M.stat == DEAD)				// No dead guys.
			continue
		if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in required_jobs))
			num_jobs++
	if(num_jobs < required_job_count)
		log_debug("VOX RAIDERSS: [name] couldn't be picked as there weren't enough required jobs on station.")
		return FALSE
	return TRUE

// Override this with any additional checks that need to be run before assigning this objective.
/datum/objective/raider/proc/AdditionalRequirements()
	return TRUE
