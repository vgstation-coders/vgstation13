//////////////////////
//					//
//     DRINKS		//
//					//
//////////////////////


/datum/reagent/coco/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/hot_coco
	name = "Hot Chocolate"
	id = HOT_COCO
	description = "Made with love! And coco beans."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" //rgb: 64, 48, 16

/datum/reagent/hot_coco/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

	M.nutrition += nutriment_factor



/datum/reagent/drink
	name = "Drink"
	id = DRINK
	description = "Uh, some kind of drink."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#E78108" //rgb: 231, 129, 8
	custom_metabolism = FOOD_METABOLISM
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0

/datum/reagent/drink/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor * REM

	if(adj_dizzy)
		M.dizziness = max(0,M.dizziness + adj_dizzy)
	if(adj_drowsy)
		M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if(adj_sleepy)
		M.sleeping = max(0,M.sleeping + adj_sleepy)
	if(adj_temp > 0 && M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(adj_temp < 0 && M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/drink/orangejuice
	name = "Orange juice"
	id = ORANGEJUICE
	description = "Both delicious AND rich in Vitamin C. What more do you need?"
	color = "#E78108" //rgb: 231, 129, 8
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/orangejuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-REM)

/datum/reagent/drink/tomatojuice
	name = "Tomato Juice"
	id = TOMATOJUICE
	description = "Tomatoes made into juice. What a waste of good tomatoes, huh?"
	color = "#731008" //rgb: 115, 16, 8
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/tomatojuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getFireLoss() && prob(20))
		M.heal_organ_damage(0, 1)

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = LIMEJUICE
	description = "The sweet-sour juice of limes."
	color = "#BBB943" //rgb: 187, 185, 67
	alpha = 170
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/limejuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/drink/carrotjuice
	name = "Carrot juice"
	id = CARROTJUICE
	description = "It's like a carrot, but less crunchy."
	color = "#973800" //rgb: 151, 56, 0
	nutriment_factor = 5 * REAGENTS_METABOLISM
	data = 1 //Used as a tally

/datum/reagent/drink/carrotjuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.eye_blurry = max(M.eye_blurry - 1 , 0)
	M.eye_blind = max(M.eye_blind - 1 , 0)
	switch(data)
		if(21 to INFINITY)
			if(prob(data - 10))
				M.disabilities &= ~NEARSIGHTED
	data++

/datum/reagent/drink/grapejuice
	name = "Grape Juice"
	id = GRAPEJUICE
	description = "Freshly squeezed juice from red grapes. Quite sweet."
	color = "#512284" //rgb: 81, 34, 132
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/ggrapejuice
	name = "Green Grape Juice"
	id = GGRAPEJUICE
	description = "Freshly squeezed juice from green grapes. Smoothly sweet."
	color = "#B79E42" //rgb: 183, 158, 66
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/berryjuice
	name = "Berry Juice"
	id = BERRYJUICE
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" //rgb: 134, 51, 51
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = POISONBERRYJUICE
	description = "A surprisingly tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" //rgb: 134, 51, 83

/datum/reagent/drink/poisonberryjuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(1)

/datum/reagent/drink/watermelonjuice
	name = "Watermelon Juice"
	id = WATERMELONJUICE
	description = "The delicious juice of a watermelon."
	color = "#EF3520" //rgb: 239, 53, 32
	alpha = 240
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/applejuice
	name = "Apple Juice"
	id = APPLEJUICE
	description = "Tastes of New York."
	color = "#FDAD01" //rgb: 253, 173, 1
	alpha = 150
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/lemonjuice
	name = "Lemon Juice"
	id = LEMONJUICE
	description = "This juice is VERY sour."
	color = "#C6BB6E" //rgb: 198, 187, 110
	alpha = 170
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/banana
	name = "Banana Juice"
	id = BANANA
	description = "The raw essence of a banana."
	color = "#FFEBC1" //rgb: 255, 235, 193
	alpha = 255
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/nothing
	name = "Nothing"
	id = NOTHING
	description = "Absolutely nothing."
	nutriment_factor = 0

/datum/reagent/drink/nothing/on_mob_life(var/mob/living/M)

    if(ishuman(M))
        var/mob/living/carbon/human/H = M
        if(H.mind.miming)
            if(M.getOxyLoss() && prob(80))
                M.adjustOxyLoss(-REM)
            if(M.getBruteLoss() && prob(80))
                M.heal_organ_damage(REM, 0)
            if(M.getFireLoss() && prob(80))
                M.heal_organ_damage(0, REM)
            if(M.getToxLoss() && prob(80))
                M.adjustToxLoss(-REM)

/datum/reagent/drink/potato_juice
	name = "Potato Juice"
	id = POTATO
	description = "Juice of the potato. Bleh."
	nutriment_factor = 5 * FOOD_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/drink/plumphjuice
	name = "Plump Helmet Juice"
	id = PLUMPHJUICE
	description = "Eeeewwwww."
	nutriment_factor = 5 * FOOD_METABOLISM
	color = "#A28691" //rgb: 162, 134, 145

/datum/reagent/drink/milk
	name = "Milk"
	id = MILK
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" //rgb: 223, 223, 223
	alpha = 240
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/milk/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10 * REAGENTS_METABOLISM)
	if(prob(50))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = SOYMILK
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" //rgb: 223, 223, 199
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = CREAM
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" //rgb: 223, 215, 175
	nutriment_factor = 5 * REAGENTS_METABOLISM
	density = 2.37
	specheatcap = 1.38

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = HOT_COCO
	description = "Made with love! And cocoa beans."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#403010" //rgb: 64, 48, 16
	adj_temp = 5
	density = 1.2
	specheatcap = 4.18

/datum/reagent/drink/coffee
	name = "Coffee"
	id = COFFEE
	description = "Coffee is a brewed drink prepared from the roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" //rgb: 72, 32, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 25
	custom_metabolism = 0.1
	var/causes_jitteriness = 1

/datum/reagent/drink/coffee/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(causes_jitteriness)
		M.Jitter(5)
	if(adj_temp > 0 && holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 10 * REAGENTS_METABOLISM)

