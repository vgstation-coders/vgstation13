
/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#A5F0EE" // rgb: 165, 240, 238

/datum/reagent/space_cleaner/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.clean_blood()
	O.color = initial(O.color)

/datum/reagent/space_cleaner/reaction_turf(var/turf/T, var/volume)
	if(volume >= 1)
		T.color = initial(T.color)
		T.overlays.len = 0
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in src)
			qdel(C)

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5,10))

		for(var/mob/living/carbon/human/H in T)
			if(H.dna.mutantrace == "slime")
				H.adjustToxLoss(rand(0.5,1))

/datum/reagent/space_cleaner/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)

	if(!holder) return
	M.color = initial(M.color)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.r_hand)
			C.r_hand.clean_blood()
		if(C.l_hand)
			C.l_hand.clean_blood()
		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
		M.clean_blood()