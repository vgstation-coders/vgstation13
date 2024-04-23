
/obj/item/weapon/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/burger/on_vending_machine_spawn()//Fast-Food Menu
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/burger/synth
	name = "synthetic burger"
	desc = "It tastes like a normal burger, but it's just not the same."

/obj/item/weapon/reagent_containers/food/snacks/burger/brain
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	reagents_to_add = list(NUTRIMENT = 6, ALKYSINE = 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/ghost
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/burger/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."

/obj/item/weapon/reagent_containers/food/snacks/burger/fish
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/tofu
	name = "tofu burger"
	desc = "What... is that meat?"
	icon_state = "tofuburger"
	food_flags = null

/obj/item/weapon/reagent_containers/food/snacks/burger/chicken
	name = "chicken burger"
	desc = "Tastes like chi... oh wait!"
	icon_state = "mc_chicken"

/obj/item/weapon/reagent_containers/food/snacks/burger/veggie
	name = "veggie burger"
	desc = "Technically vegetarian."
	icon_state = "veggieburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/veggie/nymph // Alternate recipe using nymph meat

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	reagents_to_add = list(NANITES = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger/big
	desc = "This massive patty looks like poison. Beep."
	reagents_to_add = NANITES
	bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/burger/xeno
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/burger/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	food_flags = null
	reagents_to_add = list(NUTRIMENT = 6, HONKSERUM = 6)
	//reagents.add_reagent(BLOOD, 4, list("viruses"= list(new /datum/disease/pierrot_throat(0))))

/obj/item/weapon/reagent_containers/food/snacks/burger/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	food_flags = null
	reagents_to_add = list(NUTRIMENT = 6, SILENCER = 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/donut
	name = "donut burger"
	desc = "Illegal to have out on code green."
	icon_state = "donutburger"
	reagents_to_add = list(NUTRIMENT = 6, SPRINKLES = 6)
	base_crumb_chance = 30

/obj/item/weapon/reagent_containers/food/snacks/burger/avocado
	name = "avocado burger"
	desc = "Blurring the line between ingredient and condiment."
	icon_state = "avocadoburger"
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/burger/caramel
	name = "caramel burger"
	desc = "Too sweet to be any good."
	icon_state = "caramelburger"
	food_flags = FOOD_MEAT | FOOD_SWEET
	reagents_to_add = list(NUTRIMENT = 8, CARAMEL = 4)

/obj/item/weapon/reagent_containers/food/snacks/burger/bear
	name = "bear burger"
	desc = "Fits perfectly in any pic-a-nic basket. Oh bothering to grizzle into this won't be a boo-boo. Honey, it would be beary foolish to hibernate on such a unbearably, ursa majorly good treat!"
	icon_state = "bearburger"
	reagents_to_add = list(NUTRIMENT = 20, HYPERZINE = 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/burger/glass
	name = "glass burger"
	desc = "Goes down surprisingly easily considering the ingredients."
	icon_state = "glassburger"
	food_flags = null
	filling_color = "#92CEE9"
	reagents_to_add = list(NUTRIMENT = 6, DIAMONDDUST = 4) //It's the closest we have to eating raw glass, causes some brute and screaming

/obj/item/weapon/reagent_containers/food/snacks/burger/polyp
	name = "polyp burger"
	desc = "Millions of burgers like these are cooked and sold by McZargalds every year."
	icon_state = "polypburger"
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/burger/blob
	name = "bloburger"
	desc = "Careful, has a tendency to spill sauce in every direction when squeezed too hard."
	icon_state = "blobburger"
	reagents_to_add = list(NUTRIMENT = 8, BLOBANINE = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/burger/blob/consume(mob/living/carbon/eater, messages = 0, sounds = TRUE, bitesizemod = 1)
	if(prob(50))
		src.crumb_icon = "dribbles"
	else
		src.crumb_icon = "crumbs"
	..()

/obj/item/weapon/reagent_containers/food/snacks/burger/spell
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	food_flags = null
	base_crumb_chance = 10
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/bigbite
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	reagents_to_add = list(NUTRIMENT = 14)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/bigbite/on_vending_machine_spawn()//Fast-Food Menu XL
	reagents.chem_temp = COOKTEMP_READY
