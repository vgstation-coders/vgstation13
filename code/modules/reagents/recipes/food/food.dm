
/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	results = list(null = 1)

/datum/chemical_reaction/tofu/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
	results = list(null = 1)

/datum/chemical_reaction/chocolate_bar/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
	results = list(null = 1)

/datum/chemical_reaction/chocolate_bar2/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	required_reagents = list("water" = 5, "coco" = 1)
	results = list("hot_coco" = 5)
/datum/chemical_reaction/coffee
	name = "Coffee"
	id = "coffee"
	required_reagents = list("coffeepowder" = 1, "water" = 5)
	results = list("coffee" = 5)
/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	required_reagents = list("teapowder" = 1, "water" = 5)
	results = list("tea" = 5)
/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	required_reagents = list("soymilk" = 4, "sacid" = 1)
	results = list("soysauce" = 5)
/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	results = list(null = 1)

/datum/chemical_reaction/cheesewheel/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)
	return

/datum/chemical_reaction/Cream
	name = "Cream"
	id = "cream"
	required_reagents = list("milk" = 10,"sacid" = 1)
	results = list("cream" = 5)
/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	required_reagents = list("blood" = 5, "clonexadone" = 1)
	results = list(null = 1)

/datum/chemical_reaction/syntiflesh/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
	return

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	results = list("hot_ramen" = 3)
/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	results = list("hell_ramen" = 6)
