#define EXTRACTOR_STATE_UNDEPLOYED 0
#define EXTRACTOR_STATE_DEPLOYING 1
#define EXTRACTOR_STATE_WARMUP 2
#define EXTRACTOR_STATE_EXTRACTING 3
#define EXTRACTOR_STATE_BROKEN 4

/obj/item/weapon/circuitboard/gas_extractor
	name = "Circuit board (Gas Extractor)"
	desc = "A circuit board used to build a surface gas extractor."
	board_type = MACHINE
	build_path = /obj/machinery/gas_extractor
	origin_tech = Tc_BLUESPACE + "=2;" + Tc_ENGINEERING + "=2" + Tc_EXPLORATION + "=1"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/subspace/transmitter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

// Used to extract gasses from planetary gas vents. Use with a surface gas miner on the station.
/obj/machinery/gas_extractor
	name = "\improper Surface Gas Extractor"
	desc = "A drilling rig designed to extract gasses from planetary vents. Sends gasses to a linked Surface Gas Receiver on the station using Bluespace technology."
	icon = 'icons/obj/machines/drill.dmi'
	icon_state = "deep_core_drill"
	var/base_icon_state = "deep_core_drill"
	var/icon/beam_overlay
	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU
	power_channel = ENVIRON
	use_power = MACHINE_POWER_USE_NONE
	density = TRUE
	plane = ABOVE_HUMAN_PLANE
	layer = CLOSED_CURTAIN_LAYER

	id_tag = "gas_extractor"

	var/extractor_state = EXTRACTOR_STATE_UNDEPLOYED
	var/deployed = FALSE
	var/active = FALSE
	var/extracting = FALSE
	var/stability = 100
	var/max_stability = 100

	var/datum/weakref/linked_miner_ref
	var/datum/vent/linked_vent
	var/mols_extracted = 0 //mols extracted last tick

	var/warmup_ticks = 0
	var/warmup_ticks_required = 5

	var/extraction_rate = 1

	// warning flags
	var/warned_low_reserves = FALSE
	var/warned_low_stability = FALSE

/obj/machinery/gas_extractor/New()
	..()
	beam_overlay = image(icon, icon_state = "mining_beam")

/obj/machinery/gas_extractor/Destroy()
	beam_overlay = null
	if(linked_miner_ref)
		var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
		if(M)
			M.unlinkFrom(buffer = src)
		linked_miner_ref = null
	linked_vent = null
	..()

/obj/machinery/gas_extractor/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>\The [src] is broken.</span>")
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
		to_chat(user, "<span class='boldwarning'>WARNING: Stability critical! Vent collapse imminent!</span>")

	if(linked_miner_ref?.get())
		to_chat(user, "<span class='info'>Linked to station receiver.</span>")
	else
		to_chat(user, "<span class='warning'>Not linked to any station receiver.</span>")

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
	var/datum/vent/V = find_vent()
	if(!V)
		return
	if(anchored)
		var/turf/T = V.turf_ref?.get()
		T.remove_particles(PS_GAS_VENT)
	else
		var/turf/T = V.turf_ref?.get()
		T.add_particles(PS_GAS_VENT)

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

	// Basic info
	data["anchored"] = anchored
	data["broken"] = (stat & BROKEN) ? TRUE : FALSE
	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	data["linked"] = M ? TRUE : FALSE

	// States
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

	// Deployment
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

	// Misc
	data["warmup_progress"] = warmup_ticks_required > 0 ? round((warmup_ticks / warmup_ticks_required) * 100) : 0
	data["extracting"] = extracting
	data["extraction_rate"] = extraction_rate / 2

	// Gas types
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

	// Damage & stability
	data["damage_threshold"] = 25
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
			if(!linked_miner_ref?.get())
				to_chat(usr, "<span class='warning'>\The [src] is not linked to a station receiver!</span>")
				return TRUE
			linked_vent = find_vent()
			if(!linked_vent)
				to_chat(usr, "<span class='warning'>No gas vent detected beneath \the [src]!</span>")
				return TRUE
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
		return
	for(var/datum/vent/V in gas_vents)
		var/turf/vent_turf = V.turf_ref?.get()
		if(vent_turf == T)
			return V

/obj/machinery/gas_extractor/canLink(var/obj/O, var/list/context)
	return istype(O, /obj/machinery/atmospherics/miner/surface)

/obj/machinery/gas_extractor/isLinkedWith(var/obj/O)
	return linked_miner_ref?.get() == O