/datum/reagent/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = ICECOFFEE
	description = "Coffee and ice. Refreshing and cool."
	color = "#102838" //rgb: 16, 40, 56
	adj_temp = -5

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = SOY_LATTE
	description = "The hipster version of the classic cafe latte."
	color = "#664300" //rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/drink/coffee/soy_latte/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.sleeping = 0

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/coffee/cafe_latte
	name = "Latte"
	id = CAFE_LATTE
	description = "A true classic: steamed milk, some espresso, and foamed milk to top it all off."
	color = "#664300" //rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/drink/coffee/cafe_latte/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.sleeping = 0

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/tea
	name = "Tea"
	id = TEA
	description = "Tasty black tea. It has antioxidants and is good for you!"
	color = "#101000" //rgb: 16, 16, 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp = 20

/datum/reagent/drink/tea/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	id = ICETEA
	description = "Like tea, but refreshes rather than relaxes."
	color = "#104038" //rgb: 16, 64, 56
	adj_temp = -5
	density = 1
	specheatcap = 1

/datum/reagent/drink/tea/arnoldpalmer
	name = "Arnold Palmer"
	id = ARNOLDPALMER
	description = "Known as half and half to some. A mix of ice tea and lemonade."
	color = "#104038" //rgb: 16, 64, 56
	adj_temp = -5
	adj_sleepy = -3
	adj_dizzy = -1
	adj_drowsy = -3

/datum/reagent/drink/kahlua
	name = "Kahlua"
	id = KAHLUA
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" //rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/kahlua/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold
	name = "Cold drink"
	adj_temp = -5

/datum/reagent/drink/cold/tonic
	name = "Tonic Water"
	id = TONIC
	description = "It tastes strange but at least the quinine keeps the space malaria at bay."
	color = "#664300" //rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/cold/sodawater
	name = "Soda Water"
	id = SODAWATER
	description = "Effervescent water used in many cocktails and drinks."
	color = "#619494" //rgb: 97, 148, 148
	adj_dizzy = -5
	adj_drowsy = -3

/datum/reagent/drink/cold/ice
	name = "Ice"
	id = ICE
	description = "Frozen water. Your dentist wouldn't like you chewing this."
	reagent_state = REAGENT_STATE_SOLID
	color = "#619494" //rgb: 97, 148, 148
	density = 0.91
	specheatcap = 4.18

/datum/reagent/drink/cold/space_cola
	name = "Cola"
	id = COLA
	description = "A refreshing beverage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#100800" //rgb: 16, 8, 0
	adj_drowsy 	= 	-3

/datum/reagent/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = NUKA_COLA
	description = "Cola. Cola never changes."
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	density = 4.17
	specheatcap = 124

/datum/reagent/drink/cold/nuka_cola/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/drink/cold/spacemountainwind
	name = "Space Mountain Wind"
	id = SPACEMOUNTAINWIND
	description = "Blows right through you like a space wind."
	color = "#102000" //rgb: 16, 32, 0
	adj_drowsy = -7
	adj_sleepy = -1

/datum/reagent/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = DR_GIBB
	description = "A delicious blend of 42 different flavors."
	color = "#102000" //rgb: 16, 32, 0
	adj_drowsy = -6

/datum/reagent/drink/cold/space_up
	name = "Space-Up"
	id = SPACE_UP
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" //rgb: 32, 40, 0
	adj_temp = -8

/datum/reagent/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = LEMON_LIME
	color = "#878F00" //rgb: 135, 40, 0
	adj_temp = -8

/datum/reagent/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh, the nostalgia..."
	id = LEMONADE
	color = "#FFFF00" //rgb: 255, 255, 0

/datum/reagent/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = KIRASPECIAL
	color = "#CCCC99" //rgb: 204, 204, 153

/datum/reagent/drink/cold/brownstar
	name = "Brown Star"
	description = "Its not what it sounds like..."
	id = BROWNSTAR
	color = "#9F3400" //rgb: 159, 052, 000
	adj_temp = -2

/datum/reagent/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = MILKSHAKE
	color = "#AEE5E4" //rgb" 174, 229, 228
	adj_temp = -9
	custom_metabolism = FOOD_METABOLISM
	data = 1 //Used as a tally

/datum/reagent/drink/cold/milkshake/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature -= 0.1 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 0.2 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature -= 0.3 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(15,20)
	data++

/datum/reagent/drink/cold/rewriter
	name = "Rewriter"
	description = "The librarian's special."
	id = REWRITER
	color = "#485000" //rgb:72, 080, 0

/datum/reagent/drink/cold/rewriter/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold/diy_soda
	name = "Dr. Pecker's DIY Soda"
	description = "Tastes like a science fair experiment."
	id = DIY_SODA
	color = "#7566FF" //rgb: 117, 102, 255
	adj_temp = -2
	adj_drowsy = -6

/datum/reagent/drink/cold/diy_soda/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/hippies_delight
	name = "Hippie's Delight"
	id = HIPPIESDELIGHT
	description = "You just don't get it, maaaan."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	data = 1 //Used as a tally

