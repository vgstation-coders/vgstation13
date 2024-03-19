//Drink reagents, not to be confused with ethanol drinks

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum//////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/drink
	name = "Drink"
	id = DRINK
	description = "Uh, some kind of drink."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#E78108" //rgb: 231, 129, 8
	custom_metabolism = FOOD_METABOLISM
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0

/datum/reagent/drink/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(adj_dizzy)
		M.dizziness = max(0,M.dizziness + adj_dizzy)
	if(adj_drowsy)
		M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if(adj_sleepy)
		M.sleeping = max(0,M.sleeping + adj_sleepy)

/datum/reagent/drink/gatormix
	name = "Gator Mix"
	id = GATORMIX
	description = "A vile sludge of mixed carbohydrates. Makes people more alert. May cause kidney damage in large doses."
	nutriment_factor = 4 * REAGENTS_METABOLISM //get fat, son
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A41D77"
	adj_dizzy = -5
	adj_drowsy = -5
	adj_sleepy = -5
	adj_temp = 10
	overdose_am = 50

/datum/reagent/drink/gatormix/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M) && prob(20))
		var/mob/living/carbon/human/H = M
		H.Jitter(5)

/datum/reagent/drink/gatormix/on_overdose(var/mob/living/M)
	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/kidney/killdney = H.get_kidneys()
		killdney.damage++

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = HOT_COCO
	description = "Made with love! And cocoa beans."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 6 * REAGENTS_METABOLISM
	color = "#403010" //rgb: 64, 48, 16
	adj_temp = 5
	density = 1.2
	specheatcap = 4.18
	mug_desc = "A delicious warm brew of milk and chocolate."

/datum/reagent/drink/hot_coco/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/drink/hot_coco/subhuman
	id = HOT_COCO_SUBHUMAN
	description = "Made with hate! And coco beans."

/datum/reagent/drink/hot_coco/subhuman/on_mob_life(var/mob/living/M)
	..()
	if(prob(1))
		to_chat(M, "<span class='notice'>You are suddenly reminded that you are subhuman.</span>")

/datum/reagent/drink/creamy_hot_coco
	name = "Creamy Hot Chocolate"
	id = CREAMY_HOT_COCO
	description = "Never ever let it cool."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" //rgb: 64, 48, 16
	glass_icon_state = "creamyhotchocolate"
	glass_name = "\improper Creamy Hot Chocolate"
	adj_temp = 5
	density = 1.2
	specheatcap = 4.18
	mug_desc = "A delicious warm brew of milk and chocolate. Never ever let it cool."

/datum/reagent/drink/orangejuice
	name = "Orange Juice"
	id = ORANGEJUICE
	description = "Both delicious AND rich in Vitamin C. What more do you need?"
	color = "#E78108" //rgb: 231, 129, 8
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "Vitamins! Yay!"

/datum/reagent/drink/orangejuice/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-REM)

/datum/reagent/drink/opokjuice
	name = "Opok Juice"
	id = OPOKJUICE
	description = "A fruit from the mothership pulped into bitter juice, with a very slight undertone of sweetness."
	color = "#FF9191" //rgb: 255, 145, 145
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "Vitamins from the mothership!"

/datum/reagent/drink/opokjuice/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-REM)

/datum/reagent/drink/tomatojuice
	name = "Tomato Juice"
	id = TOMATOJUICE
	description = "Tomatoes made into juice. What a waste of good tomatoes, huh?"
	color = "#731008" //rgb: 115, 16, 8
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "Are you sure this is tomato juice?"
	mug_desc = "Are you sure this is tomato juice?"

/datum/reagent/drink/tomatojuice/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.getFireLoss() && prob(20))
		M.heal_organ_damage(0, 1)

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = LIMEJUICE
	description = "The sweet-sour juice of limes."
	color = "#99bb43" //rgb: 153, 187, 67
	alpha = 170
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "A glass of sweet-sour lime juice."

