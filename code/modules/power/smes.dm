// the SMES
// stores power

var/list/smes_list = list()

/obj/machinery/power/battery/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE
	power_priority = POWER_PRIORITY_SMES_RECHARGE
	machine_flags = SCREWTOGGLE | CROWDESTROY

	starting_terminal = 1

	hack_abilities = list(
		/datum/malfhack_ability/destroy_lights,
		/datum/malfhack_ability/oneuse/overload_loud,
	)

/obj/machinery/power/battery/smes/pristine
	charge = 0

/obj/machinery/power/battery/smes/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smes,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	smes_list |= src

	RefreshParts()

	if(ticker)
		initialize()


/obj/machinery/power/battery/smes/Destroy()
	smes_list -= src
	..()

/obj/machinery/power/battery/smes/initialize()
	..()
	connect_to_network()
	if(master_mode == "sandbox")
		infinite_power = TRUE
	spawn(5)
		if(!terminal)
			stat |= BROKEN

/obj/machinery/power/battery/smes/spawned_by_map_element()
	..()

	initialize()

/obj/machinery/power/battery/smes/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob) //these can only be moved by being reconstructed, solves having to remake the powernet.
	if(iscrowbar(W) && panel_open && terminal)
		to_chat(user, "<span class='warning'>You must first cut the terminal from the SMES!</span>")
		return 1
	if(..())
		return 1
	if(panel_open)
		if(istype(W, /obj/item/stack/cable_coil) && !terminal)
			var/obj/item/stack/cable_coil/CC = W

			if (CC.amount < 10)
				to_chat(user, "<span class=\"warning\">You need 10 length cable coil to make a terminal.</span>")
				return

			if(make_terminal(user))
				CC.use(10)
				terminal.connect_to_network()

				user.visible_message(\
					"<span class='warning'>[user.name] made a terminal for the SMES.</span>",\
					"You made a terminal for the SMES.")
				src.stat = 0
				return 1
		else if(W.is_wirecutter(user) && terminal)
			var/turf/T = get_turf(terminal)
			if(T.intact)
				to_chat(user, "<span class='warning'>You must remove the floor plating in front of the SMES first.</span>")
				return
			to_chat(user, "You begin to dismantle the SMES terminal...")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			if (do_after(user, src, 50) && panel_open && terminal && !T.intact)
				if (prob(50) && electrocute_mob(usr, terminal.get_powernet(), terminal))
					spark(src, 5)
					return
				new /obj/item/stack/cable_coil(get_turf(src), 10)
				user.visible_message(\
					"<span class='warning'>[user.name] cut the cables and dismantled the power terminal.</span>",\
					"You cut the cables and dismantle the power terminal.")
				QDEL_NULL(terminal)
		else
			user.set_machine(src)
			interact(user)
			return 1
	return

/obj/machinery/power/battery/smes/can_attach_terminal(mob/user)
	return ..(user) && panel_open

/obj/machinery/power/battery/smes/surplus()
	if(terminal)
		return terminal.surplus()
	return 0

/obj/machinery/power/battery/smes/add_load(var/amount, var/priority = power_priority)
	if(terminal)
		terminal.add_load(amount, priority)

/obj/machinery/power/battery/smes/get_satisfaction(var/priority = power_priority)
	if(terminal && terminal.get_powernet())
		return terminal.get_satisfaction(priority)
	else
		return 0

/obj/machinery/power/battery/smes/infinite
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

	infinite_power = 1

	mech_flags = MECH_SCAN_FAIL
