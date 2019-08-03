/spell/aoe_turf/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."
	user_type = USER_TYPE_WIZARD
	specialization = DEFENSIVE
	abbreviation = "BL"

	school = "abjuration"
	charge_max = 20
	spell_flags = IGNOREDENSE | IGNORESPACE
	invocation = "none"
	invocation_type = SpI_NONE
	range = 7
	inner_radius = 1
	cooldown_min = 5 //4 deciseconds reduction per rank
	hud_state = "wiz_blink"
	selection_type = "range"

/spell/aoe_turf/blink/cast(var/list/targets, mob/user)
	if(!targets.len)
		return

	var/turf/T = pick(targets)
	var/turf/starting = get_turf(user)
	if(T)
		user.unlock_from()
		user.teleport_to(T)

		makeAnimation(T, starting)
	return

/spell/aoe_turf/blink/proc/makeAnimation(var/turf/T, var/turf/starting)
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(1, 0, T)
	smoke.start()

/spell/aoe_turf/blink/vamp
	name = "Shadowstep (10)"
	desc = "Vanish into the shadows."
	user_type = USER_TYPE_VAMPIRE

	override_base = "vamp"
	hud_state = "vamp_blink"

	charge_max = 20 SECONDS
	cooldown_min = 20 SECONDS

	var/max_lum = 1
	var/blood_cost = 10

/spell/aoe_turf/blink/vamp/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (user.locked_to)
		to_chat(user, "<span class='warning'>We are restrained!</span>")
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/aoe_turf/blink/vamp/choose_targets()
	var/turfs = ..()
	for (var/turf/T in turfs)
		if (T.get_lumcount() * 10 > 2)
			turfs -= T
	return turfs

/spell/aoe_turf/blink/vamp/cast(var/list/targets, var/mob/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		for (var/datum/organ/external/O in H.organs)
			O.release_restraints()
	. = ..()
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)

/spell/aoe_turf/blink/vamp/makeAnimation(var/turf/T, var/turf/starting)
	starting.turf_animation('icons/effects/effects.dmi',"shadowstep")