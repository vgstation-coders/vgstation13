/obj/item/weapon/paper/envelope
	name = "envelope"
	icon_state = "envelope_open"

	var/obj/item/weapon/paper/contained_paper
	var/open = TRUE
	var/torn = FALSE

/obj/item/weapon/paper/envelope/update_icon()
	overlays.len = 0
	if(open)
		var/overlay_state = "envelope_open_overlay"
		if(torn)
			overlay_state = "envelope_torn_overlay"
			icon_state = "envelope_torn"
		else
			icon_state = "envelope_open"
		if(contained_paper)
			var/image/paper_overlay = image(contained_paper.icon, src, contained_paper.icon_state)
			overlays += paper_overlay
			var/image/envelope_overlay = image('icons/obj/bureaucracy.dmi', src, overlay_state)
			overlays += envelope_overlay
	else
		icon_state = "envelope_closed"

/obj/item/weapon/paper/envelope/attackby(obj/item/weapon/P, mob/user)
	. = ..()
	if(open)
		if(istype(P, /obj/item/weapon/paper) && !istype(P, /obj/item/weapon/paper/envelope))
			if(contained_paper)
				to_chat(user, "<span class='notice'>There is already \a [contained_paper] inside \the [src].</span>")
				return
			if(user.drop_item(P))
				contained_paper = P
				P.forceMove(src)
				user.visible_message("\The [user] puts something into \the [src].","You put \the [P] into \the [src].")
				update_icon()
	else
		if(P.sharpness && P.sharpness_flags & SHARP_BLADE)
			open()
			user.visible_message("\The [user] slices the top of \the [src] open with \the [P].","You slice the top of \the [src] open with \the [P].")
			playsound(get_turf(src), 'sound/effects/paper_tear.ogg', 10, 1)

/obj/item/weapon/paper/envelope/AltClick(mob/user)
	if(open && contained_paper)
		if(!user.put_in_active_hand(contained_paper))
			contained_paper.forceMove(get_turf(user))
		user.visible_message("\The [user] takes something out of \the [src].","You take \the [contained_paper] out of \the [src].")
		contained_paper = null
		update_icon()

/obj/item/weapon/paper/envelope/Destroy()
	if(contained_paper)
		qdel(contained_paper)
		contained_paper = null
	..()

/obj/item/weapon/paper/envelope/attack_self(mob/living/user)
	if(!torn)
		if(open)
			seal()
			user.visible_message("\The [user] seals \the [src].","You seal \the [src].")
		else
			open()
			user.visible_message("\The [user] tears open the top of \the [src].","You tear open the top of \the [src].")
			playsound(get_turf(src), 'sound/effects/paper_tear.ogg', 50, 1)
	else
		AltClick(user)

/obj/item/weapon/paper/envelope/proc/seal()
	open = FALSE
	update_icon()

/obj/item/weapon/paper/envelope/proc/open()
	open = TRUE
	torn = TRUE
	update_icon()
