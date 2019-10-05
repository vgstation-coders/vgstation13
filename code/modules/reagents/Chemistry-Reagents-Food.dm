//////////////////////
//					//
//     FOOD			//
//					//
//////////////////////
//Part of the food code. Nutriment is used instead of the old "heal_amt" code
//Also is where all the food condiments, additives, and such go.


/datum/reagent/nutriment
	name = "Nutriment"
	id = NUTRIMENT
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" //rgb: 102, 67, 48
	density = 6.54
	specheatcap = 17.56

/datum/reagent/nutriment/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(50))
		M.heal_organ_damage(1, 0)

	M.nutrition += nutriment_factor	//For hunger and fatness

/datum/reagent/soysauce
	name = "Soysauce"
	id = SOYSAUCE
	description = "A salty sauce made from the soy plant."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" //rgb: 121, 35, 0
	density = 1.17
	specheatcap = 1.38

/datum/reagent/ketchup
	name = "Ketchup"
	id = KETCHUP
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8

/datum/reagent/mustard
	name = "Mustard"
	id = MUSTARD
	description = "A spicy yellow paste."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#cccc33" //rgb: 204, 204, 51

/datum/reagent/relish
	name = "Relish"
	id = RELISH
	description = "A pickled cucumber jam. Tasty!"
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#336600" //rgb: 51, 102, 0

/datum/reagent/dipping_sauce
	name = "Dipping Sauce"
	id = DIPPING_SAUCE
	description = "Adds extra, delicious texture to a snack."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#33cc33" //rgb: 51, 204, 51

/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = CAPSAICIN
	description = "This is what makes chilis hot."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 179, 16, 8
	data = 1 //Used as a tally
	custom_metabolism = FOOD_METABOLISM
	density = 0.53
	specheatcap = 3.49

/datum/reagent/capsaicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature += 0.6 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 0.9 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 1.2 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(15,20)
	data++

/datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = CONDENSEDCAPSAICIN
	description = "This shit goes in pepperspray."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 179, 16, 8
	density = 0.9
	specheatcap = 8.59

/datum/reagent/condensedcapsaicin/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/mouth_covered = H.get_body_part_coverage(MOUTH)
			var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
			if(eyes_covered && mouth_covered)
				H << "<span class='warning'>Your [mouth_covered == eyes_covered ? "[mouth_covered] protects" : "[mouth_covered] and [eyes_covered] protect"] you from the pepperspray!</span>"
				return
			else if(mouth_covered)	//Reduced effects if partially protected
				H << "<span class='warning'>Your [mouth_covered] protects your mouth from the pepperspray!</span>"
				H.eye_blurry = max(M.eye_blurry, 15)
				H.eye_blind = max(M.eye_blind, 5)
				H.Paralyse(1)
				H.drop_item()
				return
			else if(eyes_covered) //Eye cover is better than mouth cover
				H << "<span class='warning'>Your [eyes_covered] protects your eyes from the pepperspray!</span>"
				H.audible_scream()
				H.eye_blurry = max(M.eye_blurry, 5)
				return
			else //Oh dear
				H.audible_scream()
				H << "<span class='danger'>You are sprayed directly in the eyes with pepperspray!</span>"
				H.eye_blurry = max(M.eye_blurry, 25)
				H.eye_blind = max(M.eye_blind, 10)
				H.Paralyse(1)
				H.drop_item()

/datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

/datum/reagent/blackcolor
	name = "Black Food Coloring"
	id = BLACKCOLOR
	description = "A black coloring used to dye food and drinks."
	reagent_state = REAGENT_STATE_LIQUID
	flags = CHEMFLAG_OBSCURING
	color = "#000000" //rgb: 0, 0, 0

/datum/reagent/frostoil
	name = "Frost Oil"
	id = FROSTOIL
	description = "A special oil that noticably chills the body. Extraced from Icepeppers."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 139, 166, 233
	data = 1 //Used as a tally
	custom_metabolism = FOOD_METABOLISM

