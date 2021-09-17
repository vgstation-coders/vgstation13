/obj/item/clothing/glasses/scanner
	item_state = "glasses"
	species_fit = list(GREY_SHAPED)
	var/on = TRUE

/obj/item/clothing/glasses/scanner/attack_self()
	toggle()


/obj/item/clothing/glasses/scanner/equipped(var/mob/M, glasses)
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
			M.update_perception()
			M.update_darkness()
	..()

/obj/item/clothing/glasses/scanner/unequipped(mob/user, var/from_slot = null)
	if(from_slot == slot_glasses)
		if(on)
			user.seedarkness = TRUE
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

/obj/item/clothing/glasses/scanner/proc/disable(var/mob/C)
	on = FALSE
	to_chat(C, "You turn \the [src] off.")

/obj/item/clothing/glasses/scanner/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = Tc_MAGNETS + "=2"
	see_invisible = 0
	seedarkness = TRUE
	see_in_dark = 8
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	eyeprot = -1
	my_dark_plane_alpha_override_value = 30
	var/obj/abstract/screen/plane_master/overdark_planemaster/overdark_planemaster
	var/obj/abstract/screen/plane_master/overdark_planemaster_target/overdark_target

/obj/item/clothing/glasses/scanner/night/New()
	..()
	overdark_planemaster = new
	overdark_planemaster.render_target = "night vision goggles (\ref[src])"
	overdark_target = new
	overdark_target.render_source = "night vision goggles (\ref[src])"

/obj/item/clothing/glasses/scanner/night/enable(var/mob/C)
	see_in_dark = initial(see_in_dark)
	eyeprot = initial(eyeprot)
	my_dark_plane_alpha_override = "night_vision"
	add_overdark(C)
	if (ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.glasses == src)
			C.update_perception()
	else if (ismonkey(C))
		var/mob/living/carbon/monkey/M = C
		if (M.glasses == src)
			C.update_perception()
	return ..()

/obj/item/clothing/glasses/scanner/night/disable(var/mob/C)
	. = ..()
	see_in_dark = 0
	my_dark_plane_alpha_override = null
	eyeprot = 0
	remove_overdark(C)
	if (ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.glasses == src)
			if (C.client)
				C.client.color = null
			C.update_perception()
	else if (ismonkey(C))
		var/mob/living/carbon/monkey/M = C
		if (M.glasses == src)
			if (C.client)
				C.client.color = null
			C.update_perception()

/obj/item/clothing/glasses/scanner/night/update_perception(var/mob/living/carbon/human/M)
	if (on)
		if (M.master_plane)
			M.master_plane.blend_mode = BLEND_ADD
		if (M.client)
			M.client.color = "#33FF33"
			remove_overdark(M)
			add_overdark(M)
	else
		my_dark_plane_alpha_override = null
		if (M.master_plane)
			M.master_plane.blend_mode = BLEND_MULTIPLY

/obj/item/clothing/glasses/scanner/night/equipped(var/mob/M, glasses)
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
			add_overdark(M)
	..()

/obj/item/clothing/glasses/scanner/night/unequipped(mob/user, var/from_slot = null)
	if(from_slot == slot_glasses)
		if(on)
			remove_overdark(user)
			if (user.client)
				user.client.color = null
				user.update_perception()
	..()

/obj/item/clothing/glasses/scanner/night/proc/add_overdark(var/mob/living/carbon/C)
	if (istype(C) && C.client)
		C.client.screen |= overdark_planemaster
		C.client.screen |= overdark_target

/obj/item/clothing/glasses/scanner/night/proc/remove_overdark(var/mob/living/carbon/C)
	if (istype(C) && C.client)
		C.client.screen -= overdark_planemaster
		C.client.screen -= overdark_target

var/list/meson_wearers = list()

/obj/item/clothing/glasses/scanner/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2"
	vision_flags = SEE_TURFS
	eyeprot = -1
	see_invisible = SEE_INVISIBLE_MINIMUM
	seedarkness = FALSE
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	glasses_fit = TRUE
	var/mob/viewing

	my_dark_plane_alpha_override = "mesons"
	my_dark_plane_alpha_override_value = 255

/obj/item/clothing/glasses/scanner/meson/enable(var/mob/C)
	on = 1
	update_mob(viewing)
	var/area/A = get_area(src)
	if(A.flags & NO_MESONS)
		to_chat(C, "<span class = 'warning'>\The [src] flickers, but refuses to come online!</span>")
		return
	eyeprot = initial(eyeprot)
	vision_flags |= SEE_TURFS
	see_invisible |= SEE_INVISIBLE_MINIMUM
	seedarkness = FALSE
	my_dark_plane_alpha_override_value = 255

//	body_parts_covered |= EYES
	..()

/obj/item/clothing/glasses/scanner/meson/disable(var/mob/C)
	update_mob(viewing)
	eyeprot = 0
	on = 0
//	body_parts_covered &= ~EYES
	vision_flags &= ~SEE_TURFS
	see_invisible &= ~SEE_INVISIBLE_MINIMUM
	my_dark_plane_alpha_override_value = 0
	seedarkness = TRUE

/obj/item/clothing/glasses/scanner/meson/unequipped(mob/user, from_slot)
	. = ..()
	if (user)
		user.dark_plane?.alphas -= "mesons"
		user.update_darkness()
		user.check_dark_vision()

/obj/item/clothing/glasses/scanner/meson/area_entered(area/A)
	if(A.flags & NO_MESONS && on)
		visible_message("<span class = 'warning'>\The [src] sputter out.</span>")
		disable()

/obj/item/clothing/glasses/scanner/meson/proc/clear()
	if (viewing)
		meson_wearers -= viewing
		if (viewing.client)
			viewing.client.images -= false_wall_images

/obj/item/clothing/glasses/scanner/meson/proc/apply()
	if (!viewing || !viewing.client || !on)
		return

	meson_wearers += viewing
	viewing.client.images += false_wall_images

/obj/item/clothing/glasses/scanner/meson/unequipped(var/mob/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/meson/equipped(var/mob/M)
	update_mob(M)
	..()

/obj/item/clothing/glasses/scanner/meson/proc/update_mob(var/mob/new_mob)
	if (new_mob == viewing)
		clear()
		apply()
		return

	if (new_mob != viewing)
		clear()
		if (viewing)
			viewing = null
		if (new_mob)
			viewing = new_mob
			apply()


/obj/item/clothing/glasses/scanner/material
	name = "optical material scanner"
	desc = "Allows one to see the original layout of the pipe and cable network."
	icon_state = "material"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	// vision_flags = SEE_OBJS

	glasses_fit = TRUE

	var/list/image/showing = list()
	var/mob/viewing

/obj/item/clothing/glasses/scanner/material/enable()
	..()
	update_mob(viewing)

/obj/item/clothing/glasses/scanner/material/disable()
	..()
	update_mob(viewing)

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

	clear()

	if (viewing)
		viewing.unregister_event(/event/logout, src, .proc/mob_logout)
		viewing = null

	if (new_mob)
		new_mob.register_event(/event/logout, src, .proc/mob_logout)
		viewing = new_mob

/obj/item/clothing/glasses/scanner/material/proc/mob_logout(mob/user)
	if (user != viewing)
		return

	clear()
	viewing.unregister_event(/event/logout, src, .proc/mob_logout)
	viewing = null

/obj/item/clothing/glasses/scanner/material/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data
