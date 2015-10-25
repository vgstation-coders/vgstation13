/mob/living/simple_animal/hostile/retaliate/genie
	name = "genie"
	desc = "A floating humanoid with transparent blue skin."

	icon_state = "genie"
	icon_living = "genie"
	icon_dead = null
	icon_gib = null

	turns_per_move = 10
	flying = 1
	response_help = "thinks better of touching"
	response_disarm = "attempts to push"
	response_harm = "punches"

	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	environment_smash = 0

	maxHealth = 100
	health = 100
	speed = -1
	harm_intent_damage = 2

	melee_damage_lower = 7
	melee_damage_upper = 14
	attacktext = "drains the life from" //Like shades

	attack_sound = 'sound/effects/ghost2.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	cold_damage_per_tick = 0
	heat_damage_per_tick = 0 //Not affected by atmos at all

	supernatural = 1

	unsuitable_atoms_damage = 0

/mob/living/simple_animal/hostile/retaliate/genie/New()
	.=..()

	src.add_spell(new /spell/targeted/ethereal_jaunt/genie, "const_spell_ready")
	src.add_spell(new /spell/aoe_turf/smoke, "const_spell_ready")
	src.add_spell(new /spell/aoe_turf/conjure/conjure_item/genie, "const_spell_ready")

/mob/living/simple_animal/hostile/retaliate/genie/Die()
	..()
	dust()

/mob/living/simple_animal/hostile/retaliate/genie/Process_Spacemove() //Magic, ain't gonna explain shit
	return 1

/mob/living/simple_animal/hostile/retaliate/genie/adjustBruteLoss(damage)
	damage = 0.5*damage

	..(damage)
