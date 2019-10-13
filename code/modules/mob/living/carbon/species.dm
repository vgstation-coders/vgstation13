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

/proc/buildSpeciesLists()
	var/datum/language/L
	var/datum/species/S
	for(. in (typesof(/datum/language)-/datum/language))
		L = new .
		all_languages[L.name] = L
	for (var/language_name in all_languages)
		L = all_languages[language_name]
		language_keys[":[lowertext(L.key)]"] = L
		language_keys[".[lowertext(L.key)]"] = L
		language_keys["#[lowertext(L.key)]"] = L
	for(. in (typesof(/datum/species)-/datum/species))
		S = new .
		all_species[S.name] = S
		if(S.flags & IS_WHITELISTED)
			whitelisted_species += S.name
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

	var/body_temperature = 310.15

	var/footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints //The type of footprint the species leaves if they are not wearing shoes. If we ever get any other than human and vox, maybe this should be explicitly defined for each species.

	// For grays
	var/max_hurt_damage = 5 // Max melee damage dealt
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

/datum/species/proc/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
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
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
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

/datum/species/proc/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

/datum/species/proc/can_artifact_revive()
	return 1

/datum/species/proc/OnCrit(var/mob/living/carbon/human/H)

/datum/species/proc/OutOfCrit(var/mob/living/carbon/human/H)

/datum/species/proc/equip(var/mob/living/carbon/human/H)

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

/datum/species/proc/conditional_whitelist()
	return 0

/datum/species/human
	name = "Human"
	known_languages = list(LANGUAGE_HUMAN)
	primitive = /mob/living/carbon/monkey

	anatomy_flags = HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT | HAS_SWEAT_GLANDS

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

	blood_color = "#272727"
	flesh_color = "#C3C1BE"

/datum/species/manifested/handle_death(var/mob/living/carbon/human/H)
	H.dust()

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

	flags = IS_WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL

	default_mutations=list(M_CLAWS)

	flesh_color = "#34AF10"
	
	head_icons      = 'icons/mob/species/unathi/head.dmi'
	wear_suit_icons = 'icons/mob/species/unathi/suit.dmi'


/datum/species/unathi/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	speech.message = replacetext(speech.message, "s", "s-s") //not using stutter("s") because it likes adding more s's.
	speech.message = replacetext(speech.message, "s-ss-s", "ss-ss") //asshole shows up as ass-sshole


/datum/species/skellington // /vg/
	name = "Skellington"
	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'  // TODO: Need deform.
	known_languages = list(LANGUAGE_CLATTER)
	flags = IS_WHITELISTED | NO_BREATHE
	anatomy_flags = HAS_LIPS | NO_SKIN | NO_BLOOD
	meat_type = /obj/item/stack/sheet/bone
	chem_flags = NO_EAT | NO_INJECT

	default_mutations=list(M_SKELETON)
	brute_mod = 2.0

	has_organ = list(
		"brain" =    /datum/organ/internal/brain,
		)

	move_speed_multiplier = 1.5

	primitive = /mob/living/carbon/monkey/skellington

	species_intro = "You are a Skellington<br>\
					You have no skin, no blood, no lips, and only just enough brain to function.<br>\
					You can not eat normally, as your necrotic state only permits you to only eat raw flesh. As you lack skin, you can not be injected via syringe.<br>\
					You are also incredibly weak to brute damage, but you're fast and don't need to breathe, so that's going for you."

/datum/species/skellington/conditional_whitelist()
	var/MM = text2num(time2text(world.timeofday, "MM"))
	return MM == 10 //October


/datum/species/skellington/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	if (prob(25))
		speech.message += "  ACK ACK!"

	return ..(speech, H)

