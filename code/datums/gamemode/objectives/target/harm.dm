/datum/objective/target/harm
	name = "Cripple <target>"

// Harm a crew member, making an example of them
/datum/objective/target/harm
	var/already_completed = FALSE

/datum/objective/target/harm/format_explanation()
	return "Make an example of [target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."


/datum/objective/target/harm/IsFulfilled()
	if (..())
		return TRUE
	if(already_completed)
		return TRUE

	if(target && target.current && istype(target.current, /mob/living/carbon/human))
		if(target.current.isDead())
			return FALSE

		var/mob/living/carbon/human/H = target.current
		for(var/datum/organ/external/E in H.organs)
			if(!E.is_healthy())
				already_completed = 1
				return TRUE

		var/datum/organ/external/head/head = H.get_organ(LIMB_HEAD)
		if(head.disfigured)
			return TRUE
	return FALSE
