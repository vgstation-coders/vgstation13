
//**************************************************************
//
// Microwave Recipes
// -----------------------
// See code/datums/recipe.dm
// TODO: More inheritance
//
//**************************************************************

// Donuts //////////////////////////////////////////////////////

/datum/recipe/donut
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal

/datum/recipe/jellydonut
	reagents = list("berryjuice" = 5, "flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly

/datum/recipe/jellydonut/slime
	reagents = list("slimejelly" = 5, "flour" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly

/datum/recipe/jellydonut/cherry
	reagents = list("cherryjelly" = 5, "flour" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly

/datum/recipe/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos

// Burgers /////////////////////////////////////////////////////

/datum/recipe/customizable_bun
	items = list(/obj/item/weapon/reagent_containers/food/snacks/dough)
	result = /obj/item/weapon/reagent_containers/food/snacks/bun

/datum/recipe/plainburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/animal)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger

/datum/recipe/appendixburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/organ)
	result = /obj/item/weapon/reagent_containers/food/snacks/appendixburger

/datum/recipe/syntiburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger/synth

/datum/recipe/brainburger
	reagents = list("flour" = 5)
	items = list(/obj/item/organ/brain)
	result = /obj/item/weapon/reagent_containers/food/snacks/brainburger

/datum/recipe/roburger
	reagents = list("flour" = 5)
	items = list(/obj/item/robot_parts/head)
	result = /obj/item/weapon/reagent_containers/food/snacks/roburger

/datum/recipe/xenoburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/xenoburger

/datum/recipe/fishburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishburger

/datum/recipe/tofuburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tofu)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofuburger

/datum/recipe/chickenburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken)
	result = /obj/item/weapon/reagent_containers/food/snacks/chickenburger

/datum/recipe/ghostburger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/ectoplasm)
	result = /obj/item/weapon/reagent_containers/food/snacks/ghostburger

/datum/recipe/clownburger
	reagents = list("flour" = 5)
	items = list(/obj/item/clothing/mask/gas/clown_hat)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownburger

/datum/recipe/mimeburger
	reagents = list("flour" = 5)
	items = list(/obj/item/clothing/head/beret)
	result = /obj/item/weapon/reagent_containers/food/snacks/mimeburger

/datum/recipe/assburger
	reagents = list("flour" = 5)
	items = list(/obj/item/clothing/head/butt)
	result = /obj/item/weapon/reagent_containers/food/snacks/assburger

/datum/recipe/spellburger
	reagents = list("flour" = 5)
	items = list(/obj/item/clothing/head/wizard)
	result = /obj/item/weapon/reagent_containers/food/snacks/spellburger

/datum/recipe/bigbiteburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bigbiteburger

/datum/recipe/superbiteburger
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/superbiteburger

/datum/recipe/slimeburger
	reagents = list("slimejelly" = 5, "flour" = 15)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime

/datum/recipe/jellyburger
	reagents = list("cherryjelly" = 5, "flour" = 15)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry

// Burger sliders //////////////////////////////////////////////

/datum/recipe/sliders
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box

/datum/recipe/sliders/synth
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/synth

/datum/recipe/sliders/xeno
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/xeno

/datum/recipe/sliders/chicken
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/chicken

/datum/recipe/sliders/carp
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/carp

/datum/recipe/sliders/spider
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/spider

/datum/recipe/sliders/clown
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/clothing/mask/gas/clown_hat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/clown

/datum/recipe/sliders/mime
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/clothing/head/beret
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/mime

