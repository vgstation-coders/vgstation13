/spell/targeted/grease
	name = "Grease"
	desc = "Slick grease covers the ground in a radius, turning the terrain into difficult terrain. Has spell congruency with fire-based spells."
	abbreviation = "GR"
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	school = "evocation"
	charge_cooldown_max = 30 SECONDS
	invocation = "GR'ESE LIT'NING"
	invocation_type = SP_INV_SHOUT
	range = 0
	spell_flags = NEEDSCLOTHES | INCLUDEUSER
	level_max = list(SP_TOTAL = 5, SP_SPEED = 4, SP_POWER = 1)
	hud_state = "bucket"

/spell/targeted/grease/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(SP_POWER)
			if(spell_levels[SP_POWER] >= level_max[SP_POWER])
				return "You can already emit grease at the targeted location!"
			return "Allows you to target a different location within 4 tiles of you to cover it with grease."
	return ..()


/spell/targeted/grease/empower_spell()
	spell_levels[SP_POWER]++

	var/explosion_description = ""
	switch(spell_levels[SP_POWER])
		if(0)
			explosion_description = "You will now emit grease from your location."
		if(1)
			name = "Slick Grease"
			range = 4
			explosion_description = "You can now point to a location up to [range] tiles away to become slick greased. Has spell congruency with fire-based spells."
			spell_flags |= WAIT_FOR_CLICK
		else
			return

	return "You have improved Grease into [name]. [explosion_description]"

/spell/targeted/grease/cast(var/list/targets, mob/user)
	if(spell_levels[SP_POWER] >= 1)
		for(var/A in targets)
			var/turf/T = get_turf(A)
			var/datum/effect/system/foam_spread/s = new()
			s.set_up(50, T, null, 0)
			s.carried_reagents.Add(LUBE)
			if(user.has_spell_with_flag(SPELL_FIRE))
				s.carried_reagents.Add(FUEL)
			s.start()
	else
		var/turf/T = get_turf(user)
		var/datum/effect/system/foam_spread/s = new()
		s.set_up(50, T, null, 0)
		s.carried_reagents.Add(LUBE)
		if(user.has_spell_with_flag(SPELL_FIRE))
			s.carried_reagents.Add(FUEL)
		s.start()
	score.greasewiz++
