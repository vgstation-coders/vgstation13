//Seed packet object/procs.
/obj/item/seeds
	name = "packet of seeds"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"
	flags = FPRINT
	w_class = W_CLASS_SMALL

	var/seed_type
	var/datum/seed/seed
	var/modified = 0
	var/hydroflags = 0 // HYDRO_*, used for no-fruit exclusion lists, at the moment.

/obj/item/seeds/New()
	..()
	pixel_x = rand(-3,3) * PIXEL_MULTIPLIER
	pixel_y = rand(-3,3) * PIXEL_MULTIPLIER
	if(ticker && ticker.current_state >= GAME_STATE_PLAYING)
		initialize()

/obj/item/seeds/initialize()
	..()
	update_seed()

//Grabs the appropriate seed datum from the global list.
/obj/item/seeds/proc/update_seed()
	if(!seed && seed_type && !isnull(SSplant.seeds) && SSplant.seeds[seed_type])
		seed = SSplant.seeds[seed_type]
	update_appearance()

//Updates strings and icon appropriately based on seed datum.
/obj/item/seeds/proc/update_appearance()
	if(!seed)
		return
	icon = seed.plant_dmi
	icon_state = "seed"
	src.name = "packet of [seed.seed_name] [seed.seed_noun]"
	src.desc = "It has a picture of [seed.display_name] on the front."

/obj/item/seeds/examine(mob/user)
	..()
	if(seed && !seed.roundstart)
		to_chat(user, "It's tagged as variety <span class='info'>#[seed.uid].</span>")
	else
		to_chat(user, "Plant Yield: <span class='info'>[(seed.yield != -1) ? seed.yield : "<span class='warning'> ERROR</span>"]</span>")
		to_chat(user, "Plant Potency: <span class='info'>[(seed.potency != -1) ? seed.potency : "<span class='warning'> ERROR</span>"]</span>")
	hydro_hud_scan(user, src)

/obj/item/seeds/random
	seed_type = null

/obj/item/seeds/random/initialize()
	seed = SSplant.create_random_seed()
	seed_type = seed.name
	..()

//the vegetable/fruit categories are made from a culinary standpoint. many of the "vegetables" in there are technically fruits. (tomatoes, pumpkins...)

/obj/item/seeds/dionanode
	name = "packet of diona nodes"
	seed_type = "diona"
	vending_cat = "sentient"

/obj/item/seeds/mushroommanspore
	name = "packet of mushrom spores"
	seed_type = "moshrum"
	vending_cat = "sentient"

/obj/item/seeds/poppyseed
	name = "packet of poppy seeds"
	seed_type = "poppies"
	vending_cat = "flowers"

/obj/item/seeds/chiliseed
	name = "packet of chili seeds"
	seed_type = "chili"
	vending_cat = "vegetables"

/obj/item/seeds/plastiseed
	name = "packet of plastellium spores"
	seed_type = "plastic"
	vending_cat = "mushrooms"

/obj/item/seeds/grapeseed
	name = "packet of grape seeds"
	seed_type = "grapes"
	vending_cat = "fruits"

/obj/item/seeds/greengrapeseed
	name = "packet of green grape seeds"
	seed_type = "greengrapes"
	vending_cat = "fruits"

/obj/item/seeds/peanutseed
	name = "packet of peanut seeds"
	seed_type = "peanut"

/obj/item/seeds/rocknut
	name = "packet of rocknut seeds"
	seed_type = "rocknut"

/obj/item/seeds/cabbageseed
	name = "packet of cabbage seeds"
	seed_type = "cabbage"
	vending_cat = "vegetables"

/obj/item/seeds/plasmacabbageseed
	name = "packet of plasma cabbage seeds"
	seed_type = "plasmacabbage"

/obj/item/seeds/shandseed
	name = "packet of S'randar's hand seeds"
	seed_type = "shand"

/obj/item/seeds/mtearseed
	name = "packet of Messa's tear seeds"
	seed_type = "mtear"

/obj/item/seeds/berryseed
	name = "packet of berry seeds"
	seed_type = "berries"
	vending_cat = "fruits"

/obj/item/seeds/glowberryseed
	name = "packet of glowberry seeds"
	seed_type = "glowberries"
	vending_cat = "fruits"

/obj/item/seeds/bananaseed
	name = "packet of banana seeds"
	seed_type = "banana"
	vending_cat = "fruits"

/obj/item/seeds/bluespacebananaseed
	name = "packet of bluespace banana seeds"
	seed_type = "bluespacebanana"
	vending_cat = "fruits"

/obj/item/seeds/eggplantseed
	name = "packet of eggplant seeds"
	seed_type = "eggplant"
	vending_cat = "vegetables"

/obj/item/seeds/eggyseed
	name = "packet of egg-plant seeds"
	seed_type = "realeggplant"

/obj/item/seeds/bloodtomatoseed
	name = "packet of blood tomato seeds"
	seed_type = "bloodtomato"
	vending_cat = "vegetables"

/obj/item/seeds/tomatoseed
	name = "packet of tomato seeds"
	seed_type = "tomato"
	vending_cat = "vegetables"

/obj/item/seeds/killertomatoseed
	name = "packet of killer tomato seeds"
	seed_type = "killertomato"
	vending_cat = "sentient"

/obj/item/seeds/bluetomatoseed
	name = "packet of bluetomato seeds"
	seed_type = "bluetomato"
	vending_cat = "vegetables"

/obj/item/seeds/bluespacetomatoseed
	name = "packet of bluespace tomato seeds"
	seed_type = "bluespacetomato"
	vending_cat = "vegetables"

/obj/item/seeds/cornseed
	name = "packet of corn seeds"
	seed_type = "corn"
	vending_cat = "vegetables"

/obj/item/seeds/potatoseed
	name = "packet of potato seeds"
	seed_type = "potato"
	vending_cat = "vegetables"

/obj/item/seeds/icepepperseed
	name = "packet of icechili seeds"
	seed_type = "icechili"
	vending_cat = "vegetables"

/obj/item/seeds/ghostpepperseed
	name = "packet of ghost pepper seeds"
	seed_type = "ghostpepper"
	vending_cat = "vegetables"

