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
	var hunting_rifle = null //to prevent multiple instances of one design

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK //| EMAGGABLE
	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER | LOCKBOXES

	one_part_set_only = 0
	part_sets = list(
		"Weapons"=list(
		new /obj/item/weapon/gun/projectile/glock/lockbox(), \
		new /obj/item/weapon/gun/projectile/automatic/vector/lockbox(), \
		new /obj/item/weapon/gun/projectile/shotgun/pump(), \
		//new /obj/item/weapon/gun/projectile/hecate/hunting(), \/
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
		//new /obj/item/ammo_storage/box/dot308(), \/
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
		new /obj/item/gun_part/extended_mag(), \
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

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe/attackby(var/obj/item/A as obj, mob/user as mob)
	if(..())
		return 1
	else if(istype(A, /obj/item/weapon/disk/design_disk/hunting_rifle_license))
		if(hunting_rifle)
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"[A] was processed before.\" ")
		else if(user.drop_item(A, src))
			//part_sets["Weapons"] += new /obj/item/weapon/gun/projectile/hecate/hunting() //it doesn't work, add designs directly
			part_sets["Weapons"] += new /datum/design/hunting_rifle
			part_sets["Box_ammunition"] += new /datum/design/ammo_308
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"[A] processed. Updating available schematics list.\" ")
			hunting_rifle = A
