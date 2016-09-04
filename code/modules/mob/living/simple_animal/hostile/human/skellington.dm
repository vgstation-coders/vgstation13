/mob/living/simple_animal/hostile/humanoid/skellington
	name = "skellington"
	desc = "A skeleton, held together by scraps of skin and muscle. It sppears to be feral."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "skellington"

	corpse = /obj/effect/landmark/corpse/skellington

	melee_damage_lower = 2
	melee_damage_upper = 5
	attacktext = "punches"

	maxHealth = 50
	health = 50

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

/mob/living/simple_animal/hostile/humanoid/skellington/corsaire
	name = "skellington corsaire"
	desc = "A skellington dressed in pirate garb and wielding a blade."

	icon_state = "corsaire"

	faction = "pirate"

	attack_sound = 'sound/weapons/bloodyslice.ogg'
	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "slashes"

	corpse = /obj/effect/landmark/corpse/skellington/corsaire
	items_to_drop = list(/obj/item/weapon/sword)

/mob/living/simple_animal/hostile/humanoid/skellington/cannoneer //o shit
	name = "skellington cannoneer"
	desc = "A skellington pirate experienced in using a laser cannon."

	icon_state = "cannoneer"

	faction = "pirate"

	projectiletype = /obj/item/projectile/beam/heavylaser
	projectilesound = 'sound/weapons/lasercannonfire.ogg'

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_cap = 4

	melee_damage_lower = 2
	melee_damage_upper = 7
	attacktext = "kicks"

	corpse = /obj/effect/landmark/corpse/skellington/cannoneer
	items_to_drop = list(/obj/item/weapon/gun/energy/lasercannon/empty)

//Skellington petards
//Explode on attack or death
//Thankfully they're pretty slow

/mob/living/simple_animal/hostile/humanoid/skellington/petard
	name = "skellington petard"
	desc = "A skeleton carrying a bunch of bombs. Highly explosive."

	icon_state = "petard"
	speed = 8

	faction = "pirate"
	attacktext = "blows up"

	corpse = /obj/effect/landmark/corpse/skellington/petard

/mob/living/simple_animal/hostile/humanoid/skellington/petard/AttackingTarget()
	Die()

/mob/living/simple_animal/hostile/humanoid/skellington/petard/Die()
	var/turf/T = get_turf(src)

	..()

	explosion(T, -1, 1, 2)

/obj/effect/landmark/corpse/skellington
	name = "skellington"
	mutantrace = "Skellington"

/obj/effect/landmark/corpse/skellington/corsaire
	name = "skellington corsaire"
	corpseuniform = /obj/item/clothing/under/blackpants
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsehelmet = /obj/item/clothing/head/helmet/space/pirate
	corpsegloves = /obj/item/clothing/gloves/black
	corpseglasses = /obj/item/clothing/glasses/eyepatch

/obj/effect/landmark/corpse/skellington/cannoneer
	name = "skellington cannoneer"
	corpseuniform = /obj/item/clothing/under/blackpants
	corpsesuit = /obj/item/clothing/suit/hgpirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsehelmet = /obj/item/clothing/head/helmet/space/pirate
	corpsegloves = /obj/item/clothing/gloves/black

/obj/effect/landmark/corpse/skellington/petard
	name = "skellington petard"
	corpseuniform = /obj/item/clothing/under/redpants
	corpsesuit = /obj/item/clothing/suit/suspenders
	corpsemask = /obj/item/clothing/mask/scarf/red
	corpsehelmet = /obj/item/clothing/head/bandana
