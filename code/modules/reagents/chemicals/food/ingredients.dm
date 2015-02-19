

/datum/reagent/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	overdose_threshold = 200

/datum/reagent/sugar/overdose_start(var/mob/living/M as mob)
	M << "<span class = 'userdanger'>You go into hyperglycemic shock! Lay off the twinkies!</span>"
	M.sleeping += 30
	..()
	return

/datum/reagent/sugar/overdose_process(var/mob/living/M as mob)
	M.sleeping += 3
	..()
	return

/datum/reagent/sugar/on_mob_life(var/mob/living/M as mob)
	M.nutrition += 1*REM
	..()
	return

/datum/reagent/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/nutriment/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(prob(50)) M.heal_organ_damage(1,0)
	M.nutrition += nutriment_factor	// For hunger and fatness
/*
	// If overeaten - vomit and fall down
	// Makes you feel bad but removes reagents and some effect
	// from your body
	if (M.nutrition > 650)
		M.nutrition = rand (250, 400)
		M.weakened += rand(2, 10)
		M.jitteriness += rand(0, 5)
		M.dizziness = max (0, (M.dizziness - rand(0, 15)))
		M.druggy = max (0, (M.druggy - rand(0, 15)))
		M.adjustToxLoss(rand(-15, -5)))
		M.updatehealth()
*/

	..()
	return

/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.

/datum/reagent/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0

/datum/reagent/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8


/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/capsaicin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(5,20)
			if(M.dna.mutantrace == "slime")
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(10,20)
			if(M.dna.mutantrace == "slime")
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(15,20)
			if(M.dna.mutantrace == "slime")
				M.bodytemperature += rand(15,20)
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	data++
	..()
	return

/datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "This shit goes in pepperspray."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/condensedcapsaicin/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/victim = M
			var/obj/item/mouth_covered = victim.get_body_part_coverage(MOUTH)
			var/obj/item/eyes_covered = victim.get_body_part_coverage(EYES)

			if ( eyes_covered && mouth_covered )
				victim << "<span class='warning'>Your [mouth_covered == eyes_covered ? "[mouth_covered] protects" : "[mouth_covered] and [eyes_covered] protect"] you from the pepperspray!</span>"
				return
			else if ( mouth_covered )	// Reduced effects if partially protected
				victim << "<span class='warning'>Your [mouth_covered] protect you from most of the pepperspray!</span>"
				victim.eye_blurry = max(M.eye_blurry, 15)
				victim.eye_blind = max(M.eye_blind, 5)
				victim.Paralyse(1)
				victim.drop_item()
				return
			else if ( eyes_covered ) // Eye cover is better than mouth cover
				victim << "<span class='warning'>Your [eyes_covered] protects your eyes from the pepperspray!</span>"
				victim.emote("scream",,, 1)
				victim.eye_blurry = max(M.eye_blurry, 5)
				return
			else // Oh dear :D
				victim.emote("scream",,, 1)
				victim << "<span class='danger'>You're sprayed directly in the eyes with pepperspray!</span>"
				victim.eye_blurry = max(M.eye_blurry, 25)
				victim.eye_blind = max(M.eye_blind, 10)
				victim.Paralyse(1)
				victim.drop_item()

/datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	return

/datum/reagent/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extraced from Icepeppers."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233

/datum/reagent/frostoil/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 15)
			M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(5,20)
			if(M.dna && M.dna.mutantrace == "slime")
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(10,20)
			if(M.dna.mutantrace == "slime")
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1)) M.emote("shiver")
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(15,20)
			if(M.dna.mutantrace == "slime")
				M.bodytemperature -= rand(15,20)
	data++
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	..()
	return

/datum/reagent/frostoil/reaction_turf(var/turf/simulated/T, var/volume)
	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15,30))
	for(var/mob/living/carbon/human/H in T)
		if(H.dna.mutantrace == "slime")
			H.adjustToxLoss(rand(5,15))

/datum/reagent/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255

/datum/reagent/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)

/datum/reagent/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/coco/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And coco beans."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16

/datum/reagent/hot_coco/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FF00FF" // rgb: 255, 0, 255

/datum/reagent/sprinkles/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		M.nutrition += nutriment_factor
		..()
		return
	..()

/*	//removed because of meta bullshit. this is why we can't have nice things.
/datum/reagent/syndicream
	name = "Cream filling"
	id = "syndicream"
	description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#AB7878" // rgb: 171, 120, 120

/datum/reagent/syndicream/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.mind)
		if(M.mind.special_role)
			if(!M) M = holder.my_atom
			M.heal_organ_damage(1,1)
			M.nutrition += nutriment_factor
			..()
			return
	..()
*/

/datum/reagent/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/cornoil/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/cornoil/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 3)
		T.wet(800)
	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		del(hotspot)

/datum/reagent/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = LIQUID
	color = "#365E30" // rgb: 54, 94, 48


/datum/reagent/flour
	name = "flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/flour/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/flour/reaction_turf(var/turf/T, var/volume)
	src = null
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/cherryjelly/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M.nutrition += nutriment_factor
	..()
	return