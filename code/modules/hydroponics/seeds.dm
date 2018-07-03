//Seed packet object/procs.
/obj/item/seeds
	name = "packet of seeds"
	icon = 'icons/obj/seeds.dmi'
	icon_state = "seed"
	flags = FPRINT
	w_class = W_CLASS_SMALL

	var/seed_type
	var/datum/seed/seed
	var/modified = 0
	var/hydroflags = 0 // HYDRO_*, used for no-fruit exclusion lists, at the moment.

/obj/item/seeds/New()
	while(!plant_controller)
		sleep(30)
	update_seed()
	..()
	pixel_x = rand(-3,3) * PIXEL_MULTIPLIER
	pixel_y = rand(-3,3) * PIXEL_MULTIPLIER

//Grabs the appropriate seed datum from the global list.
/obj/item/seeds/proc/update_seed()
	if(!seed && seed_type && !isnull(plant_controller.seeds) && plant_controller.seeds[seed_type])
		seed = plant_controller.seeds[seed_type]
	update_appearance()

//Updates strings and icon appropriately based on seed datum.
/obj/item/seeds/proc/update_appearance()
	if(!seed)
		return
	icon_state = seed.packet_icon
	src.name = "packet of [seed.seed_name] [seed.seed_noun]"
	src.desc = "It has a picture of [seed.display_name] on the front."

/obj/item/seeds/examine(mob/user)
	..()
	if(seed && !seed.roundstart)
		to_chat(user, "It's tagged as variety <span class='info'>#[seed.uid].</span>")
	else
		to_chat(user, "Plant Yield: <span class='info'>[(seed.yield != -1) ? seed.yield : "<span class='warning'> ERROR</span>"]</span>")
		to_chat(user, "Plant Potency: <span class='info'>[(seed.potency != -1) ? seed.potency : "<span class='warning'> ERROR</span>"]</span>")

/obj/item/seeds/cutting
	name = "cuttings"
	desc = "Some plant cuttings."

/obj/item/seeds/cutting/update_appearance()
	..()
	src.name = "packet of [seed.seed_name] cuttings"

/obj/item/seeds/random
	seed_type = null

/obj/item/seeds/random/New()
	seed = plant_controller.create_random_seed()
	seed_type = seed.name
	update_seed()

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
	name = "packet of plastellium seeds"
	seed_type = "plastic"

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

/obj/item/seeds/cabbageseed
	name = "packet of cabbage seeds"
	seed_type = "cabbage"
	vending_cat = "vegetables"

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

/obj/item/seeds/weeds
	name = "packet of weed seeds"
	seed_type = "weeds"
	vending_cat = "weeds"

/obj/item/seeds/harebell
	name = "packet of harebell seeds"
	seed_type = "harebells"
	vending_cat = "flowers"

/obj/item/seeds/sunflowerseed
	name = "packet of sunflower seeds"
	seed_type = "sunflowers"
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
	icon_state = "avocado_pit"

/obj/item/seeds/avocadoseed/whole/update_appearance()
	if(!seed)
		return
	icon_state = "avocado_pit"

// Chili plants/variants.
/datum/seed/chili

	name = "chili"
	seed_name = "chili"
	display_name = "chili plants"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/chili)
	chems = list(CAPSAICIN = list(3,5), NUTRIMENT = list(1,25))
	mutants = list("icechili", "ghostpepper")
	packet_icon = "seed-chili"
	plant_icon = "chili"
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
	seed_name = "ice pepper"
	display_name = "ice-pepper plants"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper)
	chems = list(FROSTOIL = list(3,5), NUTRIMENT = list(1,50))
	packet_icon = "seed-icepepper"
	plant_icon = "chiliice"

	maturation = 4
	production = 4

/datum/seed/chili/ghost
	name = "ghostpepper"
	seed_name = "ghostpepper"
	display_name = "ghost pepper plants"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper)
	chems = list(CONDENSEDCAPSAICIN = list(3,4), CURARE = list(0,40))
	packet_icon = "seed-ghostpepper"
	plant_icon = "chilighost"

	production = 3

