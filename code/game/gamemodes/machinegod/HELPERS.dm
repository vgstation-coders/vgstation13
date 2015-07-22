//Returns the type associated with the id.
/proc/get_clockcult_comp_by_id(var/id)
	switch(id)
		if(CLOCK_VANGUARD)
			return /obj/item/clock_component/vanguard
		if(CLOCK_BELLIGERENT)
			return /obj/item/clock_component/belligerent
		if(CLOCK_REPLICANT)
			return /obj/item/clock_component/replicant
		if(CLOCK_HIEROPHANT)
			return /obj/item/clock_component/hierophant
		if(CLOCK_GEIS)
			return /obj/item/clock_component/geis

	CRASH("/proc/get_clockcult_comp_by_id() received invalid argument: '[id]'")
