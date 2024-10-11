/*
 * Contains:
 *		Security
 *		Detective
 *		Head of Security
 */

/*
 * Security
 */

 /*
 * Formalwear first
 */
/obj/item/clothing/under/rank/secformal
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/headofsecurity_blue
	name = "\improper HoS' blue dress uniform"
	desc = "Head of Security's blue uniform. For formal occasions."
	icon_state = "hosblueclothes"
	item_state = "ba_suit"
	_color = "hosblueclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/headofsecurity_navy
	name = "\improper HoS' navy dress uniform"
	desc = "Head of Security's navy uniform. For formal occasions."
	icon_state = "hosdnavyclothes"
	item_state = "jensensuit"
	_color = "hosdnavyclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/headofsecurity_tan
	name = "\improper HoS' tan dress uniform"
	desc = "Head of Security's uniform. For formal occasions."
	icon_state = "hostanclothes"
	item_state = "ba_suit"
	_color = "hostanclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/headofsecurity_navy/trimmed
	_color = "hosdnavyclothestrimmed"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/warden_blue
	name = "warden's blue dress uniform"
	desc = "Warden's blue dress uniform. For formal occasions."
	icon_state = "wardenblueclothes"
	item_state = "ba_suit"
	_color = "wardenblueclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/warden_navy
	name = "warden's navy dress uniform"
	desc = "Warden's navy dress uniform. For formal occasions."
	icon_state = "wardendnavyclothes"
	item_state = "jensensuit"
	_color = "wardendnavyclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/warden_tan
	name = "warden's tan dress uniform"
	desc = "Warden's tan dress uniform. For formal occasions."
	icon_state = "wardentanclothes"
	item_state = "ba_suit"
	_color = "wardentanclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/officer_blue
	name = "officer's blue dress uniform"
	desc = "Security officer's blue dress uniform. For formal occasions."
	icon_state = "officerblueclothes"
	item_state = "ba_suit"
	_color = "officerblueclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/officer_navy
	name = "officer's navy dress uniform"
	desc = "Security officer's navy dress uniform. For formal occasions."
	icon_state = "officerdnavyclothes"
	item_state = "jensensuit"
	_color = "officerdnavyclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/secformal/officer_tan
	name = "officer's tan dress uniform"
	desc = "Security officer's tan dress uniform. For formal occasions."
	icon_state = "officertanclothes"
	item_state = "ba_suit"
	_color = "officertanclothes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

 /*
 * Normalwear
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
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "A jumpsuit made of strong material, providing robust protection."
	icon_state = "security"
	item_state = "r_suit"
	_color = "security"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

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
	species_fit = list(GREY_SHAPED, INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/under/rank/collar
	name = "security officer's uniform"
	desc = "A jumpsuit made of strong material, with a dash of military flare."
	icon_state = "collar"
	item_state = "collar"
	_color = "collar"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED, INSECT_SHAPED, VOX_SHAPED)

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
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/det/noir
	desc = "This suit's stayed with you for years, like an old friend. Sure, it's seen better days, but it ain't shabby; after all, you can afford a blemish on your character, but not on your clothes."
	icon_state = "detective_noir"
	item_state = "detective_noir"
	_color = "detective_noir"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/det_hat
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/det_hat/noir
	desc = "This hat's been with you for some time now. It was a gift from your ex, and you wore it during the war. Thinking back on it, the war was prettier."
	icon_state = "detective_noir"
	item_state = "detective_noir"
	species_fit = list(INSECT_SHAPED)
/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hosred"
	item_state = "r_suit"
	_color = "hosred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.8
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.6
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/armor/hos/surveyor
	name = "surveyor coat"
	desc = "Man is by nature a curious animal. You can hide the truth from him temporarily, but not forever."
	icon_state = "surveyorcoat"
	item_state = "surveyorcoat"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

//Jensen cosplay gear
/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	item_state = "jensensuit"
	_color = "jensen"
	siemens_coefficient = 0.6
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for protection and style."
	icon_state = "jensencoat"
	item_state = "jensencoat"
	siemens_coefficient = 0.6
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/armor/hos/sundowner
	name = "armoured greatcoat"
	desc = "An oversized black greatcoat, it makes you feel fucking invincible."
	icon_state = "sundowner_coat_allblack"
	item_state = "sundowner_coat_allblack"
	siemens_coefficient = 0.6


// -- Centcomm, OG by SkyMarshall

/obj/item/clothing/under/rank/centcom/representative
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Ensign\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "\improper Nanotrasen Navy Uniform"
	icon_state = "officer"
	item_state = "g_suit"
	_color = "officer"
	displays_id = 0

/obj/item/clothing/under/rank/centcom/officer
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Lieutenant Commander\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "\improper Nanotrasen Officers Uniform"
	icon_state = "officer"
	item_state = "g_suit"
	_color = "officer"
	displays_id = 0

/obj/item/clothing/under/rank/centcom/captain
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "\improper Nanotrasen Captains Uniform"
	icon_state = "centcom"
	item_state = "dg_suit"
	_color = "centcom"
	displays_id = 0

/obj/item/clothing/under/rank/metrocop
	name = "civil protection uniform"
	desc = 	"Attention, all teams respond, code 3."
	icon_state = "metrocop"
	item_state = "r_suit"
	_color = "metrocop"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	species_fit = list(INSECT_SHAPED)

