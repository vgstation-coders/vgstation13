/spell/targeted/projectile/dumbfire/fireball/firebreath
	name = "Fire Breath"
	desc = "This spell allows you to spew a plume of fire."
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	proj_type = /obj/item/projectile/fire_breath

	price = Sp_BASE_PRICE / 2
	school = "evocation"
	invocation = "SPY'SI MEAT'A'BAL"

	spell_flags = WAIT_FOR_CLICK
	spell_aspect_flags = SPELL_FIRE
	dumbfire = 0

	amt_dam_brute = 0
	amt_dam_fire = 0
	var/pressure = ONE_ATMOSPHERE * 4.5
	level_max = list(Sp_TOTAL = 8, Sp_SPEED = 4, Sp_POWER = 4)

	hud_state = "wiz_firebreath"

/spell/targeted/projectile/dumbfire/fireball/firebreath/spawn_projectile(var/location, var/direction)
	return new proj_type(location,direction,P = pressure)

/spell/targeted/projectile/dumbfire/fireball/firebreath/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Increase the size of the fire plume."
	return ..()

/spell/targeted/projectile/dumbfire/fireball/firebreath/empower_spell()
	spell_levels[Sp_POWER]++

	var/current_name = name
	var/explosion_description = "The plume of fire you breathe will now be larger."
	switch(spell_levels[Sp_POWER])
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