

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	isGlass = 1
	amount_per_transfer_from_this = 10
	volume = 50
	starting_materials = list(MAT_GLASS = 500)
	force = 5
	smashtext = ""  //due to inconsistencies in the names of the drinks just don't say anything
	smashname = "broken glass"
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

//removed smashing - now uses smashing proc from drinks.dm - Hinaichigo
//also now produces a broken glass when smashed instead of just a shard

	on_reagent_change()
		..()
		/*if(reagents.reagent_list.len > 1 )
			icon_state = "glass_brown"
			name = "Glass of Hooch"
			desc = "Two or more drinks, mixed together."*/
		/*else if(reagents.reagent_list.len == 1)
			for(var/datum/reagent/R in reagents.reagent_list)
				switch(R.id)*/
		viewcontents = 1
		overlays.len = 0
		if (reagents.reagent_list.len > 0)
			//mrid = R.get_master_reagent_id()
			flammable = 0
			if(!molotov)
				lit = 0
			light_color = null
			set_light(0)
			isGlass = 1
			switch(reagents.get_master_reagent_id())
				if("beer")
					icon_state = "beerglass"
					name = "beer glass"
					desc = "A freezing pint of beer."
				if("beer2")
					icon_state = "beerglass"
					name = "beer glass"
					desc = "A freezing pint of beer."
				if("ale")
					icon_state = "aleglass"
					name = "ale glass"
					desc = "A freezing pint of delicious ale."
				if("milk")
					icon_state = "glass_white"
					name = "glass of milk"
					desc = "White and nutritious goodness!"
				if("cream")
					icon_state  = "glass_white"
					name = "glass of cream"
					desc = "Ewwww..."
				if("chocolate")
					icon_state  = "chocolateglass"
					name = "glass of chocolate"
					desc = "Tasty."
				if("lemonjuice")
					icon_state  = "lemonglass"
					name = "glass of lemonjuice"
					desc = "Sour..."
				if("cola")
					icon_state  = "glass_brown"
					name = "glass of Space Cola"
					desc = "A glass of refreshing Space Cola."
				if("nuka_cola")
					icon_state = "nuka_colaglass"
					name = "\improper Nuka Cola"
					desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
				if("orangejuice")
					icon_state = "glass_orange"
					name = "glass of orange juice"
					desc = "Vitamins! Yay!"
				if("tomatojuice")
					icon_state = "glass_red"
					name = "glass of tomato juice"
					desc = "Are you sure this is tomato juice?"
				if("blood")
					icon_state = "glass_red"
					name = "glass of tomato juice"
					desc = "Are you sure this is tomato juice?"
				if("limejuice")
					icon_state = "glass_green"
					name = "glass of lime juice"
					desc = "A glass of sweet-sour lime juice."
				if("whiskey")
					icon_state = "whiskeyglass"
					name = "glass of whiskey"
					desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
				if("gin")
					icon_state = "ginvodkaglass"
					name = "glass of gin"
					desc = "A crystal clear glass of Griffeater gin."
				if("vodka")
					icon_state = "ginvodkaglass"
					name = "glass of vodka"
					desc = "The glass contain wodka. Xynta."
				if("sake")
					icon_state = "ginvodkaglass"
					name = "glass of sake"
					desc = "A glass of Sake."
				if("goldschlager")
					icon_state = "ginvodkaglass"
					name = "glass of Goldschlager"
					desc = "100 proof that teen girls will drink anything with gold in it."
				if("wine")
					icon_state = "wineglass"
					name = "glass of wine"
					desc = "A very classy looking drink."
				if("cognac")
					icon_state = "cognacglass"
					name = "glass of cognac"
					desc = "Damn, you feel like some kind of French aristocrat just by holding this."
				if ("kahlua")
					icon_state = "kahluaglass"
					name = "glass of RR coffee liquor"
					desc = "DAMN, THIS THING LOOKS ROBUST"
				if("vermouth")
					icon_state = "vermouthglass"
					name = "glass of vermouth"
					desc = "You wonder why you're even drinking this straight."
				if("tequila")
					icon_state = "tequilaglass"
					name = "glass of tequila"
					desc = "Now all that's missing is the weird colored shades!"
				if("patron")
					icon_state = "patronglass"
					name = "glass of Patron"
					desc = "Drinking Patron in the bar, with all the subpar ladies."
				if("rum")
					icon_state = "rumglass"
					name = "glass of rum"
					desc = "Now you want to Pray for a pirate suit, don't you?"
				if("gintonic")
					icon_state = "gintonicglass"
					name = "gin and tonic"
					desc = "A mild but still great cocktail. Drink up, like a true Englishman."
				if("whiskeycola")
					icon_state = "whiskeycolaglass"
					name = "whiskey cola"
					desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
				if("whiterussian")
					icon_state = "whiterussianglass"
					name = "\improper White Russian"
					desc = "A very nice looking drink. But that's just, like, your opinion, man."
				if("screwdrivercocktail")
					icon_state = "screwdriverglass"
					name = "\improper Screwdriver"
					desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
				if("bloodymary")
					icon_state = "bloodymaryglass"
					name = "\improper Bloody Mary"
					desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
				if("martini")
					icon_state = "martiniglass"
					name = "classic martini"
					desc = "Damn, the bartender even stirred it, not shook it."
				if("vodkamartini")
					icon_state = "martiniglass"
					name = "vodka martini"
					desc ="A bastardisation of the classic martini. Still great."
				if("gargleblaster")
					icon_state = "gargleblasterglass"
					name = "\improper Pan-Galactic Gargle Blaster"
					desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
				if("bravebull")
					icon_state = "bravebullglass"
					name = "\improper Brave Bull"
					desc = "Tequila and coffee liquor, brought together in a mouthwatering mixture. Drink up."
				if("tequilasunrise")
					icon_state = "tequilasunriseglass"
					name = "\improper Tequila Sunrise"
					desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
				if("toxinsspecial")
					icon_state = "toxinsspecialglass"
					name = "\improper Toxins Special"
					desc = "Whoah, this thing is on FIRE!"
				if("beepskysmash")
					icon_state = "beepskysmashglass"
					name = "\improper Beepsky Smash"
					desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
				if("doctorsdelight")
					icon_state = "doctorsdelightglass"
					name = "\improper Doctor's Delight"
					desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
				if("manlydorf")
					icon_state = "manlydorfglass"
					name = "The Manly Dorf"
					desc = "A manly concotion made from Ale and Beer. Intended for true men only."
				if("irishcream")
					icon_state = "irishcreamglass"
					name = "\improper Irish Cream"
					desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
				if("cubalibre")
					icon_state = "cubalibreglass"
					name = "\improper Cuba Libre"
					desc = "A classic mix of rum and cola."
				if("b52")
					icon_state = "b52glass"
					name = "\improper B-52"
					desc = "Kahlua, Irish Cream, and congac. You will get bombed."
					light_color = "#000080"
					if(!lit)
						flammable = 1
				if("atomicbomb")
					icon_state = "atomicbombglass"
					name = "\improper Atomic Bomb"
					desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
				if("longislandicedtea")
					icon_state = "longislandicedteaglass"
					name = "\improper Long Island Iced Tea"
					desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
				if("threemileisland")
					icon_state = "threemileislandglass"
					name = "\improper Three Mile Island Ice Tea"
					desc = "A glass of this is sure to prevent a meltdown."
				if("margarita")
					icon_state = "margaritaglass"
					name = "\improper Margarita"
					desc = "On the rocks with salt on the rim. Arriba~!"
				if("blackrussian")
					icon_state = "blackrussianglass"
					name = "\improper Black Russian"
					desc = "For the lactose-intolerant. Still as classy as a White Russian."
				if("vodkatonic")
					icon_state = "vodkatonicglass"
					name = "vodka and tonic"
					desc = "For when a gin and tonic isn't Russian enough."
				if("manhattan")
					icon_state = "manhattanglass"
					name = "\improper Manhattan"
					desc = "The Detective's undercover drink of choice. He never could stomach gin..."
				if("manhattan_proj")
					icon_state = "proj_manhattanglass"
					name = "\improper Manhattan Project"
					desc = "A scienitst drink of choice, for thinking how to blow up the station."
				if("ginfizz")
					icon_state = "ginfizzglass"
					name = "\improper Gin Fizz"
					desc = "Refreshingly lemony, deliciously dry."
				if("irishcoffee")
					icon_state = "irishcoffeeglass"
					name = "\improper Irish Coffee"
					desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
				if("hooch")
					icon_state = "glass_brown2"
					name = "\improper Hooch"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if("whiskeysoda")
					icon_state = "whiskeysodaglass2"
					name = "whiskey soda"
					desc = "Ultimate refreshment."
				if("tonic")
					icon_state = "glass_clear"
					name = "glass of tonic water"
					desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
				if("sodawater")
					icon_state = "glass_clear"
					name = "glass of soda water"
					desc = "Soda water. Why not make a scotch and soda?"
				if("water")
					icon_state = "glass_clear"
					name = "glass of water"
					desc = "The father of all refreshments."
				if("spacemountainwind")
					icon_state = "Space_mountain_wind_glass"
					name = "glass of Space Mountain Wind"
					desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
				if("thirteenloko")
					icon_state = "thirteen_loko_glass"
					name = "glass of Thirteen Loko"
					desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."
				if("dr_gibb")
					icon_state = "dr_gibb_glass"
					name = "glass of Dr. Gibb"
					desc = "Dr. Gibb. Not as dangerous as the name might imply."
				if("space_up")
					icon_state = "space-up_glass"
					name = "glass of Space-up"
					desc = "Space-up. It helps keep your cool."
				if("moonshine")
					icon_state = "glass_clear"
					name = "\improper Moonshine"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if("soymilk")
					icon_state = "glass_white"
					name = "glass of soy milk"
					desc = "White and nutritious soy goodness!"
				if("berryjuice")
					icon_state = "berryjuice"
					name = "glass of berry juice"
					desc = "Berry juice. Or maybe its jam. Who cares?"
				if("poisonberryjuice")
					icon_state = "poisonberryjuice"
					name = "glass of poison berry juice"
					desc = "A glass of deadly juice."
				if("carrotjuice")
					icon_state = "carrotjuice"
					name = "glass of  carrot juice"
					desc = "It is just like a carrot but without crunching."
				if("banana")
					icon_state = "banana"
					name = "glass of banana juice"
					desc = "The raw essence of a banana. HONK"
				if("bahama_mama")
					icon_state = "bahama_mama"
					name = "\improper Bahama Mama"
					desc = "Tropic cocktail."
				if("singulo")
					icon_state = "singulo"
					name = "\improper Singulo"
					desc = "A blue-space beverage."
				if("alliescocktail")
					icon_state = "alliescocktail"
					name = "\improper Allies Cocktail"
					desc = "A drink made from your allies."
				if("antifreeze")
					icon_state = "antifreeze"
					name = "\improper Anti-freeze"
					desc = "The ultimate refreshment."
				if("barefoot")
					icon_state = "b&p"
					name = "\improper Barefoot"
					desc = "Barefoot and pregnant."
				if("demonsblood")
					icon_state = "demonsblood"
					name = "\improper Demon's Blood"
					desc = "Just looking at this thing makes the hair at the back of your neck stand up."
				if("booger")
					icon_state = "booger"
					name = "\improper Booger"
					desc = "Ewww..."
				if("snowwhite")
					icon_state = "snowwhite"
					name = "\improper Snow White"
					desc = "A cold refreshment."
				if("aloe")
					icon_state = "aloe"
					name = "aloe"
					desc = "Very, very, very good."
				if("andalusia")
					icon_state = "andalusia"
					name = "\improper Andalusia"
					desc = "A nice, strange named drink."
				if("sbiten")
					icon_state = "sbitenglass"
					name = "\improper Sbiten"
					desc = "A spicy mix of vodka and spice. Very hot."
				if("red_mead")
					icon_state = "red_meadglass"
					name = "red mead"
					desc = "A True Vikings Beverage, though its color is strange."
				if("mead")
					icon_state = "meadglass"
					name = "mead"
					desc = "A Vikings Beverage, though a cheap one."
				if("iced_beer")
					icon_state = "iced_beerglass"
					name = "iced Beer"
					desc = "A beer so frosty, the air around it freezes."
				if("grog")
					icon_state = "grogglass"
					name = "grog"
					desc = "A fine and cepa drink for Space."
				if("soy_latte")
					icon_state = "soy_latte"
					name = "soy latte"
					desc = "A nice and refrshing beverage while you are reading."
				if("cafe_latte")
					icon_state = "cafe_latte"
					name = "cafe latte"
					desc = "A nice, strong and refreshing beverage while you are reading."
				if("acidspit")
					icon_state = "acidspitglass"
					name = "\improper Acid Spit"
					desc = "A drink from Nanotrasen. Made from live aliens."
				if("amasec")
					icon_state = "amasecglass"
					name = "\improper Amasec"
					desc = "Always handy before COMBAT!!!"
				if("neurotoxin")
					icon_state = "neurotoxinglass"
					name = "\improper Neurotoxin"
					desc = "A drink that is guaranteed to knock you silly."
				if("hippiesdelight")
					icon_state = "hippiesdelightglass"
					name = "\improper Hippie's Delight"
					desc = "A drink enjoyed by people during the 1960's."
				if("bananahonk")
					icon_state = "bananahonkglass"
					name = "\improper Banana Honk"
					desc = "A drink from banana heaven."
				if("silencer")
					icon_state = "silencerglass"
					name = "\improper Silencer"
					desc = "A drink from mime heaven."
				if("nothing")
					icon_state = "nothing"
					name = "nothing"
					desc = "Absolutely nothing."
				if("devilskiss")
					icon_state = "devilskiss"
					name = "\improper Devils Kiss"
					desc = "Creepy time!"
				if("changelingsting")
					icon_state = "changelingsting"
					name = "\improper Changeling Sting"
					desc = "A stingy drink."
				if("irishcarbomb")
					icon_state = "irishcarbomb"
					name = "\improper Irish Car Bomb"
					desc = "An irish car bomb."
				if("syndicatebomb")
					icon_state = "syndicatebomb"
					name = "\improper Syndicate Bomb"
					desc = "A syndicate bomb."
					isGlass = 0//blablabla hidden features, blablabla joke material
				if("erikasurprise")
					icon_state = "erikasurprise"
					name = "\improper Erika Surprise"
					desc = "The surprise is, it's green!"
				if("driestmartini")
					icon_state = "driestmartiniglass"
					name = "\improper Driest Martini"
					desc = "Only for the experienced. You think you see sand floating in the glass."
				if("ice")
					icon_state = "iceglass"
					name = "glass of ice"
					desc = "Generally, you're supposed to put something else in there too..."
				if("icecoffee")
					icon_state = "icedcoffeeglass"
					name = "iced Coffee"
					desc = "A drink to perk you up and refresh you!"
				if("coffee")
					icon_state = "glass_brown"
					name = "glass of coffee"
					desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
				if("bilk")
					icon_state = "glass_brown"
					name = "glass of bilk"
					desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
				if("fuel")
					icon_state = "dr_gibb_glass"
					name = "glass of welder fuel"
					desc = "Unless you are an industrial tool, this is probably not safe for consumption."
				if("brownstar")
					icon_state = "brownstar"
					name = "\improper Brown Star"
					desc = "Its not what it sounds like..."
				if("icetea")
					icon_state = "icetea"
					name = "iced tea"
					desc = "No relation to a certain rap artist/ actor."
				if("milkshake")
					icon_state = "milkshake"
					name = "milkshake"
					desc = "Glorious brainfreezing mixture."
				if("lemonade")
					icon_state = "lemonade"
					name = "lemonade"
					desc = "Oh the nostalgia..."
				if("kiraspecial")
					icon_state = "kiraspecial"
					name = "\improper Kira Special"
					desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
				if("rewriter")
					icon_state = "rewriter"
					name = "\improper Rewriter"
					desc = "The secert of the sanctuary of the Libarian..."
				else
					icon_state ="glass_colour"
					get_reagent_name(src)
					var/image/filling = image('icons/obj/reagentfillings.dmi', src, "glass")
					filling.icon += mix_color_from_reagents(reagents.reagent_list)
					filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
					overlays += filling



			if(reagents.has_reagent("blackcolor"))
				icon_state ="blackglass"
				name = "international drink of mystery"
				desc = "The identity of this drink has been concealed for its protection."
				viewcontents = 0
		else
			icon_state = "glass_empty"
			name = "drinking glass"
			desc = "Your standard drinking glass."
			return

