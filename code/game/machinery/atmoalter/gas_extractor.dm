#define EXTRACTOR_STATE_UNDEPLOYED 0
#define EXTRACTOR_STATE_DEPLOYING 1
#define EXTRACTOR_STATE_WARMUP 2
#define EXTRACTOR_STATE_EXTRACTING 3
#define EXTRACTOR_STATE_BROKEN 4

// Used to extract gasses from planetary gas vents. Use with a surface gas miner on the station.
/obj/machinery/gas_extractor
	name = "\improper Surface Gas Extractor"
	desc = "A drilling rig designed to extract gasses from planetary vents."
	icon = 'icons/obj/machines/drill.dmi'
	icon_state = "deep_core_drill"
	var/base_icon_state = "deep_core_drill"
	var/icon/beam_overlay
	machine_flags = WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU
	power_channel = ENVIRON
	use_power = MACHINE_POWER_USE_NONE
	density = TRUE
	plane = ABOVE_HUMAN_PLANE
	layer = CLOSED_CURTAIN_LAYER

	var/extractor_state = EXTRACTOR_STATE_UNDEPLOYED
	var/deployed = FALSE
	var/active = FALSE
	var/extracting = FALSE
	var/stability = 100
	var/max_stability = 100

	var/datum/weakref/linked_miner_ref
	var/datum/vent/linked_vent

	var/warmup_ticks = 0
	var/warmup_ticks_required = 5

	var/extraction_rate = 1

	var/warned_low_reserves = FALSE // Has the 25% reserve warning been played?
	var/warned_low_stability = FALSE // Has the 50% stability warning been played?

/obj/machinery/gas_extractor/New()
	..()
	beam_overlay = image(icon, icon_state = "mining_beam")

/obj/machinery/gas_extractor/Destroy()
	beam_overlay = null
	if(linked_miner_ref)
		var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
		if(M)
			M.unlink_extractor(src)
		linked_miner_ref = null
	linked_vent = null
	..()

/obj/machinery/gas_extractor/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>\The [src] is broken and non-functional.</span>")
		return

	switch(extractor_state)
		if(EXTRACTOR_STATE_UNDEPLOYED)
			to_chat(user, "<span class='info'>\The [src] is not deployed. Wrench it in place and activate it to begin deployment.</span>")
		if(EXTRACTOR_STATE_DEPLOYING)
			to_chat(user, "<span class='info'>\The [src] is currently deploying...</span>")
		if(EXTRACTOR_STATE_WARMUP)
			to_chat(user, "<span class='info'>\The [src] is warming up. Progress: [round((warmup_ticks / warmup_ticks_required) * 100)]%</span>")
		if(EXTRACTOR_STATE_EXTRACTING)
			to_chat(user, "<span class='info'>\The [src] is actively extracting gas.</span>")
			if(linked_vent)
				var/remaining_percent = round((linked_vent.mols / linked_vent.initial_mols) * 100)
				to_chat(user, "<span class='info'>Vent reserves: [remaining_percent]%</span>")

	to_chat(user, "<span class='info'>Stability: [stability]%</span>")
	if(stability <= 25)
		to_chat(user, "<span class='boldwarning'>WARNING: Stability critical! Structural failure imminent!</span>")

	if(linked_miner_ref?.get())
		to_chat(user, "<span class='info'>Linked to station receiver.</span>")
	else
		to_chat(user, "<span class='warning'>Not linked to any station receiver. Use a multitool to link.</span>")

/obj/machinery/gas_extractor/update_icon()
	overlays.Cut()
	if(stat & BROKEN)
		if(deployed)
			icon_state = base_icon_state + "-deployed_broken"
		else
			icon_state = base_icon_state + "-broken"
		return

	icon_state = base_icon_state
	if(deployed)
		if(stability <= 25)
			icon_state += "-alert"
			beam_overlay = image(icon, icon_state = "mining_beam-unstable")
			overlays += beam_overlay
		else if(extracting)
			icon_state += "-active"
			beam_overlay = image(icon, icon_state = "mining_beam-particles")
			overlays += beam_overlay
		else if(active)
			icon_state += "-idle"
			beam_overlay = image(icon, icon_state = "mining_beam")
			overlays += beam_overlay
		else
			icon_state += "-idle"
	else
		icon_state = base_icon_state

