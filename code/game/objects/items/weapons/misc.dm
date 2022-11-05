/obj/item/weapon/valuable_asteroid
	name = "Valuable Asteroid"
	desc = "Valuable Asteroid on Loan to Engineering, it'd be a shame to deconstruct it."
	icon = 'icons/obj/items.dmi'
	icon_state = "valuable_asteroid"
	// Only One Inhand Sprite
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi')
	throwforce = 10
	w_class = W_CLASS_LARGE
	attack_verb = list("bashed")
	flags = TWOHANDABLE | MUSTTWOHAND | FPRINT
	starting_materials = list(MAT_URANIUM = 10000, MAT_GOLD = 10000, MAT_SILVER = 10000, MAT_PLASMA = 10000)
	origin_tech = Tc_ENGINEERING + "=3"
