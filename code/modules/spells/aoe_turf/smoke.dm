/spell/aoe_turf/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
	abbreviation = "SM"
	user_type = USER_TYPE_WIZARD
	specialization = DEFENSIVE //Provides cover

	school = "conjuration"
	charge_max = 120
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 1
	inner_radius = -1
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 2
	smoke_amt = 5

	hud_state = "wiz_smoke"
