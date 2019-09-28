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
	/*if(reagents.reagent_list.len > 1 )
		icon_state = "glass_brown"
		item_state = "glass_brown"
		name = "Glass of Hooch"
		desc = "Two or more drinks, mixed together."*/
	/*else if(reagents.reagent_list.len == 1)
		for(var/datum/reagent/R in reagents.reagent_list)
			switch(R.id)*/
	viewcontents = 1
	overlays.len = 0
	flammable = 0
	if(!molotov)
		lit = 0
	light_color = null
	set_light(0)
	if (reagents.reagent_list.len > 0)
		//mrid = R.get_master_reagent_id()
		isGlass = 1
		item_state = "glass_empty"
		origin_tech = ""
		switch(reagents.get_master_reagent_id())
			if(BEER)
				icon_state = "beerglass"
				item_state = "beerglass"
				name = "beer glass"
				desc = "A cold pint of pale lager."
			if(BEER2)
				icon_state = "beerglass"
				item_state = "beerglass"
				name = "beer glass"
				desc = "A cold pint of pale lager."
			if(ALE)
				icon_state = "aleglass"
				item_state = "aleglass"
				name = "ale glass"
				desc = "A cold pint of delicious ale."
			if(MILK)
				icon_state = "glass_white"
				item_state = "glass_white"
				name = "glass of milk"
				desc = "White and nutritious goodness!"
			if(CREAM)
				icon_state  = "glass_white"
				item_state = "glass_white"
				name = "glass of cream"
				desc = "Like milk, but thicker."
			if("chocolate")
				icon_state  = "chocolateglass"
				item_state  = "chocolateglass"
				name = "glass of chocolate"
				desc = "Tasty."
			if(LEMONJUICE)
				icon_state  = "lemonglass"
				item_state  = "lemonglass"
				name = "glass of lemonjuice"
				desc = "Sour..."
			if(COLA)
				icon_state  = "glass_brown"
				item_state = "glass_brown"
				name = "glass of Space Cola"
				desc = "A glass of refreshing Space Cola."
			if(NUKA_COLA)
				icon_state = "nuka_colaglass"
				name = "\improper Nuka Cola"
				desc = "Don't cry. Don't raise your eye. It's only nuclear wasteland."
			if(ORANGEJUICE)
				icon_state = "glass_orange"
				item_state = "glass_orange"
				name = "glass of orange juice"
				desc = "Vitamins! Yay!"
			if(TOMATOJUICE)
				icon_state = "glass_red"
				item_state = "glass_red"
				name = "glass of tomato juice"
				desc = "Are you sure this is tomato juice?"
			if(BLOOD)
				icon_state = "glass_red"
				item_state = "glass_red"
				name = "glass of tomato juice"
				desc = "Are you sure this is tomato juice?"
			if(LIMEJUICE)
				icon_state = "glass_green"
				item_state = "glass_green"
				name = "glass of lime juice"
				desc = "A glass of sweet-sour lime juice."
			if(WHISKEY)
				icon_state = "whiskeyglass"
				item_state = "whiskeyglass"
				name = "glass of whiskey"
				desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
			if(GIN)
				icon_state = "ginvodkaglass"
				item_state = "ginvodkaglass"
				name = "glass of gin"
				desc = "A crystal clear glass of Griffeater gin."
			if(VODKA)
				icon_state = "ginvodkaglass"
				item_state = "ginvodkaglass"
				name = "glass of vodka"
				desc = "The glass contain wodka. Xynta."
			if(SAKE)
				icon_state = "sakeglass"
				name = "glass of sake"
				desc = "A glass of sake."
			if(GOLDSCHLAGER)
				icon_state = "ginvodkaglass"
				name = "glass of Goldschlager"
				desc = "A schnapps with tiny flakes of gold floating in it."
			if(WINE)
				icon_state = "wineglass"
				name = "glass of red wine"
				desc = "A drink enjoyed by intellectuals and middle-aged female alcoholics alike."
			if(WWINE)
				icon_state = "wwineglass"
				name = "glass of white wine"
				desc = "A drink enjoyed by intellectuals and middle-aged female alcoholics alike."
			if(BWINE)
				icon_state = "bwineglass"
				name = "glass of berry wine"
				desc = "A particular favorite of doctors."
			if(PLUMPHWINE)
				icon_state = "plumphwineglass"
				name = "glass of plump helmet wine"
				desc = "An absolute staple to get through a day's work."
			if(COGNAC)
				icon_state = "cognacglass"
				name = "glass of cognac"
				desc = "You feel aristocratic just holding this."
			if (KAHLUA)
				icon_state = "kahluaglass"
				name = "glass of coffee liqueur"
				desc = "DAMN, THIS STUFF LOOKS ROBUST."
			if(VERMOUTH)
				icon_state = "vermouthglass"
				name = "glass of vermouth"
				desc = "You wonder why you're even drinking this straight."
			if(TEQUILA)
				icon_state = "tequilaglass"
				name = "glass of tequila"
				desc = "Now all that's missing is the weird colored shades!"
			if(PATRON)
				icon_state = "patronglass"
				name = "glass of Patron"
				desc = "Drinking Patron in the bar, with all the subpar ladies."
			if(RUM)
				icon_state = "rumglass"
				name = "glass of rum"
				desc = "Now you want to pray for a pirate suit, don't you?"
			if(GINTONIC)
				icon_state = "gintonicglass"
				name = "gin and tonic"
				desc = "A mild but still great cocktail. Drink up, like a true Englishman."
			if(WHISKEYCOLA)
				icon_state = "whiskeycolaglass"
				name = "whiskey cola"
				desc = "An innocent-looking mixture of cola and whiskey. Delicious."
			if(WHITERUSSIAN)
				icon_state = "whiterussianglass"
				name = "\improper White Russian"
				desc = "A very nice looking drink. But that's just, like, your opinion, man."
			if(SCREWDRIVERCOCKTAIL)
				icon_state = "screwdriverglass"
				name = "\improper Screwdriver"
				desc = "A simple, yet superb mixture of vodka and orange juice. Just the thing for the tired engineer."
			if(BLOODYMARY)
				icon_state = "bloodymaryglass"
				name = "\improper Bloody Mary"
				desc = "Tomato juice, mixed with vodka and a lil' bit of lime. Tastes like liquid murder."
			if(MARTINI)
				icon_state = "martiniglass"
				name = "classic martini"
				desc = "Shaken, not stirred."
			if(VODKAMARTINI)
				icon_state = "martiniglass"
				name = "vodka martini"
				desc = "A bastardisation of the classic martini. Still great."
			if(SAKEMARTINI)
				icon_state = "martiniglass"
				name = "sake martini"
				desc = "An oriental spin on the martini, mixed with sake instead of vermouth."
			if(GARGLEBLASTER)
				icon_state = "gargleblasterglass"
				name = "\improper Pan-Galactic Gargle Blaster"
				desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
			if(BRAVEBULL)
				icon_state = "bravebullglass"
				name = "\improper Brave Bull"
				desc = "Tequila and coffee liqueur. Kicks like a bull."
			if(TEQUILASUNRISE)
				icon_state = "tequilasunriseglass"
				name = "\improper Tequila Sunrise"
				desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
			if(TOXINSSPECIAL)
				icon_state = "toxinsspecialglass"
				name = "\improper Toxins Special"
				desc = "Whoah, this thing is on FIRE!"
			if(BEEPSKYSMASH)
				icon_state = "beepskysmashglass"
				item_state = "beepskysmashglass"
				name = "\improper Beepsky Smash"
				desc = "Heavy, hot and strong. Best enjoyed with your hands behind your back."
			if(DOCTORSDELIGHT)
				icon_state = "doctorsdelightglass"
				name = "\improper Doctor's Delight"
				desc = "A rejuvenating mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
			if(MANLYDORF)
				icon_state = "manlydorfglass"
				item_state = "manlydorfglass"
				name = "The Manly Dorf"
				desc = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."
			if(IRISHCREAM)
				icon_state = "irishcreamglass"
				name = "irish cream"
				desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
			if(CUBALIBRE)
				icon_state = "cubalibreglass"
				name = "\improper Cuba Libre"
				desc = "A classic mix of rum and cola."
			if(B52)
				icon_state = "b52glass"
				name = "\improper B-52"
				desc = "Kahlua, irish cream, and cognac. You will get bombed."
				light_color = "#000080"
				if(!lit)
					flammable = 1
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
				desc = "Somebody set us up the bomb!"
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
				icon_state = "icetea"
				item_state = "icetea"
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
					origin_tech = "materials=7;engineering=3;plasmatech=2;powerstorage=4;bluespace=6;combat=3;magnets=6;programming=3"
			if(METABUDDY)
				icon_state = "metabuddy"
				name = "\improper Metabuddy"
				desc = "The glass is etched with the name of a very deserving spaceman. There's a special note etched in the bottom..."
			if(SPIDERS)
				icon_state = "spiders"
				name = "\improper This glass is full of spiders"
				desc = "Seriously, dude, don't touch it."
			if(WEED_EATER)
				icon_state = "weed_eater"
				name = "\improper Weed Eater"
				desc = "The vegetarian equivalant of a snake eater."
			if(RAGSTORICHES)
				icon_state = "ragstoriches"
				name = "\improper Rags to Riches"
				desc = "The Spaceman Dream, incarnated as a cocktail."
			if(WAIFU)
				icon_state = "waifu"
				name = "\improper Waifu"
				desc = "Don't drink more than one waifu if you value your laifu."
			if(BEEPSKY_CLASSIC)
				icon_state = "beepsky_classic"
				name = "\improper Beepsky Classic"
				desc = "Some believe that the more modern Beepsky Smash was introduced to make this drink more popular."
			if(ELECTRIC_SHEEP)
				icon_state = "electric_sheep"
				name = "\improper Electric Sheep"
				desc = "Silicons dream of this."
			if(SMOKYROOM)
				icon_state = "smokyroom"
				name = "\improper Smoky Room"
				desc = "It was the kind of cool, black night that clung to you like something real... a black, tangible fabric of smoke, deceit, and murder. I had finished working my way through the fat cigars for the day - or at least told myself that to feel the sense of accomplishment for another night wasted on little more than chasing cheating dames and abusive husbands. It was enough to drive a man to drink... and it did. I sauntered into the cantina and wordlessly nodded to the barman. He knew my poison. I was a regular, after all. By the time the night was over, there would be another empty bottle and a case no closer to being cracked. Then I saw her, like a mirage across a desert, or a striken starlet on stage across a smoky room."
			if(BAD_TOUCH)
				icon_state = "bad_touch"
				name = "\improper Bad Touch"
				desc = "On the scale of bad touches, somewhere between 'fondled by clown' and 'brushed by supermatter shard'."
			if(SUICIDE)
				icon_state = "suicide"
				name = "\improper Suicide"
				desc = "It's only tolerable because of the added alcohol."

			else
				icon_state ="glass_colour"
				item_state ="glass_colour"
				get_reagent_name(src)
				var/image/filling = image('icons/obj/reagentfillings.dmi', src, "glass")
				filling.icon += mix_color_from_reagents(reagents.reagent_list)
				filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
				overlays += filling

		if(reagents.has_reagent(BLACKCOLOR))
			icon_state ="blackglass"
			name = "international drink of mystery"
			desc = "The identity of this drink has been concealed for its protection."
			viewcontents = 0
	else
		icon_state = "glass_empty"
		item_state = "glass_empty"
		name = "drinking glass"
		desc = "Your standard drinking glass."

	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

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
		switch(reagents.get_master_reagent_id())
			if(TEA)
				icon_state = "tea"
				name = "tea"
				desc = "A warm mug of tea."
			if(GREENTEA)
				icon_state = "greentea"
				name = "green tea"
				desc = "Green Tea served in a traditional Japanese tea cup, just like in your Chinese cartoons!"
			if(REDTEA)
				icon_state = "redtea"
				name = "red tea"
				desc = "Red Tea served in a traditional Chinese tea cup, just like in your Malaysian movies!"
			if(ACIDTEA)
				icon_state = "acidtea"
				name = "\improper Earl's Grey tea"
				desc = "A sizzling mug of tea made just for Greys."
			if(YINYANG)
				icon_state = "yinyang"
				name = "zen tea"
				desc = "Enjoy inner peace and ignore the watered down taste"
			if(DANTEA)
				icon_state = "dantea"
				name = "\improper Discount Dan's Green Flavor Tea"
				desc = "Tea probably shouldn't be sizzling like that..."
			if(SINGULARITEA)
				icon_state = "singularitea"
				name = "\improper Singularitea"
				desc = "Brewed under intense radiation to be extra flavorful!"
			if(MINT)
				icon_state = "mint"
				name = "\improper Groans Tea: Minty Delight Flavor"
				desc = "Groans knows mint might not be the kind of flavor our fans expect from us, but we've made sure to give it that patented Groans zing."
			if(CHAMOMILE)
				icon_state = "chamomile"
				name = "\improper Groans Tea: Chamomile Flavor"
				desc = "Groans presents the perfect cure for insomnia: Chamomile!"
			if(EXCHAMOMILE)
				icon_state = "exchamomile"
				name = "\improper Groans Banned Tea: EXTREME Chamomile Flavor"
				desc = "Banned literally everywhere."
			if(FANCYDAN)
				icon_state = "fancydan"
				name = "\improper Groans Banned Tea: Fancy Dan Flavor"
				desc = "Banned literally everywhere."
			if(GYRO)
				icon_state = "gyro"
				name = "\improper Gyro"
				desc = "Nyo ho ho~"
			if(CHIFIR)
				icon_state = "chifir"
				name = "chifir"
				desc = "A Russian kind of tea. Not for those with weak stomachs."
			if(PLASMATEA)
				icon_state = "plasmatea"
				name = "Plasma Pekoe"
				desc = "You can practically taste the science. Or maybe that's just the horrible plasma burns."
			if(COFFEE)
				icon_state = "coffee"
				name = "coffee"
				desc = "A warm mug of coffee."
			if(CAFE_LATTE)
				icon_state = "latte"
				name = "cafe latte"
				desc = "A true classic: steamed milk, some espresso, and foamed milk to top it all off."
			if(SOY_LATTE)
				icon_state = "soylatte"
				name = "soy latte"
				desc = "The hipster version of the classic cafe latte."
			if(ESPRESSO)
				icon_state = "espresso"
				name = "espresso"
				desc = "A thick blend of coffee made by forcing near-boiling pressurized water through finely ground coffee beans."
			if(CAPPUCCINO)
				icon_state = "cappuccino"
				name = "cappuccino"
				desc = "The stronger big brother of the cafe latte, cappuccino contains more espresso in proportion to milk."
			if(DOPPIO)
				icon_state = "doppio"
				name = "\improper Doppio"
				desc = "Ring ring ring ring."
			if(TONIO)
				icon_state = "tonio"
				name = "\improper Tonio"
				desc = "Delicious, and may help you get out of a Jam."
			if(PASSIONE)
				icon_state = "passione"
				name = "\improper Passione"
				desc = "Sometimes referred to as a 'Vento Aureo'."
			if(SECCOFFEE)
				icon_state = "seccoffee"
				name = "\improper Wake-Up Call"
				desc = "The perfect start for any Sec officer's day."
			if(MEDCOFFEE)
				icon_state = "medcoffee"
				name = "\improper Lifeline"
				desc = "Some days, the only thing that keeps you going is cryo and caffeine."
			if(DETCOFFEE)
				icon_state = "detcoffee"
				name = "\improper Joe"
				desc = "The lights, the smoke, the grime... the station itself felt alive that day when I stepped into my office, mug in hand. It had been one of those damn days. Some nurse got smoked in the tunnels, and it came down to me to catch the son of a bitch that did it. The dark, stale air of the tunnels sucks the soul out of a man -- sometimes literally -- and I was no closer to finding the killer than when the nurse was still alive. I hobbled over to my desk, reached for the flask in my pocket, and topped off my coffee with its contents. I had barely gotten settled in my chair when an officer burst through the door. Another body in the tunnels, an assistant this time. I grumbled and downed what was left of my joe. This stuff used to taste great when I was a rookie, but now it was like boiled dirt. I guess that's how the station changes you. I set the mug back down on my desk and lit my last cigar. My fingers instinctively sought out the comforting grip of the .44 snub in my coat as I stepped out into the bleak halls of the station. The case was not cold yet."
			if(ETANK)
				icon_state = "etank"
				name = "\improper Recharger"
				desc = "Helps you get back on your feet after a long day of robot maintenance. Can also be used as a substitute for motor oil."
			if(GREYTEA)
				icon_state = "greytea"
				name = "\improper Tide"
				desc = "This probably shouldn't be considered tea..."
			if(TOMATOJUICE)
				make_reagent_overlay()
				name = "mug of tomato juice"
				desc = "Are you sure this is tomato juice?"
			if(BLOOD)
				make_reagent_overlay()
				name = "mug of tomato juice"
				desc = "Are you sure this is tomato juice?"
			if(HOT_COCO)
				make_reagent_overlay()
				name = "hot chocolate"
				desc = "A delicious warm brew of milk and chocolate."						
			else
				make_reagent_overlay()
				get_reagent_name(src, TRUE)
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