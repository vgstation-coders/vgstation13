
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Excavation pickaxes - sorted in order of delicacy. Players will have to choose the right one for each part of excavation.

/obj/item/weapon/pickaxe/brush
	name = "1 cm brush"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_brush"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "Thick metallic wires for clearing away dust and loose scree (1 centimetre excavation depth)."
	excavation_amount = 1
	toolsounds = list('sound/weapons/thudswoosh.ogg')
	drill_verb = "brushing"
	w_class = W_CLASS_SMALL

/obj/item/weapon/pickaxe/two_pick
	name = "2 cm pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick2"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (2 centimetre excavation depth)."
	excavation_amount = 2
	toolsounds = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = W_CLASS_SMALL

/obj/item/weapon/pickaxe/three_pick
	name = "3 cm pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick3"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (3 centimetre excavation depth)."
	excavation_amount = 3
	toolsounds = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = W_CLASS_SMALL

/obj/item/weapon/pickaxe/four_pick
	name = "4 cm pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick4"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (4 centimetre excavation depth)."
	excavation_amount = 4
	toolsounds = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = W_CLASS_SMALL

/obj/item/weapon/pickaxe/five_pick
	name = "5 cm pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick5"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (5 centimetre excavation depth)."
	excavation_amount = 5
	toolsounds = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = W_CLASS_SMALL

/obj/item/weapon/pickaxe/six_pick
	name = "6 cm pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick6"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (6 centimetre excavation depth)."
	excavation_amount = 6
	toolsounds = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = W_CLASS_SMALL

/obj/item/weapon/pickaxe/hand
	name = "hand pickaxe"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_hand"
	item_state = "syringe_0"
	toolspeed = 0.3
	desc = "A smaller, more precise version of the pickaxe (15 centimetre excavation depth)."
	excavation_amount = 15
	toolsounds = list('sound/items/Crowbar.ogg')
	drill_verb = "clearing"
	w_class = W_CLASS_MEDIUM

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pack for holding pickaxes

/obj/item/weapon/storage/box/excavation
	name = "excavation pick set"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "excavation"
	desc = "A set of picks for excavation."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots = 6
	w_class = W_CLASS_SMALL
	can_only_hold = list("/obj/item/weapon/pickaxe/brush",\
	"/obj/item/weapon/pickaxe/two_pick",\
	"/obj/item/weapon/pickaxe/three_pick",\
	"/obj/item/weapon/pickaxe/four_pick",\
	"/obj/item/weapon/pickaxe/five_pick",\
	"/obj/item/weapon/pickaxe/six_pick")
	max_combined_w_class = 17
	fits_max_w_class = 4
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/excavation/New()
	..()
	new /obj/item/weapon/pickaxe/brush(src)
	new /obj/item/weapon/pickaxe/two_pick(src)
	new /obj/item/weapon/pickaxe/three_pick(src)
	new /obj/item/weapon/pickaxe/four_pick(src)
	new /obj/item/weapon/pickaxe/five_pick(src)
	new /obj/item/weapon/pickaxe/six_pick(src)
