/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum//////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Needs further subdivision. - N3X

/datum/reagent/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#E78108" // rgb: 231, 129, 8
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0

/datum/reagent/drink/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	if (adj_dizzy) M.dizziness = max(0,M.dizziness + adj_dizzy)
	if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)
	if (adj_temp)
		if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
			M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))
	// Drinks should be used up faster than other reagents.
	if(!holder)
		holder = M.reagents
	if(holder)
		holder.remove_reagent(src.id, FOOD_METABOLISM)
	..()
	return

/datum/reagent/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8

/datum/reagent/drink/orangejuice/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1*REM)
	return

/datum/reagent/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8

/datum/reagent/drink/tomatojuice/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if(M.getFireLoss() && prob(20)) M.heal_organ_damage(0,1)
	return

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	on_mob_life(var/mob/living/M as mob)

		if(!holder) return
		..()
		if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1)
		return

/datum/reagent/drink/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0

/datum/reagent/drink/carrotjuice/on_mob_life(var/mob/living/M as mob)
	if(!holder) return
	..()
	M.eye_blurry = max(M.eye_blurry-1 , 0)
	M.eye_blind = max(M.eye_blind-1 , 0)
	if(!data) data = 1
	switch(data)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if (prob(data-10))
				M.disabilities &= ~NEARSIGHTED
	data++
	return

/datum/reagent/drink/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51

/datum/reagent/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83

/datum/reagent/drink/poisonberryjuice/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	M.adjustToxLoss(1)
	return

/datum/reagent/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51

/datum/reagent/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0

/datum/reagent/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana."
	color = "#863333" // rgb: 175, 175, 0

/datum/reagent/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."

/datum/reagent/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/drink/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223

/datum/reagent/drink/milk/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10*REAGENTS_METABOLISM)
	..()
	return

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And coco beans."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	adj_temp = 5

/datum/reagent/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 25

/datum/reagent/drink/coffee/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if(!holder)
		holder = M.reagents
	if(holder)
		M.Jitter(5)
		if(adj_temp > 0 && holder.has_reagent("frostoil"))
			holder.remove_reagent("frostoil", 10*REAGENTS_METABOLISM)

		holder.remove_reagent(src.id, 0.1)

/datum/reagent/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp = -5

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/drink/coffee/soy_latte/on_mob_life(var/mob/living/M as mob)
		..()
		M.sleeping = 0
		if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
		return

/datum/reagent/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/drink/coffee/cafe_latte/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	M.sleeping = 0
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	return

/datum/reagent/drink/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp = 20

/datum/reagent/drink/tea/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)
	return

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "No relation to a certain rapper or actor."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp = -5

/datum/reagent/drink/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/kahlua/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	M.Jitter(5)
	return

/datum/reagent/drink/cold
	name = "Cold drink"
	adj_temp = -5

/datum/reagent/drink/cold/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/cold/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	adj_dizzy = -5
	adj_drowsy = -3

/datum/reagent/drink/cold/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148

/datum/reagent/drink/cold/space_cola
	name = "Cola"
	id = "cola"
	description = "A refreshing beverage."
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0
	adj_drowsy 	= 	-3

/datum/reagent/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	adj_sleepy = -2

