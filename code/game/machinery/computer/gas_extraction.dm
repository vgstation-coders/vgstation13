#define EXTRACTOR_STATE_UNDEPLOYED 0
#define EXTRACTOR_STATE_DEPLOYING 1
#define EXTRACTOR_STATE_WARMUP 2
#define EXTRACTOR_STATE_EXTRACTING 3
#define EXTRACTOR_STATE_BROKEN 4

///////////////////////////////////
// Gas Extractor Control Console //
///////////////////////////////////
// A console for monitoring and controlling surface gas extractors
// Links: Console <-> Surface Gas Receiver <-> Surface Gas Extractors

/obj/item/weapon/circuitboard/gas_extraction
	name = "Circuit board (Gas Extraction Console)"
	desc = "A circuit board for running a computer used to operate gas extractor machines."
	build_path = /obj/machinery/computer/gas_extraction
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_EXPLORATION + "=1"

/obj/machinery/computer/gas_extraction
	name = "gas extractor control console"
	desc = "A console for monitoring and controlling surface gas extractors. Links to a surface gas receiver to manage connected extractors."
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel1e"
	circuit = "/obj/item/weapon/circuitboard/gas_extraction"

	light_color = LIGHT_COLOR_CYAN

	id_tag = "gas_extractor_console"

	var/datum/weakref/linked_miner_ref

/obj/machinery/computer/gas_extraction/initialize()
	..()
	if(!linked_miner_ref)
		for(var/obj/machinery/atmospherics/miner/surface/M in world)
			if(M.z == src.z)
				linked_miner_ref = makeweakref(M)
				break

/obj/machinery/computer/gas_extraction/Destroy()
	linked_miner_ref = null
	..()

/obj/machinery/computer/gas_extraction/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] must be anchored to function.</span>")
		return
	if(!isAI(user) && !Adjacent(user))
		to_chat(user, "<span class='warning'>You're too far away.</span>")
		return
	tgui_interact(user)

/obj/machinery/computer/gas_extraction/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasExtractorConsole", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/gas_extraction/ui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	data["linked"] = M ? TRUE : FALSE
	data["broken"] = (stat & BROKEN) ? TRUE : FALSE

	if(!M)
		return data

	data["miner_on"] = M.on
	data["miner_power"] = M.active_power_usage
	data["miner_base_power"] = M.base_power_usage

	// Get gas production rates per type
	var/list/gas_rates = list()
	if(M.gases && M.gases.len > 0)
		for(var/gas_id in M.gases)
			var/datum/gas/gas_datum = XGM.gases[gas_id]
			if(!gas_datum)
				continue

			// Calculate moles per second for this gas type
			var/gas_mols_per_tick = M.rate * M.gases[gas_id]
			var/gas_mols_per_second = gas_mols_per_tick / 2 // machines subsystem ticks once every 2s

			gas_rates += list(list(
				"name" = gas_datum.name,
				"id" = gas_id,
				"rate" = round(gas_mols_per_second, 0.01)
			))
	data["gas_rates"] = gas_rates

	data["total_rate"] = M.rate ? round(M.rate / 2, 0.01) : 0

	var/list/extractors = list()
	for(var/datum/weakref/ref in M.linked_extractors)
		var/obj/machinery/gas_extractor/E = ref.get()
		if(!E)
			continue

		var/state_text = "Unknown"
		switch(E.extractor_state)
			if(EXTRACTOR_STATE_UNDEPLOYED)
				state_text = "Undeployed"
			if(EXTRACTOR_STATE_DEPLOYING)
				state_text = "Deploying"
			if(EXTRACTOR_STATE_WARMUP)
				state_text = "Warming Up"
			if(EXTRACTOR_STATE_EXTRACTING)
				state_text = "Extracting"
			if(EXTRACTOR_STATE_BROKEN)
				state_text = "Broken"

		var/gas_type_name = "None"
		if(E.linked_vent)
			var/datum/gas/gas_datum = XGM.gases[E.linked_vent.gas_type]
			if(gas_datum)
				gas_type_name = gas_datum.name

		var/vent_reserves_percent = 0
		var/vent_reserves = 0
		if(E.linked_vent)
			if(E.linked_vent.initial_mols > 0)
				vent_reserves_percent = round((E.linked_vent.mols / E.linked_vent.initial_mols) * 100)
			vent_reserves = round(E.linked_vent.mols, 0.1)

		extractors += list(list(
			"ref" = "\ref[E]",
			"name" = E.name,
			"location" = "([E.x], [E.y], [E.z])",
			"active" = E.active,
			"extracting" = E.extracting,
			"deployed" = E.deployed,
			"state" = E.extractor_state,
			"state_text" = state_text,
			"stability" = E.stability,
			"stability_critical" = E.stability <= 25,
			"gas_type" = gas_type_name,
			"vent_reserves" = vent_reserves,
			"vent_reserves_percent" = vent_reserves_percent,
			"extraction_rate" = round(E.extraction_rate / 2, 0.01) // Convert to per-second
		))

	data["extractors"] = extractors

	return data

