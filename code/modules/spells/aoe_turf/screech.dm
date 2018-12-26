/spell/aoe_turf/screech
	name = "Screech (30)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	abbreviation = "CK"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 5 MINUTES
	invocation_type = SpI_NONE
	range = 4
	spell_flags = STATALLOWED | NEEDSHUMAN
	cooldown_min = 5 MINUTES

	override_base = "vamp"
	hud_state = "vampire_screech"

	var/blood_cost = 30

/spell/aoe_turf/screech/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, 0, FALSE))
		return FALSE

/spell/aoe_turf/screech/choose_targets(var/mob/user = usr)
	
	var/list/targets = list()

	for(var/mob/living/carbon/C in hearers(user, 4))
		if(C == user)
			continue
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.earprot())
				continue
			if(!C.vampire_affected(user.mind))
				continue
			targets += C
	
	if (!targets.len)
		to_chat(user, "<span class='warning'>There are no targets.</span>")
		return FALSE

	return targets

/spell/aoe_turf/screech/cast(var/list/targets, var/mob/user)
	for (var/T in targets)
		var/mob/living/carbon/C = T
		if(C.is_deaf())
			continue
		to_chat(C, "<span class='danger'><font size='3'>You hear a ear piercing shriek and your senses dull!</font></span>")
		C.Knockdown(8)
		C.ear_deaf = 20
		C.stuttering = 20
		C.Stun(8)
		C.Jitter(150)
	for(var/obj/structure/window/W in view(4))
		W.Destroy(brokenup = 1)

	playsound(user, 'sound/effects/creepyshriek.ogg', 100, 1)

	var/datum/role/vampire/V = isvampire(user)
	if (V)
		return FALSE