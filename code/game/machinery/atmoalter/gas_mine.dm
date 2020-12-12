/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"
	power_channel=ENVIRON

	starting_materials = null
	w_type = NOT_RECYCLABLE

	var/datum/gas_mixture/air_contents
	var/datum/gas_mixture/pumping = new //used in transfering air around

	var/on=1

	var/max_external_pressure=10000 // 10,000kPa ought to do it.
	var/internal_pressure=4500 // Bottleneck

	var/overlay_color = "#FFFFFF"

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/miner/New()
	..()
	air_contents = new
	air_contents.volume = 1000
	pumping.volume = 1000 //Same as above so copying works correctly
	air_contents.temperature = T20C
	AddAir()
	air_contents.update_values()
	update_icon()

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(stat & NOPOWER)
		to_chat(user, "<span class='info'>\The [src]'s status terminal reads: Lack of power.</span>")
		return
	if (!on)
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
		update_icon()

// Critical equipment.
/obj/machinery/atmospherics/miner/ex_act(severity)
	return

// Critical equipment.
/obj/machinery/atmospherics/miner/blob_act()
	return

/obj/machinery/atmospherics/miner/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/miner/attack_ghost(var/mob/user)
	return

/obj/machinery/atmospherics/miner/attack_ai(var/mob/user)
	return attack_hand(user)

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

// Add air here.  DO NOT CALL UPDATE_VALUES OR UPDATE_ICON.
/obj/machinery/atmospherics/miner/proc/AddAir()
	return

/obj/machinery/atmospherics/miner/update_icon()
	src.overlays = 0
	if(stat & NOPOWER)
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
	if(stat & NOPOWER)
		return
	if (!on)
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

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	pumping.copy_from(air_contents)

	var/pressure_delta = 10000

	// External pressure bound
	pressure_delta = min(pressure_delta, (max_external_pressure - environment_pressure))

	// Internal pressure bound (screwed up calc, won't be used anyway)
	//pressure_delta = min(pressure_delta, (internal_pressure - environment_pressure))

	if(pressure_delta > 0.1)
		var/transfer_moles = pressure_delta * CELL_VOLUME / (pumping.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = pumping.remove(transfer_moles)

		loc.assume_air(removed)

//Controls how fast gas comes out (in total)
/obj/machinery/atmospherics/miner/proc/AirRate()
  return internal_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)


/obj/machinery/atmospherics/miner/sleeping_agent
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"

/obj/machinery/atmospherics/miner/sleeping_agent/AddAir()
	var/rate = AirRate()
	air_contents.adjust_multi(GAS_SLEEPING, rate)


/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"

/obj/machinery/atmospherics/miner/nitrogen/AddAir()
	var/rate = AirRate()
	air_contents.adjust_multi(GAS_NITROGEN, rate)


/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"

/obj/machinery/atmospherics/miner/oxygen/AddAir()
	var/rate = AirRate()
	air_contents.adjust_multi(GAS_OXYGEN, rate)


/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"

/obj/machinery/atmospherics/miner/toxins/AddAir()
	var/rate = AirRate()
	air_contents.adjust_multi(GAS_PLASMA, rate)


/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"

/obj/machinery/atmospherics/miner/carbon_dioxide/AddAir()
	var/rate = AirRate()
	air_contents.adjust_multi(GAS_CARBON, rate)


/obj/machinery/atmospherics/miner/air
	name = "\improper Air Miner"
	desc = "You fucking <em>cheater</em>."
	overlay_color = "#70DBDB"

	on = 0

/obj/machinery/atmospherics/miner/air/AddAir()
	var/rate = AirRate()
	air_contents.adjust_multi(GAS_OXYGEN, 0.2*rate,
	GAS_NITROGEN, 0.8*rate)


/obj/machinery/atmospherics/miner/gas_giant
	name = "\improper Gas Miner"

/obj/machinery/atmospherics/miner/gas_giant/initialize()
	..()
	AddAir()

/obj/machinery/atmospherics/miner/gas_giant/AddAir()
	if(ticker)
		air_contents.copy_from(gas_giant.GM)


/obj/machinery/atmospherics/miner/mixed_nitrogen
	name = "\improper Mixed Gas Miner"
	desc = "Pumping nitrogen, carbon dioxide, and plasma."
	overlay_color = "#FF80BD"

/obj/machinery/atmospherics/miner/mixed_nitrogen/AddAir()
  var/rate = AirRate()
  air_contents.adjust_multi(GAS_CARBON, 0.3*rate,
  GAS_NITROGEN, 0.4*rate,
  GAS_PLASMA, 0.3*rate)

/obj/machinery/atmospherics/miner/mixed_oxygen
	name = "\improper Mixed Gas Miner"
	desc = "Pumping oxygen and nitrous oxide."
	overlay_color = "#7EA7E0"

/obj/machinery/atmospherics/miner/mixed_oxygen/AddAir()
  var/rate = AirRate()
  air_contents.adjust_multi(GAS_OXYGEN, 0.5*rate,
  GAS_SLEEPING, 0.5*rate)

/obj/machinery/atmospherics/miner/gas_sink
	name = "Graviton Gas Sink"
	desc = "This is a piece of machinery that uses gravitons to draw in molecules of gas a ship passes while moving through space. Due to the nature of gas dispersal in a vacuum, it requires traveling at hyperspace speeds in order to collect substantial gas particles, and the intake is a mixed, requiring filtering."

/obj/machinery/atmospherics/miner/gas_sink/AddAir()
	var/rate = AirRate()
	if(!rate)
		return
	air_contents.adjust_multi(GAS_CARBON, 0.1*rand(1,2)*rate,
		GAS_NITROGEN, 0.1*rand(2,3)*rate,
		GAS_PLASMA, 0.1*rand(4,5)*rate,
		GAS_OXYGEN, 0.1*rand(4,5)*rate,
		GAS_SLEEPING, 0.1*rand(1,2)*rate)

/obj/machinery/atmospherics/miner/gas_sink/AirRate()
	var/datum/zLevel/current_zlevel = get_z_level(src)
	if(istype(current_zlevel,/datum/zLevel/hyperspace))
		return ..()
	return 0
