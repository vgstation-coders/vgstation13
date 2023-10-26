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

/spell/aoe_turf/screech/cast(var/list/targets, var/mob/user)
	var/critical_fail = FALSE
	var/list/mob_targets = hearers(user, 4)
	var/list/immune_targets = list() //Helps keep things tidy by telling the vampire everyone who is divinely-shielded
	for(var/mob/living/carbon/affected in mob_targets) //First we see the status of each target
		var/success = affected.vampire_affected(user.mind, FALSE) //Don't send any messages
		switch (success)
			if (FALSE)
				immune_targets += affected
			if (VAMP_FAILURE)
				affected.vampire_affected(user.mind)
				critical_fail = TRUE
				break
	if(critical_fail) //Cancel the spell because a null rod caused a backlash against the vampire
		critfail(targets, user)
		return
	playsound(user, 'sound/effects/creepyshriek.ogg', 100, 1)
	for (var/mob/living/carbon/C in mob_targets)
		if(C.is_deaf() || C.earprot())
			continue
		if(C in immune_targets)
			C.vampire_affected(user.mind)
			continue
		to_chat(C, "<span class='danger'><font size='3'>You hear an ear piercing shriek and your senses dull!</font></span>")
		C.Knockdown(8)
		C.ear_deaf = 20
		C.stuttering = 20
		C.Stun(8)
		C.Jitter(20)
	for(var/obj/structure/window/W in view(4))
		W.shatter()
	for(var/obj/machinery/light/L in view(7))
		L.broken()

	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)

/spell/aoe_turf/screech/critfail(var/list/targets, var/mob/user)
	user.visible_message("<span class='danger'>\The [user] emits a pathetic shriek and then falls over.</span>", "<span class='danger'>It's like a thousand needles pierce your skull.</span>")
	user.ear_deaf = 20
	user.stuttering = 30
	user.Stun(5)
	user.Jitter(150)
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(3*blood_cost)
