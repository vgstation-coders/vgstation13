// IDEAL USE FOR WIZARD EMA- I MEAN, ARCADE TAMPER:
// -Emags are already used on electronic things, so try find as many non machinery items to apply this on, particularly ones with no foreseeable emag effect.
// -Keep ideas anomalous and sometimes absurd, if possible make the item do things it shouldn't even with hacking.
// -Usable items should generally be weakened by these, as a cursing wizard spell would.

/spell/targeted/arcane_tamper
	name = "Arcane Tamper"
	desc = "Bestows anomalous properties on items."
	abbreviation = "AT"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	school = "transmutation"
	charge_max = 300
	spell_flags = NEEDSCLOTHES // now it's balanced
	invocation_type = SpI_NONE // we say it in the arcane_acts
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3)
	cooldown_min = 200 //100 deciseconds reduction per rank
	hud_state = "wiz_disint"
	spell_flags = WAIT_FOR_CLICK

/spell/targeted/arcane_tamper/cast(list/targets, mob/user)
	..()
	for(var/atom/AM in targets)
		AM.arcane_act(user)
