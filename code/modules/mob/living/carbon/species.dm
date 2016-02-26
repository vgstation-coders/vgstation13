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
		if(S.flags & IS_WHITELISTED) whitelisted_species += S.name
	return

////////////////////////////////////////////////////////////////

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human_races/r_human.dmi'		// Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi'	// Mutated icon set.
	var/override_icon = null								// DMI for overriding the icon.  states: [lowertext(species.name)]_[gender][fat?"_fat":""]
	var/eyes = "eyes_s"										// Icon for eyes.

	var/primitive											// Lesser form, if any (ie. monkey for humans)
	var/tail												// Name of tail image in species effects icon file.
	var/language = "Galactic Common"								// Default racial language, if any.
	var/default_language = "Galactic Common"						// Default language is used when 'say' is used without modifiers.
	var/attack_verb = "punch"								// Empty hand hurt intent verb.
	var/punch_damage = 0									// Extra empty hand attack damage.
	var/punch_throw_range = 0
	var/punch_throw_speed = 1
	var/mutantrace											// Safeguard due to old code.

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/survival_gear = /obj/item/weapon/storage/box/survival // For spawnin'.

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 1000 // Heat damage level 2 above this point.

	var/fireloss_mult = 1

	var/darksight = 2
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

	var/body_temperature = 310.15

	// For grays
	var/max_hurt_damage = 5 // Max melee damage dealt + 5 if hulk
	var/list/default_mutations = list()
	var/list/default_blocks = list() // Don't touch.
	var/list/default_block_names = list() // Use this instead, using the names from setupgame.dm

	var/flags = 0       // Various specific features.
	var/chem_flags = 0 //how we handle chemicals and eating/drinking i guess

	var/list/abilities = list()	// For species-derived or admin-given powers

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/base_color      //Used when setting species.
	var/uniform_icons = 'icons/mob/uniform.dmi'
	var/fat_uniform_icons = 'icons/mob/uniform_fat.dmi'
	var/gloves_icons    = 'icons/mob/hands.dmi'
	var/glasses_icons   = 'icons/mob/eyes.dmi'
	var/ears_icons      = 'icons/mob/ears.dmi'
	var/shoes_icons     = 'icons/mob/feet.dmi'
	var/head_icons      = 'icons/mob/head.dmi'
	var/belt_icons      = 'icons/mob/belt.dmi'
	var/wear_suit_icons = 'icons/mob/suit.dmi'
	var/wear_mask_icons = 'icons/mob/mask.dmi'
	var/back_icons      = 'icons/mob/back.dmi'


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
	var/can_be_hypothermic = 1
	var/has_sweat_glands = 1

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
		H.organs.len=0
	if(H.internal_organs)
		for(var/datum/organ/internal/I in H.internal_organs)
			I.Remove(H, quiet=1) // GET OUT REEEEEEE
		H.internal_organs.len=0
	if(H.organs_by_name)
		H.organs_by_name.len=0
	if(H.internal_organs_by_name)
		H.internal_organs_by_name.len=0


/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs.


	//This is a basic humanoid limb setup.
	H.organs = list()
	H.organs_by_name["chest"] = new/datum/organ/external/chest()
	H.organs_by_name["groin"] = new/datum/organ/external/groin(H.organs_by_name["chest"])
	H.organs_by_name["head"] = new/datum/organ/external/head(H.organs_by_name["chest"])
	H.organs_by_name["l_arm"] = new/datum/organ/external/l_arm(H.organs_by_name["chest"])
	H.organs_by_name["r_arm"] = new/datum/organ/external/r_arm(H.organs_by_name["chest"])
	H.organs_by_name["r_leg"] = new/datum/organ/external/r_leg(H.organs_by_name["groin"])
	H.organs_by_name["l_leg"] = new/datum/organ/external/l_leg(H.organs_by_name["groin"])
	H.organs_by_name["l_hand"] = new/datum/organ/external/l_hand(H.organs_by_name["l_arm"])
	H.organs_by_name["r_hand"] = new/datum/organ/external/r_hand(H.organs_by_name["r_arm"])
	H.organs_by_name["l_foot"] = new/datum/organ/external/l_foot(H.organs_by_name["l_leg"])
	H.organs_by_name["r_foot"] = new/datum/organ/external/r_foot(H.organs_by_name["r_leg"])

	H.internal_organs = list()
	for(var/organ in has_organ)
		var/organ_type = has_organ[organ]
		var/datum/organ/internal/O = new organ_type(H)
		if(O.CanInsert(H))
			H.internal_organs_by_name[organ] = O
			O.Insert(H)

	for(var/name in H.organs_by_name)
		H.organs += H.organs_by_name[name]

	for(var/datum/organ/external/O in H.organs)
		O.owner = H

	if(flags & IS_SYNTHETIC)
		for(var/datum/organ/external/E in H.organs)
			if(E.status & ORGAN_CUT_AWAY || E.status & ORGAN_DESTROYED) continue
			E.status |= ORGAN_ROBOT
		for(var/datum/organ/internal/I in H.internal_organs)
			I.mechanize()

