// templated off of cluwne, as this is basically the same thing.

/mob/living/simple_animal/hostile/retaliate/faguette
	name = "faguette"
	desc = "This sad, pitiful creature is all that remains of what used to be a human, cursed by the Gods to aimlessly roam with its mouth and fingers sewn shut, and it's left arm transformed into a perfectly baked baguette."
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
	meat_type = null

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
	unsuitable_atmos_damage = 10

	disabilities=EPILEPSY|MUTE
	mutations = list(M_CLUMSY)


/mob/living/simple_animal/hostile/retaliate/faguette/to_bump(atom/movable/AM as mob|obj)
	if(now_pushing)
		return
	if(ismob(AM))
		var/mob/M = AM
		to_chat(src, "<span class='danger'>You are too depressed to push [M] out of the way.</span>")
		M.LAssailant = src
		M.assaulted_by(src)
		return
	..()

/mob/living/simple_animal/hostile/retaliate/faguette/attackby(obj/item/weapon/O, mob/user)
	if(istype(O,/obj/item/weapon/book))
		gib()

/mob/living/simple_animal/hostile/retaliate/faguette/proc/handle_disabilities()
	if ((prob(5) && paralysis < 10))
		to_chat(src, "<span class='warning'>You have a seizure!</span>")
		Paralyse(10)

/mob/living/simple_animal/hostile/retaliate/faguette/emote(act, m_type = null, message = null, ignore_status = FALSE, arguments)
	if(timestopped)
		return //under effects of time magick

	var/msg = pick("drools slightly","mimes crying into a tissue","sloppily mimes tying an invisible noose")
	return ..("me", type, "[msg].")

/mob/living/simple_animal/hostile/retaliate/faguette/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(10))
			L.silent += 3
			L.visible_message("<span class='danger'>\The [src.name] silences \the [L.name]!</span>")
			return
	return ..()


/mob/living/simple_animal/hostile/retaliate/faguette/goblin
	name = "mime goblin"
	desc = "A tiny walking beret and gloves. Is it miming for a baguette?"
	icon_state = "MimeGoblin"
	icon_living = "MimeGoblin"
	icon_dead = null
	response_help = "pats the"
	maxHealth = 100
	health = 100
	size = 1
	environment_smash_flags = SMASH_LIGHT_STRUCTURES
	var/footstep = 0 //for slapping
	speed = 1
	turns_per_move = 1

	melee_damage_type = "BRAIN"

/mob/living/simple_animal/hostile/retaliate/faguette/goblin/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pen)) //Renaming
		var/n_name = copytext(sanitize(input(user, "What would you like to name this mime goblin?", "Mime Goblin Name", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	..()

/mob/living/simple_animal/hostile/retaliate/faguette/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(10))
			L.visible_message("<span class='danger'>\The [src.name] mimes an invisible wall!</span>")
			var/obj/effect/forcefield/mime/wall = new(get_turf(src))
			spawn(300)
			if(wall)
				qdel(wall)
	return ..()
/mob/living/simple_animal/hostile/retaliate/faguette/goblin/say()
	return

/mob/living/simple_animal/hostile/retaliate/faguette/goblin/death(var/gibbed = FALSE)
	..(TRUE)
	new /obj/item/clothing/head/beret(src.loc)
	new /obj/item/clothing/gloves/white(src.loc)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/faguette/goblin/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	. = ..()

	if(.)
		if(m_intent == "run")
			if(footstep > 1)
				footstep = 0
				playsound(src, "slap", 50, 1)
			else
				footstep++
		else
			playsound(src, "slap", 20, 1)
