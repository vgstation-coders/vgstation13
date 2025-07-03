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
	// Ensure Vox have feather butchering product on spawn (latejoin, roundstart, etc)
	updatespeciescolor(H)
	if(!H.butchering_drops)
		H.butchering_drops = list()
	// Only add feathers if not already present
	if(!locate(/datum/butchering_product/feathers) in H.butchering_drops)
		var/datum/butchering_product/feathers/feather_product = new
		feather_product.amount = 3
		feather_product.initial_amount = 3
		feather_product.feather_hex = H.get_vox_feather_hex()
		feather_product.feather_color_name = H.get_vox_feather_color_name()
		feather_product.product_name = "[feather_product.feather_color_name] vox feathers"
		H.butchering_drops += feather_product
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
		if(VOXPLUCKED)
			icobase = 'icons/mob/human_races/vox/r_voxplucked.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxplucked.dmi'
		else
			icobase = 'icons/mob/human_races/vox/r_vox.dmi'
			deform = 'icons/mob/human_races/vox/r_def_vox.dmi'

	// Adjust cold resistance if plucked
	if(vox.my_appearance && vox.my_appearance.s_tone == VOXPLUCKED)
		vox.species.cold_level_1 = 120
		vox.species.cold_level_2 = 80
		vox.species.cold_level_3 = 30
	else
		vox.species.cold_level_1 = 80
		vox.species.cold_level_2 = 50
		vox.species.cold_level_3 = 0
	if(vox_tail && (vox_tail.status & ORGAN_DESTROYED))
		return
	vox_tail.update_tail(vox)

	// If feathers are regenerating, force plucked appearance regardless of genetics
	if(vox.my_appearance && vox.feather_regen_timer)
		if(vox.my_appearance.s_tone != VOXPLUCKED)
			// Save the new color for when feathers regrow
			vox.original_vox_s_tone = vox.my_appearance.s_tone
			vox.my_appearance.s_tone = VOXPLUCKED
			icobase = 'icons/mob/human_races/vox/r_voxplucked.dmi'
			deform = 'icons/mob/human_races/vox/r_def_voxplucked.dmi'
			if(vox_tail)
				vox_tail.icon_name = "plucked"
			return // Do not update further if plucked

	// Ensure plucked Vox tail uses plucked icon name
	if(vox.my_appearance && vox.my_appearance.s_tone == VOXPLUCKED)
		if(vox_tail)
			vox_tail.icon_name = "plucked"

	if(/datum/dna/gene/disability/lisp in vox.active_genes) //!! Vox Beaks !!
		switch(vox.my_appearance.s_tone)
			if(VOXEMERALD)
				icobase = 'icons/mob/human_races/vox/r_voxemrl_duck.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxemrl_duck.dmi'
			if(VOXAZURE)
				icobase = 'icons/mob/human_races/vox/r_voxazu_duck.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxazu_duck.dmi'
			if(VOXLGREEN)
				icobase = 'icons/mob/human_races/vox/r_voxlgrn_duck.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxlgrn_duck.dmi'
			if(VOXGRAY)
				icobase = 'icons/mob/human_races/vox/r_voxgry_duck.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxgry_duck.dmi'
			if(VOXBROWN)
				icobase = 'icons/mob/human_races/vox/r_voxbrn_duck.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxbrn_duck.dmi'
			if(VOXPLUCKED)
				icobase = 'icons/mob/human_races/vox/r_voxplucked.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxplucked.dmi'
			else
				icobase = 'icons/mob/human_races/vox/r_vox_duck.dmi'
				deform = 'icons/mob/human_races/vox/r_def_vox_duck.dmi'

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

/datum/species/skellington/skelevox/fallback()
	return "Vox"

/mob/living/carbon/human
	var/feather_regen_timer = null
	var/original_vox_s_tone = null
	var/vox_full_regen_active = null