// Berry plants/variants.
/datum/seed/berry
	name = "berries"
	seed_name = "berry"
	display_name = "berry bush"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	mutants = list("glowberries","poisonberries")
	packet_icon = "seed-berry"
	plant_icon = "berry"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	water_consumption = 6
	nutrient_consumption = 0.15

/datum/seed/berry/glow
	name = "glowberries"
	seed_name = "glowberry"
	display_name = "glowberry bush"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries)
	mutants = null
	packet_icon = "seed-glowberry"
	plant_icon = "glowberry"
	chems = list(NUTRIMENT = list(1,10), URANIUM = list(3,5))

	lifespan = 30
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	water_consumption = 3
	nutrient_consumption = 0.25
	biolum = 1
	biolum_colour = "#00ff00"

/datum/seed/berry/poison
	name = "poisonberries"
	seed_name = "poison berry"
	display_name = "poison berry bush"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries)
	mutants = list("deathberries")
	packet_icon = "seed-poisonberry"
	plant_icon = "poisonberry"
	chems = list(NUTRIMENT = list(1), SOLANINE = list(3,5))

/datum/seed/berry/poison/death
	name = "deathberries"
	seed_name = "death berry"
	display_name = "death berry bush"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries)
	packet_icon = "seed-deathberry"
	plant_icon = "deathberry"
	chems = list(NUTRIMENT = list(1), SOLANINE = list(3,3), CORIAMYRTIN = list(1,5))

	yield = 3
	potency = 50

// Nettles/variants.
/datum/seed/nettle
	name = "nettle"
	seed_name = "nettle"
	display_name = "nettles"
	products = list(/obj/item/weapon/grown/nettle)
	mutants = list("deathnettle")
	packet_icon = "seed-nettle"
	plant_icon = "nettle"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,50), FORMIC_ACID = list(0,1))
	lifespan = 30
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growth_stages = 5

/datum/seed/nettle/death
	name = "deathnettle"
	seed_name = "death nettle"
	display_name = "death nettles"
	products = list(/obj/item/weapon/grown/deathnettle)
	mutants = null
	packet_icon = "seed-deathnettle"
	plant_icon = "deathnettle"
	chems = list(NUTRIMENT = list(1,50), PHENOL = list(0,1))

	maturation = 8
	yield = 2

//Tomatoes/variants.
/datum/seed/tomato
	name = "tomato"
	seed_name = "tomato"
	display_name = "tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato)
	mutants = list("bluetomato","bloodtomato")
	packet_icon = "seed-tomato"
	plant_icon = "tomato"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	water_consumption = 6
	nutrient_consumption = 0.25
	ideal_light = 8
	ideal_heat = 298
	juicy = 1
	splat_type = /obj/effect/decal/cleanable/tomato_smudge

/datum/seed/tomato/blood
	name = "bloodtomato"
	seed_name = "blood tomato"
	display_name = "blood tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato)
	mutants = list("killertomato")
	packet_icon = "seed-bloodtomato"
	plant_icon = "bloodtomato"
	chems = list(NUTRIMENT = list(1,10), BLOOD = list(10,2))
	yield = 1
	splat_type = /obj/effect/decal/cleanable/blood/splatter

/datum/seed/tomato/killer
	name = "killertomato"
	seed_name = "killer tomato"
	display_name = "killer tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato)
	mutants = null
	packet_icon = "seed-killertomato"
	plant_icon = "killertomato"

	yield = 2
	growth_stages = 2
	juicy = 0

/datum/seed/tomato/blue
	name = "bluetomato"
	seed_name = "blue tomato"
	display_name = "blue tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato)
	mutants = list("bluespacetomato")
	packet_icon = "seed-bluetomato"
	plant_icon = "bluetomato"
	chems = list(NUTRIMENT = list(1,20), LUBE = list(1,5))
	splat_type = /obj/effect/decal/cleanable/blood/oil

/datum/seed/tomato/blue/teleport
	name = "bluespacetomato"
	seed_name = "bluespace tomato"
	display_name = "bluespace tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato)
	mutants = null
	packet_icon = "seed-bluespacetomato"
	plant_icon = "bluespacetomato"
	chems = list(NUTRIMENT = list(1,20), SINGULO = list(1,5))
	teleporting = 1

