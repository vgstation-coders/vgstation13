/*
 *	Absorbs /obj/item/weapon/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/weapon/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/code_locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/open = 0
	w_class = W_CLASS_MEDIUM
	fits_max_w_class = W_CLASS_SMALL
	max_combined_w_class = 14

/obj/item/weapon/storage/secure/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>The service panel is [src.open ? "open" : "closed"].</span>")

/obj/item/weapon/storage/secure/AltClick()
	if(!code_locked)
		..()

/obj/item/weapon/storage/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(code_locked)
		if (W.is_screwdriver(user))
			if (do_after(user, src, 20))
				src.open =! src.open
				user.show_message(text("<span class='notice'>You [] the service panel.</span>", (src.open ? "open" : "close")))
			return
		if ((istype(W, /obj/item/device/multitool)) && (src.open == 1)&& (!src.l_hacking))
			user.show_message(text("<span class='warning'>Now attempting to reset internal memory, please hold.</span>"), 1)
			src.l_hacking = 1
			if (do_after(usr, src, 100))
				if (prob(40))
					src.l_setshort = 1
					src.l_set = 0
					user.show_message(text("<span class='warning'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>"), 1)
					sleep(80)
					src.l_setshort = 0
					src.l_hacking = 0
				else
					user.show_message(text("<span class='warning'>Unable to reset internal memory.</span>"), 1)
					src.l_hacking = 0
			else
				src.l_hacking = 0
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	// -> storage/attackby() what with handle insertion, etc
	. = ..()

/obj/item/weapon/storage/secure/emag_act(mob/user)
	if(code_locked && !emagged)
		emagged = 1
		src.overlays += image('icons/obj/storage/storage.dmi', icon_sparking)
		sleep(6)
		overlays.len = 0
		overlays += image('icons/obj/storage/storage.dmi', icon_locking)
		code_locked = 0
		to_chat(user, "You short out the lock on [src].")

/obj/item/weapon/storage/secure/MouseDropFrom(over_object, src_location, over_location)
	if (code_locked)
		if(Adjacent(usr))
			src.add_fingerprint(usr)
		return
	..()


/obj/item/weapon/storage/secure/attack_self(mob/user)
	showInterface(user)

/obj/item/weapon/storage/secure/proc/showInterface(mob/user)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.code_locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (src.emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if (src.l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if (!src.code_locked)
		message = "*****"
	dat += {"<HR><br/>>[message]<BR>\n
		<A href='?src=\ref[src];type=1'>1</A>-<A href='?src=\ref[src];type=2'>2</A>-<A href='?src=\ref[src];type=3'>3</A><BR>\n
		<A href='?src=\ref[src];type=4'>4</A>-<A href='?src=\ref[src];type=5'>5</A>-<A href='?src=\ref[src];type=6'>6</A><BR>\n
		<A href='?src=\ref[src];type=7'>7</A>-<A href='?src=\ref[src];type=8'>8</A>-<A href='?src=\ref[src];type=9'>9</A><BR>\n
		<A href='?src=\ref[src];type=R'>R</A>-<A href='?src=\ref[src];type=0'>0</A>-<A href='?src=\ref[src];type=E'>E</A><BR>\n</TT>"}
	user << browse(dat, "window=caselock;size=300x280")

/obj/item/weapon/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
				src.code_locked = 0
				src.overlays = null
				overlays += image('icons/obj/storage/storage.dmi', icon_opened)
				src.code = null
			else
				src.code = "ERROR"
		else
			if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
				src.code_locked = 1
				src.overlays = null
				src.code = null
				src.close(usr)
			else
				src.code += text("[]", href_list["type"])
				if (length(src.code) > 5)
					src.code = "ERROR"
		src.add_fingerprint(usr)
		showInterface(usr) //refresh!

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage/storage.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	icon_state = "secure"
	item_state = "secure-r"
	desc = "A large briefcase with a digital locking system."
	origin_tech = Tc_MATERIALS + "=2;" + Tc_MAGNETS + "=2;" + Tc_PROGRAMMING + "=1"
	flags = FPRINT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_MEDIUM
	max_combined_w_class = 16
	hitsound = "swing_hit"
	var/obj/item/weapon/handcuffs/casecuff = null


/obj/item/weapon/storage/secure/briefcase/MouseDropFrom(over_object, src_location, over_location)
	if(istype(over_object, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = over_object
		if(target.is_holding_item(src) && !target.stat && !target.restrained())
			if(cant_drop && !casecuff) //so you can't bypass glue this way
				..()
				return
			if(casecuff)
				playsound(target.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
				target.visible_message("<span class='notice'>\The [target] uncuffs \the [src] from \his wrist.</span>", "<span class='notice'>You uncuff \the [src] from your wrist.</span>", "<span class='notice'>You hear two ratcheting clicks.</span>")
				casecuff.forceMove(target) //Exited() gets called, stuff happens there
			else
				if(!target.mutual_handcuffs && target.find_held_item_by_type(/obj/item/weapon/handcuffs)) //need handcuffs in their hands to do this
					var/cuffslot = target.find_held_item_by_type(/obj/item/weapon/handcuffs)
					var/obj/item/weapon/handcuffs/cuffinhand = target.held_items[cuffslot]
					if(target.drop_item(cuffinhand, src))
						casecuff = cuffinhand
						playsound(target.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
						target.visible_message("<span class='notice'>\The [target] cuffs \the [src] to \his wrist with \the [casecuff].</span>", "<span class='notice'>You cuff \the [src] to your wrist with \the [casecuff].</span>", "<span class='notice'>You hear two ratcheting clicks.</span>")
						if(istype(casecuff, /obj/item/weapon/handcuffs/syndicate))
							var/obj/item/weapon/handcuffs/syndicate/syncuff = casecuff
							if(syncuff.mode == SYNDICUFFS_ON_APPLY && !syncuff.charge_detonated)
								if(syncuff.charge_detonated) //this is bad but syndicuffs are not meant for this sort of stuff
									return
								syncuff.charge_detonated = TRUE
								sleep(3)
								explosion(get_turf(target), 0, 1, 3, 0)
								QDEL_NULL(casecuff)
								return
						canremove = 0 //can't drop the case
						cant_drop = 1
						casecuff.canremove = 0 //can't strip the cuffs off either
						casecuff.cant_drop = 1 //but it'll fall off if their wrist falls off :)
						target.mutual_handcuffs = casecuff
						casecuff.invisibility = INVISIBILITY_MAXIMUM
						var/mutable_appearance/handcuff_overlay = mutable_appearance('icons/obj/cuffs.dmi', "singlecuff[cuffslot]", -HANDCUFF_LAYER)
						handcuff_overlay.pixel_x = target.species.inventory_offsets["[cuffslot]"]["pixel_x"] * PIXEL_MULTIPLIER
						handcuff_overlay.pixel_y = target.species.inventory_offsets["[cuffslot]"]["pixel_y"] * PIXEL_MULTIPLIER
						target.overlays += target.overlays_standing[HANDCUFF_LAYER] = handcuff_overlay
						close_all()
						storage_locked = TRUE
				else
					to_chat(target, "<span class='warning'>You can't cuff \the [src] to your wrist without something to cuff with.</span>")

	if(code_locked)
		if(Adjacent(usr))
			src.add_fingerprint(usr)
		return
	..()

/obj/item/weapon/storage/secure/briefcase/Exited(atom/movable/Obj) //the casecuffs are stored invisibly in the case
	if(casecuff && Obj == casecuff)  //when stripped, they get forcemoved from the case, that's why this works
		var/mob/living/carbon/human/target = loc
		target.mutual_handcuffs = null
		target.overlays -= target.overlays_standing[HANDCUFF_LAYER]
		casecuff.invisibility = initial(casecuff.invisibility)
		canremove = 1
		cant_drop = 0
		casecuff.forceMove(target.loc) //otherwise the cuff copy ghosts show up
		casecuff.on_restraint_removal(target) //for syndicuffs
		casecuff = null
		storage_locked = FALSE
	..()

/obj/item/weapon/storage/secure/briefcase/paperpen
	items_to_spawn = list(
		/obj/item/weapon/paper,
		/obj/item/weapon/pen,
	)

/obj/item/weapon/storage/secure/briefcase/paperpen/dropped(mob/user)
	..()
	if(casecuff)
		var/mob/living/carbon/human/uncuffed = user
		uncuffed.mutual_handcuffs = null
		uncuffed.overlays -= uncuffed.overlays_standing[HANDCUFF_LAYER]
		casecuff.invisibility = 0
		casecuff.forceMove(user.loc)
		canremove = 1
		cant_drop = 0
		casecuff.on_restraint_removal(uncuffed) //for syndicuffs
		casecuff = null
		storage_locked = FALSE

/obj/item/weapon/storage/secure/briefcase/attack_hand(mob/user as mob)
	if ((src.loc == user) && (src.code_locked == 1))
		to_chat(user, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if ((src.loc == user) && (!src.code_locked))
		if(!stealthy(user))
			playsound(src, "rustle", 50, 1, -5)
		if (user.s_active)
			user.s_active.close(user) //Close and re-open
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
		src.orient2hud(user)
	src.add_fingerprint(user)

/obj/item/weapon/storage/secure/briefcase/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/Topic(href, href_list)
	..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/update_icon()
	if(code_locked || emagged)
		item_state = "secure-r"
	else
		item_state = "secure-g"

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/weapon/storage/secure/briefcase/assassin
	items_to_spawn = list(
		/obj/item/weapon/spacecash/c1000 = 3,
		/obj/item/weapon/gun/energy/crossbow,
		/obj/item/weapon/gun/projectile/mateba,
		/obj/item/ammo_storage/box/a357,
		/obj/item/weapon/c4,
	)

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/weapon/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	flags = FPRINT
	force = 8.0
	w_class = 8.0
	fits_max_w_class = 8
	anchored = 1.0
	density = 0
	cant_hold = list("/obj/item/weapon/storage/secure/briefcase")
	items_to_spawn = list(
		/obj/item/weapon/paper,
		/obj/item/weapon/pen,
	)

/obj/item/weapon/storage/secure/safe/attack_hand(mob/user as mob)
	if(!code_locked)
		if(user.s_active)
			user.s_active.close(user) //Close and re-open
		show_to(user)
	showInterface(user)

// Clown planet WMD storage
/obj/item/weapon/storage/secure/safe/clown
	name="WMD Storage"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/pie = 10)

/obj/item/weapon/storage/secure/safe/HoS
	//items_to_spawn = list(/obj/item/weapon/storage/lockbox/clusterbang) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)
