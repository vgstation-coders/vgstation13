// Discount Dan shit.  Needs work.

/datum/reagent/discount
	name = "Discount Dan's Special Sauce"
	id = "discount"
	description = "You can almost feel your liver failing, just by looking at it."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/discount/on_mob_life(var/mob/living/M as mob)
	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(1 to 20)
				if(prob(5))
					H << "<span class='warning'>You don't feel very good..</span>"
					holder.remove_reagent(src.id, 0.1 * REAGENTS_METABOLISM)
			if(20 to 35)
				if(prob(10))
					H << "<span class='warning'>You REALLY don't feel very good..</span>"
				if(prob(5))
					H.adjustToxLoss(0.1)
					H.visible_message("[H] groans.")
					holder.remove_reagent(src.id, 0.3 * REAGENTS_METABOLISM)
			if(35 to INFINITY)
				if(prob(10))
					H << "<span class='warning'>Your stomach grumbles unsettlingly..</span>"
				if(prob(5))
					H << "<span class='warning'>Something feels wrong with your body..</span>"
					var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
					if (istype(L))
						L.take_damage(0.1, 1)
					H.adjustToxLoss(0.13)
					holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
			else
				return

/datum/reagent/irradiatedbeans
	name = "Irradiated Beans"
	id = "irradiatedbeans"
	description = "You can almost taste the lead sheet behind it!"
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/toxicwaste
	name = "Toxic Waste"
	id = "toxicwaste"
	description = "Yum!"
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/refriedbeans
	name = "Re-Fried Beans"
	id = "refriedbeans"
	description = "Mmm.."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/mutatedbeans
	name = "Mutated Beans"
	id = "mutatedbeans"
	description = "Mutated flavor."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/beff
	name = "Beff"
	id = "beff"
	description = "What's beff? Find out!"
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/horsemeat
	name = "Horse Meat"
	id = "horsemeat"
	description = "Tastes excellent in lasagna."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/moonrocks
	name = "Moon Rocks"
	id = "moonrocks"
	description = "We don't know much about it, but we damn well know that it hates the human skeleton."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/offcolorcheese
	name = "Off-Color Cheese"
	id = "offcolorcheese"
	description = "American Cheese."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/bonemarrow
	name = "Bone Marrow"
	id = "bonemarrow"
	description = "Looks like a skeleton got stuck in the production line."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/greenramen
	name = "Greenish Ramen Noodles"
	id = "greenramen"
	description = "That green isn't organic."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/glowingramen
	name = "Glowing Ramen Noodles"
	id = "glowingramen"
	description = "That glow 'aint healthy."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/deepfriedramen
	name = "Deep Fried Ramen Noodles"
	id = "deepfriedramen"
	description = "Ramen, deep fried."
	reagent_state = LIQUID
	color = "#6F884F" // rgb: 255,255,255 //to-do

/datum/reagent/peptobismol
	name = "Peptobismol"
	id = "peptobismol"
	description = "Jesus juice." //You're welcome, guy in the thread that rolled a 69.
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/peptobismol/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.drowsyness = max(M.drowsyness-2*REM, 0)
	if(holder.has_reagent("discount"))
		holder.remove_reagent("discount", 2*REM)
	M.hallucination = max(0, M.hallucination - 5*REM)
	M.adjustToxLoss(-2*REM)
	..()
	return