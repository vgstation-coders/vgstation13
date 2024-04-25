//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/weapon/reagent_containers/food/snacks/burger/xeno			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	food_flags = FOOD_MEAT												//For flavour, not that important. Flags are: FOOD_MEAT, FOOD_ANIMAL (for things that vegans don't eat), FOOD_SWEET, FOOD_LIQUID (soups). You can have multiple flags in here by doing this: food_flags = FOOD_MEAT | FOOD_SWEET
//	reagents_to_add = list(XENOMICROBES = 10, NUTRIMENT = 2)			//This is what is in the food item.
//	bitesize = 3														//This is the amount each bite consumes.

/obj/item/weapon/reagent_containers/food/snacks/organ
	name		=	"organ"
	desc		=	"It's good for you."
	icon		=	'icons/obj/surgery.dmi'
	icon_state	=	"appendix"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/organ/New()
	reagents_to_add = list(NUTRIMENT = rand(3,5), TOXIN = rand(1,3))
	..()

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 4, CARPPHEROMONES = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3, PSILOCYBIN = 3)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice/mushroom_man/set_reagents_to_add()
	reagents_to_add = list(NUTRIMENT = 3, PSILOCYBIN = 3, TRICORDRAZINE = rand(1,5))

/obj/item/weapon/reagent_containers/food/snacks/meat/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 6
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	sactype = /obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 2, TOXIN = 2)

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/faggot/processed
	reagents_to_add = null

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/sausage/New()
	..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	food_flags = FOOD_MEAT | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 4)
	var/warm = 0

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/process()
	if(warm <= 0)
		warm = 0
		name = initial(name)
		reagents.del_reagent(TRICORDRAZINE)
		processing_objects.Remove(src)
		return

	warm--

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/Destroy()
	processing_objects.Remove(src)

	..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/proc/warm_up()
	warm = 80
	reagents.add_reagent(TRICORDRAZINE, 5)
	bitesize = 6
	name = "warm [name]"
	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating
	name = "self-heating Donk-pocket"
	icon_state = "donkpocket_wrapped"
	desc = "Individually wrapped, frozen, unfrozen, desiccated, resiccated, twice recalled, and still edible. Infamously so."
	wrapped = TRUE
	var/unwrapping = FALSE

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating/proc/Unwrap(mob/user)
	if(unwrapping)
		return
	playsound(src, 'sound/misc/donkselfheat.ogg', 35, 0, -4)
	to_chat(user, "<span class='notice'>Following the instructions, you shake the packaging firmly and rip it open with an unsatisfying wet crunch.</span>")
	unwrapping = TRUE
	spawn(2 SECONDS)
		name = "\improper Donk-pocket"
		desc = "Freshly warmed and probably not toxic."
		icon_state = "donkpocket"
		reagents.add_reagent(CALCIUMOXIDE, 0.2)
		warm_up()
		wrapped = 0
		unwrapping = FALSE

/obj/item/weapon/reagent_containers/food/snacks/human
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/blobpudding
	name = "blob à l'impératrice"
	desc = "An extremely thick \"pudding\" that requires a tough jaw."
	icon_state = "blobpudding"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 8, BLOBANINE = 5)

