// -- Helpers for vampires spells.


/mob/proc/vampire_power(var/required_blood = 0, var/max_stat = 0)

	var/datum/role/vampire/vampire = isvampire(src)

	if(!vampire)
		world.log << "[src] has vampire spells but isn't a vampire."
		return 0

	var/fullpower = (VAMP_MATURE in vampire.powers)

	if(src.stat > max_stat)
		to_chat(src, "<span class='warning'>You are incapacitated.</span>")
		return 0

	if(vampire.nullified)
		if(!fullpower)
			to_chat(src, "<span class='warning'>Something is blocking your powers!</span>")
			return 0
	if(vampire.blood_usable < required_blood)
		to_chat(src, "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>")
		return 0
	//chapel check
	if(istype(areaMaster, /area/chapel))
		if(!fullpower)
			to_chat(src, "<span class='warning'>Your powers are useless on this holy ground.</span>")
			return 0
	if(check_holy(src) && !fullpower)
		var/turf/T = get_turf(src)
		if((T.get_lumcount() * 10) > 2)
			to_chat(src, "<span class='warning'>This ground has been blessed and illuminated, suppressing your abilities.</span>")
			return 0
	return 1

/mob/proc/vampire_affected(var/datum/mind/M) // M is the attacker, src is the target.
	//Other vampires aren't affected
	if(mind && mind.GetRole(VAMPIRE))
		return 0

	//Vampires who have reached their full potential can affect nearly everything
	if(M)
		var/datum/role/vampire/vamp = M.GetRole(VAMPIRE)
		if (vamp && (VAMP_MATURE in vamp.powers))
			return 1
		//Chaplains are resistant to vampire powers
		if(mind && mind.assigned_role == "Chaplain")
			to_chat(M.current, "<span class='warning'>[src] resists our powers!</span>")
			return 0
		return 1

// If the target is weakened, the spells take less time to complete.
/mob/living/carbon/proc/get_vamp_enhancements()
	return ((knockdown ? 2 : 0) + (stunned ? 1 : 0) + (sleeping || paralysis ? 3 : 0))
