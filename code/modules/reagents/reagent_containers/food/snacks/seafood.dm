// fishtank stuff

/obj/item/weapon/reagent_containers/food/snacks/salmonmeat
	name = "raw salmon"
	desc = "A fillet of raw salmon."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak
	name = "Salmon steak"
	desc = "A piece of freshly-grilled salmon meat."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "salmonsteak"
	filling_color = "#7A3D11"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 7)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/catfishmeat
	name = "raw catfish"
	desc = "A fillet of raw catfish."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/shrimp
	name = "shrimp"
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_raw"
	filling_color = "#FF1C1C"
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/shrimp/New()
	..()
	desc = pick("Anyway, like I was sayin', shrimp is the fruit of the sea.", "You can barbecue it, boil it, broil it, bake it, saute it.")

/obj/item/weapon/reagent_containers/food/snacks/glofishmeat
	name = "raw glofish"
	desc = "A fillet of raw glofish. The bioluminescence glands have been removed."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/goldfishmeat
	name = "raw goldfish"
	desc = "A fillet of raw goldfish, the golden carp."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fried_shrimp
	name = "fried shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_fried"
	food_flags = FOOD_MEAT
	base_crumb_chance = 2
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp
	name = "boiled shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_cooked"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

////////	SUSHI	////////

/obj/item/weapon/reagent_containers/food/snacks/sushi
	name = "generic sushi"
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ebi
	name = "Ebi Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ebi
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ebi
	name = "Ebi Sushi"
	desc = "A simple sushi consisting of cooked shrimp and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Ebi"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ikura
	name = "Ikura Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ikura
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ikura
	name = "Ikura Sushi"
	desc = "A simple sushi consisting of salmon roe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Ikura"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Sake
	name = "Sake Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Sake
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Sake
	name = "Sake Sushi"
	desc = "A simple sushi consisting of raw salmon and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Sake"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_SmokedSalmon
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	desc = "A simple sushi consisting of cooked salmon and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tamago
	name = "Tamago Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tamago
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tamago
	name = "Tamago Sushi"
	desc = "A simple sushi consisting of egg and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Tamago"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Inari
	name = "Inari Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Inari
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Inari
	name = "Inari Sushi"
	desc = "A piece of fried tofu stuffed with rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Inari"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Masago
	name = "Masago Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Masago
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Masago  																																			/*Every night I watch the skies from inside my bunker. They'll come back. If I watch they'll come. I can hear their voices from the sky. Calling out my name. There's the ridge. The guns in the jungle. Screaming. Smoke. The blood. All over my hands. */
	name = "Masago Sushi"
	desc = "A simple sushi consisting of goldfish roe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Masago"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tobiko
	name = "Tobiko Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tobiko
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tobiko
	name = "Tobiko Sushi"
	desc = "A simple sushi consisting of shark roe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Masago"
	food_flags = FOOD_MEAT

// this is an oddball because you make it using an existing sushi piece
/obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	desc = "A sushi consisting of shark roe and an egg."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_TobikoEgg"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tai
	name = "Tai Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tai
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tai
	name = "Tai Sushi"
	desc = "A simple sushi consisting of catfish and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Tai"
	bitesize = 3
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Unagi
	name = "Unagi Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Unagi
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Unagi // i have seen the face of god and it was weeping
	name = "Unagi Sushi"
	desc = "A simple sushi consisting of eel and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Hokki"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_avocado
	name = "Avocado Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_avocado
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_avocado
	name = "Avocado Sushi"
	desc = "A simple sushi consisting of avocado and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_avocado"

////	END SUSHI	////

/obj/item/weapon/reagent_containers/food/snacks/friedshrimp
	name = "fried shrimp"
	desc = "For such a little dish, it's surprisingly high calorie."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_fried"
	bitesize = 3
	food_flags = FOOD_MEAT
	reagents_to_add = list(CORNOIL = 3)

/obj/item/weapon/reagent_containers/food/snacks/soyscampi
	name = "soy scampi"
	desc = "A simple shrimp dish presented bathed in soy sauce."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "soyscampi"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1, SOYSAUCE = 2)

/obj/item/weapon/reagent_containers/food/snacks/shrimpcocktail
	name = "shrimp cocktail"
	desc = "An hors d'oeuvre which has traditionally swung like a pendulum between the height of fashion and ironically passe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimpcocktail"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/shrimpcocktail/New()
	if(prob(50))
		desc += " This one is ironic."
		reagents_to_add += list(HONKSERUM = 1)
	else
		desc += " This one is high fashion."
		reagents += list(MINTTOXIN = 1)
	..()

