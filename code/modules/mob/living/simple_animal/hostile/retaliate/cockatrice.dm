//Cockatrice
//Very dangerous beast the size of a chicken
//Touching it with any exposed part of your body will result in you turning into a statue
//That includes bumping, pulling it, picking it up, having it attack you, stepping on its corpse without shoes, etc.

//http://nethack.wikia.com/wiki/Cockatrice for more info

/mob/living/simple_animal/hostile/retaliate/cockatrice
	name = "cockatrice"
	desc = "A bizarre creature that looks like a tiny chicken with a snake's tail and a long, sharp beak. Any living being that touches it immediately turns into solid stone. Thankfully, it's relatively docile until something provokes it."

	icon = 'icons/mob/critter.dmi'
	icon_state = "cockatrice"
	icon_living = "cockatrice"
	icon_dead = "cockatrice_dead"

	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	maxHealth = 50
	health = 50
	size = SIZE_TINY

	harm_intent_damage = 8
	melee_damage_lower = 2
	melee_damage_upper = 6
	armor_modifier = 60 //Very high armor modifier - attacks stopped by any armor/hardsuit
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	environment_smash = 0

	holder_type = /obj/item/weapon/holder/animal/cockatrice

	meat_type = null
	can_butcher = 0

/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/sting(mob/living/L, instant = 0)
	//Turn the mob into a statue forever
	//Return 1 on success
	//Silicons and other cockatrices unaffected
	if(issilicon(L))
		return 0
	if(istype(L, /mob/living/simple_animal/hostile/retaliate/cockatrice))
		return 0

	if(!isDead() && prob(80))
		var/msg = pick("\The [src] hisses!", "\The [src] hisses angrily!")
		visible_message("<span class='danger'>[msg]</span>", "<span class='notice'>\The [L] touches you!</span>", "<span class='notice'>You hear an angry hiss.</span>")

	to_chat(L, "<span class='userdanger'>You have been turned to stone by \the [src]'s touch.</span>")
	L.turn_into_statue(1) //Statue forever

	return 1

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_hand(mob/living/carbon/human/H)
	.=..()

	if(istype(H))
		var/body_part_to_check = HAND_LEFT
		if(H.active_hand == GRASP_RIGHT_HAND) //No better way to do it!
			body_part_to_check = HAND_RIGHT

		var/datum/organ/external/OE = H.find_organ_by_grasp_index(H.active_hand)
		if(!OE.is_organic()) //Touching with a peg/robohand is fine!
			return

		if(!H.check_body_part_coverage(body_part_to_check))
			sting(H)

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_slime(mob/living/L)
	.=..()

	sting(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_paw(mob/living/L)
	.=..()

	sting(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_animal(mob/living/L)
	.=..()

	sting(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_alien(mob/living/L)
	.=..()

	sting(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_larva(mob/living/L)
	.=..()

	sting(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/bite_act(mob/living/L)
	.=..()

	sting(L, 1) //Instant stonefying in this case

/mob/living/simple_animal/hostile/retaliate/cockatrice/kick_act(mob/living/L)
	.=..()

	if(check_sting(L, FEET))
		sting(L)


/mob/living/simple_animal/hostile/retaliate/cockatrice/get_pulled(mob/living/L)
	if(check_sting(L, HANDS))
		sting(L)

	return ..()

/mob/living/simple_animal/hostile/retaliate/cockatrice/Life()
	.=..()

	if(isliving(pulledby))
		if(check_sting(pulledby, HANDS))
			if(sting(pulledby))
				pulledby.stop_pulling()

/mob/living/simple_animal/hostile/retaliate/cockatrice/Cross(mob/living/L)
	.=..()

	movement_touch_check(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/Move()
	.=..()

	for(var/mob/living/L in loc)
		movement_touch_check(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/Bump(mob/living/L)
	.=..()

	movement_touch_check(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/movement_touch_check(mob/living/L)
	if(!istype(L))
		return

	if(L.lying) //If the chicken steps onto a lying body, check if it's covered completely. If it's not lying, only check feet/legs
		if(check_sting(L, FULL_BODY))
			sting(L)
	else if(check_sting(L, FEET) || (!isDead() && check_sting(L, LEGS))) //Check leg coverage only if the chicken is alive (as it can brush against our legs)
		sting(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/UnarmedAttack(A)
	.=..()

	if(!ishuman(A) && check_sting(A)) //Humans are handled below in applied_damage()
		sting(A)

/mob/living/simple_animal/hostile/retaliate/cockatrice/applied_damage(mob/victim, amount, organ, armor)
	if(armor)
		return
	if(prob(50)) //50% chance of getting stoned if the armor didn't block the attack
		return

	spawn()
		sting(victim)

/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/check_sting(mob/living/L, bodyparts)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L

		if(!H.check_body_part_coverage(bodyparts))
			return 1
	else if(isliving(L))
		return 1