/obj/item/weapon/reagent_containers/food/snacks/blobsoup
	name = "blobisque"
	desc = "A thick, creamy soup containing a spongy surprise with a tough bite."
	icon_state = "blobsoup"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 15, BLOBANINE = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	food_flags = FOOD_SWEET
	reagents_to_add = list(NUTRIMENT = 4, BERRYJUICE = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles!"
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 3, CAPSAICIN = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#EFE5D4"
	valid_utensils = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/New()
		..()
		eatverb = pick("bite","crunch","nibble","gnaw","gobble","chomp")
		unpopped = rand(1,10)

/obj/item/weapon/reagent_containers/food/snacks/popcorn/after_consume()
	if(prob(unpopped))	//lol ...what's the point? << AINT SO POINTLESS NO MORE
		to_chat(usr, "<span class='warning'>You bite down on an un-popped kernel, and it hurts your teeth!</span>")
		unpopped = max(0, unpopped-1)
		reagents.add_reagent(SACID, 0.1) //only a little tingle.

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -5
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/butter
	name = "butter"
	desc = "Today we feast."
	icon_state = "butter"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(LIQUIDBUTTER = 10)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/butter/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.Slip(4, 3, slipped_on = src))
			new/obj/effect/decal/cleanable/smashed_butter(src.loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/pancake
	name = "pancake"
	desc = "You'll never guess what's for breakfast!"
	icon_state = "pancake"
	food_flags = FOOD_ANIMAL
	var/pancakes = 1
	var/max_pancakes = 10 // leaving badmins a way to raise it if they're ready to assume the consequences
	base_crumb_chance = 1
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pancake/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/pancake))
		var/obj/item/weapon/reagent_containers/food/snacks/pancake/I = O
		if (pancakes + I.pancakes > max_pancakes)
			to_chat(user, "<span class='warning'>sorry, can't go any higher!</span>")
			return
		to_chat(user, "<span class='notice'>...and another one!</span>")
		var/amount = I.reagents.total_volume
		I.reagents.trans_to(src, amount)
		var/image/img = image(I.icon, src, I.icon_state)
		img.appearance = I.appearance
		img.pixel_x = 0
		img.pixel_y = 2 * pancakes
		img.plane = FLOAT_PLANE
		img.layer = FLOAT_LAYER
		extra_food_overlay.overlays += img
		overlays += img
		pancakes += I.pancakes
		qdel(I)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	reagents_to_add = list(TOXIN = 1, CARBON = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4, SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth
	name = "Synthmeat steak"
	desc = "It's still a delicious steak, but it has no soul."
	icon_state = "meatsteak"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/beacon/bacon/baconbeacon
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/telebacon/New()
	..()
	baconbeacon = new /obj/item/beacon/bacon(src)

/obj/item/weapon/reagent_containers/food/snacks/telebacon/after_consume()
	if(!reagents.total_volume)
		baconbeacon.forceMove(usr)
		baconbeacon.digest_delay()
*/

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, CAPSAICIN = 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 10, BANANA = 5, BLACKPEPPER = 1, SODIUMCHLORIDE = 1)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/crab_sticks
	name = "\improper Not-Actually-Imitation Crab sticks"
	desc = "Made from actual crab meat."
	icon_state = "crab_sticks"
	food_flags = FOOD_MEAT
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 4, SUGAR = 1, SODIUMCHLORIDE = 1)
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/crabcake
	name = "Crab Cake"
	desc = "A New Space England favorite!"
	icon_state = "crabcake"
	food_flags = FOOD_MEAT
	bitesize = 2
	base_crumb_chance = 3
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE //eggs, can be dipped
	reagents_to_add = list(NUTRIMENT = 8, PSILOCYBIN = 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	filling_color = "#EB7C28"
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 10, TOMATOJUICE = 5, IMIDAZOLINE = 5, WATER = 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/stew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "A large, soft, all-twisted-up pretzel full of POP!"
	icon_state = "poppypretzel"
	food_flags = FOOD_DIPPABLE
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 5)

/*
/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	base_crumb_chance = 0
	reagents_to_add = list(SLIMEJELLY = 5)
	bitesize = 3
*/

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/New()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents_to_add = list(NUTRIMENT = 8, TRICORDRAZINE = 5)
	..()

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 1)

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	filling_color = "#982424"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 3, KETCHUP = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsandwich"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, ICE = list("volume" = 2,"temp" = T0C))
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	food_flags = FOOD_MEAT
	plate_offset_y = -5
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"
	food_flags = FOOD_ANIMAL //eggs are eggs
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, TOXIN = 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	food_flags = FOOD_MEAT | FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, SODIUMCHLORIDE = 1)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon = 'icons/obj/food_custom.dmi'
	icon_state = "cereal_box"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	icon = 'icons/obj/food_custom.dmi'
	icon_state = "deepfried_holder_icon"
	bitesize = 2
	deepfried = 1

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/New()
	..()
	if(deepFriedNutriment)
		reagents.add_reagent(NUTRIMENT,deepFriedNutriment)

