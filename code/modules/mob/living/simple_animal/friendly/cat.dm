//Cat
/mob/living/simple_animal/cat
	name = "cat"

	desc = "Kitty!!"
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	size = SIZE_SMALL
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	emote_see = list("shakes its head", "shivers")
	emote_sound = list("sound/voice/catmeow.ogg")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6

	speak_override = TRUE


	can_breed = 1
	species_type = /mob/living/simple_animal/cat
	childtype = /mob/living/simple_animal/cat/kitten
	holder_type = /obj/item/weapon/holder/animal/cat

	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	min_oxy = 16      // Require atleast 16kPA oxygen
	minbodytemp = 223 // Below -50 Degrees Celcius
	maxbodytemp = 323 // Above 50 Degrees Celcius
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target=null
	var/kill_verbs = list("splats", "toys with", "worries")
	var/growl_verbs = list("hisses and spits", "mrowls fiercely", "growls")

	held_items = list()

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	is_pet = TRUE

/mob/living/simple_animal/cat/Proc
	name = "Proc"

/mob/living/simple_animal/cat/salem
	name = "Salem"
	desc = "Meow."
	icon_state = "salem"
	icon_living= "salem"
	icon_dead= "salem_dead"
	gender = FEMALE
	holder_type = /obj/item/weapon/holder/animal/salem

/mob/living/simple_animal/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	gender = NEUTER
	size = SIZE_TINY

/mob/living/simple_animal/cat/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if (!isUnconscious())
		//MICE!
		if(isturf(loc))
			if(!stat && !resting && !locked_to)
				for(var/mob/living/simple_animal/mouse/M in view(1,src))
					if(!M.stat && Adjacent(M) && !(M.locked_to && istype(M.locked_to, /obj/item/critter_cage)))
						M.splat()
						visible_message("<span class='warning'>\The [name] [pick(kill_verbs)] \the [M]!</span>")
						movement_target = null
						stop_automated_movement = 0
						break

	..()

	if (!isUnconscious())
		for(var/mob/living/simple_animal/mouse/snack in oview(src, 3))
			if(prob(15) && !snack.stat)
				emote("me",, pick("[pick(growl_verbs)] at [snack]!", "eyes [snack] hungrily."))
			break

		if(!stat && !resting && !locked_to)
			turns_since_scan++
			if(turns_since_scan > 5)
				start_walk_to(0)
				turns_since_scan = 0
				if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
					movement_target = null
					stop_automated_movement = 0
				if( !movement_target || !(movement_target.loc in oview(src, 3)) )
					movement_target = null
					stop_automated_movement = 0
					for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
						if(isturf(snack.loc) && !snack.stat)
							movement_target = snack
							break
				if(movement_target)
					stop_automated_movement = 1
					start_walk_to(movement_target,0,3)

/mob/living/simple_animal/cat/attack_hand(mob/living/carbon/human/M)
	. = ..()
	react_to_touch(M)
	M.delayNextAttack(2 SECONDS)

/mob/living/simple_animal/cat/proc/react_to_touch(mob/M)
	if(M && !isUnconscious())
		switch(M.a_intent)
			if(I_HELP)
				var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
				heart.plane = ABOVE_HUMAN_PLANE
				flick_overlay(heart, list(M.client), 20)
				emote("me", EMOTE_AUDIBLE, "purrs.")
				playsound(loc, 'sound/voice/catpurr.ogg', 80, 1)
			if(I_HURT)
				playsound(loc, 'sound/voice/cathiss.ogg', 80, 1)
				emote("me", EMOTE_AUDIBLE, "hisses.")

/mob/living/simple_animal/cat/snek/react_to_touch(mob/M)
	return 0 // SNAKES DO NOT MEOW. WHY ARE THEY A CAT SUBTYPE?

/mob/living/simple_animal/cat/snek
	name = "snake"
	desc = "sssSSSSsss"
	icon_state = "snek"
	icon_living = "snek"
	icon_dead = "snek_dead"
	gender = NEUTER
	speak = list("SssssSSSS.", "Slirp.","HSSSSS")
	speak_emote = list("hisses")
	emote_hear = list("hisses")
	emote_see = list("slithers")
	emote_sound = list() // stops snakes purring
	kill_verbs = list("strikes at", "splats", "bites", "lunges at")
	growl_verbs = list("hisses")

	species_type = /mob/living/simple_animal/cat/snek
	butchering_drops = null
	childtype = null
	holder_type = /obj/item/weapon/holder/animal/snek

/mob/living/simple_animal/cat/snek/corpus
	name = "Corpus"
	density = 0

var/list/wizard_snakes = list()

/mob/living/simple_animal/cat/snek/wizard
	health = 5
	maxHealth = 5

/mob/living/simple_animal/cat/snek/wizard/New(turf/T, var/spell_holder)	//For the snake spell
	..(T)
	if(spell_holder)
		wizard_snakes[src] = spell_holder

/mob/living/simple_animal/cat/snek/wizard/death(var/gibbed = FALSE)
	if(!transmogrify())
		visible_message("<span class='notice'>\The [src] vanishes!</span>")
		qdel(src)
	..(TRUE)

/mob/living/simple_animal/cat/snek/wizard/Destroy()
	wizard_snakes[src] = null
	wizard_snakes -= src
	..()
