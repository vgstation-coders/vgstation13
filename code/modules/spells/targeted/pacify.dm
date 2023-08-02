/spell/targeted/pacify
	name = "Pacify"
	desc = "Generates a burst of calming energies which inhibit hostile behavior in living beings. The caster is slightly affected by channeling these energies."
	user_type = USER_TYPE_WIZARD
	specialization = SSDEFENSIVE

	charge_max = 45 SECONDS
	cooldown_reduc = 15 SECONDS
	cooldown_min = 15 SECONDS

	spell_levels = list(Sp_SPEED = 0, Sp_RANGE = 0, Sp_POWER = 0)
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_RANGE = 1, Sp_POWER = 2)

	spell_flags = WAIT_FOR_CLICK
	invocation = "YUKKRI SHEETI NAY"
	invocation_type = SpI_SHOUT
	range = 6

	max_targets = 1

	hud_state = "wiz_pacify"

/spell/targeted/pacify/cast(list/targets, mob/user)
	..()
	if(targets)
		if(user.reagents)
			user.reagents.add_reagent(CHILLWAX, 4 + (spell_levels[Sp_POWER]/2))
		var/turf/target = targets[1]
		if(isturf(target))
			target.vis_contents += new /obj/effect/overlay/pacify_aoe(target, spell_levels[Sp_POWER], spell_levels[Sp_RANGE])

/spell/targeted/pacify/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return quicken_spell()
		if(Sp_POWER)
			spell_levels[Sp_POWER]++
		if(Sp_RANGE)
			spell_levels[Sp_RANGE]++

/spell/targeted/pacify/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return "Reduce this spell's cooldown."
		if(Sp_POWER)
			return "Increases how long targets are pacified for."
		if(Sp_RANGE)
			return "Increases the area of the spell's impact."

/spell/targeted/pacify/is_valid_target(atom/target, mob/user, options, bypass_range = 0)
	if(!istype(target))
		return 0
	return (isturf(target))

/obj/effect/overlay/pacify_aoe
	name = "energy field"
	desc = "A field of magical calming energy."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	color = "blue"
	alpha = 127
	pixel_x = -32
	pixel_y = -32
	layer = DECAL_LAYER
	plane = ABOVE_TURF_PLANE

/obj/effect/overlay/pacify_aoe/New(var/turf/T, var/power, var/size)
	..()
	src.transform *= (size + 1)
	for(var/mob/living/M in range(size + 1, src))
		if(M.reagents)
			M.reagents.add_reagent(CHILLWAX, 4 + (power + 4)/ 2)
			M.reagents.add_reagent(OXYCODONE, 1 + (power + 1)/ 2)
	animate(src, alpha = 0, time = 2 SECONDS)
	spawn(2 SECONDS)
		T.vis_contents -= src
		qdel(src)
