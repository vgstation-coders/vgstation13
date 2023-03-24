//Barber
/obj/item/clothing/head/barber
	name = "barber's hat"
	desc = "a stylish hat for a stylish stylist."
	icon_state = "barber"
	item_state = "barber"
	species_fit = list(INSECT_SHAPED)
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
/obj/item/clothing/head/cap
	name = "captain's cap"
	desc = "You fear to wear it for the negligence it brings."
	icon_state = "capcap"
	flags = FPRINT
	body_parts_covered = HEAD
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/cap/cowboy
	name = "general's hat"
	desc = "A regal white stetson adorned with a general's badge. For especially old-school captains."
	icon_state = "cowboycap"
	species_fit = list(VOX_SHAPED,INSECT_SHAPED)

//Head of Security
/obj/item/clothing/head/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	flags = FPRINT
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	body_parts_covered = HEAD|EARS
	heat_conductivity = HELMET_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	siemens_coefficient = 0.8

/obj/item/clothing/head/HoS/NoiseDampening()
	return TRUE

/obj/item/clothing/head/HoS/surveyor
	name = "surveyor cap"
	desc = "You bring me the man, I'll find you the crime."
	icon_state = "surveyorcap"
	item_state = "surveyorcap"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/head/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6

/obj/item/clothing/head/HoS/cowboy
	name = "sheriff's hat"
	desc = "A stalwart white stetson adorned with a sheriff's badge. For especially old-school heads of security."
	icon_state = "cowboyhos"
	species_fit = list(VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/HoS/cowboy/NoiseDampening()
	return FALSE

/obj/item/clothing/head/beret/headofsecurity
	name = "formal Head of Security beret"
	desc = "A navy beret with a Head of Security rank insignia on it. For formal occasions."
	icon_state = "hosberet"
	species_fit = list(INSECT_SHAPED)

//Warden
/obj/item/clothing/head/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a security force. Protects the head from impacts."
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	icon_state = "policehelm"
	body_parts_covered = HEAD|EARS
	heat_conductivity = HELMET_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/warden/NoiseDampening()
	return TRUE

/obj/item/clothing/head/warden/cowboy
	name = "jailor's hat"
	desc = "A menacing black stetson adorned with a jailor's badge. For especially old-school wardens."
	icon_state = "cowboywarden"
	species_fit = list(VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/warden/cowboy/NoiseDampening()
	return FALSE

/obj/item/clothing/head/beret/warden
	name = "formal warden beret"
	desc = "A navy beret with a Warden rank insignia on it. For formal occasions."
	icon_state = "wardenberet"
	species_fit = list(INSECT_SHAPED)

//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "Head of Personnel's Cap"
	desc = "Papers, Please."
	armor = list(melee = 25, bullet = 0, laser = 15, energy = 10, bomb = 5, bio = 0, rad = 0)
	item_state = "hopcap"
	icon_state = "hopcap"
	body_parts_covered = HEAD
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	species_fit = list(INSECT_SHAPED)
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR
	siemens_coefficient = 0.9

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	species_fit = list(INSECT_SHAPED)
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
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/beret/officer
	name = "formal security officer beret"
	desc = "A navy beret with a Security Officer rank insignia on it. For formal occasions."
	icon_state = "officerberet"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/peaked
	name = "peaked cap"
	desc = "A red peaked cap, with a corporate logo on it."
	icon_state = "peaked"
	item_state = "peaked"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/garrison
	name = "garrison cap"
	desc = "A squat garrison cap, for officers made of sterner stuff."
	icon_state = "garrison"
	item_state = "garrison"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/cowboy/sec
	name = "deputy hat"
	desc = "A classic stetson adorned with a security badge. For especially old-school officers."
	icon_state = "cowboysec"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR

/obj/item/clothing/head/surgery/purple
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/surgery/blue
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
	icon_state = "surgcap_blue"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/surgery/green
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

 // Reference: http://www.teuse.net/personal/harrington/hh_bible.htm
 // http://www.trmn.org/portal/images/uniforms/rmn/rmn_officer_srv_dress_lrg.png

// Original by SkyMarshall

/obj/item/clothing/head/beret/centcom/officer
	name = "officers beret"
	desc = "A black beret adorned with the shield (a silver kite shield with an engraved sword) of the Nanotrasen security forces, announcing to the world that the wearer is a defender of Nanotrasen."
	icon_state = "centcomofficerberet"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/beret/centcom/captain
	name = "captains beret"
	desc = "A white beret adorned with the shield (a cobalt kite shield with an engraved sword) of the Nanotrasen security forces, worn only by those captaining a vessel of the Nanotrasen Navy."
	icon_state = "centcomcaptain"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/shoes/centcom
	name = "dress shoes"
	desc = "They appear impeccably polished."
	icon_state = "laceups"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/head/beret/engineering
	name = "engineering beret"
	desc = "A yellow-orange beret with a white insignia."
	icon_state = "e_beret_badge"
