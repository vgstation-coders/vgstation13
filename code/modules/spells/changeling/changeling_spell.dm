/spell/changeling
	name = "Changeling Spell"
	desc = "A template changeling spell."
	abbreviation = "CG"
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"

	school = "changeling"
	user_type = USER_TYPE_CHANGELING

	charge_type = Sp_RECHARGE
	charge_max = 1 SECONDS
	invocation_type = SpI_NONE
	range = 0

	cooldown_min = 1 SECONDS

	override_base = "changeling"
	hud_state = "wiz_disint"

	spell_flags = 0
	var/inuse = FALSE
	var/chemcost = 0
	var/max_genedamage = 100
	var/horrorallowed = 1
	var/required_dna = 0

/spell/changeling/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.)
		return FALSE
	var/datum/role/changeling/C = user.mind.GetRole(CHANGELING)
	if (!C)     //only changelings allowed
		message_admins("[user.real_name] has a changeling spell... and they aren't a changeling!")
		return FALSE
	if (issilicon(user))
		to_chat(C.antag.current, "<span class='warning'>You must be an organic lifeform.</span>")
		return FALSE
	if (C.chem_charges < chemcost)
		to_chat(C.antag.current, "<span class='warning'>We do not have enough chemicals stored! We require at least [chemcost] units of chemicals.</span>")
		return FALSE
	if(C.geneticdamage > max_genedamage)
		to_chat(C.antag.current, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return FALSE
	if(C.absorbedcount < required_dna)
		to_chat(C.antag.current, "<span class='warning'>We require at least [required_dna] sample of compatible DNA.</span>")
		return FALSE
		
	if(!horrorallowed && ishorrorform(C.antag.current))
		to_chat(C.antag.current, "<span class='warning'>You are not permitted to taint our purity. You cannot do this as a Horror.</span>")
		return FALSE

/spell/changeling/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/C = user.mind.GetRole(CHANGELING)
	C.chem_charges -= chemcost

/spell/changeling/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast