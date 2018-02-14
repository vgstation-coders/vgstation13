/mob/living/simple_animal/hostile/humanoid/surgeon/
	name = "\improper Surgeon"
	desc = "Don't interfere with his work!"
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "surgeon"
	icon_living = "surgeon"
	maxHealth = 100
	health = 100

	speed = 1
	harm_intent_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 13
	attacktext = "saws"
	attack_sound = 'sound/weapons/circsawhit.ogg'

	ranged = 0
	gender = MALE

	//corpse = /obj/effect/landmark/corpse/surgeon
	items_to_drop = list(/obj/item/weapon/circular_saw/plasmasaw)

/mob/living/simple_animal/hostile/humanoid/surgeon/normal
	name = "Doctor Sawyer"
	desc = "A deranged surgeon lost deep in space."
	icon_dead = null //this isn't even his final form
	maxHealth = 200
	health = 200

	speed = 1
	harm_intent_damage = 20
	melee_damage_lower = 17
	melee_damage_upper = 23

	corpse = null //he isn't dead yet

	faction = "skeleton" //don't want him to get killed by skeletons before his transformation

/mob/living/simple_animal/hostile/humanoid/surgeon/normal/Die()
	src.say("[pick("YOU CAN'T KILL ME THAT EASILY!", "I WONT LET YOU STOP ME!", "GET OUT OF MY FACILITY!", "I MUST CONTINUE MY RESEARCH!", "I'M GONNA WRECK IT!", "I'VE GOT A BONE TO PICK WITH YOU!")]")
	var/obj/effect/effect/smoke/S = new /obj/effect/effect/smoke(get_turf(src))
	to_chat("<span class=danger><B>Before he can die, the mad surgeon takes a drink of a foul-smelling concoction and begins to mutate! </span></B>")
	S.time_to_live = 20
	src.

	..()
	return qdel(src)

/mob/living/simple_animal/hostile/humanoid/surgeon/skeleton
	name = "Skeletal Strongman"
	desc = "He wont be pushed around any longer"
	//icon_state = "skeletonboss"
	//icon_living = "skeletonboss"
	maxHealth = 1000
	health = 1000

	speed = 5
	harm_intent_damage = 40
	melee_damage_lower = 35
	melee_damage_upper = 45
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	attacktext = "crushes"
	attack_sound = 'sound/weapons/heavysmash.ogg'

	//corpse = /obj/effect/landmark/corpse/surgeon/skeleton

	faction = "skeleton"
	items_to_drop = list()

