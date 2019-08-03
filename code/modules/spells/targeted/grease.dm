/spell/targeted/grease
	name = "Grease"
	desc = "Slick grease covers the ground in a radius, turning the terrain into difficult terrain. Has spell congruency with fire-based spells."
	abbreviation = "GR"
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	school = "evocation"
	charge_max = 300
	invocation = "GR'ESE LIT'NING"
	invocation_type = SpI_SHOUT
	range = 1
	spell_flags = NEEDSCLOTHES | INCLUDEUSER
	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)
	hud_state = "bucket"


/spell/targeted/grease/empower_spell()
	spell_levels[Sp_POWER]++

	var/explosion_description = ""
	switch(spell_levels[Sp_POWER])
		if(0)
			explosion_description = "You will now emit grease from your location."
		if(1)
			name = "Slick Grease"
			range = 4
			explosion_description = "You can now point to a location within [range] to become a grease slick. Has spell congruency with fire-based spells."
			spell_flags |= WAIT_FOR_CLICK
		else
			return

	return "You have improved Grease into [name]. [explosion_description]"

/spell/targeted/grease/cast(var/list/targets, mob/user)
	if(spell_levels[Sp_POWER] >= 1)
		for(var/A in targets)
			var/turf/T = get_turf(A)
			var/datum/effect/effect/system/foam_spread/s = new()
			s.set_up(50, T, null, 0)
			s.carried_reagents.Add(LUBE)
			if(user.has_spell_with_flag(SPELL_FIRE))
				s.carried_reagents.Add(FUEL)
			s.start()
	else
		var/turf/T = get_turf(user)
		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(50, T, null, 0)
		s.carried_reagents.Add(LUBE)
		if(user.has_spell_with_flag(SPELL_FIRE))
			s.carried_reagents.Add(FUEL)
		s.start()
	score["greasewiz"]++
