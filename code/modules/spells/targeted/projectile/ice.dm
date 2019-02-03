/spell/targeted/projectile/dumbfire/ice
/*
TO-DO
1 - Make Ice Missile a thrown object, much like Pastry throw
2 - Request an ice missile sprite that has directions and looks animated
3 - Make Ice barrage
4 - Make Ice Missile cast Ice Barrage when it lands

*/
	name = "Ice Missile"
	abbreviation = "IM"
	desc = "This spell conjures an icy projectile that will fly in the direction you're aiming and shatter on collision with anything, freezing the victim."
	user_type = USER_TYPE_WIZARD

	proj_type = /obj/item/projectile/spell_projectile/ice

	school = "evocation"
	charge_max = 500
	spell_flags = 0
	invocation = "Fri'z! Ai Scr'Eim!"
	invocation_type = SpI_SHOUT
	range = 40
	cooldown_min = 10 //10 deciseconds reduction per rank

	spell_flags = 0
	spell_aspect_flags = SPELL_WATER
	duration = 20
	projectile_speed = 1

	amt_dam_brute = 20

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/ice/prox_cast(var/list/targets, spell_holder)
	for(var/mob/living/M in targets)
		if (spell_levels[Sp_POWER] == 1)
			to_chat(M, "<span class='notice'>dude barrage lmao</span>")
			playsound(M,'sound/effects/icebarrage.ogg',40,1)
			apply_spell_damage(M)
			//M.stunned = 4
			//to_chat(M, "<span class='notice'>A magical force stops you from moving!</span>")
			// CAST ICE BARRAGE ON THE SPOT
			//return targets
		else
			playsound(M,'sound/effects/icebarrage.ogg',40,1)
			apply_spell_damage(M)
			M.bodytemperature -= 5
			M.color = "#00aedb"
			spawn(4 SECONDS)
			if(M.color == "#00aedb")
				M.color = ""
				to_chat(world, "[M]")
			to_chat(M, "<span class='notice'>Holy shit it's freezing!</span>")
	return targets

/spell/targeted/projectile/dumbfire/ice/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder)
	var/list/targets = ..()
	for(var/mob/living/M in targets)
		if(M.lying)
			targets -= M
	return targets

/spell/targeted/projectile/dumbfire/ice/empower_spell()
	spell_levels[Sp_POWER]++

	var/explosion_description = ""
	switch(spell_levels[Sp_POWER])
		if(0)
			name = "Ice Missile"
			explosion_description = "It will now shatter on impact."
		if (1)
			name = "Ice Barrage"
			explosion_description = "The ice missile will no longer shatter on impact. Innstead, it will freeze anyone nearby the victim that gets hit by the missile."
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
		else
			return

	return "You have improved Ice Missile into [name]. [explosion_description]"

/spell/targeted/projectile/dumbfire/ice/is_valid_target(var/atom/target)
	if(!istype(target))
		return 0
	if(target == holder)
		return 0

	return (isturf(target) || isturf(target.loc))

/spell/targeted/projectile/dumbfire/ice/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Make the spell freeze anyone nearby the impact point."
	return ..()

//PROJECTILE

/obj/item/projectile/spell_projectile/ice
	name = "ice_missile"
	icon_state = "ice_missile"
	animate_movement = 2
	linear_movement = 0

/obj/item/projectile/spell_projectile/ice/to_bump(var/atom/A)
	if(!isliving(A))
		forceMove(get_turf(A))
	return ..()