/obj/item/seeds/soyaseed
	name = "packet of soybean seeds"
	seed_type = "soybean"
	vending_cat = "vegetables"

/obj/item/seeds/koiseed
	name = "packet of koibean seeds"
	seed_type = "koibean"
	vending_cat = "vegetables"

/obj/item/seeds/wheatseed
	name = "packet of wheat seeds"
	seed_type = "wheat"
	vending_cat = "cereals"

/obj/item/seeds/riceseed
	name = "packet of rice seeds"
	seed_type = "rice"
	vending_cat = "cereals"

/obj/item/seeds/carrotseed
	name = "packet of carrot seeds"
	seed_type = "carrot"
	vending_cat = "vegetables"

/obj/item/seeds/diamondcarrotseed
	name = "packet of diamond carrot seeds"
	seed_type = "diamondcarrot"
	vending_cat = "vegetables"

/obj/item/seeds/reishimycelium
	name = "packet of reishi spores"
	seed_type = "reishi"
	vending_cat = "mushrooms"

/obj/item/seeds/amanitamycelium
	name = "packet of fly amanita spores"
	seed_type = "amanita"
	vending_cat = "mushrooms"

/obj/item/seeds/angelmycelium
	name = "packet of destroying angel spores"
	seed_type = "destroyingangel"
	vending_cat = "mushrooms"

/obj/item/seeds/libertymycelium
	name = "packet of liberty cap spores"
	seed_type = "libertycap"
	vending_cat = "mushrooms"

/obj/item/seeds/chantermycelium
	name = "packet of chanterelle spores"
	seed_type = "mushrooms"
	vending_cat = "mushrooms"

/obj/item/seeds/towermycelium
	name = "packet of tower cap spores"
	seed_type = "towercap"
	vending_cat = "trees"

/obj/item/seeds/glowshroom
	name = "packet of glowshroom spores"
	seed_type = "glowshroom"
	vending_cat = "mushrooms"

/obj/item/seeds/plumpmycelium
	name = "packet of plump helmet spores"
	seed_type = "plumphelmet"
	vending_cat = "mushrooms"

/obj/item/seeds/walkingmushroommycelium
	name = "packet of walking mushroom seeds"
	seed_type = "walkingmushroom"
	vending_cat = "sentient"

/obj/item/seeds/nettleseed
	name = "packet of nettle seeds"
	seed_type = "nettle"
	vending_cat = "weeds"

/obj/item/seeds/deathnettleseed
	name = "packet of death nettle seeds"
	seed_type = "deathnettle"
	vending_cat = "weeds"

/obj/item/seeds/dandelionseed
	name = "packet of dandelion seeds"
	seed_type = "dandelions"
	vending_cat = "weeds"

/obj/item/seeds/mockdelionseed
	name = "packet of dandelion(?) seeds"
	seed_type = "mockdelions"
	vending_cat = "weeds"

/obj/item/seeds/harebell
	name = "packet of harebell seeds"
	seed_type = "harebells"
	vending_cat = "flowers"

/obj/item/seeds/sunflowerseed
	name = "packet of sunflower seeds"
	seed_type = "sunflowers"
	vending_cat = "flowers"

/obj/item/seeds/mustardplantseed
	name = "packet of mustardplant seeds"
	seed_type = "mustardplants"
	vending_cat = "flowers"

/obj/item/seeds/moonflowerseed
	name = "packet of moonflower seeds"
	seed_type = "moonflowers"
	vending_cat = "flowers"

/obj/item/seeds/novaflowerseed
	name = "packet of novaflower seeds"
	seed_type = "novaflowers"
	vending_cat = "flowers"

/obj/item/seeds/brownmold
	name = "packet of brown mold spores"
	seed_type = "mold"
	vending_cat = "mushrooms"

/obj/item/seeds/appleseed
	name = "packet of apple seeds"
	seed_type = "apple"
	vending_cat = "fruits"

/obj/item/seeds/poisonedappleseed
	name = "packet of poisonapple seeds"
	seed_type = "poisonapple"
	vending_cat = "fruits"

/obj/item/seeds/goldappleseed
	name = "packet of golden apple seeds"
	seed_type = "goldapple"
	vending_cat = "fruits"

/obj/item/seeds/ambrosiavulgarisseed
	name = "packet of ambrosia vulgaris seeds"
	seed_type = "ambrosia"
	vending_cat = "weeds"

/obj/item/seeds/ambrosiacruciatusseed
	name = "packet of ambrosia vulgaris seeds"
	seed_type = "ambrosiacruciatus"
	vending_cat = "weeds"

/obj/item/seeds/ambrosiadeusseed
	name = "packet of ambrosia deus seeds"
	seed_type = "ambrosiadeus"
	vending_cat = "weeds"

/obj/item/seeds/whitebeetseed
	name = "packet of white-beet seeds"
	seed_type = "whitebeet"
	vending_cat = "vegetables"

/obj/item/seeds/sugarcaneseed
	name = "packet of sugarcane seeds"
	seed_type = "sugarcane"

/obj/item/seeds/watermelonseed
	name = "packet of watermelon seeds"
	seed_type = "watermelon"
	vending_cat = "fruits"

/obj/item/seeds/pumpkinseed
	name = "packet of pumpkin seeds"
	seed_type = "pumpkin"
	vending_cat = "vegetables"

/obj/item/seeds/squashseed
	name = "packet of slammed squash seeds"
	seed_type = "squash"
	vending_cat = "vegetables"

/obj/item/seeds/limeseed
	name = "packet of lime seeds"
	seed_type = "lime"
	vending_cat = "fruits"

/obj/item/seeds/lemonseed
	name = "packet of lemon seeds"
	seed_type = "lemon"
	vending_cat = "fruits"

/obj/item/seeds/orangeseed
	name = "packet of orange seeds"
	seed_type = "orange"
	vending_cat = "fruits"

/obj/item/seeds/silicatecitrus
	name = "packet of silicate citrus seeds"
	seed_type = "silicatecitrus"
	vending_cat = "fruits"

/obj/item/seeds/shardlime
	name = "packet of shardlime seeds"
	seed_type = "shardlime"

/obj/item/seeds/purpleshardlime
	name = "packet of purple shardlime seeds"
	seed_type = "purpleshardlime"

