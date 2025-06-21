/obj/structure/closet/crate/chest/exoticshotgunshells
	name = "Exotic shotgun shells crate"
	desc = "A variety of less common shotgun 12 gauge shells."

var/global/list/exotic_shotgun_shells = list(
	/obj/item/weapon/storage/box/dragonsbreathshells, /obj/item/weapon/storage/box/dragonsbreathshells, /obj/item/weapon/storage/box/dragonsbreathshells,
	/obj/item/weapon/storage/box/rocksaltshells, /obj/item/weapon/storage/box/rocksaltshells, /obj/item/weapon/storage/box/rocksaltshells,
	/obj/item/weapon/storage/box/pepperballshells, /obj/item/weapon/storage/box/pepperballshells, /obj/item/weapon/storage/box/pepperballshells,
	/obj/item/weapon/storage/box/superbeanbagshells, /obj/item/weapon/storage/box/superbeanbagshells,
	/obj/item/weapon/storage/box/duckshotshells, /obj/item/weapon/storage/box/duckshotshells,
	/obj/item/weapon/storage/box/concussiveblastshells,
	/obj/item/weapon/storage/box/fragshells,
	)

/obj/structure/closet/crate/chest/exoticshotgunshells/New()
	..()
	for(var/i = 1 to 5)
		if(!exotic_shotgun_shells.len)
			return
		var/path = pick_n_take(exotic_shotgun_shells)
		new path(src)