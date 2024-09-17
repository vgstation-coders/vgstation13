#define SPEEDLOADER 0 //the gun takes bullets directly
#define FROM_BOX 1
#define MAGAZINE 2 //the gun takes a magazine into gun storage

/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses .357 ammo."
	name = "revolver"
	icon_state = "revolver"
	caliber = list(POINT357 = 1)
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	recoil = 1
	kick_fire_chance = 5
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/list/loaded = list()
	var/max_shells = 7 //only used by guns with no magazine
	var/load_method = SPEEDLOADER //0 = Single shells or quick loader, 1 = box, 2 = magazine
	var/obj/item/ammo_storage/magazine/stored_magazine = null
	var/obj/item/ammo_casing/chambered = null
	var/mag_type = ""
	var/list/mag_type_restricted = list() //better magazine manipulation
	var/list/magwellmod = list() //this holds the magtype restriction when a mod is applied
	var/image/magazine_overlay = null //holds a copy of the overlay for the currently loaded magazine, for manipulation
	var/mag_drop_sound ='sound/weapons/magdrop_1.ogg'
	var/automagdrop_delay_time = 5 // delays the automagdrop
	var/spawn_mag = TRUE
	var/reloadsound = 'sound/items/Deconstruct.ogg'
	var/casingsound = 'sound/weapons/casing_drop.ogg'
	var/gun_flags = EMPTYCASINGS	//Yay, flags
	var/scoped //a reference to a scope object
	var/list/refuse = list() //made to store spent casings in chamber

/obj/item/weapon/gun/projectile/isHandgun() //fffuuuuuuck non-abstract base types
	return TRUE

/obj/item/weapon/gun/projectile/New()
	..()
	if(mag_type && load_method == 2 && spawn_mag)
		stored_magazine = new mag_type(src)
		chamber_round()
	else
		for(var/i = 1, i <= max_shells, i++)
			if(ammo_type)
				loaded += new ammo_type(src)
	if(gun_flags & MAG_OVERLAYS)
		mag_overlay()
	update_icon()
	return

//loads the argument magazine into the gun
/obj/item/weapon/gun/projectile/proc/LoadMag(var/obj/item/ammo_storage/magazine/AM, var/mob/user)
	if(istype(AM, text2path(mag_type)) && !stored_magazine)
		for(var/T in mag_type_restricted)
			if (istype(AM, T))
				return 0
		if(user)
			if(user.drop_item(AM, src))
				to_chat(usr, "<span class='notice'>You load [AM] into \the [src].</span>")
			else
				return

		stored_magazine = AM
		chamber_round()
		AM.update_icon()
		if(src.gun_flags & MAG_OVERLAYS)
			mag_overlay()
		update_icon()

		if(user)
			user.update_inv_hands()
		return 1
	return 0

/obj/item/weapon/gun/projectile/proc/RemoveMag(var/mob/user)
	if(stored_magazine)
		if(jammed)
			to_chat(usr, "<span class='notice'>You begin unjamming \the [name]...</span>")
			if(do_after(usr,src,50))
				jammed = 0
				in_chamber = null
				var/dropped_bullets
				var/to_drop = rand(stored_magazine.max_ammo/4, stored_magazine.max_ammo/3)
				for(var/i = 1; i<=min(to_drop, stored_magazine.stored_ammo.len); i++)
					var/obj/item/ammo_casing/AC = stored_magazine.stored_ammo[1]
					stored_magazine.stored_ammo -= AC
					AC.forceMove(user.loc)
					dropped_bullets++
					stored_magazine.update_icon()
				var/droppedwords = dropped_bullets ? "" : ", and spill [dropped_bullets] bullet\s in the process"
				to_chat(usr, "<span class='notice'>You unjam the [name][droppedwords].</span>")
				chamber_round()
				update_icon()
				return 0
			return 0
		stored_magazine.forceMove(get_turf(src.loc)) //this first drops the magazine onto the turf, it's here in case there is no applicable user
		if(user)
			if(user.put_in_any_hand_if_possible(stored_magazine)) //if you have empty hands, you'll get the mag
				user.put_in_hands(stored_magazine)
				to_chat(usr, "<span class='notice'>You pull [stored_magazine] out of \the [src]!</span>")
			else
				stored_magazine.forceMove(user.loc) //otherwise, it drops to the place you are existing
				to_chat(usr, "<span class='notice'>You drop [stored_magazine] out of \the [src]!</span>")
		stored_magazine.update_icon()
		stored_magazine = null
		if(src.gun_flags & MAG_OVERLAYS)
			mag_overlay()
		update_icon()
		if(user)
			user.update_inv_hands()
		return 1
	return 0