/obj/item/seeds/poisonberryseed
	name = "packet of poison berry seeds"
	seed_type = "poisonberries"

/obj/item/seeds/deathberryseed
	name = "packet of death berry seeds"
	seed_type = "deathberries"

/obj/item/seeds/grassseed
	name = "packet of grass seeds"
	seed_type = "grass"
	vending_cat = "weeds"

/obj/item/seeds/cocoapodseed
	name = "packet of cacao seeds"
	seed_type = "cocoa"

/obj/item/seeds/cherryseed
	name = "packet of cherry pits"
	seed_type = "cherry"
	vending_cat = "fruits"

/obj/item/seeds/kudzuseed
	name = "packet of kudzu seeds"
	seed_type = "kudzu"
	vending_cat = "weeds"

/obj/item/seeds/cinnamomum
	name = "packet of cinnamomum seeds"
	seed_type = "cinnamomum"
	vending_cat = "trees"

/obj/item/seeds/test
	name = "packet of testing data seed"
	seed_type = "test"
	vending_cat = "non-sentient"

/obj/item/seeds/clown
	name = "packet of clown pod seeds"
	seed_type = "clown"
	vending_cat = "non-sentient"

/obj/item/seeds/nofruitseed
	name = "packet of no-fruit seeds"
	seed_type = "nofruit"
	vending_cat = "fruits"

/obj/item/seeds/breadfruit
	name = "packet of breadfruit seeds"
	seed_type = "breadfruit"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/woodapple
	name = "packet of woodapple seeds"
	seed_type = "woodapple"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/chickenshroom
	name = "packet of chicken-of-the-stars spores"
	seed_type = "chickenshroom"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/garlic
	name = "packet of garlic growths"
	seed_type = "garlic"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/pitcher
	name = "tissue culture of slipping pitchers"
	seed_type = "pitcher"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/aloe
	name = "packet of aloe vera seeds"
	seed_type = "aloe"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/vaporsac
	name = "packet of vapor sac spores"
	seed_type = "vaporsac"
	vending_cat = "Vox hydroponics"
	hydroflags = HYDRO_VOX

/obj/item/seeds/avocadoseed
	name = "packet of avocado seeds"
	seed_type = "avocado"
	vending_cat = "fruits"

/obj/item/seeds/avocadoseed/whole
	name = "avocado seed"
	desc = "The pit of an avocado."
	seed_type = "avocado"
	vending_cat = "fruits"
	icon_state = "pit"

/obj/item/seeds/avocadoseed/whole/update_appearance()
	if(!seed)
		return
	icon = seed.plant_dmi
	icon_state = "pit"

/obj/item/seeds/pearseed
	name = "packet of pear seeds"
	seed_type = "pear"
	vending_cat = "fruits"

/obj/item/seeds/silverpearseed
	name = "packet of pear seeds"
	seed_type = "silverpear"
	vending_cat = "fruits"

/obj/item/seeds/cloverseed
	name = "packet of clover seeds"
	seed_type = "clover"
	vending_cat = "weeds"

/obj/item/seeds/flaxseed
	name = "packet of flax seeds"
	seed_type = "flax"

// Chili plants/variants.
/datum/seed/chili

	name = "chili"
	seed_name = "chili"
	display_name = "chili plants"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/chili.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/chili)
	chems = list(CAPSAICIN = list(3,5), NUTRIMENT = list(1,25))
	mutants = list("icechili", "ghostpepper")
	harvest_repeat = 1

	lifespan = 20
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	ideal_light = 9
	ideal_heat = 298

/datum/seed/chili/ice
	name = "icechili"
	seed_name = "chilly pepper"
	display_name = "chilly pepper plants"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/chiliice.dmi'
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper)
	chems = list(FROSTOIL = list(3,5), NUTRIMENT = list(1,50))

	maturation = 4
	production = 4

/datum/seed/chili/ghost
	name = "ghostpepper"
	seed_name = "ghostpepper"
	display_name = "ghost pepper plants"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/chilighost.dmi'
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper)
	chems = list(CONDENSEDCAPSAICIN = list(3,4), CURARE = list(0,40))

	production = 3

// Berry plants/variants.
/datum/seed/berry
	name = "berries"
	seed_name = "berry"
	display_name = "berry bush"
	plant_dmi = 'icons/obj/hydroponics/berry.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	mutants = list("glowberries","poisonberries")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	fluid_consumption = 6
	nutrient_consumption = 2

/datum/seed/berry/glow
	name = "glowberries"
	seed_name = "glowberry"
	display_name = "glowberry bush"
	plant_dmi = 'icons/obj/hydroponics/glowberry.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries)
	mutants = null
	chems = list(NUTRIMENT = list(1,10), URANIUM = list(3,5))

	lifespan = 30
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	fluid_consumption = 3
	nutrient_consumption = 3
	biolum = 1
	biolum_colour = "#00ff00"
	moody_lights = 1

/datum/seed/berry/poison
	name = "poisonberries"
	seed_name = "poison berry"
	display_name = "poison berry bush"
	plant_dmi = 'icons/obj/hydroponics/poisonberry.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries)
	mutants = list("deathberries")
	chems = list(NUTRIMENT = list(1), SOLANINE = list(3,5))

/datum/seed/berry/poison/death
	name = "deathberries"
	seed_name = "death berry"
	display_name = "death berry bush"
	plant_dmi = 'icons/obj/hydroponics/deathberry.dmi'
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries)
	chems = list(NUTRIMENT = list(1), SOLANINE = list(3,3), CORIAMYRTIN = list(1,5), CYTISINE = list(1,5))

	yield = 3
	potency = 50

// Nettles/variants.
/datum/seed/nettle
	name = "nettle"
	seed_name = "nettle"
	display_name = "nettles"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/nettle.dmi'
	products = list(/obj/item/weapon/grown/nettle)
	mutants = list("deathnettle")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,50), FORMIC_ACID = list(0,1))
	lifespan = 30
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growth_stages = 5
	constrained = 1

/datum/seed/nettle/death
	name = "deathnettle"
	seed_name = "death nettle"
	display_name = "death nettles"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/deathnettle.dmi'
	products = list(/obj/item/weapon/grown/deathnettle)
	mutants = null
	chems = list(NUTRIMENT = list(1,50), PHENOL = list(0,1))

	maturation = 8
	yield = 2
	constrained = 1

