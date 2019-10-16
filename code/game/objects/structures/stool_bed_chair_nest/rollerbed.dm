/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	var/up_state ="up"
	var/down_state = "down"
	var/roller_type = /obj/item/roller

	var/iv_lock_type = /datum/locking_category/buckle/bedtoIV

	lockflags = DENSE_WHEN_LOCKED
	mob_lock_type = /datum/locking_category/buckle/bed/roller

/obj/structure/bed/roller/update_icon()
	. = ..()
	if(is_locking(mob_lock_type))
		icon_state = up_state
	else
		icon_state = down_state

/obj/structure/bed/roller/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/roller/unlock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/roller/manual_unbuckle(var/mob/user)
	if(user.size <= SIZE_TINY)
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return FALSE

	if(is_locking(mob_lock_type))
		return ..()

	else if(is_locking(iv_lock_type))
		add_fingerprint(user)
		var/obj/machinery/iv_drip/IV = get_locked(iv_lock_type)[1]
		if(unlock_atom(IV))
			user.visible_message(
				"<span class='notice'>[user] detaches \the [IV] from \the [src].</span>",
				"You detach \the [IV] from \the [src].",
				"You hear a small metal latch.")
			playsound(src, 'sound/misc/buckle_click.ogg', 40, 1)
		return TRUE
	else
		return FALSE

/obj/structure/bed/roller/MouseDropFrom(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr))
		if(!ishigherbeing(usr) || usr.incapacitated() || usr.lying)
			return

		if(is_locking(mob_lock_type))
			return 0

		visible_message("[usr] collapses \the [src.name].")

		new roller_type(get_turf(src))

		qdel(src)

/obj/structure/bed/roller/MouseDropTo(var/atom/movable/AM, var/mob/user)
	if(istype(AM, /obj/machinery/iv_drip))
		attach_iv(AM, user)
	else
		return ..()

/obj/structure/bed/roller/proc/attach_iv(var/obj/machinery/iv_drip/IV, var/mob/user)
	if(!Adjacent(user) || user.incapacitated() || istype(user, /mob/living/silicon/pai) || user.size <= SIZE_TINY)
		return

	if(!istype(IV) || (IV.loc != src.loc) || IV.locked_to)
		return

	if(is_locking(iv_lock_type))
		to_chat(user, "<span class='warning'>There's already \a [IV] attached to \the [src]!</span>")
		return

	if(lock_atom(IV, iv_lock_type))
		playsound(src, 'sound/misc/buckle_click.ogg', 40, 1)
		add_fingerprint(user)
		user.visible_message(
			"<span class='notice'>[user] attaches \the [IV] from \the [src].</span>",
			"You attach \the [IV] from \the [src].",
			"You hear a small metal latch.")

		IV.mode = IVDRIP_INJECTING
		IV.update_icon()

		if(IV.pulledby)
			IV.pulledby.start_pulling(src)


/obj/structure/bed/roller/deff
	icon = 'maps/defficiency/medbay.dmi'
	roller_type = /obj/item/roller/deff


/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/lokiamis.dmi', "right_hand" = 'icons/mob/in-hand/right/lokiamis.dmi')
	item_state = "folded"
	var/bed_type = /obj/structure/bed/roller
	w_class = W_CLASS_LARGE // Can't be put in backpacks. Oh well.

/obj/item/roller/deff
	icon = 'maps/defficiency/medbay.dmi'
	bed_type = /obj/structure/bed/roller/deff

/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/R = new bed_type(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/borg
	name = "hover bed"
	desc = "A collapsed cyborg hover bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "borgbed_stored"
	bed_type = /obj/structure/bed/roller/borg

/obj/structure/bed/roller/borg
	name = "hover bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "borgbed_down"
	up_state ="borgbed_up"
	down_state = "borgbed_down"
	roller_type = /obj/item/roller/borg

/obj/item/roller/borg/syndie
	name = "syndicate hover bed"
	desc = "A syndicate-modded cyborg hover bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "syndie_borgbed_stored"
	bed_type = /obj/structure/bed/roller/borg/syndie

/obj/structure/bed/roller/borg/syndie
	name = "syndicate hover bed"
	icon_state = "syndie_borgbed_down"
	up_state ="syndie_borgbed_up"
	down_state = "syndie_borgbed_down"
	roller_type = /obj/item/roller/borg/syndie

//A surgical roller bed that allows you to do surgery on it 100% of the time in place of the 75% chance of the normal one.
/obj/item/roller/surgery
	name = "mobile operating table"
	desc = "A collapsed mobile operating table that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "adv_folded"
	bed_type = /obj/structure/bed/roller/surgery

/obj/structure/bed/roller/surgery
	name = "mobile operating table"
	desc = "A new meaning to saving people in the hall. It's much more stable than a regular roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "adv_down"
	up_state ="adv_up"
	down_state = "adv_down"
	roller_type = /obj/item/roller/surgery

/datum/locking_category/buckle/bed
	flags = LOCKED_SHOULD_LIE

/datum/locking_category/buckle/bed/roller
	pixel_y_offset = 6 * PIXEL_MULTIPLIER
	flags = DENSE_WHEN_LOCKING | LOCKED_SHOULD_LIE

/datum/locking_category/buckle/bedtoIV
	pixel_y_offset = 2 * PIXEL_MULTIPLIER
	pixel_x_offset = -2 * PIXEL_MULTIPLIER
	layer_override = BELOW_OBJ_LAYER - 0.01
