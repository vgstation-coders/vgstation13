/datum/component/ai/atmos_checker
	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5 / CELL_VOLUME
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1 / CELL_VOLUME
	var/min_co2 = 0
	var/max_co2 = 5 / CELL_VOLUME
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above

	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	var/fire_alert = 0
	var/oxygen_alert = 0
	var/toxins_alert = 0

	var/min_overheat_temp=40

/datum/component/ai/atmos_checker/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if("life")
			OnLife()
		else
			..(message_type, args)

/datum/component/ai/atmos_checker/proc/OnLife()
	if(!isliving(container.holder))
		return 1
	if(container.holder & INVULNERABLE)
		return 1

	var/atmos_suitable = 1

	var/atom/A = container.holder.loc

	if(isturf(A))
		var/turf/T = A
		var/datum/gas_mixture/Environment = T.return_air()

		if(Environment)
			if(abs(Environment.temperature - controller.getBodyTemperature()) > min_overheat_temp)
				SendSignal(COMSIG_ADJUST_BODYTEMP, list("temp"=((Environment.temperature - controller.getBodyTemperature()) / 5)))

			if(min_oxy)
				if(Environment.molar_density(GAS_OXYGEN) < min_oxy)
					atmos_suitable = 0
					oxygen_alert = 1
				else
					oxygen_alert = 0

			if(max_oxy)
				if(Environment.molar_density(GAS_OXYGEN) > max_oxy)
					atmos_suitable = 0

			if(min_tox)
				if(Environment.molar_density(GAS_PLASMA) < min_tox)
					atmos_suitable = 0

			if(max_tox)
				if(Environment.molar_density(GAS_PLASMA) > max_tox)
					atmos_suitable = 0
					toxins_alert = 1
				else
					toxins_alert = 0

			if(min_n2)
				if(Environment.molar_density(GAS_NITROGEN) < min_n2)
					atmos_suitable = 0

			if(max_n2)
				if(Environment.molar_density(GAS_NITROGEN) > max_n2)
					atmos_suitable = 0

			if(min_co2)
				if(Environment.molar_density(GAS_CARBON) < min_co2)
					atmos_suitable = 0

			if(max_co2)
				if(Environment.molar_density(GAS_CARBON) > max_co2)
					atmos_suitable = 0

	//Atmos effect
	if(controller.getBodyTemperature() < minbodytemp)
		fire_alert = 2
		SendSignal(COMSIG_ADJUST_BRUTE, list("amount"=cold_damage_per_tick))
	else if(controller.getBodyTemperature() > maxbodytemp)
		fire_alert = 1
		SendSignal(COMSIG_ADJUST_BRUTE, list("amount"=heat_damage_per_tick))
	else
		fire_alert = 0

	if(!atmos_suitable)
		SendSignal(COMSIG_ADJUST_BRUTE, list("amount"=unsuitable_damage))
