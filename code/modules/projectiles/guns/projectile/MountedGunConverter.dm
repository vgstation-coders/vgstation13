obj/item/weapon/gun/MechaGunConverter
	name = "mecha gun converter"
	desc = "use on mecha gun to make man gun"

/obj/item/weapon/gun/ConvertedMountedGun
	name = "man-portable exosuit weapon"
	desc = "A really big gun with a trigger assembly on it."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	item_state = "minigun0"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_COMBAT + "=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	slot_flags = null
	flags = FPRINT | TWOHANDABLE | SLOWDOWN_WHEN_CARRIED
	w_class = W_CLASS_HUGE
	fire_delay = 0
	fire_sound = 'sound/weapons/gatling_fire.ogg'
	var/max_shells = 200
	var/current_shells = 200
	var/originalclass
	var/projectile
	var/projectiles_per_shot

obj/item/weapon/gun/MechaGunConverter/New()
	..()

/obj/item/weapon/gun/ConvertedMountedGun/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [current_shells] round\s remaining.</span>")

/obj/item/weapon/gun/ConvertedMountedGun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/ConvertedMountedGun/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	..()
	var/list/turf/possible_turfs = list()
	for(var/turf/T in orange(target,1))
		possible_turfs += T
	spawn()
		for(var/i = 1; i <= projectiles_per_shot; i++)
			sleep(1)
			var/newturf = pick(possible_turfs)
			..(newturf,user,params,reflex,struggle)

/obj/item/weapon/gun/ConvertedMountedGun/update_wield(mob/user)
	item_state = "minigun[wielded ? 1 : 0]"
	if(wielded)
		slowdown = MINIGUN_SLOWDOWN_WIELDED
	else
		slowdown = MINIGUN_SLOWDOWN_NONWIELDED

/obj/item/weapon/gun/ConvertedMountedGun/process_chambered()
	if(in_chamber)
		return 1
	if(current_shells)
		current_shells--
		var/obj/item/projectile/bullet/loadedbullet = new projectile
		in_chamber = loadedbullet//We create bullets as we are about to fire them. No other way to remove them from the gun.
		new/obj/item/ammo_casing_gatling(get_turf(src))
		return 1
	return 0

/obj/item/weapon/gun/ConvertedMountedGun/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/ammo_casing_gatling
	name = "large bullet casing"
	desc = "An oversized bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "gatling-casing"
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 1
	w_class = W_CLASS_TINY
	w_type = RECYK_METAL

/obj/item/ammo_casing_gatling/New()
	..()
	pixel_x = rand(-10.0, 10) * PIXEL_MULTIPLIER
	pixel_y = rand(-10.0, 10) * PIXEL_MULTIPLIER
	dir = pick(cardinal)
