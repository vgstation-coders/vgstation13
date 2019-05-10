// Inherited

// Except for this, of course.
/mob/living/silicon/robot/mommi/laws_sanity_check()
	if (!laws)
		laws = new mommi_laws["Default"]

// Disable this.
/mob/living/silicon/robot/mommi/lawsync()
	laws_sanity_check()
	return