//Eggplants/varieties.
/datum/seed/eggplant
	name = "eggplant"
	seed_name = "eggplant"
	display_name = "eggplants"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant)
	mutants = list("realeggplant")
	packet_icon = "seed-eggplant"
	plant_icon = "eggplant"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 25
	maturation = 6
	production = 6
	yield = 2
	potency = 20
	ideal_light = 9
	ideal_heat = 298

/datum/seed/eggplant/eggs
	name = "realeggplant"
	seed_name = "egg-plant"
	display_name = "egg-plants"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	mutants = null
	packet_icon = "seed-eggy"
	plant_icon = "eggy"

	lifespan = 75
	production = 12

//Apples/varieties.

/datum/seed/apple
	name = "apple"
	seed_name = "apple"
	display_name = "apple tree"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	mutants = list("poisonapple","goldapple")
	packet_icon = "seed-apple"
	plant_icon = "apple"
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
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple)
	mutants = null
	packet_icon = "seed-goldapple"
	plant_icon = "goldapple"
	chems = list(NUTRIMENT = list(1,10), GOLD = list(1,5))

	maturation = 10
	production = 10
	yield = 3

//Ambrosia/varieties.
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris)
	mutants = list("ambrosiadeus")
	packet_icon = "seed-ambrosiavulgaris"
	plant_icon = "ambrosiavulgaris"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1), MESCALINE = list(1,8), TANNIC_ACID = list(1,8,1), OPIUM = list(1,10,1), SOLANINE = list(1,5))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	ideal_light = 8
	large = 0


/datum/seed/ambrosia/cruciatus
	name = "ambrosiacruciatus"
	seed_name = "ambrosia vulgaris"
	packet_icon = "seed-ambrosiavulgaris"
	plant_icon = "ambrosiavulgaris"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus)
	mutants = null
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	chems = list(NUTRIMENT = list(1), MESCALINE = list(1,8), TANNIC_ACID = list(1,8,1), OPIUM = list(1,10,1), SOLANINE = list(1,5), SPIRITBREAKER = list(10))


/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus)
	mutants = null
	packet_icon = "seed-ambrosiadeus"
	plant_icon = "ambrosiadeus"
	chems = list(NUTRIMENT = list(1), OPIUM = list(1,8), CYTISINE = list(1), COCAINE = list(1,10,1), MESCALINE = list(1,10))

//Mushrooms/varieties.
/datum/seed/mushroom
	name = "mushrooms"
	seed_name = "chanterelle"
	seed_noun = "spores"
	display_name = "chanterelle mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
	mutants = list("reishi","amanita","plumphelmet")
	packet_icon = "mycelium-chanter"
	plant_icon = "chanter"
	chems = list(NUTRIMENT = list(1,25))

	lifespan = 35
	maturation = 7
	production = 1
	yield = 5
	potency = 1
	growth_stages = 3
	water_consumption = 6
	light_tolerance = 6
	ideal_heat = 288

/datum/seed/mushroom/mold
	name = "mold"
	seed_name = "brown mold"
	display_name = "brown mold"
	products = null
	mutants = null
	//mutants = list("wallrot") //TBD.
	plant_icon = "mold"

	lifespan = 50
	maturation = 10
	yield = -1

/datum/seed/mushroom/plump
	name = "plumphelmet"
	seed_name = "plump helmet"
	display_name = "plump helmet mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	mutants = list("walkingmushroom","towercap")
	packet_icon = "mycelium-plump"
	plant_icon = "plump"
	chems = list(NUTRIMENT = list(2,10))

	lifespan = 25
	maturation = 8
	yield = 4
	potency = 0

/datum/seed/mushroom/hallucinogenic
	name = "reishi"
	seed_name = "reishi"
	display_name = "reishi"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi)
	mutants = list("libertycap","glowshroom")
	packet_icon = "mycelium-reishi"
	plant_icon = "reishi"
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
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap)
	mutants = null
	packet_icon = "mycelium-liberty"
	plant_icon = "liberty"
	chems = list(NUTRIMENT = list(1,50), PSILOCYBIN = list(3,5))

	lifespan = 25
	production = 1
	potency = 15
	growth_stages = 3

