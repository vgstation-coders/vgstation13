////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	container_type = INJECTABLE
	resistance_flags = FLAMMABLE
	var/foodtype = NONE
	var/last_check_time

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = rand(-5, 5)
		pixel_y = rand(-5, 5)

/obj/item/reagent_containers/food/proc/checkLiked(var/fraction, mob/M)
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.has_trait(TRAIT_AGEUSIA))
				if(foodtype & H.dna.species.toxic_food)
					to_chat(H,"<span class='warning'>What the hell was that thing?!</span>")
					H.adjust_disgust(25 + 30 * fraction)
					H.SendSignal(COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
				else if(foodtype & H.dna.species.disliked_food)
					to_chat(H,"<span class='notice'>That didn't taste very good...</span>")
					H.adjust_disgust(11 + 15 * fraction)
					H.SendSignal(COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
				else if(foodtype & H.dna.species.liked_food)
					to_chat(H,"<span class='notice'>I love this taste!</span>")
					H.adjust_disgust(-5 + -2.5 * fraction)
					H.SendSignal(COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)
			else
				if(foodtype & H.dna.species.toxic_food)
					to_chat(H, "<span class='warning'>You don't feel so good...</span>")
					H.adjust_disgust(25 + 30 * fraction)
			last_check_time = world.time
