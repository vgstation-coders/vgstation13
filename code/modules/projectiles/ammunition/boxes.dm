//Boxes store shells to be loaded into guns
//Boxes have a "fumble" effect - if you move while loading something, you drop some bullets and stop the action.
//Attempting to load a gun in the middle of a firefight is a bad idea, needless to say

/obj/item/ammo_storage/box
	exact = 1
	starting_materials = list(MAT_IRON = 2000)

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

/obj/item/ammo_storage/box/c762x38r
	name = "ammo box (7.62x38R)"
	desc = "A box of neo-russian revolver ammo."
	icon_state = "bnagant"
	ammo_type = "/obj/item/ammo_casing/c762x38r"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_storage/box/a418
	name = "ammo box (.418)"
	icon_state = "418"
	ammo_type = "/obj/item/ammo_casing/a418"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_storage/box/a666
	name = "ammo box (.666)"
	icon_state = "666"
	ammo_type = "/obj/item/ammo_casing/a666"
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_storage/box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mm"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	max_ammo = 30

/obj/item/ammo_storage/box/c12mm
	name = "ammo box (12mm)"
	icon_state = "9mm"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	max_ammo = 30

/obj/item/ammo_storage/box/c12mm/assault
	ammo_type = "/obj/item/ammo_casing/a12mm/assault"


/obj/item/ammo_storage/box/c45
	name = "pistol ammo box (.45)"
	desc = "A box of .45 bullets. Holds 24 rounds."
	icon_state = "9mmred"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	caliber = POINT45
	max_ammo = 24

/obj/item/ammo_storage/box/c45/practice
	name = "pistol ammo box (.45 practice)"
	desc = "A box of .45 practice bullets. Holds 24 rounds."
	icon_state = "9mmwhite"
	ammo_type = "/obj/item/ammo_casing/c45/practice"

/obj/item/ammo_storage/box/c45/rubber
	name = "pistol ammo box (.45 rubber)"
	desc = "A box of .45 rubber bullets. Holds 24 rounds."
	icon_state = "9mmblue"
	ammo_type = "/obj/item/ammo_casing/c45/rubber"

/obj/item/ammo_storage/box/b380auto
	name = "pistol ammo box (.380AUTO)"
	desc = "A box of .380AUTO bullets. Holds 30 rounds."
	icon_state = "9mmred"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c380auto"
	caliber = POINT380
	max_ammo = 30

/obj/item/ammo_storage/box/b380auto/practice
	name = "pistol ammo box (.380AUTO practice)"
	desc = "A box of .380AUTO practice bullets. Holds 30 rounds."
	icon_state = "9mmwhite"
	ammo_type = "/obj/item/ammo_casing/c380auto/practice"

/obj/item/ammo_storage/box/b380auto/rubber
	name = "pistol ammo box (.380AUTO rubber)"
	desc = "A box of .380AUTO rubber bullets. Holds 30 rounds."
	icon_state = "9mmblue"
	ammo_type = "/obj/item/ammo_casing/c380auto/rubber"

/obj/item/ammo_storage/box/BMG50
	name = "ammo box (.50 BMG)"
	icon_state = "50BMG"
	origin_tech = Tc_COMBAT + "=4"
	ammo_type = "/obj/item/ammo_casing/BMG50"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_storage/box/b762x55
	name = "ammo box (7.62x55mmR)"
	icon_state = "b762x55"
	origin_tech = Tc_COMBAT + "=3"
	ammo_type = "/obj/item/ammo_casing/a762x55"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_storage/box/flare
	name = "ammo box (flare shells)"
	icon_state = "flarebox"
	ammo_type = "/obj/item/ammo_casing/shotgun/flare"
	max_ammo = 7
	multiple_sprites = 1
	starting_materials = list(MAT_IRON = 8000)

/obj/item/ammo_storage/box/a50
	name = "ammo box (.50AE)"
	icon_state = "9mm"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a50"
	max_ammo = 24

/obj/item/ammo_storage/box/a75
	name = "ammo box (.75 gyrojet)"
	icon_state = "9mmred"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a75"
	max_ammo = 24

/obj/item/ammo_storage/box/a762
	name = "ammo box (7.62x51mm)"
	icon_state = "9mm"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	max_ammo = 100
