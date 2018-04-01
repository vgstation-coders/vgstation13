
/datum/organ/internal/eyes
	name = "eyes"
	parent_organ = LIMB_HEAD
	organ_type = "eyes"
	removed_type = /obj/item/organ/internal/eyes

	var/welding_proof=0
	var/eyeprot=0
	var/see_in_dark=2
	var/list/colourmatrix = list()



/datum/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	if(is_broken())
		owner.eye_blind = max(2, owner.eye_blind)
	if(is_bruised())
		owner.eye_blurry = max(2, owner.eye_blurry)


/datum/organ/internal/eyes/tajaran
	name = "feline eyes"
	see_in_dark=8
	removed_type = /obj/item/organ/internal/eyes/tajaran

/datum/organ/internal/eyes/grey
	name = "huge eyes"
	see_in_dark=5
	removed_type = /obj/item/organ/internal/eyes/grey

/datum/organ/internal/eyes/muton
	name = "muton eyes"
	see_in_dark=1
	removed_type = /obj/item/organ/internal/eyes/muton

/datum/organ/internal/eyes/vox
	name = "bird eyes"
//	colourmatrix = list(1,0.0,0.0,0,\
		 				0,0.5,0.5,0,\
						0,0.5,0.5,0,\
						0,0.0,0.0,1,)
	removed_type = /obj/item/organ/internal/eyes/vox

/datum/organ/internal/eyes/grue
	name = "monstrous eyes"
	see_in_dark=8
	colourmatrix = list(-1, 0, 0,
						 0,-1, 0,
						 0, 0,-1,
						 1, 1, 1)
	removed_type = /obj/item/organ/internal/eyes/grue

///////////////
// BIONIC EYES
///////////////

/datum/organ/internal/eyes/adv_1
	name = "advanced eyes"
	welding_proof=1
	see_in_dark=5
	robotic=2
	removed_type = /obj/item/organ/internal/eyes/adv_1
