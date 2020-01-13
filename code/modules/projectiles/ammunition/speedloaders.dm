//Speedloaders function more like boxes than mags, in that they load bullets but aren't loaded themselves into guns
//A speedloader has no fumble, though. This allows you to load guns quickly.
//TODO: Add an antag speedloader item to the ammo bundle for the revolver

/obj/item/ammo_storage/speedloader
	desc = "A speedloader, used to load a gun without any of that annoying fumbling."
	exact = 0 //load anything in the class!

/obj/item/ammo_storage/speedloader/c38
	name = "speed loader (.38)"
	icon_state = "38"
	ammo_type = "/obj/item/ammo_casing/c38"
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_storage/speedloader/c38/empty //this is what's printed by the autolathe, since the lathe also does boxes now
	starting_ammo = 0

/obj/item/ammo_storage/speedloader/a357 //now the traitors can do it too
	name = "speed loader (.357)"
	desc = "A speedloader, used to load a gun without any of that annoying fumbling. This one appears to have a small 'S' embossed on the side."
	icon_state = "s357"
	ammo_type = "/obj/item/ammo_casing/a357"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_storage/speedloader/a357/empty
	starting_ammo = 0

/obj/item/ammo_storage/speedloader/a762x55
	name = "clip (7.62x55mmR)"
	icon_state = "c762x55"
	ammo_type = "/obj/item/ammo_casing/a762x55"
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_storage/speedloader/a762x55/empty
	starting_ammo = 0

/obj/item/ammo_storage/speedloader/shotgun
	name = "double barreled shotgun speedloader"
	desc = "The instructions read 'Just break the shotgun open, stick the shells in, and break the clip off.'"
	icon_state = "shotgun_speedloader"
	caliber = GAUGE12
	exact = FALSE
	max_ammo = 2
	starting_ammo = 0

/obj/item/ammo_storage/speedloader/shotgun/loaded
	starting_ammo = 2

/obj/item/ammo_storage/speedloader/shotgun/update_icon()
	overlays.Cut()
	if(stored_ammo.len)
		var/count = 1
		for(var/obj/item/ammo_casing/shotgun/S in stored_ammo)
			var/pixelx = 0
			var/pixely = 0
			switch(count)
				if(1)
					count++
					pixelx = -10
				if(2)
					pixelx = -6
					pixely = -1
			var/image/shell_image = image("icon" = S.icon, "icon_state" = S.icon_state, "pixel_x" = pixelx, "pixel_y" = pixely)
			overlays += shell_image
