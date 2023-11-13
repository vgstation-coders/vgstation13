#define GAS_CONSUME_TO_WASTE_DENOMINATOR 2
/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

// Global Lists ////////////////////////////////////////////////
// Languages
var/global/list/language_keys[0]
var/global/list/all_languages[0]
var/global/list/all_species = list()
var/global/list/whitelisted_species = list("Human")
var/global/list/playable_species = list("Human")

/proc/buildSpeciesLists()
	var/datum/language/L
	var/datum/species/S
	for(. in subtypesof(/datum/language))
		L = new .
		all_languages[L.name] = L
	for (var/language_name in all_languages)
		L = all_languages[language_name]
		language_keys[":[lowertext(L.key)]"] = L
		language_keys[".[lowertext(L.key)]"] = L
		language_keys["#[lowertext(L.key)]"] = L
	for(. in subtypesof(/datum/species))
		S = new .
		all_species[S.name] = S
		if(S.flags & WHITELISTED)
			whitelisted_species += S.name
			if(S.flags & PLAYABLE || S.conditional_playable())
				playable_species += S.name
	return

////////////////////////////////////////////////////////////////

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human_races/r_human.dmi'		// Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi'	// Mutated icon set.
	var/override_icon = null								// DMI for overriding the icon.  states: [lowertext(species.name)]_[gender][fat?"_fat":""]
	var/eyes = "eyes_s"										// Icon for eyes.

	var/primitive												// Lesser form, if any (ie. monkey for humans)
	var/tail													// Name of tail image in species effects icon file.
	var/list/known_languages = list(LANGUAGE_GALACTIC_COMMON)	// Languages that this species innately knows.
	var/default_language = LANGUAGE_GALACTIC_COMMON				// Default language is used when 'say' is used without modifiers.
	var/attack_verb = "punches"									// Empty hand hurt intent verb.
	var/punch_damage = 0										// Extra empty hand attack damage.
	var/punch_sharpness = 0										// Slicing/cutting force of punches. Independent of the sharpness added by claws.
	var/punch_throw_range = 0
	var/punch_throw_speed = 1
	var/tacklePower = 50
	var/tackleRange = 2
	var/mutantrace											// Safeguard due to old code.
	var/myhuman												// mob reference

	var/breath_type = GAS_OXYGEN   // Non-oxygen gas breathed, if any.
	var/survival_gear = /obj/item/weapon/storage/box/survival // For spawnin'.

	var/cold_level_1 = 220  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 1000 // Heat damage level 2 above this point.

	var/fireloss_mult = 1

	var/throw_mult = 1 // Default mob throw_mult.

	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/pressure_resistance = 0 //how much we can take a change in pressure, in kPa

	// This shit is apparently not even wired up.
	var/brute_resist    // Physical damage reduction.
	var/burn_resist     // Burn damage reduction.

	var/brute_mod 		// brute multiplier
	var/burn_mod		// burn multiplier
	var/tox_mod			// toxin multiplier
	var/rad_mod			// radiation multiplier

	var/body_temperature = 310.15

	var/footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints //The type of footprint the species leaves if they are not wearing shoes. If we ever get any other than human and vox, maybe this should be explicitly defined for each species.

	// For grays
	var/max_hurt_damage = 5 // Max unarmed damage
	var/power_multiplier = 1 //A melee damage modifier
	var/list/default_mutations = list()
	var/list/default_blocks = list() // Don't touch.
	var/list/default_block_names = list() // Use this instead, using the names from setupgame.dm

	var/flags = 0       // Various specific features.
	var/anatomy_flags = 0 // Anatomical traits such as not having blood or being bulky.
	var/chem_flags = 0 //how we handle chemicals and eating/drinking i guess

	var/list/abilities = list()	// For species-derived or admin-given powers
	var/list/spells = list()	// Because spells are the hip new thing to replace verbs

	var/blood_color = DEFAULT_BLOOD //Red.
	var/flesh_color = DEFAULT_FLESH //Pink.
	var/base_color      //Used when setting species.
	var/max_skin_tone = 1

	var/uniform_icons       = 'icons/mob/uniform.dmi'
	var/fat_uniform_icons   = 'icons/mob/uniform_fat.dmi'
	var/gloves_icons        = 'icons/mob/hands.dmi'
	var/glasses_icons       = 'icons/mob/eyes.dmi'
	var/ears_icons          = 'icons/mob/ears.dmi'
	var/shoes_icons         = 'icons/mob/feet.dmi'
	var/head_icons          = 'icons/mob/head.dmi'
	var/belt_icons          = 'icons/mob/belt.dmi'
	var/wear_suit_icons     = 'icons/mob/suit.dmi'
	var/fat_wear_suit_icons = 'icons/mob/suit_fat.dmi'
	var/wear_mask_icons     = 'icons/mob/mask.dmi'
	var/back_icons          = 'icons/mob/back.dmi'
	var/id_icons            = 'icons/mob/ids.dmi'


	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	var/list/has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes
		)

	//If we will apply mutant race overlays or not.
	var/has_mutant_race = 1

	var/move_speed_mod = 0 //Higher value is slower, lower is faster.
	var/move_speed_multiplier = 1	//This is a multiplier, and can make the mob either faster or slower.

	var/meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human

	var/gender	//For races with only one or neither

	var/list/inventory_offsets

	var/species_intro //What intro you're given when you become this species.
	var/monkey_anim = "h2monkey" // Animation from monkeyisation.

	var/datum/speech_filter/speech_filter

/datum/species/New()
	..()
	if(all_species[name])
		var/datum/species/globalspeciesholder = all_species[name]
		default_blocks = globalspeciesholder.default_blocks.Copy()
		default_mutations = globalspeciesholder.default_mutations.Copy()
	inventory_offsets = get_inventory_offsets()

/datum/species/Destroy()
	if(myhuman)
		clear_organs(myhuman)
		myhuman = null
	..()

/datum/species/proc/gib(var/mob/living/carbon/human/H)
	if(H.status_flags & BUDDHAMODE)
		H.adjustBruteLoss(200)
		return
	H.death(1)
	H.monkeyizing = 1
	H.canmove = 0
	H.icon = null
	H.invisibility = 101

