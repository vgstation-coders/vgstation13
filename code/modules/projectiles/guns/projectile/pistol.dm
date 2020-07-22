/obj/item/weapon/gun/projectile/silenced
	name = "silenced pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_MEDIUM
	max_shells = 10
	caliber = list(POINT45  = 1)
	silenced = 1
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=8"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/c45"
	load_method = 2


/obj/item/weapon/gun/projectile/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo"
	icon_state = "deagle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	force = 14.0
	max_shells = 7
	caliber = list(POINT50 = 1)
	ammo_type ="/obj/item/ammo_casing/a50"
	mag_type = "/obj/item/ammo_storage/magazine/a50"
	load_method = 2
	recoil = 3

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"


/obj/item/weapon/gun/projectile/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"



/obj/item/weapon/gun/projectile/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon_state = "gyropistol"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 8
	caliber = list(POINT75 = 1)
	fire_sound = 'sound/weapons/elecfire.ogg'
	origin_tech = Tc_COMBAT + "=3"
	ammo_type = "/obj/item/ammo_casing/a75"
	mag_type = "/obj/item/ammo_storage/magazine/a75"
	load_method = 2
	recoil = 4

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

	update_icon()
		..()
		if(stored_magazine)
			icon_state = "gyropistolloaded"
		else
			icon_state = "gyropistol"
		return

/obj/item/weapon/gun/projectile/pistol
	name = "\improper Stechtkin pistol"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon_state = "pistol"
	w_class = W_CLASS_SMALL
	max_shells = 8
	caliber = list(MM9 = 1)
	silenced = 0
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	mag_type = "/obj/item/ammo_storage/magazine/mc9mm"
	load_method = 2

	gun_flags = AUTOMAGDROP | EMPTYCASINGS | SILENCECOMP

/obj/item/weapon/gun/projectile/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][silenced ? "-silencer" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/handgun //mime fingergun
	name = "hand-gun"
	desc = "This is a stickup!"
	icon_state = "handgun"
	inhand_states = list("left_hand" = null, "right_hand" = null)
	ammo_type = "/obj/item/ammo_casing/invisible"
	mag_type = "/obj/item/ammo_storage/magazine/invisible"
	cant_drop = TRUE
	gun_flags = 0
	silenced = TRUE
	fire_sound = null
	load_method = MAGAZINE


/obj/item/weapon/gun/projectile/handgun/RemoveMag(var/mob/user)
	to_chat(user, "<span class = 'warning'>Try as you might, you can't seem to find a magazine on \the [src]!</span>")

/obj/item/weapon/gun/projectile/handgun/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	if(..())
		if(silenced)
			user.emote("me",1,"pretends to fire a gun at [target]!")
		else
			user.say(pick("BANG!", "BOOM!", "PEW!", "KAPOW!"))

/obj/item/weapon/gun/projectile/NTUSP
	name = "\improper NT USP"
	desc = "The NT USP is a relatively rare sidearm, produced by a NanoTrasen subsidiary. Uses .45 rounds."
	icon = 'icons/obj/biggun.dmi' //for silencer compatibility
	icon_state = "secguncomp"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/c45"
	max_shells = 8
	caliber = list(POINT45  = 1)
	origin_tech = Tc_COMBAT + "=3"
	fire_sound = 'sound/weapons/semiauto.ogg'
	load_method = 2
	recoil = 2
	gun_flags = SILENCECOMP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/NTUSP/update_icon()
	..()
	icon_state = "secguncomp[silenced ? "-s" : ""][chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/NTUSP/fancy
	desc = "The NT USP is a relatively rare sidearm, produced by a NanoTrasen subsidiary. Uses .45 rounds.<br><span class='notice'>This one has a sweet pearl finish!</span>"
	name = "\improper NT USP Custom"
	icon_state = "secgunfancy"

/obj/item/weapon/gun/projectile/NTUSP/fancy/update_icon()
	..()
	icon_state = "secguncompfancy[silenced ? "-s" : ""][chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/glock
	name = "\improper NT Glock"
	desc = "The NT Glock is a cheap, ubiquitous sidearm, produced by a NanoTrasen subsidiary. Uses .380AUTO rounds. Its subcompact frame can fit in your pocket."
	icon = 'icons/obj/biggun.dmi'
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_BELT | SLOT_POCKET
	clowned = CLOWNABLE
	icon_state = "secglockfancy"
	ammo_type = "/obj/item/ammo_casing/c380auto"
	mag_type = "/obj/item/ammo_storage/magazine/m380auto"
	mag_type_restricted = list(/obj/item/ammo_storage/magazine/m380auto/extended)
	max_shells = 8
	caliber = list(POINT380  = 1)
	origin_tech = Tc_COMBAT + "=3"
	fire_sound = 'sound/weapons/semiauto.ogg'
	load_method = 2
	gun_flags = SILENCECOMP | EMPTYCASINGS
	starting_materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_PLASTIC = 2000)
	var/obj/item/gun_part/glock_auto_conversion_kit/conversionkit = null

