/spell/targeted/punch
	name = "Punch"
	desc = "This spell empowers your next close-and-personal unarmed attack to launch the enemy with such great force that they cause a small explosion where they land. The ensuing explosion won't harm you directly, but the after-effects might. Works against mechas."
	abbreviation = "PU"
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 1)
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE
	charge_max = 90
	invocation = "ROKETTOPANCHI"
	message = "<span class='danger'>You are punched with great force!<span>"
	spell_flags = IS_HARMFUL | WAIT_FOR_CLICK | NEEDSCLOTHES
	cooldown_min = 30
	invocation_type = SpI_SHOUT
	max_targets = 1
	range = 1
	valid_targets = list(/mob/living, /obj/mecha)
	hud_state = "wiz_punch"
	var/empowered = 0
	var/mob/living/present_target //A placeholder proc that records the target for the purpose of actually getting the impact handled.
	var/has_triggered = 0 //Variable to avoid having multiple explosions as a result of multiple to_bump and throw_impact being triggered

	//A bunch of variables used for roid rat punching, to avoid copypasting a lot of code
	var/explosive_punches = 1 //Whether it will actually cause an explosion
	var/flat_damage //If set to a value, will override the L.get_unarmed_damage(target) * (multiplier) with the flat damage

/spell/targeted/punch/invocation(mob/user, list/targets)
	invocation = pick("ROCKETTOPANCHI", "FARUKONPANCHI", "NORUMARUPANCHI", "BANZAI") //Look the BANZAI is a reference and if you get it then hats off to you.
	..()

/spell/targeted/punch/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_POWER)
			return "Make the explosion more devastating, allowing it to cause more damage and even breach the ground."
	return ..()

/spell/targeted/punch/empower_spell()
	..()
	empowered += 1
	spell_levels[Sp_POWER]++
	. = "You have made the punch more devastating."

/spell/targeted/punch/cast(var/list/targets)
	var/mob/living/L = holder
	if(!istype(L) || !L.has_hand_check() || L.restrained())
		return
	var/T = targets[1]
	if(L.is_pacified(1,T))
		return
	var/image/I = generate_punch_sprite()
	playsound(get_turf(L), 'sound/weapons/punch_reverb.ogg', 100)
	if(istype(T, /obj/mecha)) //Target is a mecha, destroy it
		var/obj/mecha/M = T
		L.visible_message("<span class='danger'>[L] throws an overwhelmingly powerful punch that breaks \the [M]!</span>")
		L.do_attack_animation(M, L, I)
		explosive_punch(M)
		M.ex_act(1)
		return
	var/mob/living/target = T
	var/obj/structure/bed/B = target.locked_to //If the target can't be unlocked from something they're sitting on, do a super punch
	if((M_HULK in target.mutations) || (B && !B.unlock_atom(target))) //Target is a hulk or can't be removed, do the punch
		L.visible_message("<span class='danger'>[L] throws an overwhelmingly powerful punch against \the [target]!</span>")
		L.do_attack_animation(target, L, I)
		target.take_organ_damage(calculate_damage(flat_damage, TRUE, target))
		explosive_punch(target)
		return
	//Use two events because each does something the other cannot do, even if they are mostly similar.
	if(explosive_punches)
		target.register_event(/event/to_bump, src, nameof(src::handle_bump()))
		target.register_event(/event/throw_impact, src, nameof(src::handle_throw_impact()))
	L.do_attack_animation(target, L, I)
	target.take_organ_damage(calculate_damage(flat_damage, FALSE, target)) //A PUNCH THAT SHALL PIERCE PROTECTIONS
	target.throw_at(get_edge_target_turf(L, L.dir), INFINITY, 1)
	L.visible_message("<span class='danger'>[L] throws a mighty punch that launches \the [target] away!</span>")
	var/turns = 0 //Fixes a bug where the transform could occasionally get messed up such as when the target is lying down
	spawn(0) //Continue spell-code
		target.SetStunned(2) //Make sure this kicks in ASAP
		while(target.throwing)
			sleep(1) //Moved it here so that it fixes a bug caused by throw_at() cancelling time stop for a split second
			if(!target.timestopped)
				target.transform = turn(target.transform, 45) //Spin the target
				target.SetStunned(2) //We don't want the target to move during this time
				turns += 45
		target.transform = turn(target.transform, -turns)
		target.Knockdown(2)
		if(explosive_punches)
			target.unregister_event(/event/to_bump, src, nameof(src::handle_bump())) //Just in case
			target.unregister_event(/event/throw_impact, src, nameof(src::handle_throw_impact()))

