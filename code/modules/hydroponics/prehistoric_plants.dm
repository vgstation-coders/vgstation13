//Plants aquired through xenoarchaeology

/datum/seed/telriis
	name = "telriis"
	seed_name = "telriis"
	display_name = "telriis grass"
	plant_dmi = 'icons/obj/hydroponics/telriis.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/telriis_clump)
	mutants = null
	harvest_repeat = 1
	chems = list(DIETHYLAMINE = list(0,10))

	lifespan = 60
	maturation = 6
	production = 4
	yield = 4
	potency = 20
	growth_stages = 4

/obj/item/seeds/telriis
	seed_type = "telriis"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/telriis_clump
	name = "telriis grass"
	desc = "A clump of telriis grass, not recommended for consumption by sentients."
	plantname = "telriis"
	hydroflags = HYDRO_PREHISTORIC

/datum/seed/thaadra
	name = "thaadra"
	seed_name = "thaadra"
	display_name = "thaa'dra grass"
	plant_dmi = 'icons/obj/hydroponics/thaadra.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/thaadrabloom)
	mutants = null
	harvest_repeat = 1
	chems = list(FROSTOIL = list(5,30))

	lifespan = 50
	maturation = 3
	production = 3
	yield = 5
	potency = 90 //Much higher than normal plants
	growth_stages = 4
	alter_temp = 1
	ideal_heat = T20C - 10

/obj/item/seeds/thaadra
	seed_type = "thaadra"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/thaadrabloom
	name = "thaa'dra bloom"
	desc = "Looks chewy, might be good to eat."
	plantname = "thaadra"
	hydroflags = HYDRO_PREHISTORIC

/datum/seed/jurlmah
	name = "jurlmah"
	seed_name = "jurlmah"
	display_name = "jurl'mah tree"
	plant_dmi = 'icons/obj/hydroponics/jurlmah.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/jurlmah)
	mutants = null
	chems = list(CLONEXADONE = list(1,10))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 3
	potency = 30
	growth_stages = 5
	biolum = 1
	biolum_colour = "#9FE7EC"

	large = 0

/obj/item/seeds/jurlmah
	seed_type = "jurlmah"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/jurlmah
	name = "jurl'mah pod"
	desc = "Bulbous and veiny, it appears to pulse slightly as you look at it."
	plantname = "jurlmah"
	hydroflags = HYDRO_PREHISTORIC

/datum/seed/amauri
	name = "amauri"
	seed_name = "amauri"
	display_name = "amauri stalks"
	plant_dmi = 'icons/obj/hydroponics/amauri.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/amauri)
	mutants = null
	noreact = 1
	chems = list(POTASSIUM = list(0,10),SUGAR = list(0,10),PHOSPHORUS = list(0,10))

	lifespan = 25
	maturation = 10
	production = 1
	yield = 3
	potency = 30
	growth_stages = 3
	biolum = 1
	biolum_colour = "#5532E2"


	large = 0

/obj/item/seeds/amauri
	seed_type = "amauri"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/amauri
	name = "amauri fruit"
	desc = "It is small, round and hard. Its skin is a thick dark purple."
	plantname = "amauri"
	hydroflags = HYDRO_PREHISTORIC

/datum/seed/gelthi
	name = "gelthi"
	seed_name = "gelthi"
	display_name = "gelthi stem"
	plant_dmi = 'icons/obj/hydroponics/gelthi.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/gelthi)
	mutants = null
	harvest_repeat = 2
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 55
	maturation = 6
	production = 5
	yield = 3
	potency = 20
	growth_stages = 3

	large = 0

/obj/item/seeds/gelthi
	seed_type = "gelthi"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/gelthi
	name = "gelthi berries"
	desc = "They feel fluffy and slightly warm to the touch."
	gender = PLURAL
	plantname = "gelthi"
	hydroflags = HYDRO_PREHISTORIC

/datum/seed/vale
	name = "vale"
	seed_name = "vale"
	display_name = "vale tree"
	plant_dmi = 'icons/obj/hydroponics/vale.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/vale)
	mutants = null
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),SPORTDRINK = list(0,2),THYMOL = list(0,5))

	lifespan = 100
	maturation = 6
	production = 6
	yield = 4
	potency = 20
	growth_stages = 4

	large = 0

/obj/item/seeds/vale
	seed_type = "vale"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/vale
	name = "vale leaves"
	desc = "Small, curly leaves covered in a soft pale fur."
	plantname = "vale"
	hydroflags = HYDRO_PREHISTORIC
	fragrance = INCENSE_CRAVE

/datum/seed/surik
	name = "surik"
	seed_name = "surik"
	display_name = "surik stalks"
	plant_dmi = 'icons/obj/hydroponics/surik.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/surik)
	mutants = null
	harvest_repeat = 1
	chems = list(KARMOTRINE = list(2,2))

	lifespan = 55
	maturation = 7
	production = 6
	yield = 5
	potency = 20
	growth_stages = 4

	large = 0

/obj/item/seeds/surik
	seed_type = "surik"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/surik
	name = "surik fruit"
	desc = "Multiple layers of blue skin peeling away to reveal a spongey core, vaguely resembling an ear."
	plantname = "surik"
	hydroflags = HYDRO_PREHISTORIC