///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	food_flags = FOOD_ANIMAL //eggs
	reagents_to_add = list(NUTRIMENT = 3)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else
		..()

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	storage_slots = 2
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL //eggs
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "burger bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 4)

//////////////////CHICKEN//////////////////

/obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets
	name = "Chicken Nuggets"
	desc = "You'd rather not know how they were prepared."
	icon_state = "kfc_nuggets"
	item_state = "kfc_bucket"
	trash = /obj/item/trash/chicken_bucket
	food_flags = FOOD_MEAT
	filling_color = "#D8753E"
	base_crumb_chance = 3
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick
	name = "chicken drumstick"
	desc = "We can fry further..."
	icon_state = "chicken_drumstick"
	food_flags = FOOD_MEAT
	filling_color = "#D8753E"
	base_crumb_chance = 0
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/chicken_tenders
	name = "Chicken Tenders"
	desc = "A very special meal for a very good boy."
	icon_state = "tendies"
	food_flags = FOOD_MEAT
	base_crumb_chance = 3
	bitesize = 2
	reagents_to_add = list(CORNOIL = 3, TENDIES = 3)

/obj/item/weapon/reagent_containers/food/snacks/flan
	name = "Flan"
	desc = "A small crème caramel."
	icon_state = "flan"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	filling_color = "#FFEC4D"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/honeyflan
	name = "Honey Flan"
	desc = "The systematic slavery of an entire society of insects, elegantly sized to fit in your mouth."
	icon_state = "honeyflan"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, CINNAMON = 5, HONEY = 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/corndog
	name = "Corndog"
	desc = "Battered hotdog on a stick!"
	icon_state = "corndog"
	food_flags = FOOD_MEAT | FOOD_ANIMAL //eggs
	base_crumb_chance = 1
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/cornydog
	name = "CORNY DOG"
	desc = "This is just ridiculous."
	icon_state = "cornydog"
	trash = /obj/item/stack/rods  //no fun allowed
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 15)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/coleslaw
	name = "Coleslaw"
	desc = "You fought the 'slaw, and the 'slaw won."
	icon_state = "coleslaw"
	plate_offset_y = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/potentham
	name = "potent ham"
	desc = "I'm sorry Dave, but I'm afraid I can't let you eat that."
	icon_state = "potentham"
	volume = 1
	base_crumb_chance = 0
	reagents_to_add = list(HAMSERUM = 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eucharist
	name = "\improper Eucharist Wafer"
	icon_state = "eucharist"
	desc = "For the kingdom, the power, and the glory are yours, now and forever."
	bitesize = 5
	base_crumb_chance = 0
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(HOLYWATER = 5)

/obj/item/weapon/reagent_containers/food/snacks/frog_leg
	name = "frog leg"
	desc = "A thick, delicious legionnaire frog leg, its taste and texture resemble chicken."
	icon_state = "frog_leg"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/reclaimed
	name = "reclaimed nutrition cube"
	desc = "This food represents a highly efficient use of station resources. The Corporate AI's favorite!"
	icon_state = "monkeycubewrap"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/threebeanburrito
	name = "three bean burrito"
	desc = "Beans, beans a magical fruit."
	icon_state = "danburrito"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/midnightsnack
	name = "midnight snack"
	desc = "Perfect for those occasions when engineering doesn't set up power."
	icon_state = "midnightsnack"
	bitesize = 2
	trash = /obj/item/trash/snack_bowl
	random_filling_colors = list("#0683FF","#00CC28","#FF8306","#8600C6","#306900","#9F5F2D")
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/midnightsnack/New()
	..()
	set_light(2)

/obj/item/weapon/reagent_containers/food/snacks/honeycitruschicken
	name = "honey citrus chicken"
	desc = "The strong, tangy flavor of the orange and soy sauce highlights the smooth, thick taste of the honey. This fusion dish is one of the highlights of Terran cuisine."
	icon_state = "honeycitruschicken"
	bitesize = 4
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, HONEY = 4, SUGAR = 4)

