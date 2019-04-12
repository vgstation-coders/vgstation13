/obj/item/weapon/gun/projectile/shotgun
	reloadsound = 'sound/weapons/shotgun_shell_insert.ogg'
	casingsound = 'sound/weapons/shotgun_shell_bounce.ogg'
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list(GAUGE12 = 1, GAUGEFLARE = 1)
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=1"

/obj/item/weapon/gun/projectile/shotgun/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/shotgun/pump
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "shotgun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 4
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	var/obj/item/ammo_casing/current_shell = null
	gun_flags = 0

/obj/item/weapon/gun/projectile/shotgun/pump/attack_self(mob/living/user as mob)
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
		playsound(current_shell, casingsound, 25, 0.2, 1)
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

/obj/item/weapon/gun/projectile/shotgun/pump/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 8
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun"

//this is largely hacky and bad :(	-Pete
/obj/item/weapon/gun/projectile/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 2
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	fire_sound = 'sound/weapons/shotgun_small.ogg'

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
	if(!(locate(/obj/item/ammo_casing/shotgun) in src) && !getAmmo())
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return

	playsound(src, 'sound/weapons/shotgun_open.ogg', 25, 0)
	var/i = 0
	for(var/obj/item/ammo_casing/shotgun/loaded_shell in src) //This feels like a hack. don't code at 3:30am kids!!
		loaded_shell.forceMove(get_turf(src))
		loaded_shell.pixel_x = min(-3 + (i*4),15) * PIXEL_MULTIPLIER
		loaded_shell.pixel_y = min( 3 - (i*4),15) * PIXEL_MULTIPLIER
		playsound(loaded_shell, casingsound, 25, 0.2, 1)
		if(loaded_shell in loaded)
			loaded -= loaded_shell
		i++

	to_chat(user, "<span class='notice'>You break \the [src].</span>")
	update_icon()

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	A.update_icon()
	update_icon()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(getAmmo())
			afterattack(user, user)	//will this work?
			afterattack(user, user)	//it will. we call it twice, for twice the FUN
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
			return
		if(do_after(user, src, 30))	//SHIT IS STEALTHY EYYYYY
			icon_state = "sawnshotgun"
			w_class = W_CLASS_MEDIUM
			item_state = "sawnshotgun"
			slot_flags &= ~SLOT_BACK	//you can't sling it on your back
			slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
			name = "sawn-off shotgun"
			desc = "Omar's coming!"
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")
			if(istype(user, /mob/living/carbon/human) && src.loc == user)
				var/mob/living/carbon/human/H = user
				H.update_inv_hands()

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff
	name = "sawn-off shotgun"
	desc = "Omar's coming!"
	icon_state = "sawnshotgun"
	item_state = "sawnshotgun"
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_BELT
	ammo_type = "/obj/item/ammo_casing/shotgun/buckshot"

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/super
	name = "super shotgun"
	desc = "bang-bang, click, tack, shoomph, click"
	icon_state = "supershotgun"
	item_state = "sawnshotgun"
	fire_delay = 0

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/super/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(..())
		..()
		attack_self(user)

/obj/item/weapon/gun/projectile/shotgun/nt12
	name = "\improper NT-12"
	desc = "The NT-12 is a new development in shotgun technology, produced by a NanoTrasen subsidiary. It is a 12-gauge semi-automatic bullpup shotgun fed with box or drum magazines."
	icon_state = "nt12"
	item_state = "nt12"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/shotgun_nt12.ogg'
	origin_tech = Tc_COMBAT + "=6;" + Tc_MATERIALS + "=3"
	ammo_type = "/obj/item/ammo_casing/shotgun"
	mag_type = "/obj/item/ammo_storage/magazine/a12ga"
	max_shells = 4
	load_method = 2
	slot_flags = 0
	gun_flags = EMPTYCASINGS

/obj/item/weapon/gun/projectile/shotgun/nt12/update_icon()
	..()
	var/MT = stored_magazine ? "[stored_magazine.max_ammo > 4 ? "-drum-20" : "-mag-4"]" : ""
	icon_state = "[initial(icon_state)]["[MT]"][stored_magazine ? "" : "-m"][chambered ? "" : "-e"]"
	item_state = icon_state