/obj/machinery/gas_extractor/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	// Handle vent particle effects
	var/datum/vent/V = find_vent()
	if(anchored)
		// Remove vent particles when anchored on a vent
		if(V)
			var/turf/T = V.turf_ref?.get()
			if(T)
				T.remove_particles(PS_GAS_VENT)
	else
		// Restore vent particles when unwrenched
		if(V)
			var/turf/T = V.turf_ref?.get()
			if(T)
				T.add_particles(PS_GAS_VENT)
		// Reset state when unwrenched
		if(deployed || active || extracting)
			deployed = FALSE
			active = FALSE
			extracting = FALSE
			extractor_state = EXTRACTOR_STATE_UNDEPLOYED
			warmup_ticks = 0
			linked_vent = null
			to_chat(user, "<span class='notice'>You retract \the [src]'s drilling apparatus.</span>")
		update_icon()

/obj/machinery/gas_extractor/attack_hand(var/mob/user)
	if(!Adjacent(user))
		to_chat(user, "<span class='warning'>You're too far away.</span>")
		return

	tgui_interact(user)

/obj/machinery/gas_extractor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasExtractor", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/gas_extractor/ui_data(mob/user)
	var/list/data = list()

	// Basic status
	data["anchored"] = anchored
	data["broken"] = (stat & BROKEN) ? TRUE : FALSE

	// Link status
	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	data["linked"] = M ? TRUE : FALSE

	// State information
	data["state"] = extractor_state
	switch(extractor_state)
		if(EXTRACTOR_STATE_UNDEPLOYED)
			data["state_text"] = "Undeployed"
		if(EXTRACTOR_STATE_DEPLOYING)
			data["state_text"] = "Deploying..."
		if(EXTRACTOR_STATE_WARMUP)
			data["state_text"] = "Warming Up"
		if(EXTRACTOR_STATE_EXTRACTING)
			data["state_text"] = "Extracting"
		if(EXTRACTOR_STATE_BROKEN)
			data["state_text"] = "Broken"
		else
			data["state_text"] = "Unknown"

	data["deployed"] = deployed

	// Can we deploy?
	data["can_deploy"] = FALSE
	data["deploy_error"] = null
	if(!anchored)
		data["deploy_error"] = "Extractor must be bolted down first."
	else if(stat & BROKEN)
		data["deploy_error"] = "Extractor is broken beyond repair."
	else if(!M)
		data["deploy_error"] = "Not linked to a station receiver. Use a multitool to link."
	else if(!find_vent())
		data["deploy_error"] = "No gas vent detected beneath the extractor."
	else if(extractor_state == EXTRACTOR_STATE_UNDEPLOYED)
		data["can_deploy"] = TRUE

	// Warmup progress
	data["warmup_progress"] = warmup_ticks_required > 0 ? round((warmup_ticks / warmup_ticks_required) * 100) : 0

	// Extraction info
	data["extracting"] = extracting
	// Calculate mols per second (extraction_rate is per tick, ticks are 2 seconds)
	data["extraction_rate"] = extraction_rate / 2

	// Gas type - convert ID to proper name
	if(linked_vent)
		var/datum/gas/gas_datum = XGM.gases[linked_vent.gas_type]
		if(gas_datum)
			data["gas_type"] = gas_datum.name
		else
			data["gas_type"] = linked_vent.gas_type
	else
		data["gas_type"] = null

	// Vent reserves
	if(linked_vent)
		data["vent_reserves"] = round(linked_vent.mols, 0.1)
		data["vent_initial"] = round(linked_vent.initial_mols, 0.1)
		data["vent_reserves_percent"] = linked_vent.initial_mols > 0 ? round((linked_vent.mols / linked_vent.initial_mols) * 100) : 0
	else
		data["vent_reserves"] = 0
		data["vent_initial"] = 0
		data["vent_reserves_percent"] = 0

	// Damage threshold - stability degrades below 25%
	data["damage_threshold"] = 25

	// Stability
	data["stability"] = stability
	data["max_stability"] = max_stability
	data["stability_percent"] = max_stability > 0 ? round((stability / max_stability) * 100) : 0
	data["stability_critical"] = stability <= 25

	return data

