//mob/living/simple_animal/hostile/humanoid/surgeon/
//	name = "\improper Surgeon"
//	desc = "Don't interfere with his work!"
//	icon = 'icons/mob/hostile_humanoid.dmi'
//	icon_state = "surgeon"
//	icon_living = "surgeon"
//	maxHealth = 100
//	health = 100

//	harm_intent_damage = 10
//	melee_damage_lower = 8
//	melee_damage_upper = 13
//	attacktext = "saws"
//	attack_sound = 'sound/weapons/circsawhit.ogg'

//	ranged = 0
//	gender = MALE

//	corpse = /obj/effect/landmark/corpse/surgeon
//	items_to_drop = list(/obj/item/weapon/circular_saw/plasmasaw)

//mob/living/simple_animal/hostile/humanoid/surgeon/boss
//	name = "Doctor Placeholder" //I can't think of a good name
//	desc = "A deranged surgeon lost deep in space."
//	icon_dead = null //this isn't even his final form
//	maxHealth = 80
//	health = 80

//	harm_intent_damage = 15
//	melee_damage_lower = 13
//	melee_damage_upper = 20

//	corpse = null //he isn't dead yet

//	faction = "necro" //don't want him to get killed by skeletons before his transformation

//mob/living/simple_animal/hostile/humanoid/surgeon/boss/death(var/gibbed = FALSE)
//	..(gibbed)
//	visible_message("<span class=danger><B>Before he can die, the mad surgeon takes a drink of a foul-smelling concoction and begins to mutate! </span></B>")
//	say("[pick("YOU CAN'T KILL ME THAT EASILY!", "I WONT LET YOU STOP ME!", "GET OUT OF MY FACILITY!", "I MUST CONTINUE MY RESEARCH!", "I'M GONNA WRECK IT!", "I'VE GOT A BONE TO PICK WITH YOU!")]")
//	var/obj/effect/effect/smoke/S = new /obj/effect/effect/smoke(get_turf(src))
//	S.time_to_live = 20
//	new /mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/(get_turf(src))
//	..()
//	return qdel(src)

//mob/living/simple_animal/hostile/humanoid/surgeon/skeleton
//	name = "\improper Skeletal Surgeon"
//	desc = "He wont be pushed around any longer"
//	icon = 'icons/mob/surgeon.dmi'
//	icon_state = "skelesurgeon"
//	icon_living = "skelesurgeon"
//	maxHealth = 400
//	health = 400

//	move_to_delay = 5 //slow
//	harm_intent_damage = 30
//	melee_damage_lower = 25
//	melee_damage_upper = 35
//	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS //he will smash through most barriers, but the walls of his vault are rwalls
//	attacktext = "crushes"
//	attack_sound = 'sound/weapons/heavysmash.ogg'

//	corpse = /obj/effect/landmark/corpse/surgeon/skeleton

//	faction = "necro"
//	mob_property_flags = MOB_UNDEAD
//	items_to_drop = list()

//mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/New()
//	..()
//	flick("skelesurgeon_laugh", src)
