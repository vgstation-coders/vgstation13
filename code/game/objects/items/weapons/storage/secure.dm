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
	var/locked = 1
	var/id_locked = 0
	var/code = "" // The entered code
	var/lastguess_code // Last guessed code
	var/l_code = null // The set code
	var/obscurecode_text // The partially starred out code from emagging, keeping it consistent here
	var/l_set = 0 // Code set?
	var/l_setshort = 0 // Memory reset?
	var/l_hacking = 0 // Hacking lock to prevent spam
	var/emagged = 0
	var/open = 0
	req_access = list(access_all_personal_lockers) // For personalised ID locking
	var/registered_name = null
	w_class = W_CLASS_MEDIUM
	fits_max_w_class = W_CLASS_SMALL
	max_combined_w_class = 14

/obj/item/weapon/storage/secure/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>The service panel is [open ? "open" : "closed"].</span>")

/obj/item/weapon/storage/secure/AltClick()
	if(!locked)
		..()

/obj/item/weapon/storage/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
		if(istype(W, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/I = W
			if(!I || !I.registered_name)
				return
			if(allowed(user) || registered_name || (registered_name == I.registered_name)) //they can open all of these, or nobody owns this, or they own this
				if(!registered_name && I.registered_name)
					registered_name = I.registered_name
					desc = "Owned by [I.registered_name]."
					visible_message("<span class='notice'>[bicon(src)] \The [src] beeps: Registered name synced to service panel. Welcome, [registered_name]</span>")
					return
				id_locked = !id_locked
				to_chat(user,"<span class='notice'>You toggle the ID lock on the service panel.</span>")
				return
			else
				to_chat(user, "<span class='warning'>Access Denied.</span>")
				return
		if (W.is_screwdriver(user))
			if(!id_locked)
				open =! open
				to_chat(user,"<span class='notice'>You [open ? "open" : "close"] the service panel.</span>")
				return
			else
				to_chat(user, "<span class='warning'>Access Denied.</span>")
				return
		if (istype(W, /obj/item/device/multitool))
			if (open == 1 && !l_hacking)
				visible_message("<span class='notice'>[bicon(src)] \The [src] beeps: Now attempting to reset internal memory, please hold.</span>")
				l_hacking = 1
				if (do_after(usr, src, 100))
					if (prob(40))
						l_setshort = 1
						l_set = 0
						visible_message("<span class='notice'>[bicon(src)] \The [src] beeps: Internal memory reset.  Please give it a few seconds to reinitialize.</span>")
						sleep(80)
						l_setshort = 0
						l_hacking = 0
					else
						visible_message("<span class='warning'>[bicon(src)] \The [src] beeps: Unable to reset internal memory.</span>")
						l_hacking = 0
				else
					l_hacking = 0
				return
			else if (emagged && lastguess_code)
				var/correct = 0
				for(var/i = 1, i <= length(lastguess_code); i++)
					if(lastguess_code[i] == l_code[i])
						correct++
				visible_message("<span class='notice'>[bicon(src)] \The [src] hisses: &*%$PASSCODE MATCH: [correct].</span>")
				return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	// -> storage/attackby() what with handle insertion, etc
	. = ..()

/obj/item/weapon/storage/secure/emag_act()
	if(locked && !emagged && l_code)
		emagged = 1
		overlays += image('icons/obj/storage/storage.dmi', icon_sparking)
		visible_message("<span class='warning'>[bicon(src)] \The [src] beeps: Encryption module runtime. Partial code obscurity failure.</span>")
		obscurecode_text = stars(l_code,pick(40,60))
		sleep(6)
		overlays.len = 0
		overlays += image('icons/obj/storage/storage.dmi', icon_locking)

/obj/item/weapon/storage/secure/emp_act(severity)
	var/unlockprob = 0
	switch(severity)
		if(1)
			unlockprob = 10
		if(2)
			unlockprob = 5
	if(prob(unlockprob) && id_locked)
		id_locked = 0
		visible_message("<span class='warning'>[bicon(src)] \The [src] hisses: ^&^$%^&*&^$^&NAMELOCK FAILURE&*%$£%&*^*&*^*&^&*^*&.</span>")

/obj/item/weapon/storage/secure/MouseDropFrom(over_object, src_location, over_location)
	if (locked)
		if(Adjacent(usr))
			add_fingerprint(usr)
		return
	..()


/obj/item/weapon/storage/secure/attack_self(mob/user)
	showInterface(user)

/obj/item/weapon/storage/secure/proc/showInterface(mob/user)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((l_set == 0) && (!emagged) && (!l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (emagged)
		dat += text("<p>\n<font color=red><b>ENCRYPTION SYSTEM ERROR - 1701. 01000111&%^$PASSCODE^&%$$ [obscurecode_text]</b></font>")
	if (l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", code)
	if (!locked)
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
			if ((l_set == 0) && (length(code) == 5) && (!l_setshort) && (code != "ERROR"))
				l_code = code
				l_set = 1
			else if ((code == l_code) && (l_set == 1))
				locked = 0
				overlays = null
				emagged = 0
				overlays += image('icons/obj/storage/storage.dmi', icon_opened)
				code = null
			else
				lastguess_code = code
				code = "ERROR"
		else
			if ((href_list["type"] == "R") && (!l_setshort))
				locked = 1
				overlays = null
				code = null
				close(usr)
			else
				code += text("[]", href_list["type"])
				if (length(code) > 5)
					code = "ERROR"
		add_fingerprint(usr)
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

/obj/item/weapon/storage/secure/briefcase/paperpen/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/briefcase/attack_hand(mob/user as mob)
	if ((loc == user) && (locked == 1))
		to_chat(user, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if ((loc == user) && (!locked))
		if(!stealthy(user))
			playsound(src, "rustle", 50, 1, -5)
		if (user.s_active)
			user.s_active.close(user) //Close and re-open
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				close(M)
		orient2hud(user)
	add_fingerprint(user)

/obj/item/weapon/storage/secure/briefcase/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/Topic(href, href_list)
	..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/update_icon()
	if(locked || emagged)
		item_state = "secure-r"
	else
		item_state = "secure-g"

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

	//I consider this worthless but it isn't my code so whatever.  Remove or uncomment.
	/*attack(mob/M as mob, mob/living/user as mob)
		if (clumsy_check(user) && prob(50))
			to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
			user.take_organ_damage(10)
			user.Paralyse(2)
			return

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to attack [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>")

		var/t = user:zone_sel.selecting
		if (t == LIMB_HEAD)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
					if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
						to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
						return
					var/time = rand(2, 6)
					if (prob(75))
						H.Paralyse(time)
					else
						H.Stun(time)
					if(H.stat != 2)
						H.stat = 1
					for(var/mob/O in viewers(H, null))
						O.show_message(text("<span class='danger'>[] has been knocked unconscious!</span>", H), 1, "<span class='warning'>You hear someone fall.</span>", 2)
				else
					to_chat(H, text("<span class='warning'>[] tried to knock you unconcious!</span>",user))
					H.eye_blurry += 3

		return*/

/obj/item/weapon/storage/secure/briefcase/assassin/New()
	..()
	for(var/i = 1 to 3)
		new /obj/item/weapon/spacecash/c1000(src)
	new /obj/item/weapon/gun/energy/crossbow(src)
	new /obj/item/weapon/gun/projectile/mateba(src)
	new /obj/item/ammo_storage/box/a357(src)
	new /obj/item/weapon/c4(src)

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

/obj/item/weapon/storage/secure/safe/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/safe/attack_hand(mob/user as mob)
	if(!locked)
		if(user.s_active)
			user.s_active.close(user) //Close and re-open
		show_to(user)
	showInterface(user)

// Clown planet WMD storage
/obj/item/weapon/storage/secure/safe/clown
	name="WMD Storage"

/obj/item/weapon/storage/secure/safe/clown/New()
	for(var/i=0;i<10;i++)
		new /obj/item/weapon/reagent_containers/food/snacks/pie(src)

/obj/item/weapon/storage/secure/safe/HoS/New()
	..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)