/obj/machinery/gas_extractor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("deploy")
			if(!anchored)
				to_chat(usr, "<span class='warning'>\The [src] must be bolted down first.</span>")
				return TRUE
			if(stat & BROKEN)
				to_chat(usr, "<span class='warning'>\The [src] is broken!</span>")
				return TRUE
			if(extractor_state != EXTRACTOR_STATE_UNDEPLOYED)
				return TRUE
			// Check for linked miner
			if(!linked_miner_ref?.get())
				to_chat(usr, "<span class='warning'>\The [src] is not linked to a station receiver! Use a multitool to link it first.</span>")
				return TRUE
			// Check for gas vent
			linked_vent = find_vent()
			if(!linked_vent)
				to_chat(usr, "<span class='warning'>No gas vent detected beneath \the [src]!</span>")
				return TRUE
			// Begin deployment
			to_chat(usr, "<span class='notice'>You begin deploying \the [src]...</span>")
			extractor_state = EXTRACTOR_STATE_DEPLOYING
			flick(base_icon_state + "-deploy", src)
			finish_deployment()
			return TRUE

		if("undeploy")
			if(extractor_state == EXTRACTOR_STATE_WARMUP || extractor_state == EXTRACTOR_STATE_EXTRACTING)
				active = FALSE
				extracting = FALSE
				extractor_state = EXTRACTOR_STATE_UNDEPLOYED
				deployed = FALSE
				warmup_ticks = 0
				warned_low_reserves = FALSE
				warned_low_stability = FALSE
				to_chat(usr, "<span class='notice'>You shut down \the [src].</span>")
				overlays.Cut()
				flick(base_icon_state + "-undeploy", src)
				update_icon()
				return TRUE

	return FALSE

/obj/machinery/gas_extractor/proc/finish_deployment()
	deployed = TRUE
	active = TRUE
	extractor_state = EXTRACTOR_STATE_WARMUP
	warmup_ticks = 0
	warned_low_reserves = FALSE
	warned_low_stability = FALSE
	update_icon()
	visible_message("<span class='notice'>\The [src] deploys and begins warming up.</span>")

/obj/machinery/gas_extractor/proc/find_vent()
	var/turf/T = get_turf(src)
	if(!T)
		return null
	// Search for a vent datum at this location
	for(var/datum/vent/V in gas_vents)
		var/turf/vent_turf = V.turf_ref?.get()
		if(vent_turf == T)
			return V
	return null

// Multitool linking - buffer this extractor so it can be linked to a surface miner
/obj/machinery/gas_extractor/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat = ""
	if(linked_miner_ref?.get())
		var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
		dat += "<b>Linked to:</b> [M.name] at ([M.x], [M.y], [M.z]) <a href='?src=\ref[src];unlink=1'>\[X\]</a><br>"
	else
		dat += "<b>Not linked to any receiver.</b><br>"
		dat += "<i>Buffer this extractor, then link it from a Surface Gas Receiver's multitool menu.</i><br>"
	return dat

/obj/machinery/gas_extractor/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if("unlink" in href_list)
		if(linked_miner_ref)
			var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
			if(M)
				M.unlink_extractor(src)
			else
				linked_miner_ref = null
			to_chat(usr, "<span class='notice'>Unlinked from station receiver.</span>")
		update_multitool_menu(usr)

