/mob/living/simple_animal/hostile/humanoid/surgeon/
	name = "\improper Surgeon"
	desc = "Don't interfere with his work!"
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "surgeon"
	icon_living = "surgeon"
	maxHealth = 100
	health = 100

	harm_intent_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 13
	attacktext = "saws"
	attack_sound = 'sound/weapons/circsawhit.ogg'

	ranged = 0
	gender = MALE

	corpse = /obj/effect/landmark/corpse/surgeon
	items_to_drop = list(/obj/item/weapon/circular_saw/plasmasaw)

/mob/living/simple_animal/hostile/humanoid/surgeon/boss
	name = "Doctor Peter Holden"
	desc = "A deranged surgeon lost deep in space."
	icon_dead = null //this isn't even his final form
	maxHealth = 150
	health = 150
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH|UNPACIFIABLE

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	harm_intent_damage = 15
	melee_damage_lower = 13
	melee_damage_upper = 20

	corpse = null //he isn't dead yet

	faction = "necro" //don't want him to get killed by skeletons before his transformation

/mob/living/simple_animal/hostile/humanoid/surgeon/boss/death(var/gibbed = FALSE)
	visible_message("<span class=danger><B>Before he can die, the mad surgeon takes a drink of a foul-smelling concoction and begins to mutate! </span></B>")
	say("[pick("YOU CAN'T KILL ME THAT EASILY!", "I WONT LET YOU STOP ME!", "GET OUT OF MY FACILITY!", "I MUST CONTINUE MY RESEARCH!", "I'M GONNA WRECK IT!", "I'VE GOT A BONE TO PICK WITH YOU!")]")
	var/obj/effect/effect/smoke/S = new /obj/effect/effect/smoke(get_turf(src))
	S.time_to_live = 20
	new /mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/(get_turf(src))
	..(gibbed)


/mob/living/simple_animal/hostile/humanoid/surgeon/skeleton
	name = "\improper Skeletal Surgeon"
	desc = "He won't be pushed around any longer"
	icon = 'icons/mob/surgeon.dmi'
	icon_state = "skelesurgeon"
	icon_living = "skelesurgeon"
	icon_dying = "skelesurgeon_death"
	icon_dying_time = 33
	maxHealth = 400
	health = 400
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH|UNPACIFIABLE

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	move_to_delay = 5 //slow
	harm_intent_damage = 30
	melee_damage_lower = 25
	melee_damage_upper = 35
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS //he will smash through most barriers, but the walls of his vault are rwalls
	attacktext = "crushes"
	attack_sound = 'sound/weapons/heavysmash.ogg'

	corpse = /obj/effect/decal/remains/skelesurgeon

	faction = "necro"
	mob_property_flags = MOB_UNDEAD
	items_to_drop = list(/obj/structure/closet/crate/medical/surgeonloot)

/mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/New()
	..()
	flick("skelesurgeon_laugh", src)



/mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/morph //morph mask version
	name = "\improper Skeletal giant"
	desc = "A giant and imposing skeleton"
	icon_state = "skelegiant"
	icon_living = "skelegiant"
	icon_dying = "skelegiant_death"
	maxHealth = 250
	health = 250
	speed = 4

	harm_intent_damage = 25
	melee_damage_lower = 20
	melee_damage_upper = 30

	items_to_drop = null //no fancy drops

/mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/morph/New()
	..()
	flick("skelegiant_laugh", src)