/datum/reagent/hippies_delight/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.druggy = max(M.druggy, 50)
	switch(data)
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(10)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 45)
			if(prob(20))
				M.emote(pick("twitch", "giggle"))
		if(10 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(40)
			M.Dizzy(40)
			M.druggy = max(M.druggy, 60)
			if(prob(30))
				M.emote(pick("twitch", "giggle"))
	data++

//ALCOHOL WOO
/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = ETHANOL
	description = "A well-known alcohol with a variety of applications."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" //RGB: 64, 64, 48
	custom_metabolism = FOOD_METABOLISM
	density = 0.79
	specheatcap = 2.46
	var/dizzy_adj = 3
	var/slurr_adj = 3
	var/confused_adj = 2
	var/slur_start = 65 //Amount absorbed after which mob starts slurring
	var/confused_start = 130 //Amount absorbed after which mob starts confusing directions
	var/blur_start = 260 //Amount absorbed after which mob starts getting blurred vision
	var/pass_out = 450 //Amount absorbed after which mob starts passing out
	var/common_data = 1 //Needed to add all ethanol subtype's datas

/datum/reagent/ethanol/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	//Sobering multiplier
	//Sober block makes it more difficult to get drunk
	var/sober_str =! (M_SOBER in M.mutations) ? 1 : 2

	M.nutrition += REM*nutriment_factor
	data++

	data /= sober_str

	//Make all the ethanol-based beverages work together
	common_data = 0

	if(holder.reagent_list) //Sanity
		for(var/datum/reagent/ethanol/A in holder.reagent_list)
			if(isnum(A.data))
				common_data += A.data

	M.dizziness += dizzy_adj
	if(common_data >= slur_start && data < pass_out)
		if(!M.slurring)
			M.slurring = 1
		M.slurring += slurr_adj/sober_str
	if(common_data >= confused_start && prob(33))
		if(!M.confused)
			M.confused = 1
		M.confused = max(M.confused+(confused_adj/sober_str), 0)
	if(common_data >= blur_start)
		M.eye_blurry = max(M.eye_blurry, 10/sober_str)
		M.drowsyness  = max(M.drowsyness, 0)
	if(common_data >= pass_out)
		M.paralysis = max(M.paralysis, 20/sober_str)
		M.drowsyness  = max(M.drowsyness, 30/sober_str)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if(!L)
				H.adjustToxLoss(5)
			else if(istype(L))
				L.take_damage(0.05, 0.5)
			H.adjustToxLoss(0.5)

/datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		if(paperaffected.info || paperaffected.stamps)
			paperaffected.clearpaper()
			O.visible_message("<span class='warning'>The solution melts away \the [O]'s ink.</span>")

	if(istype(O, /obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			if(affectedbook.dat)
				affectedbook.dat = null
				O.visible_message("<span class='warning'>The solution melts away \the [O]'s ink.</span>")

//It's really much more stronger than other drinks
/datum/reagent/ethanol/beer
	name = "Beer"
	id = BEER
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/beer/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.jitteriness = max(M.jitteriness - 3, 0)

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = WHISKEY
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	pass_out = 225

/datum/reagent/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = SPECIALWHISKEY
	description = "Just when you thought regular station whiskey was good..."
	color = "#664300" //rgb: 102, 67, 0
	slur_start = 30
	pass_out = 225

/datum/reagent/ethanol/gin
	name = "Gin"
	id = GIN
	description = "It's gin. In space. I say, good sir."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 3
	pass_out = 260

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = ABSINTHE
	description = "Watch out that the Green Fairy doesn't get you!"
	color = "#33EE00" //rgb: lots, ??, ??
	dizzy_adj = 5
	slur_start = 25
	confused_start = 100
	pass_out = 175

//Copy paste from LSD... shoot me
/datum/reagent/ethanol/absinthe/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	data++
	M.hallucination += 5

/datum/reagent/ethanol/rum
	name = "Rum"
	id = RUM
	description = "Yohoho and all that."
	color = "#664300" //rgb: 102, 67, 0
	pass_out = 250

/datum/reagent/ethanol/tequila
	name = "Tequila"
	id = TEQUILA
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty, hombre?"
	color = "#FFFF91" //rgb: 255, 255, 145

/datum/reagent/ethanol/vermouth
	name = "Vermouth"
	id = VERMOUTH
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" //rgb: 145, 255, 145

/datum/reagent/ethanol/wine
	name = "Wine"
	id = WINE
	description = "A premium alcoholic beverage made from fermented grape juice."
	color = "#7E4043" //rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/bwine
	name = "Berry Wine"
	id = BWINE
	description = "Sweet berry wine!"
	color = "#C760A2" //rgb: 199, 96, 162
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/wwine
	name = "White Wine"
	id = WWINE
	description = "A premium alcoholic beverage made from fermented green grape juice."
	color = "#C6C693" //rgb: 198, 198, 147
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/plumphwine
	name = "Plump Helmet Wine"
	id = PLUMPHWINE
	description = "A very peculiar wine made from fermented plump helmet mushrooms. Popular among asteroid dwellers."
	color = "#800080" //rgb: 128, 0, 128
	dizzy_adj = 3 //dorf wine is a bit stronger than regular stuff
	slur_start = 60
	confused_start = 135

/datum/reagent/ethanol/cognac
	name = "Cognac"
	id = COGNAC
	description = "A sweet and strongly alcoholic drink, twice distilled and left to mature for several years. Classy as fornication."
	color = "#AB3C05" //rgb: 171, 60, 5
	dizzy_adj = 4
	confused_start = 115

/datum/reagent/ethanol/hooch
	name = "Hooch"
	id = HOOCH
	description = "A suspiciously viscous off-brown liquid that reeks of fuel. Do you really want to drink that?"
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35
	confused_start = 90

/datum/reagent/ethanol/ale
	name = "Ale"
	id = ALE
	description = "A dark alcoholic beverage made from malted barley and yeast."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/pwine
	name = "Poison Wine"
	id = PWINE
	description = "Is this even wine? Toxic, hallucinogenic, foul-tasting... Why would you drink this?"
	color = "#000000" //rgb: 0, 0, 0
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1

/datum/reagent/ethanol/pwine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.druggy = max(M.druggy, 50)
	switch(data)
		if(1 to 25)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(1)
			M.hallucination = max(M.hallucination, 3)
			if(prob(1))
				M.emote(pick("twitch", "giggle"))
		if(25 to 75)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 10)
			M.Jitter(2)
			M.Dizzy(2)
			M.druggy = max(M.druggy, 45)
			if(prob(5))
				M.emote(pick("twitch", "giggle"))
		if(75 to 150)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
		if(150 to 300)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
			if(prob(5))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
					if(L && istype(L))
						L.take_damage(5, 0)
		if(300 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
				if(L && istype(L))
					L.take_damage(100, 0)
	data++

/datum/reagent/ethanol/karmotrine
	name = "Karmotrine"
	id = KARMOTRINE
	description = "A thick, light blue liquid extracted from strange plants."
	color = "#66ffff" //rgb(102, 255, 255)
	blur_start = 40 //Blur very early

/datum/reagent/ethanol/smokyroom
	name = "Smoky Room"
	id = SMOKYROOM
	description = "It was the kind of cool, black night that clung to you like something real... a black, tangible fabric of smoke, deceit, and murder. I had finished working my way through the fat cigars for the day - or at least told myself that to feel the sense of accomplishment for another night wasted on little more than chasing cheating dames and abusive husbands. It was enough to drive a man to drink... and it did. I sauntered into the cantina and wordlessly nodded to the barman. He knew my poison. I was a regular, after all. By the time the night was over, there would be another empty bottle and a case no closer to being cracked. Then I saw her, like a mirage across a desert, or a striken starlet on stage across a smoky room."
	color = "#664300"

/datum/reagent/ethanol/smokyroom/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(4)) //Small chance per tick to some noir stuff and gain NOIRBLOCK if we don't have it.
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!(M_NOIR in H.mutations))
				H.mutations += M_NOIR
				H.dna.SetSEState(NOIRBLOCK,1)
				genemutcheck(H, NOIRBLOCK, null, MUTCHK_FORCED)

		M.say(pick("The station corridors were heartless and cold, like the fickle 'love' of some hysterical dame.",
			"The lights, the smoke, the grime... the station itself seemed alive that day. Was it the pulse that made me think so? Or just all the blood?",
			"I caressed my .44 magnum. Ever since Jimmy bit it against the Two Bit Gang, the gun and its six rounds were the only partner I could trust. Never a single jam to trap me in another.",
			"The whole reason I took the case to begin with was trouble, in the shape of a pinup blonde with shanks that'd make you dizzy. Wouldn't give her name, said she was related to the captain. I doubt she was even on the manifest.",
			"According to the boys in the lab, the perp took a sander to the tooth profiles, but did a sloppy job. Lab report came in early this morning. Guess my vacation is on pause.",
			"The blacktop was baking that day, and the broads working 19th and Main were wearing even less than usual.",
			"The young dame was the pride and joy of the station. Little did she know that looks can breed envy... or worse.",
			"The new case reeked of the same bad blood as that now half-forgotten case of the turncoat chef. A recipe for murder.",
			"I dragged myself out of my drink-addled torpor and called to the shadowy figure at my door - come in - because if I didn't take a new case I'd be through my bottle by noon.",
			"Nursing my scotch, I turned my gaze upward and spotted trouble in the form of a bruiser with brass knuckles across the smoke-filled nightclub's cabaret.",
			"I didn't even know who she was. Just stumbled across a girl and four toughs. Took her home and the mayor named me a hero.",
			"She was a flapper and a swinger, but she was also in some hot water. Told me she'd make it worth my while if I could get her out of it. I told her that I wanted payment in cold hard simoleons.",
			"What he did just didn't compare. He killed an innocent person. What drives a man to kill in cold blood? I didn't want to hang around and find out.",
			"I breathed in the smoke of the underground speakeasy like a fish breathes water. The brass at the precinct couldn't understand: I was in my element.",
			"I put enough holes in the man to drop a goliath, but he kept coming. Some kind of blood-fueled hatred. The adrenaline of a dying man can snap bones in one last moment of spite. I can still see the anger in those dying eyes.",
			"Charlie's SPS sang its monotone dirge somewhere deep in the tunnels. I'd told him to watch his back, but the blood of rookies flows hot and fast. I took a long swig of scotch and lit a cigarette. Another good man lost.",
			"The scene was a mess. Three bodies, or what was left of them, the floor covered in blood and strange markings. I thought the shift couldn't possibly get any worse. A flash of blood red on pitch black in the corner of my eye proved me wrong.",
			"The martini was as dry as the barkeep's humor. How do I always find myself in this run-down hovel, I wondered as I lost myself in the drink.",
			"The coroner looked up from his papers and nodded at me. The mutilated body was none other than my damsel in distress. I cursed under my breath. Who would pay me now?"))

/datum/reagent/ethanol/rags_to_riches
	name = "Rags to Riches"
	id = RAGSTORICHES
	description = "The Spaceman Dream, incarnated as a cocktail."
	color = "#664300"
	dupeable = FALSE

/datum/reagent/ethanol/rags_to_riches/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(!M.loc || prob(70))
		return
	playsound(get_turf(M), pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 50, 1)
	dispense_cash(rand(5,15),get_turf(M))

/datum/reagent/ethanol/bad_touch
	name = "Bad Touch"
	id = BAD_TOUCH
	description = "On the scale of bad touches, somewhere between 'fondled by clown' and 'brushed by supermatter shard'."
	color = "#664300"

/datum/reagent/ethanol/bad_touch/on_mob_life(var/mob/living/M) //Hallucinate and take hallucination damage.
	if(..())
		return 1
	M.hallucination = max(M.hallucination, 10)
	M.halloss += 5

/datum/reagent/ethanol/electric_sheep
	name = "Electric Sheep"
	id = ELECTRIC_SHEEP
	description = "Silicons dream of this."
	color = "#664300"
	custom_metabolism = 1

/datum/reagent/ethanol/electric_sheep/on_mob_life(var/mob/living/M) //If it's human, shoot sparks every tick! If MoMMI, cause alcohol effects.
	if(..())
		return 1
	if(ishuman(M))
		spark(M, 5, FALSE)

/datum/reagent/ethanol/electric_sheep/reaction_mob(var/mob/living/M)
	if(isrobot(M))
		M.Jitter(20)
		M.Dizzy(20)
		M.druggy = max(M.druggy, 60)

/datum/reagent/ethanol/suicide
	name = "Suicide"
	id = SUICIDE
	description = "It's only tolerable because of the added alcohol."
	color = "#664300"
	custom_metabolism = 2

/datum/reagent/ethanol/suicide/on_mob_life(var/mob/living/M)  //Instant vomit. Every tick.
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(0,1)

/datum/reagent/ethanol/metabuddy
	name = "Metabuddy"
	id = METABUDDY
	description = "Ban when?"
	color = "#664300"
	var/global/list/datum/mind/metaclub = list()

/datum/reagent/ethanol/metabuddy/on_mob_life(var/mob/living/L)
	if(..())
		return 1
	var/datum/mind/LM = L.mind
	if(!metaclub.Find(LM) && LM)
		metaclub += LM
		var/datum/mind/new_buddy = LM
		for(var/datum/mind/M in metaclub) //Update metaclub icons
			if(M.current.client && new_buddy.current && new_buddy.current.client)
				var/imageloc = new_buddy.current
				var/imagelocB = M.current
				if(istype(M.current.loc,/obj/mecha))
					imageloc = M.current.loc
					imagelocB = M.current.loc
				var/image/I = image('icons/mob/HUD.dmi', loc = imageloc, icon_state = "metaclub")
				I.plane = METABUDDY_HUD_PLANE
				M.current.client.images += I
				var/image/J = image('icons/mob/HUD.dmi', loc = imagelocB, icon_state = "metaclub")
				J.plane = METABUDDY_HUD_PLANE
				new_buddy.current.client.images += J

/datum/reagent/ethanol/waifu
	name = "Waifu"
	id = WAIFU
	description = "Don't drink more than one waifu if you value your laifu."
	color = "#664300"

/datum/reagent/ethanol/waifu/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.gender == MALE)
		M.setGender(FEMALE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!M.is_wearing_item(/obj/item/clothing/under/schoolgirl))
			var/turf/T = get_turf(H)
			T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg',anim_plane = MOB_PLANE)
			H.visible_message("<span class='warning'>[H] dons her magical girl outfit in a burst of light!</span>")
			var/obj/item/clothing/under/schoolgirl/S = new /obj/item/clothing/under/schoolgirl(get_turf(H))
			if(H.w_uniform)
				H.u_equip(H.w_uniform, 1)
			H.equip_to_slot(S, slot_w_uniform)
			holder.remove_reagent(WAIFU,4) //Generating clothes costs extra reagent
	M.regenerate_icons()