/datum/species/proc/handle_post_spawn(var/mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
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
		return moles/6
	else
		//testing("  ratio < 1, adding oxyLoss.")
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
		H.failed_last_breath = 1
		return moles*ratio/6

// Used for species-specific names (Vox, etc)
/datum/species/proc/makeName(var/gender,var/mob/living/carbon/C=null)
	if(gender==FEMALE)	return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else				return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/datum/species/proc/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	/*
	if(flags & IS_SYNTHETIC)
		//H.Jitter(200) //S-s-s-s-sytem f-f-ai-i-i-i-i-lure-ure-ure-ure
		H.h_style = ""
		spawn(100)
			//H.is_jittery = 0
			//H.jitteriness = 0
			H.update_hair()
	*/
	return

/datum/species/proc/equip(var/mob/living/carbon/human/H)

/datum/species/human
	name = "Human"
	language = "Sol Common"
	primitive = /mob/living/carbon/monkey

	flags = HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT

/datum/species/manifested
	name = "Manifested"
	icobase = 'icons/mob/human_races/r_manifested.dmi'
	deform = 'icons/mob/human_races/r_def_manifested.dmi'
	language = "Sol Common"
	primitive = /mob/living/carbon/monkey

	flags = HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT | NO_BLOOD

/datum/species/unathi
	name = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	attack_verb = "scratch"
	punch_damage = 5
	primitive = /mob/living/carbon/monkey/unathi
	darksight = 3

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000
	has_sweat_glands = 0
	flags = IS_WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL

	flesh_color = "#34AF10"

/datum/species/unathi/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	speech.message = replacetext(speech.message, "s", stutter("ss"))
	return ..(speech, H)

/datum/species/skellington // /vg/
	name = "Skellington"
	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'  // TODO: Need deform.
	language = "Clatter"
	attack_verb = "punch"
	has_sweat_glands = 0
	flags = IS_WHITELISTED | HAS_LIPS | NO_BREATHE | NO_BLOOD | NO_SKIN

	chem_flags = NO_DRINK | NO_EAT | NO_INJECT

	default_mutations=list(SKELETON)
	brute_mod = 2.0

	has_organ = list(
		"brain" =    /datum/organ/internal/brain,
		)

	move_speed_mod = 3

/datum/species/skellington/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	if (prob(25))
		speech.message += "  ACK ACK!"

	return ..(speech, H)

/datum/species/tajaran
	name = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'tajr"
	tail = "tajtail"
	attack_verb = "scratch"
	punch_damage = 2 //Claws add 3 damage without gloves, so the total is 5
	darksight = 8

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	primitive = /mob/living/carbon/monkey/tajara

	flags = IS_WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL

	default_mutations=list(M_CLAWS)

	flesh_color = "#AFA59E"

	var/datum/speech_filter/filter = new

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes/tajaran
	)

/datum/species/tajaran/New()
	// Combining all the worst shit the world has ever offered.

	// Note: Comes BEFORE other stuff.
	// Trying to remember all the stupid fucking furry memes is hard
	filter.addPickReplacement("\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger)",
		list(
			"silly rabbit",
			"sandwich", // won't work too well with plurals OH WELL
			"recolor",
			"party pooper"
		)
	)
	filter.addWordReplacement("me","meow")
	filter.addWordReplacement("I","meow") // Should replace with player's first name.
	filter.addReplacement("fuck","yiff")
	filter.addReplacement("shit","scat")
	filter.addReplacement("scratch","scritch")
	filter.addWordReplacement("(help|assist)\\bmeow","kill meow") // help me(ow) -> kill meow
	filter.addReplacement("god","gosh")
	filter.addWordReplacement("(ass|butt)", "rump")

