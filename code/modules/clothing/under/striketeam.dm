
/obj/item/clothing/under/deathsquad
	name = "deathsquad holosuit"
	desc = "A state-of-the-art suit featuring an holographic map of the area, to help the squad coordinate their efforts."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/altsuits.dmi', "right_hand" = 'icons/mob/in-hand/right/altsuits.dmi')
	icon_state = "deathsquad"
	item_state = "deathsquad"
	_color = "deathsquad"
	flags = FPRINT  | ONESIZEFITSALL


/obj/item/clothing/under/deathsquad/New()
	..()
	attach_accessory(new/obj/item/clothing/accessory/holomap_chip/deathsquad(src))
