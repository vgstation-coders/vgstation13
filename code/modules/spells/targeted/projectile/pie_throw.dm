/spell/targeted/projectile/pie
	name = "Projectile Pastry"
	abbreviation = "PP"
	desc = "This spell summons a random pie, and throws it at the location of your choosing. More power means more pies."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	school = "evocation"
	charge_max = 100
	spell_flags = 0
	invocation = "FLA'K PA'STRY"
	invocation_type = SpI_SHOUT
	range = 20

	spell_aspect_flags = SPELL_FIRE
	spell_flags = WAIT_FOR_CLICK | IS_HARMFUL
	duration = 20
	projectile_speed = 1

	level_max = list(Sp_TOTAL = 5, Sp_POWER = 5)

	hud_state = "pie"

/spell/targeted/projectile/pie/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_POWER)
			if(spell_levels[Sp_POWER] >= level_max[Sp_POWER])
				return "The spell can't be made any more powerful than this!"
			return "Allows you to throw an extra pie, and increases the throwing damage of each pie by 4."
	return ..()

/spell/targeted/projectile/pie/empower_spell()
	spell_levels[Sp_POWER]++
	return "Your spell now throws [spell_levels[Sp_POWER]+1] pies at once!"

/spell/targeted/projectile/pie/cast(list/targets, mob/user = usr)
	for(var/atom/target in targets)
		if (user.is_pacified(VIOLENCE_DEFAULT,target))
			return
	spawn()
		for(var/i = 0 to spell_levels[Sp_POWER])
			var/turf/T = get_turf(user)
			var/atom/target = pick(targets)
			var/pie_to_spawn = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/pie))
			var/obj/pie = new pie_to_spawn(T)
			to_chat(user, "You summon and throw \a [pie].")
			pie.throw_at(target, range, (spell_levels[Sp_POWER]+1)*20)
			sleep(5)
