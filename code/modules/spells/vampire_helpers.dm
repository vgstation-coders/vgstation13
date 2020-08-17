// -- Helpers for vampires spells.

// --- TO BE CLEANED UP AND MOVED TO ROLE PROCS ! ---

/mob/proc/vampire_power(var/required_blood = 0, var/max_stat = 0)

	var/datum/role/vampire/vampire = isvampire(src)

	if(!vampire)
		world.log << "[src] has vampire spells but isn't a vampire."
		return 0

	var/fullpower = (VAMP_JAUNT in vampire.powers)

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
	if(istype(get_area(src), /area/chapel))
		to_chat(src, "<span class='warning'>Your powers are useless on this holy ground.</span>")
		return 0
	if(check_holy(src))
		var/turf/T = get_turf(src)
		if((T.get_lumcount() * 10) > 2)
			to_chat(src, "<span class='warning'>This ground has been blessed and illuminated, suppressing your abilities.</span>")
			return 0
		if (fullpower)
			to_chat(src, "<span class='warning'>Our awakened powers are suppressed on this holy ground.</span>")
			return 0
	return 1

/mob/proc/can_enthrall(var/mob/living/carbon/human/H)
	var/implanted = 0
	var/datum/role/vampire/V = isvampire(src)
	if(restrained())
		to_chat(src, "<span class ='warning'> You cannot do this while restrained! </span>")
		return 0
	if(!(VAMP_CHARISMA in V.powers)) //Charisma allows implanted targets to be enthralled.
		for(var/obj/item/weapon/implant/loyalty/L in H)
			if(L && L.implanted)
				implanted = TRUE
				break
		/* Greytide implantes - to fix
		for(var/obj/item/weapon/implant/traitor/T in H)
			if(T && T.implanted)
				enthrall_safe = TRUE
				break
		*/

	if(!istype(H))
		to_chat(src, "<span class='warning'>You can only enthrall humanoids!</span>")
		return 0
	if(!H)
		message_admins("Error during enthralling: no target. Mob is [src], (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]&mob=\ref[src]'>JMP</A>)")
		return FALSE
	if(!H.mind)
		to_chat(src, "<span class='warning'>[H]'s mind is not there for you to enthrall.</span>")
		return FALSE
	if(isvampire(H) || isthrall(H))
		H.visible_message("<span class='warning'>[H] seems to resist the takeover!</span>", "<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>")
		return FALSE
	if (implanted)
		H.visible_message("<span class='warning'>[H] seems to resist the takeover!</span>", "<span class='notice'>You feel a strange sensation in your skull that quickly dissipates.</span>")
		return FALSE
	if(H.vampire_affected(mind) < 0)
		H.visible_message("<span class='warning'>[H] seems to resist the takeover!</span>", "<span class='notice'>Your faith of [ticker.Bible_deity_name] has kept your mind clear of all evil!</span>")
	return TRUE

/mob/proc/vampire_affected(var/datum/mind/M) // M is the attacker, src is the target.
	//Other vampires aren't affected
	if(mind && mind.GetRole(VAMPIRE))
		return 0

	// Non-mature vampires are not stopped by holy things.
	if(M)
		//Chaplains are ALWAYS resistant to vampire powers
		if(mind && mind.assigned_role == "Chaplain")
			to_chat(M.current, "<span class='warning'>[src] resists our powers!</span>")
			return 0
		// Null rod nullifies vampire powers, unless we're a young vamp.
		var/datum/role/vampire/V = M.GetRole(VAMPIRE)
		var/obj/item/weapon/nullrod/N = locate(/obj/item/weapon/nullrod) in get_contents_in_object(src)
		if (N)
			if (VAMP_UNDYING in V.powers)
				to_chat(M.current, "<span class='warning'>An holy artifact has turned our powers against us!</span>")
				return VAMP_FAILURE
			if (VAMP_JAUNT in V.powers)
				to_chat(M.current, "<span class='warning'>An holy artifact protects [src]!</span>")
				return 0
		return 1

// If the target is weakened, the spells take less time to complete.
/mob/living/carbon/proc/get_vamp_enhancements()
	return ((knockdown ? 2 : 0) + (stunned ? 1 : 0) + (sleeping || paralysis ? 3 : 0))
