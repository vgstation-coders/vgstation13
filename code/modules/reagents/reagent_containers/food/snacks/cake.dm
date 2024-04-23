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

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/full
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/orange
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	reagents_to_add = list(NUTRIMENT = 20)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lime
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	reagents_to_add = list(NUTRIMENT = 20)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lemon
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	reagents_to_add = list(NUTRIMENT = 20)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	name = "lemon cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "lemoncake_slice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/chocolate
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	reagents_to_add = list(NUTRIMENT = 20)

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
