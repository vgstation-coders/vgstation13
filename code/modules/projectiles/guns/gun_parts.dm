/////////////////////////////////////
/////////////GUN PARTS///////////////
/////////////////////////////////////

/*Contains:
 - Silencer
*/
/obj/item/gun_part
	name = "gun part"
	desc = "This goes on a gun."
	icon = 'icons/obj/gun_part.dmi'
	w_class = W_CLASS_SMALL

/obj/item/gun_part/silencer
	name = "silencer"
	desc = "Suppresses the muzzle report of the weapon, making it harder to detect visibly and audibly."
	icon_state = "silencer"

/obj/item/gun_part/scope
	name = "telescopic sight"
	desc = "In the close quarters of a space station, a telescopic sight may be more cumbersome than useful. Ideal for exploring alien worlds."
	icon_state = "scope"
	starting_materials = list(MAT_IRON = 200, MAT_GLASS = 1000)
	
/obj/item/gun_part/glock_auto_conversion_kit
	name = "glock full-auto conversion kit"
	desc = "Invented by an enterprising martian gunsmith; easily installed onto any standard glock to convert it to full auto. Probably not the safest idea."
	icon_state = "fullautokit" 

	
/obj/item/gun_part/universal_magwell_expansion_kit
	name = "universal magwell expansion kit"
	desc = "A strange kit that seems to fit into most weapons that have special magwell limitations. Expended upon use."
	icon_state = "magwellkit" 
	w_class = W_CLASS_SMALL

