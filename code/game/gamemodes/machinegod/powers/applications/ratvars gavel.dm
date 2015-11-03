/datum/clockcult_power/ratvars_gavel
	name				= "Ratvar's Gavel"
	desc				= "Before chanting, a name must be inputted. Upon completion, the target will be smote with temporary brain damage and hallucination for 30 seconds. Enemy cultists will recieve 20-30 burn damage in addition to this."
	category			= CLOCK_APPLICATIONS

	invocation			= "Chav’fu urngura urnil!"
	loudness			= CLOCK_CHANTED
	participants_min	= 3
	participants_max	= 3
	cast_time			= 4 SECONDS
	req_components		= list(CLOCK_VANGUARD = 1, CLOCK_REPLICANT = 3, CLOCK_GEIS = 1)
