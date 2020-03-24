//Barber
/obj/item/clothing/head/barber
	name = "barber's hat"
	desc = "a stylish hat for a stylish stylist."
	icon_state = "barber"
	item_state = "barber"
	flags = FPRINT
	siemens_coefficient = 0.9

//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chef"
	item_state = "chef"
	desc = "The commander in chef's head wear."
	flags = FPRINT
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/caphat
	name = "captain's hat"
	icon_state = "captain"
	desc = "It's good being the king."
	flags = FPRINT
	item_state = "caphat"
	siemens_coefficient = 0.9
	heat_conductivity = HELMET_HEAT_CONDUCTIVITY
	species_fit = list(INSECT_SHAPED)

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/helmet/cap
	name = "captain's cap"
	desc = "You fear to wear it for the negligence it brings."
	icon_state = "capcap"
	flags = FPRINT
	body_parts_covered = HEAD
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR
	siemens_coefficient = 0.9

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR
	siemens_coefficient = 0.9

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, an artists favorite headwear."
	icon_state = "beret"
	flags = FPRINT
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/beret/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/gloves/white))
		new /mob/living/simple_animal/hostile/retaliate/faguette/goblin(get_turf(src))
		qdel(W)
		qdel(src)

//Security
/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_badge"
	flags = FPRINT
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR

/obj/item/clothing/head/surgery/purple
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/blue
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
	icon_state = "surgcap_blue"

/obj/item/clothing/head/surgery/green
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"
