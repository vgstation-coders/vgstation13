/datum/locking_category/frog_climb

/mob/living/simple_animal/hostile/frog
	name = "legionnaire frog"
	desc = "A cat-sized carnivorous monster with vigorous limbs, resembling a frog through both its appearance and its ability to leap. It kills its prey (often much larger than itself) by grabbing onto them and violently beating them."

	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"

	health = 30
	maxHealth = 30

	speak_chance = 1
	emote_hear = list("croaks")
	emote_see = list("looks around")

	ranged = 1
	ranged_cooldown_cap = 8
	ranged_message = "leaps"

	move_to_delay = 6
	speed = 2

	harm_intent_damage = 6
	melee_damage_lower = 1
	melee_damage_upper = 10
	attacktext = "bashes"
	attack_sound = "punch"

	size = SIZE_SMALL

/mob/living/simple_animal/hostile/frog/Shoot()
	if(locked_to) //Don't leap if already on top of a mob
		return 0

	src.throw_at(get_turf(target), 7, 1)
	return 1

/mob/living/simple_animal/hostile/frog/Bump(atom/A)
	if(throwing && isliving(A) && CanAttack(A)) //Hit somebody when flying
		attach(A)

	.=..()

/mob/living/simple_animal/hostile/frog/Life()
	.=..()

	update_climb()

/mob/living/simple_animal/hostile/frog/proc/update_climb()
	var/mob/living/L = locked_to

	if(!istype(L))
		return

	if(incapacitated())
		return detach()

	if(!CanAttack(L))
		return detach()

/mob/living/simple_animal/hostile/frog/proc/detach()
	unlock_from()

	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

/mob/living/simple_animal/hostile/frog/proc/attach(mob/living/victim)
	victim.lock_atom(src, /datum/locking_category/frog_climb)

	to_chat(victim, "<span class='danger'>\The [src] climbs on top of you!</span>")

	pixel_x = rand(-8,8)
	pixel_y = rand(-8,8)

/mob/living/simple_animal/hostile/frog/AttackingTarget()
	.=..()

	if(locked_to == target && isliving(target))
		var/mob/living/L = target

		if(prob(10))
			to_chat(L, "<span class='userdanger'>\The [src] throws you to the ground!</span>")
			L.Weaken(rand(2,5))

/mob/living/simple_animal/hostile/frog/adjustBruteLoss(amount)
	.=..()

	if(locked_to && prob(amount * 5))
		detach()
