

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/nova
	name = "nova bread"
	desc = "Some plain old destabilizing star bread."
	icon_state = "novabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/nova
	reagents_to_add = list(NUTRIMENT = 6, HELL_RAMEN = 3, NOVAFLOUR = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	bitesize = 2
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/breadslice/nova
	name = "nova bread slice"
	desc = "A slice of Sol."
	icon_state = "novabreadslice"
	plate_icon = "novacustom"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/breadslice/paibread
	icon = 'icons/obj/food2.dmi'
	icon_state = "paitoast"
	trash = 0
	desc = "A slice of bread. Browned onto it is the image of a familiar friend."
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/breadslice/paibread/attackby(obj/item/I,mob/user,params)
	return ..() //sorry no custom pai sandwiches

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 30)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat/xeno
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat/xeno

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat/xeno
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat/spider
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat/spider

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat/spider
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	plate_offset_y = -5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat/synth
	name = "synthmeatbread loaf"
	desc = "A loaf of synthetic meatbread. You can just taste the mass-production."
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat/synth

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat/synth
	name = "synthmeatbread slice"
	desc = "A slice of synthetic meatbread."
	icon_state = "meatbreadslice"
	food_flags = FOOD_MEAT | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(BANANA = 20, NUTRIMENT = 20)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/tofu
	name = "tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 30)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	plate_offset_y = -5
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/creamcheese
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/creamcheese
	food_flags = FOOD_LACTOSE | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 20)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	food_flags = FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/pumpkin
	name = "Pumpkin Bread"
	desc = "A loaf of pumpkin bread."
	icon_state = "pumpkinbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/pumpkin
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 15)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/pumpkin
	name = "Pumpkin Bread slice"
	desc = "A slice of pumpkin bread."
	icon_state = "pumpkinbreadslice"
	plate_offset_y = 0

// sammiches, sandviches, etc

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/butteredtoast
	name = "buttered toast"
	desc = "Toasted bread with butter on it."
	icon_state = "butteredtoast"
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sandwich/jelly
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	food_flags = null
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sandwich/jelly/slime
	reagents_to_add = list(NUTRIMENT = 2, SLIMEJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/jelly/cherry
	reagents_to_add = list(NUTRIMENT = 2, CHERRYJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/toasted
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	reagents_to_add = list(NUTRIMENT = 6, CARBON = 2)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	reagents_to_add = list(NUTRIMENT = 7)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/polyp
	name = "Polypwich"
	desc = "Polyp meat and gelatin between two slices of bread makes for a nutritious sandwich. Unfortunately it has a soggy and unpleasant texture. These are commonly served to mothership prisoners who misbehave."
	icon_state = "polypwich"
	food_flags = FOOD_MEAT | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 10)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/polyp/after_consume(mob/user)
	if(prob(10))	//Eating this is just an unpleasant experience, so a player might get a negative flavor message. Has no effect besides rp value. I hope ayy wardens feed these to prisoners as a punishment :)
		to_chat(user, "<span class='warning'>The sandwich is soggy and tastes too salty to be appetizing...</span>")

/obj/item/weapon/reagent_containers/food/snacks/sandwich/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sandwich/jelliedtoast/cherry
	reagents_to_add = list(NUTRIMENT = 1, CHERRYJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/jelliedtoast/slime
	reagents_to_add = list(NUTRIMENT = 1, SLIMEJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/sandwich/avocadotoast
	name = "avocado toast"
	desc = "Salted avocado on a slice of toast. For the authentic experience, make sure you pay an exorbitant price for it."
	icon_state = "avocadotoast"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 3
