//Planet atmospheres are defined here.


/datum/procedural_atmosphere
	var/composition //gas_mix
	var/list/valid_precip = list()//can it rain
	var/precipitation
	var/list/valid_temps = list(PG_FROZEN,PG_COLD,PG_BRISK,PG_TEMPERATE,PG_WARM,PG_HOT,PG_LAVA)
	var/temperature
	var/datum/gas_mixture/mix

/datum/procedural_atmosphere/proc/initialize_atmosphere()
	precipitation = pick(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	temperature = pick(valid_temps)
	//setup air mix

/datum/procedural_atmosphere/vacuum // No air

/datum/procedural_atmosphere/vacuum/initialize_atmosphere()
	..()
	precipitation = PG_NO_PRECIP
	mix = null

/datum/procedural_atmosphere/thin // Air is present, but it is too thin for humans to breathe. Some plants may grow here.

/datum/procedural_atmosphere/thin/initialize_atmosphere()
	..()
	precipitation = PG_NO_PRECIP

/datum/procedural_atmosphere/breathable // Oxygen is present in levels high enough for humans to breathe here.

/datum/procedural_atmosphere/toxic // Humans cannot breathe here, but other races may be able to.
