/*
* Acts as a color picker:
* Use it on a reagent container and if it contains some pigments, it takes on their color. Use it on a canvas and you can paint with said color, or on the floor to write messages.
* If the mix has additional reagents with less alpha, the paint will be less opaque as well.
*
* Clean the brush by dipping it in water/space cleaner/paint cleaner
* A minimum percent of cleaning reagent out of total is needed, stronger cleaners require lower percentage.
*	eg: 5u water 5u blood won't be good for cleaning, but 9u water 1u blood will, and 5u cleaner 5u blood will too
* (made up units see PAINT_CLEANER_THRESHOLD and PAINT_CLEANER_AGENT_MULTIPLIER for actual units instead)
*
*/

/*

/obj/item/painting_brush
/obj/item/paint_roller
/obj/item/high_roller

*/

/obj/item/painting_brush
	// Graphics stuff
	desc = "Horse hair on a stick, with a space age twist. Paint won't dry or run out on this."
	name = "painting brush"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "painting_brush"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')

	// Materials stuff
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_WOOD = 23) //1cm wide, 30cm long
	autoignition_temperature=AUTOIGNITION_WOOD
	w_type = RECYK_WOOD
	siemens_coefficient = 0

	// Paint brush stuff
	var/paint_color = null
	var/nano_paint = PAINTLIGHT_NONE
	var/list/blood_data = list("wet paint" = "paint")
	var/list/component = list()
	var/list/component_alt = list()

/obj/item/painting_brush/update_icon()
	..()
	overlays.len = 0
	if (paint_color)
		var/image/covering = image(icon, src, "painting_brush_overlay")
		covering.icon += paint_color
		overlays += covering
		overlays += image(icon, src, "painting_brush_glint")
		//dynamic in-hand overlay
		var/image/paintleft = image(inhand_states["left_hand"], src, "brush_pigments")
		var/image/paintright = image(inhand_states["right_hand"], src, "brush_pigments")
		paintleft.icon += paint_color
		paintright.icon += paint_color
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright
	else
		dynamic_overlay = list()
	update_blood_overlay()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()