/datum/species/proc/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	if(speech_filter)
		speech.message = speech_filter.FilterSpeech(speech.message)
	if(H.dna)
		if(length(speech.message) >= 2)
			for(var/gene_type in H.active_genes)
				var/datum/dna/gene/gene = dna_genes[gene_type]
				if(!gene.block)
					continue
				if(gene.OnSay(H,speech))
					return 0
	return 1

/datum/species/proc/clear_organs(var/mob/living/carbon/human/H)
	if(H.organs)
		for(var/datum/organ/I in H.organs)
			qdel(I)
		H.organs.len=0
	if(H.internal_organs)
		for(var/datum/organ/I in H.internal_organs)
			qdel(I)
		H.internal_organs.len=0
	//The rest SHOULD only refer to organs that were already deleted by the above loops, so we can just clear the lists.
	if(H.organs_by_name)
		H.organs_by_name.len=0
	if(H.internal_organs_by_name)
		H.internal_organs_by_name.len=0
	if(H.grasp_organs)
		H.grasp_organs.len = 0
	H.bad_external_organs.Cut()


/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs.


	//This is a basic humanoid limb setup.
	H.organs = list()
	H.organs_by_name[LIMB_CHEST] = new/datum/organ/external/chest()
	H.organs_by_name[LIMB_GROIN] = new/datum/organ/external/groin(H.organs_by_name[LIMB_CHEST])
	H.organs_by_name[LIMB_HEAD] = new/datum/organ/external/head(H.organs_by_name[LIMB_CHEST])
	H.organs_by_name[LIMB_LEFT_ARM] = new/datum/organ/external/l_arm(H.organs_by_name[LIMB_CHEST])
	H.organs_by_name[LIMB_RIGHT_ARM] = new/datum/organ/external/r_arm(H.organs_by_name[LIMB_CHEST])
	H.organs_by_name[LIMB_RIGHT_LEG] = new/datum/organ/external/r_leg(H.organs_by_name[LIMB_GROIN])
	H.organs_by_name[LIMB_LEFT_LEG] = new/datum/organ/external/l_leg(H.organs_by_name[LIMB_GROIN])
	H.organs_by_name[LIMB_LEFT_HAND] = new/datum/organ/external/l_hand(H.organs_by_name[LIMB_LEFT_ARM])
	H.organs_by_name[LIMB_RIGHT_HAND] = new/datum/organ/external/r_hand(H.organs_by_name[LIMB_RIGHT_ARM])
	H.organs_by_name[LIMB_LEFT_FOOT] = new/datum/organ/external/l_foot(H.organs_by_name[LIMB_LEFT_LEG])
	H.organs_by_name[LIMB_RIGHT_FOOT] = new/datum/organ/external/r_foot(H.organs_by_name[LIMB_RIGHT_LEG])

	H.internal_organs = list()
	for(var/organ in has_organ)
		var/organ_type = has_organ[organ]
		var/datum/organ/internal/O = new organ_type(H)
		if(O.CanInsert(H))
			H.internal_organs_by_name[organ] = O
			O.Insert(H)

	for(var/name in H.organs_by_name)
		var/datum/organ/external/OE = H.organs_by_name[name]

		H.organs += OE
		if(OE.grasp_id)
			H.grasp_organs += OE

	for(var/datum/organ/external/O in H.organs)
		O.owner = H

/datum/species/proc/handle_post_spawn(var/mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	return

/datum/species/proc/updatespeciescolor(var/mob/living/carbon/human/H) //Handles changing icobase for species that have multiple skin colors.
	return

// Sent from /datum/lung_gas/metabolizable.
/datum/species/proc/receiveGas(var/gas_id, var/ratio, var/moles, var/mob/living/carbon/human/H)
	//testing("receiveGas: [gas_id] ? [breath_type] - ratio=[ratio], moles=[moles]")
	if(ratio <= 0 || gas_id != breath_type)
		//testing("  ratio is 0 or gas_id doesn't match up, adding oxyLoss.")
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = 1
		return 0
	else if(ratio >= 1)
		//testing("  we cool")
		H.failed_last_breath = 0
		H.adjustOxyLoss(-5)
		H.oxygen_alert = 0
		return moles/GAS_CONSUME_TO_WASTE_DENOMINATOR
	else
		//testing("  ratio < 1, adding oxyLoss.")
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS * (1 - ratio)) //Damage proportional to how much gas you didn't get
		H.failed_last_breath = 1
		H.oxygen_alert = 1
		return moles*ratio/GAS_CONSUME_TO_WASTE_DENOMINATOR

/datum/species/proc/handle_environment(var/datum/gas_mixture/environment, var/mob/living/carbon/human/host)

// Used for species-specific names (Vox, etc)
/datum/species/proc/makeName(var/gender,var/mob/living/carbon/C=null)
	if(gender==FEMALE)
		return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else
		return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/datum/species/proc/handle_death(var/mob/living/carbon/human/H, var/gibbed = 0) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

/datum/species/proc/can_artifact_revive()
	return 1

/datum/species/proc/OnCrit(var/mob/living/carbon/human/H)

/datum/species/proc/OutOfCrit(var/mob/living/carbon/human/H)

/datum/species/proc/silent_speech(message)

// -- Outfit datums --
/datum/species/proc/final_equip(var/mob/living/carbon/human/H)

/datum/species/proc/get_inventory_offsets()	//This is what you override if you want to give your species unique inventory offsets.
	var/static/list/offsets = list(
		"[slot_back]"		=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_wear_mask]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_handcuffed]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_belt]"		=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_wear_id]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_ears]"		=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_glasses]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_gloves]"		=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_head]"		=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_shoes]"		=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_wear_suit]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_w_uniform]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_s_store]"	=	list("pixel_x" = 0, "pixel_y" = 0),
		"[slot_legcuffed]"	=	list("pixel_x" = 0, "pixel_y" = 0)
		)
	return offsets

/datum/species/proc/conditional_playable()
	return 0

/datum/species/human
	name = "Human"
	known_languages = list(LANGUAGE_HUMAN)
	primitive = /mob/living/carbon/monkey

	anatomy_flags = HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT | HAS_SWEAT_GLANDS

	max_skin_tone = 220

