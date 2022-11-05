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
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speak = list("HONK", "Honk!", "PLEASE KILL ME")
	speak_emote = list("squeals", "cries","sobs")
	emote_hear = list("honks sadly")
	speak_chance = 1
	a_intent = I_HELP
	var/footstep=0 // For clownshoe noises
	//deny_client_move=1 // HONK // Doesn't work right yet

	meat_type = null

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
	unsuitable_atmos_damage = 10

	disabilities=EPILEPSY|COUGHING
	mutations = list(M_CLUMSY)

	var/datum/speech_filter/speech_filter
	var/bookgib = 1

/mob/living/simple_animal/hostile/retaliate/cluwne/New()
	..()
	// Set up wordfilter
	speech_filter = new /datum/speech_filter/cluwne

/mob/living/simple_animal/hostile/retaliate/cluwne/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(10))
			L.Knockdown(5)
			L.Stun(5)
			L.visible_message("<span class='danger'>\The [src.name] slips \the [L.name]!</span>")
			return
	return ..()

/mob/living/simple_animal/hostile/retaliate/cluwne/get_butchering_products()
	return list(/datum/butchering_product/teeth/bunch)

/mob/living/simple_animal/hostile/retaliate/cluwne/attackby(var/obj/item/O as obj, var/mob/user as mob)
	var/currenthealth = health
	..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
	health = currenthealth
	//only knowledge can kill a cluwne
	if(istype(O,/obj/item/weapon/book)&&(bookgib))
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
		to_chat(src, "<span class='danger'>You are too depressed to push [M] out of the way.</span>")
		M.LAssailant = src
		M.assaulted_by(src)
		return
	..()

/mob/living/simple_animal/hostile/retaliate/cluwne/say(var/message)
	message = speech_filter.FilterSpeech(lowertext(message))
	var/list/temp_message = splittext(message, " ") //List each word in the message
	// Stolen from peirrot's throat
	for(var/i=1, (i <= temp_message.len), i++) //Loop for each stage of the disease or until we run out of words
		if(prob(50)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
			temp_message[i] = "HONK"
	message = uppertext(jointext(temp_message, " "))
	return ..(message)

/mob/living/simple_animal/hostile/retaliate/cluwne/proc/handle_disabilities()
	if ((prob(5) && paralysis < 10))
		to_chat(src, "<span class='warning'>You have a seizure!</span>")
		Paralyse(10)

/mob/living/simple_animal/hostile/retaliate/cluwne/emote(act, m_type = null, message = null, ignore_status = FALSE, arguments)
	if(timestopped)
		return //under effects of time magick

	var/msg = pick("quietly sobs into a dirty handkerchief","cries into [gender==MALE?"his":"her"] hands","bawls like a cow")
	return ..("me", type, "[msg].")

/mob/living/simple_animal/hostile/retaliate/cluwne/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	. = ..()

	if(.)
		if(m_intent == "run")
			if(footstep > 1)
				footstep = 0
				playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
			else
				footstep++
		else
			playsound(src, "clownstep", 20, 1)

/mob/living/simple_animal/hostile/retaliate/cluwne/death(var/gibbed = FALSE)
	..(gibbed)
	if(client && iscluwnebanned(src))
		to_chat(src, "<big><span class='danger'>You have died, and will not be able to rejoin the game until the next round.</span><big>")
		sleep(1)
		del(client)

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin
	name = "clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose!"
	icon_state = "ClownGoblin"
	icon_living = "ClownGoblin"
	icon_dead = null
	response_help = "honks the"
	speak = list("Honk!")
	speak_emote = list("squeaks")
	emote_hear = list("honks")
	maxHealth = 100
	health = 100
	size = 1
	environment_smash_flags = SMASH_LIGHT_STRUCTURES

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

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/death(var/gibbed = FALSE)
	..(TRUE)
	new /obj/item/clothing/mask/gas/clown_hat(src.loc)
	new /obj/item/clothing/shoes/clown_shoes(src.loc)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin
	name = "psychedelic clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose and cover your eyes!"
	icon_state = "ClownPsychedelicGoblin"
	icon_living = "ClownPsychedelicGoblin"
	icon_dead = null
	response_help = "honks the"
	speak = list("Honk!", "Groovy!", "Far Out!")
	speak_emote = list("squeaks")

	emote_hear = list("honks")
	maxHealth = 100
	health = 100
	size = 1
	environment_smash_flags = SMASH_LIGHT_STRUCTURES

	speed = 1
	turns_per_move = 1

	melee_damage_type = "BRAIN"
	var/spacedrugs_chance = 30

/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pen)) //Renaming
		var/n_name = copytext(sanitize(input(user, "What would you like to name this psychedelic clown goblin?", "Clown Goblin Name", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	..()

/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin/AttackingTarget()
	..()
	var/mob/living/L = target
	if(L.reagents)
		if(prob(spacedrugs_chance))
			visible_message("<b><span class='warning'>[src] injects something into [L]!</span>")
			L.reagents.add_reagent(SPACE_DRUGS, 1)

/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin/death(var/gibbed = FALSE)
	..(TRUE)
	new /obj/item/clothing/mask/gas/clownmaskpsyche(src.loc)
	new /obj/item/clothing/shoes/clownshoespsyche(src.loc)
	qdel(src)


/mob/living/simple_animal/hostile/retaliate/cluwne/tempcluwne
	//this version of a cluwne  is for when someone is temporarily turned into a cluwne but you don't intend for them to die before the transformation is finished
	maxHealth = 500
	health = 500
	bookgib = 0
