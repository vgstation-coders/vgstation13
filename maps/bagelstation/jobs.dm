//Allows barber on bagel only. Code magic is fun. Dont tick else you fuck shit up.

/datum/job/barber/New()
	..()
	total_positions = 1
	spawn_positions = 1

/datum/job/warden/New()
	..()
	total_positions = 2
	spawn_positions = 1