/datum/reagent/drink/cold/nuke_cola/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M.Jitter(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness +=5
	M.drowsyness = 0
	..()
	return

/datum/reagent/drink/cold/spacemountainwind
	name = "Space Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -7
	adj_sleepy = -1

/datum/reagent/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -6

/datum/reagent/drink/cold/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" // rgb: 32, 40, 0
	adj_temp = -8

/datum/reagent/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	color = "#878F00" // rgb: 135, 40, 0
	adj_temp = -8

/datum/reagent/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	id = "lemonade"
	color = "#FFFF00" // rgb: 255, 255, 0

/datum/reagent/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = "kiraspecial"
	color = "#CCCC99" // rgb: 204, 204, 153

/datum/reagent/drink/cold/brownstar
	name = "Brown Star"
	description = "Its not what it sounds like..."
	id = "brownstar"
	color = "#9F3400" // rgb: 159, 052, 000
	adj_temp = - 2

/datum/reagent/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#AEE5E4" // rgb" 174, 229, 228
	adj_temp = -9

/datum/reagent/drink/cold/milkshake/on_mob_life(var/mob/living/M as mob)

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
			if(M.dna.mutantrace == "slime")
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

/datum/reagent/drink/cold/rewriter
	name = "Rewriter"
	description = "The secert of the sanctuary of the Libarian..."
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0

/datum/reagent/drink/cold/rewriter/on_mob_life(var/mob/living/M as mob)

		if(!holder) return
		..()
		M.Jitter(5)
		return

/datum/reagent/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/hippies_delight/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 50)
	if(!data) data = 1
	switch(data)
		if(1 to 5)
			if (!M.stuttering) M.stuttering = 1
			M.Dizzy(10)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 45)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(40)
			M.Dizzy(40)
			M.druggy = max(M.druggy, 60)
			if(prob(30)) M.emote(pick("twitch","giggle"))
	holder.remove_reagent(src.id, 0.2)
	data++
	..()
	return

//ALCOHOL WOO
/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	var/dizzy_adj = 3
	var/slurr_adj = 3
	var/confused_adj = 2
	var/slur_start = 65			//amount absorbed after which mob starts slurring
	var/confused_start = 130	//amount absorbed after which mob starts confusing directions
	var/blur_start = 260	//amount absorbed after which mob starts getting blurred vision
	var/pass_out = 450	//amount absorbed after which mob starts passing out

/datum/reagent/ethanol/on_mob_life(var/mob/living/M as mob)

	if(!holder || !M.reagents) return
	// Sobering multiplier.
	// Sober block makes it more difficult to get drunk
	var/sober_str=!(M_SOBER in M.mutations)?1:2

	M:nutrition += nutriment_factor
	if(!holder)
		holder = M.reagents
	if(!holder)
		if(!M.loc || M.timeDestroyed)
			del(src) //panic
		M.create_reagents(1000)
		holder = M.reagents
	if(holder)
		holder.remove_reagent(src.id, FOOD_METABOLISM)
	if(!src.data) data = 1
	src.data++

	var/d = data
	if(!holder)
		del(src)
	// make all the beverages work together
	for(var/datum/reagent/ethanol/A in holder.reagent_list)
		if(isnum(A.data)) d += A.data

	d/=sober_str

	M.dizziness +=dizzy_adj.
	if(d >= slur_start && d < pass_out)
		if (!M:slurring) M:slurring = 1
		M:slurring += slurr_adj/sober_str
	if(d >= confused_start && prob(33))
		if (!M:confused) M:confused = 1
		M.confused = max(M:confused+(confused_adj/sober_str),0)
	if(d >= blur_start)
		M.eye_blurry = max(M.eye_blurry, 10/sober_str)
		M:drowsyness  = max(M:drowsyness, 0)
	if(d >= pass_out)
		M:paralysis = max(M:paralysis, 20/sober_str)
		M:drowsyness  = max(M:drowsyness, 30/sober_str)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if (!L)
				H.adjustToxLoss(5)
			else if(istype(L))
				L.take_damage(0.05, 1)
			H.adjustToxLoss(0.1)
	if(!holder)
		holder = M.reagents
	if(holder)
		holder.remove_reagent(src.id, 0.4)
	..()
	return


/datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		usr << "The solution melts away the ink on the paper."
	if(istype(O,/obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			usr << "The solution melts away the ink on the book."
		else
			usr << "It wasn't enough..."
	return

/datum/reagent/ethanol/beer	//It's really much more stronger than other drinks.
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	on_mob_life(var/mob/living/M as mob)
		..()
		M:jitteriness = max(M:jitteriness-3,0)
		return

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4

/datum/reagent/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300" // rgb: 102, 67, 0
	slur_start = 30		//amount absorbed after which mob starts slurring

/datum/reagent/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 3

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33EE00" // rgb: lots, ??, ??
	dizzy_adj = 5
	slur_start = 25
	confused_start = 100

				//copy paste from LSD... shoot me
/datum/reagent/ethanol/absinthe/on_mob_life(var/mob/M)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	M:hallucination += 5
	if(volume > REAGENTS_OVERDOSE)
		M:adjustToxLoss(1)
	..()
	return

/datum/reagent/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Yohoho and all that."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/tequilla
	name = "Tequila"
	id = "tequilla"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	//boozepwr = 2

/datum/reagent/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	//boozepwr = 1.5

/datum/reagent/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	//boozepwr = 1.5
	dizzy_adj = 2
	slur_start = 65			//amount absorbed after which mob starts slurring
	confused_start = 145	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	//boozepwr = 1.5
	dizzy_adj = 4
	confused_start = 115	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	//boozepwr = 2
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35			//amount absorbed after which mob starts slurring
	confused_start = 90	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	//boozepwr = 1

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33EE00" // rgb: 51, 238, 0
	//boozepwr = 4
	dizzy_adj = 5
	slur_start = 15
	confused_start = 30


/datum/reagent/ethanol/pwine
	name = "Poison Wine"
	id = "pwine"
	description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
	color = "#000000" // rgb: 0, 0, 0 SHOCKER
	//boozepwr = 1
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1

/datum/reagent/ethanol/pwine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 50)
	if(!data) data = 1
	data++
	switch(data)
		if(1 to 25)
			if (!M.stuttering) M.stuttering = 1
			M.Dizzy(1)
			M.hallucination = max(M.hallucination, 3)
			if(prob(1)) M.emote(pick("twitch","giggle"))
		if(25 to 75)
			if (!M.stuttering) M.stuttering = 1
			M.hallucination = max(M.hallucination, 10)
			M.Jitter(2)
			M.Dizzy(2)
			M.druggy = max(M.druggy, 45)
			if(prob(5)) M.emote(pick("twitch","giggle"))
		if (75 to 150)
			if (!M.stuttering) M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10)) M.emote(pick("twitch","giggle"))
			if(prob(30)) M.adjustToxLoss(2)
		if (150 to 300)
			if (!M.stuttering) M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10)) M.emote(pick("twitch","giggle"))
			if(prob(30)) M.adjustToxLoss(2)
			if(prob(5)) if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
				if (L && istype(L))
					L.take_damage(5, 0)
		if (300 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
				if (L && istype(L))
					L.take_damage(100, 0)
	holder.remove_reagent(src.id, FOOD_METABOLISM)

/datum/reagent/ethanol/deadrum
	name = "Deadrum"
	id = "rum"
	description = "Popular with the sailors. Not very popular with everyone else."
	color = "#664300" // rgb: 102, 67, 0
	//boozepwr = 1

/datum/reagent/ethanol/deadrum/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	M.dizziness +=5
	if(volume > REAGENTS_OVERDOSE)
		M:adjustToxLoss(1)
	return

/datum/reagent/ethanol/deadrum/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sake
	name = "Sake"
	id = "sake"
	description = "Anime's favorite drink."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/tequilla
	name = "Tequila"
	id = "tequilla"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#A8B0B7" // rgb: 168, 176, 183

/datum/reagent/ethanol/deadrum/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65			//amount absorbed after which mob starts slurring
	confused_start = 145	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/deadrum/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	confused_start = 115	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/deadrum/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35			//amount absorbed after which mob starts slurring
	confused_start = 90	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/deadrum/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0

/datum/reagent/ethanol/deadrum/thirteenloko/on_mob_life(var/mob/living/M as mob)

	..()
	if(!holder) return
	M:nutrition += nutriment_factor
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	M:drowsyness = max(0,M:drowsyness-7)
	//if(!M:sleeping_willingly)
	//	M:sleeping = max(0,M.sleeping-2)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature-5)
	M.Jitter(1)
	return


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/ethanol/deadrum/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = LIQUID
	color = "#895C4C" // rgb: 137, 92, 76

/datum/reagent/ethanol/deadrum/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0

/datum/reagent/ethanol/deadrumm/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	reagent_state = LIQUID
	color = "#666340" // rgb: 102, 99, 64

/datum/reagent/ethanol/deadrum/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	reagent_state = LIQUID
	color = "#585840" // rgb: 88, 88, 64

/datum/reagent/ethanol/deadrum/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0

/datum/reagent/ethanol/deadrum/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0

/datum/reagent/ethanol/deadrum/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	reagent_state = LIQUID
	color = "#A68340" // rgb: 166, 131, 64

/datum/reagent/ethanol/deadrum/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/tequilla_sunrise
	name = "Tequila Sunrise"
	id = "tequillasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	reagent_state = LIQUID
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/doctor_delight/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	M:nutrition += nutriment_factor
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	if(!M) M = holder.my_atom
	if(M:getOxyLoss() && prob(50)) M:adjustOxyLoss(-2)
	if(M:getBruteLoss() && prob(60)) M:heal_organ_damage(2,0)
	if(M:getFireLoss() && prob(50)) M:heal_organ_damage(0,2)
	if(M:getToxLoss() && prob(50)) M:adjustToxLoss(-2)
	if(M.dizziness !=0) M.dizziness = max(0,M.dizziness-15)
	if(M.confused !=0) M.confused = max(0,M.confused - 5)
	..()
	return

/datum/reagent/ethanol/deadrum/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and congac. You will get bombed."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = LIQUID
	color = "#360000" // rgb: 54, 0, 0

/datum/reagent/ethanol/deadrum/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scienitst's drink of choice, for pondering ways to blow up the station."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "Ultimate refreshment."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 10
	slurr_adj = 10

/datum/reagent/ethanol/deadrum/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/deadrum/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/deadrum/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropic cocktail."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 15
	slurr_adj = 15

/datum/reagent/ethanol/deadrum/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sbiten/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if (M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature+50) //310 is the normal bodytemp. 310.055
	return

/datum/reagent/ethanol/deadrum/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking drink! Even though it has a strange red color."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/mead
	name = "Mead"
	id = "mead"
	description = "A Vikings drink, though a cheap one."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/iced_beer/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if (M.bodytemperature < 270)
		M.bodytemperature = min(270, M.bodytemperature-40) //310 is the normal bodytemp. 310.055
	return

/datum/reagent/ethanol/deadrum/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, NanoTrasen approves!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strange named drink."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink by NanoTrasen. Made from live aliens."
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0

/datum/reagent/ethanol/deadrum/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the Imperium."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/amasec/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	M.stunned = 4
	return

/datum/reagent/ethanol/deadrum/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = LIQUID
	color = "#2E2E61" // rgb: 46, 46, 97

/datum/reagent/ethanol/deadrum/neurotoxin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	if(!M) M = holder.my_atom
	M:adjustOxyLoss(0.5)
	M:adjustOxyLoss(0.5)
	M:weakened = max(M:weakened, 15)
	M:silent = max(M:silent, 15)
	return

/datum/reagent/ethanol/deadrum/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "A stingy drink."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/changelingsting/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness +=5
	return

/datum/reagent/ethanol/deadrum/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is, it's green!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irishcarbomb/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	..()
	M.dizziness +=5
	return

/datum/reagent/ethanol/deadrum/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "A Syndicate bomb"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/driestmartini/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!data) data = 1
	data++
	M.dizziness +=10
	if(data >= 55 && data <115)
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 10
	else if(data >= 115 && prob(33))
		M.confused = max(M.confused+15,15)
	..()
	return