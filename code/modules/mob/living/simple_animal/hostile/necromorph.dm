/*Necromorphs
	4 types
		Slasher, melee based, simple mobs
		Leaper, melee based, high mobility, latch onto foes, hide in vents
		Puker, semi-ranged based, vomits a highly corrosive cone of acid forwards towards its victims
		Exploder, melee based, steady shuffle towards a target before exploding. Explodes on death
*/
/mob/living/simple_animal/hostile/necromorph
	name = "necromorph"
	desc = "A twisted husk of what was once human, repurposed to kill."
	speak_emote = list("roars")
	icon = 'icons/mob/monster_big.dmi'
	icon_state = "nmorph_standard"
	icon_living = "nmorph_standard"
	icon_dead = "nmorph_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "marker"
	speed = 4
	size = SIZE_BIG
	move_to_delay = 4
	canRegenerate = 1
	minRegenTime = 300
	maxRegenTime = 1200

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/necromorph/leaper
	desc = "A twisted husk of what was once human. Sporting razor-sharp fangs, along with a long scythe-tipped tail."
	icon_state = "nmorph_leaper"
	icon_living = "nmorph_leaper"
	icon_dead = "nmorph_leaper_dead"
	speed = 1
	health = 45
	maxHealth = 45

	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "slashes"
	attack_sound = 'sound/weapons/slashmiss.ogg'

	minRegenTime = 240
	maxRegenTime = 600

	ranged = 1
	ranged_cooldown_cap = 8
	ranged_message = "leaps"

/mob/living/simple_animal/hostile/necromorph/leaper/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	if(locked_to)
		return 0

	src.throw_at(get_turf(target),7,1)
	return 1

/mob/living/simple_animal/hostile/necromorph/leaper/Bump(atom/A)
	if(throwing && isliving(A) && CanAttack(A))
		attach(A)
	..()

/mob/living/simple_animal/hostile/necromorph/leaper/Life()

	update_climb()
	if(!isUnconscious())
		if(stance == HOSTILE_STANCE_IDLE && !client)
			var/list/can_see = view(get_turf(src), vision_range/2) //Nothing too close for comfort
			var/all_clear = 1
			for(var/mob/living/L in can_see)
				if(!istype(L, /mob/living/simple_animal/hostile/necromorph) && !(L.isDead()))
					all_clear = 0
			if(!istype(loc, /obj/machinery/atmospherics/unary/vent_pump) && istype(loc, /turf) && all_clear)
				stop_automated_movement = 0

				for(var/obj/machinery/atmospherics/unary/vent_pump/vent in can_see)
					if(Adjacent(vent))
						//Climb in
						visible_message("<span class = 'warning'>\The [src] starts climbing into \the [vent]!</span>")
						forceMove(vent)
						stop_automated_movement = 1
						break
					else
						if(prob(30))
							step_towards(src, vent)//Step towards it
							if(environment_smash)
								EscapeConfinement()
						break

			else if(istype(loc, /obj/machinery/atmospherics/unary/vent_pump) && !all_clear)
				loc.visible_message("<span class = 'warning'>\The [src] clambers out of \the [loc]!</span>")
				forceMove(get_turf(loc))
	..()

/mob/living/simple_animal/hostile/necromorph/leaper/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

/*
/mob/living/simple_animal/hostile/necromorph/leaper/CanAttack(var/atom/the_target)
	to_chat(world, "[src] checking [the_target]")
	if(istype(loc, /obj/machinery/atmospherics/unary/vent_pump/))
		to_chat(world, "[src] looking at [the_target] in [loc]")
		var/dist = get_dist(get_turf(src), the_target)
		if(dist > 3)
			to_chat(world, "Too far away")
			return 0
	return ..(the_target)
*/

/mob/living/simple_animal/hostile/necromorph/leaper/proc/update_climb()
	var/mob/living/L = locked_to

	if(!istype(L))
		return

	if(incapacitated())
		return detach()

	if(!CanAttack(L))
		return detach()

/mob/living/simple_animal/hostile/necromorph/leaper/proc/detach()
	unlock_from()

	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

/mob/living/simple_animal/hostile/necromorph/leaper/proc/attach(mob/living/victim)
	victim.lock_atom(src, /datum/locking_category/)

	victim.visible_message("<span class = 'warning'>\The [src] latches onto \the [victim]!</span>","<span class = 'userdanger'>\The [src] latches onto you!</span>")


	pixel_x = rand(-8,8) * PIXEL_MULTIPLIER
	pixel_y = rand(0,16) * PIXEL_MULTIPLIER

/mob/living/simple_animal/hostile/necromorph/leaper/AttackingTarget()
	.=..()

	if(locked_to == target && isliving(target))
		var/mob/living/L = target

		if(prob(10))
			to_chat(L, "<span class='userdanger'>\The [src] throws you to the ground!</span>")
			L.Knockdown(rand(2,5))

/mob/living/simple_animal/hostile/necromorph/leaper/adjustBruteLoss(amount)
	.=..()

	if(locked_to && prob(amount * 5))
		detach()


/mob/living/simple_animal/hostile/necromorph/exploder
	desc = "A twisted husk of what was once human. A large glowing pustule attached to their left arm."
	icon_state = "nmorph_exploder"
	icon_living = "nmorph_exploder"
	icon_dead = ""
	health = 30
	maxHealth = 30

	speed = 2

/mob/living/simple_animal/hostile/necromorph/exploder/AttackingTarget()
	visible_message("<span class='warning'>\The [src] hits \the [target] with their left arm!</span>")
	Die()

/mob/living/simple_animal/hostile/necromorph/exploder/Die()
	visible_message("<span class='warning'>\The [src] explodes!</span>")
	var/turf/T = get_turf(src)
	new /obj/effect/gibspawner/generic(T)
	explosion(T, -1, 1, 4)
	qdel(src)

/mob/living/simple_animal/hostile/necromorph/puker
	desc = "A twisted, engorged husk of what was once human. It reaks of stomach acid."
	icon_state = "nmorph_puker"
	icon_living = "nmorph_puker"
	icon_dead = "nmorph_puker_dead"

	ranged = 1
	ranged_cooldown_cap = 20
	projectiletype = /obj/item/projectile/puke
	ranged_message = "pukes"

	melee_damage_lower = 10
	melee_damage_upper = 15

/obj/item/projectile/puke
	icon_state = "projectile_puke"

/obj/item/projectile/puke/New()
	..()
	create_reagents(500)
	var/room_remaining = 500
	var/poly_to_add = rand(100,200)
	reagents.add_reagent(PACID, poly_to_add)
	room_remaining -= poly_to_add
	var/sulph_to_add = rand(100,200)
	reagents.add_reagent(SACID, sulph_to_add)
	room_remaining -= sulph_to_add
	reagents.add_reagent(VOMIT, room_remaining)


/obj/item/projectile/puke/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	splash_sub(reagents, atarget, -1)

/obj/item/projectile/puke/process_step()
	..()
	var/turf/simulated/T = get_turf(src)
	if(T) //The first time it runs, it won't work, it'll runtime
		playsound(T, 'sound/effects/splat.ogg', 50, 1)
		T.add_vomit_floor(src, 1, 1, 1)
	sleep(1) //Slow the fuck down, hyperspeed vomit