// for /obj/machinery/vending/sovietsoda
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda
	New()
		..()
		reagents.add_reagent("sodawater", 50)
		on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola
	New()
		..()
		reagents.add_reagent("cola", 50)
		on_reagent_change()

// Cafe Stuff. Mugs act the same as drinking glasses, but they don't break when thrown.

/obj/item/weapon/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "A simple mug."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "mug_empty"
	isGlass = 0
	amount_per_transfer_from_this = 10
	volume = 30
	starting_materials = list(MAT_GLASS = 500)

	on_reagent_change()

		if (reagents.reagent_list.len > 0)

			switch(reagents.get_master_reagent_id())
				if("tea")
					icon_state = "tea"
					name = "Tea"
					desc = "A warm mug of tea."
				if("greentea")
					icon_state = "greentea"
					name = "Green Tea"
					desc = "Green Tea served in a traditional Japanese tea cup, just like in your Chinese cartoons!"
				if("redtea")
					icon_state = "redtea"
					name = "Red Tea"
					desc = "Red Tea served in a traditional Chinese tea cup, just like in your Malaysian movies!"
				if("acidtea")
					icon_state = "acidtea"
					name = "Earl's Grey Tea"
					desc = "A sizzling mug of tea made just for Greys."
				if("yinyang")
					icon_state = "yinyang"
					name = "Zen Tea"
					desc = "Enjoy inner peace and ignore the watered down taste"
				if("dantea")
					icon_state = "dantea"
					name = "Discount Dans Green Flavor Tea"
					desc = "Tea probably shouldn't be sizzling like that..."
				if("singularitea")
					icon_state = "singularitea"
					name = "Singularitea"
					desc = "Brewed under intense radiation to be extra flavorful!"
				if("mint")
					icon_state = "mint"
					name = "Groans Tea: Minty Delight Flavor"
					desc = "Groans knows mint might not be the kind of flavor our fans expect from us, but we've made sure to give it that patented Groans zing."
				if("chamomile")
					icon_state = "chamomile"
					name = "Groans Tea: Chamomile Flavor"
					desc = "Groans presents the perfect cure for insomnia; Chamomile!"
				if("exchamomile")
					icon_state = "exchamomile"
					name = "Groans Banned Tea: EXTREME Chamomile Flavor"
					desc = "Banned literally everywhere."
				if("fancydan")
					icon_state = "fancydan"
					name = "Groans Banned Tea: Fancy Dan Flavor"
					desc = "Banned literally everywhere."
				if("gyro")
					icon_state = "gyro"
					name = "Gyro"
					desc = "Nyo ho ho~"
				if("chifir")
					icon_state = "chifir"
					name = "Chifir"
					desc = "Russian style of tea, not for those with weak stomachs."
				if("plasmatea")
					icon_state = "plasmatea"
					name = "Plasma Pekoe"
					desc = "You can practically taste the science, or maybe that's just the horrible plasma burns."
				if("coffee")
					icon_state = "coffee"
					name = "Coffee"
					desc = "A warm mug of coffee."
				if("cafe_latte")
					icon_state = "latte"
					name = "Latte"
					desc = "Coffee made with espresso and milk."
				if("soy_latte")
					icon_state = "soylatte"
					name = "Soy Latte"
					desc = "Latte made with soy milk."
				if("espresso")
					icon_state = "espresso"
					name = "Espresso"
					desc = "Coffee made with water."
				if("cappuccino")
					icon_state = "cappuccino"
					name = "Cappuccino"
					desc = "coffee made with espresso, milk, and steamed milk."
				if("doppio")
					icon_state = "doppio"
					name = "Doppio"
					desc = "Ring ring ring"
				if("tonio")
					icon_state = "tonio"
					name = "Tonio"
					desc = "Delicious, and it'll help you out if you get in a Jam."
				if("passione")
					icon_state = "passione"
					name = "Passione"
					desc = "Sometimes referred to as a 'Venti Aureo'"
				if("seccoffee")
					icon_state = "seccoffee"
					name = "Wake up call"
					desc = "The perfect start for any Sec officer's day."
				if("medcoffee")
					icon_state = "medcoffee"
					name = "Lifeline"
					desc = "Some days, the only thing that keeps you going is cryo and caffeine."
				if("detcoffee")
					icon_state = "detcoffee"
					name = "Joe"
					desc = "The lights, the smoke, the grime, the station itself felt alive that day as I stepped into my office, mug in hand. It was another one of those days. Some Nurse got smoked in one of the tunnels, and it came down to me to catch the guy did it. I got up to close the blinds of my office, when an officer burst through my door. There had been another one offed in the tunnels, this time an assistant. I grumbled and downed some of my joe. It was bitter, tasteless, but it was what kept me going. I remember back when I was a rookie, this stuff used to taste so great to me. I guess that's just another sign of how this station changes people. I put my mug back down on my desk, dusted off my jacket, and lit my last cigar. I checked to make sure my faithful revolver was loaded, and stepped out, back into the cold halls of the station."
				if("etank")
					icon_state = "etank"
					name = "Recharger"
					desc = "Helps you get back on your feet after a long day of robot maintenance. Can also be used as a substitute for motor oil."
				if("greytea")
					icon_state = "greytea"
					name = "Tide"
					desc = "This probably shouldn't be considered tea..."





				else
					icon_state ="mug_what"
					name = "mug of ..something?"
					desc = "You aren't really sure what this is."
		else
			icon_state = "mug_empty"
			name = "mug"
			desc = "A simple mug."
			return