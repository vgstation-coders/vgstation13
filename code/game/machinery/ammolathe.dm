/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe
	name = "\improper Ammolathe"
	desc = "Produces guns, ammunition, and firearm accessories."
	icon_state = "autolathe"
	icon_state_open = "autolathe_t"
	nano_file = "ammolathe.tmpl"

	start_end_anims = 1

	build_time = 0.5

	allowed_materials = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK //| EMAGGABLE

	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER | LOCKBOXES

	light_color = LIGHT_COLOR_YELLOW

	one_part_set_only = 0
	part_sets = list(
		"Weapons"=list(
		new /obj/item/weapon/gun/projectile/automatic/vector/lockbox(), \
		),
		"Single_ammunition"=list(
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_casing/shotgun/flare(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		new /obj/item/ammo_casing/shotgun/buckshot(),\
		),
		"Box_ammunition"=list(
		new /obj/item/ammo_storage/box/b380auto(), \
		new /obj/item/ammo_storage/box/b380auto/practice(), \
		new /obj/item/ammo_storage/box/b380auto/rubber(), \
		),
		"Magazines"=list(
		new /obj/item/ammo_storage/magazine/smg9mm/empty(), \
		new /obj/item/ammo_storage/magazine/a12mm/empty(), \
		new /obj/item/ammo_storage/magazine/a357/empty(),\
		new /obj/item/ammo_storage/magazine/m380auto/empty(), \
		),
		"Misc_Other"=list(
		new /obj/item/ammo_storage/speedloader/c38/empty(), \
		new/obj/item/ammo_storage/speedloader/a357/empty(), \
		new/obj/item/ammo_storage/speedloader/a762x55/empty(), \
		new/obj/item/ammo_storage/speedloader/shotgun(), \
		),
		"Hidden_Items" = list(
		new /obj/item/toy/gasha/skub(), \
		)//TODO: Add shit here.
	)