/obj/item/weapon/gun/projectile/verb/force_removeMag()
	set name = "Remove Ammo / Magazine"
	set category = "Object"
	set src in range(0)
	if(usr.incapacitated())
		to_chat(usr, "<span class='rose'>You can't do this!</span>")
		return
	if(stored_magazine)
		RemoveMag(usr)
	else
		to_chat(usr, "<span class='rose'>There is no magazine to remove!</span>")


/obj/item/weapon/gun/projectile/proc/mag_overlay()
	if(stored_magazine)
		var/mag_sprite = initial(stored_magazine.icon_state)
		if(!magazine_overlay || magazine_overlay.icon_state != mag_sprite) 
			overlays -= magazine_overlay
			var/image/magazine_adjustment = image("icon" = 'icons/obj/gun_part.dmi', "icon_state" = mag_sprite)
			magazine_adjustment.pixel_x -= stored_magazine.magoffsetx
			magazine_adjustment.pixel_y -= stored_magazine.magoffsety
			if(stored_magazine.markingcolor)
				magazine_adjustment.icon += stored_magazine.markingcolor
			overlays += magazine_adjustment
			magazine_overlay = magazine_adjustment
			return
	else
		if(magazine_overlay)
			overlays -= magazine_overlay
			magazine_overlay = null
		

/obj/item/weapon/gun/projectile/proc/chamber_round() //Only used by guns with magazine
	if(chambered || !stored_magazine)
		return 0
	else
		var/obj/item/ammo_casing/round = stored_magazine.get_round()
		if(istype(round))
			chambered = round
			chambered.forceMove(src)
			return 1
	return 0

/obj/item/weapon/gun/projectile/proc/getAC()
	var/obj/item/ammo_casing/AC = null
	if(mag_type && load_method == 2)
		AC = chambered
	else if(getAmmo())
		AC = loaded[1] //load next casing.
	return AC

/obj/item/weapon/gun/projectile/process_chambered()
	var/obj/item/ammo_casing/AC = getAC()
	if(in_chamber)
		return 1 //{R}
	if(isnull(AC) || !istype(AC))
		return 0
	if(mag_type && load_method == 2)
		chambered = null //Remove casing from chamber.
		chamber_round()
	else
		loaded -= AC //Remove casing from loaded list.
	if(gun_flags &EMPTYCASINGS)
		if(gun_flags &CHAMBERSPENT)
			refuse += AC
		else
			var/mob/M = get_holder_of_type(src, /mob/)
			AC.forceMove(ismob(M) ? M.loc : get_turf(src.loc)) //special forceMove because this proc hate user so much it breaks if you try to use mob/user in arg
			playsound(AC, casingsound, 25, 1)
	if(AC.BB)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.forceMove(src) //Set projectile loc to gun.
		AC.BB = null //Empty casings
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/can_discharge()
	var/obj/item/ammo_casing/AC = getAC()
	if(in_chamber)
		return 1
	if(isnull(AC) || !istype(AC))
		return 0
	else
		return 1