/obj/item/weapon/reagent_containers/food/snacks/friedcatfish
	name = "fried catfish"
	desc = "A traditional catfish fry. It's positively coated in oils."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "friedcatfish"
	bitesize = 3
	food_flags = FOOD_MEAT
	reagents_to_add = list(CORNOIL = 3)

/obj/item/weapon/reagent_containers/food/snacks/catfishgumbo
	name = "catfish gumbo"
	desc = "A traditional, thick cajun broth. Made with bottom-feeders for bottom-feeders."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "catfishgumbo"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/catfishcourtbouillon
	name = "catfish courtbouillon"
	desc = "A lightly breaded catfish fillet poached in a spicy hot-sauce short broth."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "catfishcourtbouillon"
	bitesize = 3
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6, CAPSAICIN = 3)

/obj/item/weapon/reagent_containers/food/snacks/smokedsalmon
	name = "smoked salmon"
	desc = "Perhaps the best known method of preparing salmon, smoking has been used to preserve fish for most of recorded history. The subtleties of avoiding overpowering the fatty, rich flavor of the salmon with the smoke make this a difficult dish to master."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "smokedsalmon"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/planksalmon
	name = "plank-grilled salmon"
	desc = "A simple dish that grills the flavor of wood into the meat, leaving you with a charred but workable plate in the process."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "planksalmon"
	bitesize = 3
	food_flags = FOOD_MEAT
	trash = /obj/item/stack/sheet/wood
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/citrussalmon
	name = "citrus-baked salmon"
	desc = "The piquant, almost sour flavor of the citrus fruit is baked into the fish under dry heat, to give it powerful attaque to balance its rich aftertaste."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "citrussalmon"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/salmonavocado
	name = "salmon avocado salad"
	desc = "The creamy, buttery taste of the avocado brings unity to the nutty, meaty taste of the mushrooms and the fatty, rich taste of the salmon."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "salmonavocado"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/rumshark
	name = "spiced rum shark supreme"
	desc = "When you really need something to get this party started. A savory dish enriched by alcohol."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "rumshark"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, RUM = 15)

/obj/item/weapon/reagent_containers/food/snacks/akutaq
	name = "glofish akutaq"
	desc = "This eskimo dish literally means 'something mixed'. The fat of glowish is rendered down and mixed with milk and glowberries to make a surprisingly tasty dessert dish."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "akutaq"
	bitesize = 3
	food_flags = FOOD_MEAT | FOOD_SWEET | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1, SUGAR = 6)

/obj/item/weapon/reagent_containers/food/snacks/carpcurry
	name = "golden carp curry"
	desc = "A simple traditional Space Japan curry with tangy golden carp meat."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "carpcurry"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/carpconsomme
	name = "golden carp consomme"
	desc = "A clear soup made from a concentrated broth of fish and egg whites. It's light on calories and makes you feel much more cultured."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "carpconsomme"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, METHYLIN = 5)

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail
	name = "Raw Lobster Tail"
	desc = "The tail of a lobster, raw and uncooked."
	icon = 'icons/obj/food.dmi'
	icon_state = "raw_lobster_tail"
	bitesize = 1 //your eating a raw lobster tail, shell still attatched, you disgusting animal
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat
	name = "Raw Lobster Meat"
	desc = "The delicious meat of a lobster. An impossible amount of suffering was inflicted to get this."
	icon = 'icons/obj/food.dmi'
	icon_state = "raw_lobster_meat"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_deluxe
	name = "Steamed Lobster"
	desc = "A steamed lobster, served with a side of melted butter and a slice of lemon. You can still feel its hatred"
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_steamed_deluxe"
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/plate
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, LEMONJUICE = 1, LIQUIDBUTTER = 3)
	bitesize = 2 //lobster takes a long time to eat

/obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_simple  // this one has no fancy butter or lemon
	name = "Steamed Lobster"
	desc = "A steamed lobster, served with no sides. Eat up, you barbarian."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_steamed_simple"
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/plate
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2 //lobster takes a long time to eat


/obj/item/weapon/reagent_containers/food/snacks/lobster_roll
	name = "Lobster Roll"
	desc = "A mishmash of mayo and lobster meat shoved onto a roll to make a lobster hot dog."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_roll" //it dont need trash, its a hot dog, lobster edition
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 1, MAYO = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_roll/butter  // instead of mayo it uses butter
	desc = "A glob of lobster meat drenched in butter."
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/lobster_tail_baked
	name = "Baked Lobster Tail"
	desc = "A Lobster tail, drenched in butter and a bit of lemon, you monster."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_tail_baked"
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/plate
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_dumplings
	name = "Lobster Dumplings"
	desc = "A mass of claw meat wrapped in dough."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_dumplings"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_sushi
	name = "Lobster Dumplings"
	desc = "Lobster meat wrapped up with rice."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_sushi"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2