/obj/item/painting_brush/afterattack(obj/target, mob/living/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		// Figure out how much water or cleaner there is
		var/cleaner_percent = get_reagent_paint_cleaning_percent(target)

		if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
			// Clean up that brush
			paint_color = null
			nano_paint = PAINTLIGHT_NONE
			component = list()
			to_chat(user, "<span class='notice'>You clean \the [name] in \the [target.name].</span>")
		else
			// Take the pigment mix's color
			var/paint_rgb = mix_color_from_reagents(target.reagents.reagent_list, TRUE)
			if (!paint_rgb)
				to_chat(user, "<span class='notice'>Your [name] fails to grab any pigment from \the [target.name].</span>")
				return
			component = target.reagents.get_pigment_names()
			component_alt = component.Copy()
			var/list/paint_color_rgb = rgb2num(paint_rgb)
			paint_color = rgb(paint_color_rgb[1], paint_color_rgb[2], paint_color_rgb[3], mix_alpha_from_reagents(target.reagents.reagent_list))
			nano_paint = target.reagents.get_max_paint_light()
			to_chat(user, "<span class='notice'>You dip \the [name] in \the [target.name].</span>")
			var/datum/reagent/B = get_blood(target.reagents)
			if (B)
				add_blood_from_data(B.data)
				blood_data = list(B.data["blood_DNA"] = B.data["blood_type"])
			else
				blood_data = list("wet paint" = "paint")
		update_icon()
	else if (ishuman(target) && paint_color)
		var/mob/living/carbon/human/H = target
		var/paint_data = list(
			"viruses"		=null,
			"blood_DNA"		="wet paint",
			"blood_colour"	= paint_color,
			"blood_type"	="paint",
			"resistances"	=null,
			"trace_chem"	=null,
			"virus2" 		=list(),
			"immunity" 		=null,
			)
		if (user.zone_sel.selecting == LIMB_LEFT_HAND || user.zone_sel.selecting == LIMB_RIGHT_HAND)
			H.bloody_hands_from_data(copy_blood_data(paint_data),2,src)
		else if (user.zone_sel.selecting == LIMB_LEFT_FOOT || user.zone_sel.selecting == LIMB_RIGHT_FOOT)
			H.add_blood_to_feet(3, paint_color, list("wet paint" = "paint")	)
		else
			H.bloody_body_from_data(copy_blood_data(paint_data),0,src)
			if ((target == user) && (user.zone_sel.selecting == TARGET_MOUTH))
				user.visible_message("[user] licks their brush to consolidate the bristles for detail work.","You lick your brush to consolidate the bristles for detail work.")
				nano_paint = target.reagents.get_max_paint_light()
				if (nano_paint == PAINTLIGHT_LIMITED)//Ingesting bits of Radium
					user.apply_radiation(4)//never4get the Radium Girls
		playsound(src, get_sfx("mop"), 5, 1)

//presumably this will allow painting on the floor, credit to Anonymous user No.453861032
	if(istype(target, /turf/simulated))
		var/turf/simulated/the_turf = target
		var/datum/painting_utensil/p = new(user, src)
		if (!the_turf.advanced_graffiti)
			var/datum/custom_painting/advanced_graffiti = new(the_turf, 32, 32, base_color = "#00000000")
			the_turf.advanced_graffiti = advanced_graffiti
		the_turf.advanced_graffiti.interact(user, p)
		return

/obj/item/painting_brush/AltFrom(var/atom/A,var/mob/user, var/proximity_flag, var/click_parameters)
	if(proximity_flag == 0) // not adjacent
		return
	if (isfloor(A))
		paint_doodle(user,A)
		return TRUE
	return FALSE

/obj/item/painting_brush/proc/paint_doodle(var/mob/living/user, var/turf/T)
	if (!paint_color)
		to_chat(user, "<span class='warning'>There is no paint on your brush.</span>")
		return

	if (!isfloor(T))
		to_chat(user, "<span class='warning'>You can only doodle over floors.</span>")
		return

	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		to_chat(user, "<span class='warning'>This floor is already filled with writings.</span>")
		return

	var/max_length = 30//same as bloody doodles
	var/message = stripped_input(user,"Write a message. You will be able to preview it.","Painted writings", "")

	if (!message)
		return

	message = copytext(message, 1, max_length)

	var/letter_amount = length(replacetext(message, " ", ""))
	if(!letter_amount) //If there is no text
		return

	//Previewing our message
	var/image/I = image(icon = null)
	I.maptext = {"<span style="color:[paint_color];font-size:9pt;font-family:'Bloody';" align="center" valign="top">[message]</span>"}
	I.maptext_height = 32
	I.maptext_width = 64
	I.maptext_x = -16
	I.maptext_y = -2
	I.loc = T
	I.alpha = 180

	user.client.images.Add(I)
	var/continue_drawing = alert(user, "This is how your message will look. Continue?", "Painted writings", "Yes", "Cancel")

	user.client.images.Remove(I)
	animate(I)
	I.loc = null
	qdel(I)

	if(continue_drawing != "Yes" || !user.Adjacent(T))
		return

	//Painting our message
	var/obj/effect/decal/cleanable/blood/writing/W = new /obj/effect/decal/cleanable/blood/writing(T)
	W.basecolor = paint_color
	W.color = paint_color//so alpha gets applied as well
	W.maptext = {"<span style="color:#FFFFFF;font-size:9pt;font-family:'Bloody';" align="center" valign="top">[message]</span>"}
	var/invisible = user.invisibility || !user.alpha
	W.visible_message("<span class='warning'>[invisible ? "An invisible brush" : "\The [user]"] paints something on \the [T]...</span>")
	W.blood_DNA = blood_data.Copy()

/obj/item/painting_brush/clean_act(var/cleanliness)
	..()
	paint_color = null
	nano_paint = PAINTLIGHT_NONE
	update_icon()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/paint_roller
	name = "paint roller"
	desc = "Used to cover floors in paint more efficiently than by just dumping buckets on them."
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "paint_roller"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')

	w_class = W_CLASS_TINY
	starting_materials = list(MAT_PLASTIC = 50)
	autoignition_temperature=AUTOIGNITION_PLASTIC
	w_type = RECYK_PLASTIC
	siemens_coefficient = 0

	var/paint_color = null
	var/paint_alpha = 255
	var/nano_paint = PAINTLIGHT_NONE
	var/list/blood_data = list("wet paint" = "paint")
	var/stroke_state = "border_roller"
	var/list/stroke_states = list(
		"Full Tile (default, takes 3 clicks)" = "border_roller",
		"Half Tile" = "border_half",
		"Quarter Tile" = "border_quarter",
		"Trim" = "border_trim",
		"Arrow" = "border_arrow",
		"Concave Corner" = "border_concave",
		"Convex Corner" = "border_convex",
		"Square Corner" = "border_corner",
		)//found in paint_masks.dmi

/obj/item/paint_roller/afterattack(obj/target, mob/living/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		var/cleaner_percent = get_reagent_paint_cleaning_percent(target)

		if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
			paint_color = null
			nano_paint = PAINTLIGHT_NONE
			to_chat(user, "<span class='notice'>You clean \the [name] in \the [target.name].</span>")
		else
			// Take the pigment mix's color
			var/paint_rgb = mix_color_from_reagents(target.reagents.reagent_list, TRUE)
			if (!paint_rgb)
				to_chat(user, "<span class='notice'>Your [name] fails to grab any pigment from \the [target.name].</span>")
				return
			var/list/paint_color_rgb = rgb2num(paint_rgb)
			var/mix_alpha = mix_alpha_from_reagents(target.reagents.reagent_list)
			paint_color = rgb(paint_color_rgb[1], paint_color_rgb[2], paint_color_rgb[3], mix_alpha)
			paint_alpha = mix_alpha
			nano_paint = target.reagents.get_max_paint_light()
			to_chat(user, "<span class='notice'>You dip \the [name] in \the [target.name].</span>")
			var/datum/reagent/B = get_blood(target.reagents)
			if (B)
				add_blood_from_data(B.data)
				blood_data = list(B.data["blood_DNA"] = B.data["blood_type"])
			else
				blood_data = list("wet paint" = "paint")
		update_icon()
	else if (isfloor(target))
		var/turf/F = target
		if (!paint_color)
			to_chat(user, "<span class='warning'>There is no paint on your roller.</span>")
			return
		var/turf/T = get_turf(user)
		var/_dir = user.dir
		if (T != F)
			_dir = get_dir_cardinal(F,T)
		F.apply_paint_stroke(paint_color, paint_alpha, _dir, stroke_state, blood_data, nano_paint == PAINTLIGHT_FULL)
		playsound(src, get_sfx("mop"), 5, 1)
	else if (iswall(target))
		var/turf/W = target
		if (!paint_color)
			to_chat(user, "<span class='warning'>There is no paint on your roller.</span>")
			return
		var/turf/T = get_turf(user)
		var/_dir = user.dir
		if (T != W)
			_dir = get_dir_cardinal(W,T)
		W.apply_paint_stroke(paint_color, paint_alpha, _dir, "wall_side", blood_data, nano_paint == PAINTLIGHT_FULL)
		playsound(src, get_sfx("mop"), 5, 1)
	else if (ishuman(target) && paint_color)
		var/mob/living/carbon/human/H = target
		var/paint_data = list(
			"viruses"		=null,
			"blood_DNA"		="wet paint",
			"blood_colour"	= paint_color,
			"blood_type"	="paint",
			"resistances"	=null,
			"trace_chem"	=null,
			"virus2" 		=list(),
			"immunity" 		=null,
			)
		if (user.zone_sel.selecting == LIMB_LEFT_HAND || user.zone_sel.selecting == LIMB_RIGHT_HAND)
			H.bloody_hands_from_data(copy_blood_data(paint_data),2,src)
		else if (user.zone_sel.selecting == LIMB_LEFT_FOOT || user.zone_sel.selecting == LIMB_RIGHT_FOOT)
			H.add_blood_to_feet(3, paint_color, list("wet paint" = "paint"), nano_paint == PAINTLIGHT_FULL)
		else
			H.bloody_body_from_data(copy_blood_data(paint_data),0,src)
		playsound(src, get_sfx("mop"), 5, 1)

/obj/item/paint_roller/update_icon()
	..()
	overlays.len = 0
	if (paint_color)
		var/image/covering = image(icon, src, "paint_roller_overlay")
		covering.color = paint_color
		overlays += covering
		//dynamic in-hand overlay
		var/image/paintleft = image(inhand_states["left_hand"], src, "paint_roller_pigments")
		var/image/paintright = image(inhand_states["right_hand"], src, "paint_roller_pigments")
		paintleft.color = paint_color
		paintright.color = paint_color
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright
	else
		dynamic_overlay = list()
	update_blood_overlay()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/paint_roller/attack_self(var/mob/user)
	if (user.incapacitated() || !Adjacent(user))
		return
	var/choices = list()
	for(var/entry in stroke_states)
		choices += list(list(entry, stroke_states[entry], null))
	var/new_mode = show_radial_menu(user,user,choices,'icons/obj/paint_radial.dmi',radius = 42,custom_color = paint_color)
	if (!new_mode || user.incapacitated() || !Adjacent(user))
		return
	stroke_state = stroke_states[new_mode]

/obj/item/paint_roller/AltClick(var/mob/user)
	attack_self(user)

/obj/item/paint_roller/verb/set_painting_mode()
	set name = "Change painting mode"
	set category = "Object"
	set src in range(0)
	if(usr.incapacitated())
		return
	var/new_mode = input("Choose a painting mode","[src]") in stroke_states
	if (new_mode && !usr.incapacitated() && Adjacent(usr))
		stroke_state = stroke_states[new_mode]

/obj/item/paint_roller/clean_act(var/cleanliness)
	..()
	paint_color = null
	nano_paint = PAINTLIGHT_NONE
	update_icon()


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/high_roller
	name = "high roller"
	desc = "Nyehaeh there's the high roller!"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "high_roller"
	item_state = "high_roller"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2;"
	w_class = W_CLASS_LARGE
	starting_materials = list(MAT_IRON = 9375)//half of the materials used to print one
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	flags = FPRINT | TWOHANDABLE | SLOWDOWN_WHEN_CARRIED
	slowdown = NO_SLOWDOWN//HIGHROLLER_SLOWDOWN when active

	var/obj/item/weapon/reagent_containers/container = null
	var/mixed_color = "#ffffff"
	var/mixed_alpha = 255
	var/pigment_color = "#ffffff"

/obj/item/high_roller/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)
		if(wielded)
			if (!container)
				to_chat(user, "<span class='warning'>You need to slot in a reagent container before you can use the roller.</span>")

/obj/item/high_roller/attack_hand(var/mob/living/user)
	if (container && (user.get_inactive_hand() == src))
		user.put_in_hands(container)
		container = null
		playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		update_icon()
		return
	..()

/obj/item/high_roller/splashable()
	return FALSE

/obj/item/high_roller/update_wield(mob/user)
	if(wielded)
		slowdown = HIGHROLLER_SLOWDOWN
		user.register_event(/event/after_move, src, /obj/item/high_roller/proc/swipe_turf)
	else
		slowdown = NO_SLOWDOWN
		user.unregister_event(/event/after_move, src, /obj/item/high_roller/proc/swipe_turf)
	update_icon()

/obj/item/high_roller/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers))
		if(!W.is_open_container())
			to_chat(user, "<span class='warning'>The container must be open to get properly slotted onto the roller.</span>")
			return
		if(user.drop_item(W, src))
			if (container)
				user.put_in_hands(container)
				to_chat(user, "You swap the containers.")
			else
				to_chat(user, "You slot the container on the roller.")
			container = W
			playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			mixed_color = mix_color_from_reagents(container.reagents.reagent_list)
			mixed_alpha = mix_alpha_from_reagents(container.reagents.reagent_list)
			pigment_color = mix_color_from_reagents(container.reagents.reagent_list, TRUE)
			update_icon()
			return
	..()