/obj/machinery/gas_extractor/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(istype(O, /obj/machinery/atmospherics/miner/surface))
		var/obj/machinery/atmospherics/miner/surface/M = O
		if(linked_miner_ref)
			var/obj/machinery/atmospherics/miner/surface/old_miner = linked_miner_ref.get()
			if(old_miner)
				old_miner.unlinkFrom(user, src)
		linked_miner_ref = makeweakref(M)
		var/found = FALSE
		for(var/datum/weakref/ref in M.linked_extractors)
			if(ref.get() == src)
				found = TRUE
				break
		if(!found)
			M.linked_extractors += makeweakref(src)
		return TRUE
	return FALSE

/obj/machinery/gas_extractor/getLink(var/idx)
	if(idx == 1)
		return linked_miner_ref?.get()

/obj/machinery/gas_extractor/unlinkFrom(var/mob/user, var/obj/buffer)
	if(istype(buffer, /obj/machinery/atmospherics/miner/surface))
		if(linked_miner_ref?.get() == buffer)
			linked_miner_ref = null
			return TRUE
	return FALSE

/obj/machinery/gas_extractor/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat = "<b>Linked Surface Gas Receivers:</b><br><ul>"
	if(linked_miner_ref?.get())
		var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
		dat += "[M.name] at ([M.x], [M.y], [M.z]) <a href='?src=\ref[src];unlink=1'>\[X\]</a><br>"
	return dat

/obj/machinery/gas_extractor/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if("link" in href_list)
		var/obj/item/device/multitool/P = usr.get_active_hand()
		if(!istype(P))
			return
		var/obj/machinery/atmospherics/miner/surface/M = P.buffer?.get()
		if(istype(M))
			linkWith(usr, M)
			to_chat(usr, "<span class='notice'>Linked to [M.name].</span>")
		update_multitool_menu(usr)
		return

	if("unlink" in href_list)
		if(linked_miner_ref)
			var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref.get()
			if(M)
				M.unlinkFrom(buffer = src)
			else
				linked_miner_ref = null
			to_chat(usr, "<span class='notice'>Unlinked from station receiver.</span>")
		update_multitool_menu(usr)

/obj/machinery/gas_extractor/process()
	if(stat & BROKEN)
		return

	if(!anchored || !deployed)
		return

	var/obj/machinery/atmospherics/miner/surface/M = linked_miner_ref?.get()
	if(!M)
		if(extracting)
			extracting = FALSE
			update_icon()
		return

	if(M.stat & NOPOWER)
		if(extracting)
			extracting = FALSE
			update_icon()
		return

	switch(extractor_state)
		if(EXTRACTOR_STATE_WARMUP)
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

			var/power_factor = M.active_power_usage / M.base_power_usage
			mols_extracted = extraction_rate * power_factor

			if(linked_vent.mols > 0)
				if(linked_vent.mols >= mols_extracted)
					linked_vent.mols -= mols_extracted
				else
					mols_extracted = linked_vent.mols
					linked_vent.mols = 0

			if(linked_vent.mols > 0 && linked_vent.mols < (linked_vent.initial_mols * 0.25))
				if(!warned_low_reserves)
					warned_low_reserves = TRUE
					playsound(src, 'sound/machines/warning-buzzer.ogg', 60, FALSE)
					visible_message("<span class='warning'>\The [src] emits a warning buzzer - vent reserves critically low!</span>")

			if(linked_vent.mols <= 0)
				stability = max(0, stability - 2) // Double degradation when empty
			else if(linked_vent.mols < (linked_vent.initial_mols * 0.25))
				stability = max(0, stability - 1)

			if(stability <= 50 && !warned_low_stability)
				warned_low_stability = TRUE
				playsound(src, 'sound/machines/warning.ogg', 70, FALSE)
				visible_message("<span class='boldwarning'>\The [src] emits an alarm - vent integrity at 50%!</span>")

			if(stability <= 25 && stability > 0)
				if(prob(10)) // Occasional warning
					visible_message("<span class='boldwarning'>\The [src] shudders violently! Vent integrity compromised!</span>")

			update_icon()

			if(stability <= 0)
				explode()
				return

/obj/machinery/gas_extractor/proc/explode()
	visible_message("<span class='boldwarning'>\The [src] suffers a catastrophic structural failure!</span>")
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




#undef EXTRACTOR_STATE_UNDEPLOYED
#undef EXTRACTOR_STATE_DEPLOYING
#undef EXTRACTOR_STATE_WARMUP
#undef EXTRACTOR_STATE_EXTRACTING
#undef EXTRACTOR_STATE_BROKEN
