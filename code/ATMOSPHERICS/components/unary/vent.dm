/obj/machinery/atmospherics/unary/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "base"
	name = "Vent"
	desc = "A large air vent"
	level = 1
	var/volume = 500
	dir = SOUTH
	initialize_directions = SOUTH
	var/build_killswitch = 1

	var/welded = 0

	ex_node_offset = 3
	var/static/image/bezel = image('icons/obj/atmospherics/pipe_vent.dmi', "bezel")

/obj/machinery/atmospherics/unary/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/unary/vent/New()
	..()
	air_contents.volume = volume

/obj/machinery/atmospherics/unary/vent/process()
	. = ..()

	CHECK_DISABLED(vents)
	if (!node1)
		return// Turning off the vent is a PITA. - N3X

	if (welded)
		return

	// New GC does this sometimes
	if(!loc)
		return

	//air_contents.mingle_with_turf(loc)

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()
	var/pressure_delta = min(10000, abs(environment_pressure - air_contents.return_pressure()))

	if((environment.temperature || air_contents.temperature) && pressure_delta > 0.5)
		if(environment_pressure < air_contents.pressure) //move air out
			var/air_temperature = (environment.temperature > 0) ? environment.temperature : air_contents.temperature
			var/transfer_moles = (pressure_delta * environment.volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			loc.assume_air(removed)
		else //move air in
			var/air_temperature = (air_contents.temperature > 0) ? air_contents.temperature : environment.temperature
			var/output_volume = air_contents.volume + (network ? network.volume : 0)
			var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
			//limit flow rate from turfs
			transfer_moles = min(transfer_moles, environment.total_moles*air_contents.volume/environment.volume)
			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			if(isnull(removed)) //in space
				return
			air_contents.merge(removed)

		if(network)
			network.update = TRUE

	return 1

/obj/machinery/atmospherics/unary/vent/update_icon()
	icon_state = welded ? "weld" : "base"

	..()

	if (level == 1)
		bezel.layer = VENT_BEZEL_LAYER
		bezel.plane = ABOVE_PLATING_PLANE

	else
		bezel.layer = EXPOSED_PIPE_LAYER + 1
		bezel.plane = ABOVE_TURF_PLANE

	underlays += bezel

/obj/machinery/atmospherics/unary/vent/initialize()
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/hide(var/i)
	update_icon()

/obj/machinery/atmospherics/unary/vent/examine(mob/user)
	..()
	if(welded)
		to_chat(user, "<span class='info'>It seems welded shut.</span>")

/obj/machinery/atmospherics/unary/vent/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		to_chat(user, "<span class='notice'>Now welding the vent.</span>")
		if (WT.do_weld(user, src, 20, 1))
			if(gcDestroyed)
				return
			if(!welded)
				user.visible_message("[user] welds the vent shut.", "You weld the vent shut.", "You hear welding.")
				investigation_log(I_ATMOS, "has been welded shut by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")
				welded = 1
				update_icon()
			else
				user.visible_message("[user] unwelds the vent.", "You unweld the vent.", "You hear welding.")
				investigation_log(I_ATMOS, "has been unwelded by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")
				welded = 0
				update_icon()
	return ..()
