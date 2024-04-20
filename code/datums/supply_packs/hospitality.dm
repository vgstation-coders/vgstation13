//////HOSPITALITY//////

/datum/supply_packs/food
	name = "Basic cooking supplies"
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/storage/fancy/egg_box)
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "basic cooking crate"
	group = "Hospitality"
	containsdesc = "The basics of any meal. Contains four bags of flour, two gallons of milk, and a dozen eggs."

/datum/supply_packs/randomised/fruit
	name = "Fresh fruit"
	num_contained = 16
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
					/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
					/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon,
					/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
					/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
					/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
					/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
					/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
					/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
					/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
					/obj/item/weapon/reagent_containers/food/snacks/grown/orange)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "fruit crate"
	containsdesc = "A large container filled with nothing but fruit! Comes with whatever is in season from the local Space Farm."
	group = "Hospitality"

/datum/supply_packs/exotic_garnishes //We don't use a randomised crate because we want some special reagents, and also to control chances
	name = "Exotic garnishes"
	contains = list(/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "exotic garnishes crate"
	access = list(access_kitchen)
	group = "Hospitality"
	containsdesc = "A variety of herbs and spices that can certainly add a kick to any meal. Roughly six different items in every pack."

/datum/supply_packs/randomised/premium_meats
	name = "Premium meats"
	num_contained = 8
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/meat/mimic,
					/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation,
					/obj/item/weapon/reagent_containers/food/snacks/meat/diona,
					/obj/item/weapon/reagent_containers/food/snacks/meat/nymphmeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/polyp,
					/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken,
					/obj/item/weapon/reagent_containers/food/snacks/meat/box/pig,
					/obj/item/weapon/reagent_containers/food/snacks/meat/blob)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "Premium meats crate"
	containsdesc = "A crate filled with the latest game hunted up by the local hunters."
	access = list(access_kitchen)
	group = "Hospitality"

/datum/supply_packs/randomised/budget_meats
	name = "Budget meats"
	num_contained = 8
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
					/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
					/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg,
					/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
					/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
					/obj/item/weapon/reagent_containers/food/snacks/meat/cricket/big,
					/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
					/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big
					)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "budget meats crate"
	containsdesc = "A crate filled with a variety of meat obtained from... somewhere."
	access = list(access_kitchen)
	group = "Hospitality"

/datum/supply_packs/party
	name = "Party equipment"
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/discount_shaker,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/lipstick/random,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/device/maracas,
					/obj/item/device/maracas,
					/obj/item/weapon/storage/box/balloons,
					/obj/item/weapon/storage/box/balloons,
					/obj/item/weapon/storage/box/balloons,
					/obj/item/weapon/storage/box/balloons/long,
					/obj/item/weapon/storage/box/balloons/long,
					/obj/item/weapon/storage/box/balloons/long)
	cost = 20
	containertype = /obj/structure/closet/crate/basic
	containername = "party equipment crate"
	group = "Hospitality"
	containsdesc = "An entire party in a box! Contains drinks, balloons, and other assorted party accessories."

/datum/supply_packs/randomised/pizza
	num_contained = 5
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/blingpizza)
	name = "Surprise pack of five pizzas"
	cost = 75
	containertype = /obj/structure/closet/crate/freezer
	containername = "pizza crate"
	containsicon = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	containsdesc = "Order a bunch of pizza from the local pizza joint. It's run by assistants, so expect your order to get mixed up. They deliver in sets of five."
	group = "Hospitality"

/datum/supply_packs/randomised/pizza/post_creation(var/atom/movable/container)
	if(!station_does_not_tip)
		return
	for(var/obj/item/pizzabox/box in container)
		var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza = box.pizza
		if(!pizza)
			continue
		pizza.make_poisonous()

/datum/supply_packs/cafe
	name = "Cafe equipment"
	contains = list(/obj/structure/closet/crate/flatpack/brewer,
	/obj/item/weapon/storage/box/mugs,
	/obj/item/weapon/storage/box/mugs,
	/obj/item/weapon/reagent_containers/glass/kettle/red)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "cafe equipment crate"
	group = "Hospitality"
	containsdesc = "A starter kit for running a cafe. Includes a hot drinks brewer, two boxes of mugs, and a kettle."