/// Called when Vox has at least one feather left but not full, triggers 5-minute regeneration (no radiation required)
/mob/living/carbon/human/proc/start_partial_feather_regeneration()
	if(!istype(src.species, /datum/species/vox))
		return
	if(src.feather_regen_timer)
		return // Already running
	if(src.stat == DEAD)
		return // Only start if alive
	var/datum/butchering_product/feathers/F = locate(/datum/butchering_product/feathers) in src.butchering_drops
	if(!F || F.amount == F.initial_amount || F.amount <= 0)
		return // Only if missing some feathers but not plucked
	src.feather_regen_timer = 1
	spawn(3)
		if(src)
			to_chat(src, "<span class='notice'>Your feathers begin to regrow. They'll be fully restored in a few minutes.</span>")
	spawn(3000)
		if(src && src.stat != DEAD && F && F.amount > 0 && F.amount < F.initial_amount)
			F.amount = F.initial_amount
			to_chat(src, "<span class='notice'>Your feathers have fully regrown!</span>")
			src.update_icons()
		src.feather_regen_timer = null


/// Called when feathers are depleted and Vox is plucked
/mob/living/carbon/human/proc/start_feather_regeneration()
	if(!istype(src.species, /datum/species/vox))
		return
	// If partial regen is running, cancel it and start full regen
	if(src.feather_regen_timer)
		// If already running full regen, do nothing
		if(src.vox_full_regen_active)
			return
		// Otherwise, cancel partial regen and proceed
		src.feather_regen_timer = null
		src.vox_full_regen_active = null
	if(src.stat == DEAD)
		return // Only start if alive
	src.feather_regen_timer = 1
	src.vox_full_regen_active = 1
	to_chat(src, "<span class='notice'>You feel your feathers start to regrow, this could take a while...</span>")
	spawn(9000)
		if(src && src.stat != DEAD)
			src.restore_feathers()
		src.feather_regen_timer = null
		src.vox_full_regen_active = null

/// Periodically check if Vox has gravy in their system to start feather regeneration
/mob/living/carbon/human/proc/check_vox_feather_regen_ready()
	if(!istype(src.species, /datum/species/vox))
		return
	if(src.stat == DEAD)
		return
	if(!src.my_appearance || src.my_appearance.s_tone != VOXPLUCKED)
		return // Only check if plucked
	// Check for gravy or peanuts in reagents
	if(src.reagents && (src.reagents.has_reagent("gravy") || src.reagents.has_reagent("peanut")))
		// Always trigger full regeneration, even if partial is running
		src.start_feather_regeneration()
		return
	// If already regenerating (partial), do nothing else
	if(src.feather_regen_timer)
		return
	// Otherwise, check again in 20 ticks
	spawn(20)
		if(src && !src.feather_regen_timer && src.my_appearance && src.my_appearance.s_tone == VOXPLUCKED && src.stat != DEAD)
			src.check_vox_feather_regen_ready()

/// Called after a feather is plucked, checks if partial regeneration should start
/mob/living/carbon/human/proc/check_vox_partial_feather_regen()
	if(!istype(src.species, /datum/species/vox))
		return
	if(src.feather_regen_timer)
		return
	var/datum/butchering_product/feathers/F = locate(/datum/butchering_product/feathers) in src.butchering_drops
	if(F && F.amount > 0 && F.amount < F.initial_amount)
		src.start_partial_feather_regeneration()


/// Set Vox to plucked appearance and store original s_tone
/mob/living/carbon/human/proc/set_vox_plucked_appearance()
	if(istype(src.species, /datum/species/vox))
		if(src.my_appearance)
			var/was_plucked = (src.my_appearance.s_tone == VOXPLUCKED)
			// Only set original_vox_s_tone if not already set and not already plucked
			if(isnull(src.original_vox_s_tone) && !was_plucked)
				src.original_vox_s_tone = src.my_appearance.s_tone
			if(isnull(src.my_appearance.hexcode))
				src.my_appearance.hexcode = src.get_vox_feather_hex()
			src.my_appearance.s_tone = VOXPLUCKED
			to_chat(src, "<span class='notice'>The lack of feathers makes everything feel colder.</span>")
			src.species.updatespeciescolor(src)
			src.update_icon()
			src.regenerate_icons()

