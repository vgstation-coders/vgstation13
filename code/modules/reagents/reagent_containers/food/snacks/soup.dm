
/obj/item/weapon/reagent_containers/food/snacks/soup
	name = "Vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#FAA810"
	valid_utensils = UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 8, WATER = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/soup/meatball
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	food_flags = FOOD_MEAT | FOOD_LIQUID
	filling_color = "#F4BC77"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/soup/slime
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#B2B2B2"
	reagents_to_add = list(SLIMEJELLY = 5, WATER = 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomato
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	reagents_to_add = list(NUTRIMENT = 5, TOMATO_SOUP = 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomato/blood
	desc = "Smells like iron."
	food_flags = FOOD_LIQUID | FOOD_ANIMAL //blood
	filling_color = "#FF3300"
	reagents_to_add = list(NUTRIMENT = 2, BLOOD = 10, WATER = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	food_flags = FOOD_LIQUID | FOOD_SWEET
	random_filling_colors = list("#FF0000","#FFFF00","#00CCFF","#33CC00")
	reagents_to_add = list(NUTRIMENT = 4, BANANA = 5, WATER = 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/robostears
	name = "Roboticist's Tears"
	desc = "Absolutely hilarious."
	icon_state = "roboticiststears"
	random_filling_colors = list("#5A01EF", "#4B2A7F", "#826BA7", "#573D80")
	reagents_to_add = list(NUTRIMENT = 60, PHAZON = 1, WATER = 5) //You're using phazon here, that's the good shit. //water turned into nutriment via phazon magic fuckery

/obj/item/weapon/reagent_containers/food/snacks/soup/nettle
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	filling_color = "#C1E212"
	reagents_to_add = list(NUTRIMENT = 8, WATER = 5, TRICORDRAZINE = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/mystery
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	food_flags = FOOD_LIQUID | FOOD_ANIMAL | FOOD_LACTOSE
	filling_color = "#97479B"

/obj/item/weapon/reagent_containers/food/snacks/soup/mystery/set_reagents_to_add()
	var/result = rand(1,10)
	switch(result)
		if(1)
			reagents_to_add = list(NUTRIMENT = 6, CAPSAICIN = 3, TOMATOJUICE = 2)
		if(2)
			reagents_to_add = list(NUTRIMENT = 6, FROSTOIL = 3, TOMATOJUICE = 2)
		if(3)
			reagents_to_add = list(NUTRIMENT = 5, WATER = 5, TRICORDRAZINE = 5)
		if(4)
			reagents_to_add = list(NUTRIMENT = 5, WATER = 10)
		if(5)
			reagents_to_add = list(NUTRIMENT = 2, BANANA = 10)
		if(6)
			reagents_to_add = list(NUTRIMENT = 6, BLOOD = 10)
			food_flags |= FOOD_MEAT
		if(7)
			reagents_to_add = list(SLIMEJELLY = 10, WATER = 10)
		if(8)
			reagents_to_add = list(CARBON = 10, TOXIN = 10)
		if(9)
			reagents_to_add = list(NUTRIMENT = 5, TOMATOJUICE = 10)
		if(10)
			reagents_to_add = list(NUTRIMENT = 6, TOMATOJUICE = 5, IMIDAZOLINE = 5)
	if(result != 6)
		food_flags = initial(food_flags)

/obj/item/weapon/reagent_containers/food/snacks/soup/monkey
	name = "Monkey Soup"
	desc = "Uma delicia."
	icon_state = "monkeysoup"
	trash = /obj/item/trash/monkey_bowl
	filling_color = "#D7DE77"
	reagents_to_add = list(WATER = 5, NUTRIMENT = 8, VINEGAR = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/wish
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	filling_color = "#DEF7F5"
	reagents_to_add = list(WATER = 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/wish/New()
	if(prob(25))
		desc = "A wish come true!"
		reagents_to_add += list(NUTRIMENT = 8)
	..()

/obj/item/weapon/reagent_containers/food/snacks/soup/avocado
	name = "Avocado Soup"
	desc = "May be served either hot or cold."
	icon_state = "avocadosoup"
	filling_color = "#CBD15B"
	reagents_to_add = list(NUTRIMENT = 8, LIMEJUICE = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/silicate
	name = "silicate soup"
	desc = "It's like eating sand in liquid form."
	icon_state = "silicatesoup"
	filling_color = "#C5C5FF"
	reagents_to_add = list(WATER = 10, NUTRIMENT = 6, SILICATE = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/chili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	filling_color = "#E23D12"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6, CAPSAICIN = 3, TOMATOJUICE = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/chili/cold
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#4375E8"
	reagents_to_add = list(NUTRIMENT = 6, FROSTOIL = 3, TOMATOJUICE = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/plasmastew
	name = "Plasma Stew"
	desc = "Plasma free and flavour full."
	icon_state = "plasmastew"
	filling_color = "#CE37BA"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 12, TOMATOJUICE = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/milo
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/soup/mushroom
	name = "chanterelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/soup/beet
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	filling_color = "#E00000"
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soup/beet/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")

/obj/item/weapon/reagent_containers/food/snacks/soup/primordial
	name = "primordial soup"
	desc = "From a soup just like this, a sentient race could one day emerge. Better eat it to be safe."
	icon_state = "primordialsoup"
	bitesize = 2
	food_flags = FOOD_LIQUID | FOOD_ANIMAL //blood is animal sourced
	filling_color = "#720D00"
	reagents_to_add = list(NUTRIMENT = 8)
