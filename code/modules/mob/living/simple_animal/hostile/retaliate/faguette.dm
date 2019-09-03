// templated off of cluwne, as this is basically the same thing.

/mob/living/simple_animal/hostile/retaliate/faguette
	name = "faguette"
	desc = "This sad, pitiful creature is all that remains of what used to be a human, cursed by the Gods to aimlessly roam with its mouth and fingers sewn shut, and it’s left arm transformed into a perfectly baked baguette."
	icon_state = "faguette"
	icon_living = "faguette"
	icon_dead = "faguette_dead"

	speak_chance = 50
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speak_emote = list("acts out a scream", "silently cries","silenty sobs",)
	emote_hear = list("shuffles silently")
	speak_chance = 1
	a_intent = I_HELP

	stop_automated_movement_when_pulled = 1
	maxHealth = 30
	health = 30
	speed = 11

	var/brain_op_stage = 0.0 // Faking it

	harm_intent_damage = 1
	melee_damage_lower = 0
	melee_damage_upper = 0.1
	attacktext = "attacks"
	attack_sound = 'sound/weapons/genhit1.ogg'

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atoms_damage = 10

	disabilities=EPILEPSY|MUTE
	mutations = list(M_CLUMSY)


/mob/living/simple_animal/hostile/retaliate/faguette/to_bump(atom/movable/AM as mob|obj)
	if(now_pushing)
		return
	if(ismob(AM))
		var/mob/M = AM
		to_chat(src, "<span class='danger'>You are too depressed to push [M] out of \the way.</span>")
		M.LAssailant = src
		return
	..()


/mob/living/simple_animal/hostile/retaliate/faguette/proc/handle_disabilities()
	if ((prob(5) && paralysis < 10))
		to_chat(src, "<span class='warning'>You have a seizure!</span>")
		Paralyse(10)

/mob/living/simple_animal/hostile/retaliate/faguette/emote(var/act, var/type, var/message, var/auto)
	if(timestopped)
		return //under effects of time magick

	var/msg = pick("drools through its stitched mouth","silently cries into its baguette","sloppily mimes tieing an invisible noose around its neck")
	return ..("me", type, "[msg].")
