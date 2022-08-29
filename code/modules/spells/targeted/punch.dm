/spell/targeted/punch
	name = "Punch"
	desc = "This spell empowers your next close-and-personal unarmed attack to launch the enemy with such great force that they cause a small explosion where they land. The ensuing explosion won't harm you directly, but the after-effects might."
	abbreviation = "PU"
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 1)
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE
	charge_max = 90
	invocation = "ROCKETO PUNCH!"
	message = "<span class='danger'>You are launched with great force!<span>"
	spell_flags = IS_HARMFUL | WAIT_FOR_CLICK
	cooldown_min = 30
	invocation_type = SpI_SHOUT
	max_targets = 1
	range = 1
	compatible_mobs = list(/mob/living)
	var/empowered = 0
	var/mob/living/present_target //A placeholder proc that records the target for the purpose of actually getting the impact handled.


/spell/targeted/punch/cast(var/list/targets)
	var/mob/living/L = holder
	if(istype(L) && L.has_hand_check())
		for(var/mob/living/target in targets)
			if(L.is_pacified(1,target))
				return
			present_target = target
			target.register_event(/event/throw_impact, src, .proc/handle_impact)
			target.throw_at(get_edge_target_turf(L, L.dir), INFINITY, 50)
			spawn(10) //In case the target is thrown so far away that they don't hit anything
				target.unregister_event(/event/throw_impact, src, .proc/handle_impact)

//A middle-man proc that records the hit atom and the target at the same time, because event/throw_impact doesn't carry the data on who is being listened to.
/spell/targeted/punch/proc/handle_impact(var/atom/hit_atom, var/speed, var/user)
	var/mob/living/L = user
	to_chat(L, "<span class='good'>This shit kicked off, the bumping works!</span>")
	explode_on_impact(hit_atom, present_target, holder)

//Explosion is centered on the collided entity.
/spell/targeted/punch/proc/explode_on_impact(var/atom/hit_atom, var/mob/living/T, var/mob/living/user)
	var/list/explosion_whitelist = list()
	explosion_whitelist += user //Wizard is immune to the ensuing explosion, because that's badass
	to_chat(user, "<span class='good'>Added to the whitelist bro!</span>")
	if(empowered) //The unfortunate sod being thrown by it won't be instantly deleted from the game, but whatever they collide with will.
		explosion(get_turf(hit_atom), 1, 4, 6, whodunnit = user, whitelist = explosion_whitelist)
	else
		explosion(get_turf(hit_atom), 0, 2, 3, whodunnit = user, whitelist = explosion_whitelist)
	to_chat(user, "<span class='good'>The explosion happened! Or at least is supposed to.</span>")
	T.unregister_event(/event/throw_impact, src, .proc/handle_impact)