/datum/species/human/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/manifested
	name = "Manifested"
	icobase = 'icons/mob/human_races/r_manifested.dmi'
	deform = 'icons/mob/human_races/r_def_manifested.dmi'
	known_languages = list(LANGUAGE_HUMAN)
	primitive = /mob/living/carbon/monkey
	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain/ash,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes
		)

	cold_level_1 = 210 //Default 220 - Lower is better
	cold_level_2 = 190 //Default 200
	cold_level_3 = 110 //Default 120

	heat_level_1 = 380 //Default 360 - Higher is better
	heat_level_2 = 420 //Default 400
	heat_level_3 = 1200 //Default 1000

	flags = NO_PAIN
	anatomy_flags = HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT | HAS_SWEAT_GLANDS

	blood_color = PALE_BLOOD
	flesh_color = "#C3C1BE"

/datum/species/manifested/handle_death(var/mob/living/carbon/human/H)
	H.dust(TRUE)

/datum/species/manifested/OnCrit(var/mob/living/carbon/human/H)
	H.overlays |= image('icons/mob/human.dmi',src,"CritPale")
	anim(target = H, a_icon = 'icons/effects/96x96.dmi', flick_anim = "rune_blind", offX = -WORLD_ICON_SIZE)
	H.take_overall_damage(1, 0)
	if (H.health < -50)
		H.dust()

/datum/species/manifested/OutOfCrit(var/mob/living/carbon/human/H)
	H.overlays -= image('icons/mob/human.dmi',src,"CritPale")

/datum/species/manifested/can_artifact_revive()
	return 0

/datum/species/manifested/gib(mob/living/carbon/human/H)
	handle_death(H)

/datum/species/unathi
	name = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	known_languages = list(LANGUAGE_UNATHI)
	tail = "sogtail"
	attack_verb = "scratches"
	punch_damage = 2
	primitive = /mob/living/carbon/monkey/unathi

	cold_level_1 = 260 //Default 220 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

	flags = WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL

	default_mutations=list(M_CLAWS)

	flesh_color = "#34AF10"

	head_icons      = 'icons/mob/species/unathi/head.dmi'
	wear_suit_icons = 'icons/mob/species/unathi/suit.dmi'


/datum/species/unathi/New()
	..()
	speech_filter = new /datum/speech_filter/unathi

/datum/species/unathi/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/skellington // /vg/
	name = "Skellington"
	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'  // TODO: Need deform.
	known_languages = list(LANGUAGE_CLATTER)
	flags = WHITELISTED | NO_BREATHE
	anatomy_flags = NO_SKIN | NO_BLOOD
	meat_type = /obj/item/stack/sheet/bone
	chem_flags = NO_EAT | NO_INJECT

	default_mutations=list(M_SKELETON)
	brute_mod = 2.0
	tacklePower = 20
	tackleRange = 3		//How terribly spooky

	has_organ = list(
		"brain" =    /datum/organ/internal/brain,
		)

	move_speed_multiplier = 1.5

	primitive = /mob/living/carbon/monkey/skellington

	species_intro = "You are a Skellington<br>\
					You have no skin, no blood, no lips, and only just enough brain to function.<br>\
					You can not eat normally, as your necrotic state only permits you to only eat raw flesh. As you lack skin, you can not be injected via syringe.<br>\
					You are also incredibly weak to brute damage, but you're fast and don't need to breathe, so that's going for you."

/datum/species/skellington/conditional_playable()
	var/MM = text2num(time2text(world.timeofday, "MM"))
	return MM == 10 //October


/datum/species/skellington/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	if (prob(25))
		speech.message += "  ACK ACK!"

	return ..(speech, H)

/datum/species/skellington/can_artifact_revive()
	return 0

/datum/species/skellington/gib(mob/living/carbon/human/H)
	..()
	var/datum/organ/external/head_organ = H.get_organ(LIMB_HEAD)
	if(head_organ.status & ORGAN_DESTROYED)
		new /obj/effect/decal/remains/human/noskull(H.loc)
	else
		new /obj/effect/decal/remains/human(H.loc)
		head_organ.droplimb(1,1)

	H.drop_all()
	qdel(src)


/datum/species/skellington/skelevox // Science never goes too far, it's the public that's too conservative
	name = "Skeletal Vox"
	icobase = 'icons/mob/human_races/vox/r_voxboney.dmi'
	deform = 'icons/mob/human_races/vox/r_voxboney.dmi' //Do bones deform noticeably?
	known_languages = list(LANGUAGE_VOX, LANGUAGE_CLATTER)

	survival_gear = /obj/item/weapon/storage/box/survival/vox

	primitive = /mob/living/carbon/monkey/vox/skeletal

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"

	default_mutations = list(M_BEAK, M_TALONS)

	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/vox

	uniform_icons = 'icons/mob/species/vox/uniform.dmi'
//	fat_uniform_icons = 'icons/mob/uniform_fat.dmi'
	gloves_icons    = 'icons/mob/species/vox/gloves.dmi'
	glasses_icons   = 'icons/mob/species/vox/eyes.dmi'
//	ears_icons      = 'icons/mob/ears.dmi'
	shoes_icons 	= 'icons/mob/species/vox/shoes.dmi'
	head_icons      = 'icons/mob/species/vox/head.dmi'
//	belt_icons      = 'icons/mob/belt.dmi'
	wear_suit_icons = 'icons/mob/species/vox/suit.dmi'
	wear_mask_icons = 'icons/mob/species/vox/masks.dmi'
//	back_icons      = 'icons/mob/back.dmi'

	has_organ = list(
		"brain" =    /datum/organ/internal/brain,
		"eyes" =     /datum/organ/internal/eyes/vox
	)

/datum/species/skellington/skelevox/makeName(var/gender,var/mob/living/carbon/human/H=null)
	var/sounds = rand(3,8)
	var/newname = ""

	for(var/i = 1 to sounds)
		newname += pick(vox_name_syllables)
	return capitalize(newname)

/datum/species/tajaran
	name = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	known_languages = list(LANGUAGE_CATBEAST, LANGUAGE_MOUSE)
	tail = "tajtail"
	attack_verb = "scratches"
	punch_damage = 2 //Claws add 3 damage without gloves, so the total is 5

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	primitive = /mob/living/carbon/monkey/tajara

	flags = WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL | HAS_SWEAT_GLANDS

	default_mutations=list(M_CLAWS)

	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/catbeast

	flesh_color = "#AFA59E"
	max_skin_tone = 1

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/tajaran
	)

	head_icons      = 'icons/mob/species/tajaran/head.dmi'
	wear_suit_icons = 'icons/mob/species/tajaran/suit.dmi'