/datum/reagent/ethanol/scientists_serendipity
	name = "Scientist's Serendipity"
	id = SCIENTISTS_SERENDIPITY
	description = "Go ahead and blow the research budget on drinking this." //Can deconstruct a glass with this for loadsoftech
	color = "#664300"
	custom_metabolism = 0.01
	dupeable = FALSE

/datum/reagent/ethanol/beepskyclassic
	name = "Beepsky Classic"
	id = BEEPSKY_CLASSIC
	description = "Some believe that the more modern Beepsky Smash was introduced to make this drink more popular."
	color = "#664300" //rgb: 102, 67, 0
	custom_metabolism = 2 //Ten times the normal rate.

/datum/reagent/ethanol/beepskyclassic/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			playsound(get_turf(H), 'sound/voice/halt.ogg', 100, 1, 0)
		else
			H.Knockdown(10)
			H.Stun(10)
			playsound(get_turf(H), 'sound/weapons/Egloves.ogg', 100, 1, -1)

/datum/reagent/ethanol/spiders
	name = "Spiders"
	id = SPIDERS
	description = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA."
	color = "#666666" //rgb(102, 102, 102)
	custom_metabolism = 0.01 //Spiders really 'hang around'

/datum/reagent/ethanol/spiders/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.take_organ_damage(REM, 0) //Drinking a glass of live spiders is bad for you.
	if(holder.get_reagent_amount(SPIDERS)>=4) //The main reason we need to have a minimum cost rather than just high custom metabolism is so that someone can't give themselves an IV of spiders for "fun"
		new /mob/living/simple_animal/hostile/giant_spider/spiderling(get_turf(M))
		holder.remove_reagent(SPIDERS,4)
		M.emote("scream", , , 1)
		M.visible_message("<span class='warning'>[M] recoils as a spider emerges from \his mouth!</span>")

