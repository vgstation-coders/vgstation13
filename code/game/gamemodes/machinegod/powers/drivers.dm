//Tier one clockcult powers.

/datum/clockcult_power/belligerent
	invocation			= "Chav’fu urn’gura y’vtug!"
	cast_time			= 0								//0 because it works kinda weird. read description on the design docs.
	loudness			= CLOCK_CHANTED
	req_components		= list(CLOCK_BELLIGERENT = 1)

/datum/clockcult_power/transgression
	invocation			= "F’pevor qvivar chav'fu sbez!"
	cast_time			= 50
	loudness			= CLOCK_WHISPERED
	req_components		= list(CLOCK_BELLIGERENT = 2)

/datum/clockcult_power/vanguard
	invocation			= "Qr’sraq zr fubeg!"
	cast_time			= 30
	req_components		= list(CLOCK_VANGUARD = 1)

/datum/clockcult_power/sentinels_comprimise
	invocation			= "Zraq zr vawhel."
	cast_time			= 30
	req_components		= list(CLOCK_VANGUARD = 2)

/datum/clockcult_power/replicant
	invocation			= "S’betr zr fyno."
	loudness			= CLOCK_WHISPERED
	cast_time			= 0
	req_components		= list(CLOCK_REPLICANT = 1)

/datum/clockcult_power/tinker_cache
	invocation			= "Ohv’yqva n qvfcra’fre!"
	cast_time			= 40
	req_components		= list(CLOCK_REPLICANT = 2)

/datum/clockcult_power/hierophant
	invocation			= "Tenag fyno r’nef."
	req_components		= list(CLOCK_HIEROPHANT = 1)
	cast_time			= 0
	loudness			= CLOCK_WHISPERED

/datum/clockcult_power/spectacles
	invocation			= "Tenag zr gehgu yraf."
	loudness			= CLOCK_WHISPERED
	cast_time			= 0
	req_components		= list(CLOCK_HIEROPHANT = 2)

/datum/clockcult_power/geis
	invocation			= "Rayvtugra urngura! Nyy gval orsber Ratvar! Chetr nyy hageh’guf naq ubabe Ratvar."
	cast_time			= 60
	loudness			= CLOCK_CHANTED
	req_components		= list(CLOCK_GEIS = 1)

