/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = TRUE
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/open = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 14
	desc = "This shouldn't exist. If it does, create an issue report."

/obj/item/storage/secure/examine(mob/user)
	..()
	to_chat(user, text("The service panel is currently <b>[open ? "unscrewed" : "screwed shut"]</b>."))

/obj/item/storage/secure/attackby(obj/item/W, mob/user, params)
	if(locked)
		if (istype(W, /obj/item/screwdriver))
			if (W.use_tool(src, user, 20))
				open =! open
				to_chat(user, "<span class='notice'>You [open ? "open" : "close"] the service panel.</span>")
			return
		if (istype(W, /obj/item/wirecutters))
			to_chat(user, "<span class='danger'>[src] is protected from this sort of tampering, yet it appears the internal memory wires can still be <b>pulsed</b>.</span>")
		if ((istype(W, /obj/item/device/multitool)) && (!l_hacking))
			if(src.open == 1)
				to_chat(user, "<span class='danger'>Now attempting to reset internal memory, please hold.</span>")
				src.l_hacking = 1
				if (W.use_tool(src, user, 400))
					to_chat(user, "<span class='danger'>Internal memory reset - lock has been disengaged.</span>")
					src.l_set = 0
					src.l_hacking = 0
				else
					src.l_hacking = 0
			else
				to_chat(user, "<span class='notice'>You must <b>unscrew</b> the service panel before you can pulse the wiring.</span>")
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	// -> storage/attackby() what with handle insertion, etc
	return ..()

/obj/item/storage/secure/MouseDrop(over_object, src_location, over_location)
	if (locked)
		src.add_fingerprint(usr)
		to_chat(usr, "<span class='warning'>It's locked!</span>")
		return 0
	..()

/obj/item/storage/secure/attack_self(mob/user)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((src.l_set == 0) && (!src.l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (src.l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if (!src.locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=[REF(src)];type=1'>1</A>-<A href='?src=[REF(src)];type=2'>2</A>-<A href='?src=[REF(src)];type=3'>3</A><BR>\n<A href='?src=[REF(src)];type=4'>4</A>-<A href='?src=[REF(src)];type=5'>5</A>-<A href='?src=[REF(src)];type=6'>6</A><BR>\n<A href='?src=[REF(src)];type=7'>7</A>-<A href='?src=[REF(src)];type=8'>8</A>-<A href='?src=[REF(src)];type=9'>9</A><BR>\n<A href='?src=[REF(src)];type=R'>R</A>-<A href='?src=[REF(src)];type=0'>0</A>-<A href='?src=[REF(src)];type=E'>E</A><BR>\n</TT>", message)
	user << browse(dat, "window=caselock;size=300x280")

/obj/item/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if ((src.code == src.l_code) && (src.l_set == 1))
				src.locked = FALSE
				cut_overlays()
				add_overlay(icon_opened)
				src.code = null
			else
				src.code = "ERROR"
		else
			if ((href_list["type"] == "R") && (!src.l_setshort))
				src.locked = TRUE
				cut_overlays()
				src.code = null
				src.close(usr)
			else
				src.code += text("[]", sanitize_text(href_list["type"]))
				if (length(src.code) > 5)
					src.code = "ERROR"
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
			return
	return

/obj/item/storage/secure/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
		return null
	return ..()

/obj/item/storage/secure/can_be_inserted(obj/item/W, stop_messages = 0)
	if(locked)
		return 0
	return ..()


// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	desc = "A large briefcase with a digital locking system."
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/storage/secure/briefcase/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/briefcase/attack_hand(mob/user)
	if ((src.loc == user) && (src.locked == 1))
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
		add_fingerprint(user)
	else
		..()

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/PopulateContents()
	..()
	for(var/i = 0, i < storage_slots - 2, i++)
		new /obj/item/stack/spacecash/c1000(src)


// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	desc = "Excellent for securing things away from grubby hands."
	force = 8
	w_class = WEIGHT_CLASS_GIGANTIC
	max_w_class = 8
	anchored = TRUE
	density = FALSE
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/user)
	return attack_self(user)

/obj/item/storage/secure/safe/HoS
	name = "head of security's safe"
