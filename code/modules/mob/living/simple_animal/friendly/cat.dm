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
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6

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

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE

/mob/living/simple_animal/cat/Life()
	if(timestopped) return 0 //under effects of time magick

	//MICE!
	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !locked_to)
			for(var/mob/living/simple_animal/mouse/M in view(1,src))
				if(!M.stat)
					M.splat()
					emote(pick("<span class='warning'>splats the [M]!</span>","<span class='warning'>toys with the [M]</span>","worries the [M]"))
					movement_target = null
					stop_automated_movement = 0
					break

	..()

	for(var/mob/living/simple_animal/mouse/snack in oview(src, 3))
		if(prob(15))
			emote(pick("hisses and spits!","mrowls fiercely!","eyes [snack] hungrily."))
		break

	if(!stat && !resting && !locked_to)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
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
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/cat/Proc
	name = "Proc"

/mob/living/simple_animal/cat/salem
	name = "Salem"
	desc = "Meow."
	icon_state = "salem"
	icon_living= "salem"
	icon_dead= "salem_dead"
	gender = FEMALE

/mob/living/simple_animal/cat/kitten
	name = "kitten"

	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	gender = NEUTER
	size = SIZE_TINY

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

	species_type = /mob/living/simple_animal/cat/snek
	butchering_drops = null
	childtype = null
	holder_type = null

/mob/living/simple_animal/cat/snek/corpus
	name = "Corpus"