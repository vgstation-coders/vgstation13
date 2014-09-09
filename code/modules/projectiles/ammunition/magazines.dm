//Magazines are loaded directly into weapons
//Unlike boxes, they have no fumbling. Simply loading a magazine is instant

/obj/item/ammo_storage/magazine
	desc = "A magazine capable of holding bullets. Can be loaded into certain weapons."
	exact = 1 //we only load the thing we want to load

/obj/item/ammo_storage/magazine/mc9mm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_storage/magazine/a12mm
	name = "magazine (12mm)"
	icon_state = "12mm"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	max_ammo = 20
	multiple_sprites = 1
	sprite_modulo = 10


/obj/item/ammo_storage/magazine/a12mm/empty
	name = "magazine (12mm)"
	icon_state = "12mm"
	ammo_type = "/obj/item/ammo_casing/12mm"
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a50
	name = "magazine (.50)"
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/a50"
	max_ammo = 7
//	multiple_sprites = 1 // Please don't set this unless you actually have multiple sprites

/obj/item/ammo_storage/magazine/a50/empty
	name = "magazine (.50)"
	icon_state = "50ae"
	ammo_type = "/obj/item/ammo_casing/a50"
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a75
	name = "magazine (.75)"
	icon_state = "75"
	ammo_type = "/obj/item/ammo_casing/a75"
	multiple_sprites = 1
	max_ammo = 8

/obj/item/ammo_storage/magazine/a75/empty
	name = "magazine (.75)"
	icon_state = "75"
	ammo_type = "/obj/item/ammo_casing/a75"
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a762
	name = "magazine (a762)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	max_ammo = 50
	multiple_sprites = 1
	sprite_modulo = 10

/obj/item/ammo_storage/magazine/a762/empty
	starting_ammo = 0