/// Returns the feather hexcode for this Vox
/mob/living/carbon/human/proc/get_vox_feather_hex()
	if(src.my_appearance && src.my_appearance.s_tone)
		switch(src.my_appearance.s_tone)
			if(VOXEMERALD)
				return "#3de47b"
			if(VOXAZURE)
				return "#3dbbe4"
			if(VOXLGREEN)
				return "#a3e43d"
			if(VOXGREEN)
				return "#4be43d"
			if(VOXGRAY)
				return "#bfc1c2"
			if(VOXBROWN)
				return "#bfa97a"
			if(VOXPLUCKED)
				return "#e4d13d"
			else
				return "#a3e43d"
	return "#e4e4e4"

/// Returns the feather color name for this Vox
/mob/living/carbon/human/proc/get_vox_feather_color_name()
	if(src.my_appearance && src.my_appearance.s_tone)
		switch(src.my_appearance.s_tone)
			if(VOXEMERALD)
				return "emerald"
			if(VOXAZURE)
				return "azure"
			if(VOXLGREEN)
				return "light green"
			if(VOXGREEN)
				return "green"
			if(VOXGRAY)
				return "gray"
			if(VOXBROWN)
				return "brown"
			if(VOXPLUCKED)
				return "plucked"
			else
				return "white"
		return "white"


/// Restores feathers and original appearance
/mob/living/carbon/human/proc/restore_feathers()
	if(!istype(src.species, /datum/species/vox))
		return
	if(src.stat && src.stat == DEAD)
		return // Only restore if alive
	// Restore feather butchering product
	for(var/datum/butchering_product/feathers/F in src.butchering_drops)
		F.amount = F.initial_amount
	// Always restore appearance if original_vox_s_tone is set
	if(src.my_appearance)
		if(!isnull(src.original_vox_s_tone))
			src.my_appearance.s_tone = src.original_vox_s_tone
			src.original_vox_s_tone = null
			to_chat(src, "<span class='notice'>You feel insulated again.</span>")
		else if(src.my_appearance.s_tone == VOXPLUCKED)
			src.my_appearance.s_tone = VOXBROWN // fallback if plucked and no stored color
		// Set feather_regen_timer to null BEFORE updating species color, so updatespeciescolor doesn't force plucked
		src.feather_regen_timer = null
		src.species.updatespeciescolor(src)
		src.update_icon()
		src.regenerate_icons()
	else
		src.feather_regen_timer = null


/// Called when the mob is revived from death
/mob/living/carbon/human/revive()
	..()
	if(istype(src.species, /datum/species/vox))
		if(src.my_appearance && src.my_appearance.s_tone == VOXPLUCKED)
			if(!src.feather_regen_timer)
				src.start_feather_regeneration()

// Vox self-preening (self-plucking) when clicking self with grab intent
/mob/living/carbon/human/vox/attack_hand(mob/living/carbon/human/M)
	if(M != src || !istype(src.species, /datum/species/vox))
		return ..(M)
	if(src.a_intent != I_GRAB)
		return
	var/datum/butchering_product/feathers/F = locate(/datum/butchering_product/feathers) in src.butchering_drops
	if(istype(F))
		if(F.amount > 0)
			to_chat(src, "<span class='notice'>You begin to preen yourself, plucking out a feather...</span>")
			var/success = do_after(src, src, 30, 10, TRUE, FALSE)
			if(!success)
				to_chat(src, "<span class='warning'>You stop preening yourself.</span>")
				return
			F.spawn_result(get_turf(src), src, 1)
			to_chat(src, "<span class='notice'>You preen yourself, plucking out a feather!</span>")
			src.check_vox_partial_feather_regen()
			if(F.amount == 0 && !src.feather_regen_timer && src.my_appearance && src.my_appearance.s_tone != VOXPLUCKED)
				src.set_vox_plucked_appearance()
				if(src.radiation >= 30)
					src.start_feather_regeneration()
				else
					src.check_vox_feather_regen_ready()
			return
		else
			to_chat(src, "<span class='warning'>You have no feathers left to pluck!</span>")
			return
	return