/datum/reagent/frostoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature = max(M.bodytemperature-0.3 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature = max(M.bodytemperature-0.6 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature = max(M.bodytemperature-0.9 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(15,20)
	data++

/datum/reagent/frostoil/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15, 30))
	for(var/mob/living/carbon/human/H in T)
		if(isslimeperson(H))
			H.adjustToxLoss(rand(5, 15))

/datum/reagent/sodiumchloride
	name = "Table Salt"
	id = SODIUMCHLORIDE
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF" //rgb: 255, 255, 255
	density = 2.09
	specheatcap = 1.65

/datum/reagent/sodiumchloride/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/list/borers = M.get_brain_worms()
	if(borers)
		for(var/mob/living/simple_animal/borer/B in borers)
			B.health -= 1
			to_chat(B, "<span class='warning'>Something in your host's bloodstream burns you!</span>")


/datum/reagent/blackpepper
	name = "Black Pepper"
	id = BLACKPEPPER
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = REAGENT_STATE_SOLID
	//rgb: 0, 0, 0

/datum/reagent/cinnamon
	name = "Cinnamon Powder"
	id = CINNAMON
	description = "A spice, obtained from the bark of cinnamomum trees."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#D2691E" //rgb: 210, 105, 30

/datum/reagent/coco
	name = "Coco Powder"
	id = COCO
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0


/datum/reagent/sprinkles
	name = "Sprinkles"
	id = SPRINKLES
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = REAGENTS_METABOLISM
	color = "#FF00FF" //rgb: 255, 0, 255
	density = 1.59
	specheatcap = 1.24

/datum/reagent/sprinkles/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += REM * nutriment_factor
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			H.heal_organ_damage(1, 1)
			H.nutrition += REM * nutriment_factor //Double nutrition



/datum/reagent/cornoil
	name = "Corn Oil"
	id = CORNOIL
	description = "An oil derived from various types of corn."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/cornoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/cornoil/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3)
		T.wet(800)
	var/hotspot = (locate(/obj/effect/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles())
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/enzyme
	name = "Universal Enzyme"
	id = ENZYME
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365E30" //rgb: 54, 94, 48
	density = 9.68
	specheatcap = 101.01

/datum/reagent/dry_ramen
	name = "Dry Ramen"
	id = DRY_RAMEN
	description = "Space age food, since August 25, 1958. Contains dried noodles and vegetables, best cooked in boiling water."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/dry_ramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/hot_ramen
	name = "Hot Ramen"
	id = HOT_RAMEN
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 1.33
	specheatcap = 4.18

/datum/reagent/hot_ramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/hell_ramen
	name = "Hell Ramen"
	id = HELL_RAMEN
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 1.42
	specheatcap = 14.59

/datum/reagent/hell_ramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/tomato_soup
	name = "Tomato Soup"
	id = TOMATO_SOUP
	description = "Water, tomato extract, and maybe some other stuff."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8
	density = 0.63
	specheatcap = 4.21

/datum/reagent/tomato_soup/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/flour
	name = "flour"
	id = FLOUR
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#FFFFFF" //rgb: 0, 0, 0

/datum/reagent/flour/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	M.nutrition += nutriment_factor

/datum/reagent/flour/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/flour) in T))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/flour/nova_flour
	name = "nova flour"
	id = NOVAFLOUR
	description = "This is what you rub all over yourself to set on fire."
	color = "#B22222" //rgb: 178, 34, 34

/datum/reagent/flour/nova_flour/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.bodytemperature += 3 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/rice
	name = "Rice"
	id = RICE
	description = "Enjoy the great taste of nothing."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" //rgb: 0, 0, 0

/datum/reagent/rice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = CHERRYJELLY
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" //rgb: 128, 30, 40

/datum/reagent/cherryjelly/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/discount
	name = "Discount Dan's Special Sauce"
	id = DISCOUNT
	description = "You can almost feel your liver failing, just by looking at it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 111, 136, 79
	data = 1 //Used as a tally

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

/datum/reagent/irradiatedbeans
	name = "Irradiated Beans"
	id = IRRADIATEDBEANS
	description = "You can almost taste the lead sheet behind it!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/toxicwaste
	name = "Toxic Waste"
	id = TOXICWASTE
	description = "A type of sludge."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	density = 5.59
	specheatcap = 2.71

