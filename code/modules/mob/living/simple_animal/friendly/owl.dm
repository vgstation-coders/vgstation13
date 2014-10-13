/mob/living/simple_animal/owl
	name = "owl"
	desc = "How did this owl get here? The world may never know."
	icon_state = "owl"
	icon_living = "owl"
	icon_dead = "owl_dead"
	small = 1
	speak_emote = list("hoots")
	emote_hear = list("hoots")
	emote_see = list("looks for prey")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "swipes at"
	stop_automated_movement = 1
	friendly = "pecks"

/mob/living/simple_animal/owl/Life()
	..()
	//CRAB movement
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(4,8)))
				turns_since_move = 0
	regenerate_icons()