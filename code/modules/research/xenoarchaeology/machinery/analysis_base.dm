/obj/machinery/anomaly
	name = "Analysis machine"
	desc = "A specialised, complex analysis machine."
	anchored = 1
	density = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser_old"

	idle_power_usage = 10
	active_power_usage = 1000

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/obj/item/weapon/reagent_containers/glass/held_container
	var/target_scan_ticks = 30
	var/report_num = 0
	// How far into a scan we are.
	// If it's zero we're not scanning.
	var/scan_process = 0

/obj/machinery/anomaly/Destroy()
	if (held_container)
		held_container.forceMove(loc)
		held_container = null
	..()

/obj/machinery/anomaly/RefreshParts()
	var/scancount = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SP in component_parts)
		scancount += SP.rating-1

	target_scan_ticks = initial(target_scan_ticks) - scancount*4

/obj/machinery/anomaly/power_change()
	..()
	if (stat & NOPOWER && scan_process)
		stop()
	else
		update_icon()

/obj/machinery/anomaly/process()
	//First we deal with the machine's task
	if(scan_process)
		if (stat & (NOPOWER|BROKEN))
			stop()
		else
			use_power = MACHINE_POWER_USE_ACTIVE
			if(scan_process++ > target_scan_ticks)
				FinishScan()

			//show we're busy if we're still going
			if(scan_process && prob(5))
				visible_message("<span class='notice'>[bicon(src)] [pick("whirrs","chuffs","clicks")][pick(" quietly"," softly"," sadly"," excitedly"," energetically"," angrily"," plaintively")].</span>")
	else
		use_power = MACHINE_POWER_USE_IDLE

	nanomanager.update_uis(src)

/obj/machinery/anomaly/attack_hand(var/mob/user)
	ui_interact(user)

obj/machinery/anomaly/attackby(obj/item/weapon/W, mob/living/user)
	if(istype(W, /obj/item/weapon/reagent_containers/glass))
		if(held_container)
			to_chat(user, "<span class='warning'>You must remove \the [held_container] first.</span>")
			return TRUE

		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You put \the [W] into the [src].</span>")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			held_container = W
			nanomanager.update_uis(src)

		return TRUE

	return ..()

/obj/machinery/anomaly/proc/ScanResults()
	// Override in children to produce unique scan behaviour.
	return "<span class='warning'>Error initialising scanning components.</span>"

/obj/machinery/anomaly/proc/FinishScan()
	stop()

	//determine the results and print a report
	if(held_container)
		alert_noise("ping")
		src.visible_message("<span class='notice'>[bicon(src)] makes an insistent chime.</span>", "You hear an insistent chime.")
		var/obj/item/weapon/paper/P = new(loc)
		P.name = "[src] report #[++report_num]"
		P.info = "<b>[src] analysis report #[report_num]</b><br><br>" + ScanResults()
		P.stamped = list(/obj/item/weapon/stamp)
		P.overlays += "paper_stamp-qm"
	else
		visible_message("<span class='notice'>[bicon(src)] makes a low buzzing noise.</span>", "You hear a low buzz.")

obj/machinery/anomaly/Topic(href, href_list)
	. = ..()
	if (.)
		return

	if (href_list["eject"] && held_container && !scan_process)
		eject(usr)
		. = 1

	if (href_list["begin"] && !scan_process && held_container)
		start(usr)
		. = 1

	if (href_list["stop"] && scan_process)
		stop()
		. = 1

/obj/machinery/anomaly/proc/eject(var/mob/user)
	held_container.forceMove(loc)
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	if (user && Adjacent(user))
		user.put_in_hands(held_container)
	held_container = null
	nanomanager.update_uis(src)

/obj/machinery/anomaly/proc/start(var/mob/user)
	scan_process = 1
	use_power = MACHINE_POWER_USE_ACTIVE
	update_icon()
	nanomanager.update_uis(src)

/obj/machinery/anomaly/proc/stop()
	scan_process = 0
	use_power = MACHINE_POWER_USE_IDLE
	update_icon()
	nanomanager.update_uis(src)

/obj/machinery/anomaly/update_icon()
	if (scan_process)
		icon_state = "analyser_old_processing"

	else
		icon_state = "analyser_old"


/obj/machinery/anomaly/AltClick(var/mob/user)
	if (user.incapacitated() || !user.Adjacent(src) || scan_process || !held_container || stat & NOPOWER)
		return

	eject(user)

/obj/machinery/anomaly/CtrlClick(var/mob/user)
	if (!anchored)
		return ..()

	if (user.incapacitated() || !user.Adjacent(src) || scan_process || !held_container || stat & NOPOWER)
		return

	start(user)


/obj/machinery/anomaly/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	if (stat & NOPOWER)
		return

	var/list/data[0]

	data["target_ticks"] = target_scan_ticks
	data["scan_process"] = scan_process

	data["beaker"] = !!held_container
	if (held_container)
		data["beaker_name"] = held_container.name
		var/list/beaker_contents[0]
		for(var/datum/reagent/R in held_container.reagents.reagent_list)
			beaker_contents[++beaker_contents.len] = list(
				"name" = R.name,
				"volume" = R.volume
			)

		data["beaker_contents"] = beaker_contents

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "xenoarch_analysis.tmpl", name, 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
