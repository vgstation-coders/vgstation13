/spell/targeted/projectile/dumbfire/fireball
	name = "Fireball"
	abbreviation = "FB"
	desc = "This spell conjures a fireball that will fly in the direction you're facing and explode on collision with anything, or when it gets close to anyone else."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	proj_type = /obj/item/projectile/spell_projectile/fireball

	school = "evocation"
	charge_max = 200
	spell_flags = IS_HARMFUL
	invocation = "ONI SOMA"
	invocation_type = SpI_SHOUT
	range = 20
	cooldown_min = 50
	price = 0.75 * Sp_BASE_PRICE

	spell_flags = NEEDSCLOTHES
	spell_aspect_flags = SPELL_FIRE
	duration = 20
	projectile_speed = 1

	amt_dam_brute = 10
	amt_dam_fire = 15

	var/ex_severe = 0
	var/ex_heavy = 0
	var/ex_light = 1
	var/ex_flash = 3
	var/pressure = ONE_ATMOSPHERE

	spell_levels = list(Sp_SPEED = 0, Sp_MOVE = 0, Sp_POWER = 0, Sp_SPECIAL = 0)
	level_max = list(Sp_TOTAL = 9, Sp_SPEED = 4, Sp_MOVE = 1, Sp_POWER = 3, Sp_SPECIAL = 1)

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/fireball/prox_cast(var/list/targets, spell_holder)
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	explosion(get_turf(spell_holder), ex_severe, ex_heavy, ex_light, ex_flash)
	var/fDam = 1 + spell_levels[Sp_SPEED] + spell_levels[Sp_MOVE] + spell_levels[Sp_POWER] + spell_levels[Sp_SPECIAL]
	for(var/atom/A in orange(ex_light, spell_holder))
		new /obj/effect/fire_blast(A, fDam, 0, 1, pressure, 0, 3)
	return targets

/spell/targeted/projectile/dumbfire/fireball/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder)
	var/list/targets = ..()
	for(var/mob/living/M in targets)
		if(M.lying)
			targets -= M
	return targets

/spell/targeted/projectile/dumbfire/fireball/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return quicken_spell()
		if(Sp_MOVE)
			spell_levels[Sp_MOVE]++
			name = "Controlled Fireball"
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
			return "The spell is now targetable."
		if(Sp_SPECIAL)
			spell_levels[Sp_SPECIAL]++
			spell_flags -= NEEDSCLOTHES
			return "The spell no longer requires robes to cast."
		if(Sp_POWER)
			spell_levels[Sp_POWER]++	//These are = not += to avoid potential fuckery with adding damage over and over
			pressure += 50
			if(spell_levels[Sp_POWER] == 1)
				ex_light = 2
			if(spell_levels[Sp_POWER] == 2)
				amt_dam_brute = 15
				amt_dam_fire = 25
				ex_flash = 4
			if(spell_levels[Sp_POWER] == 3)
				ex_heavy = 1
				ex_flash = 5


/spell/targeted/projectile/dumbfire/fireball/get_upgrade_price(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return 10
		if(Sp_POWER)
			return 5
		if(Sp_MOVE)
			return 10
		if(Sp_SPECIAL)
			return 10

/spell/targeted/projectile/dumbfire/fireball/is_valid_target(var/atom/target)
	if(!istype(target))
		return 0
	if(target == holder)
		return 0

	return (isturf(target) || isturf(target.loc))

/spell/targeted/projectile/dumbfire/fireball/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_MOVE)
		return "Make the spell targetable."
	if(upgrade_type == Sp_POWER)
		return "Increase explosive power! Each level is worth more than the last."
	if(upgrade_type == Sp_SPECIAL)
		return "Allows the spell to be cast without wizard robes."
	return ..()

//PROJECTILE

/obj/item/projectile/spell_projectile/fireball
	name = "fireball"
	icon_state = "fireball"
	animate_movement = 2
	linear_movement = 0

/obj/item/projectile/spell_projectile/fireball/to_bump(var/atom/A)
	if(!isliving(A))
		forceMove(get_turf(A))
	return ..()
