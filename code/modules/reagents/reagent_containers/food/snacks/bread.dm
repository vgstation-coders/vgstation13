
/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM
	reagents_to_add = list(NUTRIMENT = 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM
	reagents_to_add = list(NUTRIMENT = 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 30) //If the meat is toxic, it will inherit that
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth
	name = "synthmeatbread loaf"
	desc = "A loaf of synthetic meatbread. You can just taste the mass-production."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice/synth
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice/synth
	name = "synthmeatbread slice"
	desc = "A slice of synthetic meatbread."
	icon_state = "meatbreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(BANANA = 20, NUTRIMENT = 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread
	name = "tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM
	reagents_to_add = list(NUTRIMENT = 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	bitesize = 2
	plate_offset_y = -5
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/nova
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_LACTOSE | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	bitesize = 2
	food_flags = FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread
	name = "Pumpkin Bread"
	desc = "A loaf of pumpkin bread."
	icon_state = "pumpkinbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinbreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	reagents_to_add = list(NUTRIMENT = 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinbreadslice
	name = "Pumpkin Bread slice"
	desc = "A slice of pumpkin bread."
	icon_state = "pumpkinbreadslice"
	bitesize = 2
	food_flags = FOOD_DIPPABLE

// sammiches, sandviches, etc

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	reagents_to_add = list(NUTRIMENT = 2, SLIMEJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	reagents_to_add = list(NUTRIMENT = 2, CHERRYJELLY = 5)

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

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL //This is made from a sandwich, which contains meat!
	reagents_to_add = list(NUTRIMENT = 6, CARBON = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 7)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/polypwich
	name = "Polypwich"
	desc = "Polyp meat and gelatin between two slices of bread makes for a nutritious sandwich. Unfortunately it has a soggy and unpleasant texture. These are commonly served to mothership prisoners who misbehave."
	icon_state = "polypwich"
	food_flags = FOOD_MEAT | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/polypwich/after_consume(mob/user)
	if(prob(10))	//Eating this is just an unpleasant experience, so a player might get a negative flavor message. Has no effect besides rp value. I hope ayy wardens feed these to prisoners as a punishment :)
		to_chat(user, "<span class='warning'>The sandwich is soggy and tastes too salty to be appetizing...</span>")

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry
	reagents_to_add = list(NUTRIMENT = 1, CHERRYJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime
	reagents_to_add = list(NUTRIMENT = 1, SLIMEJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/avocadotoast
	name = "avocado toast"
	desc = "Salted avocado on a slice of toast. For the authentic experience, make sure you pay an exorbitant price for it."
	icon_state = "avocadotoast"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 3
