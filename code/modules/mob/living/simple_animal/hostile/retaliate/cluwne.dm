#define CLOWN_STANCE_IDLE 1
#define CLOWN_STANCE_ATTACK 2
#define CLOWN_STANCE_ATTACKING 3

// <3 goons.  I don't love your forums pricey admittance fee, but I love you.
/mob/living/simple_animal/hostile/retaliate/cluwne
	name = "cluwne"
	desc = "This poor creature used to be human.  Before it pissed off the Gods, that is.  Now it is retarded, miserable, and has bikehorns for an arm."
	icon_state = "cluwne"
	icon_living = "cluwne"
	icon_dead = "cluwne_dead"
	icon_gib = "clown_gib"
	speak_chance = 50
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("HONK", "Honk!", "PLEASE KILL ME")
	speak_emote = list("squeals", "cries","sobs")
	emote_see = list("honks sadly")
	speak_chance = 1
	a_intent = I_HELP
	var/footstep=0 // For clownshoe noises
	//deny_client_move=1 // HONK // Doesn't work right yet

	stop_automated_movement_when_pulled = 1
	maxHealth = 30
	health = 30
	speed = 11

	var/brain_op_stage = 0.0 // Faking it

	harm_intent_damage = 1
	melee_damage_lower = 0
	melee_damage_upper = 0.1
	attacktext = "honks at"
	attack_sound = 'sound/items/bikehorn.ogg'

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

	disabilities=EPILEPSY|COUGHING
	mutations = list(M_CLUMSY)

	var/datum/speech_filter/filter

/mob/living/simple_animal/hostile/retaliate/cluwne/New()
	..()
	// Set up wordfilter
	filter = new
	filter.addPickReplacement("\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger|security|shitcurity)",
	list(
		"honker",
		"fun police",
		"unfun",
	))
	// HELP THEY'RE KILLING ME
	// FINALLY THEY'RE TICKLING ME
	var/tickle_prefixes="\\b(kill+|murder|beat|wound|hurt|harm)"
	filter.addReplacement("[tickle_prefixes]ing","tickling")
	filter.addReplacement("[tickle_prefixes]ed", "tickled")
	filter.addReplacement(tickle_prefixes,       "tickle")

	filter.addReplacement("h\[aei\]lp\\s+me","end my show")
	filter.addReplacement("h\[aei\]lp\\s+him","end his show")
	filter.addReplacement("h\[aei\]lp\\s+her","end her show")
	filter.addReplacement("h\[aei\]lp\\s+them","end their show")
	filter.addReplacement("h\[aei\]lp\\s+(\[^\\s\]+)","end $1's show")
	filter.addReplacement("^h\[aei\]lp.*","END THE SHOW")

/*
	var/stance = CLOWN_STANCE_IDLE	//Used to determine behavior
	var/mob/living/target_mob

/mob/living/simple_animal/hostile/retaliate/cluwne/Life()
	if(timestopped)
		return 0 //under effects of time magick
	if(client || stat || stat==DEAD)
		return //Lets not force players or dead/incap cluwnes to move
	..()
	if(!stat && !resting && !locked_to)
		if(health > maxHealth)
			health = maxHealth
		if(health <= 0)
			stat=DEAD


		if(!ckey && !stop_automated_movement)
			if(isturf(src.loc) && !resting && !locked_to && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
				turns_since_move++
				if(turns_since_move >= turns_per_move)
					if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
						Move(get_step(src,pick(cardinal)))
						turns_since_move = 0

		if(!stat)
			switch(stance)
				if(CLOWN_STANCE_IDLE)
					if (src.hostile == 0)
						return
					for(var/atom/A in view(7,src))
						if(iscluwne(A))
							continue

						if(isliving(A))
							var/mob/living/L = A
							if(!L.stat)
								stance = CLOWN_STANCE_ATTACK
								target_mob = L
								break

						if(istype(A, /obj/mecha))
							var/obj/mecha/M = A
							if (M.occupant)
								stance = CLOWN_STANCE_ATTACK
								target_mob = M
								break
					if (target_mob)
						emote("honks menacingly at [target_mob]")

				if(CLOWN_STANCE_ATTACK)	//This one should only be active for one tick
					stop_automated_movement = 1
					if(!target_mob || SA_attackable(target_mob))
						stance = CLOWN_STANCE_IDLE
					if(target_mob in view(7,src))
						walk_to(src, target_mob, 1, 3)
						stance = CLOWN_STANCE_ATTACKING

				if(CLOWN_STANCE_ATTACKING)
					stop_automated_movement = 1
					if(!target_mob || SA_attackable(target_mob))
						stance = CLOWN_STANCE_IDLE
						target_mob = null
						return
					if(!(target_mob in view(7,src)))
						stance = CLOWN_STANCE_IDLE
						target_mob = null
						return
					if(get_dist(src, target_mob) <= 1)	//Attacking
						if(isliving(target_mob))
							var/mob/living/L = target_mob
							L.attack_animal(src)
							if(prob(10))
								L.Knockdown(5)
								L.visible_message("<span class='danger'>\the [src] slips \the [L]!</span>")
							for(var/mob/H in viewers(src, null))
								if(istype(H, /mob/living/simple_animal/clown))
									var/mob/living/simple_animal/clown/C = H
									C.hostile = 1
						if(istype(target_mob,/obj/mecha))
							var/obj/mecha/M = target_mob
							M.attack_animal(src)
							for(var/mob/H in viewers(src, null))
								if(istype(H, /mob/living/simple_animal/clown))
									var/mob/living/simple_animal/clown/C = H
									C.hostile = 1

/mob/living/simple_animal/hostile/retaliate/cluwne/bullet_act(var/obj/item/projectile/Proj)
	..()
	hostile = 1
	for(var/mob/M in viewers(src, null))
		if(istype(M, /mob/living/simple_animal/hostile/retaliate/cluwne))
			var/mob/living/simple_animal/hostile/retaliate/cluwne/C = M
			C.hostile = 1
	return 0


/*
/mob/living/simple_animal/hostile/retaliate/cluwne/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/hostile/retaliate/cluwne))
			var/mob/living/simple_animal/hostile/retaliate/cluwne/C = Z
			C.hostile = 1
	return 0
*/

