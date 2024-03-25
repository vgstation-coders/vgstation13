#define CAT_TABLE_OFFSET 8
#define CAT_MOOD_YEARNING 0
#define CAT_MOOD_STRAYING 1
#define CAT_MOOD_PLAYFUL 2
#define CAT_MOOD_FELL 3
#define CAT_MOOD_SLEEPY 4
#define CAT_MOOD_COZY 5

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
	pass_flags = PASSTABLE | PASSMACHINE
	held_items = list()

	var/mood = CAT_MOOD_PLAYFUL
	var/current_mood_time = 0 //Time on this mood
	var/moods_since_yearning = 0 //For deciding to go home
	var/last_loc = null //Used to check if we have made progress
	var/area/cathome = null //For returning on yearn
	var/area/goalarea = null //For straying
	var/list/mood_weights = list(
		CAT_MOOD_YEARNING = 12,
		CAT_MOOD_STRAYING = 12,
		CAT_MOOD_PLAYFUL = 12,
		CAT_MOOD_FELL = 12,
		CAT_MOOD_SLEEPY = 12,
		CAT_MOOD_COZY = 12)
	var/list/valid_stray_zones = list(/area/crew_quarters/sleep,/area/crew_quarters/toilet,
/area/crew_quarters/locker,/area/crew_quarters/bar,/area/crew_quarters/kitchen,/area/chapel,/area/hallway/secondary/exit,
/area/hallway/secondary/entry,/area/engineering/break_room,/area/medical/break_room,/area/science/breakroom,/area/supply/office,
/area/janitor,/area/security/main)

/mob/living/simple_animal/cat/New()
	..()
	cathome = get_area(src)

/mob/living/simple_animal/cat/Destroy()
	..()
	last_loc = null
	cathome = null
	goalarea = null

/mob/living/simple_animal/cat/prewander(destination)
	if(!hastable(loc) && hastable(destination))
		visible_message("<span class='notice'>\The [src] leaps up onto the table!</span>")
		do_leap()
	return ..()

/mob/living/simple_animal/cat/wander_move(dest)
	if(mood == CAT_MOOD_PLAYFUL)
		var/list/zoom_places = view(1,src)
		for(var/i = 1 to 5)
			Move(zoom_places)
			sleep(2)

	else
		..()

/mob/living/simple_animal/cat/Move(destination)
	last_loc = loc
	..()
	update_icon = TRUE //may need to hop down

/mob/living/simple_animal/cat/proc/hastable(turf/newloc)
	if(!istype(newloc))
		return FALSE
	if(locate(/obj/structure/table) in newloc)
		return TRUE
	return FALSE

/mob/living/simple_animal/cat/proc/comfiness_check(turf/newloc)
	for(var/obj/O in newloc)
		if(O.cat_comfy())
			return TRUE
	return FALSE

/mob/living/simple_animal/cat/update_icon()
	..()
	pixel_y = hastable(loc) ? CAT_TABLE_OFFSET : 0
	if(isUnconscious())
		icon_state = initial(icon_state) + "_dead"
		return
	if(resting)
		icon_state = initial(icon_state) + "_rest"

/mob/living/simple_animal/cat/proc/do_leap()
	animate(src, pixel_y = CAT_TABLE_OFFSET*1.5, time = CAT_TABLE_OFFSET/2, easing = QUAD_EASING | EASE_OUT)
	spawn(CAT_TABLE_OFFSET/2)
		animate(src, pixel_y = CAT_TABLE_OFFSET, time = CAT_TABLE_OFFSET/4, easing = QUAD_EASING | EASE_IN)

