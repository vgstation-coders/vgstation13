/datum/species/phoronman // /vg/
	name = "Phoronman"
	icobase = 'icons/mob/human_races/r_phoronman_sb.dmi'
	deform = 'icons/mob/human_races/r_phoronman_pb.dmi'  // TODO: Need deform.
	known_languages = list(LANGUAGE_CLATTER)
	attack_verb = "punches"

	flags = IS_WHITELISTED | PHORON_IMMUNE
	anatomy_flags = NO_BLOOD

	//default_mutations=list(SKELETON) // This screws things up
	primitive = /mob/living/carbon/monkey/skellington/phoron

	breath_type = "toxins"

	heat_level_1 = 350  // Heat damage level 1 above this point.
	heat_level_2 = 400  // Heat damage level 2 above this point.
	heat_level_3 = 500  // Heat damage level 3 above this point.
	burn_mod = 0.5
	brute_mod = 1.5

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs/phoronman,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes
	)

/datum/species/phoronman/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	speech.message = replacetext(speech.message, "s", "s-s") //not using stutter("s") because it likes adding more s's.
	speech.message = replacetext(speech.message, "s-ss-s", "ss-ss") //asshole shows up as ass-sshole

/datum/species/phoronman/equip(var/mob/living/carbon/human/H)
	H.fire_sprite = "Phoronman"

	// Unequip existing suits and hats.
	H.u_equip(H.wear_suit,1)
	H.u_equip(H.head,1)
	if(H.mind.assigned_role!="Clown")
		H.u_equip(H.wear_mask,1)

	H.equip_or_collect(new /obj/item/clothing/mask/breath(H), slot_wear_mask)
	var/suit=/obj/item/clothing/suit/space/phoronman
	var/helm=/obj/item/clothing/head/helmet/space/phoronman
	var/tank_slot = slot_s_store
	var/tank_slot_name = "suit storage"

	switch(H.mind.assigned_role)
		if("Scientist","Geneticist","Roboticist")
			suit=/obj/item/clothing/suit/space/phoronman/science
			helm=/obj/item/clothing/head/helmet/space/phoronman/science
		if("Research Director")
			suit=/obj/item/clothing/suit/space/phoronman/science/rd
			helm=/obj/item/clothing/head/helmet/space/phoronman/science/rd
		if("Station Engineer", "Mechanic")
			suit=/obj/item/clothing/suit/space/phoronman/engineer/
			helm=/obj/item/clothing/head/helmet/space/phoronman/engineer/
		if("Chief Engineer")
			suit=/obj/item/clothing/suit/space/phoronman/engineer/ce
			helm=/obj/item/clothing/head/helmet/space/phoronman/engineer/ce
		if("Atmospheric Technician")
			suit=/obj/item/clothing/suit/space/phoronman/atmostech
			helm=/obj/item/clothing/head/helmet/space/phoronman/atmostech
		if("Warden","Detective","Security Officer")
			suit=/obj/item/clothing/suit/space/phoronman/security/
			helm=/obj/item/clothing/head/helmet/space/phoronman/security/
		if("Head of Security")
			suit=/obj/item/clothing/suit/space/phoronman/security/hos
			helm=/obj/item/clothing/head/helmet/space/phoronman/security/hos
		if("Captain")
			suit=/obj/item/clothing/suit/space/phoronman/security/captain
			helm=/obj/item/clothing/head/helmet/space/phoronman/security/captain
		if("Head of Personnel")
			suit=/obj/item/clothing/suit/space/phoronman/security/hop
			helm=/obj/item/clothing/head/helmet/space/phoronman/security/hop
		if("Medical Doctor")
			suit=/obj/item/clothing/suit/space/phoronman/medical
			helm=/obj/item/clothing/head/helmet/space/phoronman/medical
		if("Paramedic")
			suit=/obj/item/clothing/suit/space/phoronman/medical/paramedic
			helm=/obj/item/clothing/head/helmet/space/phoronman/medical/paramedic
		if("Chemist")
			suit=/obj/item/clothing/suit/space/phoronman/medical/chemist
			helm=/obj/item/clothing/head/helmet/space/phoronman/medical/chemist
		if("Chief Medical Officer")
			suit=/obj/item/clothing/suit/space/phoronman/medical/cmo
			helm=/obj/item/clothing/head/helmet/space/phoronman/medical/cmo
		if("Bartender", "Chef")
			suit=/obj/item/clothing/suit/space/phoronman/service
			helm=/obj/item/clothing/head/helmet/space/phoronman/service
		if("Cargo Technician", "Quartermaster")
			suit=/obj/item/clothing/suit/space/phoronman/cargo
			helm=/obj/item/clothing/head/helmet/space/phoronman/cargo
		if("Shaft Miner")
			suit=/obj/item/clothing/suit/space/phoronman/miner
			helm=/obj/item/clothing/head/helmet/space/phoronman/miner
		if("Botanist")
			suit=/obj/item/clothing/suit/space/phoronman/botanist
			helm=/obj/item/clothing/head/helmet/space/phoronman/botanist
		if("Chaplain")
			suit=/obj/item/clothing/suit/space/phoronman/chaplain
			helm=/obj/item/clothing/head/helmet/space/phoronman/chaplain
		if("Janitor")
			suit=/obj/item/clothing/suit/space/phoronman/janitor
			helm=/obj/item/clothing/head/helmet/space/phoronman/janitor
		if("Assistant")
			suit=/obj/item/clothing/suit/space/phoronman/assistant
			helm=/obj/item/clothing/head/helmet/space/phoronman/assistant
		if("Clown")
			suit=/obj/item/clothing/suit/space/phoronman/clown
			helm=/obj/item/clothing/head/helmet/space/phoronman/clown
		if("Mime")
			suit=/obj/item/clothing/suit/space/phoronman/mime
			helm=/obj/item/clothing/head/helmet/space/phoronman/mime
		if("Internal Affairs Agent")
			suit=/obj/item/clothing/suit/space/phoronman/lawyer
			helm=/obj/item/clothing/head/helmet/space/phoronman/lawyer
	H.equip_or_collect(new suit(H), slot_wear_suit)
	H.equip_or_collect(new helm(H), slot_head)
	H.equip_or_collect(new/obj/item/weapon/tank/phoron/phoronman(H), tank_slot) // Bigger phoron tank from Raggy.
	to_chat(H, "<span class='notice'>You are now running on phoron internals from the [H.s_store] in your [tank_slot_name].  You must breathe phoron in order to survive, and are extremely flammable.</span>")
	H.internal = H.get_item_by_slot(tank_slot)
	if (H.internals)
		H.internals.icon_state = "internal1"

/datum/species/phoronman/can_artifact_revive()
	return 0