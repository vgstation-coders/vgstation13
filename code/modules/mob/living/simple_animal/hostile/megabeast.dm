/obj/effect/spawner/procedural_mobspawn
	name = "random mob spawner"
	desc = "It spawns a random mob. Notify a coder. Thanks!"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"

/obj/effect/landmark/procedural_mobspawn/forgottenbeast
	name = "forgotten beast spawner"
	desc = "You shouldn't be seeing this"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/mob/living/simple_animal/hostile/mobtype

/obj/effect/landmark/procedural_mobspawn/forgottenbeast/New()
	SpawnMob(mobtype)

/obj/effect/landmark/procedural_mobspawn/forgottenbeast/proc/SpawnMob(mob/living/mobtype)
	var/mob/living/simple_animal/hostile/forgotten_beast/A = new(get_turf(src))
	A.PickMob(mobtype)
	qdel(src)

/datum/procedural_mobspawn

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
	var/radioactive
	var/rad_cooldown = 0
	var/list/appendage_types = list(
		"head",
		"eye",
		"mouth",
		"arm",
		"leg",
		"tail",
		)
	var/list/appendage_modifier = list(
		"gaunt",
		"pale",
		"rusty",
		"molten",
		"scorched",
		"thin",
		"ugly",
		"translucent",
		"warty",
		"mutant",
		"twisted",
		"hairy",
		"feathery",
		"tentacled",
		)

/mob/living/simple_animal/hostile/forgotten_beast/initialize(mob/living/mobtype)
	. = ..()
	PickMob(mobtype)//needs to be fixed

/mob/living/simple_animal/hostile/forgotten_beast/Life()
	..()
	if(!picked)
		PickMob()
		if(!ranged)
			if(prob(50))
				PickProjectile()
	if(radioactive)
		if(world.time > rad_cooldown +20 SECONDS)
			rad_blast()

/mob/living/simple_animal/hostile/forgotten_beast/proc/PickProjectile()
	ranged = TRUE
	var/list/available_projectiles = existing_typesof(/obj/item/projectile)
	projectiletype = pick(available_projectiles)
	for(var/I in restricted_roulette_projectiles)
		if(projectiletype == I)
			PickProjectile()
			return
	for(var/I in restrict_with_subtypes)
		if(ispath(projectiletype, I))
			PickProjectile()
			return
	var/obj/item/projectile/P = projectiletype
	desc += " Beware of its deadly [P.name]s!"

/mob/living/simple_animal/hostile/forgotten_beast/proc/PickMob(mob/living/mobtype)
	picked = TRUE
	mymob = mobtype
	if(!mobtype)
		mob_types = existing_typesof(/mob/living/simple_animal/hostile)
		mymob = pick(mob_types)
	health = clamp((mymob.health * 10), 100, 1000)
	maxHealth = clamp((mymob.maxHealth * 10), 100, 1000)
	desc = "A great [mymob.name]."
	if(prob(90))
		AddFlavorText()
	if(prob(50))
		AddFlavorText(TRUE)
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
	var/matrix/M = matrix()
	M.Scale(1.5,1.5)
	if(prob(33))
		color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	transform = M
	if(prob(10))
		radioactive = TRUE
		desc += " It has a spooky green glow around it!"

/mob/living/simple_animal/hostile/forgotten_beast/proc/AddFlavorText(randompart = FALSE)
	var/modifier = pick(appendage_modifier)
	if(randompart)
		var/appendage = pick(appendage_types)
		appendage_types -= appendage
		var/number = roll(1, 10)
		var/amount = num2text(number)
		desc += " Its [amount] [appendage][number < 1 ? " is" : "s are"] [modifier]."
		return
	desc += " It is [modifier]."

/mob/living/simple_animal/hostile/forgotten_beast/proc/BreathAttack()

/mob/living/simple_animal/hostile/forgotten_beast/proc/GasAttack()

/mob/living/simple_animal/hostile/forgotten_beast/proc/rad_blast()//copied from glowing ones, does not require radiation
	if(prob(30))
		visible_message("<span class = 'blob'>\The [src] glows with a brilliant light!</span>")
	set_light(vision_range/2, vision_range, "#a1d68b")
	spawn(1 SECONDS)
		emitted_harvestable_radiation(get_turf(src), rand(250, 500), range = 7)

	for(var/mob/living/carbon/human/H in view(src, vision_range))
		H.apply_radiation(15, RAD_EXTERNAL)
		rad_cooldown = world.time
		spawn(3 SECONDS)
			set_light(1, 2, "#5dca31")