/datum/species/tajaran/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	if (prob(15))
		speech.message = ""

		if (prob(50))
			speech.message = pick("GOD, PLEASE", "NO, GOD", "AGGGGGGGH") + " "

		speech.message += pick("KILL ME", "END MY SUFFERING", "I CAN'T DO THIS ANYMORE")

		return ..(speech, H)

	return ..(filter.FilterSpeech(speech), H)

/datum/species/grey // /vg/
	name = "Grey"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	language = "Grey"
	attack_verb = "punch"
	darksight = 5 // BOOSTED from 2
	eyes = "grey_eyes_s"

	max_hurt_damage = 3 // From 5 (for humans)

	primitive = /mob/living/carbon/monkey // TODO

	flags = IS_WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT

	// Both must be set or it's only a 45% chance of manifesting.
	default_mutations=list(M_REMOTE_TALK)
	default_block_names=list("REMOTETALK")

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

/datum/species/muton // /vg/
	name = "Muton"
	icobase = 'icons/mob/human_races/r_muton.dmi'
	deform = 'icons/mob/human_races/r_def_muton.dmi'
	language = "Muton"
	attack_verb = "punch"
	darksight = 1
	eyes = "eyes_s"

	max_hurt_damage = 10

	primitive = /mob/living/carbon/monkey // TODO

	flags = HAS_LIPS

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
	language = "Skrellian"
	primitive = /mob/living/carbon/monkey/skrell

	flags = IS_WHITELISTED | HAS_LIPS | HAS_UNDERWEAR

	flesh_color = "#8CD7A3"

/datum/species/vox
	name = "Vox"
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = "Vox-pidgin"

	survival_gear = /obj/item/weapon/storage/box/survival/vox

	primitive = /mob/living/simple_animal/chicken

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"
	breath_type = "nitrogen"

	default_mutations = list(M_BEAK)
	flags = IS_WHITELISTED | NO_SCAN

	blood_color = "#2299FC"
	flesh_color = "#808D11"

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
		"eyes" =     /datum/organ/internal/eyes
	)

	equip(var/mob/living/carbon/human/H)
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

			if("Scientist","Roboticist")
				suit=/obj/item/clothing/suit/space/vox/civ/science
				helm=/obj/item/clothing/head/helmet/space/vox/civ/science
			if("Research Director")
				suit=/obj/item/clothing/suit/space/vox/civ/science/rd
				helm=/obj/item/clothing/head/helmet/space/vox/civ/science/rd

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

			if("Clown","Mime")
				tank_slot=slot_r_hand
				tank_slot_name = "hand"
			if("MODE") // Gamemode stuff
				switch(H.mind.special_role)
					if("Wizard")
						suit = null
						helm = null
						tank_slot = slot_l_hand
						tank_slot_name = "hand"
		if(suit)
			H.equip_or_collect(new suit(H), slot_wear_suit)
		if(helm)
			H.equip_or_collect(new helm(H), slot_head)
		H.equip_or_collect(new/obj/item/weapon/tank/nitrogen(H), tank_slot)
		to_chat(H, "<span class='info'>You are now running on nitrogen internals from the [H.s_store] in your [tank_slot_name]. Your species finds oxygen toxic, so <b>you must breathe nitrogen (AKA N<sub>2</sub>) only</b>.</span>")
		H.internal = H.get_item_by_slot(tank_slot)
		if (H.internals)
			H.internals.icon_state = "internal1"

	makeName(var/gender,var/mob/living/carbon/human/H=null)
		var/sounds = rand(2,8)
		var/i = 0
		var/newname = ""

		while(i<=sounds)
			i++
			newname += pick(vox_name_syllables)
		return capitalize(newname)

/datum/species/diona
	name = "Diona"
	icobase = 'icons/mob/human_races/r_plant.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	attack_verb = "slash"
	punch_damage = 5
	primitive = /mob/living/carbon/monkey/diona

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	flags = IS_WHITELISTED | NO_BREATHE | REQUIRE_LIGHT | NO_SCAN | IS_PLANT | RAD_ABSORB | NO_BLOOD | IS_SLOW | NO_PAIN

	blood_color = "#004400"
	flesh_color = "#907E4A"

	has_mutant_race = 0
	burn_mod = 2.5 //treeeeees

	move_speed_mod = 7