/obj/item/weapon/reagent_containers/food/snacks/pimiento
	name = "pimiento"
	desc = "A vital component in the caviar of the South."
	icon_state = "pimiento"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(SUGAR = 1)

/obj/item/weapon/reagent_containers/food/snacks/confederatespirit
	name = "confederate spirit"
	desc = "Even in space, where a north/south orientation is meaningless, the South will rise again."
	icon_state = "confederatespirit"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme
	name = "fish taco supreme"
	desc = "There may be more fish in the sea, but there's only one kind of fish in the stars."
	icon_state = "fishtacosupreme"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 1
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/chiliconcarne
	name = "chili con carne"
	desc = "This dish became exceedingly rare after Space Texas seceeded from our plane of reality."
	icon_state = "chiliconcarne"
	bitesize = 3
	food_flags = FOOD_LIQUID | FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, CAPSAICIN = 2)

/obj/item/weapon/reagent_containers/food/snacks/cloverconcarne
	name = "clover con carne"
	desc = "Hearty, yet delightfully refreshing. The savory taste of the steak is complemented by the herbal je ne sais quoi of the clover."
	icon_state = "cloverconcarne"
	bitesize = 3
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/poissoncru
	name = "poisson cru"
	desc = "The national dish of Tonga, a country that you had previously never heard about."
	icon_state = "poissoncru"
	bitesize = 2
	plate_offset_y = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/bleachkipper
	name = "bleach kipper"
	desc = "Baby blue and very fishy."
	icon_state = "bleachkipper"
	food_flags = FOOD_MEAT
	volume = 1
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(FISHBLEACH = 1)

