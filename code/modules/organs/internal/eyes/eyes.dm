
/datum/organ/internal/eyes
	name = "eyes"
	parent_organ = LIMB_HEAD
	organ_type = "eyes"
	removed_type = /obj/item/organ/internal/eyes

	var/welding_proof=0
	var/eyeprot=0
	var/see_in_dark=2
	var/list/colourmatrix = list()

/datum/organ/internal/eyes/proc/init_perception(var/mob/living/carbon/human/M)
	return

/datum/organ/internal/eyes/proc/update_perception(var/mob/living/carbon/human/M)
	return

/datum/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	if(is_broken())
		owner.eye_blind = max(2, owner.eye_blind)
	if(is_bruised())
		owner.eye_blurry = max(2, owner.eye_blurry)

/datum/organ/internal/eyes/tajaran
	name = "feline eyes"
	see_in_dark=9
	removed_type = /obj/item/organ/internal/eyes/tajaran

/datum/organ/internal/eyes/tajaran/update_perception(var/mob/living/carbon/human/M)
	M.client.darkness_planemaster.alpha = 100

/datum/organ/internal/eyes/grey
	name = "huge eyes"
	see_in_dark=5
	removed_type = /obj/item/organ/internal/eyes/grey

/datum/organ/internal/eyes/muton
	name = "muton eyes"
	see_in_dark=1
	removed_type = /obj/item/organ/internal/eyes/muton

/datum/organ/internal/eyes/compound
	name = "compound eyes"
	see_in_dark=3
	removed_type = /obj/item/organ/internal/eyes/compound

/datum/organ/internal/eyes/vox
	name = "bird eyes"
	removed_type = /obj/item/organ/internal/eyes/vox

/datum/organ/internal/eyes/monstrous
	name = "monstrous eyes"
	see_in_dark= 9
	removed_type = /obj/item/organ/internal/eyes/monstrous

/datum/organ/internal/eyes/monstrous/update_perception(var/mob/living/carbon/human/M)
	M.client.darkness_planemaster.alpha = 100

/datum/organ/internal/eyes/mushroom
	name = "mushroom eyes"
	see_in_dark = 9
	removed_type = /obj/item/organ/internal/eyes/mushroom
	var/dark_mode = FALSE

/datum/organ/internal/eyes/mushroom/update_perception(var/mob/living/carbon/human/M)
	if (dark_mode)
		M.client.darkness_planemaster.blend_mode = BLEND_SUBTRACT
		M.client.darkness_planemaster.alpha = 100
		M.client.darkness_planemaster.color = "#FF0000"
		M.client.color = list(
			1,0,0,0,
			0,1,0,0,
			0,0,1,0,
			0,-0.1,0,1,
			0,0,0,0)
	else
		M.client.darkness_planemaster.blend_mode = BLEND_MULTIPLY
		M.client.darkness_planemaster.alpha = 150
		M.client.darkness_planemaster.color = null
		M.client.color = list(
			1,0,0,0,
			0,1,0,0,
			0,0,1,0,
			0,0,0,1,
			0,0,0,0)

///////////////
// BIONIC EYES
///////////////

/datum/organ/internal/eyes/adv_1
	name = "advanced eyes"
	welding_proof=1
	see_in_dark=5
	robotic=2
	removed_type = /obj/item/organ/internal/eyes/adv_1