/obj/item/weapon/gun/projectile/glock/update_icon()
	..()
	remove_overlays()
	icon_state = "secglock[chambered ? "" : "-e"][silenced ? "-s" : ""][stored_magazine ? "" : "-m"][clowned == CLOWNED ? "-c" : ""]"
	var/image/auto_overlay = image("icon" = 'icons/obj/biggun.dmi', "icon_state" = "auto_attach")
	auto_overlay.pixel_x = chambered ? 0 : -3
	if(conversionkit)
		overlays += auto_overlay
	
/obj/item/weapon/gun/projectile/glock/proc/remove_overlays() //god this is HORRIBLE
	var/image/auto_overlay = image("icon" = 'icons/obj/biggun.dmi', "icon_state" = "auto_attach")
	auto_overlay.pixel_x = -3
	overlays -= auto_overlay
	auto_overlay.pixel_x = 0
	overlays -= auto_overlay
		
/obj/item/weapon/gun/projectile/glock/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/gun_part/glock_auto_conversion_kit))
		if(user.drop_item(A, src)) //full auto time
			to_chat(user, "<span class='notice'>You click [A] into [src].</span>")
			conversionkit = A
			update_icon()
			fire_delay = 0
			desc += "<br>This one seems to have something screwed into it."
			return 1
		
	if(conversionkit && A.is_screwdriver(user))
		to_chat(user, "<span class='notice'>You screw [conversionkit] loose.</span>")
		user.put_in_hands(conversionkit)
		conversionkit = null
		update_icon()
		fire_delay = initial(fire_delay)
		return 1
	..()
	
/obj/item/weapon/gun/projectile/glock/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	if(conversionkit)
		var/shots_fired = 0
		var/to_shoot = getAmmo() //magdump
		var/atom/originaltarget = target
		for(var/i = 1 to to_shoot)
			..()
			shots_fired++
			if(!user.contents.Find(src) || jammed)
				break
			if(prob(2 * shots_fired / 5)) //increasing chance to jam
				jammed = 1 //Someone should write a nicer Jam() proc
				user.visible_message("*click click*", "<span class='danger'>*click*</span>")
				playsound(user, empty_sound, 100, 1)
				chambered = null //there's no indication of the jam otherwise
				update_icon()
				break
			if(shots_fired > 3) //burst flies all over the place
				target = get_inaccuracy(originaltarget, clamp(recoil, 0, 1))
			recoil += min(shots_fired / 4, 1)
		recoil = initial(recoil)
		return 1
	else
		.=..()

/obj/item/weapon/gun/projectile/glock/failure_check(var/mob/living/carbon/human/M)
	if(conversionkit && prob(1))
		Fire(M,M)
		return 1
	return ..()

/obj/item/weapon/gun/projectile/glock/fancy
	name = "\improper NT Glock Custom"
	icon_state = "secgunfancy"
	clowned = UNCLOWN

/obj/item/weapon/gun/projectile/glock/fancy/New()
	. = ..()
	desc += "<br><span class='notice'>This one has a sweet platinum-plated slide, and tritium night sights for maintenance crawling!</span>"

/obj/item/weapon/gun/projectile/glock/fancy/update_icon()
	..()
	icon_state = "secglockfancy[chambered ? "" : "-e"][silenced ? "-s" : ""][stored_magazine ? "" : "-m"]"

/obj/item/weapon/gun/projectile/glock/lockbox
	max_shells = 0
	spawn_mag = FALSE

/obj/item/weapon/gun/projectile/luger
	name = "\improper Luger P08"
	desc = "The wrath of the SS"
	icon_state = "p08"
	max_shells = 8
	origin_tech = "combat=2;materials=2"
	caliber = list(MM9 = 1)
	silenced = 0
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	mag_type = "/obj/item/ammo_storage/magazine/mc9mm"
	load_method = 2

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/luger/update_icon()
	..()
	icon_state = "[initial(icon_state)][stored_magazine ? "" : "empty"]"

/obj/item/weapon/gun/projectile/luger/small
	desc = "The wrath of the SS. Now in extra-concealed size for civilian uses!"
	w_class = W_CLASS_SMALL

/obj/item/weapon/gun/projectile/beretta
	name = "\improper Beretta 92FS"
	desc = "The classic wonder nine and favorite of the undercover cop. Kong whiskey not included."
	icon = 'icons/obj/beretta.dmi'
	icon_state = "beretta"
	max_shells = 15
	caliber = list(MM9 = 1)
	silenced = 0
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	mag_type = "/obj/item/ammo_storage/magazine/beretta"
	load_method = 2
	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/beretta/update_icon()
	..()
	icon_state = "beretta[chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automag
	name = "\improper Automag VI"
	desc = "It also doubles as a fingerprint removal tool."
	icon_state = "automag"
	max_shells = 7
	caliber = list(POINT357 = 1)
	silenced = 0
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=3;" + Tc_SYNDICATE + "=3"
	ammo_type = "/obj/item/ammo_casing/a357"
	mag_type = "/obj/item/ammo_storage/magazine/a357"
	load_method = 2
	recoil = 3
	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/automag/update_icon()
	..()
	icon_state = "automag[chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automag/prestige
	name = "\improper Prestige Automag VI"
	desc = "It also doubles as a fingerprint removal tool. This one is made to look more like the original AutomagIV from the 20th century."
	icon_state = "automag-prestige"

/obj/item/weapon/gun/projectile/automag/prestige/update_icon()
	..()
	icon_state = "automag-prestige[chambered ? "" : "-e"]"