/mob/living/simple_animal/hostile/retaliate/cluwne/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/hostile/retaliate/cluwne))
			var/mob/living/simple_animal/hostile/retaliate/cluwne/C = Z
			C.hostile = 1
	return 0

/mob/living/simple_animal/hostile/retaliate/cluwne/attack_hand(mob/living/carbon/human/M as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/hostile/retaliate/cluwne))
			var/mob/living/simple_animal/hostile/retaliate/cluwne/C = Z
			C.hostile = 1
	return 0

/mob/living/simple_animal/hostile/retaliate/cluwne/proc/alertMode()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/hostile/retaliate/cluwne))
			var/mob/living/simple_animal/hostile/retaliate/cluwne/C = Z
			C.hostile = 1

/mob/living/simple_animal/hostile/retaliate/cluwne/attack_animal(mob/living/simple_animal/M as mob)
	alertMode()
	if(M.melee_damage_upper <= 0)
		M.emote("[M.friendly] \the <EM>[src]</EM>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		health -= damage
/*
/mob/living/simple_animal/hostile/retaliate/cluwne/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	alertMode()
	if(M.melee_damage_upper <= 0)
		M.emote("[M.friendly] \the <EM>[src]</EM>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		health -= damage
*/
*/
/mob/living/simple_animal/hostile/retaliate/cluwne/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(10))
			L.Knockdown(5)
			L.visible_message("<span class='danger'>\The [src.name] slips \the [L.name]!</span>")
			return
	return ..()

/mob/living/simple_animal/hostile/retaliate/cluwne/attackby(var/obj/item/O as obj, var/mob/user as mob)
	//only knowledge can kill a cluwne
	if(istype(O,/obj/item/weapon/book))
		gib()
		return
	/*if(O.force)
		Retaliate() //alertMode()
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		health -= damage
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("<span class='danger'>[src] has been attacked with the [O] by [user].</span>")
	*/

/mob/living/simple_animal/hostile/retaliate/cluwne/to_bump(atom/movable/AM as mob|obj)
	if(now_pushing)
		return
	if(ismob(AM))
		var/mob/M = AM
		to_chat(src, "<span class='danger'>You are too depressed to push [M] out of \the way.</span>")
		M.LAssailant = src
		return
	..()

/mob/living/simple_animal/hostile/retaliate/cluwne/say(var/message)
	message = filter.FilterSpeech(lowertext(message))
	var/list/temp_message = splittext(message, " ") //List each word in the message
	// Stolen from peirrot's throat
	for(var/i=1, (i <= temp_message.len), i++) //Loop for each stage of the disease or until we run out of words
		if(prob(50)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
			temp_message[i] = "HONK"
	message = uppertext(jointext(temp_message, " "))
	return ..(message)

/mob/living/simple_animal/hostile/retaliate/cluwne/Die()
	..()
	walk(src, 0)

/mob/living/simple_animal/hostile/retaliate/cluwne/proc/handle_disabilities()
	if ((prob(5) && paralysis < 10))
		to_chat(src, "<span class='warning'>You have a seizure!</span>")
		Paralyse(10)

/mob/living/simple_animal/hostile/retaliate/cluwne/emote(var/act, var/type, var/message, var/auto)
	if(timestopped)
		return //under effects of time magick

	var/msg = pick("quietly sobs into a dirty handkerchief","cries into [gender==MALE?"his":"her"] hands","bawls like a cow")
	msg = "<B>[src]</B> [msg]"
	return ..(msg)

/mob/living/simple_animal/hostile/retaliate/cluwne/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..(NewLoc, Dir, step_x, step_y)

	if(.)
		if(m_intent == "run")
			if(footstep > 1)
				footstep = 0
				playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
			else
				footstep++
		else
			playsound(src, "clownstep", 20, 1)

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin
	name = "clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose!"
	icon_state = "ClownGoblin"
	icon_living = "ClownGoblin"
	icon_dead = null
	response_help = "honks the"
	speak = list("Honk!")
	speak_emote = list("sqeaks")
	emote_see = list("honks")
	maxHealth = 100
	health = 100
	size = 1

	speed = 1
	turns_per_move = 1

	melee_damage_type = "BRAIN"

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pen)) //Renaming
		var/n_name = copytext(sanitize(input(user, "What would you like to name this clown goblin?", "Clown Goblin Name", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	..()

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/Die()
	..()
	new /obj/item/clothing/mask/gas/clown_hat(src.loc)
	new /obj/item/clothing/shoes/clown_shoes(src.loc)
	qdel(src)
