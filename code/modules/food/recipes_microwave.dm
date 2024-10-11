
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
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal/frosted

/datum/recipe/jellydonut
	reagents = list(BERRYJUICE = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly/frosted

/datum/recipe/jellydonut/slime
	reagents = list(SLIMEJELLY = 5, FLOUR = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/frosted

/datum/recipe/jellydonut/cherry
	reagents = list(CHERRYJELLY = 5, FLOUR = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/frosted

/datum/recipe/chaosdonut
	reagents = list(FROSTOIL = 5, CAPSAICIN = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos/frosted

/datum/recipe/bagel
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/butter)
	result = /obj/item/weapon/reagent_containers/food/snacks/bagel

/datum/recipe/bagel/make_food(obj/container, mob/user)
	score.bagelscooked++
	return ..()

// Burgers /////////////////////////////////////////////////////

/datum/recipe/customizable_bun
	items = list(/obj/item/weapon/reagent_containers/food/snacks/dough)
	result = /obj/item/weapon/reagent_containers/food/snacks/bun

/datum/recipe/plainburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/animal)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger

/datum/recipe/appendixburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/organ)
	result = /obj/item/weapon/reagent_containers/food/snacks/appendixburger

/datum/recipe/syntiburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger/synth

/datum/recipe/brainburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/organ/internal/brain)
	result = /obj/item/weapon/reagent_containers/food/snacks/brainburger

/datum/recipe/roburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/robot_parts/head)
	result = /obj/item/weapon/reagent_containers/food/snacks/roburger

/datum/recipe/xenoburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/xenoburger

/datum/recipe/tofuburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tofu)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofuburger

/datum/recipe/chickenburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken)
	result = /obj/item/weapon/reagent_containers/food/snacks/chickenburger

/datum/recipe/ghostburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/ectoplasm)
	result = /obj/item/weapon/reagent_containers/food/snacks/ghostburger

/datum/recipe/clownburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/mask/gas/clown_hat)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownburger

/datum/recipe/mimeburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/head/beret)
	result = /obj/item/weapon/reagent_containers/food/snacks/mimeburger

/datum/recipe/donutburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal,
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/donutburger

/datum/recipe/assburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/head/butt)
	result = /obj/item/weapon/reagent_containers/food/snacks/assburger

/datum/recipe/spellburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/head/wizard)
	result = /obj/item/weapon/reagent_containers/food/snacks/spellburger

/datum/recipe/bigbiteburger
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bigbiteburger

/datum/recipe/superbiteburger
	reagents = list(SODIUMCHLORIDE = 5, BLACKPEPPER = 5, FLOUR = 15)
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

/datum/recipe/moonsuperbiteburger //Alternate recipe using moon cheese
	reagents = list(SODIUMCHLORIDE = 5, BLACKPEPPER = 5, FLOUR = 15)
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
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/superbiteburger

/datum/recipe/slimeburger
	reagents = list(SLIMEJELLY = 5, FLOUR = 15)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime

/datum/recipe/polypburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/polyp)
	result = /obj/item/weapon/reagent_containers/food/snacks/polypburger

/datum/recipe/blobburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/blob)
	result = /obj/item/weapon/reagent_containers/food/snacks/blobburger

/datum/recipe/blobkabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/blob,
		/obj/item/weapon/reagent_containers/food/snacks/meat/blob
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/blobkabob

/datum/recipe/blobpudding
	reagents = list(SUGARS = 5, CREAM = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/blob)
	result = /obj/item/weapon/reagent_containers/food/snacks/blobpudding

/datum/recipe/blobegg
	reagents = list(BLOBANINE = 5, CREAM = 5, BLACKPEPPER = 1, SODIUMCHLORIDE = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris)
	result = /obj/item/weapon/reagent_containers/food/snacks/blobegg

/datum/recipe/blobsoup
	reagents = list(FLOUR = 5, CREAM = 5, WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/blob,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/weapon/reagent_containers/food/snacks/blobsoup

/datum/recipe/blobvolcano
	reagents = list(MUTAGEN = 10, NUTRIMENT = 10, MESCALINE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/blob/core,
	)
	result = /obj/structure/blob_volcano

/datum/recipe/jellyburger
	reagents = list(CHERRYJELLY = 5, FLOUR = 15)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry

/datum/recipe/gelatinburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slime)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/gelatin

/datum/recipe/gelatinburger/alt
//Uses gelatin from cooking.
	items = list(/obj/item/weapon/reagent_containers/food/snacks/gelatin)

/datum/recipe/veggieburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/diona)
	result = /obj/item/weapon/reagent_containers/food/snacks/veggieburger

/datum/recipe/veggieburgernymph
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/nymphmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/veggieburgernymph

/datum/recipe/avocadoburger
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/avocadoburger

/datum/recipe/caramelburger
	reagents = list(FLOUR = 5, CARAMEL = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/caramelburger

/datum/recipe/bearburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/bearburger

/datum/recipe/glassburger
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/silicatecitrus,
		/obj/item/stack/sheet/glass/glass)
	result = /obj/item/weapon/reagent_containers/food/snacks/glassburger

// Burger sliders //////////////////////////////////////////////

/datum/recipe/sliders
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider

/datum/recipe/sliders/synth
	priority = 1
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/synth

/datum/recipe/sliders/xeno
	priority = 1
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/xeno

/datum/recipe/sliders/chicken
	priority = 1
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/chicken

/datum/recipe/sliders/spider
	priority = 1
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/spider

/datum/recipe/sliders/clown
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/clothing/mask/gas/clown_hat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/clown

/datum/recipe/sliders/mime
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/clothing/head/beret
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/mime

