/obj/item/weapon/reagent_containers/food/snacks/grown/clover
	name = "clover"
	desc = "A cheerful little herb with three leaves."
	potency = 50
	filling_color = "#247E0A"
	plantname = "clover"
	luckiness_validity = LUCKINESS_WHEN_GENERAL_RECURSIVE
	var/leaves = 3

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/zeroleaf
	name = "zero-leaf clover"
	desc = "Bad luck and extreme misfortune will infest your pathetic soul for all eternity."
	luckiness = -10000
	leaves = 0

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/oneleaf
	name = "one-leaf clover"
	desc = "This cursed clover is said to bring nothing but misery to the one who bears it."
	luckiness = -500
	leaves = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/twoleaf
	name = "two-leaf clover"
	desc = "This clover only has two leaves. How unfortunate!"
	luckiness = -25
	leaves = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fourleaf
	name = "four-leaf clover"
	desc = "This clover has four leaves. Lucky you!"
	luckiness = 25
	leaves = 4

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fiveleaf
	name = "five-leaf clover"
	desc = "A marvel of probabilistics, this exquisitely rare clover is said to bring fantastic luck."
	luckiness = 100
	leaves = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sixleaf
	name = "six-leaf clover"
	desc = "A closely-guarded secret of the leperchauns."
	luckiness = 500
	leaves = 6

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sevenleaf
	name = "seven-leaf clover"
	desc = "The fates themselves are said to shower their adoration on the one who bears this legendary lucky charm."
	luckiness = 10000
	leaves = 7

/datum/seed/clover
	name = "clover"
	seed_name = "clover"
	display_name = "clover"
	plant_dmi = 'icons/obj/hydroponics/clover.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover)

	plant_icon_state = "clover"


	mutants = list("clover2","clover4")
	harvest_repeat = 1
//	chems = list(NUTRIMENT = list(1), MESCALINE = list(1,8), TANNIC_ACID = list(1,8,1), OPIUM = list(1,10,1))
	yield = 6

/*
	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	ideal_light = 8
	large = 0
*/

/datum/seed/clover/zeroleaf
	name = "clover0"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/zeroleaf)
	mutants = list("clover1")
	plant_icon_state = "clover0"
	seed_name = "zero-leaf clover"
	display_name = "zero-leaf clover"

/datum/seed/clover/oneleaf
	name = "clover1"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/oneleaf)
	mutants = list("clover0","clover3")
	plant_icon_state = "clover1"
	seed_name = "one-leaf clover"
	display_name = "one-leaf clover"

/datum/seed/clover/twoleaf
	name = "clover2"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/twoleaf)
	mutants = list("clover1","clover")
	plant_icon_state = "clover2"
	seed_name = "two-leaf clover"
	display_name = "two-leaf clover"

/datum/seed/clover/fourleaf
	name = "clover4"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fourleaf)
	mutants = list("clover","clover5")
	plant_icon_state = "clover4"
	seed_name = "four-leaf clover"
	display_name = "four-leaf clover"

/datum/seed/clover/fiveleaf
	name = "clover5"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fiveleaf)
	mutants = list("clover4","clover6")
	plant_icon_state = "clover5"
	seed_name = "five-leaf clover"
	display_name = "five-leaf clover"

/datum/seed/clover/sixleaf
	name = "clover6"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sixleaf)
	mutants = list("clover5","clover6")
	plant_icon_state = "clover6"
	seed_name = "six-leaf clover"
	display_name = "six-leaf clover"

/datum/seed/clover/sevenleaf
	name = "clover7"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sevenleaf)
	mutants = list("clover6")
	plant_icon_state = "clover7"
	seed_name = "seven-leaf clover"
	display_name = "seven-leaf clover"

/obj/item/seeds/cloverseed
	name = "packet of clover seeds"
	seed_type = "clover"
	vending_cat = "weeds"

/obj/item/seeds/cloverseed/zeroleaf
	name = "packet of zero-leaf clover seeds"
	seed_type = "clover0"

/obj/item/seeds/cloverseed/oneleaf
	name = "packet of one-leaf clover seeds"
	seed_type = "clover1"

/obj/item/seeds/cloverseed/twoleaf
	name = "packet of two-leaf clover seeds"
	seed_type = "clover2"

/obj/item/seeds/cloverseed/fourleaf
	name = "packet of four-leaf clover seeds"
	seed_type = "clover4"

/obj/item/seeds/cloverseed/fiveleaf
	name = "packet of five-leaf clover seeds"
	seed_type = "clover5"

/obj/item/seeds/cloverseed/sixleaf
	name = "packet of six-leaf clover seeds"
	seed_type = "clover6"

/obj/item/seeds/cloverseed/sevenleaf
	name = "packet of seven-leaf clover seeds"
	seed_type = "clover7"

/datum/blesscurse/brokenmirror
	blesscurse_name = "mirror-breaker curse"
	blesscurse_strength = -50

//For when someone spills salt. Requires accidental reagent spilling to be re-implmented.
/datum/blesscurse/saltspiller
	blesscurse_name = "salt-spiller curse"
	blesscurse_strength = -50