/datum/reagent/refriedbeans
	name = "Re-Fried Beans"
	id = REFRIEDBEANS
	description = "Mmm.."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/mutatedbeans
	name = "Mutated Beans"
	id = MUTATEDBEANS
	description = "Mutated flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/beff
	name = "Beff"
	id = BEFF
	description = "What's beff? Find out!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/horsemeat
	name = "Horse Meat"
	id = HORSEMEAT
	description = "Tastes excellent in lasagna."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/moonrocks
	name = "Moon Rocks"
	id = MOONROCKS
	description = "We don't know much about it, but we damn well know that it hates the human skeleton."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/offcolorcheese
	name = "Off-Color Cheese"
	id = OFFCOLORCHEESE
	description = "American Cheese."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/bonemarrow
	name = "Bone Marrow"
	id = BONEMARROW
	description = "Looks like a skeleton got stuck in the production line."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/greenramen
	name = "Greenish Ramen Noodles"
	id = GREENRAMEN
	description = "That green isn't organic."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/glowingramen
	name = "Glowing Ramen Noodles"
	id = GLOWINGRAMEN
	description = "That glow 'aint healthy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/deepfriedramen
	name = "Deep Fried Ramen Noodles"
	id = DEEPFRIEDRAMEN
	description = "Ramen, deep fried."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do


/datum/reagent/sugar
	name = "Sugar"
	id = SUGAR
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF" //rgb: 255, 255, 255
	sport = 1.2
	density = 1.59
	specheatcap = 1.244

/datum/reagent/sugar/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += REM

/datum/reagent/caramel
	name = "Caramel"
	id = CARAMEL
	description = "Created from the removal of water from sugar."
	reagent_state = REAGENT_STATE_SOLID
	color = "#844b06" //rgb: 132, 75, 6
	specheatcap = 1.244
	density = 1.59

/datum/reagent/caramel/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += (2 * REM)

/datum/reagent/honey
	name = "Honey"
	id = HONEY
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#FEAE00"
	alpha = 200
	nutriment_factor = 15 * REAGENTS_METABOLISM
	var/quality = 2
	density = 1.59
	specheatcap = 1.244

/datum/reagent/honey/on_mob_life(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!holder)
			return
		H.nutrition += nutriment_factor
		if(H.getBruteLoss() && prob(60))
			H.heal_organ_damage(quality, 0)
		if(H.getFireLoss() && prob(50))
			H.heal_organ_damage(0, quality)
		if(H.getToxLoss() && prob(50))
			H.adjustToxLoss(-quality)
		..()

/datum/reagent/honey/royal_jelly
	name = "Royal Jelly"
	id = ROYALJELLY
	description = "A pale yellow liquid that is both spicy and acidic, yet also sweet."
	color = "#FFDA6A"
	alpha = 220
	nutriment_factor = 15 * REAGENTS_METABOLISM
	quality = 3

/datum/reagent/honey/chillwax
	name = "Chill Wax"
	id = CHILLWAX
	description = "A bluish wax produced by insects found on Vox worlds. Sweet to the taste, albeit trippy."
	color = "#4C78C1"
	alpha = 250
	nutriment_factor = 10 * REAGENTS_METABOLISM
	density = 1.59
	quality = 1
	specheatcap = 1.244

/datum/reagent/honey/chillwax/on_mob_life(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.druggy = max(H.druggy, 5)
		H.Dizzy(2)
		if(prob(10))
			H.emote(pick("stare", "giggle"), null, null, TRUE)
		if(prob(5))
			to_chat(H, "<span class='notice'>[pick("You feel at peace with the world.","Everyone is nice, everything is awesome.","You feel high and ecstatic.")]</span>")
		..()


//Quiet and lethal, needs at least 4 units in the person before they'll die
/datum/reagent/chefspecial
	name = "Chef's Special"
	id = CHEFSPECIAL
	description = "An extremely toxic chemical that will surely end in death."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	overdose_tick = 165
	density = 0.687 //Let's assume it's a compound of cyanide
	specheatcap = 1.335

/datum/reagent/chefspecial/on_overdose(var/mob/living/M)
	M.death(0)
	M.attack_log += "\[[time_stamp()]\]<font color='red'>Died a quick and painless death by <font color='green'>Chef Excellence's Special Sauce</font>.</font>"

/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = MINTTOXIN
	description = "Useful for dealing with undesirable customers."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	density = 0.898
	specheatcap = 3.58

/datum/reagent/minttoxin/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(M_FAT in M.mutations)
		M.gib()


/datum/reagent/muhhardcores
	name = "Hardcores"
	id = BUSTANUT
	description = "Concentrated hardcore beliefs."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFF000"
	custom_metabolism = 0.01

/datum/reagent/muhhardcores/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(1))
		if(prob(90))
			to_chat(M, "<span class='notice'>[pick("You feel quite hardcore", "Coderbased is your god", "Fucking kickscammers Bustration will be the best")].")
		else
			M.say(pick("Muh hardcores.", "Falling down is a feature.", "Gorrillionaires and Booty Borgs when?"))