/obj/item/high_roller/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return
	if (isshelf(target))
		return
	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		to_chat(user, "<span class='warning'>The roller is too large to get dipped in that. You need to slot in a reagent container instead.</span>")
		return
	var/turf/T = get_turf(target)
	swipe_turf(T)

/obj/item/high_roller/AltClick(var/mob/user)
	if (user.incapacitated() || !Adjacent(user))
		return
	if (!container)
		to_chat(user, "<span class='warning'>There is no container to remove.</span>")
		return
	if(wielded)
		unwield(user)
	user.put_in_hands(container)
	container = null
	playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	update_icon()

/obj/item/high_roller/verb/remove_container()
	set name = "Remove container"
	set category = "Object"
	set src in range(0)
	var/mob/user = usr
	if(user.incapacitated() || !Adjacent(user))
		return
	if (!container)
		to_chat(user, "<span class='warning'>There is no container to remove.</span>")
		return
	if(wielded)
		unwield(user)
	user.put_in_hands(container)
	container = null
	playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	update_icon()

/obj/item/high_roller/update_icon()
	..()
	overlays.len = 0

	if (wielded)
		item_state = "high_roller_deployed"
	else
		item_state = "high_roller"

	var/image/rollerhandleft = image(inhand_states["left_hand"], src, "palette-color")//blank
	var/image/rollerhandright = image(inhand_states["right_hand"], src, "palette-color")

	if (container)
		var/image/container_color = image(icon, src, "high_roller_container")

		var/image/container_color_handleft = image(inhand_states["left_hand"], src, "[item_state]_container")
		var/image/container_color_handright = image(inhand_states["right_hand"], src, "[item_state]_container")

		if (container.reagents.total_volume)
			container_color.color = mixed_color
			container_color.alpha = mixed_alpha
			container_color_handleft.color = mixed_color
			container_color_handleft.alpha = mixed_alpha
			container_color_handright.color = mixed_color
			container_color_handright.alpha = mixed_alpha

			var/image/container_fillings = image(icon, src, "high_roller_fillings[clamp(round(9*container.reagents.total_volume/container.reagents.maximum_volume),1,9)]")
			container_fillings.color = mixed_color
			container_fillings.alpha = mixed_alpha
			overlays += container_fillings

			if (pigment_color)
				var/image/paint_color = image(icon, src, "high_roller_pigments")
				paint_color.color = pigment_color
				paint_color.alpha = mixed_alpha
				overlays += paint_color

				var/image/pigment_color_handleft = image(inhand_states["left_hand"], src, "[item_state]_pigments")
				pigment_color_handleft.color = pigment_color
				pigment_color_handleft.alpha = mixed_alpha
				rollerhandleft.overlays += pigment_color_handleft
				var/image/pigment_color_handright = image(inhand_states["right_hand"], src, "[item_state]_pigments")
				pigment_color_handright.color = pigment_color
				pigment_color_handright.alpha = mixed_alpha
				rollerhandright.overlays += pigment_color_handright

		overlays += container_color
		rollerhandleft.overlays += container_color_handleft
		rollerhandright.overlays += container_color_handright

	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = rollerhandleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = rollerhandright

	update_blood_overlay()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/high_roller/dropped(var/mob/user)
	if(wielded)
		unwield(user)
	..()

/obj/item/high_roller/proc/swipe_turf(var/turf/T)
	if (!T)
		T = get_turf(src)
		if (!T)
			return

	var/mob/user = loc
	if(container && container.reagents.total_volume)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			for (var/mob/M in T.contents)
				if (M.lying)
					R.reaction_mob(M, TOUCH, 5, ALL_LIMBS, FALSE)
					add_logs(user, M, "rolled over", admin = TRUE, object = src, addition = "Reagents: [english_list(container.get_reagent_names())]")

			var/list/blood_data = list("wet paint" = "paint")
			if (R.id == BLOOD)
				blood_data = list(R.data["blood_DNA"] = R.data["blood_type"])

			if (R.flags & CHEMFLAG_PIGMENT)
				T.apply_paint_overlay(R.color, R.alpha, blood_data, R.paint_light == PAINTLIGHT_FULL)
			else
				R.reaction_turf(T, 5)

		container.reagents.remove_from_all(1)
		container.reagents.handle_special_behaviours()
		playsound(T, get_sfx("mop"), 5, 1)
		anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "wfoam-disolve", lay = SNOW_LAYER, col = mixed_color, alph = mixed_alpha, plane = ABOVE_TURF_PLANE)
		update_icon()
