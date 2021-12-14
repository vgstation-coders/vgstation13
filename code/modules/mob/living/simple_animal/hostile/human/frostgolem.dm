/mob/living/simple_animal/hostile/humanoid/frostgolem
	name = "frost golem"
	desc = "A hulking construct of ice and snow."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "frost_golem"
	speak_chance = 0

	health = 100
	maxHealth = 100

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	melee_damage_lower = 15
	melee_damage_upper = 15

	stat_attack = UNCONSCIOUS
	mob_property_flags = MOB_CONSTRUCT

	faction = "frost"
	corpse = null

	attacktext = "punches"

/mob/living/simple_animal/hostile/humanoid/frostgolem/death(var/gibbed = FALSE)
	visible_message("<span class='danger'>\The [src] crumbles to snow!</span>")
	for(var/i = 1 to rand(1,10))
		new /obj/item/stack/sheet/snow(loc)
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/frostgolem/AttackingTarget()
	target.attack_animal(src)
	if(ismob(target))
		var/mob/M = target
		M.bodytemperature = max(M.bodytemperature-1 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
		to_chat(M, "<span class='danger'>\The [src]'s touch chills you to the bone!</span>")

/mob/living/simple_animal/hostile/humanoid/frostgolem/knight
	name = "frost knight"
	desc = "A hulking construct of ice and snow, armed with a sword and shield."
	icon_state = "frost_knight"

	health = 150
	maxHealth = 150

	melee_damage_lower = 20
	melee_damage_upper = 20

	attacktext = "slashes"

/mob/living/simple_animal/hostile/humanoid/frostgolem/knight/AttackingTarget()
	target.attack_animal(src)
	if(ismob(target))
		var/mob/M = target
		M.bodytemperature = max(M.bodytemperature-2 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
		to_chat(M, "<span class='danger'>\The [src]'s blade freezes you to the core!</span>")

/mob/living/simple_animal/hostile/humanoid/frostgolem/wizard
	name = "frost wizard"
	desc = "A human wizard turned to ice, or a mound of ice given life?"
	icon_state = "frost_wizard"

	health = 75
	maxHealth = 75

	melee_damage_lower = 5
	melee_damage_upper = 5

	attacktext = "swats at"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/cold
	projectilesound = 'sound/weapons/radgun.ogg'
	ranged_message = "fires a freezing bolt"

/mob/living/simple_animal/hostile/humanoid/frostgolem/wizard/Aggro()
	say(pick("Ice to meet you!","Chill out!","Time for the ice to break you!"))
	return ..()