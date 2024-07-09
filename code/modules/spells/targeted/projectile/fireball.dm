/spell/targeted/projectile/dumbfire/fireball
	name = "Fireball"
	abbreviation = "FB"
	desc = "This spell conjures a fireball that will fly in the direction you're facing and explode on collision with anything."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	proj_type = /obj/item/projectile/spell_projectile/fireball

	school = "evocation"
	charge_max = 100
	spell_flags = IS_HARMFUL
	invocation = "ONI SOMA"
	invocation_type = SpI_SHOUT
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank

	spell_aspect_flags = SPELL_FIRE
	duration = 20
	projectile_speed = 1
	cast_prox_range = 0

	amt_dam_brute = 40
	amt_dam_fire = 45

	var/ex_severe = -1
	var/ex_heavy = 0
	var/ex_light = 3
	var/ex_flash = 5

	var/safe = 0 //If toggled on, the user will be included in the explosion blacklist, making them immune to both the explosion and the shrapnel

	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_MISC = 0) //Needs to be defined since it's searching for these in the spellbook code
	level_max = list(Sp_TOTAL = 6, Sp_SPEED = 4, Sp_POWER = 1, Sp_MISC = 1)

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/fireball/get_upgrade_price(upgrade_type)
	if(upgrade_type == Sp_MISC) //Safety comes at a premium
		return 40
	return ..()

/spell/targeted/projectile/dumbfire/fireball/apply_upgrade(upgrade_type)
	if(upgrade_type == Sp_MISC)
		spell_levels[Sp_MISC]++
		safe = 1
		return 1
	return ..()

/spell/targeted/projectile/dumbfire/fireball/prox_cast(var/list/targets, spell_holder)
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	if(safe)
		var/list/immune_wizard = list()
		immune_wizard += holder
		explosion(get_turf(spell_holder), ex_severe, ex_heavy, ex_light, ex_flash, whodunnit = holder, whitelist = immune_wizard, shrapnel_whitelist = immune_wizard)
	else
		explosion(get_turf(spell_holder), ex_severe, ex_heavy, ex_light, ex_flash, whodunnit = holder)
	return targets

/spell/targeted/projectile/dumbfire/fireball/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder)
	var/list/targets = ..()
	for(var/mob/living/M in targets)
		if(M.lying)
			targets -= M
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

/spell/targeted/projectile/dumbfire/fireball/is_valid_target(atom/target, mob/user, options, bypass_range = 0)
	if(!istype(target))
		return 0
	if(target == holder)
		return 0

	return (isturf(target) || isturf(target.loc))

/spell/targeted/projectile/dumbfire/fireball/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		if(spell_levels[Sp_POWER] >= level_max[Sp_POWER])
			return "The spell is already targetable!"
		return "Make the spell targetable."
	else if(upgrade_type == Sp_MISC)
		if(spell_levels[Sp_MISC] >= level_max[Sp_MISC])
			return "You are already immune to your own fireballs!"
		return "Makes the user immune to their own fireballs, shrapnel included."
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
