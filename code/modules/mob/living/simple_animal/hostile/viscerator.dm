/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE
	health = 15
	maxHealth = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "syndicate"
	can_butcher = 0
	flying = 1

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	size = SIZE_SMALL
	meat_type = null
	held_items = list()
	mob_property_flags = MOB_ROBOTIC

/mob/living/simple_animal/hostile/viscerator/Life()
	..()
	if(stat == CONSCIOUS)
		animate(src, pixel_x = rand(-12,12) * PIXEL_MULTIPLIER, pixel_y = rand(-12,12) * PIXEL_MULTIPLIER, time = 15, easing = SINE_EASING)

/mob/living/simple_animal/hostile/viscerator/death(var/gibbed = FALSE)
	..(TRUE)
	visible_message("<span class='warning'><b>[src]</b> is smashed into pieces!</span>")
	qdel (src)

/mob/living/simple_animal/hostile/viscerator/CanAttack(var/atom/the_target)
	if(ismob(the_target))
		var/mob/mob_target = the_target
		if((isnukeop(mob_target) && faction == "syndicate") || (iswizard(mob_target) && faction == "wizard"))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/viscerator/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover, /mob/living/simple_animal/hostile/viscerator))
		return 1
	if(istype(mover, /obj/item/projectile))
		return prob(66)
	else
		return !density

/mob/living/simple_animal/hostile/viscerator/flying_skull
	name = "flying skull"
	desc = "A human skull levitating in the air."

	icon_state = "flying_skull"

	health = 8
	maxHealth = 8

	melee_damage_lower = 7
	melee_damage_upper = 12
	attack_sound = 'sound/weapons/bite.ogg'
	attacktext = "bites"

	faction = "mummy"
	mob_property_flags = MOB_SUPERNATURAL

/mob/living/simple_animal/hostile/viscerator/flying_skull/AttackingTarget()
	flick("flying_skull_bite", src)

	..()


/mob/living/simple_animal/hostile/viscerator/butterfly
	icon = 'icons/obj/butterfly.dmi'
	icon_state = "knifefly"
	icon_living = "knifefly"
	health = 25
	maxHealth = 25
	melee_damage_lower = 22
	melee_damage_upper = 28
	var/autodie = FALSE //So you can spawn the butterfly by other means and have it not selfdestruct.

/mob/living/simple_animal/hostile/viscerator/butterfly/Life()
	..()
	if(autodie && life_tick > 10)
		death()

/mob/living/simple_animal/hostile/viscerator/butterfly/magic
	name = "crystal butterfly"
	desc = "A magic crystal butterfly with razor sharp wings. This butterfly isn't too friendly."
	icon_state = "crystal_butterfly"
	icon_living = "crystal_butterfly"
	melee_damage_lower = 20
	melee_damage_upper = 25
	faction = "wizard"

/mob/living/simple_animal/hostile/viscerator/butterfly/magic/AttackingTarget()
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjustCloneLoss(rand(5,10)) //scp-553 LORE.
	..()
