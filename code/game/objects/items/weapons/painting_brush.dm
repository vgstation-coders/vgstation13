/obj/item/weapon/painting_brush
	// Graphics stuff
	desc = "Horse hair on a stick, with a space age twist. Paint won't dry or run out on this"
	name = "painting brush"
	icon = 'icons/obj/items.dmi'
	icon_state = "painting_brush"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')

	// Materials stuff
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_WOOD = 23) //1cm wide, 30cm long
	autoignition_temperature=AUTOIGNITION_WOOD
	w_type = RECYK_WOOD
	siemens_coefficient = 0

	// Paint brush stuff
	var/paint_color = null

/obj/item/weapon/painting_brush/update_icon()
	..()
	overlays.len = 0
	if (paint_color)
		var/image/covering = image(icon, "painting_brush_overlay")
		covering.icon += paint_color
		overlays += covering

#define PAINT_CLEANER_THRESHOLD 0.7 // How much of the reagent we dipped the brush into should be water or some cleaner to clean the brush
#define PAINT_CLEANER_AGENT_MULTIPLIER 2 // How effective cleaning products are, compared to water (aka they count as if there was n times water instead)

/obj/item/weapon/painting_brush/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(target.reagents)
		//Figure out how much water or cleaner there is
		var/cleaner_volume = target.reagents.get_reagent_amount(WATER)
		cleaner_volume += target.reagents.get_reagent_amount(CLEANER) * PAINT_CLEANER_AGENT_MULTIPLIER
		cleaner_volume += target.reagents.get_reagent_amount("paint_remover") * PAINT_CLEANER_AGENT_MULTIPLIER
		var/cleaner_percent = min(cleaner_volume > 0 ? target.reagents.total_volume / cleaner_volume : 0, 1)

		if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
			// Clean up that brush
			paint_color = null
			to_chat(user, "<span class='notice'>You clean \the [name] in \the [target.name].</span>")
		else
			// Take the reagent mix's color
			paint_color = mix_color_from_reagents(target.reagents.reagent_list)
			to_chat(user, "<span class='notice'>You dip \the [name] in \the [target.name].</span>")
		update_icon()

#undef PAINT_CLEANER_THRESHOLD
#undef PAINT_CLEANER_AGENT_MULTIPLIER