/datum/supply_packs/bar
	name = "Advanced bartending equipment"
	contains = list(/obj/structure/closet/crate/flatpack/soda_dispenser,
	/obj/structure/closet/crate/flatpack/booze_dispenser,
	/obj/item/weapon/storage/box/drinkingglasses,
	/obj/item/weapon/storage/box/drinkingglasses,
	/obj/item/weapon/reagent_containers/food/drinks/discount_shaker)
	cost = 40
	containertype = /obj/structure/largecrate
	containername = "bartending equipment crate"
	group = "Hospitality"
	containsdesc = "A basic kit for a fully functional bar. Includes a booze dispenser, soda dispenser, two boxes of glasses, and a surplus shaker."

/datum/supply_packs/bar/post_creation(var/atom/movable/container)
	var/obj/structure/closet/crate/flatpack/flatpack1 = locate(/obj/structure/closet/crate/flatpack/soda_dispenser/) in container
	var/obj/structure/closet/crate/flatpack/flatpack2 = locate(/obj/structure/closet/crate/flatpack/booze_dispenser/) in container
	flatpack1.add_stack(flatpack2)

/datum/supply_packs/festive
	name = "Festive supplies"
	contains = list(/obj/item/stack/package_wrap/gift,
					/obj/item/stack/package_wrap/gift,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/clothing/head/christmas/santahat/red,
					/obj/item/clothing/head/christmas/santahat/green,
					/obj/item/clothing/head/christmas/santahat/blue,
					/obj/item/clothing/suit/jumper/christmas/red,
					/obj/item/clothing/suit/jumper/christmas/green,
					/obj/item/clothing/suit/jumper/christmas/blue,
					/obj/item/clothing/under/onesie,
					/obj/item/clothing/under/onesie/blue,
					/obj/item/clothing/under/onesie/red,
					/obj/item/clothing/under/onesie/pink,
					/obj/item/clothing/under/onesie/white,
					/obj/item/clothing/under/onesie/grey,
					/obj/item/clothing/under/onesie/black,
					/obj/item/clothing/under/onesie/redgreen,
					/obj/item/clothing/under/onesie/bluenavy,
					/obj/item/clothing/mask/scarf/red,
					/obj/item/clothing/mask/scarf/blue,
					/obj/item/clothing/mask/scarf/green,
					/obj/item/clothing/under/wintercasualwear)
	cost = 30
	containertype = /obj/structure/closet/crate/basic
	containername = "festive supplies crate"
	group = "Hospitality"
	containsdesc = "The Christmas Spirit, all in one box. Contains a variety of wintery clothes, some crackers, and plenty of gift wrap."

/datum/supply_packs/randomised/instruments
	num_contained = 1 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/device/instrument/violin,
					/obj/item/device/instrument/guitar,
					/obj/item/device/instrument/glockenspiel,
					/obj/item/device/instrument/accordion,
					/obj/item/device/instrument/saxophone,
					/obj/item/device/instrument/trombone,
					/obj/item/device/instrument/recorder,
					/obj/item/device/instrument/harmonica,
					/obj/structure/piano/xylophone,
					/obj/structure/piano/random,
					/obj/item/device/instrument/bikehorn,
					/obj/item/device/instrument/drum)
	name = "Random instrument"
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "random instrument crate"
	containsdesc = "Due to strange space laws, the station can't just directly order a specific instrument..."

	group = "Hospitality"

/datum/supply_packs/bigband
	contains = list(/obj/item/device/instrument/violin,
					/obj/item/device/instrument/guitar,
					/obj/item/device/instrument/glockenspiel,
					/obj/item/device/instrument/accordion,
					/obj/item/device/instrument/saxophone,
					/obj/item/device/instrument/trombone,
					/obj/item/device/instrument/recorder,
					/obj/item/device/instrument/harmonica,
					/obj/structure/piano/xylophone,
					/obj/structure/piano/minimoog,
					/obj/structure/piano,
					/obj/item/device/instrument/bikehorn,
					/obj/item/device/instrument/drum)
	name = "Big band instrument collection"
	cost = 500
	containertype = /obj/structure/largecrate
	containername = "big band musical instruments crate"
	group = "Hospitality"
	containsdesc = "One way around the strange space law is to just order the whole band. Contains one of every instrument."