/obj/machinery/gas_extractor/process()
	if(stat & BROKEN)
		return

	if(!anchored || !deployed)
		return

	// Check if we still have a valid miner link
	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	if(!M)
		if(extracting)
			extracting = FALSE
			update_icon()
		return

	// Check if miner has power
	if(M.stat & NOPOWER)
		if(extracting)
			extracting = FALSE
			update_icon()
		return

	switch(extractor_state)
		if(EXTRACTOR_STATE_WARMUP)
			// Consume warmup power via the miner
			M.use_power(500)
			warmup_ticks++
			if(warmup_ticks >= warmup_ticks_required)
				extractor_state = EXTRACTOR_STATE_EXTRACTING
				extracting = TRUE
				visible_message("<span class='notice'>\The [src] finishes warming up and begins extraction.</span>")
				update_icon()

		if(EXTRACTOR_STATE_EXTRACTING)
			if(!linked_vent)
				extracting = FALSE
				extractor_state = EXTRACTOR_STATE_WARMUP
				warmup_ticks = warmup_ticks_required
				update_icon()
				return

			// Calculate extraction based on miner's power usage
			var/power_factor = M.active_power_usage / M.base_power_usage
			var/mols_to_extract = extraction_rate * power_factor

			// Extract gas from vent (if any remains)
			if(linked_vent.mols > 0)
				if(linked_vent.mols >= mols_to_extract)
					linked_vent.mols -= mols_to_extract
				else
					mols_to_extract = linked_vent.mols
					linked_vent.mols = 0

			// Check for low reserves warning (25%)
			if(linked_vent.mols > 0 && linked_vent.mols < (linked_vent.initial_mols * 0.25))
				if(!warned_low_reserves)
					warned_low_reserves = TRUE
					playsound(src, 'sound/machines/warning-buzzer.ogg', 60, FALSE)
					visible_message("<span class='warning'>\The [src] emits a warning buzzer - vent reserves critically low!</span>")

			// Check stability
			// Degrade when vent is below 25% capacity, or double rate when completely empty
			if(linked_vent.mols <= 0)
				stability = max(0, stability - 2) // Double degradation when empty
			else if(linked_vent.mols < (linked_vent.initial_mols * 0.25))
				stability = max(0, stability - 1)

			// Stability warnings
			if(stability <= 50 && !warned_low_stability)
				warned_low_stability = TRUE
				playsound(src, 'sound/machines/warning.ogg', 70, FALSE)
				visible_message("<span class='boldwarning'>\The [src] emits an alarm - structural integrity at 50%!</span>")

			if(stability <= 25 && stability > 0)
				if(prob(10)) // Occasional warning
					visible_message("<span class='boldwarning'>\The [src] shudders violently! Structural integrity compromised!</span>")

			update_icon()

			// Check for explosion
			if(stability <= 0)
				explode()
				return

/obj/machinery/gas_extractor/proc/explode()
	visible_message("<span class='boldwarning'>\The [src] suffers a catastrophic structural failure!</span>")
	// Medium explosion
	explosion(get_turf(src), 0, 1, 3, 4)
	stat |= BROKEN
	extracting = FALSE
	active = FALSE
	extractor_state = EXTRACTOR_STATE_BROKEN
	update_icon()

/obj/machinery/gas_extractor/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
			else
				stat |= BROKEN
				update_icon()
		if(3)
			if(prob(25))
				stat |= BROKEN
				update_icon()


///////////////////////////////////
// Gas Extractor Control Console
///////////////////////////////////
// A console for monitoring and controlling surface gas extractors
// Allows remote monitoring of extractor status and control of gas production rates

/obj/machinery/computer/gas_extractor_console
	name = "gas extractor control console"
	desc = "A console for monitoring and controlling surface gas extractors. Links to a surface gas receiver to manage connected extractors."
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel1e"
	density = TRUE
	anchored = TRUE

	machine_flags = WRENCHMOVE | MULTITOOL_MENU

	use_auto_lights = TRUE
	light_range_on = 2
	light_power_on = 1
	light_color = LIGHT_COLOR_CYAN

	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 50
	active_power_usage = 200

	id_tag = "gas_extractor_console" // Required for multitool buffer

	var/datum/weakref/linked_miner_ref // Link to the surface gas miner

/obj/machinery/computer/gas_extractor_console/New()
	..()

/obj/machinery/computer/gas_extractor_console/initialize()
	..()
	// Auto-link to surface gas miners on the same z-level for premapped consoles
	if(!linked_miner_ref)
		for(var/obj/machinery/atmospherics/miner/surface/M in world)
			if(M.z == src.z)
				linked_miner_ref = makeweakref(M)
				break // Link to the first one found

/obj/machinery/computer/gas_extractor_console/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	// Disable console when unwrenched
	if(!anchored)
		stat |= FORCEDISABLE
	else
		stat &= ~FORCEDISABLE
	power_change(TRUE)
	update_icon()

/obj/machinery/computer/gas_extractor_console/Destroy()
	linked_miner_ref = null
	..()

/obj/machinery/computer/gas_extractor_console/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] must be anchored to function.</span>")
		return
	if(!Adjacent(user))
		to_chat(user, "<span class='warning'>You're too far away.</span>")
		return
	tgui_interact(user)