/datum/recipe/sliders/slippery
	reagents = list("flour" = 10, "lube" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/slippery

// Eggs ////////////////////////////////////////////////////////

/datum/recipe/friedegg
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedegg

/datum/recipe/boiledegg
	reagents = list("water" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledegg

/datum/recipe/omelette
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/omelette

/datum/recipe/benedict
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/benedict

/datum/recipe/chocolateegg
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolateegg

// Human ///////////////////////////////////////////////////////

/datum/recipe/human //Parent datum only
	make_food(var/obj/container as obj)
		var/human_name
		var/human_job
		for(var/obj/item/weapon/reagent_containers/food/snacks/meat/human/HM in container)
			if(HM.subjectname)
				human_name = HM.subjectname
				human_job = HM.subjectjob
				break
		var/lastname_index = findtext(human_name, " ")
		if(lastname_index) human_name = copytext(human_name,lastname_index+1)
		var/obj/item/weapon/reagent_containers/food/snacks/human/HB = ..(container)
		HB.name = human_name+HB.name
		HB.job = human_job
		return HB

/datum/recipe/human/burger
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human)
	result = /obj/item/weapon/reagent_containers/food/snacks/human

/datum/recipe/human/kabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/human/kabob

// Pastries ////////////////////////////////////////////////////

/datum/recipe/waffles
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/waffles

/datum/recipe/poppypretzel
	reagents = list("flour" = 5)
	items = list(
		/obj/item/seeds/poppyseed,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poppypretzel

/datum/recipe/rofflewaffles
	reagents = list("psilocybin" = 5, "flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/sugarcookie
	reagents = list("flour" = 5, "sugar" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie

/datum/recipe/muffin
	reagents = list("milk" = 5, "flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin

/datum/recipe/berrymuffin
	reagents = list("milk" = 5, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/berry

/datum/recipe/booberrymuffin
	reagents = list("milk" = 5, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/ectoplasm
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/booberry

/datum/recipe/dindumuffin
	reagents = list("nothing" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/weapon/handcuffs)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/dindumuffin

// Donk Pockets ////////////////////////////////////////////////

/datum/recipe/donkpocket
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/faggot)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket //SPECIAL

/datum/recipe/donkpocket/proc/warm_up(var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked)
	being_cooked.warm = 1
	being_cooked.reagents.add_reagent("tricordrazine", 5)
	being_cooked.bitesize = 6
	being_cooked.name = "Warm " + being_cooked.name
	being_cooked.cooltime()

/datum/recipe/donkpocket/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = ..(container)
	warm_up(being_cooked)
	return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //No flour required
	items = list(/obj/item/weapon/reagent_containers/food/snacks/donkpocket)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket

/datum/recipe/donkpocket/warm/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = locate() in container
	if(being_cooked && !being_cooked.warm) warm_up(being_cooked)
	return being_cooked

// Bread ///////////////////////////////////////////////////////

/datum/recipe/bread
	reagents = list("flour" = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread

/datum/recipe/syntibread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth

/datum/recipe/xenomeatbread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread

/datum/recipe/spidermeatbread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread

/datum/recipe/meatbread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/bananabread
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread

/datum/recipe/tofubread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread

/datum/recipe/creamcheesebread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread

// French //////////////////////////////////////////////////////

/datum/recipe/eggplantparm
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantparm

/datum/recipe/berryclafoutis
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	result = /obj/item/weapon/reagent_containers/food/snacks/berryclafoutis

/datum/recipe/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/baguette

// Asian ///////////////////////////////////////////////////////

/datum/recipe/wingfangchu
	reagents = list("soysauce" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/wingfangchu

/datum/recipe/sashimi
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sashimi

/datum/recipe/fortunecookie
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/paper,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fortunecookie

/datum/recipe/fortunecookie/make_food(var/obj/container)
	var/obj/item/weapon/paper/paper = locate() in container
	paper.loc = null //prevent deletion
	var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/being_cooked = ..(container)
	paper.loc = being_cooked
	being_cooked.trash = paper
	return being_cooked

/datum/recipe/fortunecookie/check_items(var/obj/container)
	. = ..()
	if(.)
		var/obj/item/weapon/paper/paper = locate() in container
		if(!paper.info) . = 0
	return

/datum/recipe/boiledrice
	reagents = list("water" = 5, "rice" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledrice

/datum/recipe/ricepudding
	reagents = list("milk" = 5, "rice" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/ricepudding

// American ////////////////////////////////////////////////////

/datum/recipe/loadedbakedpotato
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/cubancarp
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubancarp

/datum/recipe/popcorn
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn

/datum/recipe/syntisteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth

/datum/recipe/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak

/datum/recipe/hotchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotchili

/datum/recipe/coldchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/coldchili

/datum/recipe/wrap
	reagents = list("soysauce" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/recipe/beans
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/beans

/datum/recipe/hotdog
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotdog

/datum/recipe/meatbun
	reagents = list("soysauce" = 5, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun

/datum/recipe/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedapple

// Cakes ///////////////////////////////////////////////////////

/datum/recipe/carrotcake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake

/datum/recipe/cheesecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/plaincake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake

/datum/recipe/braincake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/organ/brain
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake

/datum/recipe/birthdaycake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/clothing/head/cakehat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake

/datum/recipe/applecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake

/datum/recipe/orangecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake

/datum/recipe/limecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake

/datum/recipe/lemoncake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake

/datum/recipe/chocolatecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake

/datum/recipe/buchedenoel
	reagents = list("milk" = 5, "flour" = 15, "cream" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel

// Pies ////////////////////////////////////////////////////////

/datum/recipe/pie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie

/datum/recipe/applepie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/applepie

/datum/recipe/meatpie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/meatpie

/datum/recipe/tofupie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tofu)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/tofupie

/datum/recipe/xemeatpie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie

/datum/recipe/cherrypie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie

/datum/recipe/amanita_pie
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie

/datum/recipe/plump_pie
	reagents = list("flour" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie

/datum/recipe/asspie
	reagents = list("flour" = 10)
	items = list(/obj/item/clothing/head/butt)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/asspie

/datum/recipe/appletart
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/appletart

/datum/recipe/pumpkinpie
	reagents = list("milk" = 5, "sugar" = 5, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie

// Kebabs //////////////////////////////////////////////////////

/datum/recipe/syntikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeykabob/synth

/datum/recipe/monkeykabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeykabob

/datum/recipe/corgikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/corgikabob

/datum/recipe/tofukabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofukabob

// Pizza ///////////////////////////////////////////////////////

/datum/recipe/pizzamargherita
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/syntipizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth

/datum/recipe/meatpizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/mushroompizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza

// Mushrooms ///////////////////////////////////////////////////

/datum/recipe/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/amanitajelly

/datum/recipe/amanitajelly/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
	being_cooked.reagents.del_reagent("amatoxin")
	return being_cooked

/datum/recipe/plumphelmetbiscuit
	reagents = list("flour" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit

/datum/recipe/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chawanmushi

// Soup ////////////////////////////////////////////////////////

/datum/recipe/meatballsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot ,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballsoup

/datum/recipe/vegetablesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vegetablesoup

/datum/recipe/nettlesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/grown/nettle,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/nettlesoup

/datum/recipe/wishsoup
	reagents = list("water" = 20)
	result = /obj/item/weapon/reagent_containers/food/snacks/wishsoup

/datum/recipe/stew
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/stew

/datum/recipe/milosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/milosoup

/datum/recipe/stewedsoymeat
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat

/datum/recipe/tomatosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/tomatosoup

/datum/recipe/bloodsoup
	reagents = list("blood" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bloodsoup

/datum/recipe/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/slimesoup

/datum/recipe/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/ore/clown,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownstears

/datum/recipe/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushroomsoup

/datum/recipe/beetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/beetsoup

/datum/recipe/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mysterysoup

// Sandwiches //////////////////////////////////////////////////

/datum/recipe/sandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich

/datum/recipe/toastedsandwich
	items = list(/obj/item/weapon/reagent_containers/food/snacks/sandwich)
	result = /obj/item/weapon/reagent_containers/food/snacks/toastedsandwich

/datum/recipe/grilledcheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese

/datum/recipe/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/datum/recipe/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/notasandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich

/datum/recipe/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/twobread

/datum/recipe/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/datum/recipe/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

// Coder Snacks ///////////////////////////////////////////////////////

/datum/recipe/spaghetti
	reagents = list("flour" = 5)
	result= /obj/item/weapon/reagent_containers/food/snacks/spaghetti

/datum/recipe/copypasta
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta

// Pasta ///////////////////////////////////////////////////////

/datum/recipe/boiledspaghetti
	reagents = list("water" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/spaghetti)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti

/datum/recipe/pastatomato
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/recipe/meatballspaghetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti

// Salad ///////////////////////////////////////////////////////

/datum/recipe/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw

/datum/recipe/herbsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/herbsalad

/datum/recipe/herbsalad/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/herbsalad/being_cooked = ..(container)
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/aesirsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	reagents_forbidden = list("synaptizine")

/datum/recipe/validsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad

/datum/recipe/validsalad/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked
// Curry ///////////////////////////////////////////////////////

/datum/recipe/curry
	reagents = list ("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry

/datum/recipe/vindaloo
	reagents = list ("water" = 10, "capsaicin" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo

/datum/recipe/lemoncurry
	reagents = list ("water" = 10, "lemonjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/lemon

/datum/recipe/xenocurry
	reagents = list ("sacid" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/xeno

// Chips ///////////////////////////////////////////////////////

/datum/recipe/chips
	reagents = list ("sodiumchloride" = 2)
	items = list (/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable

/datum/recipe/vinegarchips
	reagents = list ("sodiumchloride" = 2, "vinegar" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar

/datum/recipe/cheddarchips
	reagents = list ("sodiumchloride" = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar

/datum/recipe/clownchips
	reagents = list ("banana" = 20)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown

/datum/recipe/nuclearchips
	reagents = list ("uranium" = 10, "sodiumchloride" = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear

/datum/recipe/commiechips
	reagents = list ("sodiumchloride" = 2, "vodka" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist

/datum/recipe/xenochips
	reagents = list ("sodiumchloride " = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno


// Misc ////////////////////////////////////////////////////////

/datum/recipe/ramen
	reagents = list("flour" = 5)
	items = list(/obj/item/stack/sheet/cardboard)
	result = /obj/item/weapon/reagent_containers/food/drinks/dry_ramen

/datum/recipe/sundaeramen
	reagents = list("dry_ramen" = 30, "sprinkles" = 1, "blackcolor" = 1, "bustanut" = 6)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundaeramen

/datum/recipe/sweetsundaeramen
	items = list(/obj/item/weapon/reagent_containers/food/snacks/sundaeramen,/obj/item/weapon/reagent_containers/food/snacks/ricepudding,/obj/item/weapon/reagent_containers/food/snacks/gigapuddi,/obj/item/weapon/reagent_containers/food/snacks/donkpocket)
	result = /obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen

/datum/recipe/cracker
	reagents = list("flour" = 5, "sodiumchloride" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/cracker

/datum/recipe/soylenviridians
	reagents = list("flour" = 15)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians

/datum/recipe/soylentgreen
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylentgreen

/datum/recipe/monkeysdelight
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/boiledspiderleg
	reagents = list("water" = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/spiderleg)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg

/datum/recipe/spidereggsham
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spidereggsham

/datum/recipe/sausage
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sausage

/datum/recipe/enchiladas
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/enchiladas

/datum/recipe/fishandchips
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishandchips

/datum/recipe/fishfingers
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishfingers

/datum/recipe/turkey
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "cornoil" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey

/datum/recipe/chicken_nuggets
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets

/datum/recipe/chicken_drumsticks
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		)
	result = /obj/item/weapon/storage/fancy/food_box/chicken_bucket

/datum/recipe/gigapuddi
	reagents = list("milk" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi

/datum/recipe/gigapuddi/happy
	reagents = list("milk" = 15, "sugar" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy

/datum/recipe/gigapuddi/anger
	reagents = list("milk" = 15, "sodiumchloride" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger

//LIVING PUDDI
//This is a terrible idea.

/datum/recipe/livingpuddi/happy
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/puddi/happy

/datum/recipe/livingpuddi/anger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/puddi/anger

/datum/recipe/livingpuddi
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gigapuddi,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/puddi


// END OF LIVING PUDDI SHIT THAT PROBABLY WON'T WORK

/datum/recipe/flan
	reagents = list("milk" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/flan

/datum/recipe/omurice
	reagents = list("rice" = 5, "ketchup" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice

/datum/recipe/omurice/heart
	reagents = list("rice" = 5, "ketchup" = 5, "sugar" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice/heart

/datum/recipe/omurice/face
	reagents = list("rice" = 5, "ketchup" = 5, "sodiumchloride" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice/face

/datum/recipe/bluespace
	reagents = list("milk" = 5, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/bluespace_crystal
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/bluespace

/datum/recipe/yellowcake
	reagents = list("uranium" = 5, "radium" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/yellowcake

/datum/recipe/yellowcupcake
	reagents = list("uranium" = 2, "radium" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/yellowcupcake

/datum/recipe/cookiebowl
	reagents = list("flour" = 5, "sugar" = 2)
	items = list (
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cookiebowl

/datum/recipe/chococherrycake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/chococherrycake

/datum/recipe/pumpkinbread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread

/datum/recipe/corndog
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/weapon/reagent_containers/food/snacks/corndog

/datum/recipe/cornydog
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi,
		/obj/item/stack/rods)
	result = /obj/item/weapon/reagent_containers/food/snacks/cornydog

/datum/recipe/higashikata
	reagents = list("cream" = 20, "watermelonjuice" = 10, "slimejelly" = 10, "ice" = 20, "milk" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/higashikata

/datum/recipe/sundae
	reagents = list("cream" = 10, "ice" = 10, "milk" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundae

/datum/recipe/potatosalad
	reagents = list("water" = 10, "milk" = 10, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/potatosalad

/datum/recipe/potentham
	reagents = list("plasma" = 10)
	items = list(
		/obj/item/weapon/aiModule/core/asimov,
		/obj/item/robot_parts/head,
		/obj/item/weapon/handcuffs

		)
	result = /obj/item/weapon/reagent_containers/food/snacks/potentham

/datum/recipe/claypot//it just works
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/ore/glass,
		)
	result = /obj/item/claypot

/datum/recipe/cinnamonroll
	reagents = list("milk" = 5, "sugar" = 10, "flour" = 5, "cinnamon" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cinnamonroll

/datum/recipe/cinnamonpie
	reagents = list("milk" = 5, "sugar" = 10, "flour" = 10, "cinnamon" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cinnamonpie

// Currently Disabled //////////////////////////////////////////

/*

/datum/recipe/bananaphone
	reagents = list("psilocybin" = 5) //Trippin' balls, man.
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/device/radio
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bananaphone

/datum/recipe/telebacon
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/device/assembly/signaler
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/telebacon

/datum/recipe/syntitelebacon
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/device/assembly/signaler
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/telebacon

*/
