/spell/aoe_turf/conjure/spares
	name = "Summon Spares"
	desc = "this spell summons spare IDs in the nearby vicinity."
	user_type = USER_TYPE_SPELLBOOK
	summon_type = list(/obj/item/weapon/card/id/captains_spare)
	summon_amt = 5

	range = 1

	school = "conjuration"
	invocation = "W'ZZ GO' T'E S'RE!"
	invocation_type = SP_INV_SHOUT
	charge_cooldown_max = 30 SECONDS
	spell_flags = 0

	hud_state = "wiz_spare"


