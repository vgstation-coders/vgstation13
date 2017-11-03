/mob/living/simple_animal/hostile/humanoid/chef
	name = "chef"
	desc = "A disgruntled culinary chef, brandishing a gatling gun and a backpack of freshly cooked pies."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "chef"
	corpse = /obj/effect/landmark/corpse/chef
	items_to_drop = list(/obj/item/weapon/gun/gatling, /obj/item/weapon/reagent_containers/food/snacks/pie/acid_filled)
	faction = "syndicate"

	maxHealth = 200
	health = 200

	speak = list("You'll look good with some fava beans and onions!","The bullets are just extra seasoning!","Try some pie!")
	speak_chance = 15

	environment_smash_flags = 0
	ranged = 1
	rapid = 1
	minimum_distance = 3
	projectiletype = /obj/item/projectile/bullet/gatling
	projectilesound = 'sound/weapons/gatling_fire.ogg'
	casingtype = /obj/item/ammo_casing_gatling
	ranged_cooldown_cap = 15

	visible_items = list('icons/mob/in-hand/right/guns_experimental.dmi' = "minigun1", 'icons/mob/in-hand/left/food.dmi' = "pie")

/mob/living/simple_animal/hostile/humanoid/chef/Aggro()
	..()
	say(pick("Fresh meat","Get the hell out of my kitchen!","Another one for the chopping board!"))

/mob/living/simple_animal/hostile/humanoid/chef/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(30))
		visible_message("<span class = 'warning'>\The [src] throws a pie towards \the [target]!</span>")
		var/atom/movable/pie_to_throw = new /obj/item/weapon/reagent_containers/food/snacks/pie/acid_filled(get_turf(src))
		pie_to_throw.throw_at(target,10,25)
	else
		..()


/mob/living/simple_animal/hostile/humanoid/janitor
	name = "janitor"
	desc = "An artisan of the cleaning arts, ready to make a mess."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "janitor"

	corpse = /obj/effect/landmark/corpse/janitor/chempack
	items_to_drop = list(/obj/item/weapon/gun/projectile/pistol, /obj/item/weapon/reagent_containers/spray/chemsprayer/lube)

	speak = list("Clean up on aisle 3","You're getting the floor dirty!","Watch your step!")
	speak_chance = 15
	faction = "syndicate"

	environment_smash_flags = 0
	ranged = 1
	minimum_distance = 3
	projectiletype = /obj/item/projectile/bullet/midbullet2
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	casingtype = /obj/item/ammo_casing/c9mm
	ranged_cooldown_cap = 15
	var/bullets_remaining = 8

	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "chemsprayer", 'icons/mob/in-hand/left/items_lefthand.dmi' = "gun")

/mob/living/simple_animal/hostile/humanoid/janitor/Aggro()
	..()
	say(pick("Time to take out the trash!","Hope you wiped your feet before you came in.","It's time to take you to the cleaners."))

/mob/living/simple_animal/hostile/humanoid/janitor/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(30))
		visible_message("<span class = 'warning'>\The [src] lets loose a blast of lubricant from their chemical sprayer!</span>")
		playsound(get_turf(src), 'sound/effects/spray2.ogg', 50, 1, -6)
		//Copypasted from the chem-sprayer make_puff()
		var/Sprays[3]

		for (var/i = 1, i <= 3, i++)
			if (src.reagents.total_volume < 1)
				break

			var/obj/effect/decal/chemical_puff/D = getFromPool(/obj/effect/decal/chemical_puff, get_turf(src), "#009CA8", 50)
			D.reagents.add_reagent(LUBE, rand(15,50))
			Sprays[i] = D

		// Move the puffs towards the target
		var/direction = get_dir(src, target)
		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T, turn(direction, 90))
		var/turf/T2 = get_step(T, turn(direction, -90))
		var/list/the_targets = list(T, T1, T2)

		for (var/i = 1, i <= Sprays.len, i++)
			spawn()
				var/obj/effect/decal/chemical_puff/D = Sprays[i]
				if (!D)
					continue

				// Spreads the sprays a little bit
				var/turf/my_target = pick(the_targets)
				the_targets -= my_target

				for (var/j = 1, j <= rand(6, 8), j++)
					step_towards(D, my_target)
					D.react(iteration_delay = 0)
					sleep(2)

				returnToPool(D)
	else
		if(bullets_remaining)
			bullets_remaining--
			..()
		else
			if(canmove)
				visible_message("<span class = 'warning'>\The [src] stops to reload!</span>")
				playsound(user, 'sound/weapons/magdrop_1.ogg', 100, 1)
				new /obj/item/ammo_storage/magazine/mc9mm/empty(get_turf(src))
				canmove = FALSE
				spawn(rand(30,60))
					visible_message("<span class = 'warning'>\The [src] reloads!</span>")
					canmove = TRUE
					bullets_remaining = initial(bullets_remaining)


/mob/living/simple_animal/hostile/humanoid/pilot
	name = "pilot"
	desc = "Ready to fly at a moments notice."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "pilot"

	corpse = /obj/effect/landmark/corpse/pilot
	items_to_drop = list(/obj/item/weapon/gun/projectile)

	faction = "syndicate"

	environment_smash_flags = 0
	ranged = 1
	minimum_distance = 3
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	casingtype = /obj/item/ammo_casing/a357
	ranged_cooldown_cap = 15
	var/bullets_remaining = 7

	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "gun")

/mob/living/simple_animal/hostile/humanoid/pilot/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(bullets_remaining)
		bullets_remaining--
		..()
	else
		if(canmove)
			visible_message("<span class = 'warning'>\The [src] stops to reload!</span>")
			playsound(user, 'sound/weapons/magdrop_1.ogg', 100, 1)
			canmove = FALSE
			spawn(rand(30,60))
				new /obj/item/ammo_storage/speedloader/a357/empty(get_turf(src))
				visible_message("<span class = 'warning'>\The [src] reloads!</span>")
				canmove = TRUE
				bullets_remaining = initial(bullets_remaining)