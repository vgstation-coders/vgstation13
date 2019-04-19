var/global/datum/gas_giant/gas_giant
/**
	Gas giant datum
	Mostly for atmospherics
		Is composed of base elemental gases, such as oxygen, nitrogen, and plasma
**/
/datum/gas_giant
	var/datum/gas_mixture/comp = new //What atmosphere is the gas giant composed of

/datum/gas_giant/New()
	var/temperature = T0C+rand(-50,150)
	comp.adjust_multi_temp(
		GAS_OXYGEN, rand(1,25)*10000/(R_IDEAL_GAS_EQUATION*temperature),temperature,
		GAS_NITROGEN, rand(4, 25)*10000/(R_IDEAL_GAS_EQUATION*temperature),temperature,
		GAS_PLASMA, rand(2, 10)*10000/(R_IDEAL_GAS_EQUATION*temperature),temperature,
		)

/datum/gas_giant/proc/return_air()
	return comp