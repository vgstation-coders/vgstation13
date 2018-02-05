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

		var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
		smoke.set_up(3, 0, starting)
		smoke.start()

		smoke = new()
		smoke.set_up(3, 0, T)
		smoke.start()

	return