/datum/reagent/ethanol/weedeater
	name = "Weed Eater"
	id = WEED_EATER
	description = "The vegetarian equivalant of a snake eater."
	color = "#009933" //rgb(0, 153, 51)

/datum/reagent/ethanol/weedeater/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	var/spell = /spell/targeted/genetic/eat_weed
	if(!(locate(spell) in M.spell_list))
		to_chat(M, "<span class='notice'>You feel hungry like the diona.</span>")
		M.add_spell(spell)

/datum/reagent/ethanol/deadrum
	name = "Deadrum"
	id = RUM
	description = "Popular with the sailors. Not very popular with anyone else."
	color = "#664300" //rgb: 102, 67, 0
	pass_out = 325

/datum/reagent/ethanol/deadrum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/deadrum/vodka
	name = "Vodka"
	id = VODKA
	description = "The drink and fuel of choice of Russians galaxywide."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sake
	name = "Sake"
	id = SAKE
	description = "Anime's favorite drink."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sake/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind.GetRole(NINJA))
			M.nutrition += nutriment_factor
			if(M.getOxyLoss() && prob(50))
				M.adjustOxyLoss(-2)
			if(M.getBruteLoss() && prob(60))
				M.heal_organ_damage(2, 0)
			if(M.getFireLoss() && prob(50))
				M.heal_organ_damage(0, 2)
			if(M.getToxLoss() && prob(50))
				M.adjustToxLoss(-2)
			if(M.dizziness != 0)
				M.dizziness = max(0, M.dizziness - 15)
			if(M.confused != 0)
				M.confused = max(0, M.confused - 5)

/datum/reagent/ethanol/deadrum/glasgow
	name = "Glasgow Deadrum"
	id = GLASGOW
	description = "Makes you feel like you had one hell of a party."
	color = "#662D1D" //rgb: 101, 44, 29
	slur_start = 1
	confused_start = 1

/datum/reagent/ethanol/deadrum/tequila
	name = "Tequila"
	id = TEQUILA
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty, hombre?"
	color = "#A8B0B7" //rgb: 168, 176, 183

/datum/reagent/ethanol/deadrum/vermouth
	name = "Vermouth"
	id = VERMOUTH
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/wine
	name = "Wine"
	id = WINE
	description = "A premium alcoholic beverage made from fermented grape juice."
	color = "#7E4043" //rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/deadrum/cognac
	name = "Cognac"
	id = COGNAC
	description = "A sweet and strongly alcoholic drink, twice distilled and left to mature for several years. Classy as fornication."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	confused_start = 115

/datum/reagent/ethanol/deadrum/hooch
	name = "Hooch"
	id = HOOCH
	description = "A suspiciously viscous off-brown liquid that reeks of fuel. Do you really want to drink that?"
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35
	confused_start = 90
	pass_out = 250

/datum/reagent/ethanol/deadrum/ale
	name = "Ale"
	id = ALE
	description = "A dark alcoholic beverage made from malted barley and yeast."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/thirteenloko
	name = "Thirteen Loko"
	id = THIRTEENLOKO
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#102000" //rgb: 16, 32, 0

/datum/reagent/ethanol/deadrum/thirteenloko/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.drowsyness = max(0, M.drowsyness - 7)
	M.Jitter(1)



