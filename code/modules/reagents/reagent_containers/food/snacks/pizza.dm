/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6
	storage_slots = 4
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FREEZER

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The most cheesy pizza in galaxy!"
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	storage_slots = 4
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	reagents_to_add = list(NUTRIMENT = 40, TOMATOJUICE = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	name = "Margherita slice"
	desc = "A slice of the most cheesy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice/rocket
	name = "Margherita slice"
	desc = "A slice of the most cheesy pizza in galaxy. Seems covered in gunpowder."
	icon_state = "pizzamargheritaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 47, TOMATOJUICE = 7)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "Meatpizza"
	desc = "A filling pizza laden with meat, perfect for the manliest of carnivores."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE //It has cheese!
	reagents_to_add = list(NUTRIMENT = 50, TOMATOJUICE = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	name = "Meatpizza slice"
	desc = "A slice of pizza, packed with delicious meat."
	icon_state = "meatpizzaslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth
	name = "Synthmeatpizza"
	desc = "A synthetic pizza laden with artificial meat, perfect for the stingiest of chefs."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice/synth
	w_class = W_CLASS_MEDIUM
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice/synth
	name = "Synthmeatpizza slice"
	desc = "A slice of pizza, packed with synthetic meat."
	icon_state = "meatpizzaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 35)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	name = "Mushroompizza slice"
	desc = "Maybe it's the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "Vegetable pizza"
	desc = "No one of Tomatos Sapiens was harmed during the making of this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 30, TOMATOJUICE = 6, IMIDAZOLINE = 12)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/blingpizza
	name = "Blingpizza"
	desc = "A pizza made with the most expensive ingredients this side of the galaxy. You feel filthy rich just by looking at it."
	icon_state = "blingpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/blingpizzaslice
	w_class = W_CLASS_MEDIUM
	//the novaflour turns into hellramen like in novabread
	reagents_to_add = list(NUTRIMENT = 50, HELL_RAMEN = 3, GOLD = 3, SILVER = 3, DIAMONDDUST = 3, TRICORDRAZINE = 8) //ambrosia's medical chems replacement
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/blingpizzaslice
	name = "Blingpizza slice"
	desc = "A slice of filthy rich blingpizza. How did you afford it?"
	icon_state = "blingpizzaslice"
	bitesize = 2

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food_container.dmi'
	icon_state = "pizzabox1"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/return_air()//keeping your pizza warms
	return

/obj/item/pizzabox/on_vending_machine_spawn()//well, it's from the supply shuttle rather but hey
	if (pizza)
		pizza.on_vending_machine_spawn()
		pizza.update_icon()

/obj/item/pizzabox/update_icon()

	overlays.Cut()

	// Set appropriate description
	if( open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if( boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if( toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if( boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if( open )
		if( ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if(pizza)
			pizza.link_particles(src)
			var/image/pizzaimg = new()
			pizzaimg.appearance = pizza.appearance
			pizzaimg.pixel_y = -3 * PIXEL_MULTIPLIER
			pizzaimg.pixel_x = 0
			pizzaimg.plane = FLOAT_PLANE
			pizzaimg.layer = FLOAT_LAYER
			overlays += pizzaimg

		return
	else
		// Stupid code because byondcode sucks
		remove_particles()
		var/doimgtag = 0
		if( boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if( boxtag != "" )
				doimgtag = 1

		if( doimgtag )
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3 * PIXEL_MULTIPLIER
			overlays += tagimg

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user as mob )

	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, "<span class='notice'>You take the [src.pizza] out of the [src].</span>")
		src.pizza = null
		remove_particles()
		update_icon()
		return

	if( boxes.len > 0 )
		if( user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, "<span class='warning'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user as mob )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I as obj, mob/user as mob )
	if( istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if( !box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if( (boxes.len+1) + boxestoadd.len <= 5 )
				if(user.drop_item(I, src))

					box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
					src.boxes.Add( boxestoadd )

					box.update_icon()
					update_icon()

					to_chat(user, "<span class='notice'>You put the [box] ontop of the [src]!</span>")

			else
				to_chat(user, "<span class='warning'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='warning'>Close the [box] first!</span>")

		return

	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/)||istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable/pizza/)) // Long ass fucking object name
		if(src.pizza)
			to_chat(user, "<span class='warning'>[src] already has a pizza in it.</span>")
		else if(src.open)
			if(user.drop_item(I, src))
				src.pizza = I
				src.update_icon()
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='warning'>Open [src] first.</span>")

		return

	if( istype(I, /obj/item/weapon/pen/) )

		if( src.open )
			return

		var/t = copytext(sanitize(input("Enter what you want to add to the tag:", "Write", null, null) as text|null), 1, MAX_MESSAGE_LEN)
		if (!Adjacent(user) || user.stat)
			return

		var/obj/item/pizzabox/boxtotagto = src
		if( boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza(src)
	boxtag = "Gourmet Vegetable"

/obj/item/pizzabox/mushroom/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza(src)
	boxtag = "Meatlover's Supreme"

/obj/item/pizzabox/blingpizza/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/blingpizza(src)
	boxtag = "Centcomm Selects"
