



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

/obj/item/weapon/painting_brush/update_icon()
	..()
	overlays.len = 0
	if (reagents.total_volume >= 1)
		var/image/covering = image(icon, "mop-reagent")
		covering.icon += mix_color_from_reagents(reagents.reagent_list)
		covering.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += covering
