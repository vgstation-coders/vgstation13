//Speedloaders function more like boxes than mags, in that they load bullets but aren't loaded themselves into guns
//A speedloader has no fumble, though. This allows you to load guns quickly.
//TODO: Add an antag speedloader item to the ammo bundle for the revolver

/obj/item/ammo_storage/speedloader
	exact = 0 //load anything in the class!

/obj/item/ammo_storage/speedloader/c38
	name = "speed loader (.38)"
	icon_state = "38"
	ammo_type = "/obj/item/ammo_casing/c38"
	max_ammo = 6
	multiple_sprites = 1