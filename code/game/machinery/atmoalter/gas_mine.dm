#define WATT_TO_KPA_COEFFICIENT 1					//4.5KW to double the default speed
#define WATT_TO_KPA_OF_EXTERNAL_PRESSURE_LIMIT 1	//10KW to double the default pressure limit

/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"
	power_channel=ENVIRON
	var/base_power_usage = 100			//their base powerdraw, can be increased
	idle_power_usage = 10				//draw when off, stays constant

	starting_materials = null
	w_type = NOT_RECYCLABLE
	var/rate							//moles generated last tick. used when examining
	var/moles_outputted					//moles outputted last tick. used when examining
	var/base_gas_production = 4500		//base KPa per tick - without external power
	var/max_external_pressure = 10000	//base KPa output - without external power
	var/output_temperature = T20C
	var/on = TRUE

/*	var/datum/power_connection/consumer/power_connection*/
//	var/power_load = 5000				//draw external power from a wire node
	var/power_load_last_tick = 0		//prevent cheeky way to make loadsa gas
	var/power_load_two_ticks_ago = 0

	var/list/gases = list()				//which gases the miner generates
	var/datum/gas_mixture/air_contents	//which gases the miner generates, and how fast (in KPa per tick)
	var/datum/gas_mixture/pumping 		//used in transfering air around

	var/overlay_color = "#FFFFFF"

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/miner/New()
	..()
	pumping = new
	air_contents = new
/*	power_connection = new(src)

	power_connection.monitoring_enabled = TRUE
	power_connection.power_priority = POWER_PRIORITY_EXCESS
	power_connection.use_power = MACHINE_POWER_USE_ACTIVE
	power_connection.active_usage = power_load*/
	air_contents.volume = 1000
	pumping.volume = 1000 //Same as above so copying works correctly

	power_change()
	update_icon()

/obj/machinery/atmospherics/miner/Destroy()
	if(pumping)
		QDEL_NULL(pumping)
	if(air_contents)
		QDEL_NULL(air_contents)
/*	if(power_connection)
		QDEL_NULL(power_connection)*/
	..()

/obj/machinery/atmospherics/miner/verb/set_power_consumption()
	set category = "Object"
	set name = "Set power consumption"
	set src in oview(1)
	if(!(isAdminGhost(usr) || ishuman(usr) || issilicon(usr)))
		to_chat(usr, "You are not capable of such fine manipulation.")
		return
	var/power = input("moar power", "Set power consumption", active_power_usage) as num
	if(power < 0)
		to_chat(usr, "You remember the tales of negative moles and pressures and reconsider.")
		return
/*	power_load = power
	power_connection.active_usage = power*/
	active_power_usage = power

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
//max out at max_external_pressure
//unless running on exernal power, which raises the pressure limit the more power you add
/obj/machinery/atmospherics/miner/proc/tranfer_gas()
	pumping.copy_from(air_contents)
	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()
	var/extra_power_pressure_bonus = 0
	extra_power_pressure_bonus = active_power_usage * WATT_TO_KPA_OF_EXTERNAL_PRESSURE_LIMIT
/*	if(power_connection.connected)	//raise max pressure if powered
		var/power_actually_consumed = power_connection.get_satisfaction() * power_load_last_tick
		extra_power_pressure_bonus = power_actually_consumed * WATT_TO_KPA_OF_EXTERNAL_PRESSURE_LIMIT*/

	var/pressure_delta = max(0, (max_external_pressure + extra_power_pressure_bonus - environment_pressure))
	if(pressure_delta > 0.1)
		moles_outputted = pressure_delta * CELL_VOLUME / (output_temperature * R_IDEAL_GAS_EQUATION)
		moles_outputted = min(moles_outputted, pumping.total_moles)
		var/datum/gas_mixture/removed = pumping.remove(moles_outputted)
		loc.assume_air(removed)
	else
		moles_outputted = 0

/*/obj/machinery/atmospherics/miner/proc/draw_power()
	if(power_connection.build_status)				//build_status means the connection needs rebuilding
		power_load_last_tick = 0
		if(power_connection.connect() == FALSE)		//try to re-connect to the powernet
			set_rate(base_gas_production)			//there's no wire to connect to
			power_connection.disconnect()
			return 0
	var/power_actually_consumed = power_connection.get_satisfaction() * power_load_last_tick
	power_connection.add_load(power_load)
	power_load_last_tick = power_load
	return power_actually_consumed*/

//this is not used because no other machines draw power like this
//the remote connect is also broken
/*/obj/machinery/atmospherics/miner/proc/connect_to_apc_cable()
	var/area/current_area = get_area(src)
	if(!current_area)
		return 0
	var/obj/machinery/power/apc = current_area.areaapc
	if(!apc)
		return 0
	var/obj/structure/cable/connected_cable = locate(/obj/structure/cable) in apc.loc
	if(!connected_cable)
		return 0
	return power_connection.connect(connected_cable)*/


/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(stat & NOPOWER)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Lack of power.</span>")
		return
/*	if(power_connection.connected)
		var/power_actually_consumed = power_connection.get_satisfaction() * power_load_last_tick
		to_chat(user, "<span class='info'>Connected to wire network and drawing [power_actually_consumed] of the requested [power_load]W.</span>")
	else
		to_chat(user, "<span class='info'>Not connected to external power.</span>")*/
	if (!on || (stat & FORCEDISABLE))
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Turned off.</span>")
		return
	if(stat & BROKEN)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Broken.</span>")
		return
	to_chat(user, "<span class='info'>Currently consuming [active_power_usage]W from the APC's environment channel.</span>")
	to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Functional and outputting [moles_outputted] out of [rate] moles per cycle.</span>")

/obj/machinery/atmospherics/miner/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(on)
		on = 0
		update_icon()
/*	if(anchored)
		power_connection.connect()
	else
		power_connection.disconnect()
	power_load_last_tick = 0*/

// Critical equipment.
/obj/machinery/atmospherics/miner/ex_act(severity)
	return

// Critical equipment.
/obj/machinery/atmospherics/miner/blob_act()
	return

/obj/machinery/atmospherics/miner/power_change()
	..()
	set_rate(base_gas_production)
	active_power_usage = base_power_usage
	power_load_last_tick = base_power_usage
	power_load_two_ticks_ago = base_power_usage
/*	power_load_last_tick = 0
	if(!power_connection.connected)
		power_connection.connect()*/
	if(on)
		use_power = MACHINE_POWER_USE_ACTIVE
	else
		use_power = MACHINE_POWER_USE_IDLE
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

	/*if(power_connection.connected)
		var/extra_mined_gas = draw_power() * WATT_TO_KPA_COEFFICIENT
		set_rate(base_gas_production + extra_mined_gas)	*/
	var/extra_mined_gas = power_load_two_ticks_ago * WATT_TO_KPA_COEFFICIENT
	power_load_two_ticks_ago = power_load_last_tick
	power_load_last_tick = active_power_usage
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

/obj/machinery/atmospherics/miner/cryotheum
	name = "\improper Cryotheum Gas Miner"
	overlay_color = "#ABCBFF"
	gases = list(GAS_CRYOTHEUM = 1)

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

/////////////////////////////////////////////
////////////////SURFACE MINER////////////////
/////////////////////////////////////////////
//Receives gas from linked gas extractors on planet surfaces.
/obj/machinery/atmospherics/miner/surface
	name = "surface gas receiver"
	desc = "A specialized gas miner that receives gasses from remote surface extractors."
	icon_state = "miner"
	overlay_color = "#80FF80"
	on = FALSE
	anchored = FALSE
	base_gas_production = 0 // Doesn't produce gas on its own

	id_tag = "surface_gas_receiver"
	machine_flags = WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU

	var/list/linked_extractors = list()
	var/warmup_time = 10 SECONDS
	var/warmup_power_usage = 500

/obj/machinery/atmospherics/miner/surface/New()
	..()
	gases = list()

/obj/machinery/atmospherics/miner/surface/initialize()
	..()
	for(var/obj/machinery/gas_extractor/E in machines)
		if(!E.linked_miner_ref?.get())
			linked_extractors += makeweakref(E)
			E.linked_miner_ref = makeweakref(src)

/obj/machinery/atmospherics/miner/surface/Destroy()
	for(var/datum/weakref/ref in linked_extractors)
		var/obj/machinery/gas_extractor/E = ref.get()
		if(E)
			E.linked_miner_ref = null
	linked_extractors.Cut()
	..()

/obj/machinery/atmospherics/miner/surface/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat = "<b>Linked Surface Extractors:</b><br><ul>"
	var/idx = 1
	for(var/datum/weakref/ref in linked_extractors)
		var/obj/machinery/gas_extractor/E = ref.get()
		if(E)
			dat += "<li>[E.name] at ([E.x], [E.y], [E.z]) <a href='?src=\ref[src];unlink=[idx]'>\[X\]</a></li>"
		idx++
	dat += "</ul>"
	return dat

