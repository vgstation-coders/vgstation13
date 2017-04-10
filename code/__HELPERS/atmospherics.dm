/proc/scan_gases(var/atom/target, var/datum/gas_mixture/mixture)
	. = "<span class='notice'>Results of the analysis of \the [target]:</span><br>"
	
	// No, I am not sorry for this beautiful monstrosity.
	if (!mixture && !(mixture = target.return_air()))
		. += "<span class='warning'>\The [target] has no gases!</span>"
		return

	var/pressure = mixture.return_pressure()
	var/total_moles = mixture.total_moles

	if (total_moles <= 0)
		

	if (total_moles>0)
		if(abs(pressure - ONE_ATMOSPHERE) < 10)
			. += "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>"
		else
			. += "<span class='warning'>Pressure: [round(pressure,0.1)] kPa</span>"
		for(var/mix in mixture.gas)
			. += "<span class='notice'>[XGM.name[mix]]: [round((mixture.gas[mix] / total_moles) * 100)]%</span>"
		. += "<span class='notice'>Temperature: [round(mixture.temperature-T0C)]&deg;C / [round(mixture.temperature)]K</span>"
		return
