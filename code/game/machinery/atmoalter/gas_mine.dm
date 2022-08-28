/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"
	power_channel=ENVIRON

	starting_materials = null
	w_type = NOT_RECYCLABLE
	var/datum/powernet/PN
	var/power_priority = POWER_PRIORITY_EXCESS
	var/power_load = 0
	var/on=1

	var/datum/gas_mixture/air_contents
	var/datum/gas_mixture/pumping //used in transfering air around
	//var/max_external_pressure=10000 // 10,000kPa ought to do it.
	var/list/gases = list()

	var/overlay_color = "#FFFFFF"

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/miner/New()
	..()
	pumping = new
	air_contents = new
	air_contents.volume = 1000
	pumping.volume = 1000 //Same as above so copying works correctly
	air_contents.temperature = T20C
	update_powernet()
	update_icon()

/obj/machinery/atmospherics/miner/proc/update_rate(var/internal_pressure)
	//rate is in mols
	var/rate = internal_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	//this is ugly
	if(length(gases) == 1)
		air_contents.adjust_multi(gases[1], rate)
	else if(length(gases) == 2)
		air_contents.adjust_multi(gases[1], gases[gases[1]]*rate, gases[2], gases[gases[2]]*rate)
	else if(length(gases) == 3)
		air_contents.adjust_multi(gases[1], gases[gases[1]]*rate, gases[2], gases[gases[2]]*rate, gases[3], gases[gases[3]]*rate)
	air_contents.update_values()

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(stat & NOPOWER)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Lack of power.</span>")
		return
	if (!on || (stat & FORCEDISABLE))
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Turned off.</span>")
		return
	if(stat & BROKEN)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Broken.</span>")
		return
	to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Functional and operating.</span>")

/obj/machinery/atmospherics/miner/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(on)
		on = 0
		power_load = 0
		update_icon()

// Critical equipment.
/obj/machinery/atmospherics/miner/ex_act(severity)
	return

// Critical equipment.
/obj/machinery/atmospherics/miner/blob_act()
	return

/obj/machinery/atmospherics/miner/power_change()
	..()
	power_load = 0
	update_rate(0)
	update_powernet()
	update_icon()

/obj/machinery/atmospherics/miner/proc/update_powernet()
	var/area/A = get_area(src)
	var/obj/machinery/power/apc/area_apc
	if(!A)
		return
	area_apc = A.areaapc
	if(!area_apc)
		return

	PN = area_apc.terminal.powernet

/obj/machinery/atmospherics/miner/attack_ghost(var/mob/user)
	return

/obj/machinery/atmospherics/miner/attack_hand(var/mob/user)
	..()
	if(!Adjacent(user))
		to_chat(user, "<span class='warning'>You can't toggle \the [src] from that far away.</span>")
	else if(anchored)
		on=!on
		power_change()
		to_chat(user, "<span class='warning'>You toggle \the [src] [on ? "on" : "off"].</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] needs to be bolted to the ground first.</span>")

/obj/machinery/atmospherics/miner/update_icon()
	overlays = 0
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(on)
		var/new_icon_state="on"
		var/new_color = overlay_color
		if(stat & BROKEN)
			new_icon_state="broken"
			new_color="#FF0000"
		var/image/I = image(icon, icon_state=new_icon_state, dir=src.dir)
		I.color=new_color
		overlays += I

/obj/machinery/atmospherics/miner/process()
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(!on)
		use_power = MACHINE_POWER_USE_IDLE
		return
	use_power = MACHINE_POWER_USE_ACTIVE
	var/power_surplus = PN.get_satisfaction(power_priority)

	var/oldstat=stat
	if(!istype(loc,/turf/simulated))
		stat |= BROKEN
	else
		stat &= ~BROKEN
	if(stat!=oldstat)
		update_icon()
	if(stat & BROKEN)
		return

	if(power_surplus > 0.55)
		power_load += 1000
	else if (power_surplus < 0.45 && power_load > 0)
		power_load -= 1000
	else
		power_load = 0

	active_power_usage = power_load
	update_rate(Ceiling(0.1 * power_load))		//scale mol output by arbitrary 10% power load

	//gas-related
	//var/datum/gas_mixture/environment = loc.return_air()
	//var/environment_pressure = environment.return_pressure()

	pumping.copy_from(air_contents)
/*
	var/pressure_delta = 10000
	// External pressure bound
	pressure_delta = min(pressure_delta, (max_external_pressure - environment_pressure))
	if(pressure_delta > 0.1)
		var/transfer_moles = pressure_delta * CELL_VOLUME / (pumping.temperature * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed = pumping.remove(transfer_moles)
		loc.assume_air(removed)*/

/obj/machinery/atmospherics/miner/sleeping_agent
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"
	gases = list(GAS_SLEEPING = 1)

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"
	gases = list(GAS_NITROGEN = 1)

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"
	gases = list(GAS_OXYGEN = 1)

/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"
	gases = list(GAS_PLASMA = 1)

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"
	gases = list(GAS_CARBON = 1)

/obj/machinery/atmospherics/miner/air
	name = "\improper Air Miner"
	desc = "You fucking <em>cheater</em>."
	overlay_color = "#70DBDB"
	gases = list(GAS_OXYGEN = 0.2, GAS_NITROGEN = 0.8)
	on = 0