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
	
/obj/item/gun_part/glockfullautoconverter
	name = "glock full-auto conversion kit"
	desc = "Invented by an enterprising martian gunsmith; easily installed onto any standard glock to convert it to full auto. Probably not the safest idea."
	icon = 'icons/obj/gun.dmi' 
	icon_state = "fullautokit" 
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 400)