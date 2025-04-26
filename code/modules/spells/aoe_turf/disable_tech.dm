/spell/aoe_turf/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	abbreviation = "DT"

	charge_cooldown_max = 40 SECONDS
	spell_flags = NEEDSCLOTHES
	invocation = "NEC CANTIO"
	invocation_type = SP_INV_SHOUT
	selection_type = "range"
	range = 0
	inner_radius = -1

	cooldown_min = 20 SECONDS //0.5 seconds reduction per rank

	var/emp_heavy = 6
	var/emp_light = 10

	hud_state = "wiz_tech"

/spell/aoe_turf/disable_tech/cast(list/targets)

	for(var/turf/target in targets)
		empulse(get_turf(target), emp_heavy, emp_light)
	return