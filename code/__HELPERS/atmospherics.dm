// If human_standard is enabled, the message will be formatted to show which values are dangerous
/proc/scan_gases(var/atom/target, var/datum/gas_mixture/mixture, var/human_standard=TRUE)
	. = "<span class='notice'>[bicon(target)] Results of the analysis of \the [target]:</span><br>"
	
	// No, I am not sorry for this beautiful monstrosity.
	if ((!mixture && !(mixture = target.return_air())) || mixture.total_moles() <= 0)
		. += "<span class='warning'>\The [target] has no gases!</span>"
		return

	var/pressure = mixture.return_pressure()
	var/total_moles = mixture.total_moles()

	if (!human_standard || abs(pressure - ONE_ATMOSPHERE) < 10)
		. += "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span><br>"
	else
		. += "<span class='warning'>Pressure: [round(pressure,0.1)] kPa</span><br>"

	var/temp_safe = !human_standard || (mixture.temperature > BODYTEMP_COLD_DAMAGE_LIMIT && mixture.temperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
	. += "<span class='[temp_safe ? "notice" : "warning"]'>Temperature: [round(mixture.temperature-T0C)]&deg;C</span> <span class='notice'>([round(mixture.temperature)] K)</span><br>"
	. += "<span class='notice'>Heat Capacity: [round(environment.heat_capacity(),0.1)] J/K</span>"

	for (var/gasid in mixture.gas)
		var/datum/gas/gas = XGM.gas[gasid]
		var/moles = mixture.gas[gasid]
		var/safe = !human_standard || gas.is_human_safe(moles, mixture)
		. += "<br><span class='[safe ? "notice" : "warning"]'>[XGM.name[mix]]: [round((mixture.gas[mix] / total_moles) * 100)]% ([round(moles, 0.01)] mol)</span>"

