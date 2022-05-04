//todo:
	//[DONE] make and test spawning a clover having all the right params
		//[DONE] need the seed to be the same as the leaves
	//[DONE] make and test seed extracting a clover passing all seed data onto its seeds
	//[DONE] make and test growing clover seeds turning into the proper type of clover
		// [DONE] need the randomness to work properly too per each spawned
	//[DONE] make sure both grown clovers and spawned clovers have the right params
	//sprites and inhand sprites
	//tune params etc
	//remove redundant code
	//using clovers as an accessory?


/obj/item/weapon/reagent_containers/food/snacks/grown/clover
	potency = 50
	filling_color = "#247E0A"
	luckiness_validity = LUCKINESS_WHEN_GENERAL_RECURSIVE
	var/leaves = 3
	plantname = "clover3"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/zeroleaf
	leaves = 0
	plantname = "clover0"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/oneleaf
	leaves = 1
	plantname = "clover1"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/twoleaf
	leaves = 2
	plantname = "clover2"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fourleaf
	leaves = 4
	plantname = "clover4"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fiveleaf
	leaves = 5
	plantname = "clover5"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sixleaf
	leaves = 6
	plantname = "clover6"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sevenleaf
	leaves = 7
	plantname = "clover7"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/New(atom/loc, custom_plantname)
	. = ..()
//	if(!isnull(leaves))
//		seed.leaves = leaves
	update_leaves()
/*
/obj/item/weapon/reagent_containers/food/snacks/grown/clover/initialize()
	. = ..()
	leaves = seed.leaves
*/

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/proc/update_leaves()
	switch(leaves)
		if(3)
			name = "clover"
			desc = "A cheerful little herb with three leaves."
		if(0)
			name = "zero-leaf clover"
			desc = "Bad luck and extreme misfortune will infest your pathetic soul for all eternity."
			luckiness = -10000
		if(1)
			name = "one-leaf clover"
			desc = "This cursed clover is said to bring nothing but misery to the one who bears it."
			luckiness = -500
		if(2)
			name = "two-leaf clover"
			desc = "This clover only has two leaves. How unfortunate!"
			luckiness = -25
		if(4)
			name = "four-leaf clover"
			desc = "This clover has four leaves. Lucky you!"
			luckiness = 25
		if(5)
			name = "five-leaf clover"
			desc = "A marvel of probabilistics, this exquisitely rare clover is said to bring fantastic luck."
			luckiness = 100
		if(6)
			name = "six-leaf clover"
			desc = "A closely-guarded secret of the leperchauns."
			luckiness = 1000
		if(7)
			name = "seven-leaf clover"
			desc = "The fates themselves are said to shower their adoration on the one who bears this legendary lucky charm."
			luckiness = 10000
//	icon = 'icons/obj/hydroponics/clover.dmi'
//	var/datum/seed/clover/S = new
//	if(seed)
//		leaves =
	plantname = "clover[leaves]"
	icon_state = "clover[leaves]"

/datum/seed/clover/
	name = "clover3"
	seed_name = "clover"
	display_name = "clover"
	plant_dmi = 'icons/obj/hydroponics/clover.dmi'
	plant_icon_state = "clover3"

	products = list(
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/zeroleaf,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/oneleaf,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/twoleaf,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fourleaf,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fiveleaf,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sixleaf,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sevenleaf)

//	mutants = list("clover2","clover4")
	harvest_repeat = 1
	yield = 3
//	yield = 50

//	leaves = 3

/*

/datum/seed/clover/New()
	. = ..()
	leaves = get_next_leaves()
*/


/datum/seed/clover/proc/get_next_leaves()
	if(isnull(leaves))
		leaves = 3
	if(prob(50 + rand(-5,5)))
		return 3
	if(prob(99 + rand(-1,1)))
		return leaves
	var/ls = 1
	for(var/i in 1 to 7)
		if(!prob(98 + rand(-2,2)))
			ls += 1
	if((leaves > 3 && rand(2)) || (leaves < 3 && !rand(2)))
		ls *= -1
	else
		ls *= pick(-1,1)
	return (leaves + ls <= 7 && leaves + ls >= 0) ? leaves + ls : 3

/datum/seed/clover/product_logic()
	return products[get_next_leaves()+1]

/datum/seed/clover/zeroleaf
	name = "clover0"
	leaves = 0

/datum/seed/clover/oneleaf
	name = "clover1"
	leaves = 1

/datum/seed/clover/twoleaf
	name = "clover2"
	leaves = 2

/*
/datum/seed/clover/threeleaf
	name = "clover3"
	leaves = 3
*/

/datum/seed/clover/fourleaf
	name = "clover4"
	leaves = 4

/datum/seed/clover/fiveleaf
	name = "clover5"
	leaves = 5

/datum/seed/clover/sixleaf
	name = "clover6"
	leaves = 6

/datum/seed/clover/sevenleaf
	name = "clover7"
	leaves = 7

/obj/item/seeds/cloverseed
	name = "packet of clover seeds"
	seed_type = "clover3"
	vending_cat = "weeds"

/obj/item/seeds/cloverseed/New()
	. = ..()
	var/datum/seed/clover/S = seed
	seed_type = "clover[S.get_next_leaves()]"


/*
	chems = list(NUTRIMENT = list(1), MESCALINE = list(1,8), TANNIC_ACID = list(1,8,1), OPIUM = list(1,10,1))
	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	ideal_light = 8
	large = 0
*/

/*
/datum/seed/clover/zeroleaf
	leaves = 0

/datum/seed/clover/oneleaf
	leaves = 1

/datum/seed/clover/twoleaf
	leaves = 2

/datum/seed/clover/fourleaf
	leaves = 4

/datum/seed/clover/fiveleaf
	leaves = 5

/datum/seed/clover/sixleaf
	leaves = 6

/datum/seed/clover/sevenleaf
	leaves = 7
*/

/*

/obj/item/seeds/cloverseed/zeroleaf

/obj/item/seeds/cloverseed/oneleaf

/obj/item/seeds/cloverseed/twoleaf

/obj/item/seeds/cloverseed/fourleaf

/obj/item/seeds/cloverseed/fiveleaf

/obj/item/seeds/cloverseed/sixleaf

/obj/item/seeds/cloverseed/sevenleaf

/obj/item/seeds/cloverseed/New()
	. = ..()
	seed.leaves = seedleaves

*/

/*
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
*/

/*

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
*/

