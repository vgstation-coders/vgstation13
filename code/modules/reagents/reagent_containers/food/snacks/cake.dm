/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //milk and eggs
	reagents_to_add = list(NUTRIMENT = 20)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/carrot
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	reagents_to_add = list(NUTRIMENT = 25, IMIDAZOLINE = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	name = "carrot cake slice"
	desc = "Carrotty slice of carrot cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	reagents_to_add = list(NUTRIMENT = 5, IMIDAZOLINE = 2)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/brain
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	reagents_to_add = list(NUTRIMENT = 25, ALKYSINE = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	plate_offset_y = 0
	reagents_to_add = list(NUTRIMENT = 5, ALKYSINE = 2)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/cheese
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	reagents_to_add = list(NUTRIMENT = 25)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	name = "cheese cake slice"
	desc = "A slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	plate_offset_y = 0
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/orange
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lime
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lemon
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	name = "lemon cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "lemoncake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/chocolate
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	name = "chocolate cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "chocolatecake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/caramel
	name = "caramel cake"
	desc = "A cake with added caramel."
	icon_state = "caramelcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/caramel
	reagents_to_add = list(NUTRIMENT = 15, CARAMEL = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/caramel
	name = "caramel cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "caramelcake_slice"
	reagents_to_add = list(NUTRIMENT = 3, CARAMEL = 1)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/birthday
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	candles_state = CANDLES_UNLIT
	always_candles = "birthdaycake"
	reagents_to_add = list(NUTRIMENT = 20, SPRINKLES = 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	name = "Birthday Cake slice"
	desc = "A slice of your birthday!"
	icon_state = "birthdaycakeslice"
	plate_icon = "bluecustom"
	candles_state = CANDLES_UNLIT
	always_candles = "birthdaycakeslice"
	plate_offset_y = 0
	reagents_to_add = list(NUTRIMENT = 4, SPRINKLES = 2)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/apple
	name = "apple cake"
	desc = "A cake centred with apple."
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	reagents_to_add = list(NUTRIMENT = 15)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/chococherry
	name = "chocolate-cherry cake"
	desc = "A chocolate cake with icing and cherries."
	icon_state = "chococherrycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/chococherry

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/chococherry
	name = "chocolate-cherry cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "chococherrycake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/fruit
	name = "fruitcake"
	desc = "A hefty fruitcake that could double as a hammer in a pinch."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "fruitcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/fruit
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/fruit
	name = "fruitcake slice"
	desc = "Delicious and fruity."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "fruitcakeslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/fruit/christmas
	name = "\improper Christmas cake"
	desc = "A hefty fruitcake covered in royal icing."
	icon_state = "christmascake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/fruit/christmas
	reagents_to_add = list(NUTRIMENT = 10)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/fruit/christmas
	name = "\improper Christmas cake slice"
	desc = "Sweet and fruity."
	icon_state = "christmascakeslice"
	reagents_to_add = list(NUTRIMENT = 2)
