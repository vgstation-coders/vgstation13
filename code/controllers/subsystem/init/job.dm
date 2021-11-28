var/datum/subsystem/job/SSjob

/datum/subsystem/job
	name       = "Job"
	init_order = SS_INIT_JOB
	flags      = SS_NO_FIRE


/datum/subsystem/job/New()
	NEW_SS_GLOBAL(SSjob)


/datum/subsystem/job/Initialize(timeofday)
	job_master = new /datum/controller/occupations()
	job_master.SetupOccupations()
	job_master.LoadJobs("config/jobs.txt")
	for (var/mob/new_player/player in player_list)
		player.new_player_panel_proc() // adds the Manifest Prediction button to players who were already connected
	if(!syndicate_code_phrase)
		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()
	..()
