//-------------------------
// Pressure valve
//-------------------------
// Allows gas to flow between the front and back inputs for as long as the side input's pressure is higher than
//  the configured threshold (or lower, if configured such). The side input does not mix with the other two.
// The mechanism is simple enough that the valve will keep opening and closing even if unpowered, but unless it's a
//  manual valve you won't be able to modify any settings
/obj/machinery/atmospherics/trinary/pressure_valve
	icon = 'icons/obj/atmospherics/pressure_valve.dmi'
	icon_state = "pvalve"
	var/icon_state_overlay_enabled = "pvalve_enabled"
	var/icon_state_overlay_open = "pvalve_open"
	var/icon_state_overlay_threshold_switch = "pvalve_switch"

	name = "pressure valve"
	desc = "A warning label reads: \"Prototype. Do not use.\""

	var/open = FALSE

	var/pressure_threshold = 0 // Threshold above or below which the valve will stay open (if enabled)
	var/enabled = FALSE // Valve will stay closed and disregard pressure readings until enabled
	var/open_on_above_threshold = TRUE // If false, opens on pressure readings below threshold pressure instead

// --- Interaction and UI ---

/obj/machinery/atmospherics/trinary/pressure_valve/digital/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/trinary/pressure_valve/digital/attack_robot(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/trinary/pressure_valve/attack_hand(mob/user)
	if(..())
		return
	setup(user)

/obj/machinery/atmospherics/trinary/pressure_valve/proc/setup(mob/user)
	var/dat = {"
			<head>
				<title>[name] control</title>
			</head>
			<body>
				<tt>
					<b>Power:</b> <a href='?src=\ref[src];toggle_enabled=1'>[enabled ? "On" : "Off"]</a><br>
					<b>Mode:</b> Open <a href='?src=\ref[src];toggle_mode=1'>[open_on_above_threshold ? "above" : "below"]</a> threshold pressure<br>
					<b>Threshold pressure:</b> [pressure_threshold]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
				</tt>
			</body>
			"}

	user << browse(dat, "window=atmo_pressure_valve")
	onclose(user, "atmo_pressure_valve")
	return

/obj/machinery/atmospherics/trinary/pressure_valve/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["toggle_enabled"])
		toggle_enabled()

	if (href_list["toggle_mode"])
		open_on_above_threshold = !open_on_above_threshold

	if(href_list["set_press"])
		pressure_threshold = input(usr, "Enter new threshold pressure", "Pressure control", pressure_threshold) as num
		pressure_threshold = max(0, pressure_threshold)

	update_icon()
	updateUsrDialog()

	return

// NPCs and assorted gremlins
/obj/machinery/atmospherics/trinary/pressure_valve/npc_tamper_act(mob/living/L)
	if (prob(33))
		open_on_above_threshold = !open_on_above_threshold
		investigation_log(I_ATMOS,"was switched to open [(open_on_above_threshold ? "above" : "below")] [pressure_threshold]kPa by [key_name(L)]")

	else if (prob(33))
		pressure_threshold = rand(0, 9000)
		investigation_log(I_ATMOS,"had its threshold configured to open [(open_on_above_threshold ? "above" : "below")] [pressure_threshold]kPa by [key_name(L)]")

	else
		toggle_enabled()
		investigation_log(I_ATMOS,"was [(enabled ? "enabled" : "disabled")] by [key_name(L)]")

	update_icon()

// --- Behaviour ---

/obj/machinery/atmospherics/trinary/pressure_valve/process()
	. = ..()
	if (!enabled)
		close()
		return

	if (open_on_above_threshold && (air2.pressure > pressure_threshold) || !open_on_above_threshold && (air2.pressure < pressure_threshold))
		open()
	else
		close()

/obj/machinery/atmospherics/trinary/pressure_valve/proc/open()
	if(open)
		return
	open = TRUE
	update_icon()

	// Connect front and back inputs
	if(network1 && network3)
		network1.merge(network3)
		network3 = network1
	if(network1)
		network1.update = 1
	else if(network3)
		network3.update = 1

/obj/machinery/atmospherics/trinary/pressure_valve/proc/close()
	if(!open)
		return
	open = FALSE
	update_icon()

	// Disconnect front and back inputs
	if(network1)
		qdel(network1)
	if(network3)
		qdel(network3)
	build_network()

/obj/machinery/atmospherics/trinary/pressure_valve/proc/toggle_enabled()
	enabled = !enabled
	if (!enabled) close()

// --- Graphics ---

/obj/machinery/atmospherics/trinary/pressure_valve/update_icon()
	..()
	overlays.Cut()
	if(enabled)
		overlays += image(icon = icon, icon_state = icon_state_overlay_enabled)

	if(open)
		overlays += image(icon = icon, icon_state = icon_state_overlay_open)

	if(!open_on_above_threshold)
		overlays += image(icon = icon, icon_state = icon_state_overlay_threshold_switch)

	return

//-------------------------
// Manual pressure valves
//-------------------------
// Cannot be controlled by AI or borgs, completely unaffected by lack of power
/obj/machinery/atmospherics/trinary/pressure_valve/manual
	icon_state = "pvalve"
	icon_state_overlay_enabled = "pvalve_enabled"
	icon_state_overlay_open = "pvalve_open"
	icon_state_overlay_threshold_switch = "pvalve_switch"

	name = "pressure valve"
	desc = "A pressure activated valve."

	use_power = MACHINE_POWER_USE_NONE

/obj/machinery/atmospherics/trinary/pressure_valve/manual/attack_ai(mob/user)
	if(isMoMMI(user) && (user in (viewers(1, src) + loc))) // MoMMIs must be next to the valve to view and manipulate it
		attack_hand(user)
	return

/obj/machinery/atmospherics/trinary/pressure_valve/manual/attack_robot(mob/user)
	if(isMoMMI(user) && (user in (viewers(1, src) + loc))) // MoMMIs must be next to the valve to view and manipulate it
		attack_hand(user)
	return

//-------------------------
// Digital pressure valves
//-------------------------
// Radio enabled, aka: can be multitooled and connected to consoles
// TODO !JLVG Radio stuff
/obj/machinery/atmospherics/trinary/pressure_valve/digital
	icon_state = "pvalve_d"
	icon_state_overlay_enabled = "pvalve_d_enabled"
	icon_state_overlay_open = "pvalve_d_open"
	icon_state_overlay_threshold_switch = "pvalve_d_switch"

	name = "digital pressure valve"
	desc = "A digitally controlled, pressure activated valve."

	var/frequency = 0
	var/datum/radio_frequency/radio_connection
	machine_flags = MULTITOOL_MENU

// --- Radio ---
/obj/machinery/atmospherics/trinary/pressure_valve/digital/multitool_menu(mob/user, obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_tag")]</a></li>
	</ul>
	"}

/obj/machinery/atmospherics/trinary/pressure_valve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/pressure_valve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)


/obj/machinery/atmospherics/trinary/pressure_valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	switch(signal.data["command"])
		if("enable")
			enabled = signal.data["enable"]

		if("mode")
			open_on_above_threshold = signal.data["above"]
			pressure_threshold = max(0, signal.data["threshold"])
