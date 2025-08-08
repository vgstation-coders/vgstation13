/*
Uses power to actively pump heat from air1 to air2.
Intentionally does not directly pump heat between networks because the volume limits are a nice way of limiting the heat transfer to reasonable numbers.

This device has a maximum temperature difference (shortened to mtd in var/proc names and MTD in the rest of the comments here) between its two sides that it can achieve.
Its internal reservoirs are instantly brought to the MTD every tick, so the network as a whole gradually approaches it.

The MTD depends on the temperature of air2. It is a simple asymptotic function with two constants:
mtd_limit is the horizontal asymptote.
In practice, the MTD approaches this value as air2.temperature increases.
This value technically also affects performance at low temperatures, but the effect is negligible unless it's set very low (well under 100).
The only necessary restriction on this value is that it must be positive.

mtd_slope_at_zero is... the slope of the function at zero.
In practice, this defines roughly what fraction of the way to absolute zero from air2.temperature the device can bring air1 when air2 is already cold.
(In other words, if mtd_slope_at_zero is 2/3 and air2.temperature is held at 1K, air1.temperature will bottom out at a bit over 1/3K.)
This value must always be less than or equal to 1 or else you run the risk of getting below absolute zero.
Exactly 1 is not recommended, but *shouldn't* break physics unless mtd_limit is also very large.
It also must be positive. Technically it can be 0 without breaking physics, but the device won't do anything.
*/

/obj/machinery/atmospherics/binary/heat_pump
	icon = 'icons/obj/atmospherics/heat_pump.dmi'
	icon_state = "intact_on"

	name = "thermoelectric cooler"
	desc = "A device that actively transfers heat between two pipelines."

	var/mtd_limit = 2500
	var/mtd_slope_at_zero = 2 / 3

	var/process_margin = 0.99 //Doesn't process when the current temperature difference is within 1% of MTD for performance reasons

	active_power_usage = 3000
	power_channel = EQUIP

	ghost_read = FALSE

	frequency = 0
	var/datum/radio_frequency/radio_connection
	machine_flags = MULTITOOL_MENU


/obj/machinery/atmospherics/binary/heat_pump/process()
	. = ..()
	if(!on || stat & (NOPOWER | BROKEN | FORCEDISABLE))
		return

	if(!air1.total_moles || !air2.total_moles)
		return

	var/temp_diff = air2.temperature - air1.temperature
	var/mtd = get_mtd(air2.temperature)
	if(temp_diff >= mtd * process_margin)
		return

	//This calculates the amount of thermal energy that must be moved from air1 to air2 to get them to the desired temperature difference.
	var/heat_transfer = (air1.temperature - air2.temperature + mtd) / (1 / air1.heat_capacity() + 1 / air2.heat_capacity())

	heat_transfer = -air1.add_thermal_energy(-heat_transfer, 0)
	air2.add_thermal_energy(heat_transfer) //Realistically it should also add idle_power_usage, but this might be more trouble than it's worth.
	//It would further complicate setups, and would also allow for infinite energy memes since (at the time of writing) the TEG can break 100% efficiency.

	network1?.update = TRUE
	network2?.update = TRUE


//It's hard to read here, but it's just an inverse function offset and scaled to match the variables as described above.
//(Specifically, it's 1/x flipped vertically and offset by 1 left and 1 up, then scaled vertically to set the asymptote and horizontally to set the slope at 0.)
/obj/machinery/atmospherics/binary/heat_pump/proc/get_mtd(temp)
	return mtd_limit * (1 - 1 / (1 + temp * mtd_slope_at_zero / mtd_limit))


/obj/machinery/atmospherics/binary/heat_pump/power_change()
	..()
	update_icon()


/obj/machinery/atmospherics/binary/heat_pump/attack_hand(mob/user)
	toggle_status(user)

/obj/machinery/atmospherics/binary/heat_pump/toggle_status(mob/user)
	if(issilicon(user))
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	. = ..()
	update_status()


/obj/machinery/atmospherics/binary/heat_pump/proc/update_status() //Really not sure why this isn't defined on the parent
	use_power = on ? MACHINE_POWER_USE_ACTIVE : MACHINE_POWER_USE_IDLE


/obj/machinery/atmospherics/binary/heat_pump/update_icon()
	if(!on || stat & (NOPOWER | BROKEN | FORCEDISABLE))
		icon_state = "intact_off"
	else
		icon_state = "intact_on"
	..()

/obj/machinery/atmospherics/binary/heat_pump/initialize()
	..()
	if(frequency)
		set_frequency(frequency)


/obj/machinery/atmospherics/binary/heat_pump/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)


/obj/machinery/atmospherics/binary/heat_pump/multitool_menu(mob/user, obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}


/obj/machinery/atmospherics/binary/heat_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/old_on = on
	switch(signal.data["command"])
		if("cooler_on")
			on = TRUE

		if("cooler_off")
			on = FALSE

		if("cooler_set")
			on = !!signal.data["state"] //The double inversion forces it to be either 1/TRUE or 0/FALSE and not some other value

		if("cooler_toggle")
			on = !on

	update_status()
	if(on != old_on)
		investigation_log(I_ATMOS,"was turned [(on ? "on" : "off")] by a signal")


/obj/machinery/atmospherics/binary/heat_pump/canClone(obj/O)
	return istype(O, /obj/machinery/atmospherics/binary/heat_pump)


/obj/machinery/atmospherics/binary/heat_pump/clone(obj/machinery/atmospherics/binary/heat_pump/O)
	id_tag = O.id_tag
	set_frequency(O.frequency)
	return 1


/obj/machinery/atmospherics/binary/heat_pump/npc_tamper_act(mob/living/L)
	on = !on
	update_status()
	investigation_log(I_ATMOS,"was turned [(on ? "on" : "off")] by [key_name(L)]")
