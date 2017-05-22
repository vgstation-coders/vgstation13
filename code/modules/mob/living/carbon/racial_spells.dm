//For spells designed to be inherent abilities given to mobs via their species datum

/spell/swallow_light	//Grue
	name = "Swallow Light"
	abbreviation = "SL"
	desc = "Create a void of darkness around yourself."
	panel = "Racial Abilities"
	override_base = "racial"
	hud_state = "racial_dark"
	spell_flags = INCLUDEUSER
	charge_type = Sp_GRADUAL
	charge_max = 600
	minimum_charge = 100
	range = SELFCAST
	cast_sound = 'sound/misc/grue_growl.ogg'
	still_recharging_msg = "<span class='notice'>You're still regaining your strength.</span>"

/spell/swallow_light/cast(list/targets, mob/user)
	user.set_light(8,-20)
	playsound(user, cast_sound, 50, 1)
	playsound(user, 'sound/misc/grue_ambience.ogg', 50, channel = CHANNEL_GRUE)

/spell/swallow_light/stop_casting(list/targets, mob/user)
	user.set_light(0)
	playsound(user, null, 50, channel = CHANNEL_GRUE)

/spell/swallow_light/choose_targets(mob/user = usr)
	var/list/targets = list()
	targets += user
	return targets

/spell/swallow_light/is_valid_target(var/target, mob/user, options)
	return(target == user)

/spell/shatter_lights	//Grue
	name = "Shatter Lights"
	abbreviation = "ST"
	desc = "Shatter all nearby lights with a shriek."
	panel = "Racial Abilities"
	override_base = "racial"
	hud_state = "blackout"
	charge_max = 1200
	spell_flags = null
	range = SELFCAST
	cast_sound = 'sound/misc/grue_screech.ogg'
	still_recharging_msg = "<span class='notice'>You're still regaining your strength.</span>"

/spell/shatter_lights/cast(list/targets, mob/user)
	playsound(user, cast_sound, 100)
	for(var/obj/machinery/light/L in range(7))
		L.broken()

/spell/shatter_lights/choose_targets(mob/user = usr)
	var/list/targets = list()
	targets += user
	return targets

/spell/shatter_lights/is_valid_target(var/target, mob/user, options)
	return(target == user)

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

/spell/regen_limbs/is_valid_target(var/target, mob/user, options)
	return(target == user)