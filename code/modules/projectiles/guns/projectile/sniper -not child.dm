/obj/item/weapon/gun/projectile/hecate
	name = "\improper PGM Hécate II"
	desc = "An Anti-Materiel Rifle. You can read \"Fabriqué en Haute-Savoie\" on the receiver. Whatever that means..."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hecate"
	item_state = null
	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 2
	slot_flags = SLOT_BACK
	fire_delay = 30
	w_class = W_CLASS_LARGE
	fire_sound = 'sound/weapons/hecate_fire.ogg'
	caliber = list(BROWNING50 = 1)
	ammo_type = "/obj/item/ammo_casing/BMG50"
	max_shells = 1
	load_method = 0
	slowdown = 10
	var/backup_view = 7

/obj/item/weapon/gun/projectile/hecate/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/hecate/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/projectile/hecate/update_wield(mob/user)
	if(wielded)
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_64x64.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_64x64.dmi')
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			backup_view = C.view
			C.changeView(C.view * 2)
	else
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.changeView(backup_view)

/obj/item/weapon/gun/projectile/hecate/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/weapon/gun/projectile/src50
	name = "\improper SRC-50"
	desc = "A long-range rifle chambered in .50 BMG used by covert operatives. While suppressed, it is by no means hearing-safe. Can be unloaded and disassembled by Alt-Clicking the rifle."
	icon = 'icons/obj/gun.dmi'
	icon_state = "src50"
	item_state = "src50"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 2
	slot_flags = SLOT_BACK
	fire_delay = 15
	w_class = W_CLASS_LARGE
	fire_sound = 'sound/weapons/hecate_fire.ogg'
	caliber = list(BROWNING50 = 1)
	ammo_type = "/obj/item/ammo_casing/BMG50"
	max_shells = 1
	load_method = 0
	var/backup_view = 7
	var/scope = 0

/obj/item/weapon/gun/projectile/src50/update_icon()
	..()
	var/MT = scope ? "[scope > 0 ? "-s" : ""]" : ""
	icon_state = "[initial(icon_state)]["[MT]"][getAmmo() ? "" : "-e"]"
	item_state = icon_state

/obj/item/weapon/gun/projectile/src50/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/src50/afterattack(atom/A as mob|obj|turf|area, mob/living/carbon/human/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")
		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		if (loaded.len > 0) // sanity so you can't break your hand if the gun is empty
			var/datum/organ/external/H = user.get_active_hand_organ()
			user.apply_damage(30, BRUTE, H) // Turns out that firing a lightweight .50 cal rifle one-handed without shouldering it is a terrible, terrible idea.
			H.fracture()
			Fire(A,user,params, "struggle" = struggle)
			to_chat(user, "<span class='warning'>The recoil shatters your hand!</span>")
			return
		Fire(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/projectile/src50/update_wield(mob/user)
	if (scope)
		if(wielded)
			inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
			if(user && user.client)
				user.regenerate_icons()
				var/client/C = user.client
				backup_view = C.view
				C.changeView(C.view * 2)
		else
			inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
			if(user && user.client)
				user.regenerate_icons()
				var/client/C = user.client
				C.changeView(backup_view)

/obj/item/weapon/gun/projectile/src50/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/weapon/gun/projectile/src50/attackby(obj/item/weapon/W, mob/user)
	..()
	if (!scope)
		if(istype(W, /obj/item/weapon/src50_scope))
			scope = 1
			qdel(W)
			to_chat(user, "You install the scope onto the SRC-50. Alt-Click the rifle to take the scope off.")
			update_icon()
	else
		to_chat(user, "There's already a scope attached on the SRC-50!")

/obj/item/weapon/gun/projectile/src50/AltClick(mob/user)
	if(scope)
		scope = 0
		var/obj/item/weapon/src50_scope/S = new (get_turf(user))
		user.put_in_hands(S)
		add_fingerprint(user)
		to_chat(user, "You detach the scope from the SRC-50.")
		update_icon()
	else
		if (getAmmo()) // Unloading a round
			var/obj/item/ammo_casing/AC = getAC()
			loaded -= AC
			user.put_in_hands(AC)
			to_chat(user, "<span class='notice'>You unload \the [AC] from \the [src]!</span>")
			update_icon()
		else // Disassembly
			to_chat(user, "You toggle off the magnetic clamp holding the barrel onto the receiver and take the barrel out of it.")
			var/obj/item/weapon/src50_stock_receiver/SR = new (get_turf(user))
			var/obj/item/weapon/src50_barrel/B = new (get_turf(user))
			user.put_in_hands(SR)
			user.put_in_hands(B)
			qdel(src)
