/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.
*/

#define PROTOLATHE_BUILD_TIME	1

/obj/machinery/r_n_d/fabricator/protolathe
	name = "Protolathe"
	icon_state = "protolathe"
	desc = "A fabricator capable of producing prototypes from research schematics."
	flags = OPENCONTAINER

	start_end_anims = 1

	build_time = PROTOLATHE_BUILD_TIME
	build_number = 2

	light_color = LIGHT_COLOR_CYAN

	research_flags = CONSOLECONTROL | HASOUTPUT | TAKESMATIN | HASMAT_OVER | LOCKBOXES | MULTIOUTPUT

	part_sets = list(
		"Stock Parts" = list(),
		"Bluespace" = list(),
		"Anomaly" = list(),
		"Data" = list(),
		"Engineering" = list(),
		"Medical" = list(),
		"Surgery" = list(),
		"Mining" = list(),
		"Robotics" = list(),
		"Weapons" = list(),
		"Armor" = list(),
		"Misc" = list(),
		)

/obj/machinery/r_n_d/fabricator/protolathe/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		kill_light()

/obj/machinery/r_n_d/fabricator/protolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/protolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/protolathe/Destroy()
	if(linked_console && linked_console.linked_lathe == src)
		linked_console.linked_lathe = null

	. = ..()

/obj/machinery/r_n_d/fabricator/protolathe/setup_part_sets()
	return

/obj/machinery/r_n_d/fabricator/protolathe/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (O.is_open_container())
		return 1
