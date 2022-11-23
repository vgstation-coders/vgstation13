#define WATT_TO_KPA_COEFFICIENT 10

/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"
	power_channel=ENVIRON

	starting_materials = null
	w_type = NOT_RECYCLABLE
	var/rate							//moles generated last tick. used when examining
	var/moles_outputted					//moles outputted last tick. used when examining
	var/base_gas_production = 4500		//base KPa per tick - without external power
	var/max_external_pressure = 10000	//max KPa output - without external power
	var/output_temperature = T20C		
	var/on = TRUE
	
	var/datum/power_connection/consumer/power_connection
	var/power_load = 1000				//draw external power from a wire node
	var/power_load_last_tick = 0
	
	var/list/gases = list()				//which gases the miner generates
	var/datum/gas_mixture/air_contents	//which gases the miner generates, and how fast (in KPa per tick)
	var/datum/gas_mixture/pumping 		//used in transfering air around

	var/overlay_color = "#FFFFFF"

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/miner/New()
	..()	
	pumping = new
	air_contents = new
	power_connection = new(src)
	
	power_connection.monitoring_enabled = TRUE
	power_connection.power_priority = POWER_PRIORITY_EXCESS
	power_connection.idle_usage = idle_power_usage
	power_connection.active_usage = power_load
	air_contents.volume = 1000
	pumping.volume = 1000 //Same as above so copying works correctly
	set_rate(base_gas_production)
	update_icon()

/obj/machinery/atmospherics/miner/Destroy()
	if(pumping)
		qdel(pumping)
		pumping = null
	if(air_contents)
		qdel(air_contents)
		air_contents = null
	if(power_connection)
		qdel(power_connection)
		power_connection = null
	..()

/obj/machinery/atmospherics/miner/verb/set_power_consumption()
	set category = "Object"
	set name = "Set power consumption"
	set src in oview(1)
	power_load = input("moar power", "Set power consumption", power_load) as num
	//todo prevent ghosts from messing with this
	//todo sanitize negative inputs

//update gas creation speed into air_contents
/obj/machinery/atmospherics/miner/proc/set_rate(var/internal_pressure)
	air_contents.remove(air_contents.total_moles)//set to 0
	//rate is in mols
	rate = internal_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * output_temperature)

	for(var/current_gas in gases)
		air_contents.adjust_gas(current_gas, gases[current_gas] * rate)
	
	air_contents.temperature = output_temperature
	air_contents.update_values()

//actually create the gas and pump it into the air
//if running on extra power, no pressure maximum
//otherwise, max out at max_external_pressure
/obj/machinery/atmospherics/miner/proc/tranfer_gas()
	pumping.copy_from(air_contents)
	if(power_connection.get_satisfaction())
		moles_outputted = pumping.total_moles
		var/datum/gas_mixture/removed = pumping.remove(moles_outputted)
		loc.assume_air(removed)
		
	else
		var/datum/gas_mixture/environment = loc.return_air()
		var/environment_pressure = environment.return_pressure()
		var/pressure_delta = max(0, (max_external_pressure - environment_pressure))
		if(pressure_delta > 0.1)
			moles_outputted = pressure_delta * CELL_VOLUME / (output_temperature * R_IDEAL_GAS_EQUATION)
			moles_outputted = min(moles_outputted, pumping.total_moles)
			var/datum/gas_mixture/removed = pumping.remove(moles_outputted)
			loc.assume_air(removed)
		else 
			moles_outputted = 0

/obj/machinery/atmospherics/miner/proc/draw_power()
	if(power_connection.build_status)				//build_status means the connection needs rebuilding
		if(power_connection.connect() == FALSE)		//try to re-connect to the powernet
			return 0								//there's no wire to connect to
	var/power_actually_consumed = power_connection.get_satisfaction() * power_load_last_tick
	power_connection.add_load(power_load)
	power_load_last_tick = power_load
	return power_actually_consumed

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(stat & NOPOWER)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Lack of power.</span>")
		return
	if(power_connection.connected)
		var/power_actually_consumed = power_connection.get_satisfaction() * power_load_last_tick
		to_chat(user, "<span class='info'>Connected to external power and drawing [power_actually_consumed] of the requested [power_load]W.</span>")	
	if (!on || (stat & FORCEDISABLE))
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Turned off.</span>")
		return
	if(stat & BROKEN)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Broken.</span>")
		return
	to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Functional and outputting [moles_outputted] out of [rate] moles per cycle.</span>")

/obj/machinery/atmospherics/miner/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(on)
		on = 0
		update_icon()
	if(anchored)
		power_connection.connect()
	else
		power_connection.disconnect()
	power_load_last_tick = 0

// Critical equipment.
/obj/machinery/atmospherics/miner/ex_act(severity)
	return

// Critical equipment.
/obj/machinery/atmospherics/miner/blob_act()
	return

/obj/machinery/atmospherics/miner/power_change()
	..()
	set_rate(base_gas_production)
	power_load_last_tick = 0
	update_icon()


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
		return

	var/oldstat=stat
	if(!istype(loc,/turf/simulated))
		stat |= BROKEN
	else
		stat &= ~BROKEN
	if(stat!=oldstat)
		update_icon()
	if(stat & BROKEN)
		return

	if(power_connection.get_satisfaction())
		var/extra_mined_gas = draw_power() * WATT_TO_KPA_COEFFICIENT //in KPa per tick
		set_rate(base_gas_production + extra_mined_gas)	
	tranfer_gas()


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
	
/obj/machinery/atmospherics/miner/mixed_nitrogen
	name = "\improper Mixed Gas Miner"
	desc = "Pumping nitrogen, carbon dioxide, and plasma."
	overlay_color = "#FF80BD"
	gases = list(GAS_CARBON = 0.3, GAS_NITROGEN = 0.4, GAS_PLASMA = 0.3)

/obj/machinery/atmospherics/miner/mixed_oxygen
	name = "\improper Mixed Gas Miner"
	desc = "Pumping oxygen and nitrous oxide."
	overlay_color = "#7EA7E0"
	gases = list(GAS_OXYGEN = 0.5, GAS_SLEEPING = 0.5)