/datum/reagent/drink/limejuice/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/drink/carrotjuice
	name = "Carrot Juice"
	id = CARROTJUICE
	description = "It's like a carrot, but less crunchy."
	color = "#FF8820" //rgb: 255, 136, 32
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "It's like a carrot, but less crunchy."

/datum/reagent/drink/carrotjuice/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.eye_blurry = max(M.eye_blurry - 1 , 0)
	M.eye_blind = max(M.eye_blind - 1 , 0)
	switch(tick)
		if(21 to INFINITY)
			if(prob(tick - 10))
				M.disabilities &= ~NEARSIGHTED

/datum/reagent/drink/grapejuice
	name = "Grape Juice"
	id = GRAPEJUICE
	description = "Freshly squeezed juice from red grapes. Quite sweet."
	color = "#512284" //rgb: 81, 34, 132
	nutriment_factor = 2.5 * REAGENTS_METABOLISM

/datum/reagent/drink/ggrapejuice
	name = "Green Grape Juice"
	id = GGRAPEJUICE
	description = "Freshly squeezed juice from green grapes. Smoothly sweet."
	color = "#B79E42" //rgb: 183, 158, 66
	nutriment_factor = 2.5 * REAGENTS_METABOLISM

/datum/reagent/drink/berryjuice
	name = "Berry Juice"
	id = BERRYJUICE
	description = "A delicious blend of several different kinds of berries."
	color = "#660099" //rgb: 102, 0, 153
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = POISONBERRYJUICE
	description = "A surprisingly tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#6600CC" //rgb: 102, 0, 204
	glass_desc = "Drinking this may not be a good idea."

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
	nutriment_factor = 2.5 * REAGENTS_METABOLISM

/datum/reagent/drink/applejuice
	name = "Apple Juice"
	id = APPLEJUICE
	description = "Tastes of New York."
	color = "#FDAD01" //rgb: 253, 173, 1
	alpha = 150
	nutriment_factor = 2.5 * REAGENTS_METABOLISM

/datum/reagent/drink/lemonjuice
	name = "Lemon Juice"
	id = LEMONJUICE
	description = "This juice is VERY sour."
	color = "#fff690" //rgb: 255, 246, 144
	alpha = 170
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "Sour..."

/datum/reagent/drink/banana
	name = "Banana Juice"
	id = BANANA
	description = "The raw essence of a banana. HONK"
	color = "#FFE777" //rgb: 255, 230, 119
	alpha = 255
	nutriment_factor = 2.5 * REAGENTS_METABOLISM

/datum/reagent/drink/nothing
	name = "Nothing"
	id = NOTHING
	description = "Absolutely nothing."
	color = "#FFFFFF" //rgb: 255, 255, 255
	nutriment_factor = 0
	glass_name = "nothing"

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
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/drink/plumphjuice
	name = "Plump Helmet Juice"
	id = PLUMPHJUICE
	description = "Eeeewwwww."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#A28691" //rgb: 162, 134, 145
	glass_name = "glass of plump helmet wine"
	glass_desc = "An absolute staple to get through a day's work."
	glass_icon_state = "plumphwineglass"

/datum/reagent/drink/milk
	name = "Milk"
	id = MILK
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" //rgb: 223, 223, 223
	alpha = 240
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "White and nutritious goodness!"

/datum/reagent/drink/milk/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10 * REAGENTS_METABOLISM)
	if(holder.has_reagent("zamspicytoxin"))
		holder.remove_reagent("zamspicytoxin", 10 * REAGENTS_METABOLISM)
	if(prob(50))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/milk/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(1)
	T.add_waterlevel(1)


/datum/reagent/drink/milk/mommimilk
	name = "MoMMI Milk"
	id = MOMMIMILK
	description = "Milk from a MoMMI, but how is it produced?"
	color = "#eaeaea" //rgb(234, 234, 234)
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "Artificially white nutrition!"


