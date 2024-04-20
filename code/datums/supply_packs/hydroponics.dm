//////HYDROPONICS//////

/datum/supply_packs/monkey
	name = "Monkey cubes"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "monkey crate"
	group = "Hydroponics"
	containsicon = /mob/living/carbon/monkey
	containsdesc = "Several whole monkeys, in a classic cube form. A little water will restore them."

/datum/supply_packs/farwa
	name = "Farwa cubes"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/farwacubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "farwa crate"
	group = "Hydroponics"
	containsicon = /mob/living/carbon/monkey/tajara
	containsdesc = "A few farwas in cubes. Just add water!"

/datum/supply_packs/skrell
	name = "Neaera cubes"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/neaeracubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "neaera crate"
	group = "Hydroponics"
	containsicon = /mob/living/carbon/monkey/skrell
	containsdesc = "Cubes? That contain neaera? Sure."

/datum/supply_packs/stok
	name = "Stok cubes"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/stokcubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "stok crate"
	group = "Hydroponics"
	containsicon = /mob/living/carbon/monkey/unathi
	containsdesc = "What the fuck is a stok? Order and find out!"

/datum/supply_packs/isopod
	name = "Isopod cubes"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/isopodcubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "isopod crate"
	group = "Hydroponics"
	containsicon = /mob/living/carbon/monkey/roach
	containsdesc = "A cubed up weird bug thing."

/datum/supply_packs/vox
	name = "Genetically modified chicken eggs"
	contains = list(/obj/item/weapon/storage/fancy/egg_box/vox)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "green egg crate"
	group = "Hydroponics"
	containsdesc = "Some strange green eggs that they found in the dorms at Central Command. What... Might as well sell them."

/* Defined below
/datum/supply_packs/lisa
	name = "Corgi Crate"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/lisa
	containername = "Corgi Crate"
	group = "Hydroponics" */

/datum/supply_packs/hydroponics // -- Skie
	name = "Hydroponics supplies"
	contains = list(/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/hatchet,
					/obj/item/weapon/minihoe,
					/obj/item/weapon/minihoe,
					/obj/item/device/analyzer/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron, // Updated with new things
					/obj/item/weapon/storage/lockbox/diskettebox/open/botanydisk) //Updated with flora disks
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"
	access = list(access_hydroponics)
	group = "Hydroponics"
	containsdesc = "A basic set of gardening supplies. Includes a plant analyzer, apron, gloves, tools, and chemicals. Trays sold separately."

/datum/supply_packs/aquaculture // fish n shit
	name = "Aquaculture supply"
	contains = list(/obj/item/weapon/fishtools/fish_egg_scoop,
					/obj/item/weapon/fishtools/fish_net,
					/obj/item/weapon/fishtools/fish_food,
					/obj/item/weapon/fishtools/fish_tank_brush,
					/obj/item/fish_eggs/catfish,
					/obj/item/fish_eggs/catfish,
					/obj/item/fish_eggs/salmon,
					/obj/item/fish_eggs/salmon,
					/obj/item/fish_eggs/shrimp,
					/obj/item/fish_eggs/shrimp,
					/obj/item/fish_eggs/lobster,
					/obj/item/fish_eggs/lobster,
					/obj/item/weapon/circuitboard/fishtank,
					/obj/item/weapon/circuitboard/fishtank,
					/obj/item/weapon/circuitboard/fishtank,
					)
	cost = 30
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "aquaculture crate"
	group = "Hydroponics"
	containsdesc = "A starter set for raising your own fresh fish! Includes all the tools necessary plus three tank electronics, perfect for raising catfish, salmon, shrimp, and lobster."

/datum/supply_packs/exoticfish // weird fish eggs n shit
	name = "Exotic fish"
	contains = list(/obj/item/fish_eggs/goldfish,
					/obj/item/fish_eggs/goldfish,
					/obj/item/fish_eggs/clownfish,
					/obj/item/fish_eggs/clownfish,
					/obj/item/fish_eggs/feederfish,
					/obj/item/fish_eggs/feederfish,
					/obj/item/fish_eggs/electric_eel,
					/obj/item/fish_eggs/electric_eel,
					/obj/item/fish_eggs/shark,
					/obj/item/fish_eggs/shark,
					/obj/item/fish_eggs/glofish,
					/obj/item/fish_eggs/glofish,
					/obj/item/weapon/circuitboard/fishwall,
					/obj/item/weapon/circuitboard/fishwall,
					/obj/item/weapon/circuitboard/conduction_plate
					)
	cost = 40
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "exotic fish crate"
	group = "Hydroponics"
	containsdesc = "An advanced fish raising expansion set. Includes 6 varieties of rare fish to raise! Also contains two large tank electronics and a conduction plate. Basic fish raising tools sold separately."

//farm animals - useless and annoying, but potentially a good source of food
/datum/supply_packs/cow
	name = "Cow"
	cost = 30
	containertype = /obj/structure/largecrate/cow
	containername = "cow crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/cow
	containsdesc = "Contains the whole cow."