//Tomatoes/variants.
/datum/seed/tomato
	name = "tomato"
	seed_name = "tomato"
	display_name = "tomato plant"
	plant_dmi = 'icons/obj/hydroponics/tomato.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato)
	mutants = list("bluetomato","bloodtomato")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	fluid_consumption = 6
	nutrient_consumption = 3
	ideal_light = 8
	ideal_heat = 298
	juicy = 1
	splat_type = /obj/effect/decal/cleanable/tomato_smudge
	constrained = 1

/datum/seed/tomato/blood
	name = "bloodtomato"
	seed_name = "blood tomato"
	display_name = "blood tomato plant"
	plant_dmi = 'icons/obj/hydroponics/bloodtomato.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato)
	mutants = list("killertomato")
	chems = list(NUTRIMENT = list(1,10), BLOOD = list(10,2))
	yield = 1
	splat_type = /obj/effect/decal/cleanable/blood/splatter

/datum/seed/tomato/killer
	name = "killertomato"
	seed_name = "killer tomato"
	display_name = "killer tomato plant"
	plant_dmi = 'icons/obj/hydroponics/killertomato.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato)
	chems = list(NUTRIMENT = list(1,10), KILLERPHEROMONES = list(5,4))
	mutants = null

	yield = 2
	growth_stages = 2
	juicy = 0
	constrained = 0

/datum/seed/tomato/blue
	name = "bluetomato"
	seed_name = "blue tomato"
	display_name = "blue tomato plant"
	plant_dmi = 'icons/obj/hydroponics/bluetomato.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato)
	mutants = list("bluespacetomato")
	chems = list(NUTRIMENT = list(1,20), LUBE = list(1,5))
	splat_type = /obj/effect/decal/cleanable/blood/oil

/datum/seed/tomato/blue/teleport
	name = "bluespacetomato"
	seed_name = "bluespace tomato"
	display_name = "bluespace tomato plant"
	plant_dmi = 'icons/obj/hydroponics/bluespacetomato.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato)
	mutants = null
	chems = list(NUTRIMENT = list(1,20), SINGULO = list(1,5))
	teleporting = 1

//Eggplants/varieties.
/datum/seed/eggplant
	name = "eggplant"
	seed_name = "eggplant"
	display_name = "eggplants"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/eggplant.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant)
	mutants = list("realeggplant")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 25
	maturation = 6
	production = 6
	yield = 2
	potency = 20
	ideal_light = 9
	ideal_heat = 298
	constrained = 1

/datum/seed/eggplant/eggs
	name = "realeggplant"
	seed_name = "egg-plant"
	display_name = "egg-plants"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/eggy.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	mutants = null

	lifespan = 75
	production = 12

//Apples/varieties.

/datum/seed/apple
	name = "apple"
	seed_name = "apple"
	display_name = "apple tree"
	plant_dmi = 'icons/obj/hydroponics/apple.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	mutants = list("poisonapple","goldapple")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	ideal_light = 6
	large = 0

/datum/seed/apple/poison
	name = "poisonapple"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned)
	chems = list(CYANIDE = list(1,5))

/datum/seed/apple/gold
	name = "goldapple"
	seed_name = "golden apple"
	display_name = "gold apple tree"
	plant_dmi = 'icons/obj/hydroponics/goldapple.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple)
	mutants = null
	chems = list(NUTRIMENT = list(1,10), GOLD = list(1,5))

	maturation = 10
	production = 10
	yield = 3

//Ambrosia/varieties.
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	plant_dmi = 'icons/obj/hydroponics/ambrosiavulgaris.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris)
	mutants = list("ambrosiadeus")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1), MESCALINE = list(1,8), TANNIC_ACID = list(1,8,1), OPIUM = list(1,10,1))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	ideal_light = 8
	large = 0
	constrained = 1


/datum/seed/ambrosia/cruciatus
	name = "ambrosiacruciatus"
	seed_name = "ambrosia vulgaris"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus)
	mutants = null
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	chems = list(NUTRIMENT = list(1), MESCALINE = list(1,8), TANNIC_ACID = list(1,8,1), OPIUM = list(1,10,1), SPIRITBREAKER = list(1,10,1))


/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	plant_dmi = 'icons/obj/hydroponics/ambrosiadeus.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus)
	mutants = null
	chems = list(NUTRIMENT = list(1), PHYTOCARISOL = list(1,8), KATHALAI = list(1,8), COCAINE = list(1,10,1), MESCALINE = list(1,10))
	moody_lights = 1

//Mushrooms/varieties.
/datum/seed/mushroom
	name = "mushrooms"
	seed_name = "chanterelle"
	seed_noun = "spores"
	display_name = "chanterelle mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/chanter.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
	mutants = list("reishi","amanita","plumphelmet")
	chems = list(NUTRIMENT = list(1,25))

	lifespan = 35
	maturation = 7
	production = 1
	yield = 5
	potency = 1
	growth_stages = 3
	fluid_consumption = 6
	light_tolerance = 6
	ideal_heat = 288

/datum/seed/mushroom/mold
	name = "mold"
	seed_name = "brown mold"
	display_name = "brown mold"
	plant_dmi = 'icons/obj/hydroponics/mold.dmi'
	products = null
	mutants = null
	//mutants = list("wallrot") //TBD.

	lifespan = 50
	maturation = 10
	yield = -1

/datum/seed/mushroom/plump
	name = "plumphelmet"
	seed_name = "plump helmet"
	display_name = "plump helmet mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/plump.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	mutants = list("walkingmushroom","towercap")
	chems = list(NUTRIMENT = list(2,10))

	lifespan = 25
	maturation = 8
	yield = 4
	potency = 0
	constrained = 1

/datum/seed/mushroom/hallucinogenic
	name = "reishi"
	seed_name = "reishi"
	display_name = "reishi mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/reishi.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi)
	mutants = list("libertycap","glowshroom")
	chems = list(NUTRIMENT = list(1), VALERENIC_ACID = list(3,3), MESCALINE = list(1,25))

	maturation = 10
	production = 5
	yield = 4
	potency = 15
	growth_stages = 4

