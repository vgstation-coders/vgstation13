/datum/clockcult_power/sigil_of_transmission
	name				= "Sigil of Transmission"
	desc				= "After reciting, a number of faint golden sigils randomly appear on the ground on floor tiles in the area. The amount scales with the amount of cultists involved. Any noncultist who steps on one will be electrocuted. The power is taken directly from the APC, and will not work if the APC is drained or an APC is not present. Enemy cultists who tread on these sigils will be given considerably more of a shock than non-cultists."
	category			= CLOCK_APPLICATIONS

	invocation			= "TODO"
	cast_time			= 7 SECONDS
	participants_max	= INFINITY
	req_components		= list(CLOCK_BELLIGERENT = 1, CLOCK_VANGUARD = 3, CLOCK_HIEROPHANT = 1)
