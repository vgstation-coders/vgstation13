/datum/clockcult_power/mania_motor
	name				= "Mania Motor"
	desc				= "Constructs a mind-damaging machine that causes brain damage and insanity in anyone not loyal to Ratvar. Prolonged exposure will eventually lead to mental vegetation. Can be moved around, but must be bolted down and powered by an APC"
	category			= CLOCK_APPLICATIONS

	invocation			= "TODO"
	participants_min	= 2
	participants_max	= 2
	cast_time			= 6 SECONDS
	req_components		= list(CLOCK_BELLIGERENT = 1, CLOCK_REPLICANT = 1, CLOCK_GEIS = 3)