/datum/seed/mushroom/poison
	name = "amanita"
	seed_name = "fly amanita"
	display_name = "fly amanita mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita)
	mutants = list("destroyingangel","plastic")
	packet_icon = "mycelium-amanita"
	plant_icon = "amanita"
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
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel)
	packet_icon = "mycelium-angel"
	plant_icon = "angel"
	chems = list(NUTRIMENT = list(1,50), AMANATIN = list(1,3))

	maturation = 12
	yield = 2
	potency = 15

/datum/seed/mushroom/towercap
	name = "towercap"
	seed_name = "tower cap"
	display_name = "tower caps"
	mutants = null
	products = list(/obj/item/weapon/grown/log)
	packet_icon = "mycelium-tower"
	plant_icon = "towercap"

	lifespan = 80
	maturation = 15
	ligneous = 1

/datum/seed/mushroom/glowshroom
	name = "glowshroom"
	seed_name = "glowshroom"
	display_name = "glowshrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom)
	mutants = null
	packet_icon = "mycelium-glowshroom"
	plant_icon = "glowshroom"
	chems = list(RADIUM = list(1,20))

	lifespan = 120
	maturation = 15
	yield = 3
	potency = 30
	growth_stages = 4
	biolum = 1
	biolum_colour = "#006622"

/datum/seed/mushroom/walking
	name = "walkingmushroom"
	seed_name = "walking mushroom"
	display_name = "walking mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom)
	mutants = null
	packet_icon = "mycelium-walkingmushroom"
	plant_icon = "walkingmushroom"
	chems = list(NUTRIMENT = list(2,10))

	lifespan = 30
	maturation = 5
	yield = 1
	potency = 0
	growth_stages = 3

/datum/seed/mushroom/plastic
	name = "plastic"
	seed_name = "plastellium"
	display_name = "plastellium"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium)
	mutants = null
	packet_icon = "mycelium-plast"
	plant_icon = "plastellium"
	chems = list(PLASTICIDE = list(3,12))

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
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/harebell)
	packet_icon = "seed-harebell"
	plant_icon = "harebell"
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 100
	maturation = 7
	production = 1
	yield = 2
	growth_stages = 4
	nutrient_consumption = 0.15

/datum/seed/flower/poppy
	name = "poppies"
	seed_name = "poppy"
	display_name = "poppies"
	packet_icon = "seed-poppy"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/poppy)
	plant_icon = "poppy"
	chems = list(NUTRIMENT = list(1,20), OPIUM = list(1,10))

	lifespan = 25
	potency = 20
	maturation = 8
	production = 6
	yield = 6
	growth_stages = 3
	ideal_light = 8
	water_consumption = 0.5
	nutrient_consumption = 0.15

	large = 0

/datum/seed/flower/sunflower
	name = "sunflowers"
	seed_name = "sunflower"
	display_name = "sunflowers"
	packet_icon = "seed-sunflower"
	products = list(/obj/item/weapon/grown/sunflower)
	mutants = list("moonflowers","novaflowers")
	plant_icon = "sunflower"

	lifespan = 25
	maturation = 6
	growth_stages = 3
	ideal_light = 8
	water_consumption = 6
	nutrient_consumption = 0.15
	large = 0

/datum/seed/flower/sunflower/moonflower
	name = "moonflowers"
	seed_name = "moonflower"
	display_name = "moonflowers"
	packet_icon = "seed-moonflower"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower)
	mutants = null
	plant_icon = "moonflower"
	chems = list(NUTRIMENT = list(1), MOONSHINE = list(1,5))

	lifespan = 25
	maturation = 6
	growth_stages = 3
	potency = 30
	biolum = 1
	biolum_colour = "#B5ABDD"

	large = 0

/datum/seed/flower/sunflower/novaflower
	name = "novaflowers"
	seed_name = "novaflower"
	display_name = "novaflowers"
	packet_icon = "seed-novaflower"
	products = list(/obj/item/weapon/grown/novaflower)
	mutants = null
	plant_icon = "novaflower"
	chems = list(NUTRIMENT = list(1), CAPSAICIN = list(1,5))

	lifespan = 25
	maturation = 6
	growth_stages = 3
	potency = 30
	biolum = 1
	biolum_colour = "#FF9900"

	large = 0

