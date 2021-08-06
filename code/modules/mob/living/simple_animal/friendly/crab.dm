//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "A hard-shelled crustacean. Seems quite content to lounge around all the time."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 5
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement = 1
	friendly = "pinches"
	size = SIZE_TINY
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat

	var/obj/item/inventory_head
	var/obj/item/inventory_mask
	held_items = list()

/mob/living/simple_animal/crab/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()
	//CRAB movement
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !locked_to)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(4,8)))
				turns_since_move = 0
	regenerate_icons()

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"

//LOOK AT THIS - ..()??
/mob/living/simple_animal/crab/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.is_wirecutter(user))
		if(stat == DEAD)
			return ..()
		if(prob(50))
			to_chat(user, "<span class='danger'>This kills the crab.</span>")
			health -= 20
			death()
		else
			to_chat(user, "<span class='danger'>You can't help but feel you've just done something terribly wrong.</span>")
			add_gamelogs(user, "attacked a crab with wirecutters, and made it angry", admin = TRUE, tp_link = TRUE, span_class = "danger")
			GetMad()
	else
		return ..()

/mob/living/simple_animal/crab/proc/GetMad()
	new /mob/living/simple_animal/hostile/crab(src.loc)
	qdel(src)

/mob/living/simple_animal/crab/kickstool
	name = "kickstool crab"
	desc = "Small, docile crab. They tend to live in large libraries, and eat dust for some reason."
	icon_state = "kickstool"
	icon_living = "kickstool"
	icon_dead = "kickstool_dead"

/mob/living/simple_animal/crab/norris
	name = "Norris"
	desc = "Some weird Thing that makes a neat pet. Screams a lot."
	icon_state = "norris"
	icon_living = "norris"
	icon_dead = "norris_dead"
	speak_emote = list("screams")
	emote_hear = list("screams")
	emote_see = list("screams")
	emote_sound = list(
		'sound/misc/malescream1.ogg',
		'sound/misc/malescream2.ogg',
		'sound/misc/malescream3.ogg',
		'sound/misc/malescream4.ogg',
		'sound/misc/malescream5.ogg',
		'sound/misc/wilhelm.ogg', 
		'sound/misc/goofy.ogg',
		'sound/misc/femalescream1.ogg',
		'sound/misc/femalescream2.ogg',
		'sound/misc/femalescream3.ogg',
		'sound/misc/femalescream4.ogg',
		'sound/misc/femalescream5.ogg',
		'sound/misc/shriek1.ogg',
		'sound/misc/hiss1.ogg',
		'sound/misc/hiss2.ogg',
		'sound/misc/hiss3.ogg'
	)
	friendly = "bites"
	canRegenerate = 1
	minRegenTime = 30 //It's just a crab, might as well give it quick regen
	maxRegenTime = 120


/mob/living/simple_animal/crab/snowy
	name = "Snowy"
	desc = "While you'd think that most crabs in cold climates would stick to the relatively warmer water, this one's adapted to living on the land and even has camouflage to boot!"
	icon_state = "snowcrab"
	icon_living = "snowcrab"
	icon_dead = "snowcrab_dead"
