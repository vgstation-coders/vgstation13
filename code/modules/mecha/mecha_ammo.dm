/obj/mecha/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_storage/box) || (istype(W, /obj/item/weapon/storage/box)))
		resupply_box(W, user)
		return
	if(istype(W, /obj/item/ammo_casing))
		resupply_single(W, user)
		return
	..()