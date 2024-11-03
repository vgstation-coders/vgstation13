/datum/species/vox
	name = "Vox"
	icobase = 'icons/mob/human_races/vox/r_vox.dmi'
	deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
	known_languages = list(LANGUAGE_VOX)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox
	tacklePower = 40
	anatomy_flags = HAS_SWEAT_GLANDS | HAS_ICON_SKIN_TONE | HAS_TAIL

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
	tail = "green"
	tail_icon = 'icons/mob/human_races/vox/tails.dmi'
	tail_type = "vox"
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
	accessory_icons = 'icons/mob/species/vox/clothing_accessories.dmi'
	has_mutant_race = 0
	has_organ = list(
		"heart" =    /datum/organ/internal/heart/vox,
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

/datum/species/vox/updatespeciescolor(mob/living/carbon/human/vox)
	var/datum/organ/external/tail/vox_tail = vox.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	switch(vox.my_appearance.s_tone)
		if(VOXEMERALD)
			icobase = 'icons/mob/human_races/vox/r_voxemrl.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxemrl.dmi'
		if(VOXAZURE)
			icobase = 'icons/mob/human_races/vox/r_voxazu.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxazu.dmi'
		if(VOXLGREEN)
			icobase = 'icons/mob/human_races/vox/r_voxlgrn.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxlgrn.dmi'
		if(VOXGRAY)
			icobase = 'icons/mob/human_races/vox/r_voxgry.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxgry.dmi'
		if(VOXBROWN)
			icobase = 'icons/mob/human_races/vox/r_voxbrn.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxbrn.dmi'
		else
			icobase = 'icons/mob/human_races/vox/r_vox.dmi'
			deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
	if(vox_tail && (vox_tail.status & ORGAN_DESTROYED))
		return
	vox_tail.update_tail(vox)

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
	accessory_icons = 'icons/mob/species/vox/clothing_accessories.dmi'
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
