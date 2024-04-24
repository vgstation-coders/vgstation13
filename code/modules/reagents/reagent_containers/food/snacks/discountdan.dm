/obj/item/weapon/reagent_containers/food/snacks/sausage/dan
	name = "premium sausage"
	desc = "A piece of premium, mixed meat. Very mixed..."
	icon_state = "sausage"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 7 //Three bites on average to finish

/obj/item/weapon/reagent_containers/food/snacks/sausage/dan/refill()
	reagents_to_add = list()
	for(var/blendedmeat = 1 to 6)
		switch(rand(1,3))
			if(1)
				reagents_to_add[NUTRIMENT] += 1 //15 nutrition
			if(2)
				reagents_to_add[BEFF] += rand(3,8) //6-16
			if(3)
				reagents_to_add[HORSEMEAT] += rand(3,6) //9-18
	if(prob(75))
		reagents_to_add[BONEMARROW] = rand(1,3) //0-3
	if(prob(44))
		reagents_to_add[ROACHSHELL] = rand(1,8) //0-8
	//36 to 111 nutrition. 4noraisins has 90...
	..()

/obj/item/weapon/reagent_containers/food/snacks/sausage/dan/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FROZEN

/obj/item/weapon/reagent_containers/food/snacks/discountchocolate
	name = "\improper Discount Dan's Chocolate Bar"
	desc = "Something tells you that the glowing green filling inside isn't healthy."
	icon_state = "danbar"
	trash = /obj/item/trash/discountchocolate
	food_flags = FOOD_SWEET
	filling_color = "#7D390D"
	base_crumb_chance = 20
	valid_utensils = 0
	reagents_to_add = list(NUTRIMENT = 3, DISCOUNT = 4, MOONROCKS = 4, TOXICWASTE = 8, URANIUM = 8, CORNSYRUP = 2, CHEMICAL_WASTE = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/discountburrito
	name = "Discount Dan's Burritos"
	desc = "The perfect blend of cheap processing and cheap materials."
	icon_state = "danburrito"
	var/list/ddname = list("Spooky Dan's BOO-ritos - Texas Toast Chainsaw Massacre Flavor","Sconto Danilo's Burritos - 50% Real Mozzarella Pepperoni Pizza Party Flavor","Descuento Danito's Burritos - Pancake Sausage Brunch Flavor","Descuento Danito's Burritos - Homestyle Comfort Flavor","Spooky Dan's BOO-ritos - Nightmare on Elm Meat Flavor","Descuento Danito's Burritos - Strawberrito Churro Flavor","Descuento Danito's Burritos - Beff and Bean Flavor")
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 3, DISCOUNT = 6, IRRADIATEDBEANS = 4, REFRIEDBEANS = 4, MUTATEDBEANS = 4, BEFF = 4, CHEMICAL_WASTE = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/discountburrito/New()
	..()
	name = pick(ddname)

/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins
	name = "economy-class raisins"
	icon_state = "cheap_raisins"
	desc = "Entire galactic economies have been brought to their knees over raisins just like these. The raisins must flow. He who controls the raisins, controls the universe."
	//You don't even get trash back!
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 3
	reagents_to_add = list(GRAPEJUICE = 2, WATER = 2, DISCOUNT = 2) //Overall, these are 9x less nutritious than 4no raisins

/obj/item/weapon/reagent_containers/food/snacks/burger/discount
	name = "\improper Discount Dan's On The Go Burger"
	desc = "It's still warm..."
	icon_state = "goburger" //Someone make a better sprite for this.
	reagents_to_add = list(NUTRIMENT = 4, DISCOUNT = 4, BEFF = 4, HORSEMEAT = 4, OFFCOLORCHEESE = 4, CHEMICAL_WASTE = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/discount
	name = "Discount Pie"
	icon_state = "meatpie"
	desc = "Regulatory laws prevent us from lying to you in the technical sense, so you know this has to contain at least some meat!"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 2, DISCOUNT = 2, TOXIN = 2, CORNSYRUP = 4)

/obj/item/weapon/reagent_containers/food/snacks/danitos
	name = "Danitos"
	desc = "For only the most MLG hardcore robust spessmen."
	icon_state = "danitos"
	trash = /obj/item/trash/chips/danitos
	filling_color = "#FF9933"
	base_crumb_chance = 30
	reagents_to_add = list(NUTRIMENT = 3, DISCOUNT = 4, BONEMARROW = 4, TOXICWASTE = 8, BUSTANUT = 2) //YOU FEELIN HARDCORE BRAH?
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/dangles
	name = "Dangles: "
	desc = "Once you pop, you'll wish you stopped."
	icon_state = "dangles"
	trash = /obj/item/trash/dangles
	filling_color = "#FF9933"
	base_crumb_chance = 30
	var/image/lid_overlay
	var/popped
	bitesize = 4
	reagents_to_add = list(DISCOUNT = 10, SODIUMCHLORIDE = 5, NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/dangles/New()
	switch(rand(1,4))
		if(1)
			name += "Arguably A Potato" //tomatos are actually closely related to potatos
			icon_state += "_red"
			reagents_to_add += list(ENZYME = 5, KETCHUP = 5, ICE = list("volume" = 5,"temp" = T0C), POTATO = list("volume" = 5,"temp" = T0C)) //frozen potato juice
		if(2)
			name += "Cheddar Craving Concussion"
			icon_state += "_blue"
			reagents_to_add += list(MANNITOL = 5, OFFCOLORCHEESE = 5, ICE = list("volume" = 10,"temp" = T0C)) //brainfreeze
		if(3)
			name += "Iodine & Industrial Vinegar"
			icon_state += "_green"
			reagents_to_add += list(TOXICWASTE = 5, STERILIZINE = 5, ETHANOL = 5, SACID = 5) //acetic acid but we don't have that
		if(4)
			name += "South of the Border Jalepeno"
			icon_state += "_purple"
			reagents_to_add += list(HORSEMEAT = 5, BEFF = 5, CAPSAICIN = 5, CONDENSEDCAPSAICIN = 5)
	name += " Flavor"
	..()
	lid_overlay = image(icon, null, "dangles_lid")
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/dangles/can_consume(mob/user)
	return popped

/obj/item/weapon/reagent_containers/food/snacks/dangles/attack_self(var/mob/user)
	if(!popped)
		return pop_open(user)
	..()

/obj/item/weapon/reagent_containers/food/snacks/dangles/proc/pop_open(var/mob/user)
	to_chat(user, "You pop the top off \the [src].")
	playsound(user, 'sound/effects/opening_snack_tube.ogg', 50, 1)
	popped = TRUE
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/dangles/update_icon()
	extra_food_overlay.overlays -= lid_overlay
	if (!popped)
		extra_food_overlay.overlays += lid_overlay
	..()
