/spell/targeted/fist
	name = "Fist"
	desc = "This spell punches up to three beings in view."
	abbreviation = "FS"
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	level_max = list(SP_TOTAL = 3, SP_SPEED = 3)
	charge_cooldown_max = 5 SECONDS
	cooldown_min = 1 SECONDS
	invocation = "I CAST FIST"
	invocation_type = SP_INV_SHOUT
	max_targets = 3
	spell_flags = NEEDSCLOTHES | LOSE_IN_TRANSFER | IS_HARMFUL

	valid_targets = list(/mob/living)

	hud_state = "wiz_fist"

/spell/targeted/fist/is_valid_target(atom/target, mob/user, options, bypass_range)
	if(target in user.get_arcane_golems())
		return FALSE
	if((target in doppelgangers) && doppelgangers[target] == user)
		return FALSE
	return ..()	

/spell/targeted/fist/cast(var/list/targets)
	var/mob/living/L = holder
	if(istype(L) && L.has_hand_check()) //Can't punch if you have no haaands
		for(var/mob/living/target in targets)
			if (L.is_pacified(1,target))
				return
			L.unarmed_attack_mob(target)
