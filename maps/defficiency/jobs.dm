//Two janitors on Deff. Don't tick this file in Dreammaker or there will be two jobs on all maps.  It just works.

/datum/job/janitor/New()
	..()
	total_positions = 2
	spawn_positions = 2

//Limit geneticist slots to one because only one geneticist spawn is available on Deff.
/datum/job/geneticist/New()
	..()
	total_positions = 1
	spawn_positions = 1