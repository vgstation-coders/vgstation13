/obj/machinery/computer/rust_core_monitor
	name = "R-UST Mk. 7 Tokamak Core Monitoring Computer"
	icon_state = "power"
	light_color = LIGHT_COLOR_YELLOW
	circuit = /obj/item/weapon/circuitboard/rust_core_monitor

	var/obj/machinery/power/rust_core/linked_core

/obj/machinery/computer/rust_core_monitor/New()
	..()


/obj/machinery/computer/rust_core_monitor/Destroy()
//	qdel(interface)
	..()

/obj/machinery/computer/rust_core_monitor/attack_hand(var/mob/user)
	. =..()
	if(.)
		user.unset_machine()
		return
	ui_interact(user)

/obj/machinery/computer/rust_core_monitor/process()
/*	buildui()
	for(var/client/C in interface.clients)
		if(C.mob && get_dist(C.mob.loc,src.loc)<=1)
			interface.show( interface._getClient(interface.clients[C]) ) //Shamefully stolen from the fission reactor UI
		else
			interface.hide(interface._getClient(interface.clients[C]))
*/
/obj/machinery/computer/rust_core_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	if(!user)
		return

	var/list/data = list("linked_core" = !!linked_core)
	if(linked_core)
		var/avail_power = linked_core.last_power_received
		var/power_color = (avail_power < linked_core.last_power_request ? "orange" : "green")
		var/field_status
		if(!linked_core.owned_field)
			field_status = 0
		else if (linked_core.field_strength < linked_core.targeted_field_strength)
			field_status = 1
		else
			field_status = 2
		var/field_colour
		var/field_string
		switch(field_status)
			if(0)
				field_colour = "red"
				field_string = "disabled"
			if(1)
				field_colour = "orange"
				field_string = "unstable"
			if(2)
				field_colour = "green"
				field_string = "enabled"
		data += list(
			"idtag" = linked_core.id_tag,
			"core_status" = check_core_status(),
			"power_color" = power_color,
			"power_available" = avail_power,
			"power_needed" = linked_core.last_power_request,
			"owned_field" = !!linked_core.owned_field,
			"field_color" = field_colour,
			"field_string" = field_string,
			"targeted_field_strength" = linked_core.targeted_field_strength,
			"field_frequency" = linked_core.field_frequency
			)
		if(linked_core.owned_field)
			data += list(
				"field_diameter" = linked_core.owned_field.size,
				"field_strength" = linked_core.owned_field.field_strength,
				"field_mega_energy" = linked_core.owned_field.mega_energy,
				"field_sub_mega_energy" = linked_core.owned_field.energy,
				"list_of_reagents" = list()
			)
			for(var/reagent in linked_core.owned_field.dormant_reactant_quantities)
				var/list/reactant_data = list(
					"key1" = reagent,
					"key2" = linked_core.owned_field.dormant_reactant_quantities[reagent]
				)
				data["list_of_reagents"] += list(reactant_data)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "r-ust_core_monitor.tmpl", name, 650, 500)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/*
/obj/machinery/computer/rust_core_monitor/proc/buildui(var/mob/user)
	. = {"<body scroll=auto>
		<div class='uiWrapper'>
			[name ? "<div class='uiTitleWrapper'><div><tt>[name]</tt></div></div>" : ""]
			<div class='uiContent'>"}
	if(linked_core)
		. += {"
			<b>Device ID tag:</b> [linked_core.id_tag]<br>
		"}
		if(!check_core_status())
			. += {"
			<b><span style='color: red'>ERROR: Device unresponsive</b><span>
			"}
		else
			var/avail_power = linked_core.last_power_received
			var/power_color = (avail_power < linked_core.last_power_request ? "orange" : "green")
			var/field_status
			if(!linked_core.owned_field)
				field_status = 0
			else if (linked_core.field_strength < linked_core.targeted_field_strength)
				field_status = 1
			else
				field_status = 2
			var/field_colour
			var/field_string
			switch(field_status)
				if(0)
					field_colour = "red"
					field_string = "disabled"
				if(1)
					field_colour = "orange"
					field_string = "unstable"
				if(2)
					field_colour = "green"
					field_string = "enabled"
			. += {"
			<b>Device power status: </b><span style='color: [power_color]'>[avail_power]/[linked_core.last_power_request] W</span><br>
			<b>Device field status: </b><span style='color: [field_colour]'>[field_string]</span><hr>
			<b>Targeted Field power density (W.m<sup>-3</sup>):</b> [linked_core.targeted_field_strength]<br>
			<b>Current Field power density (W.m<sup>-3</sup>):</b> [linked_core.field_strength]<br>
			<b>Field frequency (MHz):</b> [linked_core.field_frequency]<br>
			"}
			if(linked_core.owned_field)
				. += {"
			<b>Approximate field diameter (m):</b> [linked_core.owned_field.size]<br>
			<b>Field mega energy:</b> [linked_core.owned_field.mega_energy]<br>
			<b>Field sub-mega energy:</b> [linked_core.owned_field.energy]<hr>
			<b>Field dormant reagents:</b><br>
			<table>
				<tr>
					<th><b>Name</b></th>
					<th><b>Amount</b></th>
				</tr>
				"}
				for(var/reagent in linked_core.owned_field.dormant_reactant_quantities)
					. += {"
				<tr>
					<td>[reagent]</td>
					<td>[linked_core.owned_field.dormant_reactant_quantities[reagent]]</td>
				</tr>
					"}
			. += {"
			</table>
			"}
	else
		. += {"
			<span style='color: red'><b>No linked R-UST Mk. 7 pattern Electromagnetic Field Generator</b></span>
		"}
	. += {"

	"}
	interface.updateLayout(.)
*/
//Returns 1 if the linked core is accesible.
/obj/machinery/computer/rust_core_monitor/proc/check_core_status()
	if(!istype(linked_core))
		return

	if(linked_core.stat & BROKEN)
		return

	if(!linked_core.powered)
		return

	. = 1

//Multitool menu shit.
/obj/machinery/computer/rust_core_monitor/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	if(linked_core)
		. = {"
			<b>Linked R-UST Mk. 7 pattern Electromagnetic Field Generator:<br>
			[linked_core.id_tag] <a href='?src=\ref[src];unlink=1'>\[X\]</a></b>
		"}
	else
		. = {"
			<b>No Linked R-UST Mk. 7 pattern Electromagnetic Field Generator</b>
		"}

/obj/machinery/computer/rust_core_monitor/linkMenu(var/obj/machinery/power/rust_core/O)
	if(istype(O))
		. = "<a href='?src=\ref[src];link=1'>\[LINK\]</a> "

/obj/machinery/computer/rust_core_monitor/canLink(var/obj/machinery/power/rust_core/O, var/list/context)
	if(istype(O) && !linked_core)
		. = 1

/obj/machinery/computer/rust_core_monitor/isLinkedWith(var/obj/machinery/power/rust_core/O)
	. = (linked_core == O)

/obj/machinery/computer/rust_core_monitor/linkWith(var/mob/user, var/obj/machinery/power/rust_core/O, var/list/context)
	linked_core = O
	. = 1

/obj/machinery/computer/rust_core_monitor/getLink(var/idx)
	. = linked_core

/obj/machinery/computer/rust_core_monitor/unlinkFrom(var/mob/user, var/obj/buffer)
	linked_core = null
	. = 1
