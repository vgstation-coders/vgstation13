//Listen here you god damn piece of shit. Do not add magazines for strong calibers.
//Dont fucking do it. If you do you're gonna gunk the vector to high heaven again and someone's gonna get mad that they got one hit and grudgecode
//So dont fucking do it

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe
	name = "\improper Ammolathe"
	desc = "Produces guns, ammunition, and firearm accessories."
	icon_state = "ammolathe"
	icon_state_open = "ammolathe_t"
	nano_file = "ammolathe.tmpl"

	default_mat_overlays = TRUE
	//build_time = 0.5
	light_color = LIGHT_COLOR_RED

	allowed_materials = list()
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | MULTIOUTPUT //| EMAGGABLE
	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER | LOCKBOXES | FAB_RECYCLER

	one_part_set_only = 0
	part_sets = list(
		"Weapons"=list(
		new /obj/item/weapon/gun/projectile/glock/lockbox(), \
		new /obj/item/weapon/gun/energy/laser/liberator(), \
		new /obj/item/weapon/gun/projectile/automatic/vector/lockbox(), \
		new /obj/item/weapon/gun/projectile/shotgun/pump(), \
		new /obj/item/weapon/gun/projectile/rocketlauncher/nanotrasen/lockbox(), \
		),
		"Single_ammunition"=list(
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/rocket_rpg/lowyield(),\
		new /obj/item/ammo_casing/rocket_rpg/blank(),\
		new /obj/item/ammo_casing/rocket_rpg/emp(),\
		new /obj/item/ammo_casing/rocket_rpg/stun(),\
		),
		"Box_ammunition"=list(
		new /obj/item/ammo_storage/box/b380auto(), \
		new /obj/item/ammo_storage/box/b380auto/practice(), \
		new /obj/item/ammo_storage/box/b380auto/rubber(), \
		new /obj/item/ammo_storage/box/c9mm(), \
		new /obj/item/ammo_storage/box/c38(), \
		new /obj/item/ammo_storage/box/a357(), \
		new /obj/item/ammo_storage/box/c12mm/assault(), \
		new /obj/item/ammo_storage/box/c45(), \
		new /obj/item/ammo_storage/box/c45/practice(), \
		new /obj/item/ammo_storage/box/c45/rubber(), \
		new /obj/item/ammo_storage/box/a50(), \
		new /obj/item/weapon/storage/box/lethalshells(), \
		new /obj/item/weapon/storage/box/buckshotshells(), \
		new /obj/item/weapon/storage/box/beanbagshells(), \
		new /obj/item/weapon/storage/box/stunshells(), \
		new /obj/item/weapon/storage/box/dartshells(), \
		new /obj/item/ammo_storage/box/flare(), \
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
		new /obj/item/ammo_storage/magazine/a12ga/empty(), \
		),
		"Misc_Other"=list(
		new /obj/item/ammo_storage/speedloader/c38/empty(), \
		new /obj/item/ammo_storage/speedloader/shotgun(), \
		new /obj/item/gun_part/scope(), \
		),
		"Hidden_Items" = list(
		new /obj/item/ammo_storage/speedloader/a357/empty(), \
		new /obj/item/ammo_storage/speedloader/a762x55/empty(), \
		new /obj/item/ammo_storage/box/b762x55(), \
		new /obj/item/ammo_storage/box/c762x38r(), \
		new /obj/item/ammo_storage/magazine/a762/empty(), \
		new /obj/item/ammo_storage/box/a762(), \
		new /obj/item/ammo_storage/magazine/a12mm/ops/empty(), \
		new /obj/item/ammo_storage/magazine/a75/empty(), \
		new /obj/item/ammo_storage/box/a75(), \
		new /obj/item/ammo_casing/shotgun/dragonsbreath(), \
		new /obj/item/weapon/storage/box/dragonsbreathshells(), \
		)
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


