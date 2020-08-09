/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	item_state = "glass_empty"
	isGlass = 1
	amount_per_transfer_from_this = 10
	volume = 50
	starting_materials = list(MAT_GLASS = 500)
	force = 5
	smashtext = ""  //due to inconsistencies in the names of the drinks just don't say anything
	smashname = "broken glass"
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	..()

	viewcontents = 1
	overlays.len = 0
	flammable = 0
	if(!molotov)
		lit = 0
	light_color = null
	set_light(0)
	origin_tech = ""

	if (reagents.reagent_list.len > 0)
		if(reagents.has_reagent(BLACKCOLOR))
			icon_state ="blackglass"
			name = "international drink of mystery"
			desc = "The identity of this drink has been concealed for its protection."
			viewcontents = 0 
		else
			var/datum/reagent/R = reagents.get_master_reagent()

			if(R.light_color)
				light_color = R.light_color
			
			if(R.flammable)
				if(!lit)
					flammable = 1
<<<<<<< HEAD
			if(ATOMICBOMB)
				icon_state = "atomicbombglass"
				name = "\improper Atomic Bomb"
				desc = "NanoTrasen does not take legal responsibility for your actions after imbibing."
			if(LONGISLANDICEDTEA)
				icon_state = "longislandicedteaglass"
				name = "\improper Long Island Iced Tea"
				desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			if(THREEMILEISLAND)
				icon_state = "threemileislandglass"
				name = "\improper Three Mile Island Iced Tea"
				desc = "A glass of this is sure to prevent a meltdown. Or cause one."
			if(MARGARITA)
				icon_state = "margaritaglass"
				name = "margarita"
				desc = "On the rocks with salt on the rim. Arriba!"
			if(BLACKRUSSIAN)
				icon_state = "blackrussianglass"
				name = "\improper Black Russian"
				desc = "For the lactose-intolerant. Still as classy as a White Russian."
			if(VODKATONIC)
				icon_state = "vodkatonicglass"
				name = "vodka and tonic"
				desc = "For when a gin and tonic isn't Russian enough."
			if(MANHATTAN)
				icon_state = "manhattanglass"
				name = "\improper Manhattan"
				desc = "The Detective's undercover drink of choice. He never could stomach gin..."
			if(MANHATTAN_PROJ)
				icon_state = "proj_manhattanglass"
				name = "\improper Manhattan Project"
				desc = "A scientist's drink of choice, for thinking about how to blow up the station."
			if(GINFIZZ)
				icon_state = "ginfizzglass"
				name = "\improper Gin Fizz"
				desc = "Refreshingly lemony, deliciously dry."
			if(IRISHCOFFEE)
				icon_state = "irishcoffeeglass"
				name = "irish coffee"
				desc = "Coffee served with irish cream. Regular cream just isn't the same."
			if(HOOCH)
				icon_state = "glass_brown2"
				item_state = "glass_brown2"
				name = "hooch"
				desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
			if(WHISKEYSODA)
				icon_state = "whiskeysodaglass2"
				name = "whiskey soda"
				desc = "Ultimate refreshment."
			if(TONIC)
				icon_state = "glass_clear"
				item_state = "glass_clear"
				name = "glass of tonic water"
				desc = "Quinine tastes funny, but at least it'll keep that space malaria away."
			if(SODAWATER)
				icon_state = "glass_clear"
				item_state = "glass_clear"
				name = "glass of soda water"
				desc = "Soda water. Why not make a scotch and soda?"
			if(WATER)
				icon_state = "glass_clear"
				item_state = "glass_clear"
				name = "glass of water"
				desc = "The father of all refreshments."
			if(SPACEMOUNTAINWIND)
				icon_state = "Space_mountain_wind_glass"
				item_state = "Space_mountain_wind_glass"
				name = "glass of Space Mountain Wind"
				desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
			if(THIRTEENLOKO)
				icon_state = "thirteen_loko_glass"
				item_state = "thirteen_loko_glass"
				name = "glass of Thirteen Loko"
				desc = "This is a glass of Thirteen Loko. It appears to be of the highest quality. The drink, not the glass."
			if(DR_GIBB)
				icon_state = "dr_gibb_glass"
				item_state = "dr_gibb_glass"
				name = "glass of Dr. Gibb"
				desc = "Dr. Gibb. Not as dangerous as the name might imply."
			if(SPACE_UP)
				icon_state = "space-up_glass"
				item_state = "space-up_glass"
				name = "glass of Space-up"
				desc = "Space-up. It helps keep your cool."
			if(MOONSHINE)
				icon_state = "glass_clear"
				item_state = "glass_clear"
				name = "moonshine"
				desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
			if(SOYMILK)
				icon_state = "glass_white"
				item_state = "glass_white"
				name = "glass of soy milk"
				desc = "White and nutritious soy goodness!"
			if(BERRYJUICE)
				icon_state = "berryjuice"
				item_state = "berryjuice"
				name = "glass of berry juice"
				desc = "Berry juice. Or maybe it's jam. Who cares?"
			if(POISONBERRYJUICE)
				icon_state = "poisonberryjuice"
				item_state = "poisonberryjuice"
				name = "glass of poison berry juice"
				desc = "Drinking this may not be a good idea."
			if(CARROTJUICE)
				icon_state = "carrotjuice"
				item_state = "carrotjuice"
				name = "glass of carrot juice"
				desc = "It's like a carrot, but less crunchy."
			if(BANANA)
				icon_state = "banana"
				item_state = "banana"
				name = "glass of banana juice"
				desc = "The raw essence of a banana. HONK"
			if(BAHAMA_MAMA)
				icon_state = "bahama_mama"
				name = "\improper Bahama Mama"
				desc = "A delicious tropical cocktail."
			if(SINGULO)
				icon_state = "singulo"
				name = "\improper Singulo"
				desc = "IT'S LOOSE!"
			if(ALLIESCOCKTAIL)
				icon_state = "alliescocktail"
				name = "\improper Allies Cocktail"
				desc = "A cocktail of spirits from three historical Terran nations, symbolizing their alliance in a great war."
			if(ANTIFREEZE)
				icon_state = "antifreeze"
				item_state = "antifreeze"
				name = "\improper Anti-freeze"
				desc = "The ultimate refreshment."
			if(BAREFOOT)
				icon_state = "b&p"
				name = "\improper Barefoot"
				desc = "Barefoot and pregnant."
			if(DEMONSBLOOD)
				icon_state = "demonsblood"
				name = "\improper Demon's Blood"
				desc = "Just looking at this thing makes the hair on the back of your neck stand up."
			if(BOOGER)
				icon_state = "booger"
				item_state = "booger"
				name = "\improper Booger"
				desc = "The color reminds you of something that came out of the clown's nose."
			if(SNOWWHITE)
				icon_state = "snowwhite"
				item_state = "snowwhite"
				name = "\improper Snow White"
				desc = "Pale lager mixed with lemon-lime soda. Refreshing and sweet."
			if(ALOE)
				icon_state = "aloe"
				name = "\improper Aloe"
				desc = "Watermelon juice and irish cream. Contains no actual aloe."
			if(ANDALUSIA)
				icon_state = "andalusia"
				name = "\improper Andalusia"
				desc = "A strong cocktail named after a historical Terran land."
			if(SBITEN)
				icon_state = "sbitenglass"
				name = "sbiten"
				desc = "A spicy mix of vodka and spice. Very hot."
			if(RED_MEAD)
				icon_state = "red_meadglass"
				name = "red mead"
				desc = "A crimson beverage consumed by space vikings. The coloration is from berries... you hope."
			if(MEAD)
				icon_state = "meadglass"
				name = "mead"
				desc = "A beverage consumed by space vikings on their long raids and rowdy festivities."
			if(ICED_BEER)
				icon_state = "iced_beerglass"
				item_state = "iced_beerglass"
				name = "iced beer"
				desc = "A beer so frosty the air around it freezes."
			if(GROG)
				icon_state = "grogglass"
				name = "grog"
				desc = "The favorite of pirates everywhere."
			if(SOY_LATTE)
				icon_state = "soy_latte"
				item_state = "soy_latte"
				name = "soy latte"
				desc = "The hipster version of the classic cafe latte."
			if(CAFE_LATTE)
				icon_state = "cafe_latte"
				item_state = "cafe_latte"
				name = "cafe latte"
				desc = "A true classic: steamed milk, some espresso, and foamed milk to top it all off."
			if(ACIDSPIT)
				icon_state = "acidspitglass"
				item_state = "acidspitglass"
				name = "\improper Acid Spit"
				desc = "Bites like a xeno queen."
			if(AMASEC)
				icon_state = "amasecglass"
				name = "\improper Amasec"
				desc = "A grim and dark drink that knows only war."
			if(NEUROTOXIN)
				icon_state = "neurotoxinglass"
				name = "\improper Neurotoxin"
				desc = "Guaranteed to knock you silly."
			if(HIPPIESDELIGHT)
				icon_state = "hippiesdelightglass"
				name = "\improper Hippie's Delight"
				desc = "A drink popular in the 1960s."
			if(BANANAHONK)
				icon_state = "bananahonkglass"
				name = "\improper Banana Honk"
				desc = "A cocktail from the clown planet."
			if(SILENCER)
				icon_state = "silencerglass"
				item_state = "silencerglass"
				name = "\improper Silencer"
				desc = "The mime's favorite, though you won't hear him ask for it."
			if(NOTHING)
				icon_state = "nothing"
				item_state = "nothing"
				name = "nothing"
				desc = "Absolutely nothing."
			if(DEVILSKISS)
				icon_state = "devilskiss"
				name = "\improper Devil's Kiss"
				desc = "Creepy time!"
			if(CHANGELINGSTING)
				icon_state = "changelingsting"
				name = "\improper Changeling Sting"
				desc = "Stings, but not deadly."
			if(IRISHCARBOMB)
				icon_state = "irishcarbomb"
				item_state = "irishcarbomb"
				name = "\improper Irish Car Bomb"
				desc = "Something about this drink troubles you."
			if(SYNDICATEBOMB)
				icon_state = "syndicatebomb"
				name = "\improper Syndicate Bomb"
				desc = "Somebody set up us the bomb!"
				isGlass = 0//blablabla hidden features, blablabla joke material
			if(ERIKASURPRISE)
				icon_state = "erikasurprise"
				name = "\improper Erika Surprise"
				desc = "The surprise is, it's green!"
			if(DRIESTMARTINI)
				icon_state = "driestmartiniglass"
				name = "\improper Driest Martini"
				desc = "Only for the experienced. You think you see sand floating in the glass."
			if(ICE)
				icon_state = "iceglass"
				item_state = "iceglass"
				name = "glass of ice"
				desc = "Generally, you're supposed to put something else in there too..."
			if(ICECOFFEE)
				icon_state = "icedcoffeeglass"
				item_state = "icedcoffeeglass"
				name = "iced coffee"
				desc = "For when you need a coffee without the warmth."
			if(COFFEE)
				icon_state = "glass_brown"
				item_state = "glass_brown"
				name = "glass of coffee"
				desc = "Careful, it's hot!"
			if(BILK)
				icon_state = "glass_brown"
				item_state = "glass_brown"
				name = "glass of bilk"
				desc = "A brew of milk and beer. For alcoholics who fear osteoporosis."
			if(FUEL)
				icon_state = "dr_gibb_glass"
				name = "glass of welder fuel"
				desc = "Unless you are an industrial tool, this is probably not safe for consumption."
			if(BROWNSTAR)
				icon_state = "brownstar"
				item_state = "brownstar"
				name = "\improper Brown Star"
				desc = "It's not what it sounds like..."
			if(ICETEA)
				icon_state = "icedteaglass"
				item_state = "icedteaglass"
				name = "iced tea"
				desc = "Like tea, but refreshes rather than relaxes."
			if(ARNOLDPALMER)
				icon_state = "arnoldpalmer"
				name = "\improper Arnold Palmer"
				desc = "Known as half and half to some. A mix of ice tea and lemonade."
			if(MILKSHAKE)
				icon_state = "milkshake"
				item_state = "milkshake"
				name = "milkshake"
				desc = "Brings all the boys to the yard."
			if(LEMONADE)
				icon_state = "lemonade"
				item_state = "lemonade"
				name = "lemonade"
				desc = "Oh, the nostalgia..."
			if(KIRASPECIAL)
				icon_state = "kiraspecial"
				name = "\improper Kira Special"
				desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
			if(REWRITER)
				icon_state = "rewriter"
				name = "\improper Rewriter"
				desc = "This will cure your dyslexia and cause your arrhythmia."
			if(PINACOLADA)
				icon_state = "pinacolada"
				name = "\improper Pina Colada"
				desc = "If you like this and getting caught in the rain, come with me and escape."
			if(SANGRIA)
				icon_state = "sangria"
				item_state = "sangria"
				name = "\improper Sangria"
				desc = "So sweet you won't notice the alcohol until you're wasted."
			if(DANS_WHISKEY)
				icon_state = "dans_whiskey"
				item_state = "dans_whiskey"
				name = "\improper Discount Dan's 'Malt' Whiskey"
				desc = "The cheapest path to liver failure."
			if(GREYVODKA)
				icon_state = "ginvodkaglass"
				item_state = "ginvodkaglass"
				name = "glass of greyshirt vodka"
				desc = "A questionable concoction of ingredients found within maintenance. Tastes just like you'd expect."
