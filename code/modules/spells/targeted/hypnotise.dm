/spell/targeted/hypnotise
	name = "Hypnotise (10)"
	desc = "A piercing stare that incapacitates your victim for a good length of time."
	abbreviation = "HN"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN
	cooldown_min = 3 MINUTES
	selection_type = "range"

	amt_paralysis = 20
	amt_stuttering = 50

	override_base = "vamp"
	hud_state = "vampire_hypno"

	var/blood_cost = 10

/spell/targeted/hypnotise/cast_check(skipcharge = 0, mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (istype(user.get_item_by_slot(slot_glasses), /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, "<span class='warning'>You're blindfolded!</span>")
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/targeted/hypnotise/is_valid_target(var/target, var/mob/user, var/list/options)
	if (!ismob(target))
		return FALSE

	var/mob/M = target

	if (!M.vampire_affected(user.mind))
		return FALSE
	return ..()

/spell/targeted/hypnotise/cast(var/list/targets, var/mob/user)
	if (targets.len > 1)
		return FALSE

	var/target = targets[1]

	if(ishuman(target) || ismonkey(target))
		var/mob/living/carbon/C = target
		if(do_mob(user, C, 10 - C.get_vamp_enhancements()))
			to_chat(user, "<span class='warning'>Your piercing gaze knocks out \the [C].</span>")
			to_chat(C, "<span class='sinister'>You find yourself unable to move and barely able to speak.</span>")
			apply_spell_damage(target)
		else
			to_chat(user, "<span class='warning'>You broke your gaze.</span>")
			return FALSE
	var/datum/role/vampire/V = isvampire(user)
	if (!V)
		return FALSE
	V.remove_blood(blood_cost)