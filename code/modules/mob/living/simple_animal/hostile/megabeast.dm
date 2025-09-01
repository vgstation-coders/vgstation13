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
	var/special_cooldown
	var/breath_string
	var/breath_damage = 10
	var/breath_damage_type = BRUTE
	var/breath_list = list(
		"burning plasma" = BURN,//VIOLET
		"scorching ray" = BURN,//NULL)
		"acidic spray" = TOXIN,//ORANGE
		"toxic breath" = TOXIN,//YELLOW
		"dust cloud" = BRUTE,//GREY
		)
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
		"mutated",
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
			if(prob(30))
				PickProjectile()
			else
				PickBreath()
	if(radioactive)
		if(world.time > rad_cooldown +20 SECONDS)
			rad_blast()

/mob/living/simple_animal/hostile/forgotten_beast/OpenFire(target)
	if(!breath_string)
		return ..()
	if(prob(70))
		BreathAttack(target)
		return
	if(!projectiletype)
		return
	..()


/mob/living/simple_animal/hostile/forgotten_beast/proc/PickProjectile()
	ranged = TRUE
	var/list/available_projectiles = existing_typesof(/obj/item/projectile) - restricted_roulette_projectiles
	for(var/type in restricted_with_subtypes)
		for(var/subtype in subtypesof(type))
			available_projectiles -= subtype
		available_projectiles -= type
	var/obj/item/projectile/P = pick(available_projectiles)
	desc += " Beware of its deadly [P.name]s!"

/mob/living/simple_animal/hostile/forgotten_beast/proc/PickBreath()
	ranged = TRUE
	var/breath_type = pick(breath_list)
	breath_string = breath_type[1]
	breath_damage_type = breath_type[2]
	desc += " Beware its deadly [breath_type]!"

/mob/living/simple_animal/hostile/forgotten_beast/proc/PickMob(mob/living/mobtype)
	picked = TRUE
	mymob = mobtype
	if(!mobtype)
		mob_types = existing_typesof(/mob/living/simple_animal/hostile)
		mymob = pick(mob_types)
	health = clamp((mymob.health * 10), 100, 1000)
	maxHealth = clamp((mymob.maxHealth * 10), 100, 1000)
	GenerateDesc()
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
	breath_damage = clamp(rand(30), 10, 30)
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

/mob/living/simple_animal/hostile/forgotten_beast/proc/GenerateDesc()//can be done much better
	var/list/mydesc = list(
		"A great [mymob.name].",
		"An abominable [mymob.name].",
		"An enormous [mymob.name].",
		)
	desc = pick(mydesc)

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

/mob/living/simple_animal/hostile/forgotten_beast/proc/BreathAttack(atom/A = target)
	if(!world.time > (special_cooldown + 10 SECONDS))
		return
	var/obj/item/projectile/fire_breath/mybreath = new()
	mybreath.fire_damage = 0
	switch(breath_damage_type)
		if(BURN)
			mybreath.fire_damage = breath_damage
		if(BRUTE)
			mybreath.damage = breath_damage
		if(TOXIN)
			mybreath.damage = breath_damage//todo: make this actually toxins
	generic_projectile_fire(get_ranged_target_turf(src, dir, 10), src, mybreath, 'sound/weapons/flamethrower.ogg', src)
	special_cooldown = world.time

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
