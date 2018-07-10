/spell/targeted/projectile/dumbfire/ice_missile
	name = "Ice Missile"
	abbreviation = "IM"
	desc = "This spell conjures an icy projectile that will fly in the direction you're facing and shatter on collision with anything, freezing the victim."
	user_type = USER_TYPE_WIZARD

	proj_type = /obj/item/projectile/spell_projectile/ice_missile

	school = "evocation"
	charge_max = 300
	spell_flags = NEEDSCLOTHES
	invocation = "Fri'z! Ai Scr'Eim!"
	invocation_type = SpI_SHOUT
	range = 40
	cooldown_min = 20 //10 deciseconds reduction per rank

	spell_flags = 0
	spell_aspect_flags = SPELL_WATER
	duration = 20
	proj_step_delay = 0

	amt_dam_brute = 25

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 2)

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/ice_missile/prox_cast(var/list/targets, spell_holder)

	for(var/mob/living/M in targets)
		if (spell_levels[Sp_POWER] == 2)
			M.Stun(4)
			M.bodytemperature -= 6
			M.show_message(M, "<span class='notice'>A magical force stops you from moving!</span>") // CODE IN THE AOE EFFECT YOU SHIT
			apply_spell_damage(M)
			playsound(M, 'sound/effects/icebarrage.ogg', 50, 10)
			M.color = "#00aedb"
			spawn(8 SECONDS)
				if(M.color == "#00aedb")
					M.color = ""

		else
			M.bodytemperature -= 6
			to_chat(M, "<span class='notice'>You feel a chill!</span>")
			apply_spell_damage(M)
			playsound(M, 'sound/effects/icebarrage.ogg', 50, 10)
	return targets

/spell/targeted/projectile/dumbfire/ice_missile/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder)
	var/list/targets = ..()
	for(var/mob/living/M in targets)
		if(M.lying)
			targets -= M
	return targets



/spell/targeted/projectile/dumbfire/ice_missile/empower_spell()
	spell_levels[Sp_POWER]++

	var/explosion_description = ""
	switch(spell_levels[Sp_POWER])
		if(0)
			name = "Ice Missile"
			explosion_description = "It will now shatter on impact."
		if(1)
			name = "Ice Blitz"
			explosion_description = "The ice blitz will no longer only fly in the direction you're facing. Now you're able to shoot it wherever you want."
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
		if (2)
			name = "Ice Barrage"
			explosion_description = "The ice barrage will no longer only fly in the direction you're facing. Now you're able to shoot it wherever you want, freezing victims in the area in place."
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
		else
			return

	return "You have improved Ice Missile into [name]. [explosion_description]"

/spell/targeted/projectile/dumbfire/ice_missile/is_valid_target(var/atom/target)
	if(!istype(target))
		return 0
	if(target == holder)
		return 0

	return (isturf(target) || isturf(target.loc))

/spell/targeted/projectile/dumbfire/ice_missile/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Make the spell targetable."
	return ..()

//PROJECTILE

/obj/item/projectile/spell_projectile/ice_missile
	name = "ice_2"
	icon_state = "ice_2"
	animate_movement = 2
	linear_movement = 0

/obj/item/projectile/spell_projectile/ice_missile/to_bump(var/atom/A)
	if(!isliving(A))
		forceMove(get_turf(A))
	return ..()