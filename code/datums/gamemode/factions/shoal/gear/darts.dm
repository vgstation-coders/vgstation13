///////////////////////////////////////////////
//
//				DARTS
//
///////////////////////////////////////////////


/obj/item/ammo_casing/dart
	name = "dart"
	desc = "A dart."
	icon = 'icons/obj/shoal.dmi'
	item_state = "syringe_0"
	icon_state = "dart_0"
	hitsound = 'sound/weapons/toolhit.ogg'
	sharpness = 1
	force = 3
	sharpness_flags = SHARP_TIP
	flags = FPRINT | NOREACT
	starting_materials = list(MAT_GLASS = 1000, MAT_IRON = 1000)
	attack_verb = list("stabs", "sticks", "pokes")
	caliber = DART
	projectile_type = /obj/item/projectile/dart
	w_type = RECYK_METAL

/obj/item/ammo_casing/dart/New()
	..()
	create_reagents(15)			// 15 unit volume.

// Raiders can label their darts, for fun.
/obj/item/ammo_casing/dart/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		set_tiny_label(user)


/obj/item/ammo_casing/dart/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] starts stabbing himself in the neck with [src]! It looks like \he's trying to commit suicide!</span>")
	user.audible_scream()
	for(var/i=1, i<=rand(2,4), i++)
		user.spray_blood(pick(cardinal),rand(1,5))
		playsound(user, 'sound/weapons/toolhit.ogg', 30, 1)
		playsound(user, get_sfx("gib"),40,1)
		user.apply_damage(25, BRUTE, LIMB_HEAD)
		sleep(5)
	inject(user)
	user.death()
	user.Life()
	return SUICIDE_ACT_CUSTOM

/obj/item/ammo_casing/dart/on_reagent_change()
	..()
	update_icon()

/obj/item/ammo_casing/dart/attack(mob/M, mob/user, def_zone)
	if(..())
		if(clumsy_check(user) && prob(50))
			to_chat(user, "<span class='warning'>Your footing slips and you stab yourself in the knee!</span>")
			inject(user, def_zone)
			return
		inject(M, def_zone)

/obj/item/ammo_casing/dart/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	. = ..()

/obj/item/ammo_casing/dart/update_icon()
	if(reagents)
		var/rounded_vol = round(reagents.total_volume,5)
		if(0 < reagents.total_volume && reagents.total_volume < 5)
			rounded_vol = 5
		overlays.len = 0

		icon_state = "dart_[rounded_vol]"
		item_state = "syringe_[rounded_vol]"

		if(reagents.total_volume)
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")
			filling.icon_state = "syringe[rounded_vol]"
			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling
	else
		icon_state = "dart_0"
		item_state = "syringe_0"


//////////// TODO
//////////// Instead of simply adding the dart as an implant, consider improving the code for embedded objects (currently only mob cubes use it)
//////////// There's a lot of leftover code for embedded stuff, including a HUD icon.
//////////// Maybe these darts can literally be removed by (alt clicking) on a person/yourself, with some pain if not using a hemostat
//////////// It would be funny to see darts sticking out of people like a pincushion too.

/obj/item/ammo_casing/dart/proc/inject(var/mob/living/target, var/embed_limb)
	reagents.trans_to(target, reagents.total_volume)		// Juice them up!
	var/datum/organ/external/organ = target.get_organ(embed_limb ? embed_limb : LIMB_CHEST)		// If no limb was specified, use the torso.
	if(organ)
		target.visible_message("<span class='warning'>[src] embeds itself in [target]'s [organ.display_name]!</span>", \
			self_message = "<span class='danger'>[src] embeds itself in your [organ.display_name]!</span>", \
			drugged_message = "<span class='good'>[target] gets pumped full of love!</span>")
		if(istype(loc, /mob))
			var/mob/M = loc
			M.drop_item(src, target, TRUE)
		else
			forceMove(target)
		organ.implants += src
		add_blood(target)
	else	// If there's no limb to target, we just give up and die.
		target.visible_message("<span class='warning'>[target] is hit by [src]!</span>", \
			self_message = "<span class='danger'>You're hit by [src]!</span>", \
			drugged_message = "<span class='good'>[target] gets pumped full of love!</span>")
		qdel(src)


///////////////////////////////////////////////
//
//				DART PROJECTILES
//
///////////////////////////////////////////////


// Not to be confused with /obj/item/projectile/bullet/dart AKA shotgun darts.

/obj/item/projectile/dart
	name = "dart"
	icon_state = "syringe"
	damage = 5
	phase_type = null
	penetration = 0
	fire_sound = 'sound/items/syringeproj.ogg'
	travel_range = 6
	custom_impact = TRUE
	decay_type = null 		// Set to an instance of /obj/item/ammo_casing/dart on fire.

	var/obj/item/ammo_casing/dart/source_dart

