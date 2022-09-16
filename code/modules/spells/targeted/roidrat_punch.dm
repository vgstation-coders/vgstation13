/spell/targeted/roidrat_punch // A much less powerful version of the wizard punch. Can launch a mob a long distance, but causes no explosion. Even this rat's gains have their limits
	name = "Roid Rat Punch"
	desc = "This spell empowers your next close-and-personal unarmed attack to launch the enemy with great force"
	abbreviation = "RP"
	specialization = SSOFFENSIVE

	charge_max = 450 // Much longer cooldown than the wizard spell
	cooldown_min = 30

	message = "<span class='danger'>You are punched with great force!<span>"
	spell_flags = IS_HARMFUL | WAIT_FOR_CLICK

	invocation = "OHYEAH"
	invocation_type = SpI_SHOUT

	max_targets = 1
	range = 1

	compatible_mobs = list(/mob/living) // Unlike the other version, this one can't target and destroy mechs
	hud_state = "gen_hulk"

	var/mob/living/present_target //A placeholder proc that records the target for the purpose of actually getting the impact handled. Thanks Barry

/spell/targeted/roidrat_punch/invocation(mob/user, list/targets)
	invocation = pick("OHYEAH", "YEAH", "POWEEEER", "BOOOM")
	..()

/spell/targeted/roidrat_punch/cast(var/list/targets)
	var/mob/living/L = holder
	if(istype(L) && L.has_hand_check() && !L.restrained())
		var/image/I = generate_punch_sprite()
		for(var/mob/living/target in targets)
			if(L.is_pacified(1,target))
				return
			playsound(get_turf(L), 'sound/weapons/punch_reverb.ogg', 100)
			if(M_HULK in target.mutations) //Target is a hulk and too tough to throw, cannot be stunned
				L.visible_message("<span class='danger'>[L] throws a powerful punch against \the [target]!</span>")
				L.do_attack_animation(target, L, I)
				target.take_organ_damage(30)
				return
			if(istype(target.locked_to, /obj/structure/bed)) //Target is sitting on something, knock them off it
				var/obj/structure/bed/B = target.locked_to
				if(!B.unlock_atom(target)) //We can't knock them off, let them taste the full brunt of this punch
					L.visible_message("<span class='danger'>[L] throws a powerful punch against \the [target]!</span>")
					L.do_attack_animation(target, L, I)
					target.take_organ_damage(30)
					return
			present_target = target
//Use two events because each does something the other cannot do, even if they are mostly similar.
			target.register_event(/event/to_bump, src, .proc/handle_bump)
			target.register_event(/event/throw_impact, src, .proc/handle_throw_impact)
			L.do_attack_animation(target, L, I)
			target.take_organ_damage(30) //A PUNCH THAT SHALL PIERCE PROTECTIONS
			target.throw_at(get_edge_target_turf(L, L.dir), INFINITY, 1)
			L.visible_message("<span class='danger'>[L] throws a mighty punch that launches \the [target] away!</span>")
			var/turns = 0 //Fixes a bug where the transform could occasionally get messed up such as when the target is lying down
			spawn(0) //Continue spell-code
				while(target.throwing)
					if(!target.timestopped) //Don't wanna copy-paste so hard that I revive an old bug
						target.transform = turn(target.transform, 45) //Spin the target
						target.SetStunned(2) //We don't want the target to move during this time
						turns += 45
					sleep(1)
				target.transform = turn(target.transform, -turns)
				target.Knockdown(2)
				target.unregister_event(/event/to_bump, src, .proc/handle_bump) //Just in case
				target.unregister_event(/event/throw_impact, src, .proc/handle_throw_impact)

/spell/targeted/roidrat_punch/proc/handle_bump(atom/movable/bumper, atom/bumped)
	present_target.unregister_event(/event/to_bump, src, .proc/handle_bump)
	present_target.unregister_event(/event/throw_impact, src, .proc/handle_throw_impact)

/spell/targeted/roidrat_punch/proc/handle_throw_impact(atom/hit_atom, speed, mob/living/user)
	present_target.unregister_event(/event/to_bump, src, .proc/handle_bump)
	present_target.unregister_event(/event/throw_impact, src, .proc/handle_throw_impact)

/spell/targeted/roidrat_punch/proc/generate_punch_sprite()
	return image(icon = 'icons/mob/screen_spells.dmi', icon_state = hud_state)
