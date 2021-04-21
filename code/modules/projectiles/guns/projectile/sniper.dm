/obj/item/weapon/gun/projectile/hecate
	name = "\improper PGM Hécate II"
	desc = "An Anti-Materiel Rifle. You can read \"Fabriqué en Haute-Savoie\" on the receiver. Whatever that means..."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hecate"
	item_state = null
	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 16
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

/obj/item/weapon/gun/projectile/hecate/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
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

/obj/item/weapon/gun/projectile/hecate/hunting
	name = "hunting rifle"
	desc = "A pistol caliber carbine. Designed for rimworld settlers, it was conceived as a weapon that would protect settlers without arming revolutions. It's a poor weapon against any armored target, but compensates with range."
	icon = 'icons/obj/biggun.dmi'
	icon_state = "hunting-rifle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	max_shells = 6
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=3"
	ammo_type = "/obj/item/ammo_casing/c38"
	caliber = list(POINT38 = 1)
	recoil = 2
	fire_sound = 'sound/weapons/hunting_fire.ogg'
	fire_delay = 2
	slowdown = NO_SLOWDOWN
	var/scope_toggled = 0
	gun_flags = SCOPED
	var/recentpump = 0
	var/obj/item/ammo_casing/current_shell = null
	var/list/gun_overlay = list()
	actions_types = list(/datum/action/item_action/toggle_wielding)

/obj/item/weapon/gun/projectile/hecate/hunting/bullet_hitting(var/obj/item/projectile/P,var/atom/atarget)
	if(ishuman(atarget))
		P.stun = 0
		P.weaken = 0
	if(isanimal(atarget))
		P.damage *= 6

/obj/item/weapon/gun/projectile/hecate/hunting/attack_self(mob/user)
	if(wielded)
		if(!getAmmo())
			handing(user)
			return
		if(recentpump)
			return
		pump(user)
		recentpump = 1
		spawn(10)
			recentpump = 0
	else
		handing(user)

/obj/item/weapon/gun/projectile/hecate/hunting/proc/handing(mob/user)
	scope_toggled = 0
	if (wielded)
		unwield(user)
		update_wield(user)
	else
		wield(user)
		update_wield(user)

/obj/item/weapon/gun/projectile/hecate/hunting/verb/twowield()
	set name = "Wield/Unwield"
	set category = "Object"
	set src in usr
	handing(usr)

/obj/item/weapon/gun/projectile/hecate/hunting/process_chambered()
	if(in_chamber)
		return 1
	else if(current_shell && current_shell.BB)
		in_chamber = current_shell.BB
		current_shell.BB.forceMove(src)
		current_shell.BB = null
		current_shell.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/hecate/hunting/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/hunting_slide.ogg', 60, 1)
	if(current_shell)
		current_shell.forceMove(get_turf(src))
		playsound(current_shell, casingsound, 25, 0.2, 1)
		current_shell = null
		if(in_chamber)
			in_chamber = null
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1]
	loaded -= AC
	current_shell = AC
	update_icon()
	return 1

/obj/item/weapon/gun/projectile/hecate/hunting/proc/scoping()
	if(!is_holder_of(usr, src))
		return
	if(wielded && scoped)
		scope_toggled = !scope_toggled
		update_wield(usr)
	else
		if(scoped)
			to_chat(usr, "<span class='warning'>You must dual-wield \the [src] before you can use scope on it!</span>")

/obj/item/weapon/gun/projectile/hecate/hunting/AltClick()
	scoping()

/datum/action/item_action/toggle_wielding
	name = "Wield/Unwield"

/datum/action/item_action/toggle_wielding/Trigger()
	if(IsAvailable() && owner && target && istype(target,/obj/item/weapon/gun/projectile/hecate/hunting))
		var/obj/item/weapon/gun/projectile/hecate/hunting/W = target
		W.handing(owner)

/obj/item/weapon/gun/projectile/hecate/hunting/update_icon()
	AttachOverlays()
	..()

/obj/item/weapon/gun/projectile/hecate/hunting/proc/AttachOverlays() //to prevent overlaying issues
	var scope_overlay = image("icon" = 'icons/obj/biggun.dmi', "icon_state" = "hf_scope")
	if(scoped)
		if("/obj/item/gun_part/scope" in gun_overlay)
		else
			overlays += scope_overlay
			gun_overlay += "/obj/item/gun_part/scope"
	else
		overlays -= scope_overlay
		gun_overlay -= "/obj/item/gun_part/scope"

/datum/action/item_action/toggle_scope
	name = "Toggle Scope"

/datum/action/item_action/toggle_scope/Trigger()
	if(IsAvailable() && owner && target && istype(target,/obj/item/weapon/gun/projectile/hecate/hunting))
		var/obj/item/weapon/gun/projectile/hecate/hunting/W = target
		W.scoping(owner)

/obj/item/weapon/gun/projectile/hecate/hunting/update_wield(mob/user)
	if(wielded)
		user.regenerate_icons()
		var/client/C = user.client
		C.changeView()
		if(user && user.client)
			if(scoped && scope_toggled)
				user.regenerate_icons()
				//var/client/C = user.client
				backup_view = C.view
				C.changeView(C.view * 1.5)
	else
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.changeView(backup_view)
