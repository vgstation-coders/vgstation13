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
	..()
