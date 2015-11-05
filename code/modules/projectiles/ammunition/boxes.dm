//Boxes store shells to be loaded into guns
//Boxes have a "fumble" effect - if you move while loading something, you drop some bullets and stop the action.
//Attempting to load a gun in the middle of a firefight is a bad idea, needless to say

/obj/item/ammo_storage/box
	exact = 1

/obj/item/ammo_storage/box/a357
	name = "ammo box (.357)"
	desc = "A box of .357 ammo."
	icon_state = "357"
	ammo_type = "/obj/item/ammo_casing/a357"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_storage/box/c38
	name = "ammo box (.38)"
	desc = "A box of non-lethal .38 ammo."
	icon_state = "b38"
	ammo_type = "/obj/item/ammo_casing/c38"
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_storage/box/a418
	name = "ammo box (.418)"
	desc = "A box of .418 ammo."
	icon_state = "418"
	ammo_type = "/obj/item/ammo_casing/a418"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_storage/box/a666
	name = "ammo box (.666)"
	desc = "A box of .666 ammo. You're a bit unsure about using this kind of caliber."
	icon_state = "666"
	ammo_type = "/obj/item/ammo_casing/a666"
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_storage/box/a556x45
	name = "ammo box (5.56x45)"
	desc = "A box of 5.56x45 ammo."
	icon_state = "5.56x45-box"
	ammo_type = "/obj/item/ammo_casing/a556x45"
	max_ammo = 100
	multiple_sprites = 1
	sprite_modulo = 5

/obj/item/ammo_storage/box/c9mm
	name = "ammo box (9mm)"
	desc = "A box of 9mm ammo."
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	max_ammo = 100
	multiple_sprites = 1
	sprite_modulo = 5

/obj/item/ammo_storage/box/c45
	name = "ammo box (.45)"
	desc = "A box of .45 ammo."
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	max_ammo = 30

/obj/item/ammo_storage/box/BMG50
	name = "ammo box (.50 BMG)"
	desc = "A box of .50 BMG ammo."
	icon_state = "50BMG"
	origin_tech = "combat=4"
	ammo_type = "/obj/item/ammo_casing/BMG50"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_storage/box/b762x55
	name = "ammo box (7.62x55mmR)"
	desc = "A box of 7.62x55mmR ammo."
	icon_state = "b762x55"
	origin_tech = "combat=3"
	ammo_type = "/obj/item/ammo_casing/a762x55"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_storage/box/flare
	name = "ammo box (flare shells)"
	desc = "A box of flare shells."
	icon_state = "flarebox"
	ammo_type = "/obj/item/ammo_casing/shotgun/flare"
	max_ammo = 7
	multiple_sprites = 1
