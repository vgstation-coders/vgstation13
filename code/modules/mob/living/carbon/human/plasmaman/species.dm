/datum/species/plasmaman // /vg/
	name = "Plasmaman"
	icobase = 'icons/mob/human_races/r_plasmaman_sb.dmi'
	deform = 'icons/mob/human_races/r_plasmaman_pb.dmi'  // TODO: Need deform.
	known_languages = list(LANGUAGE_CLATTER)
	attack_verb = "punches"

	flags = IS_WHITELISTED | PLASMA_IMMUNE
	anatomy_flags = NO_BLOOD
	blood_color = "#743474"
	flesh_color = "#898476"

	//default_mutations=list(M_SKELETON) // This screws things up
	primitive = /mob/living/carbon/monkey/skellington/plasma

	breath_type = GAS_PLASMA

	heat_level_1 = 350  // Heat damage level 1 above this point.
	heat_level_2 = 400  // Heat damage level 2 above this point.
	heat_level_3 = 500  // Heat damage level 3 above this point.
	burn_mod = 0.5
	brute_mod = 1.5

	head_icons      = 'icons/mob/species/plasmaman/head.dmi'
	wear_suit_icons = 'icons/mob/species/plasmaman/suit.dmi'

	has_organ = list(
		"heart" =    /datum/organ/internal/heart,
		"lungs" =    /datum/organ/internal/lungs/plasmaman,
		"liver" =    /datum/organ/internal/liver,
		"kidneys" =  /datum/organ/internal/kidney,
		"brain" =    /datum/organ/internal/brain,
		"appendix" = /datum/organ/internal/appendix,
		"eyes" =     /datum/organ/internal/eyes
	)
	monkey_anim = "p2monkey"

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/plasmaman

	survival_gear = /obj/item/weapon/storage/box/survival/plasmaman

/datum/species/plasmaman/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	speech.message = replacetext(speech.message, "s", "s-s") //not using stutter("s") because it likes adding more s's.
	speech.message = replacetext(speech.message, "s-ss-s", "ss-ss") //asshole shows up as ass-sshole
	..()

// -- Outfit datums --
/datum/species/plasmaman/final_equip(var/mob/living/carbon/human/H)
	H.fire_sprite = "Plasmaman"
	var/tank_slot = slot_s_store
	var/tank_slot_name = "suit storage"
	H.equip_or_collect(new/obj/item/weapon/tank/plasma/plasmaman(H), tank_slot) // Bigger plasma tank from Raggy.
	to_chat(H, "<span class='notice'>You are now running on plasma internals from the [H.s_store] in your [tank_slot_name].  You must breathe plasma in order to survive, and are extremely flammable.</span>")
	H.internal = H.get_item_by_slot(tank_slot)
	if (H.internals)
		H.internals.icon_state = "internal1"

/datum/species/plasmaman/can_artifact_revive()
	return 0

/datum/species/plasmaman/handle_environment(var/datum/gas_mixture/environment, var/mob/living/carbon/human/host)
	//For now we just assume suit and head are capable of containing the plasmaman
	var/flags_found = FALSE
	if(host.wear_suit && (host.wear_suit.clothing_flags & CONTAINPLASMAMAN) && host.head && (host.head.clothing_flags & CONTAINPLASMAMAN))
		flags_found = TRUE

	if(!flags_found)
		if(environment)
			if(environment.total_moles && ((environment[GAS_OXYGEN] / environment.total_moles) >= OXYCONCEN_PLASMEN_IGNITION)) //How's the concentration doing?
				if(!host.on_fire)
					to_chat(host, "<span class='warning'>Your body reacts with the atmosphere and bursts into flame!</span>")
				host.adjust_fire_stacks(0.5)
				host.IgniteMob()
	else
		var/obj/item/clothing/suit/space/plasmaman/PS=host.wear_suit
		if(istype(PS))
			if(host.fire_stacks > 0)
				PS.Extinguish(host)
			else
				PS.regulate_temp_of_wearer(host)

/datum/species/plasmaman/gib(mob/living/carbon/human/H)
	..()
	var/datum/organ/external/head_organ = H.get_organ(LIMB_HEAD)
	if(head_organ.status & ORGAN_DESTROYED)
		new /obj/effect/decal/remains/human/noskull(H.loc)
	else
		new /obj/effect/decal/remains/human(H.loc)
		head_organ.droplimb(1,1)

	H.drop_all()
	qdel(H)