/datum/species/tajaran/New()
	..()
	speech_filter = new /datum/speech_filter/tajaran

/datum/species/tajaran/handle_post_spawn(var/mob/living/carbon/human/H)
	if(myhuman != H)
		return
	updatespeciescolor(H)
	H.update_icon()

/datum/species/tajaran/updatespeciescolor(var/mob/living/carbon/human/H)
	switch(H.my_appearance.s_tone)
		if(CATBEASTBLACK)
			icobase = 'icons/mob/human_races/r_tajaranblack.dmi'
			deform = 'icons/mob/human_races/r_def_tajaranblack.dmi'
			tail = "tajtailb"
			H.my_appearance.h_style = "Black Tajaran Ears"
		else
			icobase = 'icons/mob/human_races/r_tajaran.dmi'
			deform = 'icons/mob/human_races/r_def_tajaran.dmi'
			tail = "tajtail"
			H.my_appearance.h_style = "Tajaran Ears"

/datum/species/tajaran/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	if (prob(15))
		speech.message = ""

		if (prob(50))
			speech.message = pick("GOD, PLEASE", "NO, GOD", "AGGGGGGGH") + " "

		speech.message += pick("KILL ME", "END MY SUFFERING", "I CAN'T DO THIS ANYMORE")
	return ..()

/datum/species/tajaran/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/grey // /vg/
	name = "Grey"
	icobase = 'icons/mob/human_races/grey/r_grey.dmi'
	deform = 'icons/mob/human_races/grey/r_def_grey.dmi'
	known_languages = list(LANGUAGE_GREY)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grey
	eyes = "grey_eyes_s"

	max_hurt_damage = 3 // From 5 (for humans)
	tacklePower = 25
	power_multiplier = 0.8

	blood_color = "#CFAAAA"
	flesh_color = "#B5B5B5"
	max_skin_tone = 4

	primitive = /mob/living/carbon/monkey/grey

	flags = PLAYABLE | WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_SWEAT_GLANDS | ACID4WATER

	spells = list(/spell/targeted/telepathy)

	//PLEASE IF YOU MAKE A NEW RACE, KEEP IN MIND PEOPLE WILL PROBABLY MAKE UNIFORM SPRITES.
	uniform_icons = 'icons/mob/species/grey/uniform.dmi'
//	fat_uniform_icons = 'icons/mob/uniform_fat.dmi'
//	gloves_icons    = 'icons/mob/gloves.dmi'
	glasses_icons   = 'icons/mob/species/grey/eyes.dmi'
//	ears_icons      = 'icons/mob/ears.dmi'
//	shoes_icons 	= 'icons/mob/shoes.dmi'
	head_icons      = 'icons/mob/species/grey/head.dmi'
//	belt_icons      = 'icons/mob/belt.dmi'
	wear_suit_icons = 'icons/mob/species/grey/suit.dmi'
	wear_mask_icons = 'icons/mob/species/grey/masks.dmi'
//	back_icons      = 'icons/mob/back.dmi'

	has_mutant_race = 0

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/grey
	)

	species_intro = "You are a Grey.<br>\
					You are particularly allergic to water, which acts like acid to you, but the inverse is so for acid, so you're fun at parties.<br>\
					You're not as good at swinging a toolbox or throwing a punch as a baseline human, but you make up for this by bullying them from afar by talking directly into peoples minds."

/datum/species/grey/makeName(var/gender,var/mob/living/carbon/human/H=null) // Grey names are hard to pin down. Some have surnames, some lack surnames. And due to their long period of contact with humanity, a few have more humanized names
	if(prob(90)) // More alien sounding name
		switch(rand(0,1))
			if(0) // No surname. Maybe we're a clone who has forgotten it, or we don't care
				if(gender==FEMALE)
					return capitalize(pick(grey_first_female))
				else
					return capitalize(pick(grey_first_male))
			if(1) // Surname present. Maybe we held on to one for sentimental reasons, or wanted to feel more important
				if(gender==FEMALE)
					return capitalize(pick(grey_first_female)) + " " + capitalize(pick(grey_last))
				else
					return capitalize(pick(grey_first_male)) + " " + capitalize(pick(grey_last))
	else // More humanized name
		if(gender==FEMALE)
			return capitalize(pick(grey_first_female_h)) + " " + capitalize(pick(grey_last_h))
		else
			return capitalize(pick(grey_first_male_h)) + " " + capitalize(pick(grey_last_h))

/datum/species/grey/handle_post_spawn(var/mob/living/carbon/human/H)
	if(myhuman != H)
		return
	updatespeciescolor(H)
	H.update_icon()

/datum/species/grey/updatespeciescolor(var/mob/living/carbon/human/H)
	switch(H.my_appearance.s_tone)
		if(4)
			icobase = 'icons/mob/human_races/grey/r_greyblue.dmi'
			deform = 'icons/mob/human_races/grey/r_def_greyblue.dmi'
		if(3)
			icobase = 'icons/mob/human_races/grey/r_greygreen.dmi'
			deform = 'icons/mob/human_races/grey/r_def_greygreen.dmi'
		if(2)
			icobase = 'icons/mob/human_races/grey/r_greylight.dmi'
			deform = 'icons/mob/human_races/grey/r_def_greylight.dmi'
		else
			icobase = 'icons/mob/human_races/grey/r_grey.dmi'
			deform = 'icons/mob/human_races/grey/r_def_grey.dmi'
/datum/species/grey/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/muton // /vg/
	name = "Muton"
	icobase = 'icons/mob/human_races/r_muton.dmi'
	deform = 'icons/mob/human_races/r_def_muton.dmi'
	//known_languages = list("Muton") //this language doesn't even EXIST
	eyes = "eyes_s"

	max_hurt_damage = 10
	tacklePower = 90

	primitive = /mob/living/carbon/monkey // TODO
	anatomy_flags = HAS_LIPS | HAS_SWEAT_GLANDS

	// Both must be set or it's only a 45% chance of manifesting.
	default_mutations=list(M_STRONG | M_RUN | M_LOUD)
	default_block_names=list("STRONGBLOCK","LOUDBLOCK","INCREASERUNBLOCK")

	has_mutant_race = 0

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/muton
	)

	move_speed_mod = 1

