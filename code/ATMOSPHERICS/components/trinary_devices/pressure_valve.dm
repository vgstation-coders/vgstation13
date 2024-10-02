#define CVALVE_THRESHOLD_CONSTANT "CONSTANT"
#define CVALVE_THRESHOLD_LEFT "LEFT"
#define CVALVE_THRESHOLD_RIGHT "RIGHT"

#define CVALVE_INPUT_LEFT "LEFT"
#define CVALVE_INPUT_CENTER "CENTER"
#define CVALVE_INPUT_RIGHT "RIGHT"

#define CVALVE_MODE_PRESSURE "PRESSURE"
#define CVALVE_MODE_TEMPERATURE "TEMPERATURE"

//-------------------------
// Conditional valve
//-------------------------
// Allows gas to flow between the front and back inputs for as long as the control input's pressure, temperature, or whatever higher than
//  the configured threshold (or lower, if configured such).
// All inputs are eligible as control inputs (the side input can be useful in that it will not mix with the other two when the valve opens),
//  and the threshold may be read either from a constant value set by the player or from the front or back inputs.
// The mechanism is simple enough that the valve will keep opening and closing even if unpowered, but unless it's a
//  manual valve you won't be able to modify any settings until it's powered again
/obj/machinery/atmospherics/trinary/pressure_valve
	icon = 'icons/obj/atmospherics/pressure_valve.dmi'
	icon_state = "pvalve"
	var/icon_state_overlay_enabled = "pvalve_enabled"
	var/icon_state_overlay_open = "pvalve_open"
	var/icon_state_overlay_threshold_switch = "pvalve_switch"
	var/icon_state_overlay_mode = "pvalve_mode_"
	var/icon_state_overlay_left_pipe = "pvalve_switch_LEFT"
	var/icon_state_overlay_right_pipe = "pvalve_switch_RIGHT"

	name = "conditional valve"
	desc = "A warning label reads: \"Prototype. Do not use.\""

	var/open = FALSE

	var/enabled = FALSE // Safety override, will keep the valve closed until enabled

	var/mode = CVALVE_MODE_PRESSURE // Gas characteristic whose value will be measured and compared

	var/control_input = CVALVE_INPUT_CENTER // The pipe we will be reading a control value from
	var/threshold_source = CVALVE_THRESHOLD_CONSTANT // The threshold we will be checking our control value against. Can be `constant_threshold`, can be a value from some other pipe
	var/constant_threshold = 0 // Threshold above or below which the valve will stay open (if enabled)

	var/open_on_above_threshold = TRUE // If true, the valve will open on `control_input > threshold_source`. If false, it'll open on `control_input < threshold_source`

	var/list/mode2label = list(
		CVALVE_MODE_PRESSURE = "pressure",
		CVALVE_MODE_TEMPERATURE = "temperature"
	)

	var/list/mode2unit = list(
		CVALVE_MODE_PRESSURE = "kPA",
		CVALVE_MODE_TEMPERATURE = "K"
	)

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
						<b>Power</b>: <a href='?src=\ref[src];toggle_enabled=1'>[enabled ? "On" : "Off"]</a><br>

						<b>Condition</b>: Open if control value <a href='?src=\ref[src];toggle_condition=1'>[open_on_above_threshold ? "above" : "below"]</a> threshold value<br>

						<b>Mode</b>:<br>
						&nbsp;- <a href='?src=\ref[src];set_mode=[CVALVE_MODE_PRESSURE]'>[mode == CVALVE_MODE_PRESSURE ? "<b>PRESSURE</b>" : "Pressure"]</a><br>
						&nbsp;- <a href='?src=\ref[src];set_mode=[CVALVE_MODE_TEMPERATURE]'>[mode == CVALVE_MODE_TEMPERATURE ? "<b>TEMPERATURE</b>" : "Temperature"]</a><br>

						<hr>

						<b>Constant value:</b> [constant_threshold] [mode2unit[mode]] | <a href='?src=\ref[src];set_constant=1'>Change</a><br>

						<b>Control source</b>:<br>
						&nbsp;- <a href='?src=\ref[src];set_control=[CVALVE_INPUT_LEFT]'>[control_input == CVALVE_INPUT_LEFT ? "<b>[uppertext(dir2text(opposite_dirs[src.dir]))]</b>" : "[capitalize(dir2text(opposite_dirs[src.dir]))]"]</a><br>
						&nbsp;- <a href='?src=\ref[src];set_control=[CVALVE_INPUT_CENTER]'>[control_input == CVALVE_INPUT_CENTER ? "<b>[uppertext(dir2text(counterclockwise_perpendicular_dirs[src.dir]))]</b>" : "[capitalize(dir2text(counterclockwise_perpendicular_dirs[src.dir]))]"]</a><br>
						&nbsp;- <a href='?src=\ref[src];set_control=[CVALVE_INPUT_RIGHT]'>[control_input == CVALVE_INPUT_RIGHT ? "<b>[uppertext(dir2text(src.dir))]</b>" : "[capitalize(dir2text(src.dir))]"]</a><br>

						<b>Threshold source</b>:<br>
						&nbsp;- <a href='?src=\ref[src];set_threshold=[CVALVE_THRESHOLD_LEFT]'>[threshold_source == CVALVE_THRESHOLD_LEFT ? "<b>[uppertext(dir2text(opposite_dirs[src.dir]))]</b>" : "[capitalize(dir2text(opposite_dirs[src.dir]))]"]</a><br>
						&nbsp;- <a href='?src=\ref[src];set_threshold=[CVALVE_THRESHOLD_CONSTANT]'>[threshold_source == CVALVE_THRESHOLD_CONSTANT ? "<b>CONSTANT</b>" : "Constant"]</a><br>
						&nbsp;- <a href='?src=\ref[src];set_threshold=[CVALVE_THRESHOLD_RIGHT]'>[threshold_source == CVALVE_THRESHOLD_RIGHT ? "<b>[uppertext(dir2text(src.dir))]</b>" : "[capitalize(dir2text(src.dir))]"]</a><br>
					</tt>
				</body>
			"}

	user << browse(dat, "window=atmo_conditional_valve")
	onclose(user, "atmo_conditional_valve")
	return

