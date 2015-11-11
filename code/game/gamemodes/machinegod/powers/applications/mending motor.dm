/datum/clockcult_power/mending_motor
	name				= "Mending Motor"
	desc				= "Constructs a machine that restores damage to cult mobs and subverted borgs, and transforms things into their Ratvarian equivalents in the area it's in. Can be moved around, but must be bolted down and powered by an APC."
	category			= CLOCK_APPLICATIONS

	invocation			= "TODO"
	participants_min	= 2
	participants_max	= 2
	cast_time			= 6 SECONDS
	req_components		= list(CLOCK_VANGUARD = 1, CLOCK_REPLICANT = 3, CLOCK_GEIS = 1)