/mob/living/simple_animal/cat/proc/pick_mood()
	//YEARNING = Goes home
	//STRAYING = Goes to a random room
	//Fell: Automatic if attacked
	//COZY = Seeks out a place to lay, plays rest animation
	//Automaticly if completed straying or yearning

	var/list/possible_moods = mood_weights.Copy()
	//Step 1: Location-based
	possible_moods[mood] = 0 //No chance of picking current mood
	if(get_area(src) == cathome)
		possible_moods[CAT_MOOD_YEARNING] = 0 //Can't yearn when at home
		possible_moods[CAT_MOOD_SLEEPY] *= 2
	else
		possible_moods[CAT_MOOD_SLEEPY] *= 0.5
	if(z != map.zMainStation)
		possible_moods[CAT_MOOD_STRAYING] = 0
	//Step 2: Apply current-mood effects
	switch(mood)
		if(CAT_MOOD_YEARNING)
			//If we are still yearning, we never fully reached home
			goalarea = null
			possible_moods[CAT_MOOD_FELL] *= 1.25
			possible_moods[CAT_MOOD_COZY] *= 1.25

		if(CAT_MOOD_STRAYING)
			//We just wandered a while but never got where we wanted to
			goalarea = null
			possible_moods[CAT_MOOD_FELL] *= 2
			possible_moods[CAT_MOOD_YEARNING] *= 2

		if(CAT_MOOD_PLAYFUL)
			//No longer playful, reset wander freq
			turns_per_move = 5
			possible_moods[CAT_MOOD_FELL] *= 0.5
			possible_moods[CAT_MOOD_SLEEPY] *= 1.5

		if(CAT_MOOD_FELL)
			//We are no longer in a Fell mood, stop hissing
			emote_sound = list("sound/voice/catmeow.ogg")
			possible_moods[CAT_MOOD_PLAYFUL] *= 0.25
			possible_moods[CAT_MOOD_STRAYING] *= 3
			possible_moods[CAT_MOOD_SLEEPY] *= 1.5

		if(CAT_MOOD_SLEEPY)
			//We are not going to be sleepy after this, so immediately clear sleepiness
			sleeping = 0
			possible_moods[CAT_MOOD_PLAYFUL] *= 2
			possible_moods[CAT_MOOD_FELL] *= 2

		if(CAT_MOOD_COZY)
			//No longer comfy, can wander
			wander = TRUE
			possible_moods[CAT_MOOD_SLEEPY] *= 2
			possible_moods[CAT_MOOD_YEARNING] *= 0.25
			possible_moods[CAT_MOOD_STRAYING] *= 0.25

	//Step 3: Apply stat-based effects
	if(size == SIZE_TINY)
		possible_moods[CAT_MOOD_PLAYFUL] *= 2 //kittens are more playful
	if(health<maxHealth)
		//This formula looks more complicated than it is.
		//Get the percent health (e.g.: 40%). Then take the inverse of that, so 0.6
		//Then add 1, and round to nearest 0.25, so 1.6 ~= 1.5
		var/weight = round(1+(1-(health/maxHealth)),0.25)
		possible_moods[CAT_MOOD_SLEEPY] *= weight
		possible_moods[CAT_MOOD_FELL] *= weight

	//Step 4: Yearn
	if(moods_since_yearning>1)
		possible_moods[CAT_MOOD_YEARNING] *= moods_since_yearning-1 //e.g.: 3 moods = 2x

	set_mood(pickweight(possible_moods))

/mob/living/simple_animal/cat/proc/set_mood(numood)
	mood = numood
	current_mood_time = 0
	if(get_area(src) != cathome) //Only increase if not at home
		moods_since_yearning++
	else
		moods_since_yearning = 0
	update_icon()
	switch(mood)
		if(CAT_MOOD_PLAYFUL)
			turns_per_move = 2
		if(CAT_MOOD_YEARNING)
			goalarea = cathome
		if(CAT_MOOD_STRAYING)
			goalarea = pick_straying()
		if(CAT_MOOD_COZY)
			wander = FALSE

/mob/living/simple_animal/cat/proc/pick_straying()
	var/list/searchareas = shuffle(areas.Copy())

	for(var/area/A in searchareas)
		if(is_type_in_list(A,valid_stray_zones))
			goalarea = A
			return

/mob/living/simple_animal/cat/Life()
	if(timestopped)
		return 0 //under effects of time magick

	sleeping = max(sleeping-1,0) //Same rate as carbons)
	current_mood_time++

	if(current_mood_time>120+rand(0,60)) //Can't pick a mood under 4 minutes. Then, the odds increase per second (guaranteed at 5 min).
		pick_mood()

	if(isUnconscious())
		health = min(health+1, maxHealth) //Heal while sleeping
		if(mood!=CAT_MOOD_SLEEPY)
			set_mood(CAT_MOOD_SLEEPY)
		if(prob(5))
			playsound(loc, 'sound/voice/catpurr.ogg', 50, 1)
		return ..()

	resting = FALSE //We are not asleep, so stop resting. This will be activated again if we are comfy.
	switch(mood)
		if(CAT_MOOD_SLEEPY)
			sleeping += 150 //5 minutes at 2 sec per tick
		//No special behavior for playful, but wanders more and does wild movement when wandering
		if(CAT_MOOD_YEARNING, CAT_MOOD_STRAYING)
			if(loc == last_loc) //Why haven't we made progress? Meow!
				playsound(loc, 'sound/voice/catmeow.ogg', 50, 1)
				visible_message("\The [src] meows impatiently!")
		//Cozy: Check if we have arrived at our movement_target so we can lay down
		if(CAT_MOOD_COZY)
			if(comfiness_check())
				resting = TRUE
				update_icon()

		//Fell: Attack things
		if(CAT_MOOD_FELL)
			var/list/valid_fell_targets = list(/obj/structure/bookcase,/obj/item)
			var/list/ire = list()
			for(var/obj/O in view(1,src))
				if(istype(O,valid_fell_targets))
					O+=ire
			var/obj/chosen = pick(ire)
			chosen?.cat_act()

	//Perform other behaviors
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