/datum/species/skellington/can_artifact_revive()
	return 0

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

	flags = IS_WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL | HAS_SWEAT_GLANDS

	default_mutations=list(M_CLAWS)

	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/catbeast

	flesh_color = "#AFA59E"

	var/datum/speech_filter/speech_filter = new

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
	// Combining all the worst shit the world has ever offered.

	// Note: Comes BEFORE other stuff.
	// Trying to remember all the stupid fucking furry memes is hard
	speech_filter.addPickReplacement("\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger)\\b",
		list(
			"silly rabbit",
			"sandwich", // won't work too well with plurals OH WELL
			"recolor",
			"party pooper"
		)
	)
	speech_filter.addWordReplacement("me","meow")
	speech_filter.addWordReplacement("I","meow") // Should replace with player's first name.
	speech_filter.addReplacement("fuck","yiff")
	speech_filter.addReplacement("shit","scat")
	speech_filter.addReplacement("scratch","scritch")
	speech_filter.addWordReplacement("(help|assist)\\smeow","kill meow") // help me(ow) -> kill meow
	speech_filter.addReplacement("god","gosh")
	speech_filter.addWordReplacement("(ass|butt)", "rump")

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

	speech.message = speech_filter.FilterSpeech(speech.message)
	return ..()

/datum/species/grey // /vg/
	name = "Grey"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	known_languages = list(LANGUAGE_GREY)
	eyes = "grey_eyes_s"

	max_hurt_damage = 3 // From 5 (for humans)

	primitive = /mob/living/carbon/monkey/grey

	flags = IS_WHITELISTED
	anatomy_flags = HAS_LIPS | CAN_BE_FAT | HAS_SWEAT_GLANDS | ACID4WATER

	// Both must be set or it's only a 45% chance of manifesting.
	default_mutations=list(M_REMOTE_TALK)
	default_block_names=list("REMOTETALK")

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
					You're not as good in a fist fight as a regular baseline human, but you make up for this by bullying them from afar by talking directly into peoples minds."

/datum/species/muton // /vg/
	name = "Muton"
	icobase = 'icons/mob/human_races/r_muton.dmi'
	deform = 'icons/mob/human_races/r_def_muton.dmi'
	//known_languages = list("Muton") //this language doesn't even EXIST
	eyes = "eyes_s"

	max_hurt_damage = 10

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

/datum/species/muton/equip(var/mob/living/carbon/human/H)
	// Unequip existing suits and hats.
	H.u_equip(H.wear_suit,1)
	H.u_equip(H.head,1)

	move_speed_mod = 1

/datum/species/skrell
	name = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	known_languages = list(LANGUAGE_SKRELLIAN)
	primitive = /mob/living/carbon/monkey/skrell

	flags = IS_WHITELISTED
	anatomy_flags = HAS_LIPS | HAS_UNDERWEAR | HAS_SWEAT_GLANDS

	flesh_color = "#8CD7A3"
	

	head_icons      = 'icons/mob/species/skrell/head.dmi'
	wear_suit_icons = 'icons/mob/species/skrell/suit.dmi'


/datum/species/vox
	name = "Vox"
	icobase = 'icons/mob/human_races/vox/r_vox.dmi'
	deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
	known_languages = list(LANGUAGE_VOX)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox

	anatomy_flags = HAS_SWEAT_GLANDS

	survival_gear = /obj/item/weapon/storage/box/survival/vox

	primitive = /mob/living/carbon/monkey/vox

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"
	breath_type = GAS_NITROGEN

	default_mutations = list(M_BEAK, M_TALONS)
	flags = IS_WHITELISTED | NO_SCAN

	blood_color = "#2299FC"
	flesh_color = "#808D11"

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
//	back_icons      = 'icons/mob/back.dmi'

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

