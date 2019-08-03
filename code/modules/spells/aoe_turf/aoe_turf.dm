/*
Aoe turf spells target a ring of tiles around the user
This ring has an outer radius (range) and an inner radius (inner_radius)
Aoe turf spells have two useful flags: IGNOREDENSE and IGNORESPACE. These are explained in setup.dm
*/

/spell/aoe_turf //affects all turfs in view or range (depends)
	spell_flags = IGNOREDENSE
	user_type = USER_TYPE_NOUSER
	var/inner_radius = -1 //for all your ring spell needs
	var/center	//in case it's not supposed to center on the caster

/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()
	var/spell_center = holder
	if(center)
		spell_center = center
	for(var/turf/target in view_or_range(range, spell_center, selection_type))
		if(!(target in view_or_range(inner_radius, spell_center, selection_type)))
			if(target.density && (spell_flags & IGNOREDENSE))
				continue
			if(istype(target, /turf/space) && (spell_flags & IGNORESPACE))
				continue
			targets += target

	if(!targets.len) //doesn't waste the spell
		return

	return targets

/spell/aoe_turf/is_valid_target(var/target, mob/user, options)
	var/spell_center = user
	if(center)
		spell_center = center
	return ((target in view_or_range(range, spell_center, selection_type)))

/spell/aoe_turf/perform(mob/user = usr, skipcharge = 0, list/target_override)
	. = ..()
	center = null