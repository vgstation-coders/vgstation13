// IDEAL USE FOR WIZARD EMA- I MEAN, ARCADE TAMPER:
// -Emags are already used on electronic things, so try find as many non machinery items to apply this on, particularly ones with no foreseeable emag effect.
// -Keep ideas anomalous and sometimes absurd, if possible make the item do things it shouldn't even with hacking.
// -Usable items should generally be weakened by these, as a cursing wizard spell would.

/spell/targeted/arcane_tamper
	name = "Arcane Tamper"
	desc = "Bestows anomalous properties on nearby items."
	abbreviation = "AT"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	school = "transmutation"
	charge_cooldown_max = 15 SECONDS
	spell_flags = NEEDSCLOTHES // now it's balanced
	invocation = "E'MAGI!"
	invocation_type = SP_INV_NONE // we say it in the arcane_acts
	level_max = list(SP_TOTAL = 4, SP_SPEED = 2, SP_POWER = 2)
	range = 1
	cooldown_min = 10 SECONDS // 5 seconds reduction per rank
	hud_state = "wiz_arctam"
	spell_flags = WAIT_FOR_CLICK
	var/recursive = FALSE // does it curse contents too?

/spell/targeted/arcane_tamper/empower_spell()
	spell_levels[SP_POWER]++

	var/oldname = name
	var/description = ""
	switch(spell_levels[SP_POWER])
		if(0)
			name = "Arcane Tamper"
			description = "It will now make nearby items anomalous."
		if(1)
			name = "Ranged Arcane Tamper"
			description = "It can now affect any item in view."
			range = 7
		if(2)
			name = "Ranged Recursive Arcane Tamper"
			description = "It will now make any item in normal view anomalous along with their contents."
			recursive = TRUE
		else
			return

	return "You have improved [oldname] into [name]. [description]"

/spell/targeted/arcane_tamper/get_upgrade_price(upgrade_type)
	switch(upgrade_type)
		if(SP_SPEED)
			return 10
		if(SP_POWER)
			return 10

/spell/targeted/arcane_tamper/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(SP_POWER)
			if(spell_levels[SP_POWER] == 0)
				return "Upgrades the range of the spell. At the second upgrade, improves the recursiveness of the spell, allowing it to affect the target's contents."
			if(spell_levels[SP_POWER] == 1)
				return "Improves the recursiveness of the spell, allowing it to affect the target's contents."
	return ..()

/spell/targeted/arcane_tamper/cast(list/targets, mob/user)
	..()
	invocation = "E'MAGI!"
	for(var/atom/AM in targets)
		invocation = AM.arcane_act(user,recursive)
		// below looks close enough to ideal
		anim(target = AM, a_icon = 'icons/mob/blob/blob.dmi', flick_anim = "blob_act", sleeptime = 15, lay = BLOB_SPORE_LAYER, plane = BLOB_PLANE)
		var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread()
		steam.set_up(10, 0, AM.loc)
		steam.start()
	if(prob(50))
		invocation = replacetext(invocation," ","`")
	user.say(invocation)