/////////////////////////////////////////////////////////////////Cocktail Entities//////////////////////////////////////////////

/datum/reagent/ethanol/deadrum/bilk
	name = "Bilk"
	id = BILK
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#895C4C" //rgb: 137, 92, 76
	density = 0.89
	specheatcap = 2.46

/datum/reagent/ethanol/deadrum/atomicbomb
	name = "Atomic Bomb"
	id = ATOMICBOMB
	description = "Nuclear proliferation never tasted so good."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666300" //rgb: 102, 99, 0

/datum/reagent/ethanol/deadrumm/threemileisland
	name = "Three Mile Island Iced Tea"
	id = THREEMILEISLAND
	description = "Made for a woman. Strong enough for a man."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666340" //rgb: 102, 99, 64

/datum/reagent/ethanol/deadrum/goldschlager
	name = "Goldschlager"
	id = GOLDSCHLAGER
	description = "100 proof cinnamon schnapps with small gold flakes mixed in."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	density = 2.72
	specheatcap = 0.32

/datum/reagent/ethanol/deadrum/patron
	name = "Patron"
	id = PATRON
	description = "Tequila with small flakes of silver in it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#585840" //rgb: 88, 88, 64
	density = 1.84
	specheatcap = 0.59

/datum/reagent/ethanol/deadrum/gintonic
	name = "Gin and Tonic"
	id = GINTONIC
	description = "An all time classic, mild cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/cuba_libre
	name = "Cuba Libre"
	id = CUBALIBRE
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0

/datum/reagent/ethanol/deadrum/whiskey_cola
	name = "Whiskey Cola"
	id = WHISKEYCOLA
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0

/datum/reagent/ethanol/deadrum/martini
	name = "Classic Martini"
	id = MARTINI
	description = "Vermouth with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/vodkamartini
	name = "Vodka Martini"
	id = VODKAMARTINI
	description = "Vodka with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sakemartini
	name = "Sake Martini"
	id = SAKEMARTINI
	description = "A martini mixed with sake instead of vermouth. Has a fruity, oriental flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/white_russian
	name = "White Russian"
	id = WHITERUSSIAN
	description = "That's just, like, your opinion, man..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68340" //rgb: 166, 131, 64

/datum/reagent/ethanol/deadrum/screwdrivercocktail
	name = "Screwdriver"
	id = SCREWDRIVERCOCKTAIL
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/booger
	name = "Booger"
	id = BOOGER
	description = "Ewww..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/bloody_mary
	name = "Bloody Mary"
	id = BLOODYMARY
	description = "A strange yet pleasant mixture made of vodka, tomato and lime juice. Or at least you think the red stuff is tomato juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = GARGLEBLASTER
	description = "Whoah, this stuff looks volatile!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/brave_bull
	name = "Brave Bull"
	id = BRAVEBULL
	description = "A mixture of tequila and coffee liqueur."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/tequila_sunrise
	name = "Tequila Sunrise"
	id = TEQUILASUNRISE
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/toxins_special
	name = "Toxins Special"
	id = TOXINSSPECIAL
	description = "This thing is FLAMING! CALL THE DAMN SHUTTLE!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/beepsky_smash
	name = "Beepsky Smash"
	id = BEEPSKYSMASH
	description = "This drink is the law."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	id = DOCTORSDELIGHT
	description = "A gulp a day keeps the MediBot away. That's what they say, at least."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = FOOD_METABOLISM
	color = "#BA7DBA" //rgb: 73, 49, 73

/datum/reagent/drink/doctor_delight/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.getOxyLoss())
		M.adjustOxyLoss(-2)
	if(M.getBruteLoss())
		M.heal_organ_damage(2, 0)
	if(M.getFireLoss())
		M.heal_organ_damage(0, 2)
	if(M.getToxLoss())
		M.adjustToxLoss(-2)
	if(M.dizziness != 0)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused != 0)
		M.confused = max(0, M.confused - 5)

/datum/reagent/ethanol/deadrum/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irish_cream
	name = "Irish Cream"
	id = IRISHCREAM
	description = "Whiskey-imbued cream. What else could you expect from the Irish."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/manly_dorf
	name = "The Manly Dorf"
	id = MANLYDORF
	description = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/longislandicedtea
	name = "Long Island Iced Tea"
	id = LONGISLANDICEDTEA
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/moonshine
	name = "Moonshine"
	id = MOONSHINE
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/b52
	name = "B-52"
	id = B52
	description = "Coffee, irish cream, and cognac. You will get bombed."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/irishcoffee
	name = "Irish Coffee"
	id = IRISHCOFFEE
	description = "Coffee served with irish cream. Regular cream just isn't the same."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/margarita
	name = "Margarita"
	id = MARGARITA
	description = "On the rocks with salt on the rim. Arriba!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/black_russian
	name = "Black Russian"
	id = BLACKRUSSIAN
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#360000" //rgb: 54, 0, 0

/datum/reagent/ethanol/deadrum/manhattan
	name = "Manhattan"
	id = MANHATTAN
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/manhattan_proj
	name = "Manhattan Project"
	id = MANHATTAN_PROJ
	description = "A scientist's drink of choice, for thinking about how to blow up the station."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/whiskeysoda
	name = "Whiskey Soda"
	id = WHISKEYSODA
	description = "Ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/antifreeze
	name = "Anti-freeze"
	id = ANTIFREEZE
	description = "Ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/barefoot
	name = "Barefoot"
	id = BAREFOOT
	description = "Barefoot and pregnant"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/snowwhite
	name = "Snow White"
	id = SNOWWHITE
	description = "Pale lager mixed with lemon-lime soda. Refreshing and sweet."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/demonsblood
	name = "Demon's Blood"
	id = DEMONSBLOOD
	description = "AHHHH!!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 10
	slurr_adj = 10

/datum/reagent/ethanol/deadrum/vodkatonic
	name = "Vodka and Tonic"
	id = VODKATONIC
	description = "For when a gin and tonic isn't Russian enough."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/deadrum/ginfizz
	name = "Gin Fizz"
	id = GINFIZZ
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/deadrum/bahama_mama
	name = "Bahama mama"
	id = BAHAMA_MAMA
	description = "Tropical cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/pinacolada
	name = "Pina Colada"
	id = PINACOLADA
	description = "Sans pineapple."
	reagent_state = REAGENT_STATE_LIQUID
	color = "F2F5BF" //rgb: 242, 245, 191