/datum/reagent/drink/milk/mommimilk/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(1)
/datum/reagent/drink/milk/mommimilk/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(10)
	T.add_planthealth(-20)

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = SOYMILK
	description = "An opaque white liquid made from soybeans."
	color = "#e8e8d8" //rgb: 232, 232, 216
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	glass_desc = "White and nutritious soy goodness!"

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = CREAM
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" //rgb: 223, 215, 175
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	density = 2.37
	specheatcap = 1.38
	glass_desc = "Like milk, but thicker."

/datum/reagent/drink/coffee
	name = "Coffee"
	id = COFFEE
	description = "Coffee is a brewed drink prepared from the roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#390600"
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 20
	custom_metabolism = 0.1
	var/causes_jitteriness = 1
	glass_desc = "Careful, it's hot!"
	mug_icon_state = "coffee"
	mug_desc = "A warm mug of coffee."

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
	adj_temp = -1.5
	glass_icon_state = "icedcoffeeglass"
	glass_desc = "For when you need a coffee without the warmth."

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = SOY_LATTE
	description = "The hipster version of the classic cafe latte."
	color = "#B7AA8D"
	adj_sleepy = 0
	adj_temp = 5
	glass_icon_state = "soy_latte"
	glass_name = "soy latte"
	mug_icon_state = "latte"

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
	color = "#B7AA8D"
	adj_sleepy = 0
	adj_temp = 5
	glass_icon_state = "cafe_latte"
	glass_name = "cafe latte"
	mug_icon_state = "latte"

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
	color = "#320438"
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp = 20
	mug_icon_state = "tea"
	mug_desc = "A warm mug of tea."

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
	adj_temp = -1.5
	density = 1
	specheatcap = 1
	glass_icon_state = "icedteaglass"

/datum/reagent/drink/tea/arnoldpalmer
	name = "Arnold Palmer"
	id = ARNOLDPALMER
	description = "Known as half and half to some. A mix of ice tea and lemonade."
	color = "#104038" //rgb: 16, 64, 56
	adj_temp = -1.5
	adj_sleepy = -3
	adj_dizzy = -1
	adj_drowsy = -3
	glass_icon_state = "arnoldpalmer"
	glass_name = "\improper Arnold Palmer"

/datum/reagent/drink/kahlua
	name = "Kahlua"
	id = KAHLUA
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" //rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	glass_icon_state = "kahluaglass"
	glass_name = "glass of coffee liqueur"
	glass_desc = "DAMN, THIS STUFF LOOKS ROBUST."

/datum/reagent/drink/kahlua/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold
	id = EXPLICITLY_INVALID_REAGENT_ID
	name = "Cold Drink"
	adj_temp = -1.5

/datum/reagent/drink/cold/tonic
	name = "Tonic Water"
	id = TONIC
	description = "It tastes strange but at least the quinine keeps the space malaria at bay."
	color = "#bafffd" //rgb: 186, 255, 253
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/cold/sodawater
	name = "Soda Water"
	id = SODAWATER
	description = "Effervescent water used in many cocktails and drinks."
	color = "#bafffd" //rgb: 186, 255, 253
	adj_dizzy = -5
	adj_drowsy = -3
	glass_desc = "Soda water. Why not make a scotch and soda?"

/datum/reagent/drink/cold/sodawater/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(1)
	T.add_waterlevel(1)
	T.add_planthealth(1)

/datum/reagent/drink/cold/ice
	name = "Ice"
	id = ICE
	description = "Frozen water. Your dentist wouldn't like you chewing this."
	reagent_state = REAGENT_STATE_SOLID
	color = "#619494" //rgb: 97, 148, 148
	density = 0.91
	specheatcap = 4.18
	glass_icon_state = "iceglass"
	glass_desc = "Generally, you're supposed to put something else in there too..."
	adj_temp = -5//drinking ice directly may give you some mild hypothermia

/datum/reagent/drink/cold/space_cola
	name = "Cola"
	id = COLA
	description = "A refreshing beverage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6e6450" //rgb: 110, 100, 80
	adj_drowsy 	= 	-3
	glass_desc = "A glass of refreshing Space Cola."

