/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/item/projectile/beam/wormhole
	e_cost = 0
	fire_sound = 'sound/weapons/pulse3.ogg'
	var/obj/item/gun/energy/wormhole_projector/gun = null
	select_name = "blue"

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/item/projectile/beam/wormhole/orange
	select_name = "orange"

/obj/item/ammo_casing/energy/wormhole/Initialize(mapload, obj/item/gun/energy/wormhole_projector/wh)
	. = ..()
	gun = wh

/obj/item/ammo_casing/energy/wormhole/throw_proj()
	. = ..()
	if(istype(BB, /obj/item/projectile/beam/wormhole))
		var/obj/item/projectile/beam/wormhole/WH = BB
		WH.gun = gun
