/obj/item/weapon/paper/envelope
	name = "envelope"
	icon_state = "envelope_open"

	var/list/never_allowed = list(/obj/item/weapon/paper/envelope)	//Not allowed out of sanity/necessity, not convenience.
	var/list/not_allowed = list(/obj/item/weapon/pen,	//These have interactions with paper/envelopes and it would really be a nuisance if they were stuck into envelopes every time they were used on one.
								/obj/item/toy/crayon,
								/obj/item/weapon/stamp,
								/obj/item/device/destTagger)
	var/obj/item/contained_item
	var/open = TRUE
	var/torn = FALSE
	var/sortTag

/obj/item/weapon/paper/envelope/update_icon()
	overlays.len = 0
	if(open)
		var/overlay_state = "envelope_open_overlay"
		if(torn)
			overlay_state = "envelope_torn_overlay"
			icon_state = "envelope_torn"
		else
			icon_state = "envelope_open"
		if(contained_item)
			var/image/item_overlay = image(contained_item.icon, src, contained_item.icon_state)
			overlays += item_overlay
			var/image/envelope_overlay = image('icons/obj/bureaucracy.dmi', src, overlay_state)
			overlays += envelope_overlay
	else
		icon_state = "envelope_closed"

/obj/item/weapon/paper/envelope/attackby(obj/item/weapon/P, mob/user)
	. = ..()
	if(.)
		return
	if(open)
		if(!is_type_in_list(P, not_allowed))
			insert_item(user, P)
	else
		if(P.sharpness && P.sharpness_flags & SHARP_BLADE)
			open()
			user.visible_message("\The [user] slices the top of \the [src] open with \the [P].","You slice the top of \the [src] open with \the [P].")
			playsound(src, 'sound/effects/paper_tear.ogg', 10, 1)

	if(istype(P, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = P
		if(src.sortTag != O.currTag)
			if(!O.currTag)
				to_chat(user, "<span class='notice'>Select a destination first!</span>")
				return
			var/tag = uppertext(O.destinations[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = tag
			playsound(src, 'sound/machines/twobeep.ogg', 100, 1)
			overlays = 0
			overlays += image(icon = icon, icon_state = "deliverytag")
			desc = "It has a label reading [tag]."

/obj/item/weapon/paper/envelope/AltClick(mob/user)
	if(open)
		if(contained_item)
			if(!user.put_in_active_hand(contained_item))
				contained_item.forceMove(get_turf(user))
			user.visible_message("\The [user] takes something out of \the [src].","You take \the [contained_item] out of \the [src].")
			contained_item = null
			update_icon()
		else
			var/obj/item/I = user.get_active_hand()
			if(I != src)
				insert_item(user, I)

/obj/item/weapon/paper/envelope/proc/insert_item(mob/user, obj/item/I)
	if(istype(I) && I.w_class == W_CLASS_TINY && !is_type_in_list(I, never_allowed))
		if(contained_item)
			to_chat(user, "<span class='notice'>There is already \a [contained_item] inside \the [src].</span>")
			return
		if(user.drop_item(I))
			contained_item = I
			I.forceMove(src)
			user.visible_message("\The [user] puts something into \the [src].","You put \the [I] into \the [src].")
			update_icon()

/obj/item/weapon/paper/envelope/Destroy()
	if(contained_item)
		qdel(contained_item)
		contained_item = null
	..()

/obj/item/weapon/paper/envelope/attack_self(mob/living/user)
	if(!torn)
		if(open)
			seal()
			user.visible_message("\The [user] seals \the [src].","You seal \the [src].")
		else
			open()
			user.visible_message("\The [user] tears open the top of \the [src].","You tear open the top of \the [src].")
			playsound(src, 'sound/effects/paper_tear.ogg', 50, 1)
	else
		AltClick(user)

/obj/item/weapon/paper/envelope/proc/seal()
	open = FALSE
	update_icon()

/obj/item/weapon/paper/envelope/proc/open()
	open = TRUE
	torn = TRUE
	update_icon()
