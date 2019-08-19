/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe
	name = "\improper Ammolathe"
	desc = "Produces guns, ammunition, and firearm accessories."
	icon_state = "ammolathe"
	icon_state_open = "ammolathe_t"
	nano_file = "ammolathe.tmpl"

	default_mat_overlays = TRUE
	//build_time = 0.5
	allowed_materials = 0 //A 0 or FALSE Allows all materials.
	light_color = LIGHT_COLOR_RED

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK //| EMAGGABLE
	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER | LOCKBOXES

	one_part_set_only = 0
	part_sets = list(
		"Weapons"=list(
		new /obj/item/weapon/gun/projectile/glock/lockbox(), \
		new /obj/item/weapon/gun/projectile/automatic/vector/lockbox(), \
		new /obj/item/weapon/gun/projectile/rocketlauncher/nanotrasen/lockbox(), \
		),
		"Single_ammunition"=list(
		new /obj/item/ammo_casing/shotgun/flare(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_casing/shotgun/stunshell(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/buckshot(),\
		new /obj/item/ammo_casing/rocket_rpg/lowyield(),\
		new /obj/item/ammo_casing/rocket_rpg/blank(),\
		new /obj/item/ammo_casing/rocket_rpg/emp(),\
		new /obj/item/ammo_casing/rocket_rpg/stun(),\
		),
		"Box_ammunition"=list(
		new /obj/item/ammo_storage/box/b380auto(), \
		new /obj/item/ammo_storage/box/b380auto/practice(), \
		new /obj/item/ammo_storage/box/b380auto/rubber(), \
		),
		"Magazines"=list(
		new /obj/item/ammo_storage/magazine/smg9mm/empty(), \
		new /obj/item/ammo_storage/magazine/beretta/empty(), \
		new /obj/item/ammo_storage/magazine/a12mm/empty(), \
		new /obj/item/ammo_storage/magazine/a357/empty(),\
		new /obj/item/ammo_storage/magazine/m380auto/empty(), \
		new /obj/item/ammo_storage/magazine/m380auto/extended/empty(), \
		new /obj/item/ammo_storage/magazine/c45/empty(), \
		new /obj/item/ammo_storage/magazine/uzi45/empty(), \
		new /obj/item/ammo_storage/magazine/a50/empty(), \
		new /obj/item/ammo_storage/magazine/a75/empty(), \
		new /obj/item/ammo_storage/magazine/a762/empty(), \
		new /obj/item/ammo_storage/magazine/a12ga/empty(), \
		),
		"Misc_Other"=list(
		new /obj/item/ammo_storage/speedloader/c38/empty(), \
		new /obj/item/ammo_storage/speedloader/a357/empty(), \
		new /obj/item/ammo_storage/speedloader/a762x55/empty(), \
		new /obj/item/ammo_storage/speedloader/shotgun(), \
		),
		"Hidden_Items" = list(
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(), \
		new /obj/item/weapon/reagent_containers/syringe(), \
		) //Syringes and vials are technically an ammo.
	)

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/ammolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()