/datum/seed/mushroom/hallucinogenic/strong
	name = "libertycap"
	seed_name = "liberty cap"
	display_name = "liberty cap mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/liberty.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap)
	mutants = null
	chems = list(NUTRIMENT = list(1,50), PSILOCYBIN = list(3,5))

	lifespan = 25
	production = 1
	potency = 15
	growth_stages = 3

/datum/seed/mushroom/poison
	name = "amanita"
	seed_name = "fly amanita"
	display_name = "fly amanita mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/amanita.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita)
	mutants = list("destroyingangel","plastic")
	chems = list(NUTRIMENT = list(1), AMATOXIN = list(3,3), PSILOCYBIN = list(1,25))

	lifespan = 50
	maturation = 10
	production = 5
	yield = 4
	potency = 10

/datum/seed/mushroom/poison/death
	name = "destroyingangel"
	seed_name = "destroying angel"
	display_name = "destroying angel mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/angel.dmi'
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel)
	chems = list(NUTRIMENT = list(1,50), AMANITIN = list(1,3))

	maturation = 12
	yield = 2
	potency = 15

/datum/seed/mushroom/towercap
	name = "towercap"
	seed_name = "tower cap"
	display_name = "tower caps"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/towercap.dmi'
	mutants = null
	products = list(/obj/item/weapon/grown/log)

	lifespan = 80
	maturation = 15
	ligneous = 1

/datum/seed/mushroom/glowshroom
	name = "glowshroom"
	seed_name = "glowshroom"
	display_name = "glowshrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/glowshroom.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom)
	mutants = null
	chems = list(RADIUM = list(1,20))

	lifespan = 120
	maturation = 15
	yield = 3
	potency = 30
	growth_stages = 4
	biolum = 1
	biolum_colour = "#006622"
	moody_lights = 1

/datum/seed/mushroom/walking
	name = "walkingmushroom"
	seed_name = "walking mushroom"
	display_name = "walking mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/walkingmushroom.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom)
	mutants = null
	chems = list(NUTRIMENT = list(2,10))

	lifespan = 30
	maturation = 5
	yield = 1
	potency = 0
	growth_stages = 3

/datum/seed/mushroom/plastic
	name = "plastic"
	seed_name = "plastellium"
	display_name = "plastellium mushrooms"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/plastellium.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium)
	mutants = null
	chems = list(PLASTICIDE = list(0,1))

	lifespan = 15
	maturation = 5
	production = 6
	yield = 6
	potency = 20

//Flowers/varieties
/datum/seed/flower
	name = "harebells"
	seed_name = "harebell"
	display_name = "harebells"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/harebell.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/harebell)
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 100
	maturation = 7
	production = 1
	yield = 2
	growth_stages = 4
	nutrient_consumption = 2
	constrained = 1

/datum/seed/flower/poppy
	name = "poppies"
	seed_name = "poppy"
	display_name = "poppies"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/poppy.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/poppy)
	chems = list(NUTRIMENT = list(1,20), OPIUM = list(1,10))

	lifespan = 25
	potency = 20
	maturation = 8
	production = 6
	yield = 6
	growth_stages = 3
	ideal_light = 8
	fluid_consumption = 0.5
	nutrient_consumption = 2

	large = 0

/datum/seed/flower/sunflower
	name = "sunflowers"
	seed_name = "sunflower"
	display_name = "sunflowers"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/sunflower.dmi'
	products = list(/obj/item/weapon/grown/sunflower)
	mutants = list("moonflowers","novaflowers")

	lifespan = 25
	maturation = 6
	growth_stages = 3
	ideal_light = 8
	fluid_consumption = 6
	nutrient_consumption = 2
	large = 0

/datum/seed/flower/sunflower/moonflower
	name = "moonflowers"
	seed_name = "moonflower"
	display_name = "moonflowers"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/moonflower.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower)
	mutants = null
	chems = list(NUTRIMENT = list(1), MOONSHINE = list(1,5))

	lifespan = 25
	maturation = 6
	growth_stages = 3
	potency = 30
	biolum = 1
	biolum_colour = "#B5ABDD"
	moody_lights = 1

	large = 0

/datum/seed/flower/sunflower/novaflower
	name = "novaflowers"
	seed_name = "novaflower"
	display_name = "novaflowers"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/novaflower.dmi'
	products = list(/obj/item/weapon/grown/novaflower)
	mutants = null
	chems = list(NUTRIMENT = list(1), CAPSAICIN = list(1,5))

	lifespan = 25
	maturation = 6
	growth_stages = 3
	potency = 30
	biolum = 1
	biolum_colour = "#FF9900"
	moody_lights = 1

	large = 0

/datum/seed/flower/mustardplant //yes this is a real plant
	name = "mustardplants"
	seed_name = "mustardplant"
	display_name = "mustardplants"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/mustardplant.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mustardplant)
	chems = list(MUSTARD_POWDER = list(4,10))

	lifespan = 40 //real mustard plants live for like two months
	maturation = 6
	growth_stages = 3
	ideal_light = 8
	fluid_consumption = 6
	nutrient_consumption = 0 //these are a bunch of flowers, not an actual food
	large = 0

//Grapes/varieties
/datum/seed/grapes
	name = "grapes"
	seed_name = "grape"
	display_name = "grapevines"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/grape.dmi'
	mutants = list("greengrapes")
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10), SUGAR = list(1,5))

	lifespan = 50
	maturation = 3
	production = 5
	growth_stages = 2
	yield = 4
	potency = 10
	ideal_light = 8
	nutrient_consumption = 2
	large = 0

/datum/seed/grapes/green
	name = "greengrapes"
	seed_name = "green grape"
	display_name = "green grapevines"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/greengrape.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes)
	mutants = null
	chems = list(NUTRIMENT = list(1,10), TANNIC_ACID = list(3,5))

//Everything else
/datum/seed/peanuts
	name = "peanut"
	seed_name = "peanut"
	display_name = "peanut vines"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/peanut.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/peanut)
	mutants = list("rocknut")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 6
	potency = 10
	ideal_light = 8

