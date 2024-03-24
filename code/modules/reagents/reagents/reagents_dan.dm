//Discount Dan! He's our man!

/datum/reagent/discount
	name = "Discount Dan's Special Sauce"
	id = DISCOUNT
	description = "You can almost feel your liver failing, just by looking at it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 111, 136, 79
	nutriment_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/discount/New()
	..()
	density = rand(12,48)
	specheatcap = rand(25,2500)/100

/datum/reagent/discount/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(1 to 20)
				if(prob(5))
					to_chat(H,"<span class='warning'>You don't feel very good.</span>")
					holder.remove_reagent(src.id, 0.1 * FOOD_METABOLISM)
			if(20 to 35)
				if(prob(10))
					to_chat(H,"<span class='warning'>You really don't feel very good.</span>")
				if(prob(5))
					H.adjustToxLoss(0.1)
					H.visible_message("[H] groans.")
					holder.remove_reagent(src.id, 0.3 * FOOD_METABOLISM)
			if(35 to INFINITY)
				if(prob(10))
					to_chat(H,"<span class='warning'>Your stomach grumbles unsettlingly.</span>")
				if(prob(5))
					to_chat(H,"<span class='warning'>Something feels wrong with your body.</span>")
					var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
					if(istype(L))
						L.take_damage(0.1, 1)
					H.adjustToxLoss(0.13)
					holder.remove_reagent(src.id, 0.5 * FOOD_METABOLISM)

/datum/reagent/discount/mannitol
	name = "Mannitol"
	id = MANNITOL
	description = "The only medicine a <B>REAL MAN</B> needs."

/datum/reagent/irradiatedbeans
	name = "Irradiated Beans"
	id = IRRADIATEDBEANS
	description = "You can almost taste the lead sheet behind it!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/irradiatedbeans/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		M.apply_radiation(2, RAD_INTERNAL)

/datum/reagent/toxicwaste
	name = "Toxic Waste"
	id = TOXICWASTE
	description = "A type of sludge."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	density = 5.59
	specheatcap = 2.71

/datum/reagent/toxicwaste/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(20))
		M.adjustToxLoss(1)

/datum/reagent/refriedbeans
	name = "Re-Fried Beans"
	id = REFRIEDBEANS
	description = "Mmm.."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/mutatedbeans
	name = "Mutated Beans"
	id = MUTATEDBEANS
	description = "Mutated flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/mutatedbeans/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(10))
		M.adjustToxLoss(1)

/datum/reagent/beff
	name = "Beff"
	id = BEFF
	description = "What's beff? Find out!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/horsemeat
	name = "Horse Meat"
	id = HORSEMEAT
	description = "Tastes excellent in lasagna."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 3 * REAGENTS_METABOLISM

/datum/reagent/moonrocks
	name = "Moon Rocks"
	id = MOONROCKS
	description = "We don't know much about it, but we damn well know that it hates the human skeleton."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/moonrocks/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(15))
		M.adjustBruteLoss(2) //Brute damage since it hates the human skeleton

/datum/reagent/offcolorcheese
	name = "Off-Color Cheese"
	id = OFFCOLORCHEESE
	description = "American Cheese."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/bonemarrow
	name = "Bone Marrow"
	id = BONEMARROW
	description = "Looks like a skeleton got stuck in the production line."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/greenramen
	name = "Greenish Ramen Noodles"
	id = GREENRAMEN
	description = "That green isn't organic."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/greenramen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		M.adjustToxLoss(1)

	if(prob(5))
		M.apply_radiation(1, RAD_INTERNAL) //Call it uranium contamination so heavy metal poisoning for the tox and the uranium radiation for the radiation damage

/datum/reagent/glowingramen
	name = "Glowing Ramen Noodles"
	id = GLOWINGRAMEN
	description = "That glow 'aint healthy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/glowingramen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(10))
		M.apply_radiation(1, RAD_INTERNAL)

/datum/reagent/deepfriedramen
	name = "Deep Fried Ramen Noodles"
	id = DEEPFRIEDRAMEN
	description = "Ramen, deep fried."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/fake_creep // Used to spread xenomorph creep. Why? Well, why not?
	name = "Dan's Grape Drank"
	id = FAKE_CREEP
	description = "Discount Dan's award-winning grape drink. Limited production run! Now with added peanuts!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F2DA8" // 111, 45, 168

/datum/reagent/fake_creep/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 1)
		if(!locate(/obj/effect/alien/weeds) in T)
			new /obj/effect/alien/weeds(T)
		if(!locate(/obj/effect/decal/cleanable/purpledrank) in T)
			new /obj/effect/decal/cleanable/purpledrank(T)