/datum/species/muton/final_equip(var/mob/living/carbon/human/H)
	// Unequip existing suits and hats.
	H.u_equip(H.wear_suit,1)
	H.u_equip(H.head,1)
	move_speed_mod = 1

/datum/species/muton/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/skrell
	name = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	known_languages = list(LANGUAGE_SKRELLIAN)
	primitive = /mob/living/carbon/monkey/skrell

	flags = WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_UNDERWEAR | HAS_SWEAT_GLANDS

	flesh_color = "#8CD7A3"


	head_icons      = 'icons/mob/species/skrell/head.dmi'
	wear_suit_icons = 'icons/mob/species/skrell/suit.dmi'

/datum/species/skrell/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/vox
	name = "Vox"
	icobase = 'icons/mob/human_races/vox/r_vox.dmi'
	deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
	known_languages = list(LANGUAGE_VOX)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox
	tacklePower = 40
	anatomy_flags = HAS_SWEAT_GLANDS

	survival_gear = /obj/item/weapon/storage/box/survival/vox

	primitive = /mob/living/carbon/monkey/vox

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"
	breath_type = GAS_NITROGEN

	default_mutations = list(M_BEAK, M_TALONS)
	flags = PLAYABLE | WHITELISTED

	blood_color = VOX_BLOOD
	flesh_color = "#808D11"
	max_skin_tone = 6

	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/vox //Bird claws

	uniform_icons = 'icons/mob/species/vox/uniform.dmi'
//	fat_uniform_icons = 'icons/mob/uniform_fat.dmi'
	gloves_icons    = 'icons/mob/species/vox/gloves.dmi'
	glasses_icons   = 'icons/mob/species/vox/eyes.dmi'
//	ears_icons      = 'icons/mob/ears.dmi'
	shoes_icons 	= 'icons/mob/species/vox/shoes.dmi'
	head_icons      = 'icons/mob/species/vox/head.dmi'
//	belt_icons      = 'icons/mob/belt.dmi'
	wear_suit_icons = 'icons/mob/species/vox/suit.dmi'
	wear_mask_icons = 'icons/mob/species/vox/masks.dmi'
	back_icons      = 'icons/mob/species/vox/back.dmi'

	has_mutant_race = 0
	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs/vox,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/vox
	)

	species_intro = "You are a Vox.<br>\
					You are somewhat more adept at handling the lower pressures of space and colder temperatures.<br>\
					You have talons with which you can slice others in a fist fight, and a beak which can be used to butcher corpses without the need for finer tools.<br>\
					However, Oxygen is incredibly toxic to you, in breathing it or consuming it. You can only breathe nitrogen."

// -- Outfit datums --
/datum/species/vox/final_equip(var/mob/living/carbon/human/H)
	var/tank_slot = slot_s_store
	var/tank_slot_name = "suit storage"
	if(tank_slot)
		H.equip_or_collect(new/obj/item/weapon/tank/nitrogen(H), tank_slot)
	else
		H.put_in_hands(new/obj/item/weapon/tank/nitrogen(H))
	to_chat(H, "<span class='info'>You are now running on nitrogen internals from the [H.s_store] in your [tank_slot_name].</span>")
	var/obj/item/weapon/tank/nitrogen/N = H.get_item_by_slot(tank_slot)
	if(!N)
		N = H.get_item_by_slot(slot_back)
	H.internal = N
	if (H.internals)
		H.internals.icon_state = "internal1"

/datum/species/vox/makeName(var/gender,var/mob/living/carbon/human/H=null)
	var/sounds = rand(3,8)
	var/newname = ""

	for(var/i = 1 to sounds)
		newname += pick(vox_name_syllables)
	return capitalize(newname)

/datum/species/vox/handle_post_spawn(var/mob/living/carbon/human/H)
	if(myhuman != H)
		return
	updatespeciescolor(H)
	H.update_icon()

/datum/species/vox/updatespeciescolor(var/mob/living/carbon/human/H)
	switch(H.my_appearance.s_tone)
		if(6)
			icobase = 'icons/mob/human_races/vox/r_voxemrl.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxemrl.dmi'
		if(5)
			icobase = 'icons/mob/human_races/vox/r_voxazu.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxazu.dmi'
		if(4)
			icobase = 'icons/mob/human_races/vox/r_voxlgrn.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxlgrn.dmi'
		if(3)
			icobase = 'icons/mob/human_races/vox/r_voxgry.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxgry.dmi'
		if(2)
			icobase = 'icons/mob/human_races/vox/r_voxbrn.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxbrn.dmi'
		else
			icobase = 'icons/mob/human_races/vox/r_vox.dmi'
			deform = 'icons/mob/human_races/vox/r_def_vox.dmi'

/datum/species/vox/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/diona
	name = "Diona"
	icobase = 'icons/mob/human_races/r_plant.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	known_languages = list(LANGUAGE_ROOTSPEAK)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/diona
	attack_verb = "slashes"
	punch_damage = 5
	tacklePower = 65
	tackleRange = 1
	primitive = /mob/living/carbon/monkey/diona

	spells = list(/spell/targeted/transfer_reagents)

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = T0C + 50
	heat_level_2 = T0C + 75
	heat_level_3 = T0C + 100

	flags = WHITELISTED | PLAYABLE | NO_BREATHE | REQUIRE_LIGHT | IS_PLANT | RAD_ABSORB | IS_SLOW | NO_PAIN | HYPOTHERMIA_IMMUNE
	anatomy_flags = NO_BLOOD | HAS_SWEAT_GLANDS

	blood_color = "#004400"
	flesh_color = "#907E4A"

	has_mutant_race = 0
	burn_mod = 2.5 //treeeeees

	move_speed_mod = 4

	species_intro = "You are a Diona.<br>\
					You are a plant, so light is incredibly helpful for you, in both photosynthesis, and regenerating damage you have received.<br>\
					You absorb radiation which helps you in a similar way to sunlight. Your rigid, wooden limbs make you incredibly slow.<br>\
					You do not need to breathe, do not feel pain,  you are incredibly resistant to cold and low pressure, and have no blood to bleed.<br>\
					However, as you are a plant, you are incredibly susceptible to burn damage, which is something you can not regenerate normally.<br>\
					Your liver is special. It converts a portion of what you ingest into ammonia. You can use your transfer reagents spell to inject plants."

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver/diona,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes
	)

