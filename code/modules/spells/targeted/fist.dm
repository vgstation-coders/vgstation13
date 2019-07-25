/spell/targeted/fist
	name = "Fist"
	desc = "This spell punches up to three beings in view."
	abbreviation = "FS"
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	charge_max = 50
	spell_flags = 0 //So that it doesn't open a dialog box.
	cooldown_min = 10
	invocation = "I CAST FIST"
	invocation_type = SpI_SHOUT
	max_targets = 3
	spell_flags = NEEDSCLOTHES|LOSE_IN_TRANSFER

	compatible_mobs = list(/mob/living)

	hud_state = "wiz_fist"

/spell/targeted/fist/cast(var/list/targets)
	var/mob/living/L = holder
	if(istype(L) && L.has_hand_check()) //Can't punch if you have no haaands
		for(var/mob/living/target in targets)
			if (L.is_pacified(1,target))
				return
			L.unarmed_attack_mob(target)
