//Cockatrice
//Touching it with any exposed part of your body will result in you turning into a statue (only if it's alive!)
//That includes bumping, pulling it, picking it up, having it attack you, etc.
//Meat & eggs contain petritricin, a venom that petrifies you after a short delay (countered by acid)

//They can lay eggs when surrounded by statues. The eggs are safe to eat, but will hatch into just as dangerous chickatrices

/mob/living/simple_animal/hostile/retaliate/cockatrice
	name = "cockatrice"
	desc = "A chicken-like beast with a reptile's tail, its body is completely covered by tiny poisonous quills. Any living tissue that comes directly into contact with this creature will die in a matter of seconds."

	icon = 'icons/mob/critter.dmi'
	icon_state = "cockatrice"
	icon_living = "cockatrice"
	icon_dead = "cockatrice_dead"

	response_help = "bravely touches"
	response_disarm = "gently pushes aside"
	response_harm = "recklessly punches"

	maxHealth = 55
	health = 55
	size = SIZE_SMALL
	mob_property_flags = MOB_NO_PETRIFY

	harm_intent_damage = 8
	melee_damage_lower = 8
	melee_damage_upper = 12
	armor_modifier = 4 //High armor modifier - attacks are less likely to pierce armor
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	move_to_delay = 3

	environment_smash_flags = 0

	species_type = /mob/living/simple_animal/hostile/retaliate/cockatrice
	childtype = /mob/living/simple_animal/hostile/retaliate/cockatrice/chick
	holder_type = null
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/cockatrice

	var/egg_layer = 1

/mob/living/simple_animal/hostile/retaliate/cockatrice/chick
	name = "chickatrice"
	desc = "The offspring of a cockatrice, this young animal can be described as a chicken with a lizard's tail. Its body is covered by poisonous quills that will rapidly destroy any living tissue they come into direct contact with."
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
	if(gender == NEUTER)
		gender = pick(MALE, FEMALE)

	//There are differences between genders!

	//Females can lay eggs
	//Males have better combat stats: 12-16dmg (as opposed to 8-12), 70hp (as opposed to 55) and faster movement speed
	if(gender == MALE)
		egg_layer = 0
		melee_damage_lower += 4
		melee_damage_upper += 4
		health += 15
		maxHealth += 15
		move_to_delay -= 1

/mob/living/simple_animal/hostile/retaliate/cockatrice/proc/petrify(mob/living/L, instant = 0)
	//Turn the mob into a statue forever
	//Return 1 on success
	//Silicons and other cockatrices unaffected
	if(issilicon(L) || (L.mob_property_flags & MOB_NO_PETRIFY))
		return 0
	if(isDead())
		return

	if(!ishuman(L) || instant)
		if(!L.turn_into_statue(1)) //Statue forever
			return 0

		to_chat(L, "<span class='userdanger'>You have been turned to stone by \the [src]'s touch.</span>")
		add_logs(src, L, "instantly petrified", admin = L.ckey ? TRUE : FALSE)

	else if(ishuman(L))
		var/mob/living/carbon/human/H = L

		add_logs(src, L, "petrified", admin = L.ckey ? TRUE : FALSE)

		var/found_virus = FALSE
		for(var/datum/disease/petrification/P in H.viruses) //If already petrifying, speed up the process!
			P.stage = P.max_stages
			P.stage_act()
			found_virus = TRUE
			break

		if(!found_virus)
			var/datum/disease/D = new /datum/disease/petrification
			D.holder = H
			D.affected_mob = H
			H.viruses += D

	var/msg = pick("\The [src] hisses at [L]!", "\The [src] hisses angrily at [L]!")
	visible_message("<span class='userdanger'>[msg]</span>", "<span class='notice'>You touch [L].</span>", "<span class='sinister'>You hear an eerie hiss.</span>")

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
	//Humans are already handled in attack_hand
	if(!ishuman(L))
		petrify(L)

/mob/living/simple_animal/hostile/retaliate/cockatrice/bite_act(mob/living/L)
	.=..()

	//Biting petrifies you instantly
	petrify(L, 1)

/mob/living/simple_animal/hostile/retaliate/cockatrice/kick_act(mob/living/L)
	.=..()

	if(check_petrify(L, FEET))
		petrify(L)


/mob/living/simple_animal/hostile/retaliate/cockatrice/on_pull_start(mob/living/L)
	if(check_petrify(L, HANDS))
		petrify(L)

	return ..()

/mob/living/simple_animal/hostile/retaliate/cockatrice/Life()
	.=..()

	if(isDead())
		return

	//Whoever is pulling us is at risk of petrification
	if(isliving(pulledby))
		if(check_petrify(pulledby, HANDS))
			if(petrify(pulledby))
				pulledby.stop_pulling()

	if(!isUnconscious() && egg_layer && prob(2))
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
		if(animal_count[src.species_type] < ANIMAL_CHILD_CAP && prob(50))
			processing_objects.Add(E)

/mob/living/simple_animal/hostile/retaliate/cockatrice/Cross(mob/living/L)
	movement_touch_check(L)

	return ..()

/mob/living/simple_animal/hostile/retaliate/cockatrice/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
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
