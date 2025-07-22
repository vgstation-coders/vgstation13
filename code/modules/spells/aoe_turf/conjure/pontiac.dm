// Also called the firebird. Included here for people who want to find this spell

/spell/aoe_turf/conjure/pontiac
	name = "Chariot"
	desc = "This spell summons a glorious, flaming chariot that can move in space."
	abbreviation = "WM"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY

	charge_type = SP_CHARGES
	charge_cooldown_max = 1 CHARGES
	school = "conjuration"
	spell_flags = Z2NOCAST
	invocation = "NO F'AT C'HX"
	invocation_type = SP_INV_SHOUT
	level_max = list(SP_TOTAL = 0)
	range = 0

	summon_type = list(/obj/structure/bed/chair/vehicle/firebird)
	duration = 0

	hud_state = "wiz_mobile"
