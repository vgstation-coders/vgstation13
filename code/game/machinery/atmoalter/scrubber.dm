#define MAX_PRESSURE 50*ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = 0
	var/volume_rate = 5000 //litres / tick
	var/scrubbing_rate = 300 //litres / tick, max amount of gas put in internal tank per tick

	var/scrub_o2 = FALSE
	var/scrub_n2 = FALSE
	var/scrub_n2o = TRUE
	var/scrub_co2 = TRUE
	var/scrub_plasma = TRUE

	volume = 2000

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on
		update_icon()

	nanomanager.update_uis(src)
	..(severity)

/obj/machinery/portable_atmospherics/scrubber/huge
	name = "Huge Air Scrubber"
	icon_state = "scrubber:0"
	anchored = 1
	volume = 50000
	volume_rate = 20000
	scrubbing_rate = 1200

	var/global/gid = 1
	var/id = 0
/obj/machinery/portable_atmospherics/scrubber/huge/New()
	..()
	id = gid
	gid++

	name = "[name] (ID [id])"

/obj/machinery/portable_atmospherics/scrubber/huge/attack_hand(var/mob/user as mob)
	to_chat(usr, "<span class='notice'>You can't directly interact with this machine. Use the area atmos computer.</span>")

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "scrubber:1"
	else
		icon_state = "scrubber:0"

/obj/machinery/portable_atmospherics/scrubber/huge/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(iswrench(W))
		if(on)
			to_chat(user, "<span class='notice'>Turn it off first!</span>")
			return

		anchored = !anchored
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")

		return

	..()

/obj/machinery/portable_atmospherics/scrubber/huge/stationary
	name = "Stationary Air Scrubber"

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(iswrench(W))
			to_chat(user, "<span class='notice'>The bolts are too tight for you to unscrew!</span>")
			return

		..()


/obj/machinery/portable_atmospherics/scrubber/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	if(holding)
		overlays += image(icon = icon, icon_state = "scrubber-open")

	if(connected_port)
		overlays += image(icon = icon, icon_state = "scrubber-connector")

	return

/obj/machinery/portable_atmospherics/scrubber/proc/get_environment()
	if(holding)
		return holding.air_contents
	else
		return loc.return_air()

/obj/machinery/portable_atmospherics/scrubber/proc/remove_sample(var/datum/gas_mixture/environment, var/transfer_moles)
	if(holding)
		return environment.remove(transfer_moles)
	else
		return loc.remove_air(transfer_moles)

/obj/machinery/portable_atmospherics/scrubber/proc/return_sample(var/datum/gas_mixture/environment, var/datum/gas_mixture/removed)
	if(holding)
		environment.merge(removed)
	else
		loc.assume_air(removed)

/obj/machinery/portable_atmospherics/scrubber/process()
	..()

	if(on && air_contents.return_pressure() < MAX_PRESSURE)
		var/datum/gas_mixture/environment = get_environment()
		var/transfer_moles = min(1, volume_rate / environment.volume) * environment.total_moles()
		var/removed_volume = min(volume_rate, environment.volume)

		//Take a gas sample
		var/datum/gas_mixture/removed = remove_sample(environment, transfer_moles)

		//Filter it
		//copypasted from scrubber code with modifications to add the scrubbing rate limit
		if (removed)
			var/datum/gas_mixture/total_to_filter = new
			total_to_filter.temperature = removed.temperature
			#define FILTER(g) total_to_filter.adjust_gas((g), removed[g], FALSE)
			if(scrub_plasma)
				FILTER(GAS_PLASMA)
			if(scrub_co2)
				FILTER(GAS_CARBON)
			if(scrub_n2o)
				FILTER(GAS_SLEEPING)
			if(scrub_n2)
				FILTER(GAS_NITROGEN)
			if(scrub_o2)
				FILTER(GAS_OXYGEN)
			FILTER(GAS_OXAGENT)
			#undef FILTER
			total_to_filter.update_values() //since the FILTER macro doesn't update to save perf, we need to update here
			//calculate the amount of moles in scrubbing_rate litres of gas in removed and apply the scrubbing rate limit
			var/filter_moles = min(1, scrubbing_rate / removed_volume) * removed.total_moles()
			var/datum/gas_mixture/filtered_out = total_to_filter.remove(filter_moles)

			removed.subtract(filtered_out)

			//Remix the resulting gases
			air_contents.merge(filtered_out)
			return_sample(environment, removed)
		//src.update_icon()
		nanomanager.update_uis(src)
	//src.updateDialog()
	return

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(var/mob/user as mob)
	ui_interact(user)
	return

/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/list/data[0]
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() > 0 ? air_contents.return_pressure() : 0)
	data["rate"] = round(volume_rate)
	data["on"] = on ? 1 : 0
	data["scrub_plasma"] = scrub_plasma
	data["scrub_co2"] = scrub_co2
	data["scrub_n2o"] = scrub_n2o
	data["scrub_n2"] = scrub_n2
	data["scrub_o2"] = scrub_o2

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure() > 0 ? holding.air_contents.return_pressure() : 0))

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "portscrubber.tmpl", "Portable Scrubber", 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	. = ..()
	if(.)
		return .

	if(href_list["power"])
		on = !on
		update_icon()

	if(href_list["remove_tank"])
		if(holding)
			eject_holding()

	if(href_list["scrub_toggle"])
		switch(href_list["scrub_toggle"])
			if("plasma")
				scrub_plasma = !scrub_plasma
			if("co2")
				scrub_co2 = !scrub_co2
			if("n2o")
				scrub_n2o = !scrub_n2o
			if("n2")
				scrub_n2 = !scrub_n2
			if("o2")
				scrub_o2 = !scrub_o2
		return 1

	src.add_fingerprint(usr)
	return 1

/obj/machinery/portable_atmospherics/scrubber/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
		eject_holding()
		return
	return ..()

/obj/machinery/portable_atmospherics/scrubber/mech
	volume = 50000
	volume_rate = 20000
	scrubbing_rate = 1200
	var/obj/mecha/mech //the mech associated with this scrubber

/obj/machinery/portable_atmospherics/scrubber/mech/New(var/location)
	..()
	src.mech = location

/obj/machinery/portable_atmospherics/scrubber/mech/get_environment()
	var/turf/T = get_turf(src)
	return T.return_air()

/obj/machinery/portable_atmospherics/scrubber/mech/remove_sample(var/environment, var/transfer_moles)
	var/turf/T = get_turf(src)
	return T.remove_air(transfer_moles)

/obj/machinery/portable_atmospherics/scrubber/mech/return_sample(var/environment, var/removed)
	var/turf/T = get_turf(src)
	T.assume_air(removed)

//required to allow the pilot to use the scrubber UI
/obj/machinery/portable_atmospherics/scrubber/mech/is_on_same_z(var/mob/user)
	if(user == mech.occupant)
		return TRUE
	return FALSE

/obj/machinery/portable_atmospherics/scrubber/mech/is_in_range(var/mob/user)
	if(user == mech.occupant)
		return TRUE
	return FALSE

//Have to override this to let it connect from the mech
/obj/machinery/portable_atmospherics/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src

	anchored = 1 //Prevent movement

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network && !network.gases.Find(air_contents))
		network.gases += air_contents
		network.update = 1
	update_icon()
	return 1

#undef MAX_PRESSURE
