//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_stomach()
	for(var/mob/living/M in stomach_contents)
		if(M.loc != src)
			stomach_contents.Remove(M)
			continue
		if(istype(M, /mob/living/carbon) && stat & stat != DEAD)//Only digest carbons and only when not dead
			if(M.stat == DEAD)//Only digest if mob inside is dead
				M.death(0)
				M.ghostize(1)
				qdel(M)
				drop_stomach_contents()
				continue
			if(SSair.current_cycle % 3 == 1)
				if(!(M.status_flags & GODMODE))
					M.adjustBruteLoss(5)
				nutrition += 10

	//Code for devouring things by standing on them, for mushroom men
	if((species.flags & SPECIES_NO_MOUTH) && (species.flags & IS_PLANT))
		var/turf/T = get_turf(src)
		var/list/foods = prune_list_to_type(T.contents,/obj/item/weapon/reagent_containers/food/snacks)
		if(foods && foods.len) //don't send a message if we aren't standing on at least one food
			var/fullness = nutrition + (reagents.get_reagent_amount(NUTRIMENT) * 25)
			switch(fullness)
				if(0 to 50)
					to_chat(src,"<span class='notice'>You dissolve the food with urgency.</span>")
				if(51 to 150)
					to_chat(src,"<span class='notice'>You dissolve the food with purpose.</span>")
				if(151 to 350)
					to_chat(src,"<span class='notice'>You dissolve the food.</span>")
				if(351 to INFINITY)
					to_chat(src,"<span class='notice'>You dissolve the food with lethargy.</span>")

		for(var/obj/item/weapon/reagent_containers/food/snacks/S in foods)
			S.consume(src,FALSE,FALSE,lying ? 1 : 0.1) //Eat at 10% speed if not laying down


	//I put the nutriment stuff here

	if(!hardcore_mode_on)
		return //If hardcore mode isn't on, return
	if(!eligible_for_hardcore_mode(src))
		return //If our mob isn't affected by hardcore mode (like it isn't player controlled), return
	if(src.isDead())
		return //Don't affect dead dudes

	if(nutrition < 100) //Nutrition is below 100 = starvation

		var/list/hunger_phrases = list(
			"You feel weak and malnourished. You must find something to eat now!",
			"You haven't eaten in ages, and your body feels weak! It's time to eat something.",
			"You can barely remember the last time you had a proper, nutritional meal. Your body will shut down soon if you don't eat something!",
			"Your body is running out of essential nutrients! You have to eat something soon.",
			"If you don't eat something very soon, you're going to starve to death."
			)

		//When you're starving, the rate at which oxygen damage is healed is reduced by 80% (you only restore 1 oxygen damage per life tick, instead of 5)

		switch(nutrition)
			if(STARVATION_NOTICE to STARVATION_MIN) //60-80
				if(sleeping)
					return

				if(prob(2))
					to_chat(src, "<span class='notice'>[pick("You're very hungry.","You really could use a meal right now.")]</span>")

			if(STARVATION_WEAKNESS to STARVATION_NOTICE) //30-60
				if(sleeping)
					return

				if(prob(3)) //3% chance of a tiny amount of oxygen damage (1-10)

					adjustOxyLoss(rand(1,10))
					to_chat(src, "<span class='danger'>[pick(hunger_phrases)]</span>")

				else if(prob(5)) //5% chance of being knocked down

					eye_blurry += 10
					Knockdown(10)
					adjustOxyLoss(rand(1,15))
					to_chat(src, "<span class='danger'>You're starving! The lack of strength makes you black out for a few moments...</span>")

			if(STARVATION_NEARDEATH to STARVATION_WEAKNESS) //5-30, 5% chance of weakening and 1-230 oxygen damage. 5% chance of a seizure. 10% chance of dropping item
				if(sleeping)
					return

				if(prob(5))

					adjustOxyLoss(rand(1,20))
					to_chat(src, "<span class='danger'>You're starving. You feel your life force slowly leaving your body...</span>")
					eye_blurry += 20
					if(knockdown < 1)
						Knockdown(20)

				else if(paralysis<1 && prob(5)) //Mini seizure (25% duration and strength of a normal seizure)

					seizure(5, 500)

					adjustOxyLoss(rand(1,25))
					eye_blurry += 20

			if(-INFINITY to STARVATION_NEARDEATH) //Fuck the whole body up at this point
				to_chat(src, "<span class='danger'>You are dying from starvation!</span>")
				adjustToxLoss(STARVATION_TOX_DAMAGE)
				adjustOxyLoss(STARVATION_OXY_DAMAGE)
				adjustBrainLoss(STARVATION_BRAIN_DAMAGE)

				if(prob(10))
					Knockdown(15)
