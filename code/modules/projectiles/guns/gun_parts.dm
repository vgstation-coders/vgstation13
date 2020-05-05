/////////////////////////////////////
/////////////GUN PARTS///////////////
/////////////////////////////////////

/*Contains:
 - Silencer
*/


/obj/item/gun_part/silencer
	name = "silencer"
	desc = "a silencer"
	icon = 'icons/obj/gun.dmi'
	icon_state = "silencer"
	w_class = W_CLASS_SMALL

/obj/item/gun_part/scope
	name = "telescopic sight"
	desc = "In the close quarters of a space station, a telescopic sight may be more cumbersome than useful. Ideal for exploring alien worlds."
	icon = 'icons/obj/gun.dmi'
	icon_state = "scope"
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 400, MAT_GLASS = 2000)