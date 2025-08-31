/mob/living/simple_animal/hostile/forgotten_beast//randomly generated
	name = "Forgotten Beast"
	desc = "Some indescribable horror."
	health = 1000
	maxHealth = 1000
	icon = 'icons/mob/animal.dmi'
	icon_state = "otherthing"
	icon_dead = "otherthing-dead"
	faction = "megabeast"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	size = SIZE_BIG
	a_intent = I_HURT
	var/picked
	var/mob/living/simple_animal/hostile/mymob
	var/list/mob_types
	var/list/breath_types = list()
	var/list/gas_types = list()
	var/appendage_string
	var/threat_string

/mob/living/simple_animal/hostile/forgotten_beast/initialize(mob/living/mobtype)
	. = ..()
	PickMob(mobtype)//doesn't work

/mob/living/simple_animal/hostile/forgotten_beast/Life()
	..()
	if(!picked)
		PickMob()
		if(!ranged)
			if(prob(50))
				ranged = TRUE
				var/list/available_projectiles = existing_typesof(/obj/item/projectile)
				projectiletype = pick(available_projectiles)
				var/obj/item/projectile/P = projectiletype
				desc += " Beware of its deadly [P.name]s!"


/mob/living/simple_animal/hostile/forgotten_beast/proc/PickMob(mob/living/mobtype)
	picked = TRUE
	mymob = mobtype
	if(!mobtype)
		mob_types = existing_typesof(/mob/living/simple_animal/hostile)
		mymob = pick(mob_types)
//	new mymob(get_turf(src))
	health = clamp((mymob.health * 10), 100, 1000)
	maxHealth = clamp((mymob.maxHealth * 10), 100, 1000)
	desc = "A great [mymob.name]."
	icon = mymob.icon
	icon_state = mymob.icon_state
	icon_dead = mymob.icon_dead
	pixel_x = mymob.pixel_x
	pixel_y = mymob.pixel_y
	melee_damage_lower = clamp((mymob.melee_damage_lower * 2), 15, 60)
	melee_damage_upper = clamp((mymob.melee_damage_upper * 2), 35, 80)
	if(mymob.ranged)
		ranged = TRUE
		rapid = mymob.rapid
		projectiletype =  mymob.projectiletype
		var/obj/item/projectile/P = projectiletype
		desc += " Beware of its deadly [P.name]s!"
	move_to_delay = mymob.move_to_delay
//	qdel(mymob)
	var/matrix/M = matrix()
	M.Scale(1.5,1.5)
	if(prob(33))
		color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	transform = M

/mob/living/simple_animal/hostile/forgotten_beast/proc/BreathAttack()

/mob/living/simple_animal/hostile/forgotten_beast/proc/GasAttack()
