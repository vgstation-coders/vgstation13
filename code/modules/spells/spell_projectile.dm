/obj/item/projectile/spell_projectile
	name = "spell"
	icon = 'icons/obj/projectiles.dmi'

	nodamage = 1 //Most of the time, anyways

	var/spell/targeted/projectile/carried

	kill_count = 10 //set by the duration of the spell

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"

/obj/item/projectile/spell_projectile/ex_act()
	return

/obj/item/projectile/spell_projectile/process_step()
	..()
	if(!isnull(src.loc))
		if(carried)
			var/list/targets = choose_prox_targets(user = carried.holder, spell_holder = src)
			if(targets && targets.len)
				src.prox_cast(targets)
		if(proj_trail && src && src.loc) //pretty trails
			var/obj/effect/overlay/trail = getFromPool(/obj/effect/overlay, src.loc)
			trail.icon = proj_trail_icon
			trail.icon_state = proj_trail_icon_state
			trail.setDensity(FALSE)
			spawn(proj_trail_lifespan)
				returnToPool(trail)
	return

/obj/item/projectile/spell_projectile/proc/prox_cast(var/list/targets)
	if(loc)
		carried.prox_cast(targets, src)
		qdel(src)
	return

/obj/item/projectile/spell_projectile/to_bump(var/atom/A)
	if(loc)
		prox_cast(choose_prox_targets(user = carried.holder, spell_holder = src))
	return

/obj/item/projectile/spell_projectile/OnDeath()
	if(loc)
		prox_cast(choose_prox_targets(user = carried.holder, spell_holder = src))
	return

/obj/item/projectile/spell_projectile/proc/choose_prox_targets(user = carried.holder, spell_holder = src)
	if(!carried)
		return

	return carried.choose_prox_targets(arglist(args))

/obj/item/projectile/spell_projectile/seeking
	name = "seeking spell"

/obj/item/projectile/spell_projectile/seeking/choose_prox_targets(user = carried.holder, spell_holder = src)
	if(Adjacent(original))
		return list(original)
	else
		return list()

/obj/item/projectile/spell_projectile/seeking/process_step()
	..()
	if(original && !isnull(src.loc))
		current = original //update the target