/spell/targeted/punch/proc/handle_bump(atom/movable/bumper, atom/bumped)
	bumper.unregister_event(/event/to_bump, src, nameof(src::handle_bump()))
	bumper.unregister_event(/event/throw_impact, src, nameof(src::handle_throw_impact()))
	var/mob/living/L = holder
	explode_on_impact(bumped, bumper, L)

/spell/targeted/punch/proc/handle_throw_impact(atom/hit_atom, speed, mob/living/user, atom/thrown_atom)
	thrown_atom.unregister_event(/event/to_bump, src, nameof(src::handle_bump()))
	thrown_atom.unregister_event(/event/throw_impact, src, nameof(src::handle_throw_impact()))
	var/mob/living/L = holder
	explode_on_impact(hit_atom, thrown_atom, L)

//Explosion is centered on the collided entity.
/spell/targeted/punch/proc/explode_on_impact(var/atom/bumped, var/mob/living/T, var/mob/living/user)
	if(has_triggered || !explosive_punches)
		return
	var/list/explosion_whitelist = list()
	var/list/projectile_whitelist = list()
	explosion_whitelist += user //Wizard is immune to the ensuing explosion, because that's badass
	projectile_whitelist += user //Wizard shouldn't have to worry too much about the shrapnel from explosions, fight on!
	projectile_whitelist += T //Shrapnel causes the spell to be overkill on victims and way too unfair
	if(empowered) //The unfortunate sod being thrown by it won't be that severely harmed compared to what they collide into
		explosion(get_turf(bumped), 0, 1, 5, whodunnit = user, whitelist = explosion_whitelist, shrapnel_whitelist = projectile_whitelist)
	else
		explosion(get_turf(bumped), 0, 0, 3, whodunnit = user, whitelist = explosion_whitelist, shrapnel_whitelist = projectile_whitelist)
	has_triggered = 1
	spawn(1) //A 0.1 second delay, then we allow the spell to cause explosions again
		has_triggered = 0

//Explosion as a result of the target not flying away, significantly stronger than launching punches
/spell/targeted/punch/proc/explosive_punch(atom/target)
	if(!explosive_punches) //No explosive punches allowed!
		return
	var/list/explosion_whitelist = list()
	var/list/projectile_whitelist = list()
	explosion_whitelist += holder
	projectile_whitelist += holder
	projectile_whitelist += target
	if(empowered)
		explosion(get_turf(target), 0, 3, 7, whodunnit = holder, whitelist = explosion_whitelist, shrapnel_whitelist = projectile_whitelist)
	else
		explosion(get_turf(target), 0, 1, 5, whodunnit = holder, whitelist = explosion_whitelist, shrapnel_whitelist = projectile_whitelist)

/spell/targeted/punch/proc/generate_punch_sprite()
	return image(icon = 'icons/mob/screen_spells.dmi', icon_state = hud_state)

/spell/targeted/punch/proc/calculate_damage(flat_damage, tough_target, var/target)
	if(flat_damage)
		return flat_damage
	var/mob/living/L = holder
	return L.get_unarmed_damage(target) * (tough_target ? 10 : 5)


// Rat punch code here
/spell/targeted/punch/roidrat // A much less powerful version of the wizard punch. Can launch a mob a long distance, but causes no explosion. Even this rat's gains have their limits
	name = "Roid Rat Punch"
	desc = "This spell empowers your next close-and-personal unarmed attack to launch the enemy with great force"
	abbreviation = "RP"
	user_type = USER_TYPE_GYMRAT
	charge_max = 300 // Much longer cooldown than the wizard spell
	spell_flags = IS_HARMFUL | WAIT_FOR_CLICK
	invocation_type = SpI_NONE
	valid_targets = list(/mob/living) // Unlike the other version, this one can't target and destroy mechs
	hud_state = "gen_hulk"
	explosive_punches = 0
	flat_damage = 30

/spell/targeted/punch/roidrat/invocation(mob/user, list/targets) // No invocation on this one, just raw muscle
	return