/datum/species/vox/equip(var/mob/living/carbon/human/H)
	// Unequip existing suits and hats.
	if(H.mind.assigned_role != "MODE")
		H.u_equip(H.wear_suit,1)
		H.u_equip(H.head,1)
	if(H.mind.assigned_role!="Clown")
		H.u_equip(H.wear_mask,1)

	H.equip_or_collect(new /obj/item/clothing/mask/breath/vox(H), slot_wear_mask)
	var/suit=/obj/item/clothing/suit/space/vox/civ
	var/helm=/obj/item/clothing/head/helmet/space/vox/civ
	var/tank_slot = slot_s_store
	var/tank_slot_name = "suit storage"
	switch(H.mind.assigned_role)

		if("Bartender")
			suit=/obj/item/clothing/suit/space/vox/civ/bartender
			helm=/obj/item/clothing/head/helmet/space/vox/civ/bartender
		if("Chef")
			suit=/obj/item/clothing/suit/space/vox/civ/chef
			helm=/obj/item/clothing/head/helmet/space/vox/civ/chef
		if("Botanist")
			suit=/obj/item/clothing/suit/space/vox/civ/botanist
			helm=/obj/item/clothing/head/helmet/space/vox/civ/botanist
		if("Janitor")
			suit=/obj/item/clothing/suit/space/vox/civ/janitor
			helm=/obj/item/clothing/head/helmet/space/vox/civ/janitor
		if("Cargo Technician","Quartermaster")
			suit=/obj/item/clothing/suit/space/vox/civ/cargo
			helm=/obj/item/clothing/head/helmet/space/vox/civ/cargo
		if("Shaft Miner")
			suit=/obj/item/clothing/suit/space/vox/civ/mining
			helm=/obj/item/clothing/head/helmet/space/vox/civ/mining
		if("Mechanic")
			suit=/obj/item/clothing/suit/space/vox/civ/mechanic
			helm=/obj/item/clothing/head/helmet/space/vox/civ/mechanic
		if("Chaplain")
			suit=/obj/item/clothing/suit/space/vox/civ/chaplain
			helm=/obj/item/clothing/head/helmet/space/vox/civ/chaplain
		if("Librarian")
			suit=/obj/item/clothing/suit/space/vox/civ/librarian
			helm=/obj/item/clothing/head/helmet/space/vox/civ/librarian

		if("Chief Engineer")
			suit=/obj/item/clothing/suit/space/vox/civ/engineer/ce
			helm=/obj/item/clothing/head/helmet/space/vox/civ/engineer/ce
		if("Station Engineer")
			suit=/obj/item/clothing/suit/space/vox/civ/engineer
			helm=/obj/item/clothing/head/helmet/space/vox/civ/engineer
		if("Atmospheric Technician")
			suit=/obj/item/clothing/suit/space/vox/civ/engineer/atmos
			helm=/obj/item/clothing/head/helmet/space/vox/civ/engineer/atmos

		if("Scientist")
			suit=/obj/item/clothing/suit/space/vox/civ/science
			helm=/obj/item/clothing/head/helmet/space/vox/civ/science
		if("Research Director")
			suit=/obj/item/clothing/suit/space/vox/civ/science/rd
			helm=/obj/item/clothing/head/helmet/space/vox/civ/science/rd
		if("Roboticist")
			suit=/obj/item/clothing/suit/space/vox/civ/science/roboticist
			helm=/obj/item/clothing/head/helmet/space/vox/civ/science/roboticist

		if("Medical Doctor")
			suit=/obj/item/clothing/suit/space/vox/civ/medical
			helm=/obj/item/clothing/head/helmet/space/vox/civ/medical
		if("Paramedic")
			suit=/obj/item/clothing/suit/space/vox/civ/medical/paramedic
			helm=/obj/item/clothing/head/helmet/space/vox/civ/medical/paramedic
		if("Geneticist")
			suit=/obj/item/clothing/suit/space/vox/civ/medical/geneticist
			helm=/obj/item/clothing/head/helmet/space/vox/civ/medical/geneticist
		if("Virologist")
			suit=/obj/item/clothing/suit/space/vox/civ/medical/virologist
			helm=/obj/item/clothing/head/helmet/space/vox/civ/medical/virologist
		if("Chemist")
			suit=/obj/item/clothing/suit/space/vox/civ/medical/chemist
			helm=/obj/item/clothing/head/helmet/space/vox/civ/medical/chemist
		if("Chief Medical Officer")
			suit=/obj/item/clothing/suit/space/vox/civ/medical/cmo
			helm=/obj/item/clothing/head/helmet/space/vox/civ/medical/cmo

		if("Head of Security","Warden","Detective","Security Officer")
			suit=/obj/item/clothing/suit/space/vox/civ/security
			helm=/obj/item/clothing/head/helmet/space/vox/civ/security