/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/gun_part/silencer) && src.gun_flags & SILENCECOMP && !silenced)

		if(user.drop_item(A, src)) //put the silencer into the gun
			to_chat(user, "<span class='notice'>You screw [A] onto [src].</span>")
			silenced = A	//dodgy?
			w_class = W_CLASS_MEDIUM
			if(silencer_offset.len)
				var/image/silence_overlay = image("icon" = 'icons/obj/gun_part.dmi', "icon_state" = "[A.icon_state]_mounted")
				silence_overlay.pixel_x += silencer_offset[SILENCER_OFFSET_X]
				silence_overlay.pixel_y += silencer_offset[SILENCER_OFFSET_Y]
				overlays += silence_overlay
				gun_part_overlays += silence_overlay
			update_icon()
			user.update_inv_hands()
			return 1

	if(mag_type_restricted.len && istype(A, /obj/item/gun_part/universal_magwell_expansion_kit))
		if(user.drop_item(A, src))
			to_chat(user, "<span class='notice'>You apply [A] to [src]. It won't be coming off in one piece.</span>")
			magwellmod = mag_type_restricted
			mag_type_restricted = list()
			w_class = W_CLASS_MEDIUM
			update_icon()
			return 1

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_storage/magazine))
		var/obj/item/ammo_storage/magazine/AM = A
		if(load_method == MAGAZINE)
			if(!stored_magazine)
				LoadMag(AM, user)
			else
				to_chat(user, "<span class='rose'>There is already a magazine loaded in \the [src]!</span>")
		else
			to_chat(user, "<span class='rose'>You can't load \the [src] with a magazine, dummy!</span>")
	if(istype(A, /obj/item/ammo_storage) && load_method != MAGAZINE)
		var/obj/item/ammo_storage/AS = A
		var/success_load = AS.LoadInto(AS, src)
		if(success_load)
			to_chat(user, "<span class='notice'>You successfully fill the [src] with [success_load] shell\s from the [AS].</span>")
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		//message_admins("Loading the [src], with [AC], [AC.caliber] and [caliber.len]") //Enable this for testing
		if(AC.BB && caliber[AC.caliber]) // a used bullet can't be fired twice
			if(load_method == MAGAZINE && !chambered)
				if(user.drop_item(AC, src))
					chambered = AC
					num_loaded++
					playsound(src, reloadsound, 25, 1)
			else if((getAmmo() + getSpent()) < max_shells && load_method != MAGAZINE)
				if(user.drop_item(AC, src))
					loaded += AC
					num_loaded++
					playsound(src, reloadsound, 25, 1)

	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
	A.update_icon()
	update_icon()
	..()

	if(istype(A, /obj/item/gun_part/scope) && gun_flags & SCOPED)
		if(scoped)
			return
		if(user.drop_item(A, src))
			to_chat(user, "<span class='notice'>You attach \the [A] onto \the [src].</span>")
			scoped = A
			//var/datum/action/item_action/toggle_scope
			new /datum/action/item_action/toggle_scope(src)
			actions_types += /datum/action/item_action/toggle_scope
			update_icon()
			return

	if(A.is_screwdriver(user))
		if(magwellmod.len)
			mag_type_restricted = magwellmod
			magwellmod = list()
			to_chat(user, "<span class='notice'>You destroy the strange magwell attachment.</span>")
			return

/obj/item/weapon/gun/projectile/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (loaded.len || stored_magazine || refuse.len)
		if (load_method == SPEEDLOADER)
			if(!(gun_flags & CHAMBERSPENT))
				var/obj/item/ammo_casing/AC = loaded[1]
				loaded -= AC
				AC.forceMove(user.loc)
				to_chat(user, "<span class='notice'>You unload \the [AC] from \the [src]!</span>")
				update_icon()
			else
				for(var/obj/item/ammo_casing/AC in loaded)
					loaded -= AC
					AC.forceMove(user.loc)
					playsound(AC, casingsound, 25, 1)
				for(var/obj/item/ammo_casing/AC in refuse)
					refuse -= AC
					AC.forceMove(user.loc)
					playsound(AC, casingsound, 25, 1)
				to_chat(user, "<span class='notice'>You empty \the [src]!</span>")
			return
		if (load_method == MAGAZINE && stored_magazine)
			RemoveMag(user)
	else if(loc == user)
		if(chambered) // So it processing unloading of a bullet first
			var/obj/item/ammo_casing/AC = chambered
			AC.forceMove(user.loc)
			chambered = null
			to_chat(user, "<span class='notice'>You unload \the [AC] from \the [src]!</span>")
			update_icon()
			return
		if(silenced)
			RemoveAttach(usr)
			return
	else
		to_chat(user, "<span class='warning'>Nothing loaded in \the [src]!</span>")