/datum/reagent/rogan
	name = "Rogan"
	id = ROGAN
	description = "Smells older than your grandpa."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#0000FF"
	custom_metabolism = 0.01

/datum/reagent/rogan/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(1))
		if(prob(42))
			to_chat(M, "<span class='notice'>[pick("Rogan?", "ROGAN.", "Food please.", "Wood please.", "Gold please.", "All hail, king of the losers!", "I'll beat you back to Age of Empires.", "Sure, blame it on your ISP.", "Start the game already!", "It is good to be the king.", "Long time, no siege.", "Nice town, I'll take it.", "Raiding party!", "Dadgum.", "Wololo.", "Attack an enemy now.", "Cease creating extra villagers.", "Create extra villagers.", "Build a navy.", "	Stop building a navy.", "Wait for my signal to attack.", "Build a wonder.", "Give me your extra resources.", "What age are you in?")]")
		else
			M.say("Rogan?")

/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = SLIMEJELLY
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#801E28" //rgb: 128, 30, 40
	density = 0.8
	specheatcap = 1.24

/datum/reagent/slimejelly/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	var/mob/living/carbon/human/human = M
	if(!isslimeperson(human))
		if(prob(10))
			to_chat(M, "<span class='warning'>Your insides are burning!</span>")
			M.adjustToxLoss(rand(20, 60) * REM)
	if(prob(40))
		M.heal_organ_damage(5 * REM, 0)


/datum/reagent/vinegar
	name = "Vinegar"
	id = VINEGAR
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3F1900" //rgb: 63, 25, 0
	density = 0.79
	specheatcap = 2.46



/datum/reagent/gravy
	name = "Gravy"
	id = GRAVY
	description = "Aww, come on Double D, I don't say 'gravy' all the time."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#EDEDE1"

/datum/reagent/gravy/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == "Vox")
			M.adjustToxLoss(-4 * REM) //chicken and gravy just go together

/datum/reagent/cheesygloop
	name = "Cheesy Gloop"
	id = CHEESYGLOOP
	description = "This fatty, viscous substance is found only within the cheesiest of cheeses. Has the potential to cause heart stoppage."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFF00" //rgb: 255, 255, 0
	overdose_am = 5
	custom_metabolism = 0 //does not leave your body, clogs your arteries! puke or otherwise clear your system ASAP
	density = 0.14
	specheatcap = 0.7

/datum/reagent/cheesygloop/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/damagedheart = H.get_heart()
		damagedheart.damage++

/datum/reagent/maplesyrup
	name = "Maple Syrup"
	id = MAPLESYRUP
	description = "Reddish brown Canadian maple syrup, perfectly sweet and thick. Nutritious and effective at healing."
	color = "#7C1C04"
	alpha = 200
	nutriment_factor = 20 * REAGENTS_METABOLISM

/datum/reagent/maplesyrup/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.adjustOxyLoss(-2 * REM)
	M.adjustToxLoss(-2 * REM)
	M.adjustBruteLoss(-3 * REM)
	M.adjustFireLoss(-3 * REM)


/datum/reagent/fishbleach
	name = "Fish Bleach"
	id = FISHBLEACH
	description = "Just looking at this liquid makes you feel tranquil and peaceful. You aren't sure if you want to drink any however."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#12A7C9"

/datum/reagent/fishbleach/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	H.color = "#12A7C9"
	return


/datum/reagent/roach_shell
	name = "Cockroach chitin"
	id = ROACHSHELL
	description = "Looks like somebody's been shelling peanuts."
	reagent_state = REAGENT_STATE_SOLID
	color = "#8B4513"


/datum/reagent/liquidbutter
	name ="Liquid Butter"
	id = LIQUIDBUTTER
	description = "A lipid heavy liquid, that's likely to make your fad lipozine diet fail."
	color = "#DFDFDF"
	nutriment_factor = 25 * REAGENTS_METABOLISM

/datum/reagent/liquidbutter/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(holder.has_reagent(LIPOZINE))
		holder.remove_reagent(LIPOZINE, 50)

	M.nutrition += nutriment_factor

