
//For spells designed to be inherent abilities given to mobs via their species datum

/spell/targeted/genetic/invert_eyes
	name = "Invert eyesight"
	desc = "Inverts the colour spectrum you see, letting you see clearly in the dark, but not in the light."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = SELFCAST

	charge_type = Sp_RECHARGE

	spell_flags = INCLUDEUSER

	invocation_type = SpI_NONE

	override_base = "genetic"
	hud_state = "wiz_sleepold"

/spell/targeted/genetic/invert_eyes/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/M in targets)
		var/datum/organ/internal/eyes/mushroom/E = M.internal_organs_by_name["eyes"]
		if(istype(E))
			E.dark_mode = !E.dark_mode

/spell/regen_limbs	//Slime people
	name = "Regenerate Limbs"
	abbreviation = "RL"
	desc = "Sprout new limbs to replace lost ones."
	panel = "Racial Abilities"
	override_base = "racial"
	hud_state = "racial_regen_limbs"
	spell_flags = INCLUDEUSER
	charge_type = Sp_RECHARGE
	charge_max = 100
	range = SELFCAST
	cast_sound = 'sound/effects/squelch1.ogg'
	still_recharging_msg = "<span class='notice'>You're still regaining your strength.</span>"

/spell/regen_limbs/cast(list/targets, mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/list/priority_organs = list()
		if(H.get_organ(LIMB_GROIN))
			priority_organs.Add(H.get_organ(LIMB_GROIN))
		if(H.get_organ(LIMB_RIGHT_LEG))
			priority_organs.Add(H.get_organ(LIMB_RIGHT_LEG))
		if(H.get_organ(LIMB_LEFT_LEG))
			priority_organs.Add(H.get_organ(LIMB_LEFT_LEG))
		if(H.get_organ(LIMB_RIGHT_FOOT))
			priority_organs.Add(H.get_organ(LIMB_RIGHT_FOOT))
		if(H.get_organ(LIMB_LEFT_FOOT))
			priority_organs.Add(H.get_organ(LIMB_LEFT_FOOT))
		for(var/organ_name in H.organs_by_name)
			if(!(H.organs_by_name[organ_name] in priority_organs))
				priority_organs.Add(H.organs_by_name[organ_name])

		var/has_regenerated = FALSE
		for(var/datum/organ/external/O in priority_organs)
			if(O.status & ORGAN_DESTROYED)
				if(O.name == LIMB_LEFT_FOOT || O.name == LIMB_RIGHT_FOOT || O.name == LIMB_LEFT_HAND || O.name == LIMB_RIGHT_HAND)
					if(!(O.parent.status & ORGAN_DESTROYED))
						if(H.nutrition >= 50)
							H.nutrition -= 50
							O.rejuvenate_limb()
							has_regenerated = TRUE
							user.visible_message("<span class='warning'>\The [user] sprouts a new [O.display_name]!</span>",\
 								"<span class='notice'>You sprout a new [O.display_name]!</span>")
				else if(H.nutrition >= 100)
					H.nutrition -= 100
					O.rejuvenate_limb()
					has_regenerated = TRUE
					user.visible_message("<span class='warning'>\The [user] sprouts a new [O.display_name]!</span>",\
						"<span class='notice'>You sprout a new [O.display_name]!</span>")

		H.resting = 0
		H.regenerate_icons()
		H.update_canmove()
		if(!has_regenerated)
			to_chat(user, "<span class='warning'>You don't have enough energy to regenerate!</span>")

/spell/regen_limbs/choose_targets(mob/user = usr)
	var/list/targets = list()
	targets += user
	return targets

/spell/regen_limbs/is_valid_target(atom/target, mob/user, options, bypass_range = 0)
	return(target == user)

/spell/targeted/transfer_reagents
	name = "Fertilize"
	desc = "Taps into your internal nutrient storage to fertilize a plant."
	abbreviation = "TR"

	spell_flags = WAIT_FOR_CLICK
	range = 1
	max_targets = 1

	override_base = "racial"
	hud_state = "transfer_reagents"

	charge_max = 20

	invocation_type = SpI_NONE

/spell/targeted/transfer_reagents/is_valid_target(atom/target, mob/user, options, bypass_range = 0)
	if(!istype(target, /obj/machinery/portable_atmospherics/hydroponics))
		to_chat(holder, "<span class='warning'>That's neither soil nor an hydroponic tray!</span>")
		return FALSE
	return TRUE

/spell/targeted/transfer_reagents/cast(var/list/targets, mob/user)
	..()
	if(!holder.reagents)
		to_chat(holder, "<span class='warning'>Uhh that's not gonna work. You don't seem to have reagents!</span>")
		CRASH("[holder] tried to cast [name] but has no reagents!")

	if(holder.reagents.total_volume <= 5)
		to_chat(holder, "<span class='warning'>You don't have enough reagents in your system!</span>")
		return 1

	for(var/obj/machinery/portable_atmospherics/hydroponics/target in targets)
		to_chat(holder, "You secrete some nutritional sap from your fingertips and let it fall into \the [target].")
		holder.reagents.trans_to(target, 5, log_transfer = TRUE, whodunnit = holder)
