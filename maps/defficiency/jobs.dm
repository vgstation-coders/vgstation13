//Two janitors on Deff. Don't tick this file in Dreammaker or there will be two jobs on all maps.  It just works.

/datum/job/janitor/New()
	..()
	total_positions = 2
	spawn_positions = 2