/obj/machinery/computer/gas_extraction/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(stat & BROKEN)
		return FALSE

	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	if(!M)
		return FALSE

	switch(action)
		if("toggle_miner")
			if(M.anchored)
				M.on = !M.on
				M.power_change()
				return TRUE

		if("set_power")
			var/new_power = text2num(params["power"])
			if(!isnum(new_power) || new_power < 0)
				return FALSE
			if(new_power > 50000)
				to_chat(usr, "<span class='warning'>Bluespace link collapses with power rates higher than 50kW.</span>")
				return FALSE
			M.active_power_usage = new_power
			M.power_load_last_tick = new_power
			return TRUE

		if("adjust_power")
			var/adjustment = text2num(params["amount"])
			if(!isnum(adjustment))
				return FALSE
			var/new_power = M.active_power_usage + adjustment
			if(new_power < M.base_power_usage)
				new_power = M.base_power_usage
			if(new_power > 50000)
				to_chat(usr, "<span class='warning'>Bluespace link collapses with power rates higher than 50kW.</span>")
				return FALSE
			M.active_power_usage = new_power
			M.power_load_last_tick = new_power
			return TRUE

		if("toggle_extractor")
			var/extractor_ref = params["ref"]
			if(!extractor_ref)
				return FALSE

			for(var/datum/weakref/ref in M.linked_extractors)
				var/obj/machinery/gas_extractor/E = ref.get()
				if(!E || "\ref[E]" != extractor_ref)
					continue

				if(!E.deployed && !E.active)
					if(!E.anchored)
						to_chat(usr, "<span class='warning'>\The [E] must be bolted down first.</span>")
						return FALSE
					if(E.stat & BROKEN)
						to_chat(usr, "<span class='warning'>\The [E] is broken!</span>")
						return FALSE
					if(E.extractor_state != EXTRACTOR_STATE_UNDEPLOYED)
						return FALSE

					E.linked_vent = E.find_vent()
					if(!E.linked_vent)
						to_chat(usr, "<span class='warning'>No gas vent detected beneath \the [E]!</span>")
						return FALSE

					E.extractor_state = EXTRACTOR_STATE_DEPLOYING
					flick(E.base_icon_state + "-deploy", E)
					E.finish_deployment()
					return TRUE

				else if(E.deployed || E.active)
					if(E.extractor_state == EXTRACTOR_STATE_WARMUP || E.extractor_state == EXTRACTOR_STATE_EXTRACTING)
						E.active = FALSE
						E.extracting = FALSE
						E.extractor_state = EXTRACTOR_STATE_UNDEPLOYED
						E.deployed = FALSE
						E.warmup_ticks = 0
						E.warned_low_reserves = FALSE
						E.warned_low_stability = FALSE
						flick(E.base_icon_state + "-undeploy", E)
						E.update_icon()
						return TRUE
	return FALSE

/obj/machinery/computer/gas_extraction/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat = "<b>Gas Extractor Console</b><br>"
	if(linked_miner_ref?.get())
		var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
		dat += "<b>Linked to:</b> [M.name] at ([M.x], [M.y], [M.z]) <a href='?src=\ref[src];unlink=1'>\[X\]</a><br>"
	else
		dat += "<b>Not linked to any surface gas receiver.</b><br>"
		if(P && P.buffer)
			var/obj/machinery/atmospherics/miner/surface/buffered = P.buffer.get()
			if(istype(buffered))
				dat += "<a href='?src=\ref[src];link=1'>\[Link to buffered Surface Gas Receiver\]</a><br>"
	return dat

/obj/machinery/computer/gas_extraction/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if("link" in href_list)
		var/obj/item/device/multitool/P = usr.get_active_hand()
		if(!istype(P))
			return
		var/obj/machinery/atmospherics/miner/surface/M = P.buffer?.get()
		if(istype(M))
			linked_miner_ref = makeweakref(M)
			to_chat(usr, "<span class='notice'>Linked to [M.name].</span>")
		update_multitool_menu(usr)
		return

	if("unlink" in href_list)
		linked_miner_ref = null
		to_chat(usr, "<span class='notice'>Unlinked from surface gas receiver.</span>")
		update_multitool_menu(usr)

/obj/machinery/computer/gas_extraction/canLink(var/obj/O, var/list/context)
	return istype(O, /obj/machinery/atmospherics/miner/surface)

/obj/machinery/computer/gas_extraction/isLinkedWith(var/obj/O)
	return linked_miner_ref?.get() == O

/obj/machinery/computer/gas_extraction/linkWith(var/mob/user, var/obj/machinery/atmospherics/miner/surface/O, var/list/context)
	if(!istype(O))
		return FALSE
	linked_miner_ref = makeweakref(O)
	return TRUE

/obj/machinery/computer/gas_extraction/getLink(var/idx)
	if(idx == 1)
		return linked_miner_ref?.get()
	return null

/obj/machinery/computer/gas_extraction/unlinkFrom(var/mob/user, var/obj/buffer)
	if(linked_miner_ref?.get() == buffer)
		linked_miner_ref = null
		return TRUE
	return FALSE

#undef EXTRACTOR_STATE_UNDEPLOYED
#undef EXTRACTOR_STATE_DEPLOYING
#undef EXTRACTOR_STATE_WARMUP
#undef EXTRACTOR_STATE_EXTRACTING
#undef EXTRACTOR_STATE_BROKEN