/obj/machinery/computer/gas_extractor_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasExtractorConsole", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/gas_extractor_console/ui_data(mob/user)
	var/list/data = list()

	// Check if we have a linked miner
	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	data["linked"] = M ? TRUE : FALSE
	data["broken"] = (stat & BROKEN) ? TRUE : FALSE

	if(!M)
		return data

	// Get miner status
	data["miner_on"] = M.on
	data["miner_power"] = M.active_power_usage
	data["miner_base_power"] = M.base_power_usage

	// Get gas production rates - calculate per gas type
	var/list/gas_rates = list()
	if(M.gases && M.gases.len > 0)
		for(var/gas_id in M.gases)
			var/datum/gas/gas_datum = XGM.gases[gas_id]
			if(!gas_datum)
				continue

			// Calculate moles per second for this gas type
			// M.rate is total moles per tick (2 seconds)
			// M.gases[gas_id] is the ratio of this gas
			var/gas_mols_per_tick = M.rate * M.gases[gas_id]
			var/gas_mols_per_second = gas_mols_per_tick / 2

			gas_rates += list(list(
				"name" = gas_datum.name,
				"id" = gas_id,
				"rate" = round(gas_mols_per_second, 0.01)
			))
	data["gas_rates"] = gas_rates

	// Get total production rate
	data["total_rate"] = M.rate ? round(M.rate / 2, 0.01) : 0 // Convert from per-tick to per-second

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

/obj/machinery/computer/gas_extractor_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
			// Reasonable limits
			if(new_power > 50000)
				to_chat(usr, "<span class='warning'>Power draw cannot exceed 50kW for safety reasons.</span>")
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
				to_chat(usr, "<span class='warning'>Power draw cannot exceed 50kW for safety reasons.</span>")
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

				// Toggle the extractor
				if(!E.deployed && !E.active)
					// Try to deploy
					if(!E.anchored)
						to_chat(usr, "<span class='warning'>\The [E] must be bolted down first.</span>")
						return FALSE
					if(E.stat & BROKEN)
						to_chat(usr, "<span class='warning'>\The [E] is broken!</span>")
						return FALSE
					if(E.extractor_state != 0) // EXTRACTOR_STATE_UNDEPLOYED
						return FALSE

					// Check for gas vent
					E.linked_vent = E.find_vent()
					if(!E.linked_vent)
						to_chat(usr, "<span class='warning'>No gas vent detected beneath \the [E]!</span>")
						return FALSE

					// Begin deployment
					E.extractor_state = 1 // EXTRACTOR_STATE_DEPLOYING
					flick(E.base_icon_state + "-deploy", E)
					E.finish_deployment()
					return TRUE

				else if(E.deployed || E.active)
					// Shutdown
					if(E.extractor_state == 2 || E.extractor_state == 3) // WARMUP or EXTRACTING
						E.active = FALSE
						E.extracting = FALSE
						E.extractor_state = 0 // EXTRACTOR_STATE_UNDEPLOYED
						E.deployed = FALSE
						E.warmup_ticks = 0
						E.warned_low_reserves = FALSE
						E.warned_low_stability = FALSE
						flick(E.base_icon_state + "-undeploy", E)
						E.update_icon()
						return TRUE

	return FALSE

// Multitool linking interface
/obj/machinery/computer/gas_extractor_console/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
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
			else
				dat += "<i>Buffer a Surface Gas Receiver to link it to this console.</i><br>"
		else
			dat += "<i>Buffer a Surface Gas Receiver to link it to this console.</i><br>"
	return dat

/obj/machinery/computer/gas_extractor_console/Topic(href, href_list)
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

/obj/machinery/computer/gas_extractor_console/canLink(var/obj/O, var/list/context)
	return istype(O, /obj/machinery/atmospherics/miner/surface)

/obj/machinery/computer/gas_extractor_console/isLinkedWith(var/obj/O)
	return linked_miner_ref?.get() == O

/obj/machinery/computer/gas_extractor_console/linkWith(var/mob/user, var/obj/machinery/atmospherics/miner/surface/O, var/list/context)
	if(!istype(O))
		return FALSE
	linked_miner_ref = makeweakref(O)
	return TRUE

/obj/machinery/computer/gas_extractor_console/getLink(var/idx)
	if(idx == 1)
		return linked_miner_ref?.get()
	return null

/obj/machinery/computer/gas_extractor_console/unlinkFrom(var/mob/user, var/obj/buffer)
	if(linked_miner_ref?.get() == buffer)
		linked_miner_ref = null
		return TRUE
	return FALSE

#undef EXTRACTOR_STATE_UNDEPLOYED
#undef EXTRACTOR_STATE_DEPLOYING
#undef EXTRACTOR_STATE_WARMUP
#undef EXTRACTOR_STATE_EXTRACTING
#undef EXTRACTOR_STATE_BROKEN
