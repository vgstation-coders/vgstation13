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
	armor = list(melee = 25, bullet = 55, laser = 60,energy = 25, bomb = 0, bio = 0, rad = 0)
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
	items_to_drop = list(/obj/item/weapon/gun/projectile/pistol)

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
	needs_to_reload = TRUE
	bullets_remaining = 8
	drop_on_reload = /obj/item/ammo_storage/magazine/mc9mm/empty
	var/obj/item/weapon/reagent_containers/spray/chemsprayer/CS
	armor = list(melee = 15, bullet = 35, laser = 45,energy = 35, bomb = 0, bio = 100, rad = 0)

	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "chemsprayer", 'icons/mob/in-hand/left/items_lefthand.dmi' = "gun")

/mob/living/simple_animal/hostile/humanoid/janitor/New()
	..()
	CS = new /obj/item/weapon/reagent_containers/spray/chemsprayer/lube(src)
	CS.reagents.add_reagent(LUBE, 600)

/mob/living/simple_animal/hostile/humanoid/janitor/Aggro()
	..()
	say(pick("Time to take out the trash!","Hope you wiped your feet before you came in.","It's time to take you to the cleaners."))

/mob/living/simple_animal/hostile/humanoid/janitor/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(30) && CS.reagents.has_reagent(LUBE))
		visible_message("<span class = 'warning'>\The [src] lets loose a blast of lubricant from their chemical sprayer!</span>")
		playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
		CS.make_puff(target, user)
	else
		..()

/mob/living/simple_animal/hostile/humanoid/janitor/death(var/gibbed = FALSE)
	CS.forceMove(loc)
	CS = null
	..(gibbed)


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
	needs_to_reload = TRUE
	bullets_remaining = 7
	drop_on_reload = /obj/item/ammo_storage/speedloader/a357/empty
	armor = list(melee = 10, bullet = 20, laser = 25,energy = 15, bomb = 0, bio = 0, rad = 0)
	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "gun")