/obj/item/weapon/reagent_containers/food/snacks/magbites
	name = "mag-bites"
	desc = "Tiny boot-shaped cheese puffs. Made with real magnets!\
	<br>Warning: not suitable for those with heart conditions or on medication, consult your doctor before consuming this product. Cheese dust may stain or dissolve fabrics."
	icon_state = "magbites"
	reagents_to_add = list(MEDCORES = 6, SODIUMCHLORIDE = 6, NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/tontesdepelouse/
	name = "tontes de pelouse"
	desc = "A fashionable dish that some critics say engages the aesthetic sensibilities of even the most refined gastronome."
	icon_state = "tontesdepelouse"
	bitesize = 3
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/butterstick
	name = "butter on a stick"
	desc = "The clown told you to make this."
	icon_state = "butter_stick"
	bitesize = 3
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/butterstick/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.Slip(4, 3, slipped_on = src))
			new/obj/effect/decal/cleanable/smashed_butter(src.loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l
	name = "butter fingers"
	desc = "It's a microwaved hand slathered in butter!"
	icon_state = "butterfingers_l"
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	plate_offset_y = -3
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		C.Slip(4, 3, slipped_on = src)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/r
	icon_state = "butterfingers_r"

/obj/item/weapon/reagent_containers/food/snacks/pickledpears
	name = "pickled pears"
	desc = "A jar filled with pickled pears."
	icon_state = "pickledpears"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/pickledbeets
	name = "pickled beets"
	desc = "A jar of pickled whitebeets. How did they become so red, then?"
	icon_state = "pickledbeets"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bulgogi
	name = "bulgogi"
	desc = "Thin grilled beef marinated with grated pear juice."
	icon_state = "bulgogi"
	food_flags = FOOD_SWEET | FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/bakedpears
	name = "baked pears"
	desc = "Baked pears cooked with cinnamon, sugar and some cream."
	icon_state = "bakedpears"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/winepear
	name = "wine pear"
	desc = "This pear has been laced with wine, some cinnamon and a touch of cream."
	icon_state = "winepear"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grapejelly
	name = "jelly"
	desc = "The choice of choosy moms."
	icon = 'icons/obj/food2.dmi'
	icon_state = "grapejelly"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/peanutbutter
	name = "peanut butter"
	desc = "A jar of smashed peanuts, contains no actual butter."
	icon = 'icons/obj/food2.dmi'
	icon_state = "peanutbutter"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/saltednuts
	name = "salted peanuts"
	desc = "Popular in saloons."
	icon = 'icons/obj/food2.dmi'
	icon_state = "saltednuts"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, SODIUMCHLORIDE = 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/pbj
	name = "peanut butter and jelly sandwich"
	desc = "A classic treat of childhood."
	icon = 'icons/obj/food2.dmi'
	icon_state = "pbj"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sweetroll
	name = "sweetroll"
	desc = "While on the station, the chef gives you a sweetroll. Delighted, you take it into maintenance to enjoy, only to be intercepted by a gang of three assistants your age."
	icon = 'icons/obj/food.dmi'
	icon_state = "sweetroll"
	food_flags = FOOD_ANIMAL | FOOD_SWEET | FOOD_LACTOSE | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/dorfbiscuit
	name = "special plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. Aside from the usual ingredients of minced plump helmet and well-minced dwarven wheat flour, this particular serving includes a chemical that sticks whoever eats it to the floor, much like magboots."
	icon_state = "phelmbiscuit"
	bitesize = 1
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(SOFTCORES = 3, NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "Diona Roast"
	desc = "A slow cooked diona nymph. Very nutritious, and surprisingly tasty!"
	icon_state = "dionaroast"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, BLACKPEPPER = 1, SODIUMCHLORIDE = 1, CORNOIL = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps
	name = "half-eaten cheese wedge"
	desc = "Looks like someone already got to this one, but there's still quite a bit of cheese left."
	icon_state = "halfeaten_wedge"
	filling_color = "#FFCC33"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/popcorn/cricket
	name = "hopcorn"
	desc = "Surprisingly crunchy!"
	icon_state = "hoppers"
	trash = /obj/item/trash/popcorn/hoppers
	filling_color = "#610000"

/obj/item/weapon/reagent_containers/food/snacks/popcorn/cricket/after_consume()
	if(prob(unpopped))
		to_chat(usr, "<span class='warning'>Just as you were going to bite down on the cricket, it jumps away from your hand. It was alive!</span>")
		unpopped = max(0, unpopped-3) //max 3 crickets per bag
		new /mob/living/simple_animal/cricket(get_turf(src))

/obj/item/weapon/reagent_containers/food/snacks/popcorn/roachsalad
	name = "cockroach salad"
	desc = "You're gonna be sick..."
	icon_state = "cockroachsalad"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT
	random_filling_colors = list("#610000", "#32AE32")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/roachsalad/after_consume()
	if(prob(unpopped))
		to_chat(usr, "<span class='warning'>A cockroach wriggles out of the bowl!</span>")
		unpopped = max(0, unpopped-3) //max 3 roaches per roach salad
		new /mob/living/simple_animal/cockroach(get_turf(src))

/obj/item/weapon/reagent_containers/food/snacks/roachesonstick
	name = "Roaches on a stick"
	desc = "Literally two roaches a stick, man. Don't know what you were expecting."
	icon_state = "roachesonastick"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5, ROACHSHELL = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/saltcube
	name = "salt cubes"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/saltcube
	child_volume = 3
	reagents_to_add = list(SODIUMCHLORIDE = 15) //spawns 5

/obj/item/weapon/reagent_containers/food/snacks/saltcube
	name = "salt cubes"
	desc = "You wish you had a salt rhombicosidodecahedron, but a cube will do."
	icon_state = "sugarsaltcube"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sugarcube
	name = "sugar cube"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sugarcube
	child_volume = 3
	reagents_to_add = list(SUGAR = 15) //spawns 5

/obj/item/weapon/reagent_containers/food/snacks/sugarcube
	name = "sugar cube"
	desc = "The superior sugar delivery method. How will sugar sphere babies ever compare?"
	icon_state = "sugarsaltcube"
	bitesize = 3
