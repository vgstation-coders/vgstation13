/////////////////////////////
///// sec ammolathe   ///////
/////////////////////////////











#define AMMOLATHE_BUILD_TIME	1

/obj/machinery/r_n_d/fabricator/ammolathe
	name = "Ammunition Lathe"
	desc = "A specialised fabricator for ammunition."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"

	start_end_anims = 1

	build_time = AMMOLATHE_BUILD_TIME
	build_number = 256

	light_color = LIGHT_COLOR_CYAN

	research_flags = CONSOLECONTROL | HASOUTPUT | TAKESMATIN | HASMAT_OVER | LOCKBOXES

	part_sets = list(
		"shotgun" = list(),
		"standard" = list(),
		"exotic" = list(),
		"grenades" = list(),
		"miscammo" = list(),
		)

/obj/machinery/r_n_d/fabricator/ammolathe/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/r_n_d/fabricator/ammolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/ammolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/ammolathe/Destroy()
	if(linked_console && linked_console.linked_amlathe == src)
		linked_console.linked_amlathe = null

	. = ..()

/obj/machinery/r_n_d/fabricator/ammolathe/setup_part_sets()
	return

/obj/machinery/r_n_d/fabricator/ammolathe/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (O.is_open_container())
		return 1

































/* DELET THIS
#define AMLATHE_SCREEN_MAIN			1
#define	AMLATHE_SCREEN_QUEUE		2

#define	AMLATHE_SCREEN_SHOTGUN		3
#define	AMLATHE_SCREEN_STANDARD		4
#define	AMLATHE_SCREEN_EXOTIC		5
#define AMLATHE_SCREEN_GRENADE		6

#define	MECH_SCREEN_MISC		10

#define AMMOLATHE_BUILD_TIME 1

/obj/machinery/r_n_d/fabricator/ammolathe
	name = "Ammunition Lathe"
	desc = "A specialised fabricator for ammunition."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"


	research_flags = NANOTOUCH | HASOUTPUT | HASMAT_OVER | TAKESMATIN | ACCESS_EMAG | LOCKBOXES

	nano_file = "ammolathe.tmpl"

	max_material_storage = 937500
	build_time = MECH_BUILD_TIME
	build_number = 256

	screen = AMLATHE_SCREEN_MAIN

	part_sets = list(//set names must be unique
		"Shotgun" = list(
		/obj/item/weapon/storage/box/lethalshells
		),
		"Standard" = list(
		),
		"Exotic" = list(
		),
		"Grenade" = list(
		),
		"Misc" = list(
	)
)
/obj/machinery/r_n_d/fabricator/ammolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/ammolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()
*/