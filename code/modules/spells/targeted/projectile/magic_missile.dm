/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	abbreviation = "MM"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	school = "evocation"
	charge_max = 150
	spell_flags = NEEDSCLOTHES
	invocation = "FORTI GY AMA"
	invocation_type = SpI_SHOUT
	range = 7
	cooldown_min = 90 //15 deciseconds reduction per rank

	max_targets = 0

	proj_type = /obj/item/projectile/spell_projectile/seeking/magic_missile
	duration = 10
	projectile_speed = 5

	hud_state = "wiz_mm"

	amt_knockdown = 3
	amt_stunned = 3

	amt_dam_fire = 10

/spell/targeted/projectile/magic_missile/prox_cast(var/list/targets, atom/spell_holder)
	spell_holder.visible_message("<span class='danger'>\The [spell_holder] pops with a flash!</span>")
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	return

/spell/targeted/projectile/magic_missile/spare_stunned
	user_type = USER_TYPE_OTHER

/spell/targeted/projectile/magic_missile/spare_stunned/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder) //This version of magic missile doesn't hit stunned mobs.
	var/list/targets = ..()
	for(var/mob/living/M in targets)
		if(M.stunned)
			targets.Remove(M)
	return targets

//PROJECTILE

/obj/item/projectile/spell_projectile/seeking/magic_missile
	name = "magic missile"
	icon_state = "magicm"

	animate_movement = 2
	linear_movement = 0

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

/obj/item/projectile/spell_projectile/seeking/magic_missile/indiscriminate/choose_prox_targets(user = carried.holder, spell_holder = src)
	if(!carried)
		return

	return carried.choose_prox_targets(arglist(args))
