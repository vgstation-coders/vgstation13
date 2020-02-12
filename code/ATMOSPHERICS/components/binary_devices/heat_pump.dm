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
	var/mtd_slope_at_zero = 0.5

	use_power = 0
	idle_power_usage = 1000


/obj/machinery/atmospherics/binary/heat_pump/process()
	. = ..()
	if(!on || stat & (NOPOWER | BROKEN))
		return

	var/temp_diff = air2.temperature - air1.temperature
	var/mtd = get_mtd(air2.temperature)
	if(temp_diff >= mtd)
		return

	//This calculates the amount of thermal energy that must be moved from air1 to air2 to get them to the desired temperature difference.
	var/heat_transfer = (air1.temperature - air2.temperature + mtd) / (1 / air1.heat_capacity() + 1 / air2.heat_capacity())

	air1.add_thermal_energy(-heat_transfer, 0)
	air2.add_thermal_energy(heat_transfer) //Realistically it should also add idle_power_usage, but this might be more trouble than it's worth.
	//It would further complicate setups, and would also allow for infinite energy memes since (at the time of writing) the TEG can break 100% efficiency.

	network1.update = TRUE
	network2.update = TRUE


/obj/machinery/atmospherics/binary/heat_pump/attack_hand(mob/user)
	toggle_status(user)


/obj/machinery/atmospherics/binary/heat_pump/toggle_status(mob/user)
	. = ..()
	use_power = on


/obj/machinery/atmospherics/binary/heat_pump/update_icon()
	if(!on || stat & (NOPOWER | BROKEN))
		icon_state = "intact_off"
	else
		icon_state = "intact_on"
	..()


//It's hard to read here, but it's just an inverse function offset and scaled to match the variables as described above.
//(Specifically, it's 1/x flipped vertically and offset by 1 left and 1 up, then scaled vertically to set the asymptote and horizontally to set the slope at 0.)
/obj/machinery/atmospherics/binary/heat_pump/proc/get_mtd(temp)
	return mtd_limit * (1 - 1 / (1 + temp * mtd_slope_at_zero / mtd_limit))