//		if("Clown","Mime")
//			tank_slot=null
//			tank_slot_name = "hand"
		if("Trader")
			suit = /obj/item/clothing/suit/space/vox/civ/trader
			helm = /obj/item/clothing/head/helmet/space/vox/civ/trader

		if("MODE") // Gamemode stuff
			switch(H.mind.special_role)
				if("Wizard")
					suit = null
					helm = null
					tank_slot = null
					tank_slot_name = "hand"
	if(suit)
		H.equip_or_collect(new suit(H), slot_wear_suit)
	if(helm)
		H.equip_or_collect(new helm(H), slot_head)
	if(tank_slot)
		H.equip_or_collect(new/obj/item/weapon/tank/nitrogen(H), tank_slot)
	else
		H.put_in_hands(new/obj/item/weapon/tank/nitrogen(H))
	to_chat(H, "<span class='info'>You are now running on nitrogen internals from the [H.s_store] in your [tank_slot_name].</span>")
	H.internal = H.get_item_by_slot(tank_slot)
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

/datum/species/diona
	name = "Diona"
	icobase = 'icons/mob/human_races/r_plant.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	known_languages = list(LANGUAGE_ROOTSPEAK)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/diona
	attack_verb = "slashes"
	punch_damage = 5
	primitive = /mob/living/carbon/monkey/diona

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = T0C + 50
	heat_level_2 = T0C + 75
	heat_level_3 = T0C + 100

	flags = IS_WHITELISTED | NO_BREATHE | REQUIRE_LIGHT | NO_SCAN | IS_PLANT | RAD_ABSORB | IS_SLOW | NO_PAIN | HYPOTHERMIA_IMMUNE
	anatomy_flags = NO_BLOOD | HAS_SWEAT_GLANDS

	blood_color = "#004400"
	flesh_color = "#907E4A"

	has_mutant_race = 0
	burn_mod = 2.5 //treeeeees

	move_speed_mod = 7

	species_intro = "You are a Diona.<br>\
					You are a plant, so light is incredibly helpful for you, in both photosynthesis, and regenerating damage you have received.<br>\
					You absorb radiation which helps you in a similar way to sunlight. You are incredibly slow as you are rooted to the ground.<br>\
					You do not need to breathe, do not feel pain,  you are incredibly resistant to cold and low pressure, and have no blood to bleed.<br>\
					However, as you are a plant, you are incredibly susceptible to burn damage, which is something you can not regenerate normally."

/datum/species/golem
	name = "Golem"
	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_def_golem.dmi'
	known_languages = list(LANGUAGE_GOLEM)
	meat_type = /obj/item/stack/ore/diamond
	attack_verb = "punches"

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
					var/mob/dead/observer/ghost = mind_can_reenter(mind)
					if(ghost)
						var/mob/ghostmob = ghost.get_top_transmogrification()
						if(ghostmob)
							ghostmob << 'sound/effects/adminhelp.ogg'
							to_chat(ghostmob, "<span class='interface big'><span class='bold'>Someone is trying to resurrect you. Return to your body if you want to live again!</span> \
								(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</span>")
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

/datum/species/grue
	name = "Grue"
	icobase = 'icons/mob/human_races/r_grue.dmi'		// Normal icon set.
	deform = 'icons/mob/human_races/r_def_grue.dmi'	// Mutated icon set.
	eyes = "grue_eyes_s"
	attack_verb = "claws"
	flags = NO_PAIN | IS_WHITELISTED | HYPOTHERMIA_IMMUNE
	anatomy_flags = HAS_LIPS
	punch_damage = 7
	default_mutations=list(M_HULK,M_CLAWS,M_TALONS)
	burn_mod = 2
	brute_mod = 2
	move_speed_multiplier = 2
	has_mutant_race = 0

	primitive = /mob/living/carbon/monkey //Just to keep them SoC friendly.

	spells = list(/spell/swallow_light,/spell/shatter_lights)

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/grue
	)

