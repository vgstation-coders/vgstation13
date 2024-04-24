
//////////////////CURRY//////////////////

/obj/item/weapon/reagent_containers/food/snacks/curry
	name = "Chicken Balti"
	desc = "Finest Indian Cuisine, at least you think it is chicken."
	icon_state = "curry_balti"
	item_state = "curry_balti"
	food_flags = FOOD_MEAT
	valid_utensils = UTENSILE_SPOON
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 20)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo
	name = "Chicken Vindaloo"
	desc = "Me and me Mum and me Dad and me Nan are off to Waterloo, me and me Mum and me Dad and me Nan and a bucket of Vindaloo!"
	icon_state = "curry_vindaloo"
	item_state = "curry_vindaloo"
	reagents_to_add = list(NUTRIMENT = 20, CAPSAICIN = 10)

/obj/item/weapon/reagent_containers/food/snacks/curry/crab
	name = "Crab Curry"
	desc = "An Indian dish with a snappy twist!"
	icon_state = "curry_crab"
	item_state = "curry_crab"

/obj/item/weapon/reagent_containers/food/snacks/curry/lemon
	name = "Lemon Curry"
	desc = "This actually exists?"
	icon_state = "curry_lemon"
	item_state = "curry_lemon"

/obj/item/weapon/reagent_containers/food/snacks/curry/xeno
	name = "Xeno Balti"
	desc = "Waste not want not."
	icon_state = "curry_xeno"
	item_state = "curry_xeno"

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi
	name = "Giga Puddi"
	desc = "A large crème caramel."
	icon_state = "gigapuddi"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_SWEET
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	filling_color = "#FFEC4D"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy
	desc = "A large crème caramel, made with extra love."
	icon_state = "happypuddi"

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger
	desc = "A large crème caramel, made with extra hate."
	icon_state = "angerpuddi"

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/riceball
	name = "Rice Ball"
	desc = "In mining culture, this is also known as a donut."
	icon_state = "riceball"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/eggplantsushi
	name = "Spicy Eggplant Sushi Rolls"
	desc = "Eggplant rolls are an example of Asian Fusion as eggplants were introduced from mainland Asia to Japan. This dish is Earth Fusion, originating after the introduction of the chili from the Americas to Japan. Fusion HA!"
	icon_state = "eggplantsushi"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4, CAPSAICIN = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	reagents_to_add = list(NUTRIMENT = 12, STOXIN = 3)
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 5)
	bitesize = 3
