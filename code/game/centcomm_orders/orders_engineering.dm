
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                         ENGINEERING ORDERS                                               //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//2 orders

/datum/centcomm_order/department/engineering
	acct_by_string = "Engineering"
	request_consoles_to_notify = list(
		"Chief Engineer's Desk",
		"Engineering",
		)

//----------------------------------------------Engineering----------------------------------------------------


/datum/centcomm_order/department/engineering/portable_smes/New()
	..()
	request_consoles_to_notify = list(
		"Chief Engineer's Desk",
		"Engineering",
		"Mechanics",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/machinery/power/battery/portable = 1
	)
	name_override = list(
		/obj/machinery/power/battery/portable = "Portable Power Storage Unit"
	)
	extra_requirements = "The battery must be filled to full capacity."
	worth = 800

/datum/centcomm_order/department/engineering/portable_smes/ExtraChecks(var/obj/machinery/power/battery/portable/P)
	if (!istype(P))
		return 0
	if (P.charge < P.capacity)
		return 0
	return 1

/datum/centcomm_order/department/engineering/portable_smes/BuildToExtraChecks(var/obj/machinery/power/battery/portable/P)
	if (istype(P))
		P.charge = P.capacity

//----------------------------------------------Atmospherics----------------------------------------------------


/datum/centcomm_order/department/engineering/cold_canister/New()
	..()
	request_consoles_to_notify = list(
		"Chief Engineer's Desk",
		"Atmospherics",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/machinery/portable_atmospherics/canister = 1
	)
	name_override = list(
		/obj/machinery/portable_atmospherics/canister = "Cold Plasma Canister"
	)
	extra_requirements = "Filled with over 1000 kPa of plasma below 2K."
	worth = 1300

/datum/centcomm_order/department/engineering/cold_canister/ExtraChecks(var/obj/machinery/portable_atmospherics/canister/C)
	if (!istype(C))
		return 0
	var/datum/gas_mixture/GM = C.return_air()
	if ((GM.gas?.len == 1) && (GAS_PLASMA in GM.gas) && (GM.return_temperature() < 2) && (GM.pressure > 1000))
		return 1
	return 0

/datum/centcomm_order/department/engineering/cold_canister/BuildToExtraChecks(var/obj/machinery/portable_atmospherics/canister/C)
	if (istype(C))
		// Just below 1K
		C.air_contents.adjust_gas_temp(GAS_PLASMA, (C.maximum_pressure * C.filled) * C.air_contents.volume / (R_IDEAL_GAS_EQUATION * 1.9), 1.9)
		C.update_icon()