/mob/living/simple_animal/cat/get_butchering_products()
	return list(/datum/butchering_product/skin/cat)

/mob/living/simple_animal/cat/proc/react_to_touch(mob/M)
	if(M && !isUnconscious())
		if(mood == CAT_MOOD_FELL)
			playsound(loc, 'sound/voice/cathiss.ogg', 50, 1)
			emote("me", EMOTE_AUDIBLE, "hisses.")
			return
		switch(M.a_intent)
			if(I_HELP)
				var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
				heart.plane = ABOVE_HUMAN_PLANE
				flick_overlay(heart, list(M.client), 20)
				emote("me", EMOTE_AUDIBLE, "purrs.")
				playsound(loc, 'sound/voice/catpurr.ogg', 50, 1)
				if(prob(5))
					set_mood(CAT_MOOD_PLAYFUL)
			if(I_HURT)
				playsound(loc, 'sound/voice/cathiss.ogg', 50, 1)
				emote("me", EMOTE_AUDIBLE, "hisses.")
	if(sleeping)
		sleeping -= 10
		if(sleeping <= 0)
			pick_mood()

/mob/living/simple_animal/cat/proc/espify()
	desc = "The product of irresponsible chemistry. She's acutely aware of your presence."
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"

//Subtypes
//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	is_pet = TRUE
	mood_weights = list(
		CAT_MOOD_YEARNING = 4,
		CAT_MOOD_STRAYING = 12,
		CAT_MOOD_PLAYFUL = 0,
		CAT_MOOD_FELL = 0,
		CAT_MOOD_SLEEPY = 12,
		CAT_MOOD_COZY = 12)
	valid_stray_zones = list(/area/medical/medbay,/area/medical/medbay2,/area/medical/break_room,/area/medical/patient_room1,/area/medical/patient_room2,
/area/medical/chemistry,/area/medical/cryo,/area/medical/storage,/area/medical/genetics,/area/medical/sleeper,/area/medical/paramedics)

/mob/living/simple_animal/cat/Runtime/on_reagent_change()
	if(src.icon_living != "original")
		var/m_amount = reagents.get_reagent_amount(METHYLIN)
		if(m_amount >= 4) /* We want 5 units, but we're accounting for metabolism ticks here. */
			reagents.remove_reagent_by_type(METHYLIN, m_amount)
			playsound(src, 'sound/effects/bubbles.ogg', 80, 1)
			for(var/mob/M in view())
				to_chat(M, "<span class='notice'>\The [src]'s fur vibrates and shimmers as a mind-enhancing solution flows through \his... and \she transforms!</span>") /* BYOND doesn't have an equivalent macro for "her"... */
			espify()

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
	//Salem always more likely to return home and be cozy
	mood_weights = list(
		CAT_MOOD_YEARNING = 24,
		CAT_MOOD_STRAYING = 12,
		CAT_MOOD_PLAYFUL = 12,
		CAT_MOOD_FELL = 12,
		CAT_MOOD_SLEEPY = 12,
		CAT_MOOD_COZY = 36)

/mob/living/simple_animal/cat/kitten
	name = "kitten"
	desc = "D'aaawwww!"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	gender = NEUTER
	size = SIZE_TINY


/*********************
*    Snakes			 *
* Should not be cats *
*********************/

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
	pass_flags = 0

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
	..(TRUE)
	if(!transmogrify())
		visible_message("<span class='notice'>\The [src] vanishes!</span>")
		qdel(src)

/mob/living/simple_animal/cat/snek/wizard/Destroy()
	wizard_snakes[src] = null
	wizard_snakes -= src
	..()

/mob/living/simple_animal/cat/snek/pudge
	name = "Pudge"
	desc = "You've never seen a snake like this before. It is quite chubby!"
	icon_state = "pudge"
	icon_living = "pudge"
	icon_dead = "pudge_dead"
	gender = NEUTER
	speak = list("Meep!", "Chirp!","Mweeeb!")
	speak_emote = list("squeaks")
	emote_hear = list("squeaks")
	emote_see = list("slithers")
	emote_sound = list() // stops snakes purring
	kill_verbs = list("strikes at", "splats", "bites", "lunges at")
	growl_verbs = list("squeaks")

	species_type = /mob/living/simple_animal/cat/snek
	butchering_drops = null
	childtype = null
	holder_type = /obj/item/weapon/holder/animal/snek
