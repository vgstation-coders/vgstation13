/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

#define MECH_SCREEN_MAIN		1
#define	MECH_SCREEN_QUEUE		2

#define	MECH_SCREEN_ROBOT		3
#define	MECH_SCREEN_RIPLEY		4
#define	MECH_SCREEN_ODYSSEUS	5
#define	MECH_SCREEN_GYGAX		6
#define	MECH_SCREEN_DURAND		7
#define	MECH_SCREEN_HONK		8
#define	MECH_SCREEN_PHAZON		9

#define	MECH_SCREEN_EXOSUIT		10
#define	MECH_SCREEN_UPGRADE		11
#define	MECH_SCREEN_SPACE_POD	12
#define	MECH_SCREEN_MISC		13
#define MECH_SCREEN_ROBOT		16

#define MECH_BUILD_TIME 1

/obj/machinery/r_n_d/fabricator/mech
	name = "Exosuit Fabricator"
	desc = "A specialised fabricator for robotic and mechatronic components."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"
	req_one_access = list(access_robotics)

	research_flags = NANOTOUCH | HASOUTPUT | HASMAT_OVER | TAKESMATIN | ACCESS_EMAG | LOCKBOXES

	nano_file = "exofab.tmpl"

	build_time = MECH_BUILD_TIME
	build_number = 16

	screen = MECH_SCREEN_MAIN

/obj/machinery/r_n_d/fabricator/mech/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/mechfab,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()