/datum/reagent/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = NUKA_COLA
	description = "Cola. Cola never changes."
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	density = 4.17
	specheatcap = 1.24
	glass_icon_state = "nuka_colaglass"
	glass_name = "\improper Nuka Cola"
	glass_desc = "Don't cry. Don't raise your eye. It's only nuclear wasteland."

/datum/reagent/drink/cold/nuka_cola/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Jitter(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/drink/cold/geometer
	name = "Geometer"
	id = GEOMETER
	description = "Summon the Beast."
	color = "#ffd700"
	adj_sleepy = -2

/datum/reagent/drink/cold/spacemountainwind
	name = "Space Mountain Wind"
	id = SPACEMOUNTAINWIND
	description = "Blows right through you like a space wind."
	color = "#A4FF8F" //rgb: 164, 255, 143
	adj_drowsy = -7
	adj_sleepy = -1
	glass_icon_state = "Space_mountain_wind_glass"
	glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."

/datum/reagent/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = DR_GIBB
	description = "A delicious blend of 42 different flavors."
	color = "#102000" //rgb: 16, 32, 0
	adj_drowsy = -6
	glass_icon_state = "dr_gibb_glass"
	glass_desc = "Dr. Gibb. Not as dangerous as the name might imply."

/datum/reagent/drink/cold/space_up
	name = "Space-Up"
	id = SPACE_UP
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" //rgb: 32, 40, 0
	adj_temp = -1.5
	glass_icon_state = "space-up_glass"
	glass_desc = "Space-up. It helps keep your cool."

/datum/reagent/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = LEMON_LIME
	color = "#878F00" //rgb: 135, 40, 0
	adj_temp = -1.5

/datum/reagent/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh, the nostalgia..."
	id = LEMONADE
	color = "#FFFF00" //rgb: 255, 255, 0
	glass_icon_state = "lemonadeglass"

/datum/reagent/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = KIRASPECIAL
	color = "#CCCC99" //rgb: 204, 204, 153
	glass_icon_state = "kiraspecial"
	glass_name = "\improper Kira Special"

/datum/reagent/drink/cold/brownstar
	name = "Brown Star"
	description = "Its not what it sounds like..."
	id = BROWNSTAR
	color = "#9F3400" //rgb: 159, 052, 000
	adj_temp = -1.5
	glass_icon_state = "brownstar"
	glass_name = "\improper Brown Star"

/datum/reagent/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = MILKSHAKE
	color = "#AEE5E4" //rgb" 174, 229, 228
	adj_temp = -1.5
	custom_metabolism = FOOD_METABOLISM
	glass_icon_state = "milkshake"
	glass_desc = "Brings all the boys to the yard."

/datum/reagent/drink/cold/milkshake/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(tick)
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

/datum/reagent/drink/cold/rewriter
	name = "Rewriter"
	description = "The librarian's special."
	id = REWRITER
	color = "#485000" //rgb:72, 080, 0
	glass_icon_state = "rewriter"
	glass_name = "\improper Rewriter"
	glass_desc = "This will cure your dyslexia and cause your arrhythmia."

/datum/reagent/drink/cold/rewriter/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold/diy_soda
	name = "Dr. Pecker's DIY Soda"
	description = "Tastes like a science fair experiment."
	id = DIY_SODA
	color = "#7566FF" //rgb: 117, 102, 255
	adj_temp = -1.5
	adj_drowsy = -6

/datum/reagent/drink/cold/diy_soda/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	id = DOCTORSDELIGHT
	description = "A gulp a day keeps the MediBot away. That's what they say, at least."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#BA7DBA" //rgb: 73, 49, 73
	glass_icon_state = "doctorsdelightglass"
	glass_name = "\improper Doctor's Delight"
	glass_desc = "A rejuvenating mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."

/datum/reagent/drink/doctor_delight/on_mob_life(var/mob/living/M)
	if(..())
		return 1

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
		M.remove_confused(5)

/datum/reagent/drink/bananahonk
	name = "Banana Honk"
	id = BANANAHONK
	description = "A non-alcoholic drink of banana juice, milk cream and sugar."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bananahonkglass"
	glass_name = "\improper Banana Honk"
	glass_desc = "A cocktail from the clown planet."

/datum/reagent/drink/silencer
	name = "Silencer"
	id = SILENCER
	description = "Some say this is the diluted blood of the mime."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "silencerglass"
	glass_name = "\improper Silencer"
	glass_desc = "The mime's favorite, though you won't hear him ask for it."

/datum/reagent/drink/silencer/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.silent = max(M.silent, 15)

/datum/reagent/drink/tea/greentea
	name = "Green Tea"
	id = GREENTEA
	description = "Delicious green tea."
	mug_icon_state = "greentea"
	mug_desc = "Green Tea served in a traditional Japanese tea cup, just like in your Chinese cartoons!"
	color = "#719B00"

/datum/reagent/drink/tea/redtea
	name = "Red Tea"
	id = REDTEA
	description = "Tasty red tea."
	mug_icon_state = "redtea"
	mug_desc = "Red Tea served in a traditional Chinese tea cup, just like in your Malaysian movies!"
	color = "#770000"

/datum/reagent/drink/tea/singularitea
	name = "Singularitea"
	id = SINGULARITEA
	description = "Swirly!"
	mug_icon_state = "singularitea"
	mug_name = "\improper Singularitea"
	mug_desc = "Brewed under intense radiation to be extra flavorful!"
	color = "#5A0422"

var/global/list/chifir_doesnt_remove = list("chifir", "blood")

/datum/reagent/drink/tea/chifir
	name = "Chifir"
	id = CHIFIR
	description = "Strong Russian tea. It'll help you remember what you had for lunch!"
	mug_icon_state = "chifir"
	mug_desc = "A Russian kind of tea. Not for those with weak stomachs."
	color = "#72452C"

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
	mug_icon_state = "acidtea"
	mug_desc = "A sizzling mug of tea made just for Greys."
	color = "#8DE45E"

/datum/reagent/drink/tea/yinyang
	name = "Zen Tea"
	id = YINYANG
	description = "Find inner peace."
	mug_icon_state = "yinyang"
	mug_desc = "Enjoy inner peace and ignore the watered down taste"
	color = "#7D7F83"

/datum/reagent/drink/tea/gyro
	name = "Gyro"
	id = GYRO
	description = "Nyo ho ho~"
	mug_icon_state = "gyro"
	mug_name = "\improper Gyro"
	color = "#1B1E24"

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
	mug_icon_state = "dantea"
	mug_name = "\improper Discount Dan's Green Flavor Tea"
	mug_desc = "Tea probably shouldn't be sizzling like that..."
	color = "#3CFF00"

/datum/reagent/drink/tea/mint
	name = "Groans Tea: Minty Delight Flavor"
	id = MINT
	description = "Very filling!"
	mug_icon_state = "mint"
	mug_name = "\improper Groans Tea: Minty Delight Flavor"
	mug_desc = "Groans knows mint might not be the kind of flavor our fans expect from us, but we've made sure to give it that patented Groans zing."
	color = "#99FF99"

/datum/reagent/drink/tea/chamomile
	name = "Groans Tea: Chamomile Flavor"
	id = CHAMOMILE
	description = "Enjoy a good night's sleep."
	mug_icon_state = "chamomile"
	mug_name = "\improper Groans Tea: Chamomile Flavor"
	mug_desc = "Groans presents the perfect cure for insomnia: Chamomile!"
	color = "#BE9801"

/datum/reagent/drink/tea/exchamomile
	name = "Tea"
	id = EXCHAMOMILE
	description = "Who needs to wake up anyway?"
	mug_icon_state = "exchamomile"
	mug_name = "\improper Groans Banned Tea: EXTREME Chamomile Flavor"
	mug_desc = "Banned literally everywhere."
	color = "#BE9801"

/datum/reagent/drink/tea/fancydan
	name = "Groans Banned Tea: Fancy Dan Flavor"
	id = FANCYDAN
	description = "Full of that patented Dan taste you love!"
	mug_icon_state = "fancydan"
	mug_name = "\improper Groans Banned Tea: Fancy Dan Flavor"
	mug_desc = "Banned literally everywhere."
	color = "#FF9900"

/datum/reagent/drink/tea/plasmatea
	name = "Plasma Pekoe"
	id = PLASMATEA
	description = "Probably not the safest beverage."
	mug_icon_state = "plasmatea"
	mug_desc = "You can practically taste the science. Or maybe that's just the horrible plasma burns."
	color = "#FF22D9"

/datum/reagent/drink/tea/greytea
	name = "Tide"
	id = GREYTEA
	description = "This probably shouldn't even be considered tea..."
	mug_icon_state = "greytea"
	mug_name = "\improper Tide"
	color = "#8F836B"

/datum/reagent/drink/coffee/espresso
	name = "Espresso"
	id = ESPRESSO
	description = "A thick blend of coffee made by forcing near-boiling pressurized water through finely ground coffee beans."
	mug_icon_state = "espresso"
	color = "#803C00"

//Let's hope this one works
var/global/list/tonio_doesnt_remove=list("tonio", "blood")

/datum/reagent/drink/coffee/tonio
	name = "Tonio"
	id = TONIO
	nutriment_factor = 3 * REAGENTS_METABOLISM
	description = "This coffee seems uncannily good."
	mug_icon_state = "tonio"
	mug_name = "\improper Tonio"
	mug_desc = "Delicious, and may help you get out of a Jam."
	color = "#990F29"

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

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/coffee/cappuccino
	name = "Cappuccino"
	id = CAPPUCCINO
	description = "Espresso with milk."
	mug_icon_state = "cappuccino"
	mug_desc = "The stronger big brother of the cafe latte, cappuccino contains more espresso in proportion to milk."
	color = "#E6DDC3"

/datum/reagent/drink/coffee/cappuccino/on_mob_life(var/mob/living/M)
	..()
	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0) //milk doing its work

