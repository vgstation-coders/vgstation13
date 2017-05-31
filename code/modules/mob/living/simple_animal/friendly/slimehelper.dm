/mob/living/simple_animal/hostile/helperslime
	name = "Yuu"
	desc = "A cute slime that picks up slime cores"
	icon_state = "helperslime"
	icon_living = "helperslime"
	icon_dead = "helperslime_dead"
	speak_emote = list("goops")
	health = 90
	maxHealth = 90
	attacktext = "glomps"
	response_help  = "hugs"
	response_disarm = "shoos"
	response_harm   = "slaps"
	can_butcher = 0
	meat_type = null
	wander = 1
	move_to_delay = 10
	environment_smash = 0
	faction = list("neutral","slimesummon")
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	stop_automated_movement_when_pulled = 1
	size = SIZE_BIG
	wanted_objects = list(/obj/item/slime_extract)
	var/obj/item/weapon/storage/bag/slime/B

/mob/living/simple_animal/hostile/helperslime/CanAttack(atom/new_target)
	if(istype(new_target, /obj/item/slime_extract))
		return 1
	else
		return 0
/obj/item/weapon/storage/bag/slime
	name = "slime bag"
	desc = "If you can see this this means something messed up"
	storage_slots = 25
	can_only_hold = list("/obj/item/slime_extract")


/mob/living/simple_animal/hostile/helperslime/New()
	B = new/obj/item/weapon/storage/bag/slime

/mob/living/simple_animal/hostile/helperslime/AttackingTarget()
	for(var/mob/M in view(src))
		if(CanAttack(M))
		...

	if(istype(target,/obj/item/slime_extract))
		B.attackby(target,src)
	else
		return