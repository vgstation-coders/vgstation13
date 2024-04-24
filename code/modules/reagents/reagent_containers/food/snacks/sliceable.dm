/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

// sliceable is just an organization type path, it doesn't have any additional code or variables tied to it.

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delicious cheddar."
	icon_state = "cheesewheel"
	filling_color = "#FFCC33"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFCC33"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	bitesize = 2
	food_flags = FOOD_SWEET

//////////////////CHRISTMAS AND WINTER FOOD//////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel
	name = "\improper Buche de Noel"
	desc = "Merry Christmas."
	icon_state = "buche"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bucheslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/tray
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //eggs
	reagents_to_add = list(NUTRIMENT = 20, SUGAR = 9, COCO = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bucheslice
	name = "\improper Buche de Noel slice"
	desc = "A slice of winter magic."
	icon_state = "buche_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey
	name = "turkey"
	desc = "Tastes like chicken."
	icon_state = "turkey"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	slices_num = 2
	storage_slots = 2
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 20, BLACKPEPPER = 1, SODIUMCHLORIDE = 1, CORNOIL = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	name = "turkey drumstick"
	desc = "Guaranteed vox-free!"
	icon_state = "turkey_drumstick"
	bitesize = 2
	food_flags = FOOD_MEAT
	plate_offset_y = -1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter
	name = "suppermatter"
	desc = "Extremely dense and powerful food."
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/suppermattershard
	storage_slots = 1
	slices_num = 4
	icon_state = "suppermatter"
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 48)
	bitesize = 12

/obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter/New()
	..()
	set_light(1.4,2,"#FFFF00")

/obj/item/weapon/reagent_containers/food/snacks/suppermattershard
	name = "suppermatter shard"
	desc = "A single portion of power."
	icon_state = "suppermattershard"
	bitesize = 3
	trash = null
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/suppermattershard/New()
	..()
	set_light(1.4,1.4,"#FFFF00")

/obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter/exciting
	name = "exciting suppermatter"
	desc = "Extremely dense, powerful and exciting food!"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/suppermattershard/exciting
	slices_num = 5
	icon_state = "excitingsuppermatter"
	reagents_to_add = list(NUTRIMENT = 60)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter/exciting/New()
	..()
	set_light(1.4,2,"#FF0000")

/obj/item/weapon/reagent_containers/food/snacks/suppermattershard/exciting
	name = "exciting suppermatter shard"
	desc = "A single portion of exciting power!"
	icon_state = "excitingsuppermattershard"

/obj/item/weapon/reagent_containers/food/snacks/suppermattershard/exciting/New()
	..()
	set_light(1.4,1.4,"#FF0000")