/datum/reagent/drink/coffee/doppio
	name = "Doppio"
	id = DOPPIO
	description = "Double shot of espresso."
	mug_icon_state = "doppio"
	mug_name = "\improper Doppio"
	mug_desc = "Ring ring ring ring."
	color = "#6E0024"

/datum/reagent/drink/coffee/passione
	name = "Passione"
	id = PASSIONE
	description = "Rejuvenating!"
	nutriment_factor = 4.5 * REAGENTS_METABOLISM //because honey
	mug_icon_state = "passione"
	mug_name = "\improper Passione"
	mug_desc = "Sometimes referred to as a 'Vento Aureo'."
	color = "#B28A17"

/datum/reagent/drink/coffee/passione/on_mob_life(var/mob/living/M)
	..()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!holder)
			return
		H.sleeping = 0
		if(H.getBruteLoss() && prob(60))
			H.heal_organ_damage(1, 0)
		if(H.getFireLoss() && prob(50))
			H.heal_organ_damage(0, 1)
		if(H.getToxLoss() && prob(50))
			H.adjustToxLoss(-1)

/datum/reagent/drink/coffee/seccoffee
	name = "Wake-Up Call"
	id = SECCOFFEE
	description = "All the essentials."
	mug_icon_state = "seccoffee"
	mug_name = "\improper Wake-Up Call"
	mug_desc = "The perfect start for any Sec officer's day."
	color = "#390600"

