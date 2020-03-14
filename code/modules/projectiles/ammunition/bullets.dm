/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = POINT357
	projectile_type = "/obj/item/projectile/bullet"
	w_type = RECYK_METAL

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = POINT50
	projectile_type = "/obj/item/projectile/bullet"
	w_type = RECYK_METAL

/obj/item/ammo_casing/a418
	desc = "A .418 bullet casing."
	caliber = POINT357
	projectile_type = "/obj/item/projectile/bullet/suffocationbullet"
	w_type = RECYK_METAL


/obj/item/ammo_casing/a75
	desc = "A .75 bullet casing."
	caliber = POINT75
	projectile_type = "/obj/item/projectile/bullet/gyro"
	w_type = RECYK_METAL


/obj/item/ammo_casing/a666
	desc = "A .666 bullet casing."
	caliber = POINT357
	projectile_type = "/obj/item/projectile/bullet/cyanideround"
	w_type = RECYK_METAL


/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = POINT38
	projectile_type = "/obj/item/projectile/bullet/weakbullet"
	w_type = RECYK_METAL

/* Not entirely ready to be implemented yet. Get a server vote on bringing these in
/obj/item/ammo_casing/c38/lethal
	desc = "A .38 bullet casing. This is the lethal variant."
	caliber = POINT38
	projectile_type = "/obj/item/projectile/bullet" //HAHA, why is this a good idea
	w_type = RECYK_METAL
*/

/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = MM9
	projectile_type = "/obj/item/projectile/bullet/midbullet2"
	w_type = RECYK_METAL

/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = POINT45
	projectile_type = "/obj/item/projectile/bullet/fourtyfive"

/obj/item/ammo_casing/c45/practice
	desc = "A .45 practice bullet casing."
	caliber = POINT45
	projectile_type = "/obj/item/projectile/bullet/fourtyfive/practice"
	icon_state = "s-p-casing"

/obj/item/ammo_casing/c45/rubber
	desc = "A .45 rubber bullet casing."
	caliber = POINT45
	projectile_type = "/obj/item/projectile/bullet/fourtyfive/rubber"
	icon_state = "s-r-casing"

/obj/item/ammo_casing/c380auto
	desc = "A .380AUTO bullet casing."
	caliber = POINT380
	projectile_type = "/obj/item/projectile/bullet/auto380"

/obj/item/ammo_casing/c380auto/practice
	desc = "A .380AUTO practice bullet casing."
	caliber = POINT380
	projectile_type = "/obj/item/projectile/bullet/auto380/practice"
	icon_state = "s-p-casing"

/obj/item/ammo_casing/c380auto/rubber
	desc = "A .380AUTO rubber bullet casing."
	caliber = POINT380
	projectile_type = "/obj/item/projectile/bullet/auto380/rubber"
	icon_state = "s-r-casing"

/obj/item/ammo_casing/a12mm
	desc = "A 12mm bullet casing."
	caliber = MM12
	projectile_type = "/obj/item/projectile/bullet/midbullet"
	w_type = RECYK_METAL

/obj/item/ammo_casing/a12mm/assault
	projectile_type = "/obj/item/projectile/bullet/midbullet/assault"

/obj/item/ammo_casing/a12mm/bounce
	desc = "A rubber-titanium 12mm bullet casing."
	projectile_type = "/obj/item/projectile/bullet/midbullet/bouncebullet"

/obj/item/ammo_casing/shotgun
	name = "shotgun shell"
	desc = "A 12 gauge slug."
	icon_state = "gshell"
	caliber = GAUGE12
	projectile_type = "/obj/item/projectile/bullet"
	starting_materials = list(MAT_IRON = 12500)
	w_type = RECYK_METAL

	update_icon()
		desc = "[initial(desc)][BB ? "" : " This one is spent"]"
		overlays = list()
		if(!BB)
			overlays += icon('icons/obj/ammo.dmi', "emptyshell")

/obj/item/ammo_casing/shotgun/blank
	name = "blank shell"
	desc = "A blank shell.  Does not contain any projectile material."
	icon_state = "blshell"
	projectile_type = "/obj/item/projectile/bullet/blank"
	starting_materials = list(MAT_IRON = 250)
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/weakbullet"
	starting_materials = list(MAT_IRON = 500)
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/weakbullet/booze"
	starting_materials = list(MAT_IRON = 12500)
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"
	desc = "A stunning shell."
	icon_state = "stunshell"
	projectile_type = "/obj/item/projectile/bullet/stunshot"
	starting_materials = list(MAT_IRON = 2500)
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns."
	icon_state = "blshell"
	projectile_type = "/obj/item/projectile/bullet/dart"
	starting_materials = list(MAT_IRON = 12500)
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge shell filled with standard double-aught buckshot."
	projectile_type = "/obj/item/projectile/bullet/buckshot"
	starting_materials = list(MAT_IRON = 12500)
	w_type = RECYK_METAL

/obj/item/ammo_casing/a762
	desc = "A 7.62 bullet casing."
	caliber = POINT762
	projectile_type = "/obj/item/projectile/bullet"
	w_type = RECYK_METAL

/obj/item/ammo_casing/BMG50
	desc = "A .50 BMG bullet casing."
	caliber = BROWNING50
	projectile_type = "/obj/item/projectile/bullet/hecate"
	w_type = RECYK_METAL
	icon_state = "l-casing"

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/bullet
	//select_name = "kinetic"
	//e_cost = 500
	//fire_sound = 'sound/weapons/Gunshot4.ogg'
	w_type = RECYK_METAL

/obj/item/ammo_casing/a762x55
	desc = "A 7.62x55mmR bullet casing."
	caliber = POINT762X55
	projectile_type = "/obj/item/projectile/bullet/a762x55"
	w_type = RECYK_METAL
	icon_state = "762x55-casing-live"
	starting_materials = list(MAT_IRON = 12500)

	update_icon()
		desc = "[initial(desc)][BB ? "" : " This one is spent"]"
		if(!BB)
			icon_state = "762x55-casing"

/obj/item/ammo_casing/invisible
	desc = "An invisible bullet casing, it's hard to tell if it's been spent or not."
	projectile_type = "/obj/item/projectile/bullet/invisible"
	icon_state = null
