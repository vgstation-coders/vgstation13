/obj/effect/landmark/procedural_mobspawn/forgottenbeast
	name = "forgotten beast spawner"
	desc = "You shouldn't be seeing this"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/mob/living/simple_animal/hostile/mobtype

/obj/effect/landmark/procedural_mobspawn/forgottenbeast/New()
	SpawnMob(mobtype)

/obj/effect/landmark/procedural_mobspawn/forgottenbeast/proc/SpawnMob()
	new /mob/living/simple_animal/hostile/forgotten_beast(get_turf(src), new /datum/procedural_mobspawn(mobtype))
	qdel(src)

/*
//Megabeast Template
//Basic beast template.
//Arguments: loc for spawn location
//(optional) add_template for a pre-chosen procgen datum to template off of. If none is provided, it will pick one at random from the existing list. If none exist, it will make one.
//
//refer to procedural_mobspawn for the datums
*/
/mob/living/simple_animal/hostile/forgotten_beast
	name = "Forgotten Beast"
	desc = "Some indescribable horror."
	health = 1000
	maxHealth = 1000
	icon = 'icons/mob/animal.dmi'
	icon_state = "otherthing"
	icon_dead = "otherthing-dead"
	attack_sound = 'sound/weapons/heavysmash.ogg'
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
	size = SIZE_HUGE
	a_intent = I_HURT
	var/picked
	var/mob/living/simple_animal/hostile/mymob
	var/list/mob_types
	var/list/breath_types = list()
	var/datum/reagent/vapors
	var/radioactive
	var/pulse_cooldown = 0
	var/special_cooldown
	var/breath_damage = 10
	var/breath_damage_type = BRUTE
	var/datum/custom_breath/mybreath
	var/datum/procedural_mobspawn/template
	var/obj/loot
	var/loot_count

/mob/living/simple_animal/hostile/forgotten_beast/Life()
	..()
	if(radioactive)
		if(world.time > pulse_cooldown +20 SECONDS)
			rad_blast()
	if(vapors)
		if(world.time > pulse_cooldown +60 SECONDS)
			GasAttack()

/mob/living/simple_animal/hostile/forgotten_beast/death(var/gibbed = FALSE)
	if(!gibbed)
		gib()
		return
	for(var/i = loot_count; i > 0)
		new loot(get_turf(src))
		--i
	gibs(loc)
	..()

/mob/living/simple_animal/hostile/forgotten_beast/OpenFire(target)
	if(!mybreath)
		return ..()
	if(prob(70))
		BreathAttack(target)
		return
	if(!projectiletype)
		return
	..()

/mob/living/simple_animal/hostile/forgotten_beast/New(loc, var/datum/procedural_mobspawn/add_template)
	appearance_flags |= PIXEL_SCALE
	if(!add_template) //no template provided
		if(!procgen_mob_datums.len) //if no pre-generated templates available...
			add_template = new /datum/procedural_mobspawn/ //generating a new one will add it to the list automatically
		else
			add_template = pick(procgen_mob_datums)
	template = add_template
	meat_type = pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))

	name = template.name
	health = template.health
	maxHealth = template.maxHealth
	desc = template.desc
	icon = template.icon
	icon_state = template.icon_state
	icon_dead = template.icon_dead
	pixel_x = template.pixel_x
	pixel_y = template.pixel_y
	melee_damage_lower = template.melee_damage_lower
	melee_damage_upper = template.melee_damage_upper
	mybreath = template.mybreath
	ranged = template.ranged
	rapid = template.rapid
	projectiletype = template.projectiletype
	move_to_delay = template.move_to_delay
	color = template.color
	transform = template.size_matrix
	radioactive = template.radioactive
	vapors = template.vapors
	loot = template.randomloot[1]
	loot_count = template.randomloot[2]
	..()

/mob/living/simple_animal/hostile/forgotten_beast/proc/BreathAttack(atom/A = target)
	if(world.time < (special_cooldown + 10 SECONDS))
		return
	var/obj/item/projectile/custom_breath/thebreath = new /obj/item/projectile/custom_breath(src)
	thebreath.name = mybreath.name//find a better way to do this
	thebreath.damage = mybreath.damage
	thebreath.color = mybreath.color
	thebreath.damage_type = mybreath.damage_type
	thebreath.pressure = mybreath.pressure
	thebreath.temperature = mybreath.temperature
	thebreath.special = mybreath.special
	thebreath.reagent_type = mybreath.reagent_type
	generic_projectile_fire(get_ranged_target_turf(src, dir, 10), src, thebreath, 'sound/weapons/flamethrower.ogg', src)
	special_cooldown = world.time

/mob/living/simple_animal/hostile/forgotten_beast/proc/GasAttack()
	playsound(get_turf(src), 'sound/effects/smoke.ogg', 50, FALSE, 8)
	// Create the reagents to put into the air
	reagents.add_reagent(vapors.id, 100)
	var/datum/chemical_reaction/chemsmoke/CS = new()
	CS.on_reaction(src.reagents)
	pulse_cooldown = world.time

/mob/living/simple_animal/hostile/forgotten_beast/proc/rad_blast()//copied from glowing ones, does not require radiation
	if(prob(30))
		visible_message("<span class = 'blob'>\The [src] glows with a brilliant light!</span>")
	set_light(vision_range/2, vision_range, "#a1d68b")
	spawn(1 SECONDS)
		emitted_harvestable_radiation(get_turf(src), rand(250, 500), range = 7)

	for(var/mob/living/carbon/human/H in view(src, vision_range))
		H.apply_radiation(15, RAD_EXTERNAL)
		pulse_cooldown = world.time
		spawn(3 SECONDS)
			set_light(1, 2, "#5dca31")
