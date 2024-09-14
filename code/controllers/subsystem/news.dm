var/datum/subsystem/news/SSnews

/datum/subsystem/news
	name     = "News"
	wait     = 1 MINUTES
	flags    = SS_NO_INIT | SS_KEEP_TIMING
	priority = SS_PRIORITY_EVENT

/datum/subsystem/news/Initialize(timeofday)
	setup_news()

/datum/subsystem/news/New()
	NEW_SS_GLOBAL(SSnews)

/datum/subsystem/news/fire(resumed = FALSE)
	checkNews()
