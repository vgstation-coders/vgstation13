/spell/aoe_turf/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."
	user_type = USER_TYPE_WIZARD
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
		user.forceMove(T)

		makeAnimation(T, starting, user)
	return

/spell/aoe_turf/blink/proc/makeAnimation(var/turf/T, var/turf/starting)
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(3, 0, starting)
	smoke.start()

	smoke = new()
	smoke.set_up(3, 0, T)
	smoke.start()

/spell/aoe_turf/blink/vamp
	name = "Shadowstep (10)"
	desc = "Vanish into the shadows."
	user_type = USER_TYPE_VAMPIRE

	override_base = "vamp"
	hud_state = "vampire_blink"

	charge_max = 20 SECONDS
	cooldown_min = 20 SECONDS

	var/max_lum = 1
	var/blood_cost = 10

/spell/aoe_turf/blink/vamp/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/aoe_turf/blink/vamp/is_valid_target(var/target, mob/user, options)
	var/turf/T = target
	. = ..()
	if (!.)
		return FALSE
	if (istype(T))
		return FALSE
	if ((T.get_lumcount() * 10) > max_lum)
		return FALSE
	if (istype(T,/turf/space))
		return FALSE

/spell/aoe_turf/blink/vamp/makeAnimation(var/turf/T, var/turf/starting)
	starting.turf_animation('icons/effects/effects.dmi',"shadowstep")