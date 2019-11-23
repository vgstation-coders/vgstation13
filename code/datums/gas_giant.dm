var/global/datum/gas_giant/gas_giant

/datum/gas_giant
	var/name
	var/datum/gas_mixture/GM

/datum/gas_giant/New()
	name = take_name(planet_names)
	GM = new
	GM.temperature = rand(T0C-224, T0C+95)
	GM.adjust_multi(
		GAS_OXYGEN, rand(10, 50)*1000/(R_IDEAL_GAS_EQUATION * GM.temperature),
		GAS_NITROGEN, rand(10, 50)*1000/(R_IDEAL_GAS_EQUATION * GM.temperature),
		GAS_PLASMA, rand(5, 25)*1000/(R_IDEAL_GAS_EQUATION * GM.temperature))