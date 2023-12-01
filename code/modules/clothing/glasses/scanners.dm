/obj/item/clothing/glasses/scanner
	item_state = "glasses"
	species_fit = list(GREY_SHAPED)
	var/on = TRUE
	var/list/stored_huds = list() // Stores a hud datum instance to apply to a mob
	var/list/hud_types = list() // What HUD the glasses provides, if any

/obj/item/clothing/glasses/scanner/New()
	..()
	if(hud_types.len)
		for(var/H in hud_types)
			if(ispath(H))
				stored_huds += new H

/obj/item/clothing/glasses/scanner/attack_self()
	toggle()

/obj/item/clothing/glasses/scanner/equipped(var/mob/living/carbon/M, glasses)
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
		if(iscarbon(M) && glasses == slot_glasses)
			for(var/datum/visioneffect/H in stored_huds)
				M.apply_hud(H)
			M.update_perception()
			M.update_darkness()
	..()

/obj/item/clothing/glasses/scanner/unequipped(mob/living/carbon/M, var/from_slot = null)
	..()
	if(from_slot == slot_glasses)
		if(on)
			for(var/datum/visioneffect/H in stored_huds)
				M.remove_hud(H)
			M.seedarkness = TRUE

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

/obj/item/clothing/glasses/scanner/proc/enable(var/mob/living/carbon/C)
	on = TRUE
	for(var/datum/visioneffect/H in stored_huds)
		C.apply_hud(H)
	to_chat(C, "You turn \the [src] on.")

/obj/item/clothing/glasses/scanner/proc/disable(var/mob/living/carbon/C)
	on = FALSE
	for(var/datum/visioneffect/H in stored_huds)
		C.remove_hud(H)
	to_chat(C, "You turn \the [src] off.")

/obj/item/clothing/glasses/scanner/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = Tc_MAGNETS + "=2"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	hud_types = list(/datum/visioneffect/night)

/obj/item/clothing/glasses/scanner/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	glasses_fit = TRUE
	prescription_type = /obj/item/clothing/glasses/scanner/meson/prescription
	hud_types = list(/datum/visioneffect/meson)

/obj/item/clothing/glasses/scanner/meson/enable(var/mob/living/carbon/C)
	var/area/A = get_area(src)
	if(A.flags & NO_MESONS)
		to_chat(C, "<span class = 'warning'>\The [src] flickers, but refuses to come online!</span>")
		return
	..()

/obj/item/clothing/glasses/scanner/meson/area_entered(area/A)
	if(A.flags & NO_MESONS && on)
		visible_message("<span class = 'warning'>\The [src] sputter out.</span>")
		disable()

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

/obj/item/clothing/glasses/scanner/material/dropped(var/mob/living/carbon/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/material/unequipped(var/mob/living/carbon/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/material/equipped(var/mob/living/carbon/M)
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


/obj/item/clothing/glasses/scanner/material/proc/update_mob(var/mob/living/carbon/new_mob)
	if (new_mob == viewing)
		clear()
		apply()
		return

	clear()

	if (viewing)
		viewing.unregister_event(/event/logout, src, nameof(src::mob_logout()))
		viewing = null

	if (new_mob)
		new_mob.register_event(/event/logout, src, nameof(src::mob_logout()))
		viewing = new_mob

/obj/item/clothing/glasses/scanner/material/proc/mob_logout(mob/living/carbon/user)
	if (user != viewing)
		return

	clear()
	viewing.unregister_event(/event/logout, src, nameof(src::mob_logout()))
	viewing = null

/obj/item/clothing/glasses/scanner/material/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data