/datum/seed/rocknut
	name = "rocknut"
	seed_name = "rocknut"
	display_name = "quarry bush"
	plant_dmi = 'icons/obj/hydroponics/rocknut.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/rocknut)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),IRON = list(3,5))

	lifespan = 70
	maturation = 6
	production = 6
	yield = 4
	potency = 10

/datum/seed/cabbage
	name = "cabbage"
	seed_name = "cabbage"
	display_name = "cabbages"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/cabbage.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage)
	mutants = list("plasmacabbage")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 1
	ideal_light = 8
	fluid_consumption = 6
	nutrient_consumption = 2

/datum/seed/plasmacabbage
	name = "plasmacabbage"
	seed_name = "plasma cabbage"
	display_name = "plasma cabbages"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/cabbageplasma.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/plasmacabbage)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),PLASMA = list(3,5))
	gas_absorb = 1
	consume_gasses = list(GAS_PLASMA = 10)

	lifespan = 30
	maturation = 3
	production = 6
	yield = 4
	potency = 10
	growth_stages = 1
	ideal_light = 8
	fluid_consumption = 6
	nutrient_consumption = 2

/datum/seed/shand
	name = "shand"
	seed_name = "S'randar's hand"
	display_name = "S'randar's hand leaves"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/shand.dmi'
	products = list(/obj/item/stack/medical/bruise_pack/tajaran)
	chems = list(OPIUM = list(0,10))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 3

/datum/seed/mtear
	name = "mtear"
	seed_name = "Messa's tear"
	display_name = "Messa's tear leaves"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/mtear.dmi'
	products = list(/obj/item/stack/medical/ointment/tajaran)
	chems = list(HONEY = list(1,10), TANNIC_ACID = list(3,5))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 3

/datum/seed/banana
	name = "banana"
	seed_name = "banana"
	display_name = "banana tree"
	plant_dmi = 'icons/obj/hydroponics/banana.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	harvest_repeat = 1
	chems = list(BANANA = list(1,10), POTASSIUMCARBONATE = list(0.1,30))
	mutants = list("bluespacebanana")

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	ideal_light = 9
	fluid_consumption = 6
	ideal_heat = 298

/datum/seed/banana/bluespace
	name = "bluespacebanana"
	seed_name = "bluespacebanana"
	display_name = "bluespace banana tree"
	plant_dmi = 'icons/obj/hydroponics/bluespacebanana.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacebanana)
	mutants = null
	chems = list(BANANA = list(1,10), HONKSERUM = list(1,10))

/datum/seed/corn
	name = "corn"
	seed_name = "corn"
	display_name = "ears of corn"
	plant_dmi = 'icons/obj/hydroponics/corn.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 25
	maturation = 8
	production = 6
	yield = 3
	potency = 20
	growth_stages = 3
	ideal_light = 8
	fluid_consumption = 6
	ideal_heat = 298
	large = 0

/datum/seed/potato
	name = "potato"
	seed_name = "potato"
	display_name = "potatoes"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/potato.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	potency = 10
	growth_stages = 4
	fluid_consumption = 6

/datum/seed/soybean
	name = "soybean"
	seed_name = "soybean"
	display_name = "soybeans"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/soybean.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans)
	mutants = list("koibean")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 25
	maturation = 4
	production = 4
	yield = 3
	potency = 5

/datum/seed/koiseed
	name = "koibean"
	seed_name = "koibean"
	display_name = "koibeans"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/koibean.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),CARPOTOXIN = list(1,25))

	lifespan = 25
	maturation = 4
	production = 4
	yield = 3
	potency = 10

/datum/seed/wheat
	name = "wheat"
	seed_name = "wheat"
	display_name = "wheat stalks"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/wheat.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)
	chems = list(NUTRIMENT = list(1,25))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	ideal_light = 8
	nutrient_consumption = 2

/datum/seed/rice
	name = "rice"
	seed_name = "rice"
	display_name = "rice stalks"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/rice.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk)
	chems = list(NUTRIMENT = list(1,25))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	growth_stages = 4
	fluid_consumption = 6
	nutrient_consumption = 2

/datum/seed/carrots
	name = "carrot"
	seed_name = "carrot"
	display_name = "carrots"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/carrot.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
	mutants = list("diamondcarrot")
	chems = list(NUTRIMENT = list(1,20), ZEAXANTHIN = list(3,5))

	lifespan = 25
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	growth_stages = 3
	fluid_consumption = 6
	visible_roots_in_hydro_tray = 1

/datum/seed/carrots/diamond
	name = "diamondcarrot"
	seed_name = "diamond carrot"
	display_name = "diamond carrots"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/diamondcarrot.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/diamond)
	mutants = null
	chems = list(NUTRIMENT = list(1,10), DIAMONDDUST = list(1,5))

	maturation = 10
	production = 10
	yield = 3

/datum/seed/dandelions
	name = "dandelions"
	seed_name = "dandelion"
	display_name = "dandelions"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/dandelions.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/dandelion)
	mutants = list("dandelions(?)")
	lifespan = 100
	harvest_repeat = 1
	chems = list(DYE_DANDELIONS = list(1,20))
	maturation = 5
	production = 3
	maturation_max = 2
	yield = 2
	potency = 10
	growth_stages = 5
	visible_roots_in_hydro_tray = 1

	products_per_maturation_level = list(
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/dandelion),
		list(/obj/item/weapon/grown/dandelion),
		)
	pollen = PS_DANDELIONS
	pollen_at_level = 2

/datum/seed/mockdelions
	name = "dandelions(?)"
	seed_name = "dandelion(?)"
	display_name = "dandelions(?)"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/dandelions_old.dmi'
	lifespan = 100
	maturation = 5
	production = 1
	yield = -1
	potency = -1
	growth_stages = 4
	immutable = -1

/datum/seed/whitebeets
	name = "whitebeet"
	seed_name = "white-beet"
	display_name = "white-beets"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/whitebeet.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet)
	chems = list(NUTRIMENT = list(0,20), SUGAR = list(1,5))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 10
	fluid_consumption = 6

/datum/seed/sugarcane
	name = "sugarcane"
	seed_name = "sugarcane"
	display_name = "sugarcanes"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/sugarcane.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane)
	harvest_repeat = 1
	chems = list(SUGAR = list(4,5))

	lifespan = 60
	maturation = 3
	production = 6
	yield = 4
	potency = 10
	growth_stages = 3
	ideal_heat = 298