/datum/reagent/ethanol/deadrum/singulo
	name = "Singulo"
	id = SINGULO
	description = "A gravitational anomaly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	dizzy_adj = 15
	slurr_adj = 15

/datum/reagent/ethanol/deadrum/sangria
	name = "Sangria"
	id = SANGRIA
	description = "So tasty you won't believe it's alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#53181A" //rgb: 83, 24, 26
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/deadrum/sbiten
	name = "Sbiten"
	id = SBITEN
	description = "A spicy vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sbiten/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + 50) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/deadrum/devilskiss
	name = "Devil's Kiss"
	id = DEVILSKISS
	description = "Creepy time!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/red_mead
	name = "Red Mead"
	id = RED_MEAD
	description = "A crimson beverage consumed by space vikings. The coloration is from berries... you hope."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/mead
	name = "Mead"
	id = MEAD
	description = "A beverage consumed by space vikings on their long raids and rowdy festivities."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/iced_beer
	name = "Iced Beer"
	id = ICED_BEER
	description = "A beer so frosty the air around it freezes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/iced_beer/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < T0C+33)
		M.bodytemperature = min(T0C+33, M.bodytemperature - 4) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/deadrum/grog
	name = "Grog"
	id = GROG
	description = "Watered down rum. NanoTrasen approves!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/aloe
	name = "Aloe"
	id = ALOE
	description = "Contains no actual aloe."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/andalusia
	name = "Andalusia"
	id = ANDALUSIA
	description = "Rum, whiskey, and lemon juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/alliescocktail
	name = "Allies Cocktail"
	id = ALLIESCOCKTAIL
	description = "English gin, French vermouth, and Russian vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/acid_spit
	name = "Acid Spit"
	id = ACIDSPIT
	description = "Wine and sulphuric acid. You hope the wine has neutralized the acid."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365000" //rgb: 54, 80, 0

/datum/reagent/ethanol/deadrum/amasec
	name = "Amasec"
	id = AMASEC
	description = "The official drink of the Imperium."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/amasec/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.stunned = 4

/datum/reagent/ethanol/deadrum/neurotoxin
	name = "Neurotoxin"
	id = NEUROTOXIN
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E2E61" //rgb: 46, 46, 97

/datum/reagent/ethanol/deadrum/neurotoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustOxyLoss(1)
	M.SetKnockdown(max(M.knockdown, 15))
	M.SetStunned(max(M.stunned, 15))
	M.silent = max(M.silent, 15)

/datum/reagent/drink/bananahonk
	name = "Banana Honk"
	id = BANANAHONK
	description = "A non-alcoholic drink of banana juice, milk cream and sugar."
	nutriment_factor = FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/drink/silencer
	name = "Silencer"
	id = SILENCER
	description = "Some say this is the diluted blood of the mime."
	nutriment_factor = FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/drink/silencer/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	M.silent = max(M.silent, 15)

/datum/reagent/ethanol/deadrum/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/changelingsting/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/deadrum/erikasurprise
	name = "Erika Surprise"
	id = ERIKASURPRISE
	description = "The surprise is, it's green!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irishcarbomb
	name = "Irish Car Bomb"
	id = IRISHCARBOMB
	description = "A troubling mixture of irish cream and ale."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irishcarbomb/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/deadrum/syndicatebomb
	name = "Syndicate Bomb"
	id = SYNDICATEBOMB
	description = "Whiskey cola and beer. Figuratively explosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/driestmartini
	name = "Driest Martini"
	id = DRIESTMARTINI
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = FOOD_METABOLISM
	color = "#2E6671" //rgb: 46, 102, 113
	data = 1 //Used as a tally

/datum/reagent/ethanol/deadrum/driestmartini/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 10
	if(data >= 55 && data < 115)
		M.stuttering += 10
	else if(data >= 115 && prob(33))
		M.confused = max(M.confused + 15, 15)
	data++

/datum/reagent/ethanol/deadrum/danswhiskey
	name = "Discount Dan's 'Malt' Whiskey"
	id = DANS_WHISKEY
	description = "It looks like whiskey... kinda."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 181, 199, 158

/datum/reagent/ethanol/deadrum/danswhiskey/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(1 to 15)
				if(prob(5))
					to_chat(H,"<span class='warning'>Your stomach grumbles and you feel a little nauseous.</span>")
					H.adjustToxLoss(0.5)
				H.adjustToxLoss(0.1)
			if(15 to 25)
				if(prob(10))
					to_chat(H,"<span class='warning'>Something in your abdomen definitely doesn't feel right.</span>")
					H.adjustToxLoss(1)
				if(prob(5))
					H.adjustToxLoss(2)
					H.vomit()
				H.adjustToxLoss(0.2)
			if(25 to INFINITY)
				if(prob(10))
					H.custom_pain("You feel a horrible throbbing pain in your stomach!",1)
					var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
					if(istype(L))
						L.take_damage(1, 1)
					H.adjustToxLoss(2)
				if(prob(5))
					H.vomit()
					H.adjustToxLoss(3)
				H.adjustToxLoss(0.3)

/datum/reagent/ethanol/deadrum/pintpointer
	name = "Pintpointer"
	id = PINTPOINTER
	description = "A little help finding the bartender."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/greyvodka
	name = "Greyshirt vodka"
	id = GREYVODKA
	description = "Made presumably from whatever scrapings you can get out of maintenance. Don't think, just drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5"
	alpha = 64

/datum/reagent/ethanol/deadrum/greyvodka/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	H.radiation = max(H.radiation - 5 * REM, 0)
	H.rad_tick = max(H.rad_tick - 3 * REM, 0)



//Cafe drinks

/datum/reagent/drink/tea/greentea
	name = "Green Tea"
	id = GREENTEA
	description = "Delicious green tea."

/datum/reagent/drink/tea/redtea
	name = "Red Tea"
	id = REDTEA
	description = "Tasty red tea."

/datum/reagent/drink/tea/singularitea
	name = "Singularitea"
	id = SINGULARITEA
	description = "Swirly!"

var/global/list/chifir_doesnt_remove = list("chifir", "blood")

