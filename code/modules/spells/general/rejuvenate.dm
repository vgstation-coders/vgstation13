/spell/rejuvenate
	name = "Rejuvenate"
	desc = "Flush your system with spare blood to remove any incapacitating effects."
	abbreviation = "RJ"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 0
	spell_flags = STATALLOWED | NEEDSHUMAN
	cooldown_min = 3 MINUTES

	override_base = "vamp"
	hud_state = "vampire_rejuv"

	var/blood_cost = 0

/spell/rejuvenate/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, UNCONSCIOUS))
		return FALSE

/spell/rejuvenate/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/rejuvenate/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/role/vampire/V = isvampire(user) // Shouldn't ever be null, as cast_check checks if we're a vamp.
	var/empowered = (V.blood_total >= 200)
	H.SetKnockdown(0)
	H.SetStunned(0)
	H.SetParalysis(0)
	H.reagents.clear_reagents()
	if(empowered)
		to_chat(H, "<span class='notice'>You flush your system with clean blood, removing any incapacitating effects and mildly healing you.</span>")
	else
		to_chat(H, "<span class='notice'>You flush your system with clean blood and remove any incapacitating effects.</span>")
	spawn() // sleep() causes issues with cooldown.
		if(empowered)
			var/wound_count = 0
			for(var/datum/organ/external/E in H.organs)
				for(var/datum/wound/W in E.wounds)
					if(W.internal)
						W.heal_damage(W.damage) //Completely heal internal wounds.
						wound_count++
					else
						if(W.bleeding()) //Check this purely for fluff
							W.bleed_timer = 0 //Stop the bleeding completely otherwise. The wounds are still there.
							wound_count++
			if(wound_count)
				to_chat(H, "<span class='notice'>In addition, you stitch [wound_count] wounds shut, preventing any further bleeding.</span>")
			for(var/i = 0 to 5)
				H.adjustBruteLoss(-2)
				H.adjustOxyLoss(-5)
				H.adjustToxLoss(-2)
				H.adjustFireLoss(-2)
				sleep(3.5 SECONDS) // Before the next healing tick
	V.remove_blood(blood_cost)
