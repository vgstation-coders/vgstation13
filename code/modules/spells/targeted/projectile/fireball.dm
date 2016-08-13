/spell/targeted/projectile/dumbfire/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	proj_type = /obj/item/projectile/spell_projectile/fireball

	school = "evocation"
	charge_max = 100
	spell_flags = 0
	invocation = "ONI SOMA"
	invocation_type = SpI_SHOUT
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank

	spell_flags = 0

	duration = 20
	proj_step_delay = 0

	amt_dam_brute = 20
	amt_dam_fire = 25

	var/ex_severe = -1
	var/ex_heavy = 1
	var/ex_light = 2
	var/ex_flash = 5

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/fireball/prox_cast(var/list/targets, spell_holder)
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	explosion(get_turf(spell_holder), ex_severe, ex_heavy, ex_light, ex_flash)
	return targets

/spell/targeted/projectile/dumbfire/fireball/empower_spell()
	spell_levels[Sp_POWER]++

	var/explosion_description = ""
	switch(spell_levels[Sp_POWER])
		if(0)
			name = "Fireball"
			explosion_description = "It will now create a small explosion."
		if(1)
			name = "Controlled Fireball"
			explosion_description = "The fireball will no longer only fly in the direction you're facing. Now you're able to shoot it wherever you want."
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
		else
			return

	return "You have improved Fireball into [name]. [explosion_description]"

/spell/targeted/projectile/dumbfire/fireball/is_valid_target(var/atom/target)
	if(!istype(target))
		return 0
	if(target == holder)
		return 0

	return (isturf(target) || isturf(target.loc))

//PROJECTILE

/obj/item/projectile/spell_projectile/fireball
	name = "fireball"
	icon_state = "fireball"
	animate_movement = 2
	linear_movement = 0