/datum/species/diona/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/golem
	name = "Golem"
	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_def_golem.dmi'
	known_languages = list(LANGUAGE_GOLEM)
	meat_type = /obj/item/stack/ore/diamond
	attack_verb = "punches"
	tacklePower = 70
	tackleRange = 1

	flags = NO_BREATHE | NO_PAIN | HYPOTHERMIA_IMMUNE
	anatomy_flags = HAS_LIPS | NO_SKIN | NO_BLOOD | IS_BULKY | NO_STRUCTURE

	uniform_icons = 'icons/mob/uniform_fat.dmi'
	primitive = /mob/living/carbon/monkey/rock

	gender = NEUTER

	blood_color = "#B4DBCB"
	flesh_color = "#B4DBCB"

	warning_low_pressure = -1
	hazard_low_pressure = -1

	body_temperature = 0

	cold_level_1 = -1  // Cold damage level 1 below this point.
	cold_level_2 = -1  // Cold damage level 2 below this point.
	cold_level_3 = -1  // Cold damage level 3 below this point.

	heat_level_1 = 3600
	heat_level_2 = 4000
	heat_level_3 = 10000

	burn_mod = 0.0001

	has_mutant_race = 0
	move_speed_mod = 1

	default_mutations = list(M_STONE_SKIN)

	chem_flags = NO_INJECT

	has_organ = list(
		"brain" =    /datum/organ/internal/brain,
		)

/datum/species/golem/makeName()
	return capitalize(pick(golem_names))

var/list/has_died_as_golem = list()

/datum/species/golem/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	if(!isgolem(H))
		return
	var/datum/mind/golemmind = H.mind
	if(!istype(golemmind,/datum/mind))	//not a mind
		golemmind = null
	for(var/atom/movable/I in H.contents)
		I.forceMove(H.loc)
	anim(target = H, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-g", sleeptime = 15)
	var/mob/living/adamantine_dust/A = new(H.loc)
	if(golemmind)
		has_died_as_golem[H.mind.key] = world.time
		A.mind = golemmind
		H.mind = null
		golemmind.current = A
		if(H.real_name)
			A.real_name = H.real_name
			A.desc = "The remains of what used to be [A.real_name]."
		A.key = H.key
	qdel(H)

/datum/species/golem/can_artifact_revive()
	return 0

/datum/species/golem/gib(mob/living/carbon/human/H)
	handle_death()

/mob/living/adamantine_dust //serves as the corpse of adamantine golems
	name = "adamantine dust"
	desc = "The remains of an adamantine golem."
	stat = DEAD
	icon = 'icons/mob/human_races/r_golem.dmi'
	icon_state = "golem_dust"
	density = 0
	meat_type = /obj/item/stack/ore/diamond

/mob/living/adamantine_dust/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/slime_extract/adamantine))
		var/obj/item/slime_extract/adamantine/A = I
		if(A.Uses)
			if(!mind)
				to_chat(user, "<span class='warning'>You press \the [A] into \the [src], but nothing happens.</span>")
			else
				if(!client)
					to_chat(user, "<span class='notice'>As you press \the [A] into \the [src], it shudders briefly, but falls still.</span>")
					ghost_reenter_alert("Someone is trying to resurrect you. Return to your body if you want to live again!")
				else
					anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "reverse-dust-g", sleeptime = 15)
					var/mob/living/carbon/human/golem/G = new /mob/living/carbon/human/golem
					if(!real_name)
						real_name = G.species.makeName()
					to_chat(user, "<span class='notice'>As you press \the [A] into \the [src], it is consumed. [real_name] reconstitutes itself!.</span>")
					qdel(A)
					G.real_name = real_name
					G.forceMove(src.loc) //we use move to get the entering procs - this fixes gravity
					var/datum/mind/dustmind = mind
					G.mind = dustmind
					dustmind.current = G
					mind = null
					G.key = key
					to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as impervious to burn damage. You are unable to wear most clothing, but can still use most tools. Serve [user], and assist them in completing their goals at any cost.")
					qdel(src)
		else
			to_chat(user, "<span class='warning'>The used extract doesn't have any effect on \the [src].</span>")

/datum/species/vampire
	name = "Vampire"
	icobase = 'icons/mob/human_races/r_grue.dmi'		// Normal icon set.
	deform = 'icons/mob/human_races/r_def_grue.dmi'	// Mutated icon set.
	attack_verb = "claws"
	flags = HYPOTHERMIA_IMMUNE
	anatomy_flags = HAS_LIPS
	punch_damage = 7
	default_mutations=list(M_CLAWS,M_TALONS)
	has_mutant_race = 0

	primitive = /mob/living/carbon/monkey //Just to keep them SoC friendly.

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/monstrous
	)

/datum/species/vampire/makeName()
	return "vampire"

/datum/species/vampire/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/ghoul
	name = "Ghoul"
	icobase = 'icons/mob/human_races/r_ghoul.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi' //It's thin leathery skin on top of bone, deformation's just gonna show bone

	flags = NO_PAIN | WHITELISTED | RAD_ABSORB
	anatomy_flags = HAS_LIPS | HAS_SWEAT_GLANDS
	has_mutant_race = 0

	burn_mod = 1.2
	brute_mod = 0.8
	move_speed_multiplier = 2

	blood_color = GHOUL_BLOOD

	primitive = /mob/living/carbon/monkey //Just to keep them SoC friendly.

/datum/species/ghoul/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/slime
	name = "Slime"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_def_slime.dmi'
	known_languages = list(LANGUAGE_SLIME)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slime
	attack_verb = "glomps"
	tacklePower = 35

	flags = WHITELISTED | NO_BREATHE | ELECTRIC_HEAL
	anatomy_flags = NO_SKIN | NO_BLOOD | NO_BONES | NO_STRUCTURE | MULTICOLOR

	spells = list(/spell/regen_limbs)

	gender = NEUTER

	tox_mod = 2

	primitive = /mob/living/carbon/slime/pygmy

	blood_color = "#96FFC5"
	flesh_color = "#96FFC5"

	cold_level_1 = T0C  	// Cold damage level 1 below this point.
	cold_level_2 = T0C-23	// Cold damage level 2 below this point.
	cold_level_3 = T0C-43	// Cold damage level 3 below this point.

	heat_level_1 = T0C+57	// Heat damage level 1 above this point.
	heat_level_2 = T0C+77	// Heat damage level 2 above this point.
	heat_level_3 = T0C+100	// Heat damage level 3 above this point.

	has_mutant_race = 0

	has_organ = list(
		"brain" =    /datum/organ/internal/brain/slime_core,
		)