//Grapes/varieties
/datum/seed/grapes
	name = "grapes"
	seed_name = "grape"
	display_name = "grapevines"
	packet_icon = "seed-grapes"
	mutants = list("greengrapes")
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes)
	plant_icon = "grape"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10), SUGAR = list(1,5))

	lifespan = 50
	maturation = 3
	production = 5
	growth_stages = 2
	yield = 4
	potency = 10
	ideal_light = 8
	nutrient_consumption = 0.15
	large = 0

/datum/seed/grapes/green
	name = "greengrapes"
	seed_name = "green grape"
	display_name = "green grapevines"
	packet_icon = "seed-greengrapes"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes)
	mutants = null
	plant_icon = "greengrape"
	chems = list(NUTRIMENT = list(1,10), TANNIC_ACID = list(3,5))

//Everything else
/datum/seed/peanuts
	name = "peanut"
	seed_name = "peanut"
	display_name = "peanut vines"
	packet_icon = "seed-peanut"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/peanut)
	plant_icon = "peanut"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 6
	potency = 10
	ideal_light = 8
/datum/seed/cabbage
	name = "cabbage"
	seed_name = "cabbage"
	display_name = "cabbages"
	packet_icon = "seed-cabbage"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage)
	plant_icon = "cabbage"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 1
	ideal_light = 8
	water_consumption = 6
	nutrient_consumption = 0.15

/datum/seed/shand
	name = "shand"
	seed_name = "S'randar's hand"
	display_name = "S'randar's hand leaves"
	packet_icon = "seed-shand"
	products = list(/obj/item/stack/medical/bruise_pack/tajaran)
	plant_icon = "shand"
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
	packet_icon = "seed-mtear"
	products = list(/obj/item/stack/medical/ointment/tajaran)
	plant_icon = "mtear"
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
	packet_icon = "seed-banana"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	plant_icon = "banana"
	harvest_repeat = 1
	chems = list(BANANA = list(1,10), POTASSIUMCARBONATE = list(0.1,30))
	mutants = list("bluespacebanana")

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	ideal_light = 9
	water_consumption = 6
	ideal_heat = 298

/datum/seed/banana/bluespace
	name = "bluespacebanana"
	seed_name = "bluespacebanana"
	display_name = "bluespace banana tree"
	packet_icon = "seed-bluespacebanana"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacebanana)
	plant_icon = "banana"
	mutants = null

/datum/seed/corn
	name = "corn"
	seed_name = "corn"
	display_name = "ears of corn"
	packet_icon = "seed-corn"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	plant_icon = "corn"
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 25
	maturation = 8
	production = 6
	yield = 3
	potency = 20
	growth_stages = 3
	ideal_light = 8
	water_consumption = 6
	ideal_heat = 298
	large = 0

/datum/seed/potato
	name = "potato"
	seed_name = "potato"
	display_name = "potatoes"
	packet_icon = "seed-potato"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	plant_icon = "potato"
	plant_icon = POTATO
	chems = list(NUTRIMENT = list(1,10))

	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	potency = 10
	growth_stages = 4
	water_consumption = 6

/datum/seed/soybean
	name = "soybean"
	seed_name = "soybean"
	display_name = "soybeans"
	packet_icon = "seed-soybean"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans)
	mutants = list("koibean")
	plant_icon = "soybean"
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
	packet_icon = "seed-koibean"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans)
	plant_icon = "soybean"
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
	packet_icon = "seed-wheat"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)
	plant_icon = "wheat"
	chems = list(NUTRIMENT = list(1,25))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	ideal_light = 8
	nutrient_consumption = 0.15

/datum/seed/rice
	name = "rice"
	seed_name = "rice"
	display_name = "rice stalks"
	packet_icon = "seed-rice"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk)
	plant_icon = "rice"
	chems = list(NUTRIMENT = list(1,25))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	growth_stages = 4
	water_consumption = 6
	nutrient_consumption = 0.15

/datum/seed/carrots
	name = "carrot"
	seed_name = "carrot"
	display_name = "carrots"
	packet_icon = "seed-carrot"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
	plant_icon = "carrot"
	chems = list(NUTRIMENT = list(1,20), ZEAXANTHIN = list(3,5))

	lifespan = 25
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	growth_stages = 3
	water_consumption = 6