/datum/recipe/sliders/slippery
	reagents = list(FLOUR = 10, LUBE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/slippery

// Eggs ////////////////////////////////////////////////////////

/datum/recipe/friedegg
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedegg

/datum/recipe/boiledegg
	reagents = list(WATER = 5)
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

/datum/recipe/moonomelette //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
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

/datum/recipe/valentinebar
	items = list(
		/obj/item/organ/internal/heart,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine

// Human ///////////////////////////////////////////////////////

/datum/recipe/human //Parent datum only

/datum/recipe/human/make_food(var/obj/container, var/mob/user)
	var/human_name
	for(var/obj/item/weapon/reagent_containers/food/snacks/meat/human/HM in container)
		if(HM.subjectname)
			human_name = HM.subjectname
			break
	var/lastname_index = findtext(human_name, " ")
	if(lastname_index)
		human_name = copytext(human_name,lastname_index+1)
	var/obj/item/weapon/reagent_containers/food/snacks/human/HB = ..(container)
	HB.name = human_name+HB.name
	return HB

/datum/recipe/human/burger
	reagents = list(FLOUR = 5)
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

/datum/recipe/eclair
	reagents = list(FLOUR = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eclair

/datum/recipe/eclair_big
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/eclair,
		/obj/item/weapon/reagent_containers/food/snacks/eclair,
		/obj/item/weapon/reagent_containers/food/snacks/eclair,
		/obj/item/weapon/reagent_containers/food/snacks/eclair,
		/obj/item/weapon/reagent_containers/food/snacks/eclair,
		/obj/item/weapon/reagent_containers/food/snacks/eclair,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eclair/big

/datum/recipe/waffles
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/waffles

/datum/recipe/poppypretzel
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/seeds,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poppypretzel

/datum/recipe/poppypretzel/check_items(obj/container)
	. = ..()
	if(. == 1)
		var/obj/item/seeds/seed_item = locate() in container // Parent call returned 1 so this is expected to be non-null
		return seed_item.seed_type == "poppies"

/datum/recipe/rofflewaffles
	reagents = list(PSILOCYBIN = 5, FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/pancake
	reagents = list(PANCAKE = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/pancake

/datum/recipe/sugarcookie
	reagents = list(FLOUR = 5, SUGARS = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie

/datum/recipe/caramelcookie
	reagents = list(FLOUR = 5, CARAMEL = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/caramelcookie

/datum/recipe/holidaycookie
	reagents = list(FLOUR = 5, SUGARS = 5, SPRINKLES = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/holidaycookie

/datum/recipe/candyheart
	reagents = list(SUGARS = 5, CORNOIL = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/candyheart

/datum/recipe/chocostrawberry
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar, /obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocostrawberry

/datum/recipe/gingerbread_man
	reagents = list(FLOUR = 5, SUGARS = 5, WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/gingerbread_man

/datum/recipe/livinggingerbread_man
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gingerbread_man,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/hostile/gingerbread

/datum/recipe/candy_cane
	reagents = list(SUGARS = 5, WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy_cane

/datum/recipe/muffin
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin

/datum/recipe/berrymuffin
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/berry

/datum/recipe/booberrymuffin
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/ectoplasm
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/booberry

/datum/recipe/dindumuffin
	reagents = list(NOTHING = 5, MILK = 5, FLOUR = 5)
	items = list(/obj/item/weapon/handcuffs)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/dindumuffin

// Donk Pockets ////////////////////////////////////////////////

/datum/recipe/donkpocket
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/faggot)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket //SPECIAL

/datum/recipe/donkpocket/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = ..(container)
	being_cooked.warm_up()
	return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //No flour required
	items = list(/obj/item/weapon/reagent_containers/food/snacks/donkpocket)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket

/datum/recipe/donkpocket/warm/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = locate() in container
	if(istype(being_cooked))
		if(being_cooked.warm <= 0)
			being_cooked.warm_up()
		else
			being_cooked.warm = 80
	return being_cooked

// Bread ///////////////////////////////////////////////////////

/datum/recipe/bread
	reagents = list(FLOUR = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread

/datum/recipe/nova_bread
	reagents = list(NOVAFLOUR = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/nova

/datum/recipe/syntibread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth

/datum/recipe/moonsyntibread //Alternate recipe using moon cheese
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth

/datum/recipe/xenomeatbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread

/datum/recipe/moonxenomeatbread //Alternate recipe using moon cheese
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread

/datum/recipe/spidermeatbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread

/datum/recipe/moonspidermeatbread //Alternate recipe using moon cheese
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread

/datum/recipe/meatbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/moonmeatbread //Alternate recipe using moon cheese
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/bananabread
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread

/datum/recipe/tofubread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread

/datum/recipe/moontofubread //Alternate recipe using moon cheese
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread

/datum/recipe/creamcheesebread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread

/datum/recipe/mooncreamcheesebread //Alternate recipe using moon cheese
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread

/datum/recipe/eucharist
	reagents = list(FLOUR = 5, HOLYWATER = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/eucharist

// French //////////////////////////////////////////////////////

/datum/recipe/eggplantparm
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantparm

/datum/recipe/mooneggplantparm //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantparm

/datum/recipe/berryclafoutis
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	result = /obj/item/weapon/reagent_containers/food/snacks/berryclafoutis

/datum/recipe/baguette
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, FLOUR = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/baguette

/datum/recipe/croissant
	reagents = list(FLOUR = 5, WATER = 5, MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/croissant

// Asian ///////////////////////////////////////////////////////

/datum/recipe/wingfangchu
	reagents = list(SOYSAUCE = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/wingfangchu

/datum/recipe/fortunecookie
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/paper,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fortunecookie

/datum/recipe/fortunecookie/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/paper/paper = locate() in container
	paper.forceMove(null) //prevent deletion
	var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/being_cooked = ..(container)
	paper.forceMove(being_cooked)
	being_cooked.trash = paper
	return being_cooked

/datum/recipe/fortunecookie/check_items(var/obj/container, var/mob/user)
	. = ..()
	if(.)
		var/obj/item/weapon/paper/paper = locate() in container
		if(!paper.info)
			. = 0
	return

/datum/recipe/boiledrice
	reagents = list(WATER = 5, RICE = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledrice

/datum/recipe/ricepudding
	reagents = list(MILK = 5, RICE = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/ricepudding

/datum/recipe/riceball
	reagents = list(RICE = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/riceball

// American ////////////////////////////////////////////////////

/datum/recipe/loadedbakedpotato
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/moonloadedbakedpotato //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/mooncheesyfries //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/punnetofcheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesyfries,
		/obj/item/stack/sheet/cardboard,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries/punnet

/datum/recipe/coneoffries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/stack/sheet/cardboard,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fries/cone

/datum/recipe/popcorn
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/popcorn/allpopped

/datum/recipe/syntisteak
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth

/datum/recipe/meatsteak
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
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

/datum/recipe/plasmastew
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/plasmacabbage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/plasmastew

/datum/recipe/plasmastew/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/plasmastew/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(PLASMA)
	return being_cooked

/datum/recipe/wrap
	reagents = list(SOYSAUCE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/recipe/beans
	reagents = list(KETCHUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/beans

/datum/recipe/hotdog
	reagents = list(KETCHUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotdog

/datum/recipe/meatbun
	reagents = list(SOYSAUCE = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun

/datum/recipe/candiedapple
	reagents = list(WATER = 5, SUGARS = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedapple

/datum/recipe/caramelapple
	reagents = list(WATER = 5, CARAMEL = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/caramelapple

// Cakes ///////////////////////////////////////////////////////

/datum/recipe/carrotcake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake

/datum/recipe/cheesecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/mooncheesecake //Alternate recipe using moon cheese
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/plaincake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake

/datum/recipe/braincake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/organ/internal/brain
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake

/datum/recipe/birthdaycake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/clothing/head/cakehat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake

/datum/recipe/applecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake

/datum/recipe/orangecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake

/datum/recipe/limecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake

/datum/recipe/lemoncake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake

/datum/recipe/chocolatecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake

/datum/recipe/caramelcake
	reagents = list(MILK = 5, FLOUR = 15, CARAMEL = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/caramelcake

/datum/recipe/buchedenoel
	reagents = list(MILK = 5, FLOUR = 15, CREAM = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel

/datum/recipe/popoutcake
	reagents = list("milk" = 15, "flour" = 45)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard
		)
	result = /obj/structure/popout_cake
	cookable_with = COOKABLE_WITH_MICROWAVE

/datum/recipe/fruitcake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake

/datum/recipe/christmascake
	reagents = list(SUGARS = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake/christmascake

// Pies ////////////////////////////////////////////////////////

/datum/recipe/pie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie

/datum/recipe/clovercreampie
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/clovercreampie

/datum/recipe/applepie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/applepie

/datum/recipe/xemeatpie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie

/datum/recipe/meatpie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/meatpie

/datum/recipe/tofupie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tofu)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/tofupie

/datum/recipe/cherrypie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie

/datum/recipe/amanita_pie
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie

/datum/recipe/plump_pie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie/perfect

/datum/recipe/asspie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/clothing/head/butt)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/asspie

/datum/recipe/appletart
	reagents = list(SUGARS = 5, MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/appletart

/datum/recipe/pumpkinpie
	reagents = list(MILK = 5, SUGARS = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie

/datum/recipe/nofruitpie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie

/datum/recipe/mincepie
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
		/obj/item/weapon/reagent_containers/food/snacks/meat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/mincepie

/datum/recipe/caramelpie
	reagents = list(FLOUR = 10, CARAMEL = 10)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/caramelpie

/datum/recipe/cloverpie
	reagents = list(MILK = 5, SUGARS = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/cloverpie

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
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/moonpizzamargherita //Alternate recipe using moon cheese
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/syntipizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth

/datum/recipe/moonsyntipizza //Alternate recipe using moon cheese
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth

/datum/recipe/meatpizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/moonmeatpizza //Alternate recipe using moon cheese
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/mushroompizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza

/datum/recipe/blingpizza
	reagents = list(NOVAFLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/diamond,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/silverpear,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/blingpizza

// Mushrooms ///////////////////////////////////////////////////

/datum/recipe/spacylibertyduff
	reagents = list(WATER = 5, VODKA = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list(WATER = 5, VODKA = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/amanitajelly

/datum/recipe/amanitajelly/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(AMATOXIN)
	return being_cooked

/datum/recipe/plumphelmetbiscuit
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/perfect

/datum/recipe/chawanmushi
	reagents = list(WATER = 5, SOYSAUCE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chawanmushi

// Soup ////////////////////////////////////////////////////////

/datum/recipe/meatballsoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot ,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballsoup

/datum/recipe/vegetablesoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vegetablesoup

/datum/recipe/nettlesoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/grown/nettle,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/nettlesoup

/datum/recipe/monkeysoup
	reagents = list(WATER = 10, VINEGAR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeysoup

/datum/recipe/wishsoup
	reagents = list(WATER = 20)
	result = /obj/item/weapon/reagent_containers/food/snacks/wishsoup
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/wishsoup/perfect

/datum/recipe/stew
	reagents = list(WATER = 10)
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
	reagents = list(WATER = 10)
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
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/tomatosoup

/datum/recipe/bloodsoup
	reagents = list(BLOOD = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bloodsoup

/datum/recipe/slimesoup
	reagents = list(WATER = 10, SLIMEJELLY = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/slimesoup

/datum/recipe/clownstears
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/stack/sheet/mineral/clown,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownstears

/datum/recipe/roboticiststears
	reagents = list(WATER = 10)
	items = list(
		/obj/item/robot_parts/head,
		/obj/item/stack/sheet/mineral/phazon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/roboticiststears

/datum/recipe/mushroomsoup
	reagents = list(WATER = 5, MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushroomsoup

/datum/recipe/beetsoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/beetsoup

/datum/recipe/mysterysoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mysterysoup

/datum/recipe/moonmysterysoup //Alternate recipe using moon cheese
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mysterysoup

/datum/recipe/primordialsoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/primordialsoup

/datum/recipe/avocadosoup
	reagents = list(LIMEJUICE = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/avocadosoup

/datum/recipe/silicatesoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/silicatecitrus)
	result = /obj/item/weapon/reagent_containers/food/snacks/silicatesoup

/datum/recipe/mothershipbroth
	reagents = list(ZAMMILD = 5, CREAM = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/mothershipbroth
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/mothershipbroth/abducted

/datum/recipe/mothershipbroth_spicy
	reagents = list(ZAMSPICYTOXIN = 5, CREAM = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/mothershipbroth_spicy
	silver_slime_result = /obj/item/weapon/reagent_containers/food/snacks/mothershipbroth_spicy/abducted

/datum/recipe/cheesybroth
	reagents = list(ZAMMILD = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesybroth

/datum/recipe/mooncheesybroth //Alternate recipe using moon cheese
	reagents = list(ZAMMILD = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesybroth

/datum/recipe/swimmingcarp
	reagents = list(ZAMMILD = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/swimmingcarp

/datum/recipe/swimmingcarp_spicy
	reagents = list(ZAMSPICYTOXIN = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/swimmingcarp_spicy

/datum/recipe/blethernoodlesoup
	reagents = list(SACIDS = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/wrapped

/datum/recipe/polyppudding
	reagents = list(POLYPGELATIN = 5, SUGARS = 5, CREAM = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/polyppudding

// Sandwiches //////////////////////////////////////////////////

/datum/recipe/sandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/moonsandwich //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich
	cookable_with = COOKABLE_WITH_MIXING

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

/datum/recipe/moongrilledcheese //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese

/datum/recipe/slimetoast
	reagents = list(SLIMEJELLY = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/datum/recipe/jelliedtoast
	reagents = list(CHERRYJELLY = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/notasandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/twobread
	reagents = list(WINE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/twobread
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/slimesandwich
	reagents = list(SLIMEJELLY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/cherrysandwich
	reagents = list(CHERRYJELLY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/avocadotoast
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/avocadotoast

/datum/recipe/pbj
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/grapejelly,
		/obj/item/weapon/reagent_containers/food/snacks/peanutbutter,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pbj
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/polypwich
	reagents = list (POLYPGELATIN = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/polyp,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/polypwich
	cookable_with = COOKABLE_WITH_MIXING

// Coder Snacks ///////////////////////////////////////////////////////

/datum/recipe/spaghetti
	reagents = list(FLOUR = 5)
	result= /obj/item/weapon/reagent_containers/food/snacks/spaghetti

/datum/recipe/copypasta
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta

// Pasta ///////////////////////////////////////////////////////

/datum/recipe/mommispaghetti // Same as roburger, but for mommis
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/pipe,
		/obj/item/stack/sheet/mineral/plasma,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mommispaghetti

/datum/recipe/boiledspaghetti
	reagents = list(WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/spaghetti)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti

/datum/recipe/pastatomato
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/recipe/meatballspaghetti
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti

/datum/recipe/crabspaghetti
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/crabspaghetti

/datum/recipe/spesslaw
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw

/datum/recipe/coldnoodles
	reagents = list (SOYSAUCE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spicycoldnoodles

// Salad ///////////////////////////////////////////////////////

/datum/recipe/salad
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/salad/herbsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/herbsalad

/datum/recipe/salad/herbsalad/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/herbsalad/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(TOXIN)
	return being_cooked

/datum/recipe/salad/aesirsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	reagents_forbidden = SYNAPTIZINES

/datum/recipe/salad/validsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad

/datum/recipe/salad/validsalad/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(TOXIN)
	return being_cooked

/datum/recipe/salad/chinesecoldsalad
	reagents = list (VINEGAR = 5, SOYSAUCE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chinesecoldsalad

/datum/recipe/salad/confederatespirit
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/pimiento,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/confederatespirit

/datum/recipe/salad/moonconfederatespirit //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/pimiento,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/confederatespirit

/datum/recipe/salad/fruitsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fruitsalad

/datum/recipe/salad/nofruitsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/nofruitsalad

/datum/recipe/salad/chickensalad
	reagents = list (VINEGAR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chickensalad

/datum/recipe/salad/grapesalad
	reagents = list (SUGARS = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/grapesalad

/datum/recipe/salad/moongrapesalad //Alternate recipe using moon cheese
	reagents = list (SUGARS = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/grapesalad

/datum/recipe/salad/orzosalad
	reagents = list (RICE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/mint
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/orzosalad

/datum/recipe/salad/mexicansalad
	reagents = list (LIMEJUICE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/pimiento,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mexicansalad

/datum/recipe/salad/moonmexicansalad //Alternate recipe using moon cheese
	reagents = list (LIMEJUICE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/pimiento,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mexicansalad

/datum/recipe/salad/tontesdepelouse
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/grass,
		/obj/item/weapon/reagent_containers/food/snacks/grown/clover
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/tontesdepelouse

/datum/recipe/salad/midnightsnack
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower,
		/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower,
		/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/midnightsnack

/datum/recipe/salad/starrynight
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower,
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/starrynightsalad

/datum/recipe/salad/rosolli
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/rosolli

// Curry ///////////////////////////////////////////////////////

/datum/recipe/curry
	reagents = list (WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry

/datum/recipe/crabcurry
	reagents = list (WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/crab

/datum/recipe/vindaloo
	reagents = list (WATER = 10, CAPSAICIN = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo

/datum/recipe/lemoncurry
	reagents = list (WATER = 10, LEMONJUICE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/lemon

/datum/recipe/xenocurry
	reagents = list (SACID = 10)
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
	reagents = list (SODIUMCHLORIDE = 2)
	items = list (/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable

/datum/recipe/vinegarchips
	reagents = list (SODIUMCHLORIDE = 2, VINEGAR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar

/datum/recipe/cheddarchips
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar

/datum/recipe/mooncheddarchips // Alternate recipe using moon cheese
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar

/datum/recipe/clownchips
	reagents = list (BANANA = 20)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown

/datum/recipe/nuclearchips
	reagents = list (URANIUM = 10, SODIUMCHLORIDE = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear

/datum/recipe/commiechips
	reagents = list (SODIUMCHLORIDE = 2, VODKA = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist

/datum/recipe/xenochips
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno

/datum/recipe/hotchips
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/hot

/datum/recipe/novachips
	reagents = list (SODIUMCHLORIDE = 2, NOVAFLOUR = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nova

/datum/recipe/tortillachips
	reagents = list (FLOUR = 20, CORNOIL = 10, SODIUMCHLORIDE = 10)
	result = /obj/item/weapon/chipbasket

/datum/recipe/queso
	reagents = list(BLACKPEPPER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili
		)
	result = /obj/item/weapon/reagent_containers/food/dipping_sauce/queso

/datum/recipe/lunaqueso // Alternate recipe using moon cheese
	reagents = list(BLACKPEPPER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili
		)
	result = /obj/item/weapon/reagent_containers/food/dipping_sauce/queso

/datum/recipe/guacamole
	reagents = list(LIMEJUICE = 10, SODIUMCHLORIDE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		)
	result = /obj/item/weapon/reagent_containers/food/dipping_sauce/guacamole
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/salsa
	reagents = list(LIMEJUICE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
		)
	result = /obj/item/weapon/reagent_containers/food/dipping_sauce/salsa
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/hummus
	reagents = list(LEMONJUICE = 10, HONEY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
		)
	result = /obj/item/weapon/reagent_containers/food/dipping_sauce/hummus
	cookable_with = COOKABLE_WITH_MIXING

// Misc ////////////////////////////////////////////////////////

/datum/recipe/caramel
	reagents = list(SUGARS = 50)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/condiment/caramel

/datum/recipe/chiliconcarne
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
				/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
				/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
				/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/chiliconcarne

/datum/recipe/cloverconcarne
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
				/obj/item/weapon/reagent_containers/food/snacks/grown/clover,
				/obj/item/weapon/reagent_containers/food/snacks/meat,
				/obj/item/weapon/reagent_containers/food/snacks/butter)
	result = /obj/item/weapon/reagent_containers/food/snacks/cloverconcarne

/datum/recipe/chilaquiles
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
				/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
				/obj/item/weapon/reagent_containers/food/dipping_sauce/salsa)
	result = /obj/item/weapon/reagent_containers/food/snacks/chilaquiles

/datum/recipe/lunachilaquiles // Alternate recipe using moon cheese
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/tortillachip,
				/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
				/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
				/obj/item/weapon/reagent_containers/food/dipping_sauce/salsa)
	result = /obj/item/weapon/reagent_containers/food/snacks/chilaquiles

/datum/recipe/quiche
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato,
				/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
				/obj/item/weapon/reagent_containers/food/snacks/egg,
				/obj/item/weapon/reagent_containers/food/snacks/cheesewedge)
	result = /obj/item/weapon/reagent_containers/food/snacks/quiche

/datum/recipe/moonquiche // Alternate recipe using moon cheese
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato,
				/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
				/obj/item/weapon/reagent_containers/food/snacks/egg,
				/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese)
	result = /obj/item/weapon/reagent_containers/food/snacks/quiche

/datum/recipe/minestrone
	reagents = list(WATER = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
				/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
				/obj/item/weapon/reagent_containers/food/snacks/spaghetti)
	result = /obj/item/weapon/reagent_containers/food/snacks/minestrone

/datum/recipe/gazpacho
	reagents = list(VINEGAR = 10, SODIUMCHLORIDE = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
				/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato)
	result = /obj/item/weapon/reagent_containers/food/snacks/gazpacho

/datum/recipe/bruschetta
	reagents = list(SODIUMCHLORIDE = 2, FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
				/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
				/obj/item/weapon/reagent_containers/food/snacks/cheesewedge)
	result = /obj/item/weapon/reagent_containers/food/snacks/bruschetta

/datum/recipe/moonbruschetta // Alternate recipe using moon cheese
	reagents = list(SODIUMCHLORIDE = 2, FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
				/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
				/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese)
	result = /obj/item/weapon/reagent_containers/food/snacks/bruschetta

/datum/recipe/pannacotta
	reagents = list(CREAM = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
				/obj/item/weapon/reagent_containers/food/snacks/gelatin,
				/obj/item/weapon/reagent_containers/food/snacks/yogurt
				)
	result = /obj/item/weapon/reagent_containers/food/snacks/pannacotta

/datum/recipe/pannacotta/alt
//Uses gelatin from butchered slime people
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
				/obj/item/weapon/reagent_containers/food/snacks/meat/slime,
				/obj/item/weapon/reagent_containers/food/snacks/yogurt
				)

/datum/recipe/yogurt
	reagents = list(CREAM = 10, VIRUSFOOD = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes)
	result = /obj/item/weapon/reagent_containers/food/snacks/yogurt
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/gelatin
	reagents = list(WATER = 10)
	items = list(/obj/item/stack/teeth)
	result = /obj/item/weapon/reagent_containers/food/snacks/gelatin

/datum/recipe/jectie
	reagents = list(CHERRYJELLY = 5, SUGARS = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/jectie

/datum/recipe/jectie/make_food(obj/container, mob/user)
	if(user && user.mind)
		var/datum/role/jectie_cooker/R = user.mind.GetRole(JECTIE_COOKER)
		if(!R)
			R = new
			R.AssignToRole(user.mind,1)
		var/obj/item/weapon/reagent_containers/food/snacks/jectie/J = ..()
		if(J && J.icon_state == "jectie_green")
			R.logo_state = "jectie_green"
			R.AppendObjective(/datum/objective/cook_jectie/success)
		else
			R.logo_state = "jectie_red"
			R.AppendObjective(/datum/objective/cook_jectie)
		return J
	return ..()

/datum/recipe/ramen
	reagents = list(FLOUR = 5)
	items = list(/obj/item/stack/sheet/cardboard)
	result = /obj/item/weapon/reagent_containers/food/drinks/dry_ramen

/datum/recipe/sundaeramen
	reagents = list(DRY_RAMEN = 30, SPRINKLES = 1, BLACKCOLOR = 1, BUSTANUT = 6)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundaeramen

/datum/recipe/sweetsundaeramen
	items = list(/obj/item/weapon/reagent_containers/food/snacks/sundaeramen,/obj/item/weapon/reagent_containers/food/snacks/ricepudding,/obj/item/weapon/reagent_containers/food/snacks/gigapuddi,/obj/item/weapon/reagent_containers/food/snacks/donkpocket)
	result = /obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen

/datum/recipe/cracker
	reagents = list(FLOUR = 5, SODIUMCHLORIDE = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/cracker

/datum/recipe/soylenviridians
	reagents = list(FLOUR = 15)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians

/datum/recipe/soylentgreen
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylentgreen

/datum/recipe/monkeysdelight
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/boiledspiderleg
	reagents = list(WATER = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg

/datum/recipe/spidereggsham
	reagents = list(SODIUMCHLORIDE = 1)
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

/datum/recipe/fishburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishburger

/datum/recipe/fishandchips
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishandchips

/datum/recipe/fishfingers
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishfingers

/datum/recipe/fishtacosupreme
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme

/datum/recipe/bleachkipper
	reagents = list(BLEACH = 30, PHAZON = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		/obj/item/robot_parts/head,
		/obj/item/weapon/handcuffs,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/blue
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bleachkipper

/datum/recipe/poissoncru
	reagents = list(LIMEJUICE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poissoncru
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/sashimi
	reagents = list(SOYSAUCE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sashimi
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/cubancarp
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubancarp

/datum/recipe/sliders/carp
	priority = 1
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/carp

/datum/recipe/sliders/carp/make_food(var/obj/container, var/mob/user)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/C = locate() in container
	if(C.poisonsacs)
		result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/toxiccarp
	..()

/datum/recipe/turkey
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, CORNOIL = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey

/datum/recipe/chicken_nuggets
	reagents = list(KETCHUP = 5)
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

/datum/recipe/chicken_tenders
	reagents = list(CORNOIL = 3)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken)
	result = /obj/item/weapon/reagent_containers/food/snacks/chicken_tenders

/datum/recipe/vox_nuggets
	reagents = list(KETCHUP = 5)
	priority = 1
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vox_nuggets

/datum/recipe/vox_chicken_drumstick
	priority = 1
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken,
		)
	result = /obj/item/weapon/storage/fancy/food_box/vox_chicken_bucket

/datum/recipe/vox_chicken_tenders
	priority = 1
	reagents = list(CORNOIL = 3)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken)
	result = /obj/item/weapon/reagent_containers/food/snacks/vox_chicken_tenders

/datum/recipe/vox_nuggets_pox
	reagents = list(KETCHUP = 5)
	priority = 1
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vox_nuggets

/datum/recipe/vox_chicken_drumstick_pox
	priority = 1
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox,
		)
	result = /obj/item/weapon/storage/fancy/food_box/vox_chicken_bucket

/datum/recipe/vox_chicken_tenders_pox
	priority = 1
	reagents = list(CORNOIL = 3)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox)
	result = /obj/item/weapon/reagent_containers/food/snacks/vox_chicken_tenders

/datum/recipe/crab_sticks
	reagents = list(SODIUMCHLORIDE = 1, SUGARS = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/crab_sticks

/datum/recipe/crabcake
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/crabcake

/datum/recipe/honeycitruschicken
	reagents = list(SOYSAUCE = 5, HONEY = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
			/obj/item/weapon/reagent_containers/food/snacks/grown/orange)
	result = /obj/item/weapon/reagent_containers/food/snacks/honeycitruschicken

/datum/recipe/gigapuddi
	reagents = list(MILK = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi

/datum/recipe/gigapuddi/happy
	reagents = list(MILK = 15, SUGARS = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy

/datum/recipe/gigapuddi/anger
	reagents = list(MILK = 15, SODIUMCHLORIDE = 5)
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
	reagents = list(MILK = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/flan

/datum/recipe/honeyflan
	reagents = list(MILK = 5,CINNAMON = 5,HONEY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/honeyflan

/datum/recipe/omurice
	reagents = list(RICE = 5, KETCHUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice

/datum/recipe/omurice/heart
	reagents = list(RICE = 5, KETCHUP = 5, SUGARS = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice/heart

/datum/recipe/omurice/face
	reagents = list(RICE = 5, KETCHUP = 5, SODIUMCHLORIDE = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice/face

/datum/recipe/bluespace
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/bluespace_crystal
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/bluespace

/datum/recipe/yellowcake
	reagents = list(URANIUM = 5, RADIUM = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/yellowcake

/datum/recipe/yellowcupcake
	reagents = list(URANIUM = 2, RADIUM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/yellowcupcake

/datum/recipe/cookiebowl
	reagents = list(FLOUR = 5, SUGARS = 2)
	items = list (
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cookiebowl

/datum/recipe/chococherrycake
	reagents = list(MILK = 5, FLOUR = 15)
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
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread

/datum/recipe/corndog
	reagents = list(FLOUR = 5)
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
	reagents = list(CREAM = 20, WATERMELONJUICE = 10, SLIMEJELLY = 10, ICE = 20, MILK = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/higashikata
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/sundae
	reagents = list(CREAM = 10, ICE = 10, MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundae
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/icecreamsandwich
	items = list(/obj/item/weapon/reagent_containers/food/snacks/icecream,/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/avocadomilkshake
	reagents = list(MILK = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/icecream,
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/avocadomilkshake
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/potatosalad
	reagents = list(WATER = 10, MILK = 10, SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/potatosalad

/datum/recipe/coleslaw
	reagents = list(VINEGAR = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/coleslaw
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/risotto
	reagents = list(RICE = 10, WINE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/risotto

/datum/recipe/moonrisotto //Alternate recipe using moon cheese
	reagents = list(RICE = 10, WINE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/risotto

/datum/recipe/potentham
	reagents = list(PLASMA = 10)
	items = list(

		/obj/item/weapon/reagent_containers/food/snacks/meat/box,
		/obj/item/weapon/aiModule/core/asimov,
		/obj/item/robot_parts/head,
		/obj/item/weapon/handcuffs

		)
	result = /obj/item/weapon/reagent_containers/food/snacks/potentham

/datum/recipe/chococoin
	reagents = list(MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/chococoin

/datum/recipe/claypot//it just works
	reagents = list(WATER = 10)
	items = list(
		/obj/item/stack/ore/glass,
		)
	result = /obj/item/claypot

//I hate this please for the love of god someone enable microwaves to batch produce items
/datum/recipe/waxcake
	reagents = list(WAX = 5)
	result = /obj/item/stack/sheet/wax
/datum/recipe/waxcake_times_two
	reagents = list(WAX = 10)
	result = /obj/item/stack/sheet/wax/times_two
/datum/recipe/waxcake_times_three
	reagents = list(WAX = 15)
	result = /obj/item/stack/sheet/wax/times_three
/datum/recipe/waxcake_times_four
	reagents = list(WAX = 20)
	result = /obj/item/stack/sheet/wax/times_four
/datum/recipe/waxcake_times_ten
	reagents = list(WAX = 50)
	result = /obj/item/stack/sheet/wax/times_ten
/datum/recipe/waxcake_times_twenty
	reagents = list(WAX = 100)
	result = /obj/item/stack/sheet/wax/bigstack

/datum/recipe/cinnamonroll
	reagents = list(MILK = 5, SUGARS = 10, FLOUR = 5, CINNAMON = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cinnamonroll

/datum/recipe/cinnamonpie
	reagents = list(MILK = 5, SUGARS = 10, FLOUR = 10, CINNAMON = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cinnamonpie

/datum/recipe/ijzerkoekje
	reagents = list(FLOUR = 30, IRON = 30)
	result = /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy
	name = "Helper Dummy"
	desc = "You should never see this text."

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy/New()
	for(var/i = 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje(get_turf(src))
	qdel(src)

/datum/recipe/pimiento
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pimiento

/datum/recipe/burrito
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/beans
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/threebeanburrito

/datum/recipe/hauntedjam
	reagents = list(SUGARS = 5, VINEGAR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hauntedjam

///Vox Food///
/datum/recipe/gravyboat
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/condiment/gravy

/datum/recipe/gravybig
	reagents = list(WATER = 50)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/condiment/gravy/gravybig

/datum/recipe/sundayroast
	reagents = list(GRAVY = 10,SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundayroast

/datum/recipe/risenshiny
	reagents = list(FLOUR = 10, GRAVY = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/risenshiny

/datum/recipe/mushnslush
	reagents = list(GRAVY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushnslush

/datum/recipe/breadfruitpie
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/breadfruit

/datum/recipe/woodapplejam
	reagents = list(SUGARS = 20)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/woodapplejam

/datum/recipe/candiedwoodapple
	reagents = list(SUGARS = 5, WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedwoodapple

/datum/recipe/voxstew
	reagents = list(GRAVY = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/voxstew

/datum/recipe/garlicbread
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/garlicbread

/datum/recipe/flammkuche
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/flammkuchen

/datum/recipe/moonflammkuche //Alternate recipe using moon cheese
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/flammkuchen

/datum/recipe/welcomepie
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/welcomepie

/datum/recipe/zhulongcaofan
	reagents = list(RICE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/zhulongcaofan

/datum/recipe/zhulongcaofan/make_food(var/obj/container, var/mob/user)
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher/P in container)
		P.reagents.del_reagent(FORMIC_ACID) //This cleanses the plant.
	return ..()

/datum/recipe/bacon
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/box)
	result = /obj/item/weapon/reagent_containers/food/snacks/bacon

/datum/recipe/porktenderloin
	reagents = list(GRAVY = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/box
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/porktenderloin

/datum/recipe/sweetandsourpork
	reagents = list(SOYSAUCE = 10, SUGARS = 10) //Will require trading with humans to get soy, but they can make their own acid.
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/box
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sweetandsourpork

/datum/recipe/hoboburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/box,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hoboburger

/datum/recipe/hoboburger/make_food(var/obj/container, var/mob/user)
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher/P in container)
		P.reagents.del_reagent(FORMIC_ACID) //This cleanses the plant.
	return ..()

/datum/recipe/moonhoboburger //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/box,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hoboburger

/datum/recipe/moonhoboburger/make_food(var/obj/container, var/mob/user)
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher/P in container)
		P.reagents.del_reagent(FORMIC_ACID) //This cleanses the plant.
	return ..()

/datum/recipe/reclaimed
	reagents = list(VOMIT = 5, ANTI_TOXINS = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/reclaimed

/datum/recipe/bruisepack
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	result = /obj/item/stack/medical/bruise_pack
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/ointment
	reagents = list(DERMALINES = 5)
	result = /obj/item/stack/medical/ointment
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/poachedaloe
	reagents = list(WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	result = /obj/item/weapon/reagent_containers/food/snacks/poachedaloe

/datum/recipe/toxicmint
	reagents = list(SUGARS = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	result = /obj/item/weapon/reagent_containers/food/snacks/mint

/datum/recipe/vanishingstew
	reagents = list(VAPORSALT = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vanishingstew

/datum/recipe/poutine
	reagents = list(GRAVY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poutine

/datum/recipe/moonpoutine //Alternate recipe using moon cheese
	reagents = list(GRAVY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poutine

/datum/recipe/poutinedangerous
	reagents = list(GRAVY = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/poutine,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poutinedangerous

/datum/recipe/poutinebarrel
	reagents = list(GRAVY = 50)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/poutinedangerous,
		/obj/item/weapon/reagent_containers/food/snacks/poutinedangerous,
		/obj/item/weapon/reagent_containers/food/snacks/poutinedangerous,
		/obj/item/weapon/reagent_containers/food/snacks/poutinedangerous
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poutinebarrel

/datum/recipe/mapleleaf
	reagents = list (SUGARS = 10, HONEY = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/aloe,
		/obj/item/stack/sheet/snow
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mapleleaf
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/poutinesyrup
	reagents = list (MAPLESYRUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/poutine
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poutinesyrup

/datum/recipe/poutineocean
	reagents = list (GRAVY = 100)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel
		)
	result = /obj/structure/poutineocean

/datum/recipe/poutinecitadel
	reagents = list (MAPLESYRUP = 50)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel,
		/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel
		)
	result = /obj/structure/poutineocean/poutinecitadel

/datum/recipe/mud_pie
	reagents = list(WATER = 25)
	items = list(
		/obj/item/stack/ore/glass,
		/obj/item/stack/ore/glass,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/mudpie

/datum/recipe/power_crepe
	reagents = list(RADIUM = 5)
	items = list(
		/obj/item/weapon/cell,
		/obj/item/weapon/reagent_containers/food/snacks/dough,
		/obj/item/stack/cable_coil,
		)
	result = /obj/item/weapon/cell/crepe
	time = 300

/datum/recipe/lasagna
	reagents = list(TOMATOJUICE = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lasagna

/datum/recipe/moonlasagna //Alternate recipe using moon cheese
	reagents = list(TOMATOJUICE = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lasagna

/*seafood!*/

/datum/recipe/salmonsteak
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonmeat)

	result = /obj/item/weapon/reagent_containers/food/snacks/salmonsteak

/datum/recipe/boiled_shrimp
	reagents = list(WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/shrimp)

	result = /obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp

/datum/recipe/sushi
	cookable_with = COOKABLE_WITH_MIXING //No cooking sushi in a frying pan!

/datum/recipe/sushi/Ebi
	items = list(/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp,
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ebi

/datum/recipe/sushi/Ikura
	items = list(/obj/item/fish_eggs/salmon,
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ikura

/datum/recipe/sushi/Sake     // 100000 TIMES FOLDED SUSHI CAN CUT THROUGH DIAMONDS
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonmeat,
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Sake

/datum/recipe/sushi/SmokedSalmon
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonsteak,
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_SmokedSalmon // this shit sounds fucking delicous IRL

/datum/recipe/sushi/Tamago
	reagents = list(SAKE = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/boiledrice,
	/obj/item/weapon/reagent_containers/food/snacks/egg
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tamago

/datum/recipe/sushi/Inari
	items = list(/obj/item/weapon/reagent_containers/food/snacks/boiledrice,
	/obj/item/weapon/reagent_containers/food/snacks/tofu
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Inari

/datum/recipe/sushi/Masago
	items = list(/obj/item/fish_eggs/goldfish,
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Masago

/datum/recipe/sushi/Tobiko
	items = list(/obj/item/fish_eggs/shark,                                                                                                                                                                                                                                              //Every night I watch the skies from inside my bunker. They'll come back. If I watch they'll come. I can hear their voices from the sky. Calling out my name. There's the ridge. The guns in the jungle. Screaming. Smoke. The blood. All over my hands.
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tobiko

/datum/recipe/sushi/TobikoEgg
	items = list(/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tobiko,
	/obj/item/weapon/reagent_containers/food/snacks/egg
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg

/datum/recipe/sushi/Tai
	items = list(/obj/item/weapon/reagent_containers/food/snacks/catfishmeat,
	/obj/item/weapon/reagent_containers/food/snacks/boiledrice)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tai
// this is a lot of fucking fish

/datum/recipe/sushi/lobster
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat,
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lobster_sushi

/datum/recipe/sushi/Unagi
	reagents = list(SAKE = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/boiledrice,
	/obj/item/weapon/fish/electric_eel
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Unagi

/datum/recipe/sushi/avocado
	items = list(/obj/item/weapon/reagent_containers/food/snacks/boiledrice,
	/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_avocado

/datum/recipe/sushi/eggplant
	reagents = list(RICE = 10, VINEGAR = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
				/obj/item/weapon/reagent_containers/food/snacks/grown/chili
				)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantsushi

/datum/recipe/friedshrimp
	reagents = list(CORNOIL = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/shrimp
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/friedshrimp

/datum/recipe/soyscampi
	reagents = list(SOYSAUCE = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/shrimp
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/soyscampi

/datum/recipe/shrimpcocktail
	reagents = list(KETCHUP = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/shrimp,
	/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/shrimpcocktail

/datum/recipe/friedcatfish
	reagents = list(CORNOIL = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/catfishmeat
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/friedcatfish

/datum/recipe/gumbo
	reagents = list(WATER = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/catfishmeat,
	/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/catfishgumbo

/datum/recipe/catfishcourtbouillon
	reagents = list(CAPSAICIN = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/catfishmeat
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/catfishcourtbouillon

/datum/recipe/smokedsalmon
	reagents = list(BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonmeat,
	/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/smokedsalmon

/datum/recipe/planksalmon
	reagents = list(HONEY = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonmeat,
	/obj/item/stack/sheet/wood
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/planksalmon

/datum/recipe/citrussalmon
	reagents = list(BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonmeat,
	/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
	/obj/item/weapon/reagent_containers/food/snacks/grown/orange
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/citrussalmon

/datum/recipe/salmonavocado
	items = list(/obj/item/weapon/reagent_containers/food/snacks/salmonmeat,
	/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle,
	/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/salmonavocado

/datum/recipe/rumshark
	reagents = list(BLACKPEPPER = 15, RUM = 15)
	items = list(/obj/item/weapon/fish/toothless_shark,
	/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/rumshark

/datum/recipe/akutaq
	reagents = list(MILK = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/glofishmeat,
	/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/akutaq
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/carpcurry
	reagents = list(VINEGAR = 5, RICE = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/goldfishmeat
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/carpcurry

/datum/recipe/carpconsomme
	reagents = list(WATER = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/goldfishmeat,
	/obj/item/weapon/reagent_containers/food/snacks/egg
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/carpconsomme

/datum/recipe/butterstick
	items = list(/obj/item/weapon/reagent_containers/food/snacks/butter,
	/obj/item/stack/rods
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/butterstick
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/ambrosia_brownies
	reagents = list(COCO = 10, SUGARS = 10, FLOUR = 15)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/butter,
	/obj/item/weapon/reagent_containers/food/snacks/egg,
	/obj/item/weapon/reagent_containers/food/snacks/egg,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/ambrosia_brownies
/datum/recipe/butterfingers_r
	items = list(/obj/item/organ/external/r_hand,
	/obj/item/weapon/reagent_containers/food/snacks/butter,
	)

 result = /obj/item/weapon/reagent_containers/food/snacks/butterfingers_r/
/datum/recipe/butterfingers_l
	items = list(/obj/item/organ/external/l_hand,
	/obj/item/weapon/reagent_containers/food/snacks/butter,
	)

 result = /obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/

/datum/recipe/butteredtoast
	reagents = list(LIQUIDBUTTER = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)

 result = /obj/item/weapon/reagent_containers/food/snacks/butteredtoast

/datum/recipe/pierogi
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)

	result = /obj/item/weapon/reagent_containers/food/snacks/pierogi

/datum/recipe/moonpierogi //Alternate recipe using moon cheese
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
		)

	result = /obj/item/weapon/reagent_containers/food/snacks/pierogi

/datum/recipe/sauerkraut
	reagents = list(SODIUMCHLORIDE = 2, WATER = 15)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage)

	result = /obj/item/weapon/reagent_containers/food/snacks/sauerkraut
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/pickledpears
	reagents = list(VINEGAR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pickledpears
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/pickledbeets
	reagents = list(VINEGAR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pickledbeets
	cookable_with = COOKABLE_WITH_MICROWAVE

/datum/recipe/bulgogi
	reagents = list(SOYSAUCE = 10, SUGARS =5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bulgogi

/datum/recipe/candiedpear
	reagents = list(CARAMEL = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedpear

/datum/recipe/bakedpears
	reagents = list(CINNAMON = 5, SUGARS = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bakedpears

/datum/recipe/winepear
	reagents = list(CINNAMON = 5, WINE = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/winepear

/datum/recipe/suppermatter
	reagents = list(PLASMA = 5, NITROGEN = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/caramelcake
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter

/datum/recipe/excitingsuppermatter
	reagents = list(PLASMA = 5, OXYGEN = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/caramelcake
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/excitingsuppermatter

/datum/recipe/saltednuts
	reagents = list(SODIUMCHLORIDE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/peanut,
		/obj/item/weapon/reagent_containers/food/snacks/grown/peanut,
		/obj/item/weapon/reagent_containers/food/snacks/grown/peanut,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/saltednuts
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/grapejelly
	reagents = list (SUGARS = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes)
	result = /obj/item/weapon/reagent_containers/food/snacks/grapejelly

/datum/recipe/peanutbutter
	reagents = list (SODIUMCHLORIDE = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/peanut,
		/obj/item/weapon/reagent_containers/food/snacks/grown/peanut,
		/obj/item/weapon/reagent_containers/food/snacks/grown/peanut,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/peanutbutter
	//going to let this be made in a pan because the peanuts are roasted

/datum/recipe/escargot
	reagents = list (SODIUMCHLORIDE = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/snail,
		/obj/item/clothing/head/helmet/snail_helm,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
		/obj/item/weapon/reagent_containers/food/snacks/peanutbutter,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/escargot

/datum/recipe/es_cargo
	reagents = list (SODIUMCHLORIDE = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/snail,
		/obj/item/clothing/head/helmet/snail_helm,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/paper,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/es_cargo

/datum/recipe/steamed_lobster_deluxe //the deluxe comes with butter and a slice of lemon
	reagents = list (WATER = 10)
	items = list(
		/obj/item/weapon/fish/lobster,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/butter,
		)
	result = /obj/item/weapon/steamed_lobster_deluxe_uncracked //this is the lobster whose shell isnt cracked, break its seal and steal its soul, you vile cretin

/datum/recipe/steamed_lobster_simple //the simple has no fancy butter or lemon
	reagents = list (WATER = 10)
	items = list(
		/obj/item/weapon/fish/lobster
		)
	result = /obj/item/weapon/steamed_lobster_simple_uncracked //same as the deluxe, wirecutter it to make it edible

/datum/recipe/lobster_roll //lobster hot dog
	reagents = list (MAYO = 10) // these things are mostly mayo
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lobster_roll

/datum/recipe/lobster_roll_butter //lobster hot dog, no mayo and buttery
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/butter
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lobster_roll_butter

/datum/recipe/lobster_tail_baked
	reagents = list (SODIUMCHLORIDE = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail,
		/obj/item/weapon/reagent_containers/food/snacks/butter,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lobster_tail_baked

/datum/recipe/lobster_dumplings
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat,
		/obj/item/weapon/reagent_containers/food/snacks/doughslice
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/lobster_dumplings

/datum/recipe/sweetroll
	reagents = list(FLOUR = 5, SUGARS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/butter,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sweetroll

// You have now entered the Ayy food zone

/datum/recipe/greytvdinnerclassic
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/zamdinnerclassic
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/greytvdinnerclassic

/datum/recipe/salad/greygreens
	reagents = list(SOYSAUCE = 10)
	items = list(
		/obj/item/weapon/grown/nettle,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/greygreens
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/stuffedpitcher
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/stuffedpitcher

/datum/recipe/moonstuffedpitcher //Alternate recipe using moon cheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/stuffedpitcher

/datum/recipe/nymphsperil
	reagents = list(RICE = 10, CORNOIL = 5, SACID = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/nymphmeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/nymphsperil

//You have now exited the ayy food zone. Thanks for visiting.

/datum/recipe/dionaroast
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, CORNOIL = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/nymphmeat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/dionaroast

////////////////////////////////
// YE ENTERING THE GUNK ZONE ///
////////////////////////////////

/datum/recipe/gunkburgerroach
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/roach)
	result = /obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger

/datum/recipe/gunkburgercricket
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/cricket)
	result = /obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger

/datum/recipe/deluxegunkburger
	reagents = list(FLOUR = 5)
	priority = 1
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big)
	result = /obj/item/weapon/reagent_containers/food/snacks/skitter/deluxegunkburger

/datum/recipe/supergunkburger
	reagents = list(GUNKS = 10, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
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
	result = /obj/item/weapon/reagent_containers/food/snacks/skitter/supergunkburger

/datum/recipe/moonsupergunkburger
	reagents = list(GUNKS = 10, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/skitter/supergunkburger

/datum/recipe/hopcorn
	items = list(
				/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
				/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
				/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
				)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn/cricket

/datum/recipe/gunkkabobroach
	reagents = list(GUNKS = 5)
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gunkkabob

/datum/recipe/gunkkabobcricket
	reagents = list(GUNKS = 5)
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gunkkabob

/datum/recipe/salad/roachsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn/roachsalad

/datum/recipe/gunksouproach
	reagents = list(WATER = 10, GUNKS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gunksoup

/datum/recipe/gunksoupcricket
	reagents = list(WATER = 10, GUNKS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cricket,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gunksoup

/datum/recipe/gunksoupembassy
	reagents = list(WATER = 10, GUNKS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		/obj/item/toy/crayon/red,
		/obj/item/stack/sheet/cardboard
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gunksoupembassy

/datum/recipe/gunkbread
	reagents = list(FLOUR = 15, GUNKS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkbread

/datum/recipe/moongunkbread
	reagents = list(FLOUR = 15, GUNKS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkbread

/datum/recipe/gunkpieroach
	reagents = list(FLOUR = 5, GUNKS = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/roach)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/gunkpie

/datum/recipe/gunkpiecricket
	reagents = list(FLOUR = 5, GUNKS = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/cricket)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/gunkpie

/datum/recipe/gunkcake
	reagents = list(FLOUR = 15, GUNKS = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkcake

/datum/recipe/roachesonastick
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		/obj/item/weapon/reagent_containers/food/snacks/meat/roach,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/roachesonstick

/datum/recipe/sugarcube
	reagents = list(SODIUMCHLORIDE = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/saltcube
	cookable_with = COOKABLE_WITH_MIXING
	
/datum/recipe/saltcube
	reagents = list(SUGARS = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/multispawner/sugarcube
	cookable_with = COOKABLE_WITH_MIXING

/datum/recipe/trackingbacon
	reagents = list(CORNOIL = 10, SODIUMCHLORIDE = 5) //fried, salted, and not actually bacon
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/telebacon
