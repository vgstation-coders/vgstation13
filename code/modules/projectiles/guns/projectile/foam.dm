//pistol, auto, gat, sniper, shotgun
/obj/item/weapon/gun/projectile/foam //Manually loaded versions.
	name = "basic foam dart gun"
	desc = "A norf gun"
	icon_state = "basic norf"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_SMALL
	origin_tech = null //Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2"
	fire_sound = 'sound/items/syringeproj.ogg'
	max_shells = 1
	caliber = list(FOAM = 1)
	ammo_type ="/obj/item/ammo_casing/foam"
	load_method = 0
	recoil = 0
	gun_flags = 0
	clumsy_check = FALSE //So nerf guns don't explode on clowns.
	advanced_tool_user_check = FALSE
	MoMMI_check = FALSE //MoMMIs could fire foambows in the past so they can shoot these as well.
	nymph_check = FALSE
	golem_check = FALSE

/obj/item/weapon/gun/projectile/foam/mag //Mag loaded versions.
	name = "basic foam dart gun"
	desc = "A norf gun"
	icon_state = "basic norf"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = ARBITRARILY_LARGE_NUMBER
	mag_type = "/obj/item/ammo_storage/magazine/foam"
	load_method = 2

/obj/item/weapon/gun/projectile/foam/mag/automatic
	name = "auto norf gun"
	desc = "An auto norf gun."
	icon_state = "saber"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_MEDIUM
	automatic = 1
	fire_delay = 0
	var/burstfire = FALSE
	var/burst_count = 3
	var/burstfiring = 0

//Mostly copy/paste from automatic guns.
/obj/item/weapon/gun/projectile/foam/mag/automatic/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/foam/mag/automatic/verb/ToggleFire()
	set name = "Toggle Burstfire"
	set category = "Object"
	if(!(world.time >= last_fired + fire_delay) || burstfiring)
		to_chat(usr, "<span class='warning'>You're unable to toggle the fire rate on \the [src] right now!</span>")
	else
		burstfire = !burstfire
		if(!burstfire)
			fire_delay = initial(fire_delay)
		to_chat(usr, "You toggle \the [src]'s firing setting to [burstfire ? "burst fire" : "single fire"].")

/obj/item/weapon/gun/projectile/foam/mag/automatic/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(burstfire == TRUE)
		if(!ready_to_fire())
			return 1
		//var/shots_fired = 0
		var/to_shoot = min(burst_count, getAmmo())
		for(var/i = 1 to to_shoot)
			..()
			burstfiring = 1
		//	shots_fired++
			if(!user.contents.Find(src) || jammed)
				break
		recoil = initial(recoil)
		burstfiring = 0
		return 1
	else
		.=..()








