/obj/item/clothing/glasses/scanner
	item_state = "glasses"
	species_fit = list(GREY_SHAPED)
	var/on = TRUE
	var/list/color_matrix = null

/obj/item/clothing/glasses/scanner/attack_self()
	toggle()

/obj/item/clothing/glasses/scanner/proc/apply_color(mob/living/carbon/user)	//for altering the color of the wearer's vision while active
	if(color_matrix)
		if(user.client)
			var/client/C = user.client
			C.color =  color_matrix

/obj/item/clothing/glasses/scanner/proc/remove_color(mob/living/carbon/user)
	if(color_matrix)
		if(user.client)
			var/client/C = user.client
			C.color = initial(C.color)

/obj/item/clothing/glasses/scanner/equipped(M as mob, glasses)
	if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/O = M
		if(O.glasses != src)
			return
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.glasses != src)
			return
	else
		return
	if(on)
		if(iscarbon(M))
			apply_color(M)
	..()

/obj/item/clothing/glasses/scanner/unequipped(mob/user, var/from_slot = null)
	if(from_slot == slot_glasses)
		if(on)
			if(iscarbon(user))
				remove_color(user)
	..()

/obj/item/clothing/glasses/scanner/update_icon()
	icon_state = initial(icon_state)

	if (!on)
		icon_state += "off"

/obj/item/clothing/glasses/scanner/proc/toggle()
	var/mob/C = usr
	if (!usr)
		if (!ismob(loc))
			return
		C = loc

	if (C.incapacitated())
		return

	if (on)
		disable(C)

	else
		enable(C)

	update_icon()
	C.update_inv_glasses()

/obj/item/clothing/glasses/scanner/proc/enable(var/mob/C)
	on = TRUE
	to_chat(C, "You turn \the [src] on.")
	if(iscarbon(loc))
		if(istype(loc, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = C
			if(M.glasses && (M.glasses == src))
				apply_color(M)
		else if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(H.glasses && (H.glasses == src))
				apply_color(H)

/obj/item/clothing/glasses/scanner/proc/disable(var/mob/C)
	on = FALSE
	to_chat(C, "You turn \the [src] off.")
	if(iscarbon(loc))
		if(istype(loc, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = C
			if(M.glasses && (M.glasses == src))
				remove_color(M)
		else if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(H.glasses && (H.glasses == src))
				remove_color(H)

/obj/item/clothing/glasses/scanner/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = Tc_MAGNETS + "=2"
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	see_in_dark = 8
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	eyeprot = -1
	color_matrix = list(0.8, 0, 0  ,\
						0  , 1, 0  ,\
						0  , 0, 0.8) //equivalent to #CCFFCC

/obj/item/clothing/glasses/scanner/night/enable(var/mob/C)
	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	eyeprot = initial(eyeprot)
	..()

/obj/item/clothing/glasses/scanner/night/disable(var/mob/C)
	see_invisible = 0
	see_in_dark = 0
	eyeprot = 0
	..()

/obj/item/clothing/glasses/scanner/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2"
	vision_flags = SEE_TURFS
	eyeprot = -1
	see_invisible = SEE_INVISIBLE_MINIMUM
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/scanner/meson/enable(var/mob/C)
	var/area/A = get_area(src)
	if(A.flags & NO_MESONS)
		to_chat(C, "<span class = 'warning'>\The [src] flickers, but refuses to come online!</span>")
		return
	eyeprot = initial(eyeprot)
	vision_flags |= SEE_TURFS
	see_invisible |= SEE_INVISIBLE_MINIMUM
//	body_parts_covered |= EYES
	..()

/obj/item/clothing/glasses/scanner/meson/disable(var/mob/C)
	eyeprot = 0
//	body_parts_covered &= ~EYES
	vision_flags &= ~SEE_TURFS
	see_invisible &= ~SEE_INVISIBLE_MINIMUM
	..()

/obj/item/clothing/glasses/scanner/meson/area_entered(area/A)
	if(A.flags & NO_MESONS && on)
		visible_message("<span class = 'warning'>\The [src] sputter out.</span>")
		disable()

/obj/item/clothing/glasses/scanner/material
	name = "optical material scanner"
	desc = "Allows one to see the original layout of the pipe and cable network."
	icon_state = "material"
	species_fit = list(GREY_SHAPED)
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	// vision_flags = SEE_OBJS

	var/list/image/showing = list()
	var/mob/viewing

/obj/item/clothing/glasses/scanner/material/enable()
	update_mob(viewing)
	..()

/obj/item/clothing/glasses/scanner/material/disable()
	update_mob(viewing)
	..()

/obj/item/clothing/glasses/scanner/material/update_icon()
	if (!on)
		icon_state = "mesonoff"

	else
		icon_state = initial(icon_state)

/obj/item/clothing/glasses/scanner/material/dropped(var/mob/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/material/unequipped(var/mob/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/material/equipped(var/mob/M)
	update_mob(M)
	..()

/obj/item/clothing/glasses/scanner/material/OnMobLife(var/mob/living/carbon/human/M)
	update_mob(M.glasses == src ? M : null)

/obj/item/clothing/glasses/scanner/material/proc/clear()
	if (!showing.len)
		return

	if (viewing && viewing.client)
		viewing.client.images -= showing

	showing.Cut()

/obj/item/clothing/glasses/scanner/material/proc/apply()
	if (!viewing || !viewing.client || !on)
		return

	showing = get_images(get_turf(viewing), viewing.client.view)
	viewing.client.images += showing

/obj/item/clothing/glasses/scanner/material/proc/update_mob(var/mob/new_mob)
	if (new_mob == viewing)
		clear()
		apply()
		return

	if (new_mob != viewing)
		clear()

		if (viewing)
			viewing.on_logout.Remove("\ref[src]:mob_logout")
			viewing = null

		if (new_mob)
			new_mob.on_logout.Add(src, "mob_logout")
			viewing = new_mob

/obj/item/clothing/glasses/scanner/material/proc/mob_logout(var/list/args, var/mob/M)
	if (M != viewing)
		return

	clear()
	viewing.on_logout.Remove("\ref[src]:mob_logout")
	viewing = null

/obj/item/clothing/glasses/scanner/material/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data