/obj/item/projectile/dart/New(atom/A)
	..()
	if(istype(loc, /obj/item/ammo_casing/dart))		// Are we inside a casing right now?
		source_dart = loc
		name = source_dart.name
	else														// This should not happen under normal circumstances, but might occur from guns like a roulette revolver.
		source_dart = new /obj/item/ammo_casing/dart(src)		// In that case, we just conjure up an empty dart out of thin air and shove it inside us.

	decay_type = source_dart 									// Our decay type should be the source dart, so it's dropped if we reach our maximum range.


// This feels jank. It might be better to just have a SHOOTCASINGS gun_flag for projectile weapons. But projectile code is already such as mess.
/obj/item/projectile/dart/OnFired(proj_target)
	if(source_dart.loc != src)											// If our source dart isn't already inside us, move it to us.
		source_dart.forceMove(src)
	source_dart.BB = new source_dart.projectile_type(source_dart)		// Reload the dart with a new projectile, so that it can be fired again when it was retrieved.


/obj/item/projectile/dart/on_hit(atom/A as mob|obj|turf|area)
	if(!A)
		return
	if(!..())
		return FALSE
	if(ismob(A))
		var/mob/M = A

		// Skeletons, liches, and golemns don't care about darts since they can't be injected. God help you if it's halloween season.
		// Maybe make them pass through sketons and liches instead, since they're... basically just bones?
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && (H.species.chem_flags & NO_INJECT))
				H.visible_message("<span class='warning'>\The [src] bounces harmlessly off of \the [H].</span>", "<span class='notice'>\The [src] bounces off you harmlessly and breaks as it hits the ground.</span>")
				return

		//Reagent logging, same as the syringe gun does it.
		if(reagents.total_volume)
			var/R
			for(var/datum/reagent/E in reagents.reagent_list)
				R += E.id + " ("
				R += num2text(E.volume) + "),"
			M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with \a <b>[src]</b> ([R])"
			firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with \a <b>[src]</b> ([R])"
			msg_admin_attack("[firer] ([firer.ckey]) shot [M] ([M.ckey]) with \a [src] ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")


		source_dart.inject(M, def_zone)		// In we go!




///////////////////////////////////////////////
//
//				DARTGUNS
//
///////////////////////////////////////////////


/obj/item/weapon/gun/projectile/dartgun
	name = "dart gun"
	desc = "A small gas-powered dartgun, capable of delivering chemical cocktails swiftly across short distances. Dials allow you to specify how much of the loaded chemicals to fire at once."
	icon_state = "dartgun-empty"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/dartgun.ogg'

	ammo_type ="/obj/item/ammo_casing/dart"
	mag_type = "/obj/item/ammo_storage/magazine/dart_cartridge"
	caliber = list(DART = 1)

	load_method = 2		// 2 = Magazine loaded. Not sure why the define won't work here.
	force = 10
	recoil = FALSE
	ejectshell = FALSE		// I'm pretty sure this variable does nothing and that this behavior is handled by the (lack of the) EMPTYCASINGS flag
	gun_flags = AUTOMAGDROP

/obj/item/weapon/gun/projectile/dartgun/isHandgun()
	return TRUE

/obj/item/weapon/gun/projectile/dartgun/update_icon()
	if(!stored_magazine)
		icon_state = "dartgun-empty"
		return 1

	if(!stored_magazine.stored_ammo.len)
		icon_state = "dartgun-0"
	else if(stored_magazine.stored_ammo.len > 5)
		icon_state = "dartgun-5"
	else
		icon_state = "dartgun-[stored_magazine.stored_ammo.len]"
	return 1

/obj/item/weapon/gun/projectile/dartgun/New()
	..()
	update_icon()

///////////////////////////////////////////////
//
//			CARTRIDGES AND BOXES
//
///////////////////////////////////////////////

/obj/item/ammo_storage/magazine/dart_cartridge
	name = "dart cartridge"
	desc = "A rack of darts."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "darts"
	item_state = "rcdammo"
	origin_tech = Tc_SYNDICATE + "=2;" + Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	w_class = W_CLASS_SMALL

	caliber = DART
	max_ammo = 5
	starting_ammo = 0
	multiple_sprites = TRUE
	exact = TRUE
	ammo_type = "/obj/item/ammo_casing/dart"

/obj/item/ammo_storage/box/darts
	name = "dart box"
	desc = "A box of empty darts. Holds 15 darts."
	icon_state = "9mmred"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/dart"
	caliber = DART
	max_ammo = 15