/datum/seed/watermelon
	name = "watermelon"
	seed_name = "watermelon"
	display_name = "watermelon vine"
	plant_dmi = 'icons/obj/hydroponics/watermelon.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,6))

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	fluid_consumption = 6
	ideal_heat = 298
	ideal_light = 8

/datum/seed/pumpkin
	name = "pumpkin"
	seed_name = "pumpkin"
	display_name = "pumpkin vine"
	plant_dmi = 'icons/obj/hydroponics/pumpkin.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,6))
	mutants = list("squash")
	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	growth_stages = 3
	fluid_consumption = 6
	constrained = 1

/datum/seed/squash
	name = "squash"
	seed_name = "squash"
	display_name = "slammed squash vine"
	plant_dmi = 'icons/obj/hydroponics/squash.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/squash)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,12), SQUASH = list(1,6)) //half of the nutrients turn into SQUASH

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	growth_stages = 3
	fluid_consumption = 6
	constrained = 1

/datum/seed/lime
	name = "lime"
	seed_name = "lime"
	display_name = "lime tree"
	plant_dmi = 'icons/obj/hydroponics/lime.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lime)
	harvest_repeat = 1
	mutants = list("silicatecitrus")
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 4
	potency = 15

	large = 0

/datum/seed/lemon
	name = "lemon"
	seed_name = "lemon"
	display_name = "lemon tree"
	plant_dmi = 'icons/obj/hydroponics/lemon.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lemon)
	harvest_repeat = 1
	mutants = list("silicatecitrus")
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	ideal_light = 8
	large = 0

/datum/seed/orange
	name = "orange"
	seed_name = "orange"
	display_name = "orange tree"
	plant_dmi = 'icons/obj/hydroponics/orange.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/orange)
	harvest_repeat = 1
	mutants = list("silicatecitrus")
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 5
	potency = 1

	large = 0

/datum/seed/silicatecitrus
	name = "silicatecitrus"
	seed_name = "silicate citrus"
	display_name = "silicate citrus"
	plant_dmi = 'icons/obj/hydroponics/silicatecitrus.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/silicatecitrus)
	harvest_repeat = 1
	mutants = list("shardlime")
	chems = list(SILICATE = list(3,5))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 5

	large = 0

/datum/seed/shardlime
	name = "shardlime"
	seed_name = "shardlime"
	display_name = "shardlime"
	plant_dmi = 'icons/obj/hydroponics/shardlime.dmi'
	products = list(/obj/item/weapon/shard)
	mutants = list("purpleshardlime")
	harvest_repeat = 1

	lifespan = 70
	maturation = 4
	production = 5
	yield = 5
	biolum = 1
	biolum_colour = "#FFFFFF"
	thorny = 1
	moody_lights = 1

	large = 0

/datum/seed/purpleshardlime
	name = "purpleshardlime"
	seed_name = "purple shardlime"
	display_name = "purple shardlime"
	plant_dmi = 'icons/obj/hydroponics/purpleshardlime.dmi'
	products = list(/obj/item/weapon/shard/plasma)
	harvest_repeat = 1
	mutants = null

	lifespan = 70
	maturation = 4
	production = 5
	yield = 5
	biolum = 1
	biolum_colour = "#DBBEF0"
	thorny = 1
	moody_lights = 1

	large = 0

/datum/seed/grass
	name = "grass"
	seed_name = "grass"
	display_name = "grass"
	plant_dmi = 'icons/obj/hydroponics/grass.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grass)
	harvest_repeat = 1

	lifespan = 60
	maturation = 2
	production = 5
	yield = 5
	growth_stages = 2
	fluid_consumption = 0.5
	nutrient_consumption = 2

/datum/seed/cocoa
	name = "cocoa"
	seed_name = "cacao"
	display_name = "cacao tree"
	plant_dmi = 'icons/obj/hydroponics/cocoapod.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10), COCO = list(4,5))

	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	growth_stages = 5
	fluid_consumption = 6
	ideal_heat = 298
	large = 0

/datum/seed/cherries
	name = "cherry"
	seed_name = "cherry"
	seed_noun = "pits"
	display_name = "cherry tree"
	plant_dmi = 'icons/obj/hydroponics/cherry.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,15))

	lifespan = 35
	maturation = 5
	production = 5
	yield = 3
	potency = 10
	growth_stages = 5

	large = 0

/datum/seed/cinnamomum
	name = "cinnamomum"
	seed_name = "cinnamomum"
	display_name = "cinnamomum tree"
	plant_dmi = 'icons/obj/hydroponics/cinnamomum.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cinnamon)
	chems = list(CINNAMON = list(4,3))

	lifespan = 80
	maturation = 15
	production = 1
	yield = 4
	potency = 10
	growth_stages = 4
	ligneous = 1

	large = 0

/datum/seed/kudzu
	name = "kudzu"
	seed_name = "kudzu"
	display_name = "kudzu vines"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/kudzu.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod)
	chems = list(NUTRIMENT = list(1,50), ALLICIN = list(2,10))

	lifespan = 20
	maturation = 6
	production = 6
	yield = 4
	potency = 20
	growth_stages = 4
	spread = 2
	fluid_consumption = 0.5
	constrained = 1

/datum/seed/diona
	name = "diona"
	seed_name = "diona"
	seed_noun = "nodes"
	display_name = "diona node"
	plant_dmi = 'icons/obj/hydroponics/dionanode.dmi'
	products = list(/mob/living/carbon/monkey/diona)
	mob_drop = /obj/item/seeds/dionanode
	product_requires_player = 1
	product_kill_inactive = FALSE
	immutable = 1

	lifespan = 50
	endurance = 35
	maturation = 5
	production = 10
	yield = 1
	potency = 30
	constrained = 1

/datum/seed/clown
	name = "clown"
	seed_name = "clown"
	seed_noun = "pods"
	display_name = "laughing clowns"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/replicapod.dmi'
	products = list(/mob/living/simple_animal/hostile/retaliate/clown)
	product_requires_player = 1

	lifespan = 100
	endurance = 8
	maturation = 1
	production = 1
	yield = 10
	potency = 30
	constrained = 1

