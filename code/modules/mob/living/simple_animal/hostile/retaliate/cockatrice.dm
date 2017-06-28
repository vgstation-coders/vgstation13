//Cockatrice
//Very dangerous chicken-like beast
//Touching it with any exposed part of your body will result in you turning into a statue (only if it's alive!)
//That includes bumping, pulling it, picking it up, having it attack you, etc.
//Dead cockatrices and their meat are fair game

//They can lay eggs when surrounded by statues. The eggs are unsafe to eat, but can be touched just fine

//http://nethack.wikia.com/wiki/Cockatrice for more info

/mob/living/simple_animal/hostile/retaliate/cockatrice
	name = "cockatrice"
	desc = "A large chicken-like creature with a reptile's tail, its body is completely covered by tiny poisonous quills. Merely touching it with unprotected skin is enough to receive the lethal dose of the world's most dangerous venom."

	icon = 'icons/mob/critter.dmi'
	icon_state = "cockatrice"
	icon_living = "cockatrice"
	icon_dead = "cockatrice_dead"

	response_help = "bravely touches"
	response_disarm = "gently pushes aside"
	response_harm = "recklessly punches"

	maxHealth = 60
	health = 60
	size = SIZE_SMALL

	harm_intent_damage = 8
	melee_damage_lower = 8
	melee_damage_upper = 12
	armor_modifier = 4 //High armor modifier - attacks are less likely to pierce armor
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	environment_smash = 0

	species_type = /mob/living/simple_animal/hostile/retaliate/cockatrice
	childtype = /mob/living/simple_animal/hostile/retaliate/cockatrice/chick
	holder_type = null
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/cockatrice

	var/egg_layer = 1

/mob/living/simple_animal/hostile/retaliate/cockatrice/chick
	name = "chickatrice"
	desc = "A young cockatrice. Despite being smaller, it's still capable of petrifying anybody that touches it."
	maxHealth = 25
	health = 25
	size = SIZE_TINY

	icon_state = "chickatrice"
	icon_living = "chickatrice"
	icon_dead = "chickatrice_dead"

	melee_damage_lower = 2
	melee_damage_upper = 4
	attacktext = "pecks"

	egg_layer = 0

/mob/living/simple_animal/hostile/retaliate/cockatrice/New()
	..()
	gender = pick(MALE, FEMALE)
	if(egg_layer && (gender != FEMALE))
		egg_layer = 0

/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/petrify(mob/living/L, instant = 0)
	//Turn the mob into a statue forever
	//Return 1 on success
	//Silicons and other cockatrices unaffected
	if(issilicon(L))
		return 0
	if(istype(L, /mob/living/simple_animal/hostile/retaliate/cockatrice))
		return 0
	if(isDead())
		return

	var/msg = pick("\The [src] hisses!", "\The [src] hisses angrily!")
	visible_message("<span class='danger'>[msg]</span>", "<span class='sinister'>\The [L] touches you!</span>", "<span class='sinister'>You hear an eerie hiss.</span>")

	if(!ishuman(L) || instant)
		to_chat(L, "<span class='userdanger'>You have been turned to stone by \the [src]'s touch.</span>")
		if(!L.turn_into_statue(1)) //Statue forever
			return 0
	else if(ishuman(L))
		var/mob/living/carbon/human/H = L
		for(var/datum/disease/petrification/P in H.viruses) //If already petrifying, speed up the process!
			P.stage = P.max_stages
			P.stage_act()
			return 1

		var/datum/disease/D = new /datum/disease/petrification
		D.holder = H
		D.affected_mob = H
		H.viruses += D

	return 1

/mob/living/simple_animal/hostile/retaliate/cockatrice/attack_hand(mob/living/carbon/human/H)
	.=..()

	if(istype(H))
		var/body_part_to_check = HAND_LEFT
		if(H.active_hand == GRASP_RIGHT_HAND) //No better way to do it!
			body_part_to_check = HAND_RIGHT

		if(!H.check_body_part_coverage(body_part_to_check))
			petrify(H)

/mob/living/simple_animal/hostile/retaliate/cockatrice/unarmed_attacked(mob/living/L)
	.=..()

	//Respond to all unarmed attacks with petrification of the attacker
	petrify(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/bite_act(mob/living/L)
	.=..()

	//Biting petrifies you instantly, while merely touching takes some itme
	petrify(L, 1)

/mob/living/simple_animal/hostile/retaliate/cockatrice/kick_act(mob/living/L)
	.=..()

	if(check_petrify(L, FEET))
		petrify(L)


/mob/living/simple_animal/hostile/retaliate/cockatrice/get_pulled(mob/living/L)
	if(check_petrify(L, HANDS))
		petrify(L)

	return ..()

/mob/living/simple_animal/hostile/retaliate/cockatrice/Life()
	.=..()

	if(isDead())
		return

	if(isliving(pulledby))
		if(check_petrify(pulledby, HANDS))
			if(petrify(pulledby))
				pulledby.stop_pulling()

	if(!stat && egg_layer && prob(1))
		var/statue_amount = 0//Gotta have at least 4 statues around
		for(var/obj/structure/closet/statue/S in oview(5, src))
			statue_amount++

			if(statue_amount >= 4)
				break

		if(statue_amount < 4)
			return

		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")

		var/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice/E = new(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(animal_count[src.species_type] < ANIMAL_CHILD_CAP && prob(10))
			processing_objects.Add(E)

/mob/living/simple_animal/hostile/retaliate/cockatrice/Cross(mob/living/L)
	movement_touch_check(L)

	return ..()

/mob/living/simple_animal/hostile/retaliate/cockatrice/Move()
	.=..()

	for(var/mob/living/L in loc)
		movement_touch_check(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/Bump(mob/living/L)
	spawn()
		movement_touch_check(L)

	return ..()

//Called when the chicken either crosses a body, or a body crosses the chicken
/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/movement_touch_check(mob/living/L)
	if(!istype(L))
		return

	if(L.lying) //If the body is lying, it needs full coverage to not petrify. If it's not lying, only check feet/legs
		if(check_petrify(L, FULL_BODY))
			return petrify(L)
	else if(check_petrify(L, FEET) || check_petrify(L, LEGS))
		return petrify(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/UnarmedAttack(A)
	.=..()

	if(!ishuman(A) && check_petrify(A)) //Humans are handled below in applied_damage()
		petrify(A)

/mob/living/simple_animal/hostile/retaliate/cockatrice/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	set waitfor = 0

	if(armor)
		return
	if(prob(50)) //50% chance of getting stoned if the armor didn't block the attack
		return

	sleep()

	petrify(target)

/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/check_petrify(mob/living/L, bodyparts)
	if(isDead())
		return

	if(ishuman(L))
		var/mob/living/carbon/human/H = L

		if(!H.check_body_part_coverage(bodyparts))
			return 1
	else if(isliving(L))
		return 1