/datum/reagent/drink/coffee/seccoffee/on_mob_life(var/mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			H.heal_organ_damage(1, 1) //liquid sprinkles!


/datum/reagent/drink/coffee/engicoffee
	name = "NT Standard Battery Acid"
	id = ENGICOFFEE
	description = "This Plasma Infused Brew, will fix what ails you."
	//mug_icon_state = "engicoffeee"	//Since it normally comes in cans, it doesn't have a custom mug icon. feel free to add one eventually
	mug_name = "\improper Energizer"
	mug_desc = "Taste that Triple A Goodness."

/datum/reagent/drink/coffee/engicoffee/on_mob_life(var/mob/living/M)
	..()
	M.hallucination = 0
	M.reagents.add_reagent (HYRONALIN, 0.05)

/datum/reagent/drink/coffee/medcoffee
	name = "Lifeline"
	id = MEDCOFFEE
	description = "Tastes like it's got iron in it or something."
	nutriment_factor = 1.5 * REAGENTS_METABOLISM //because medical healing?
	mug_icon_state = "medcoffee"
	mug_name = "\improper Lifeline"
	mug_desc = "Some days, the only thing that keeps you going is cryo and caffeine."
	color = "#390600"

/datum/reagent/drink/coffee/medcoffee/on_mob_life(var/mob/living/M)
	if(..())
		return 1

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
		M.remove_confused(5)
	M.reagents.add_reagent (IRON, 0.1)

/datum/reagent/drink/coffee/detcoffee
	name = "Joe"
	id = DETCOFFEE
	description = "Bitter, black, and tasteless. Just the way I liked my coffee. I was halfway down my third mug that day, and all the way down on my luck. The only case I'd had all month had just turned sour. I took the flask in my drawer and emptied its contents into my coffee. No alcohol today, I'd promised myself. Thing is, promises to yourself are easy to break. No one to hold you accountable."
	causes_jitteriness = 0
	var/activated = 0
	var/noir_set_by_us = 0
	mug_icon_state = "detcoffee"
	mug_name = "\improper Joe"
	mug_desc = "The lights, the smoke, the grime... the station itself felt alive that day when I stepped into my office, mug in hand. It had been one of those damn days. Some nurse got smoked in the tunnels, and it came down to me to catch the son of a bitch that did it. The dark, stale air of the tunnels sucks the soul out of a man -- sometimes literally -- and I was no closer to finding the killer than when the nurse was still alive. I hobbled over to my desk, reached for the flask in my pocket, and topped off my coffee with its contents. I had barely gotten settled in my chair when an officer burst through the door. Another body in the tunnels, an assistant this time. I grumbled and downed what was left of my joe. This stuff used to taste great when I was a rookie, but now it was like boiled dirt. I guess that's how the station changes you. I set the mug back down on my desk and lit my last cigar. My fingers instinctively sought out the comforting grip of the .44 snub in my coat as I stepped out into the bleak halls of the station. The case was not cold yet."
	color = "#18150B"

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
	mug_icon_state = "etank"
	mug_name = "\improper Recharger"
	mug_desc = "Helps you get back on your feet after a long day of robot maintenance. Can also be used as a substitute for motor oil."
	color = "#1A0705"

/datum/reagent/drink/cold/quantum
	name = "Nuka Cola Quantum"
	id = QUANTUM
	description = "Take the leap... enjoy a Quantum!"
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	sport = SPORTINESS_SPORTS_DRINK

/datum/reagent/drink/cold/quantum/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.apply_radiation(2, RAD_INTERNAL)

/datum/reagent/drink/sportdrink
	name = "Sport Drink"
	id = SPORTDRINK
	description = "You like sports, and you don't care who knows."
	sport = SPORTINESS_SPORTS_DRINK
	color = "#CCFF66" //rgb: 204, 255, 51
	custom_metabolism =  0.01

/datum/reagent/drink/blisterol
	name = "Blisterol"
	id = BLISTEROL
	description = "Blisterol is a deprecated drug used to treat wounds. Renamed and marked as deprecated due to its tendency to cause blisters."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	density = 1.8
	specheatcap = 3
	adj_temp = 40
	custom_metabolism = 1 //goes through you fast

/datum/reagent/drink/blisterol/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.heal_organ_damage(4 * REM, -1 * REM) //heal 2 brute, cause 0.5 burn
