//Planet atmospheres are defined here.


/datum/procgen/atmosphere
	var/composition //gas_mix
	var/list/valid_precip = list()//can it rain
	var/precipitation
	var/list/valid_temps = list(PG_FROZEN,PG_COLD,PG_BRISK,PG_TEMPERATE,PG_WARM,PG_HOT,PG_LAVA)
	var/temperature
	var/datum/gas_mixture/mix

/datum/procgen/atmosphere/proc/initialize_atmosphere()
	precipitation = pick(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	temperature = pick(valid_temps)
	//setup air mix

/datum/procgen/atmosphere/vacuum
	name = "Vacuum"
	desc = "No air present."

/datum/procgen/atmosphere/vacuum/initialize_atmosphere()
	..()
	precipitation = PG_NO_PRECIP
	mix = null

/datum/procgen/atmosphere/thin
	name = "Thin Atmosphere"
	desc = "Air is present, but it is too thin for humans to breathe. Some plants may grow here."

/datum/procgen/atmosphere/thin/initialize_atmosphere()
	..()
	precipitation = PG_NO_PRECIP

/datum/procgen/atmosphere/breathable
	name = "Breathable Atmosphere"
	desc = "Oxygen is present in levels high enough for humans to breathe here."

/datum/procgen/atmosphere/toxic
	name = "Toxic Atmosphere"
	desc = "Humans cannot breathe here, but other races may be able to."