/obj/machinery/atmospherics/trinary/pressure_valve/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["toggle_enabled"])
		toggle_enabled()

	if (href_list["toggle_condition"])
		open_on_above_threshold = !open_on_above_threshold

	if (href_list["set_mode"])
		mode = href_list["set_mode"]

	if (href_list["set_control"])
		control_input = href_list["set_control"]

	if (href_list["set_threshold"])
		threshold_source = href_list["set_threshold"]

	if(href_list["set_constant"])
		constant_threshold = input("Set threshold [mode2label[mode]], in [mode2unit[mode]].", "Threshold", constant_threshold) as num
		constant_threshold = max(0, constant_threshold)

	update_icon()
	updateUsrDialog()

	return

// NPCs and assorted gremlins
/obj/machinery/atmospherics/trinary/pressure_valve/npc_tamper_act(mob/living/L)
	switch(rand(0, 5))
		if(0)
			toggle_enabled()
			investigation_log(I_ATMOS,"was [(enabled ? "enabled" : "disabled")] by [key_name(L)]")
		if(1)
			open_on_above_threshold = !open_on_above_threshold
			investigation_log(I_ATMOS,"was switched to open if controls is [(open_on_above_threshold ? "ABOVE" : "BELOW")] the threshold by [key_name(L)]")
		if(2)
			mode = pick(CVALVE_MODE_PRESSURE, CVALVE_MODE_TEMPERATURE)
			investigation_log(I_ATMOS,"had it's compare mode set to [mode] by [key_name(L)]")
		if(3)
			mode = pick(CVALVE_INPUT_LEFT, CVALVE_INPUT_CENTER, CVALVE_INPUT_RIGHT)
			investigation_log(I_ATMOS,"had it's control pipe set to [control_input] by [key_name(L)]")
		if(4)
			mode = pick(CVALVE_THRESHOLD_LEFT, CVALVE_THRESHOLD_CONSTANT, CVALVE_THRESHOLD_RIGHT)
			investigation_log(I_ATMOS,"had it's threshold source set to [threshold_source] by [key_name(L)]")
		if(5)
			constant_threshold = rand(0, 9000)
			investigation_log(I_ATMOS,"had it's threshold constant set to [constant_threshold] by [key_name(L)]")
	investigation_log(I_ATMOS,"current configuration: open if [control_input] [mode] [(open_on_above_threshold ? "ABOVE" : "BELOW")] [threshold_source][threshold_source == CVALVE_THRESHOLD_CONSTANT ? "[constant_threshold][mode2unit[mode]]" : ""]")

	update_icon()