/obj/machinery/atmospherics/miner/surface/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if("link_extractor" in href_list)
		var/obj/item/device/multitool/P = usr.get_active_hand()
		if(!istype(P))
			return
		var/obj/machinery/gas_extractor/E = P.buffer?.get()
		if(istype(E))
			linkWith(usr, E)
			to_chat(usr, "<span class='notice'>Linked to [E.name].</span>")
		update_multitool_menu(usr)
		return

	if("link_console" in href_list)
		var/obj/item/device/multitool/P = usr.get_active_hand()
		if(!istype(P))
			return
		var/obj/machinery/computer/gas_extraction/C = P.buffer?.get()
		if(istype(C))
			linkWith(usr, C)
			to_chat(usr, "<span class='notice'>Linked to [C.name].</span>")
		update_multitool_menu(usr)
		return

	if("unlink" in href_list)
		var/idx = text2num(href_list["unlink"])
		if(idx >= 1 && idx <= linked_extractors.len)
			var/datum/weakref/ref = linked_extractors[idx]
			var/obj/machinery/gas_extractor/E = ref.get()
			if(E)
				unlinkFrom(usr, E)
				to_chat(usr, "<span class='notice'>Unlinked from [E.name].</span>")
		update_multitool_menu(usr)

/obj/machinery/atmospherics/miner/surface/canLink(var/obj/O, var/list/context)
	return istype(O, /obj/machinery/gas_extractor) || istype(O, /obj/machinery/computer/gas_extraction)

/obj/machinery/atmospherics/miner/surface/isLinkedWith(var/obj/O)
	for(var/datum/weakref/ref in linked_extractors)
		if(ref.get() == O)
			return TRUE
	return FALSE

/obj/machinery/atmospherics/miner/surface/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(istype(O, /obj/machinery/gas_extractor))
		var/obj/machinery/gas_extractor/E = O
		for(var/datum/weakref/ref in linked_extractors)
			if(ref.get() == E)
				return FALSE
		if(E.linked_miner_ref)
			var/obj/machinery/atmospherics/miner/surface/old_miner = E.linked_miner_ref.get()
			if(old_miner)
				old_miner.unlinkFrom(user, E)
		linked_extractors += makeweakref(E)
		E.linked_miner_ref = makeweakref(src)
		return TRUE

	else if(istype(O, /obj/machinery/computer/gas_extraction))
		var/obj/machinery/computer/gas_extraction/C = O
		C.linked_miner_ref = makeweakref(src)
		return TRUE
	return FALSE

/obj/machinery/atmospherics/miner/surface/getLink(var/idx)
	if(idx >= 1 && idx <= linked_extractors.len)
		var/datum/weakref/ref = linked_extractors[idx]
		return ref.get()

/obj/machinery/atmospherics/miner/surface/unlinkFrom(var/mob/user, var/obj/buffer)
	if(istype(buffer, /obj/machinery/gas_extractor))
		var/obj/machinery/gas_extractor/E = buffer
		for(var/datum/weakref/ref in linked_extractors)
			if(ref.get() == E)
				linked_extractors -= ref
				E.linked_miner_ref = null
				return TRUE
		return FALSE

	else if(istype(buffer, /obj/machinery/computer/gas_extraction))
		var/obj/machinery/computer/gas_extraction/C = buffer
		if(C.linked_miner_ref?.get() == src)
			C.linked_miner_ref = null
			return TRUE
		return FALSE

	return FALSE

/obj/machinery/atmospherics/miner/surface/process()
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(!on)
		return

	gases.Cut()
	var/total_extraction = 0
	var/active_extractor_count = 0

	for(var/datum/weakref/ref in linked_extractors)
		var/obj/machinery/gas_extractor/E = ref.get()
		if(!E || !E.extracting || !E.linked_vent)
			continue
		var/datum/vent/V = E.linked_vent
		if(!V || V.mols <= 0)
			continue
		active_extractor_count++

	var/rate_modifier = 1
	if(active_extractor_count > 1)
		rate_modifier = 1 / active_extractor_count // Gas miner is the bottleneck

	for(var/datum/weakref/ref in linked_extractors)
		var/obj/machinery/gas_extractor/E = ref.get()
		if(!E || !E.extracting || !E.linked_vent)
			continue
		var/datum/vent/V = E.linked_vent
		if(!V || V.mols <= 0)
			continue

		var/adjusted_rate = E.mols_extracted * rate_modifier
		if(gases[V.gas_type])
			gases[V.gas_type] += adjusted_rate
		else
			gases[V.gas_type] = adjusted_rate
		total_extraction += adjusted_rate

	if(total_extraction <= 0)
		return

	var/oldstat = stat
	if(!istype(loc, /turf/simulated))
		stat |= BROKEN
	else
		stat &= ~BROKEN
	if(stat != oldstat)
		update_icon()
	if(stat & BROKEN)
		return

	var/extra_mined_gas = power_load_two_ticks_ago * WATT_TO_KPA_COEFFICIENT
	power_load_two_ticks_ago = power_load_last_tick
	power_load_last_tick = active_power_usage
	set_rate(base_gas_production + extra_mined_gas + (total_extraction * 100))
	tranfer_gas()