/datum/supply_packs/goat
	name = "Goat"
	cost = 25
	containertype = /obj/structure/largecrate/goat
	containername = "goat crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/hostile/retaliate/goat
	containsdesc = "When weeds have your station, call in the goat."

/datum/supply_packs/polyp
	name = "Polyp"
	cost = 75
	containertype = /obj/structure/largecrate/polyp
	containername = "polyp crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/hostile/retaliate/polyp
	containsdesc = "Blub, blub..."

/datum/supply_packs/chicken
	name = "Chicken"
	cost = 20
	containertype = /obj/structure/largecrate/chick
	containername = "chicken crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/chick
	containsdesc = "A crate filled to the brim with chickens. We fit in as many as we could."

/datum/supply_packs/lisa
	name = "Corgi"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/lisa
	containername = "corgi Crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/corgi/Lisa
	containsdesc = "Contains one common breed corgi."

/datum/supply_packs/cat
	name = "Cat"
	contains = list()
	cost = 30
	containertype = /obj/structure/largecrate/cat
	containername = "cat crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/cat
	containsdesc = "Cat."

/datum/supply_packs/snails
	name = "Snails"
	contains = list()
	cost = 25
	containertype = /obj/structure/largecrate/snails
	containername = "snail crate"
	group = "Hydroponics"
	containsicon = /mob/living/simple_animal/snail
	containsdesc = "A box with a bunch of snails in it. Perfect for treadmill engines."

/datum/supply_packs/weedcontrol
	name = "Weed control equipment"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = list(access_hydroponics)
	group = "Hydroponics"
	containsdesc = "Emergency tools for removing fast-growing weeds. Contains a scythe, gas mask, and two anti-weed gas grenades."

/datum/supply_packs/insectcontrol
	name = "Insect control equipment"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/insecticide,
					/obj/item/weapon/reagent_containers/glass/bottle/insecticide,
					/obj/item/weapon/reagent_containers/glass/bottle/insecticide,
					/obj/item/weapon/reagent_containers/spray/bugzapper,
					/obj/item/weapon/reagent_containers/spray/bugzapper)
	cost = 40
	containertype = /obj/structure/largecrate/hissing
	containername = "hissing crate"
	access = list(access_hydroponics)
	group = "Hydroponics"
	containsdesc = "Order this before the inspectors get here. Includes a bunch of sprays and poisons lethal to insects."

/datum/supply_packs/exoticseeds
	name = "Exotic seeds"
	contains = list(/obj/item/seeds/dionanode,
					/obj/item/seeds/dionanode,
					/obj/item/seeds/libertymycelium,
					/obj/item/seeds/reishimycelium,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/kudzuseed,
					/obj/item/seeds/nofruitseed)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "exotic seeds crate"
	one_access = list(access_hydroponics, access_science)
	group = "Hydroponics"
	containsdesc = "Direct from Central Command's hydroponics research facility, this crate contains samples of several exotic plants. Includes six commonly researched samples and six experimental samples."

/datum/supply_packs/bee_keeper
	name = "Beekeeping kit"
	contains = list(
		/obj/item/weapon/reagent_containers/food/snacks/beezeez,
		/obj/item/weapon/reagent_containers/food/snacks/beezeez,
		/obj/item/weapon/bee_net,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/apiary,
		/obj/item/queen_bee,
		/obj/item/queen_bee,
		/obj/item/queen_bee,
		/obj/item/clothing/suit/bio_suit/beekeeping,
		/obj/item/clothing/head/bio_hood/beekeeping,
		/obj/item/weapon/book/manual/hydroponics_beekeeping,
		)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "beekeeping crate"
	access = list(access_hydroponics)
	group = "Hydroponics"
	containsdesc = "A starter kit for raising your own bees! Has everything you'd ever need to get started, including a manual. Comes with three queen bees."

/datum/supply_packs/ranching
	name = "Ranching kit"
	contains = list(
			/obj/item/weapon/circuitboard/egg_incubator,
			/obj/item/weapon/stock_parts/capacitor,
			/obj/item/weapon/stock_parts/capacitor,
			/obj/item/weapon/stock_parts/matter_bin,
			/obj/item/weapon/reagent_containers/food/snacks/egg,
			/obj/item/weapon/reagent_containers/food/snacks/egg,
			/obj/item/weapon/reagent_containers/food/snacks/egg,
			/obj/item/weapon/kitchen/utensil/knife/large,
			/obj/item/clothing/head/cowboy
		)
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "ranching crate"
	group = "Hydroponics"
	containsdesc = "For the cowboys. Comes with everything you need to raise and process chickens and their eggs."

/datum/supply_packs/Hydroponics_Trays
	name = "Hydroponic trays parts"
	contains = list(
					/obj/item/weapon/circuitboard/hydroponics,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/scanning_module,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/stock_parts/console_screen,
					/obj/item/weapon/circuitboard/hydroponics,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/scanning_module,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/stock_parts/console_screen)
	cost = 12
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "hydroponic trays components crate"
	access = list(access_hydroponics)
	group = "Hydroponics"
	containsdesc = "Plant growing trays, perfect for a space station. Includes two sets of tray electronics per crate. Some assembly required. Machine frames not included."
