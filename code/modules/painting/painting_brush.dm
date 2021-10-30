/*
* Acts as a color picker:
* Use it on a reagent container and it takes on the mix's color. Use it on a canvas and you can paint with said color.
* Side note: canvas does not support alpha colors, meaning brush ignores reagent colors' alpha, which result in weird looking colors sometimes
*
* Clean the brush by dipping it in water/space cleaner/paint cleaner
* A minimum percent of cleaning reagent out of total is needed, stronger cleaners require lower percentage.
*	eg: 5u water 5u blood won't be good for cleaning, but 9u water 1u blood will, and 5u cleaner 5u blood will too
* (made up units see PAINT_CLEANER_THRESHOLD and PAINT_CLEANER_AGENT_MULTIPLIER for actual units instead)
*
*/

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

	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		//Figure out how much water or cleaner there is
		var/cleaner_volume = target.reagents.get_reagent_amount(WATER)
		cleaner_volume += target.reagents.get_reagent_amount(CLEANER) * PAINT_CLEANER_AGENT_MULTIPLIER
		cleaner_volume += target.reagents.get_reagent_amount("paint_remover") * PAINT_CLEANER_AGENT_MULTIPLIER
		var/cleaner_percent = min(cleaner_volume > 0 ? cleaner_volume / target.reagents.total_volume : 0, 1)

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