/datum/seed/weeds
	name = "weeds"
	seed_name = "weed"
	display_name = "weeds"
	packet_icon = "seed-ambrosiavulgaris"
	plant_icon = "weeds"

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
	packet_icon = "seed-whitebeet"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet)
	plant_icon = "whitebeet"
	chems = list(NUTRIMENT = list(0,20), SUGAR = list(1,5))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 10
	water_consumption = 6

/datum/seed/sugarcane
	name = "sugarcane"
	seed_name = "sugarcane"
	display_name = "sugarcanes"
	packet_icon = "seed-sugarcane"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane)
	plant_icon = "sugarcane"
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
	packet_icon = "seed-watermelon"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon)
	plant_icon = "watermelon"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,6))

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 1
	water_consumption = 6
	ideal_heat = 298
	ideal_light = 8

/datum/seed/pumpkin
	name = "pumpkin"
	seed_name = "pumpkin"
	display_name = "pumpkin vine"
	packet_icon = "seed-pumpkin"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin)
	plant_icon = "pumpkin"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,6))

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	growth_stages = 3
	water_consumption = 6

/datum/seed/lime
	name = "lime"
	seed_name = "lime"
	display_name = "lime trees"
	packet_icon = "seed-lime"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lime)
	plant_icon = "lime"
	harvest_repeat = 1
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
	display_name = "lemon trees"
	packet_icon = "seed-lemon"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lemon)
	plant_icon = "lemon"
	harvest_repeat = 1
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
	display_name = "orange trees"
	packet_icon = "seed-orange"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/orange)
	plant_icon = "orange"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 5
	potency = 1

	large = 0

/datum/seed/grass
	name = "grass"
	seed_name = "grass"
	display_name = "grass"
	packet_icon = "seed-grass"
	products = list(/obj/item/stack/tile/grass)
	plant_icon = "grass"
	harvest_repeat = 1

	lifespan = 60
	maturation = 2
	production = 5
	yield = 5
	growth_stages = 2
	water_consumption = 0.5
	nutrient_consumption = 0.15

/datum/seed/cocoa
	name = "cocoa"
	seed_name = "cacao"
	display_name = "cacao tree"
	packet_icon = "seed-cocoapod"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod)
	plant_icon = "cocoapod"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10), COCO = list(4,5))

	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	growth_stages = 5
	water_consumption = 6
	ideal_heat = 298
	large = 0

/datum/seed/cherries
	name = "cherry"
	seed_name = "cherry"
	seed_noun = "pits"
	display_name = "cherry tree"
	packet_icon = "seed-cherry"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)
	plant_icon = "cherry"
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
	packet_icon = "seed-cinnamomum"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cinnamon)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "cinnamomum"
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
	packet_icon = "seed-kudzu"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod)
	plant_icon = "kudzu"
	chems = list(NUTRIMENT = list(1,50), ALLICIN = list(2,10))

	lifespan = 20
	maturation = 6
	production = 6
	yield = 4
	potency = 20
	growth_stages = 4
	spread = 2
	water_consumption = 0.5

/datum/seed/diona
	name = "diona"
	seed_name = "diona"
	seed_noun = "nodes"
	display_name = "diona nodes"
	packet_icon = "seed-dionanode"
	products = list(/mob/living/carbon/monkey/diona)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "dionanode"
	mob_drop = /obj/item/seeds/dionanode
	product_requires_player = 1
	immutable = 1

	lifespan = 50
	endurance = 35
	maturation = 5
	production = 10
	yield = 1
	potency = 30

/datum/seed/clown
	name = "clown"
	seed_name = "clown"
	seed_noun = "pods"
	display_name = "laughing clowns"
	packet_icon = "seed-replicapod"
	products = list(/mob/living/simple_animal/hostile/retaliate/clown)
	plant_icon = "replicapod"
	product_requires_player = 1

	lifespan = 100
	endurance = 8
	maturation = 1
	production = 1
	yield = 10
	potency = 30