/datum/species/slime/handle_death(var/mob/living/carbon/human/H, gibbed) //Handles any species-specific death events (such as dionaea nymph spawns).
	H.dropBorers(gibbed)
	for(var/atom/movable/I in H.contents)
		I.forceMove(H.loc)
	anim(target = H, a_icon = 'icons/mob/mob.dmi', flick_anim = "liquify", sleeptime = 15)
	if(!gibbed)
		handle_slime_puddle(H)

/datum/species/slime/gib(mob/living/carbon/human/H)
	handle_slime_puddle(H)
	..()
	H.monkeyizing = TRUE
	for(var/datum/organ/external/E in H.organs)
		if(istype(E, /datum/organ/external/chest) || istype(E, /datum/organ/external/groin) || istype(E, /datum/organ/external/head))
			continue
		//Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			//Override the current limb status and don't cause an explosion
			E.droplimb(1, 1)
	var/gib_radius = 0
	if(H.reagents.has_reagent(LUBE))
		gib_radius = 6

	anim(target = H, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-h", sleeptime = 15)
	hgibs(H.loc, H.virus2, H.dna, flesh_color, blood_color, gib_radius)

/datum/species/slime/proc/handle_slime_puddle(var/mob/living/carbon/human/H)
	if(!H)
		return
	var/mob/living/slime_pile/S = new(H.loc)
	if(H.real_name)
		S.real_name = H.real_name
		S.name = "puddle of [H.real_name]"
		S.desc = "The slimy remains of what used to be [S.real_name]. There's probably still enough genetic material in there for a cloning console to work its magic."
	S.slime_person = H
	H.forceMove(S)
	//Transfer the DNA and mind into the slime puddle.
	S.dna=H.dna
	S.mind=H.mind

/mob/living/slime_pile //serves as the corpse of slime people
	name = "puddle of slime"
	desc = "The remains of a slime person."
	stat = DEAD
	icon = null //'icons/mob/human_races/r_slime.dmi'
	icon_state = null //"slime_puddle"
	density = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slime
	var/mob/living/carbon/human/slime_person

/mob/living/slime_pile/New()
	..()
	spawn(1)
		update_icon()

/mob/living/slime_pile/update_icon()
	if(slime_person)
		var/icon/I = new ('icons/mob/human_races/r_slime.dmi', "slime_puddle")
		I.Blend(rgb(slime_person.multicolor_skin_r, slime_person.multicolor_skin_g, slime_person.multicolor_skin_b), ICON_ADD)
		overlays += I

/mob/living/slime_pile/attack_hand(mob/user)
	if(slime_person)
		var/datum/organ/external/head = slime_person.get_organ(LIMB_HEAD)
		var/datum/organ/internal/I = slime_person.internal_organs_by_name["brain"]

		var/obj/item/organ/internal/O
		if(I && istype(I))
			O = I.remove(user)
			if(O && istype(O))

				O.organ_data.rejecting = null

				slime_person.internal_organs_by_name["brain"] = null
				slime_person.internal_organs_by_name -= "brain"
				slime_person.internal_organs -= O.organ_data
				head.internal_organs -= O.organ_data
				O.removed(slime_person,user)
				user.put_in_hands(O)
				to_chat(user, "<span class='notice'>You remove \the [O] from \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You root around inside \the [src], but find nothing.</span>")

/mob/living/slime_pile/attackby(obj/item/I, mob/user)
	if(slime_person)
		if(istype(I, /obj/item/organ/internal/brain/slime_core))
			if(slime_person.internal_organs_by_name["brain"])
				to_chat(user, "<span class='notice'>There is already \a [I] in \the [src].</span>")
				return
			if(user.drop_item(I))
				var/datum/organ/external/head = slime_person.get_organ(LIMB_HEAD)
				var/obj/item/organ/internal/O = I

				if(istype(O))
					O.organ_data.transplant_data = list()
					O.organ_data.transplant_data["species"] =    slime_person.species.name
					O.organ_data.transplant_data["blood_type"] = slime_person.dna.b_type
					O.organ_data.transplant_data["blood_DNA"] =  slime_person.dna.unique_enzymes

					O.organ_data.owner = slime_person
					slime_person.internal_organs |= O.organ_data
					head.internal_organs |= O.organ_data
					slime_person.internal_organs_by_name[O.organ_tag] = O.organ_data
					O.organ_data.status |= ORGAN_CUT_AWAY
					O.replaced(slime_person)

				to_chat(user, "<span class='notice'>You place \the [O] into \the [src].</span>")
				O.stabilized = TRUE
				O.loc = null

/datum/species/insectoid
	name = "Insectoid"
	icobase = 'icons/mob/human_races/r_insectoid.dmi'
	deform = 'icons/mob/human_races/r_def_insectoid.dmi'
	eyes = "insectoid_eyes_m"
	known_languages = list(LANGUAGE_INSECT)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/insectoid
	primitive = /mob/living/carbon/monkey/roach

	flags = WHITELISTED | PLAYABLE
	anatomy_flags = HAS_LIPS | HAS_SWEAT_GLANDS | NO_BALD | RGBSKINTONE

	burn_mod = 1.1
	tox_mod = 0.5
	rad_mod = 0.5

	blood_color = INSECT_BLOOD
	flesh_color = "#9C7F25"

	uniform_icons = 'icons/mob/species/insectoid/uniform.dmi'
//	fat_uniform_icons = 'icons/mob/uniform_fat.dmi'
	gloves_icons    = 'icons/mob/species/vox/gloves.dmi'
	glasses_icons   = 'icons/mob/species/insectoid/eyes.dmi'
	ears_icons      = 'icons/mob/species/insectoid/ears.dmi'
	shoes_icons 	= 'icons/mob/species/insectoid/feet.dmi'
	head_icons      = 'icons/mob/species/insectoid/head.dmi'
//	belt_icons      = 'icons/mob/belt.dmi'
	wear_suit_icons = 'icons/mob/species/insectoid/suit.dmi'
	wear_mask_icons = 'icons/mob/species/insectoid/mask.dmi'
//	back_icons      = 'icons/mob/back.dmi'


	has_mutant_race = 0

	has_organ = list(
		"heart" =    /datum/organ/internal/heart/insect,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"eyes" =     /datum/organ/internal/eyes/compound/
		)

	species_intro = "You are an Insectoid.<br>\
					Your body is highly resistant to the initial effects of radiation exposure, and you'll be better able to defend against toxic chemicals. <br>\
					However, your body is more susceptible to heat than that of other species. Resilient though you may be, heat and flame are your biggest concern."

/datum/species/insectoid/New()
	..()
	speech_filter = new /datum/speech_filter/insectoid

/datum/species/insectoid/makeName(var/gender,var/mob/living/carbon/human/H=null)
	var/sounds = rand(2,3)
	var/newname = ""

	for(var/i = 1 to sounds)
		newname += pick(insectoid_name_syllables)
	return capitalize(newname)

/datum/species/insectoid/gib(mob/living/carbon/human/H) //changed from Skrell to Insectoid for testing
	H.default_gib()

/datum/species/mushroom
	name = "Mushroom"
	icobase = 'icons/mob/human_races/r_mushman.dmi'
	deform = 'icons/mob/human_races/r_mushman.dmi'
	eyes = "mushroom_eyes"
	known_languages = list(LANGUAGE_VOX)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice/mushroom_man

	flags = WHITELISTED | PLAYABLE | NO_BREATHE | IS_PLANT | SPECIES_NO_MOUTH
	anatomy_flags = NO_BALD

	gender = NEUTER

	tox_mod = 0.8
	brute_mod = 1.8
	burn_mod = 0.6

	primitive = /mob/living/carbon/monkey/mushroom

	spells = list(/spell/targeted/genetic/invert_eyes, /spell/targeted/telepathy)


	default_mutations=list() //exoskeleton someday...

	blood_color = MUSHROOM_BLOOD
	flesh_color = "#D3D3D3"

	//Copypaste of Dionae
	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = T0C + 50
	heat_level_2 = T0C + 75
	heat_level_3 = T0C + 100

//	uniform_icons = 'icons/mob/species/mushroom/uniform.dmi'
//	fat_uniform_icons = 'icons/mob/uniform_fat.dmi'
//	gloves_icons    = 'icons/mob/species/vox/gloves.dmi'
//	glasses_icons   = 'icons/mob/species/vox/eyes.dmi'
//	ears_icons      = 'icons/mob/ears.dmi'
//	shoes_icons 	= 'icons/mob/species/vox/shoes.dmi'
	head_icons      = 'icons/mob/species/mushroom/head.dmi'
//	belt_icons      = 'icons/mob/belt.dmi'
	wear_suit_icons = 'icons/mob/species/mushroom/suit.dmi'
//	wear_mask_icons = 'icons/mob/species/mushroom/masks.dmi'
//	back_icons      = 'icons/mob/back.dmi'

	has_mutant_race = 0

	has_organ = list(
		"brain" =    /datum/organ/internal/brain/mushroom_brain,
		"eyes" =     /datum/organ/internal/eyes/mushroom,
		)

	species_intro = "You are a Mushroom Person.<br>\
					You are an odd creature. Your lack of a mouth prevents you from eating, but you can stand or lay on food to absorb it.<br>\
					You have a resistance to burn and toxin, but you are vulnerable to brute attacks.<br>\
					You are adept at seeing in the dark, moreso with your light inversion ability. When you speak, it will only go to the target chosen with your Fungal Telepathy.<br>\
					You also have access to the Sporemind, which allows you to communicate with others on the Sporemind through :~"
	var/mob/living/telepathic_target[] = list()

/datum/species/mushroom/makeName()
	return capitalize(pick(mush_first)) + " " + capitalize(pick(mush_last))

/datum/species/mushroom/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/datum/species/mushroom/silent_speech(mob/M, message)
	if(!message)
		return
	if(M.stat == DEAD)
		to_chat(M, "<span class='warning'>You must be alive to do this!</span>")
		return
	if (M.stat == UNCONSCIOUS)
		to_chat(M, "<span class='warning'>You must be conscious to do this!</span>")
		return

	if(!telepathic_target.len)
		var/mob/living/L = M
		telepathic_target += L

	var/all_switch = TRUE
	for(var/mob/living/T in telepathic_target)
		if(istype(T) && M.can_mind_interact(T))
			to_chat(T,"<span class='mushroom'>You feel <b>[M]</b>'s thoughts: </span><span class='mushroom'>[message]</span>")
		if(all_switch)
			all_switch = FALSE
			if(T != M)
				to_chat(M,"<span class='mushroom'>Projected to <b>[english_list(telepathic_target)]</b>: \"[message]\"</span>")
			for(var/mob/dead/observer/G in dead_mob_list)
				G.show_message("<i>Telepathy, <b>[M]</b> to <b>[english_list(telepathic_target)]</b>: [message]</i>")
			log_admin("[key_name(M)] projects his mind towards [english_list(telepathic_target)]: [message]")

/datum/species/lich
	name = "Undead"
	icobase = 'icons/mob/human_races/r_lich.dmi'
	deform = 'icons/mob/human_races/r_lich.dmi'
	known_languages = list(LANGUAGE_CLATTER)
	flags = WHITELISTED | NO_BREATHE
	anatomy_flags = HAS_LIPS | NO_SKIN | NO_BLOOD
	meat_type = /obj/item/stack/sheet/bone
	chem_flags = NO_EAT | NO_INJECT

	brute_mod = 1.2

	has_organ = list(
		"brain" =    /datum/organ/internal/brain,
		)

	move_speed_multiplier = 1

	primitive = /mob/living/carbon/monkey/skellington

	species_intro = "You are a Lich<br>\
					A more refined version of the skellington, you're not as brittle, but not quite as fast.<br>\
					You have no skin, no blood, and only a brain to guide you.<br>\
					You can not eat normally, as your necrotic state permits you to only eat raw flesh. As you lack skin, you can not be injected via syringe."

/datum/species/lich/gib(mob/living/carbon/human/H)
	..()
	var/datum/organ/external/head_organ = H.get_organ(LIMB_HEAD)
	if(head_organ.status & ORGAN_DESTROYED)
		new /obj/effect/decal/remains/human/noskull(H.loc)
	else
		new /obj/effect/decal/remains/human(H.loc)
		head_organ.droplimb(1,1)

	H.drop_all()
	qdel(src)
