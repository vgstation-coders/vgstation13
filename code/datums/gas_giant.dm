var/global/datum/gas_giant/gas_giant

/datum/gas_giant
	var/datum/gas_mixture/GM

/datum/gas_giant/New()
	GM = new
	GM.temperature = rand(T0C-224, T0C+95)
	GM.adjust_multi(
		GAS_OXYGEN, rand(10, 50)*3000/(R_IDEAL_GAS_EQUATION * GM.temperature),
		GAS_NITROGEN, rand(10, 50)*3000/(R_IDEAL_GAS_EQUATION * GM.temperature),
		GAS_PLASMA, rand(5, 25)*3000/(R_IDEAL_GAS_EQUATION * GM.temperature))