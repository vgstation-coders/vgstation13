/*
 * Contains:
 *		Security
 *		Detective
 *		Head of Security
 */

/*
 * Security
 */
/obj/item/clothing/under/rank/warden
	desc = "A jumpsuit made of strong material, providing robust protection. It has the word \"WARDEN\" written on the shoulders."
	name = "warden's jumpsuit"
	icon_state = "warden"
	item_state = "r_suit"
	_color = "warden"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "A jumpsuit made of strong material, providing robust protection."
	icon_state = "security"
	item_state = "r_suit"
	_color = "secred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/rank/security/sneaksuit
	name = "sneaking suit"
	desc = "It's made of a strong material developed by the Soviet Union centuries ago which provides robust protection."
	icon_state = "sneakingsuit"
	item_state = "sneakingsuit"
	_color = "sneakingsuit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/metalgear.dmi', "right_hand" = 'icons/mob/in-hand/right/metalgear.dmi')
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/rank/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon_state = "dispatch"
	item_state = "dispatch"
	_color = "dispatch"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security2
	name = "security officer's uniform"
	desc = "A jumpsuit made of strong material, providing robust protection."
	icon_state = "redshirt2"
	item_state = "r_suit"
	_color = "redshirt2"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED)

/*
 * Detective
 */
/obj/item/clothing/under/det
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	_color = "detective"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED, GREY_SHAPED)


/obj/item/clothing/head/det_hat
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/det_hat/noir
	desc = "This hat's been with you for some time now. It was a gift from your ex, and you wore it during the war. Thinking back on it, the war was prettier."
	icon_state = "detective_noir"
	item_state = "detective_noir"
/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hos"
	item_state = "r_suit"
	_color = "hosred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.8
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.6

//Jensen cosplay gear
/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	item_state = "jensensuit"
	_color = "jensen"
	siemens_coefficient = 0.6
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for protection and style."
	icon_state = "jensencoat"
	item_state = "jensencoat"
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/hos/sundowner
	name = "armoured greatcoat"
	desc = "An oversized black greatcoat, it makes you feel fucking invincible."
	icon_state = "sundowner_coat"
	item_state = "sundowner_coat"
	siemens_coefficient = 0.6