/datum/seed/moshrum
	name = "moshrum"
	seed_name = "moshrum"
	seed_noun = "nodules"
	display_name = "moshrum nodes"
	packet_icon = "mycelium-walkingmushroom"
	plant_icon = "walkingmushroom"
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


/datum/seed/test
	name = "test"
	seed_name = "testing"
	seed_noun = "data"
	display_name = "runtimes"
	packet_icon = "seed-replicapod"
	products = list(/mob/living/simple_animal/cat/Runtime)
	plant_icon = "replicapod"

	nutrient_consumption = 0
	water_consumption = 0
	pest_tolerance = 11
	weed_tolerance = 11
	lifespan = 1000
	endurance = 100
	maturation = 1
	production = 1
	yield = 1
	potency = 1

/datum/seed/nofruit
	name = "nofruit"
	seed_name = "no-fruit"
	display_name = "no-fruit vine"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	packet_icon = "seed-nofruit"
	plant_icon = "nofruit"
	chems = list(NOTHING = list(1,20))
	immutable = 1

	lifespan = 30
	maturation = 5
	production = 5
	yield = 1
	potency = 10
	water_consumption = 6
	nutrient_consumption = 1
	growth_stages = 4

/datum/seed/avocado
	name = "avocado"
	seed_name = "avocado"
	display_name = "avocado tree"
	packet_icon = "seed-avocado"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/avocado)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "avocado"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,20))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 2
	potency = 10
	ideal_light = 8
	large = 0

// Vox Food

/datum/seed/mushroom/chicken
	name = "chickenshroom"
	seed_name = "chickenshroom"
	display_name = "chicken of the stars"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom)
	mutants = null
	packet_icon = "mycelium-chickenshroom"
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "chickenshroom"
	chems = list(NUTRIMENT = list(2,10))
	consume_gasses = list("nitrogen"=20) //Really likes its nitrogen. Planting on main station may mess with room air mix.

	lifespan = 30
	growth_stages = 3
	maturation = 4
	yield = 3
	potency = 0

/datum/seed/apple/wood
	name = "woodapple"
	seed_name = "woodapple"
	display_name = "woodapple tree"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple)
	packet_icon = "seed-woodapple"
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "woodapple"
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
	packet_icon = "seed-breadfruit"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "breadfruit"
	harvest_repeat = 1
	chems = list(FLOUR = list(2,10))

	potency = 30
	lifespan = 50
	maturation = 6
	growth_stages = 3
	production = 6
	yield = 3
	ideal_light = 9
	water_consumption = 6
	ideal_heat = 298

/datum/seed/garlic
	name = "garlic"
	seed_name = "garlic"
	display_name = "garlic"
	packet_icon = "seed-garlic"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/garlic)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "garlic"
	chems = list(HOLYWATER = list(1,25),NUTRIMENT = list(1,10), ALLICIN = list(5,10))

	potency = 15
	lifespan = 200
	maturation = 4
	growth_stages = 3
	production = 6
	yield = 4
	water_consumption = 2
	ideal_heat = 298

/datum/seed/pitcher
	name = "pitcher" //based on the slippery Nepenthes genus of pitcher plants
	seed_name = "pitcher"
	display_name = "pitcher plant" //because these are juicy 2, they automatically get renamed "slippery pitcher"
	packet_icon = "seed-pitcher"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "pitcher"
	chems = list(FORMIC_ACID = list(1,25))

	potency = 10
	lifespan = 50
	yield = 3
	growth_stages = 3
	maturation = 12
	production = 1
	water_consumption = 6
	ideal_heat = 310
	pest_tolerance = 10
	endurance = 25 //Fragile...
	carnivorous = 1 //Eats pests!
	juicy = 2 //And here's where the slipperiness comes in

/datum/seed/aloe
	name = "aloe"
	seed_name = "aloe"
	display_name = "aloe vera"
	packet_icon = "seed-aloe"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "aloe"
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
	packet_icon = "seed-vaporsac"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac)
	plant_dmi = 'icons/obj/hydroponics2.dmi'
	plant_icon = "vaporsac"
	chems = list(VAPORSALT = list(1,2))

	lifespan = 50
	maturation = 6
	production = 1
	yield = 1
	potency = 30
	growth_stages = 3
