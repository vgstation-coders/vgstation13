/obj/item/weapon/gun/projectile/shotgun/pump
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "shotgun"
	item_state = "shotgun0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 4
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT | TWOHANDABLE
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list("shotgun" = 1, "flare" = 1) //flare shells are still shells
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	var/obj/item/ammo_casing/current_shell = null


	gun_flags = 0

/obj/item/weapon/gun/projectile/shotgun/pump/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0)
	var/atom/newtarget = target
	if(!wielded)
		newtarget = get_inaccuracy(target,1+recoil) //Inaccurate when not wielded
	..(newtarget,user,params,reflex,struggle)

/obj/item/weapon/gun/projectile/shotgun/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/shotgun/pump/attack_self(mob/living/user as mob)
	if(!wielded)
		wield(user)
		src.update_wield(user)
	else if(wielded)
		if(recentpump)
			return
		pump(user)
		recentpump = 1
		spawn(10)
			recentpump = 0
		return

/obj/item/weapon/gun/projectile/shotgun/pump/process_chambered()
	if(in_chamber)
		return 1
	else if(current_shell && current_shell.BB)
		in_chamber = current_shell.BB //Load projectile into chamber.
		current_shell.BB.forceMove(src) //Set projectile loc to gun.
		current_shell.BB = null
		current_shell.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/shotgun/pump/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pumped = 0
	if(current_shell)//We have a shell in the chamber
		current_shell.forceMove(get_turf(src))//Eject casing
		current_shell = null
		if(in_chamber)
			in_chamber = null
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	current_shell = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/pump/update_wield(mob/user)
	..()
	item_state = "[initial(icon_state)][wielded ? 1 : 0]"
	if(user)
		user.update_inv_hands()

/obj/item/weapon/gun/projectile/shotgun/pump/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	item_state = "cshotgun0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 8
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun"

/obj/item/weapon/gun/projectile/shotgun/pump/combat/update_wield(mob/user)
	..()
	item_state = "[initial(icon_state)][wielded ? 1 : 0]"
	if(user)
		user.update_inv_hands()

//this is largely hacky and bad :(	-Pete
/obj/item/weapon/gun/projectile/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "dshotgun0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 2
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT | TWOHANDABLE
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list("shotgun" = 1, "flare" = 1)
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=1"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	var/broke = 0 //To check if it's been broken or not
	var/canwield = 1

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/process_chambered()
	if(in_chamber)
		return 1
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	loaded += AC //Put it in at the end - because it hasn't been ejected yet
	if(AC.BB)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.forceMove(src) //Set projectile loc to gun.
		AC.BB = null
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/attack_self(mob/living/user as mob)
	if(!wielded && canwield)
		wield(user)
		src.update_wield(user)
	else if(!broke)
		var/i = 0
		if(clumsy_check && clumsy_check(usr))
			usr.visible_message("<span class='danger'>[usr] literally breaks \the [src.name]!.</span>", "<span class='danger'>You literally break the [src.name].</span>")
			playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 50, 1)
			icon_state = "literallybroken"
			src.become_defective()
			return
		for(var/obj/item/ammo_casing/shotgun/loaded_shell in src) //This feels like a hack. don't code at 3:30am kids!!
			loaded_shell.forceMove(get_turf(src))
			loaded_shell.pixel_x = min(-3 + (i*4),15) * PIXEL_MULTIPLIER
			loaded_shell.pixel_y = min( 3 - (i*4),15) * PIXEL_MULTIPLIER
			if(loaded_shell in loaded)
				loaded -= loaded_shell
			i++
		to_chat(usr, "<span class='notice'>You break \the [src].</span>")
		playsound(get_turf(src), 'sound/weapons/shotgun_break.ogg', 50, 1)
		broke = 1
		icon_state = "[initial(icon_state)]broke"
		update_icon()
	else if(broke)
		to_chat(usr, "<span class='notice'>You put \the [src] back to its original position.</span>")
		playsound(get_turf(src), 'sound/weapons/shotgun_unbreak.ogg', 50, 1)
		broke = 0
		icon_state = "[initial(icon_state)]"
		update_icon()
	if(!(locate(/obj/item/ammo_casing/shotgun) in src) && !getAmmo())
		to_chat(usr, "<span class='notice'>\The [src] is empty.</span>")
		return

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/update_wield(mob/user)
	..()
	item_state = "[initial(icon_state)][wielded ? 1 : 0]"
	if(user)
		user.update_inv_hands()

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0)
	var/atom/newtarget = target
	if(!wielded && w_class > W_CLASS_MEDIUM)
		newtarget = get_inaccuracy(target,1+recoil)
	if(broke)
		return
	..(newtarget,user,params,reflex,struggle)

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	if(broke)
		..()
		A.update_icon()
		update_icon()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(getAmmo() && !broke)
			afterattack(user, user)	//will this work?
			afterattack(user, user)	//it will. we call it twice, for twice the FUN
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
			return
		if(do_after(user, src, 30))	//SHIT IS STEALTHY EYYYYY
			qdel(src)
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")
			var/sawn = new /obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff
			user.put_in_hands(sawn)

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff
	name = "sawn-off shotgun"
	desc = "Omar's coming!"
	icon_state = "sawnshotgun"
	item_state = "sawnshotgun"
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	slot_flags = SLOT_BELT
	canwield = 0