/obj/item/weapon/gun/projectile/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	..()
	if(!chambered && stored_magazine && !stored_magazine.ammo_count() && gun_flags & AUTOMAGDROP) //auto_mag_drop decides whether or not the mag is dropped once it empties
		var/drop_me = stored_magazine // prevents dropping a fresh/different mag.
		spawn(automagdrop_delay_time)
			if((stored_magazine == drop_me) && (loc == user))	//prevent dropping the magazine if we're no longer holding the gun
				RemoveMag(user)
				if(mag_drop_sound)
					playsound(user, mag_drop_sound, 40, 1)

	return

/obj/item/weapon/gun/projectile/examine(mob/user)
	..()
	if(conventional_firearm)
		to_chat(user, "<span class='info'>Has [getAmmo()] round\s remaining.</span>")
	if(getSpent() > 0)
		to_chat(user, "<span class='info'>Has [getSpent()] round\s spent.</span>")
	if(istype(silenced, /obj/item/gun_part/silencer))
		var/obj/item/gun_part/silencer/A = silenced
		to_chat(user, "<span class='warning'>It has \a [A] attached to the barrel.</span>")
	if(magwellmod.len)
		to_chat(user, "<span class='warning'>There's something strange screwed into the magwell.</span>")

/obj/item/weapon/gun/projectile/proc/getAmmo()
	var/bullets = 0
	if(mag_type && load_method == 2)
		if(stored_magazine)
			bullets += stored_magazine.ammo_count()
		if(chambered)
			bullets++
	else
		for(var/obj/item/ammo_casing/AC in loaded)
			if(istype(AC))
				bullets += 1
	return bullets

/obj/item/weapon/gun/projectile/proc/getSpent()
	var/spent = 0
	for(var/obj/item/ammo_casing/AC in refuse)
		spent += 1
	return spent

/obj/item/weapon/gun/projectile/failure_check(var/mob/living/carbon/human/M)
	if(load_method == MAGAZINE && prob(3))
		jammed = 1
		M.visible_message("*click click*", "<span class='danger'>*click*</span>")
		playsound(M, empty_sound, 100, 1)
		return 0
	return ..()

/obj/item/weapon/gun/projectile/proc/RemoveAttach(var/mob/user)
	if(silenced)
		var/obj/item/gun_part/silencer/A = silenced
		for(var/image/ol in gun_part_overlays)
			if(ol.icon_state == "[A.icon_state]_mounted")
				overlays -= ol
				gun_part_overlays -= ol
		to_chat(user, "<span class='notice'>You unscrew [silenced] from [src].</span>")
		user.put_in_hands(silenced)
		silenced = 0
		w_class = W_CLASS_SMALL
	if(scoped)
		to_chat(user, "<span class='notice'>You release \the [scoped] from \the [src].</span>")
		user.put_in_hands(scoped)
		scoped = null
		actions_types -= /datum/action/item_action/toggle_scope
		for(var/datum/action/A in src.actions)
			if(istype(A, /datum/action/item_action/toggle_scope))
				qdel(A)
	update_icon()

/obj/item/weapon/gun/projectile/verb/RemoveAttachments()
	set name = "Remove Attachments"
	set category = "Object"
	set src in usr
	if(!usr.is_holding_item(src))
		to_chat(usr, "<span class='notice'>You'll need [src] in your hands to do that.</span>")
		return
	if(usr.incapacitated())
		to_chat(usr, "<span class='rose'>You can't do this!</span>")
		return
	if(istype(silenced, /obj/item/gun_part/silencer) || scoped)
		RemoveAttach(usr)
	else
		to_chat(usr, "<span class='rose'>There are no attachments to remove!</span>")

/obj/item/weapon/gun/projectile/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"chambered",
		"stored_magazine",
		"loaded")
	reset_vars_after_duration(resettable_vars, duration)