/datum/reagent/drink/tea/chifir
	name = "Chifir"
	id = CHIFIR
	description = "Strong Russian tea. It'll help you remember what you had for lunch!"

/datum/reagent/drink/tea/chifir/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		H.vomit()

	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in chifir_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 3 * REM)

	M.adjustToxLoss(-2 * REM)

/datum/reagent/drink/tea/acidtea
	name = "Earl's Grey Tea"
	id = ACIDTEA
	description = "Get in touch with your Roswellian side!"

/datum/reagent/drink/tea/yinyang
	name = "Zen Tea"
	id = YINYANG
	description = "Find inner peace."

/datum/reagent/drink/tea/gyro
	name = "Gyro"
	id = GYRO
	description = "Nyo ho ho~"

/datum/reagent/drink/tea/gyro/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(30))
		M.emote("spin")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/zone in list(LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT))
			H.HealDamage(zone, rand(1, 3), rand(1, 3)) //Thank you Gyro

/datum/reagent/drink/tea/dantea
	name = "Discount Dan's Green Flavor Tea"
	id = DANTEA
	description = "Not safe for children above or under the age of 12."

/datum/reagent/drink/tea/mint
	name = "Groans Tea: Minty Delight Flavor"
	id = MINT
	description = "Very filling!"

/datum/reagent/drink/tea/chamomile
	name = "Groans Tea: Chamomile Flavor"
	id = CHAMOMILE
	description = "Enjoy a good night's sleep."

/datum/reagent/drink/tea/exchamomile
	name = "Tea"
	id = EXCHAMOMILE
	description = "Who needs to wake up anyway?"

/datum/reagent/drink/tea/fancydan
	name = "Groans Banned Tea: Fancy Dan Flavor"
	id = FANCYDAN
	description = "Full of that patented Dan taste you love!"

/datum/reagent/drink/tea/plasmatea
	name = "Plasma Pekoe"
	id = PLASMATEA
	description = "Probably not the safest beverage."

/datum/reagent/drink/tea/greytea
	name = "Tide"
	id = GREYTEA
	description = "This probably shouldn't even be considered tea..."

/datum/reagent/drink/coffee/espresso
	name = "Espresso"
	id = ESPRESSO
	description = "A thick blend of coffee made by forcing near-boiling pressurized water through finely ground coffee beans."

//Let's hope this one works
var/global/list/tonio_doesnt_remove=list("tonio", "blood")

/datum/reagent/drink/coffee/tonio
	name = "Tonio"
	id = TONIO
	nutriment_factor = FOOD_METABOLISM
	description = "This coffee seems uncannily good."

/datum/reagent/drink/coffee/tonio/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		H.vomit()

	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in tonio_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 3 * REM)

	M.adjustToxLoss(-2 * REM)
	M.nutrition += nutriment_factor

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/coffee/cappuccino
	name = "Cappuccino"
	id = CAPPUCCINO
	description = "Espresso with milk."

/datum/reagent/drink/coffee/doppio
	name = "Doppio"
	id = DOPPIO
	description = "Double shot of espresso."

/datum/reagent/drink/coffee/passione
	name = "Passione"
	id = PASSIONE
	description = "Rejuvenating!"

/datum/reagent/drink/coffee/seccoffee
	name = "Wake-Up Call"
	id = SECCOFFEE
	description = "All the essentials."

/datum/reagent/drink/coffee/seccoffee/on_mob_life(var/mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			H.heal_organ_damage(1, 1) //liquid sprinkles!

/datum/reagent/drink/coffee/medcoffee
	name = "Lifeline"
	id = MEDCOFFEE
	description = "Tastes like it's got iron in it or something."

/datum/reagent/drink/coffee/medcoffee/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.getOxyLoss() && prob(25))
		M.adjustOxyLoss(-1)
	if(M.getBruteLoss() && prob(30))
		M.heal_organ_damage(1, 0)
	if(M.getFireLoss() && prob(25))
		M.heal_organ_damage(0, 1)
	if(M.getToxLoss() && prob(25))
		M.adjustToxLoss(-1)
	if(M.dizziness != 0)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused != 0)
		M.confused = max(0, M.confused - 5)
	M.reagents.add_reagent (IRON, 0.1)

/datum/reagent/drink/coffee/detcoffee
	name = "Joe"
	id = DETCOFFEE
	description = "Bitter, black, and tasteless. Just the way I liked my coffee. I was halfway down my third mug that day, and all the way down on my luck. The only case I'd had all month had just turned sour. I took the flask in my drawer and emptied its contents into my coffee. No alcohol today, I'd promised myself. Thing is, promises to yourself are easy to break. No one to hold you accountable."
	causes_jitteriness = 0
	var/activated = 0
	var/noir_set_by_us = 0

/datum/reagent/drink/coffee/detcoffee/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(!activated)
		if (M_NOIR in M.mutations)
			noir_set_by_us = 0
		else
			noir_set_by_us = 1
			M.dna.SetSEState(NOIRBLOCK, 1)
			genemutcheck(M, NOIRBLOCK)
			M.update_mutations()
		activated = 1

/datum/reagent/drink/coffee/detcoffee/reagent_deleted()
	if(..())
		return 1
	if(!holder)
		return
	var/mob/M =  holder.my_atom
	if (istype(M) && activated && noir_set_by_us)
		M.dna.SetSEState(NOIRBLOCK, 0)
		genemutcheck(M, NOIRBLOCK)
		M.update_mutations()

/datum/reagent/drink/coffee/etank
	name = "Recharger"
	id = ETANK
	description = "Regardless of how energized this coffee makes you feel, jumping against doors will still never be a viable way to open them."

/datum/reagent/drink/cold/quantum
	name = "Nuka Cola Quantum"
	id = QUANTUM
	description = "Take the leap... enjoy a Quantum!"
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	sport = 5

/datum/reagent/drink/cold/quantum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(2, RAD_INTERNAL)

/datum/reagent/drink/sportdrink
	name = "Sport Drink"
	id = SPORTDRINK
	description = "You like sports, and you don't care who knows."
	sport = 5
	color = "#CCFF66" //rgb: 204, 255, 51
	custom_metabolism =  0.01
	custom_plant_metabolism = HYDRO_SPEED_MULTIPLIER/5