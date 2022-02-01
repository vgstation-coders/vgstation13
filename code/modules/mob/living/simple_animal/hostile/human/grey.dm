/mob/living/simple_animal/hostile/humanoid/grey
	name = "Grey"
	desc = "A thin alien humanoid. This one seems to be feral."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "grey"
	icon_living = "grey"

	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	corpse = /obj/effect/landmark/corpse/grey

/mob/living/simple_animal/hostile/humanoid/grey/New()
	..()
	languages += all_languages[LANGUAGE_GREY]

/mob/living/simple_animal/hostile/humanoid/grey/space
	name = "Grey Explorer"
	desc = "A thin alien humanoid in a space suit. This one seems to be hostile."

	icon_state = "greyspace"
	icon_living = "greyspace"
	melee_damage_lower = 5
	melee_damage_upper = 8 // Their arms may be noodly and weak, but getting kicked by a steel toed boot hurts!

	stat_attack = UNCONSCIOUS // Grey hostile humanoids are too smart to think that someone is dead just because they fell over

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	corpse = /obj/effect/landmark/corpse/grey/space

	faction = "mothership"

/mob/living/simple_animal/hostile/humanoid/grey/space/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/humanoid/grey/space/melee/toolbox
	name = "Grey Explorer"
	desc = "A thin alien humanoid in a space suit. This one seems to be hostile."

	icon_state = "greyspace_toolbox"
	icon_living = "greyspace_toolbox"
	melee_damage_lower = 12
	melee_damage_upper = 15

	items_to_drop = list(/obj/item/weapon/storage/toolbox/mechanical)

	speak = list("Speak softly, and carry a robust toolbox.","Where did I put that soldering iron?","Mothership guide us...")
	speak_chance = 5

/mob/living/simple_animal/hostile/humanoid/grey/space/melee/toolbox/Aggro()
	..()
	say(pick("I won't allow you to damage mothership equipment!","Time to apply percussive maintenance!"), all_languages[LANGUAGE_GREY])

	attacktext = "batters"
	attack_sound = 'sound/weapons/toolbox.ogg'

/mob/living/simple_animal/hostile/humanoid/grey/space/melee/scalpel
	name = "Grey Explorer"
	desc = "A thin alien humanoid in a space suit. This one seems to be hostile."

	icon_state = "greyspace_scalpel"
	icon_living = "greyspace_scalpel"
	melee_damage_lower = 15
	melee_damage_upper = 18

	items_to_drop = list(/obj/item/tool/scalpel)

	speak = list("I need a new specimen to dissect.","A dissection is all I need... just one more dissection.","Praise the mothership.")
	speak_chance = 5

/mob/living/simple_animal/hostile/humanoid/grey/space/melee/scalpel/Aggro()
	..()
	say(pick("I need your organs for testing!","You'll make a fine specimen for an operation!"), all_languages[LANGUAGE_GREY])

	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'

/mob/living/simple_animal/hostile/humanoid/grey/space/ranged
	name = "Grey Explorer"
	desc = "A thin alien humanoid in a space suit. This one seems to be hostile."

	icon_state = "greyspace_laser"
	icon_living = "greyspace_laser"

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator)

	speak = list("Set disintegrators to scorch, medium well.","Praise the mothership, and all hail the Chairman.","Disintegrate all unidentified targets.")
	speak_chance = 5

/mob/living/simple_animal/hostile/humanoid/grey/space/ranged/Aggro()
	..()
	say(pick("Intruder!","You will be disintegrated!"), all_languages[LANGUAGE_GREY])

	projectilesound = 'sound/weapons/ray1.ogg'
	ranged = 1
	retreat_distance = 3
	minimum_distance = 3
	projectiletype = /obj/item/projectile/beam/scorchray