=======

			name = R.glass_name ? R.glass_name : "glass of " + R.name //uses glass of [reagent name] if a glass name isn't defined
			desc = R.glass_desc ? R.glass_desc : R.description //uses the description if a glass description isn't defined
			isGlass = R.glass_isGlass

			if(R.glass_icon_state)
				icon_state = R.glass_icon_state
				item_state = R.glass_icon_state
			else
				icon_state ="glass_colour"
				item_state ="glass_colour"
				var/image/filling = image('icons/obj/reagentfillings.dmi', src, "glass")
				filling.icon += mix_color_from_reagents(reagents.reagent_list)
				filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
				overlays += filling
	else
		icon_state = "glass_empty"
		item_state = "glass_empty"
		name = "drinking glass"
		desc = "Your standard drinking glass."

	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

		/*
>>>>>>> 846620c67e... reworks drinking glass code
			if(PINTPOINTER)
				var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/P = new (get_turf(src))
				if(reagents.last_ckey_transferred_to_this)
					for(var/client/C in clients)
						if(C.ckey == reagents.last_ckey_transferred_to_this)
							var/mob/M = C.mob
							P.creator = M
				reagents.trans_to(P, reagents.total_volume)
				spawn(1)
					qdel(src)
			if(SCIENTISTS_SERENDIPITY)
				if(reagents.get_reagent_amount(SCIENTISTS_SERENDIPITY)<10) //You need at least 10u to get the tech bonus
					icon_state = "scientists_surprise"
					name = "\improper Scientist's Surprise"
					desc = "There is as yet insufficient data for a meaningful answer."
				else
					icon_state = "scientists_serendipity"
					name = "\improper Scientist's Serendipity"
					desc = "Knock back a cold glass of R&D."
					origin_tech = "materials=7;engineering=3;plasmatech=2;powerstorage=4;bluespace=6;combat=3;magnets=6;programming=3"*/

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/examine(mob/user)
	..()
	if(reagents.get_master_reagent_id() == METABUDDY && istype(user) && user.client)
		to_chat(user,"<span class='warning'>This one is made out to 'My very best friend, [user.client.ckey]'</span>")