// --- Behaviour ---
/obj/machinery/atmospherics/trinary/pressure_valve/process()
	. = ..()
	if (!enabled)
		close()
		return

	var/input = 0
	var/threshold = 0
	switch(control_input)
		if (CVALVE_INPUT_LEFT)
			input = get_valve_mode_gas_value(pipe_flags & IS_MIRROR ? air3 : air1)
		if (CVALVE_INPUT_CENTER)
			input = get_valve_mode_gas_value(air2)
		if (CVALVE_INPUT_RIGHT)
			input = get_valve_mode_gas_value(pipe_flags & IS_MIRROR ? air1 : air3)
		else
			control_input = CVALVE_INPUT_CENTER
			input = get_valve_mode_gas_value(air2)

	switch(threshold_source)
		if (CVALVE_THRESHOLD_LEFT)
			threshold = get_valve_mode_gas_value(pipe_flags & IS_MIRROR ? air3 : air1)
		if (CVALVE_THRESHOLD_CONSTANT)
			threshold = constant_threshold
		if (CVALVE_THRESHOLD_RIGHT)
			threshold = get_valve_mode_gas_value(pipe_flags & IS_MIRROR ? air1 : air3)
		else
			threshold_source = CVALVE_INPUT_CENTER
			threshold = constant_threshold

	if (open_on_above_threshold && (input > threshold) || !open_on_above_threshold && (input < threshold))
		open()
	else
		close()

/obj/machinery/atmospherics/trinary/pressure_valve/proc/get_valve_mode_gas_value(datum/gas_mixture/air)
	switch(mode)
		if (CVALVE_MODE_PRESSURE)
			return air.pressure
		if (CVALVE_MODE_TEMPERATURE)
			return air.temperature
		else
			mode = CVALVE_MODE_PRESSURE
			return air.pressure

/obj/machinery/atmospherics/trinary/pressure_valve/proc/open()
	if(open)
		return
	open = TRUE
	update_icon()

	// Connect Left and Right
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

	// Disconnect Left and Right
	if(network1)
		qdel(network1)
	if(network3)
		qdel(network3)
	build_network()

/obj/machinery/atmospherics/trinary/pressure_valve/proc/toggle_enabled()
	enabled = !enabled
	if (!enabled) close()


/obj/machinery/atmospherics/trinary/pressure_valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	..()

	if(open)
		if(reference == node1)
			if(node3)
				return node3.network_expand(new_network, src)
		else if(reference == node3)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

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

	overlays += image(icon = icon, icon_state = icon_state_overlay_mode + mode)

	if(control_input == CVALVE_INPUT_LEFT || threshold_source == CVALVE_THRESHOLD_LEFT)
		overlays += image(icon = icon, icon_state = icon_state_overlay_left_pipe)

	if(control_input == CVALVE_INPUT_RIGHT || threshold_source == CVALVE_THRESHOLD_RIGHT)
		overlays += image(icon = icon, icon_state = icon_state_overlay_right_pipe)

	return

//-------------------------
// Manual conditional valves
//-------------------------
// Cannot be controlled by AI or borgs, completely unaffected by lack of power
/obj/machinery/atmospherics/trinary/pressure_valve/manual
	icon_state = "pvalve"
	icon_state_overlay_enabled = "pvalve_enabled"
	icon_state_overlay_open = "pvalve_open"
	icon_state_overlay_threshold_switch = "pvalve_switch"

	name = "conditional valve"
	desc = "An automatic valve."

	use_power = MACHINE_POWER_USE_NONE

/obj/machinery/atmospherics/trinary/pressure_valve/manual/attack_ai(mob/user)
	if(isMoMMI(user) && (user in (viewers(1, src) + loc))) // MoMMIs must be next to the valve to view and manipulate it
		attack_hand(user)
	return

/obj/machinery/atmospherics/trinary/pressure_valve/manual/attack_robot(mob/user)
	if(isMoMMI(user) && (user in (viewers(1, src) + loc))) // MoMMIs must be next to the valve to view and manipulate it
		attack_hand(user)
	return

/obj/machinery/atmospherics/trinary/pressure_valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	..()

	if(open)
		if(reference == node1)
			if(node3)
				return node3.network_expand(new_network, src)
		else if(reference == node3)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

//-------------------------
// Digital conditional valves
//-------------------------
// Radio enabled, aka: can be multitooled and connected to consoles
/obj/machinery/atmospherics/trinary/pressure_valve/digital
	icon_state = "pvalve_d"
	icon_state_overlay_enabled = "pvalve_d_enabled"
	icon_state_overlay_open = "pvalve_d_open"
	icon_state_overlay_threshold_switch = "pvalve_d_switch"
	icon_state_overlay_mode = "pvalve_d_mode_"
	icon_state_overlay_left_pipe = "pvalve_d_switch_LEFT"
	icon_state_overlay_right_pipe = "pvalve_d_switch_RIGHT"

	name = "digital conditional valve"
	desc = "A digitally controlled automatic valve."

	frequency = 0
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

/obj/machinery/atmospherics/trinary/pressure_valve/digital/set_frequency(new_frequency)
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
			update_icon()
