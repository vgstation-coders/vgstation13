/spell/aoe_turf/conjure/snowmobile
	name = "Summon Snowmobile"
	desc = "Time to Sleigh some No-gooders."
	user_type = USER_TYPE_OTHER // Unused as far as I am aware.

	charge_type = SP_CHARGES
	charge_cooldown_max = 1 CHARGES
	school = "conjuration"
	spell_flags = Z2NOCAST
	invocation = "SL'IGH B'LLS RIN'!"
	invocation_type = SP_INV_SHOUT
	range = 0

	summon_type = list(/obj/structure/bed/chair/vehicle/firebird/santa)
	duration = 0

	hud_state = "snowmobile"