/datum/seed/moshrum
	name = "moshrum"
	seed_name = "moshrum"
	seed_noun = "nodules"
	display_name = "moshrum nodes"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/walkingmushroom.dmi'
	products = list(/mob/living/carbon/monkey/mushroom)
	mob_drop = /obj/item/seeds/mushroommanspore
	product_requires_player = TRUE
	product_kill_inactive = FALSE
	immutable = TRUE

	lifespan = 50
	endurance = 35
	maturation = 5
	production = 10
	yield = 2
	potency = 30
	ideal_light = 0
	constrained = 1

/datum/seed/nofruit
	name = "nofruit"
	seed_name = "no-fruit"
	display_name = "no-fruit vine"
	plant_dmi = 'icons/obj/hydroponics/nofruit.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit)
	chems = list(NOTHING = list(1,20))
	immutable = 1

	lifespan = 30
	maturation = 5
	production = 5
	yield = 1
	potency = 10
	fluid_consumption = 6
	nutrient_consumption = 10
	growth_stages = 4

/datum/seed/avocado
	name = "avocado"
	seed_name = "avocado"
	display_name = "avocado tree"
	plant_dmi = 'icons/obj/hydroponics/avocado.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/avocado)
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 2
	potency = 10
	ideal_light = 8
	large = 0


/datum/seed/pear
	name = "pear"
	seed_name = "pear"
	display_name = "pear tree"
	plant_dmi = 'icons/obj/hydroponics/pear.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pear)
	mutants = list("silverpear")
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	ideal_light = 6
	large = 0

/datum/seed/pear/silver
	name = "silverpear"
	seed_name = "silver pear"
	display_name = "silver pear tree"
	plant_dmi = 'icons/obj/hydroponics/silverpear.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/silverpear)
	mutants = null
	chems = list(NUTRIMENT = list(1,10), SILVER = list(1,5))

	maturation = 10
	production = 10
	yield = 3

// Vox Food

/datum/seed/mushroom/chicken
	name = "chickenshroom"
	seed_name = "chickenshroom"
	display_name = "chicken of the stars"
	plant_dmi = 'icons/obj/hydroponics/chickenshroom.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom)
	mutants = null
	chems = list(NUTRIMENT = list(2,10))
	consume_gasses = list(GAS_NITROGEN = 20) //Really likes its nitrogen. Planting on main station may mess with room air mix.

	lifespan = 30
	growth_stages = 3
	maturation = 4
	yield = 3
	potency = 0

/datum/seed/apple/wood
	name = "woodapple"
	seed_name = "woodapple"
	display_name = "woodapple tree"
	plant_dmi = 'icons/obj/hydroponics/woodapple.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple)
	chems = list(SUGAR = list(1,10))

	growth_stages = 3
	maturation = 4
	yield = 4
	potency = 20
	ligneous = 1

/datum/seed/breadfruit
	name = "breadfruit"
	seed_name = "breadfruit"
	display_name = "breadfruit tree"
	plant_dmi = 'icons/obj/hydroponics/breadfruit.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit)
	harvest_repeat = 1
	chems = list(FLOUR = list(2,10))

	potency = 30
	lifespan = 50
	maturation = 6
	growth_stages = 3
	production = 6
	yield = 3
	ideal_light = 9
	fluid_consumption = 6
	ideal_heat = 298

/datum/seed/garlic
	name = "garlic"
	seed_name = "garlic"
	display_name = "garlic"
	plant_dmi = 'icons/obj/hydroponics/garlic.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/garlic)
	chems = list(HOLYWATER = list(1,25),NUTRIMENT = list(1,10), ALLICIN = list(5,10))

	potency = 15
	lifespan = 200
	maturation = 4
	growth_stages = 3
	production = 6
	yield = 4
	fluid_consumption = 2
	ideal_heat = 298

/datum/seed/pitcher
	name = "pitcher" //based on the slippery Nepenthes genus of pitcher plants
	seed_name = "pitcher"
	display_name = "pitcher plant" //because these are juicy 2, they automatically get renamed "slippery pitcher"
	plant_dmi = 'icons/obj/hydroponics/pitcher.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher)
	chems = list(FORMIC_ACID = list(1,25))

	potency = 10
	lifespan = 50
	yield = 3
	growth_stages = 3
	maturation = 12
	production = 1
	fluid_consumption = 6
	ideal_heat = 310
	pest_tolerance = 100
	endurance = 25 //Fragile...
	voracious = 1 //Eats pests!
	juicy = 2 //And here's where the slipperiness comes in
	constrained = 1

/datum/seed/aloe
	name = "aloe"
	seed_name = "aloe"
	display_name = "aloe vera"
	plant_dmi = 'icons/obj/hydroponics/aloe.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	chems = list(KATHALAI = list(1,10)) //Not as good as poppy's opium for speedy heals, but general purpose.

	lifespan = 30
	maturation = 6
	production = 6
	yield = 4
	potency = 20
	growth_stages = 3
	ideal_heat = 310
	thorny = 1

/datum/seed/vaporsac
	name = "vaporsac"
	seed_name = "vaporsac"
	display_name = "vapor sac"
	plant_dmi = 'icons/obj/hydroponics/vaporsac.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac)
	chems = list(VAPORSALT = list(1,2))

	lifespan = 50
	maturation = 6
	production = 1
	yield = 1
	potency = 30
	growth_stages = 3

/datum/seed/clover
	name = "clover"
	seed_name = "clover"
	display_name = "clover"
	plant_dmi = 'icons/obj/hydroponics/clover.dmi'
	plant_icon_state = "clover"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/clover)
	chems = list(NUTRIMENT = list(1,25))
	harvest_repeat = 1
	lifespan = 60
	maturation = 2
	production = 5
	yield = 5
	growth_stages = 2
	fluid_consumption = 0.5
	nutrient_consumption = 0.15

/datum/seed/flax
	name = "flax"
	seed_name = "flax"
	display_name = "flax stalks"
	plural = 1
	plant_dmi = 'icons/obj/hydroponics/flax.dmi'
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/flax)
	chems = list(FLAXOIL = list(6,5))
	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	ideal_light = 8
	nutrient_consumption = 2
	constrained = 1