// for /obj/machinery/vending/sovietsoda
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda/New()
	..()
	reagents.add_reagent(SODAWATER, 50)
	on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola/New()
	..()
	reagents.add_reagent(COLA, 50)
	on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/toxinsspecial/New()
	..()
	reagents.add_reagent(TOXINSSPECIAL, 30)
	on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/irishcoffee
	name = "irish coffee"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/irishcoffee/New()
	..()
	reagents.add_reagent(IRISHCOFFEE, 50)
	on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/sake
	name = "glass of sake"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/sake/New()
	..()
	reagents.add_reagent(SAKE, 50)
	on_reagent_change()

// Cafe Stuff. Mugs act the same as drinking glasses, but they don't break when thrown.

/obj/item/weapon/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "A simple mug."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "mug_empty"
	item_state = "mug_empty"
	isGlass = 0
	amount_per_transfer_from_this = 10
	volume = 30
	starting_materials = list(MAT_IRON = 500)

/obj/item/weapon/reagent_containers/food/drinks/mug/on_reagent_change()

	if (reagents.reagent_list.len > 0)
		item_state = "mug_empty"

		var/datum/reagent/R = reagents.get_master_reagent()

		name = R.mug_name ? R.mug_name : "\improper [R.name]"
		desc = R.mug_desc ? R.mug_desc : R.description
		isGlass = R.glass_isGlass

		if(R.mug_icon_state)
			icon_state = R.mug_icon_state
			item_state = R.mug_icon_state

		else
			make_reagent_overlay()
	else
		overlays.len = 0
		icon_state = "mug_empty"
		name = "mug"
		desc = "A simple mug."
		return

/obj/item/weapon/reagent_containers/food/drinks/mug/proc/make_reagent_overlay()
	overlays.len = 0
	icon_state ="mug_empty"
	var/image/filling = image('icons/obj/reagentfillings.dmi', src, "mug")
	filling.icon += mix_color_from_reagents(reagents.reagent_list)
	filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
	overlays += filling
