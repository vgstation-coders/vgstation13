/mob/living/simple_animal/hostile/skeletonjack
	name = "skeleton jack"
	desc = "This one isn't king of the pumpkin patch."
	icon = 'icons/obj/candybucket.dmi'
	icon_state = "skeleton_jack"
	mob_property_flags = MOB_UNDEAD | MOB_SUPERNATURAL
	environment_smash_flags = SMASH_LIGHT_STRUCTURES
	supernatural = 1
	health = 30	//It's a bunch of bones glued to a pumpkin
	maxHealth = 30
	melee_damage_lower = 10
	melee_damage_upper = 15
	var/obj/structure/candybucket/candy_jack/ourBucket = null

	blooded = FALSE

/mob/living/simple_animal/hostile/skeletonjack/proc/candyEnhance(var/candyAmount)
	maxHealth += candyAmount //A bunch of bones glued to a pumpkin powered by halloween energy
	health = maxHealth


/mob/living/simple_animal/hostile/skeletonjack/spook(mob/dead/observer/ghost)
	maxHealth++
	health = min(health + 15, maxHealth)
	src.visible_message("<span class='danger'>\The [src] gives off a spooky glow!</span>")


/mob/living/simple_animal/hostile/skeletonjack/death(var/gibbed = FALSE)
	..(gibbed)
	if(ourBucket)
		ourBucket.forceMove(loc)
	else
		new /obj/item/clothing/head/pumpkinhead(src.loc)
	qdel(src)

/mob/living/simple_animal/hostile/skeletonjack/Destroy()
	..()
	ourBucket = null
