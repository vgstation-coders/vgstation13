#define ROSA_PANEL_GENRATE 500 // Flexible roll-out panels are less efficient than standard solar panels on a planetary surface
#define ROSA_PANEL_GENRATE_SPACE 1000 // More efficient in space with direct, unfiltered sunlight

var/list/obj/machinery/power/rosa/rosa_machines = list()

/obj/machinery/power/rosa
	name = "Roll Out Solar Array"
	desc = "A machine which dispenses a flexible solar array for energy collection. Requires a power terminal to output power."
	icon = 'icons/obj/power.dmi'
	icon_state = "rollerpanel"
	anchored = 1
	density = 1
	use_power = MACHINE_POWER_USE_NONE
	machine_flags = MULTITOOL_MENU
	starting_terminal = 1
	var/deployed = FALSE
	var/deploying = FALSE
	var/list/panels = list()
	var/frequency = 1449
	var/datum/radio_frequency/radio_connection

/obj/machinery/power/rosa/New()
	..()
	rosa_machines += src

/obj/machinery/power/rosa/initialize()
	..()
	if(!terminal)
		stat |= BROKEN
	if(radio_controller && frequency)
		set_frequency(frequency)

/obj/machinery/power/rosa/Destroy()
	for(var/obj/structure/rosa_panel/panel in panels)
		qdel(panel)
	panels.Cut()
	rosa_machines -= src
	if(radio_connection)
		radio_controller.remove_object(src, frequency)
	..()

/obj/machinery/power/rosa/proc/set_frequency(new_frequency)
	if(!radio_controller)
		return
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/power/rosa/receive_signal(datum/signal/signal)
	if(!signal || !id_tag)
		return
	if(signal.data["tag"] != id_tag)
		return
	switch(signal.data["command"])
		if("toggle")
			spawn()
				activate()
		if("status")
			send_status()

/obj/machinery/power/rosa/proc/send_status()
	if(radio_connection)
		var/datum/signal/signal = new /datum/signal
		signal.transmission_method = 1
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time
		signal.data["active"] = deployed ? 1 : 0
		radio_connection.post_signal(src, signal, range = 25, filter = RADIO_AIRLOCK)

/obj/machinery/power/rosa/process()
	if(!terminal)
		return
	if(!deployed || !panels.len)
		return
	var/datum/virtual_z/vz = get_virtual_z()
	var/vz_type = vz.level_type
	var/genrate = (vz_type == VZ_PLANET) ? ROSA_PANEL_GENRATE : ROSA_PANEL_GENRATE_SPACE
	var/total_power = 0
	for(var/obj/structure/rosa_panel/panel in panels)
		if(!QDELETED(panel))
			total_power += genrate
	if(total_power > 0)
		terminal.add_avail(total_power)

/obj/machinery/power/rosa/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil) && !terminal)
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 10)
			to_chat(user, "<span class='warning'>You need 10 lengths of cable to make a terminal.</span>")
			return
		if(make_terminal(user))
			CC.use(10)
			terminal.connect_to_network()
			to_chat(user, "<span class='notice'>You connect \the [src] to the power network.</span>")
			stat &= ~BROKEN
		return
	if(W.is_wirecutter(user) && terminal)
		var/turf/T = get_turf(terminal)
		if(T.intact)
			to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
			return
		to_chat(user, "<span class='notice'>You begin to cut the terminal...</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 50) && terminal && !T.intact)
			if(prob(50) && electrocute_mob(user, terminal.get_powernet(), terminal))
				spark(src, 5)
				return
			new /obj/item/stack/cable_coil(get_turf(src), 10)
			to_chat(user, "<span class='notice'>You cut the terminal from \the [src].</span>")
			QDEL_NULL(terminal)
		return
	..()

/obj/machinery/power/rosa/examine(mob/user)
	..()
	if(terminal)
		to_chat(user, "<span class='notice'>It has a power terminal connected.</span>")
	else
		to_chat(user, "<span class='warning'>It is missing a power terminal. Use cable coil to connect one.</span>")
	if(deployed)
		to_chat(user, "<span class='notice'>It has [panels.len] panel\s deployed.</span>")

/obj/machinery/power/rosa/proc/activate()
	if(deploying)
		return
	if(deployed)
		retract()
	else
		deploy()

/obj/machinery/power/rosa/proc/deploy()
	deploying = TRUE
	flick("rollerpanel-open", src)
	sleep(7)
	flick("rollerpanel-deploy", src)
	sleep(3)
	spawn(20)
		icon_state = "rollerpanel-deployed"
	var/turf/current = get_turf(src)
	for(var/i = 1 to 4)
		current = get_step(current, dir)
		if(current.density)
			break
		if(locate(/obj/structure/rosa_panel) in current)
			break
		var/obj/structure/rosa_panel/panel = new(current)
		panel.parent_rosa = src
		panels += panel
		panel.dir = dir
		flick("solarpanel-deploy", panel)
		sleep(8)
	deployed = TRUE
	deploying = FALSE
	send_status()

/obj/machinery/power/rosa/proc/force_retract()
	deploying = FALSE
	for(var/obj/structure/rosa_panel/panel in panels)
		qdel(panel)
	panels.Cut()
	icon_state = "rollerpanel"
	deployed = FALSE
	send_status()

/obj/machinery/power/rosa/proc/retract()
	deploying = TRUE
	for(var/i = panels.len to 1 step -1)
		var/obj/structure/rosa_panel/panel = panels[i]
		if(!QDELETED(panel))
			flick("solarpanel-retract", panel)
			sleep(5)
			qdel(panel)
	panels.Cut()
	icon_state = "rollerpanel"
	deployed = FALSE
	deploying = FALSE
	send_status()

/obj/structure/rosa_panel
	name = "solar panel"
	desc = "A flexible roll-out solar panel."
	icon = 'icons/turf/floors.dmi'
	icon_state = "solarpanel"
	anchored = 1
	density = 0
	var/obj/machinery/power/rosa/parent_rosa

/obj/structure/rosa_panel/Destroy()
	if(parent_rosa)
		parent_rosa.panels -= src
		parent_rosa = null
	..()
