//Planet atmospheres are defined here.


/datum/procgen/atmosphere
	var/composition //gas_mix

/datum/procgen/atmosphere/vacuum
	name = "Vacuum"
	desc = "No air present."

/datum/procgen/atmosphere/thin
	name = "Thin Atmosphere"
	desc = "Air is present, but it is too thin for humans to breathe. Some plants may grow here."

/datum/procgen/atmosphere/breathable
	name = "Breathable Atmosphere"
	desc = "Oxygen is present in levels high enough for humans to breathe here."

/datum/procgen/atmosphere/toxic
	name = "Toxic Atmosphere"
	desc = "Humans cannot breathe here, but other races may be able to."
