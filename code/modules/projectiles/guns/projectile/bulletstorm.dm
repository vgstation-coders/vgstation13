/obj/item/weapon/gun/bulletstorm
	name = "\improper Bullet Storm"
	desc = "You only get one shot, so make it count."
	icon = 'icons/obj/gun.dmi'
	icon_state = "volley_gun"
	item_state = "cshotgun"
	origin_tech = Tc_COMBAT + "=5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 1
	slot_flags = SLOT_BELT
	w_class = W_CLASS_MEDIUM
	fire_delay = 1
	fire_sound = 'sound/weapons/railgun_highpower.ogg'
	var/projectile_type = /obj/item/projectile/bullet/buckshot/bullet_storm

/obj/item/weapon/gun/bulletstorm/isHandgun()
	return FALSE

/obj/item/weapon/gun/bulletstorm/New()
	..()
	in_chamber = new projectile_type(src)

/obj/item/weapon/gun/bulletstorm/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return

	Fire(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/bulletstorm/can_discharge()
	if(in_chamber)
		return 1
	
/obj/item/weapon/gun/bulletstorm/process_chambered()
	return in_chamber