/mob/living/simple_animal/hostile/humanoid/wizard
	name = "wizard"
	desc = "An elite troop of the Wizard Federation, trained in casting fireball and teleport."
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = null //The corpse disappears!
	speak_chance = 2

	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "punches"

	corpse = null
	items_to_drop = list()

	ranged = 1
	ranged_message = null
	ranged_cooldown_cap = 5
	retreat_distance = 6
	minimum_distance = 6
	projectiletype = /obj/item/projectile/simple_fireball
	gender = MALE

	faction = "wizard"

	var/speak_when_spawned = TRUE
	var/incantation = "ONI SOMA"

/mob/living/simple_animal/hostile/humanoid/wizard/New()
	..()

	name = "[pick(wizard_first)] [pick(wizard_second)]"
	if(speak_when_spawned)
		speak = list("Your souls shall suffer!", "No mortals shall be spared.", "My magic will tear you apart!", "Prepare to face the almighty [name]!")

/mob/living/simple_animal/hostile/humanoid/wizard/death(var/gibbed = FALSE)
	src.say("SCYAR NILA [pick("AI UPLOAD", "SECURE ARMORY", "BAR", "PRIMARY TOOL STORAGE", "INCINERATOR", "CHAPEL", "FORE STARBOARD MAINTENANCE", "WIZARD FEDERATION")]")
	var/obj/effect/effect/smoke/S = new /obj/effect/effect/smoke(get_turf(src))
	S.time_to_live = 20 //2 seconds instead of full 10

	..(TRUE)
	qdel(src)

/mob/living/simple_animal/hostile/humanoid/wizard/OpenFire()
	src.say(incantation)
	..()

/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger
	speak_when_spawned = FALSE
	projectiletype = /obj/item/projectile/spell_projectile/seeking/magic_missile/indiscriminate
	incantation = "FORTI GY AMA"
	ranged_cooldown_cap = 2
	retreat_distance = 5
	minimum_distance = 5
	attack_sound = "punch"
	var/mob/creator
	var/spell/spell

/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/New()
	..()
	var/spell/S = new /spell/targeted/projectile/magic_missile/spare_stunned
	spell = S
	add_spell(S, src)

/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/Destroy()
	spell = null
	var/mob/my_wiz = doppelgangers[src]
	doppelgangers_count_by_wizards[my_wiz]--
	doppelgangers[src] = null
	doppelgangers -= src
	..()

/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/create_projectile(var/mob/user)
	var/obj/item/projectile/spell_projectile/S = ..()
	S.carried = spell
	return S

/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/ListTargets()
	var/list/L = ..()
	for(var/mob/M in L)
		if(doppelgangers[src] == M)
			L.Remove(M)
	return L

/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/melee
	ranged = FALSE
	retreat_distance = 0
	minimum_distance = 1