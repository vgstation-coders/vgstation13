/spell/targeted/projectile/dumbfire/firebreath
	name = "Fire Breath"
	abbreviation = "FB"
	desc = "This spell allows you to spew a plume of fire."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	proj_type = /obj/item/projectile/fire_breath

	school = "evocation"
	price = SP_BASE_PRICE / 2
	charge_cooldown_max = 10 SECONDS
	spell_flags = WAIT_FOR_CLICK | IS_HARMFUL
	invocation = "SPY'SI MEAT'A'BAL"
	invocation_type = SP_INV_SHOUT
	range = 20
	cooldown_min = 2 SECONDS

	spell_aspect_flags = SPELL_FIRE
	duration = 2 SECONDS
	projectile_speed = 1
	dumbfire = 0

	var/pressure = ONE_ATMOSPHERE * 4.5
	level_max = list(SP_TOTAL = 8, SP_SPEED = 4, SP_POWER = 4)

	hud_state = "wiz_firebreath"

/spell/targeted/projectile/dumbfire/firebreath/spawn_projectile(var/location, var/direction)
	return new proj_type(location, direction, P = pressure)

/spell/targeted/projectile/dumbfire/firebreath/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == SP_POWER)
		return "Increase the size of the fire plume."
	return ..()

/spell/targeted/projectile/dumbfire/firebreath/empower_spell()
	spell_levels[SP_POWER]++

	var/current_name = name
	var/explosion_description = "The plume of fire you breathe will now be larger."
	switch(spell_levels[SP_POWER])
		if(0)
			name = "Fire Breath"
			explosion_description = "You can now breathe fire."
		if(1)
			name = "Improved Fire Breath"
		if(2)
			name = "Enhanced Fire Breath"
		if(3)
			name = "Advanced Fire Breath"
		if(4)
			name = "Ascended Fire Breath"
		else
			return

	pressure += 150
	return "You have improved [current_name] into [name]. [explosion_description]"