/datum/species/grue/makeName()
	return "grue"


/datum/species/ghoul
	name = "Ghoul"
	icobase = 'icons/mob/human_races/r_ghoul.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi' //It's thin leathery skin on top of bone, deformation's just gonna show bone

	flags = NO_PAIN | IS_WHITELISTED | RAD_ABSORB
	anatomy_flags = HAS_LIPS | HAS_SWEAT_GLANDS
	has_mutant_race = 0

	burn_mod = 1.2
	brute_mod = 0.8
	move_speed_multiplier = 2

	blood_color = "#7FFF00"

	primitive = /mob/living/carbon/monkey //Just to keep them SoC friendly.

/datum/species/slime
	name = "Slime"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_def_slime.dmi'
	known_languages = list(LANGUAGE_SLIME)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slime
	attack_verb = "glomps"

	flags = IS_WHITELISTED | NO_BREATHE
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

/datum/species/slime/xenobio
	name = "Evolved Slime"
	flags = IS_WHITELISTED | NO_BREATHE | ELECTRIC_HEAL

/datum/species/slime/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	for(var/atom/movable/I in H.contents)
		I.forceMove(H.loc)
	anim(target = H, a_icon = 'icons/mob/mob.dmi', flick_anim = "liquify", sleeptime = 15)
	var/mob/living/slime_pile/S = new(H.loc)
	if(H.real_name)
		S.real_name = H.real_name
		S.desc = "The remains of what used to be [S.real_name]."
	S.slime_person = H
	H.forceMove(S)

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

					O.organ_data.organ_holder = null
					O.organ_data.owner = slime_person
					slime_person.internal_organs |= O.organ_data
					head.internal_organs |= O.organ_data
					slime_person.internal_organs_by_name[O.organ_tag] = O.organ_data
					O.organ_data.status |= ORGAN_CUT_AWAY
					O.replaced(slime_person)

				to_chat(user, "<span class='notice'>You place \the [O] into \the [src].</span>")
				qdel(O)


/datum/species/mushroom
	name = "Mushroom"
	icobase = 'icons/mob/human_races/r_mushman.dmi'
	deform = 'icons/mob/human_races/r_mushman.dmi'
	known_languages = list(LANGUAGE_VOX)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/mushroom_man

	flags = IS_WHITELISTED | NO_BREATHE | IS_PLANT | REQUIRE_DARK | IS_SPECIES_MUTE

	gender = NEUTER

	tox_mod = 0.8
	brute_mod = 1.8
	burn_mod = 0.6

	primitive = /mob/living/carbon/monkey/mushroom

	spells = list(/spell/targeted/genetic/invert_eyes)

	default_mutations=list(M_REMOTE_TALK)
	default_block_names=list("REMOTETALK")

	blood_color = "#D3D3D3"
	flesh_color = "#D3D3D3"

	//Copypaste of Dionae
	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = T0C + 50
	heat_level_2 = T0C + 75
	heat_level_3 = T0C + 100

	has_mutant_race = 0

	has_organ = list(
		"brain" =    /datum/organ/internal/brain/mushroom_brain,
		)

	species_intro = "You are a Mushroom Person.<br>\
					You are an odd creature, light harms you and makes you hunger, but the darkness heals you and feeds you.<br>\
					You have a resistance to burn and toxin, but a weakness to brute damage. You are adept at seeing in the dark, moreso with your light inversion ability.<br>\
					However, you lack a mouth with which to talk. Instead you can remotely talk into somebodies mind should you examine them, or they talk to you.<br>\
					You also have access to the Sporemind, which allows you to communicate with others on the Sporemind through :~"

/datum/species/lich
	name = "Undead"
	icobase = 'icons/mob/human_races/r_lich.dmi'
	deform = 'icons/mob/human_races/r_lich.dmi'
	known_languages = list(LANGUAGE_CLATTER)
	flags = IS_WHITELISTED | NO_BREATHE
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
