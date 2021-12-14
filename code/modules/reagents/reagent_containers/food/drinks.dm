////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/drinkingglass.dmi', "right_hand" = 'icons/mob/in-hand/right/drinkingglass.dmi')
	icon = 'icons/obj/drinks.dmi'
	icon_state = "glassbottle"
	flags = FPRINT  | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5, 10, 25)
	volume = 50
	log_reagents = 1
	//Merged from bottle.dm - Hinaichigo
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 0 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

	//Molotov and smashing variables
	var/molotov = 0 //-1 = can be made into molotov, 0 = can't, 1 = has had rag stuffed into it
	var/lit = 0
	var/brightness_lit = 3
	var/bottleheight = 23 //To offset the molotov rag and fire - beer and ale are 23
	var/smashtext = "bottle of " //To handle drinking glasses and the flask of holy water
	var/smashname = "broken bottle" //As above
	var/flammable = 0
	var/flammin = 0
	var/flammin_color = null
	var/base_icon_state = "glassbottle"

/obj/item/weapon/reagent_containers/food/drinks/on_reagent_change()
	if(gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/weapon/reagent_containers/food/drinks/proc/try_consume(mob/user)
	if(!is_open_container())
		to_chat(user, "<span class='warning'>You can't, \the [src] is closed.</span>")//Added this here and elsewhere to prevent drinking, etc. from closed drink containers. - Hinaichigo
		return 0

	else if(!src.reagents.total_volume || !src)
		to_chat(user, "<span class='warning'>\The [src] is empty.<span>")
		return 0

	else
		imbibe(user)
		return 0

/obj/item/weapon/reagent_containers/food/drinks/attack_self(mob/user)
	try_consume(user)

/obj/item/weapon/reagent_containers/food/drinks/bite_act(mob/user)
	return try_consume(user)

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/living/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents
	var/fillevel = gulp_size

	//Smashing on someone
	if(user.a_intent == I_HURT && isGlass && molotov != 1)  //To smash a bottle on someone, the user must be harm intent, the bottle must be out of glass, and we don't want a rag in here

		if(!M) //This really shouldn't be checked here, but sure
			return

		force = 15 //Smashing bottles over someoen's head hurts. //todo: check that this isn't overwriting anything it shouldn't be //It was

		var/datum/organ/external/affecting = user.zone_sel.selecting //Find what the player is aiming at

		var/armor_block = 0 //Get the target's armour values for normal attack damage.
		var/armor_duration = 0 //The more force the bottle has, the longer the duration.

		//Calculating duration and calculating damage.
		if(ishuman(M))

			var/mob/living/carbon/human/H = M
			var/headarmor = 0 // Target's head armour
			armor_block = H.run_armor_check(affecting, "melee") // For normal attack damage

			//If they have a hat/helmet and the user is targeting their head.
			if(istype(H.head, /obj/item) && affecting == LIMB_HEAD)

				// If their head has an armour value, assign headarmor to it, else give it 0.
				if(H.head.armor["melee"])
					headarmor = H.head.armor["melee"]
				else
					headarmor = 0
			else
				headarmor = 0

			//Calculate the weakening duration for the target.
			armor_duration = (duration - headarmor) + force

		else
			//Only humans can have armour, right?
			armor_block = M.run_armor_check(affecting, "melee")
			if(affecting == LIMB_HEAD)
				armor_duration = duration + force
		armor_duration /= 10

		//Apply the damage!
		M.apply_damage(force, BRUTE, affecting, armor_block)

		// You are going to knock someone out for longer if they are not wearing a helmet.
		// For drinking glass
		if(affecting == LIMB_HEAD && istype(M, /mob/living/carbon/))

			//Display an attack message.
			for(var/mob/O in viewers(user, null))
				if(M != user)
					O.show_message(text("<span class='danger'>[M] has been hit over the head with a [smashtext][src.name], by [user]!</span>"), 1)
				else
					O.show_message(text("<span class='danger'>[M] hits \himself with a [smashtext][src.name] on the head!</span>"), 1)
			//Weaken the target for the duration that we calculated and divide it by 5.
			if(armor_duration)
				M.apply_effect(min(armor_duration, 10) , WEAKEN) // Never weaken more than a flash!

		else
			//Default attack message and don't weaken the target.
			for(var/mob/O in viewers(user, null))
				if(M != user)
					O.show_message(text("<span class='danger'>[M] has been attacked with a [smashtext][src.name], by [user]!</span>"), 1)
				else
					O.show_message(text("<span class='danger'>[M] has attacked \himself with a [smashtext][src.name]!</span>"), 1)

		//Attack logs
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has attacked [M.name] ([M.ckey]) with a bottle!</font>")
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been smashed with a bottle by [user.name] ([user.ckey])</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] with a bottle. ([M.ckey])</font>")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user
			M.assaulted_by(user)

		//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
		if(src.reagents)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='bnotice'>The contents of \the [smashtext][src] splashes all over [M]!</span>"), 1)
			src.reagents.reaction(M, TOUCH)

		//Finally, smash the bottle. This kills (del) the bottle.
		src.smash(M, user)

		return

	else if(!is_open_container())
		to_chat(user, "<span class='warning'>You can't, \the [src] is closed.</span>")//Added this here and elsewhere to prevent drinking, etc. from closed drink containers. - Hinaichigo

		return 0

	else if(!R.total_volume || !R)
		to_chat(user, "<span class='warning'>\The [src] is empty.<span>")
		return 0

	else if(M == user)
		imbibe(user)
		return 0

	else if(istype(M, /mob/living/carbon/human))

		user.visible_message("<span class='danger'>[user] attempts to feed [M] \the [src].</span>", "<span class='danger'>You attempt to feed [M] \the [src].</span>")

		if(!do_mob(user, M))
			return

		user.visible_message("<span class='danger'>[user] feeds [M] \the [src].</span>", "<span class='danger'>You feed [M] \the [src].</span>")

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user
			M.assaulted_by(user)

		if(reagents.total_volume)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.chem_flags & NO_DRINK)
					reagents.reaction(get_turf(H), TOUCH)
					H.visible_message("<span class='warning'>The contents in [src] fall through and splash onto the ground, what a mess!</span>")
					reagents.remove_any(gulp_size)
					return 0

			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, gulp_size)

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			var/refill = R.get_master_reagent_id()
			spawn(600)
				R.add_reagent(refill, fillevel)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0


/obj/item/weapon/reagent_containers/food/drinks/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	if(!reagents)
		return

	// Attempt to transfer to our glass
	if (transfer(target, user, can_send = FALSE, can_receive = TRUE))
		return

	// Attempt to transfer from our glass
	transfer(target, user, can_send = TRUE, can_receive = FALSE)

/obj/item/weapon/reagent_containers/food/drinks/examine(mob/user)
	..()

	if(is_open_container())
		if(!reagents || reagents.total_volume == 0)
			to_chat(user, "<span class='info'>\The [src] is empty!</span>")
		else if (reagents.total_volume <= src.volume/4)
			to_chat(user, "<span class='info'>\The [src] is almost empty!</span>")
		else if (reagents.total_volume <= src.volume*0.66)
			to_chat(user, "<span class='info'>\The [src] is about half full, or about half empty!</span>")
		else if (reagents.total_volume <= src.volume*0.90)
			to_chat(user, "<span class='info'>\The [src] is almost full!</span>")
		else
			to_chat(user, "<span class='info'>\The [src] is full!</span>")

/obj/item/weapon/reagent_containers/food/drinks/imbibe(mob/user) //Drink the liquid within
	if(lit)
		user.bodytemperature += 3 * TEMPERATURE_DAMAGE_COEFFICIENT//only the first gulp will be hot.
		lit = 0

	..()

/obj/item/weapon/reagent_containers/food/drinks/New()
	..()
	base_icon_state = icon_state

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup."
	name = "golden cup"
	icon_state = "golden_cup"
	w_class = W_CLASS_LARGE
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	flags = FPRINT  | OPENCONTAINER
	siemens_coefficient = 1

/obj/item/weapon/reagent_containers/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 June, and name of the winner will be engraved on it."


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon = 'icons/obj/food_condiment.dmi'
	icon_state = "milk"
	vending_cat = "dairy products"
/obj/item/weapon/reagent_containers/food/drinks/milk/New()
	..()
	reagents.add_reagent(MILK, 50)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/flour
	name = "\improper flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon = 'icons/obj/food_condiment.dmi'
	icon_state = "flour"
/obj/item/weapon/reagent_containers/food/drinks/flour/New()
	..()
	reagents.add_reagent(FLOUR, 50)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon = 'icons/obj/food_condiment.dmi'
	icon_state = "soymilk"
	vending_cat = "dairy products"//it's not a dairy product but oh come on who cares
/obj/item/weapon/reagent_containers/food/drinks/soymilk/New()
	..()
	reagents.add_reagent(SOYMILK, 50)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER


/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/coffee/New()
	..()
	reagents.add_reagent(COFFEE, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/latte
	name = "Smooth Latte"
	desc = "A pleasant soft taste of latte will sooth any and all pain, while relaxing music plays in your head."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/latte/New()
	..()
	reagents.add_reagent(CAFE_LATTE, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soy_latte
	name = "Soy Latte"
	desc = "Soy version of a latte for soy people."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/soy_latte/New()
	..()
	reagents.add_reagent(SOY_LATTE, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/cappuccino
	name = "Cappuccino"
	desc = "You will ask yourself: how is cappuccino different from latte? It tastes the same; and you will be right."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/cappuccino/New()
	..()
	reagents.add_reagent(CAPPUCCINO, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/espresso
	name = "Zip Espresso"
	desc = "When you need a small and quick kick."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/espresso/New()
	..()
	reagents.add_reagent(ESPRESSO, 15)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/doppio
	name = "Doppio x2"
	desc = "Double espresso made only out of the finest twin coffee beans."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/doppio/New()
	..()
	reagents.add_reagent(DOPPIO, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Tea"
	icon_state = "tea"
	item_state = "mug_empty"
/obj/item/weapon/reagent_containers/food/drinks/tea/New()
	..()
	switch(pick(1,2,3))
		if(1)
			name = "Duke Purple Tea"
			desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
			reagents.add_reagent(TEA, 30)
		if(2)
			name = "Century Tea"
			desc = "In most cultures, if you leave tea out for months it's considered spoiled. Although this tea is black, we still consider it good for cultural reasons. Taste the century."
			reagents.add_reagent(REDTEA, 30)
		if(3)
			name = "Hippie Farms Eco-Tea"
			desc = "Remember when the station was powered by solar panels instead of raping space for its plasma, then creating an engine of destruction? Hippie Farms remembers, maaaan."
			reagents.add_reagent(GREENTEA, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/chifir
	name = "Siberian Chifir"
	desc = "Only a true siberian can appreciate its deep and rich flavor. Embrace siberian tradition!"
	icon_state = "tea"
	item_state = "mug_empty"
/obj/item/weapon/reagent_containers/food/drinks/chifir/New()
	..()
	reagents.add_reagent(CHIFIR, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "\improper ice cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "icecup"
/obj/item/weapon/reagent_containers/food/drinks/ice/New()
	..()
	reagents.add_reagent(ICE, 30, reagtemp = T0C)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/tomatosoup
	name = "Tomato Soup"
	desc = "Tomato Soup! In a cup!"
	icon_state = "tomatosoup"
/obj/item/weapon/reagent_containers/food/drinks/tomatosoup/New()
	..()
	reagents.add_reagent(TOMATO_SOUP, 30, reagtemp = T0C + 80)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "tea"
	item_state = "mug_empty"
/obj/item/weapon/reagent_containers/food/drinks/h_chocolate/New()
	..()
	reagents.add_reagent(HOT_COCO, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "\improper cup ramen"
	desc = "A taste that reminds you of your school years."
	icon_state = "ramen"
/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/New()
	..()
	reagents.add_reagent(DRY_RAMEN, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating //vendor version
	name = "\improper cup ramen"
	desc = "Just add 12ml water, self heats!"
	icon_state = "ramen"
/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating/New()
	..()
	reagents.add_reagent(CALCIUMOXIDE, 2)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/groans
	name = "Groans Soda"
	desc = "Groans Soda: We'll make you groan."
	icon_state = "groans"
/obj/item/weapon/reagent_containers/food/drinks/groans/New()
	..()
	switch(pick(1,2,3,4,5))
		if(1)
			name = "Groans Soda: Cuban Spice Flavor"
			desc = "Warning: Long exposure to liquid inside may cause you to follow the rumba beat."
			icon_state += "_hot"
			reagents.add_reagent(CONDENSEDCAPSAICIN, 10)
			reagents.add_reagent(RUM, 10)
		if(2)
			name = "Groans Soda: Icey Cold Flavor"
			desc = "Cold in a can. Er, bottle."
			icon_state += "_cold"
			reagents.add_reagent(FROSTOIL, 10)
			reagents.add_reagent(ICE, 10, reagtemp = T0C)
		if(3)
			name = "Groans Soda: Zero Calories"
			desc = "Zero Point Calories. That's right, we fit even MORE nutriment in this thing."
			icon_state += "_nutriment"
			reagents.add_reagent(NUTRIMENT, 20)
		if(4)
			name = "Groans Soda: Energy Shot"
			desc = "Warning: The Groans Energy Blend(tm), may be toxic to those without constant exposure to chemical waste. Drink responsibly."
			icon_state += "_energy"
			reagents.add_reagent(SUGAR, 10)
			reagents.add_reagent(CHEMICAL_WASTE, 10)
		if(5)
			name = "Groans Soda: Double Dan"
			desc = "Just when you thought you've had enough Dan, The 'Double Dan' strikes back with this wonderful mixture of too many flavors. Bring a barf bag, Drink responsibly."
			icon_state += "_doubledew"
			reagents.add_reagent(DISCOUNT, 20)
	reagents.add_reagent(DISCOUNT, 10)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/filk
	name = "Filk"
	desc = "Only the best Filk for your crew."
	icon_state = "filk"
/obj/item/weapon/reagent_containers/food/drinks/filk/New()
	..()
	switch(pick(1,2,3,4,5))
		if(1)
			name = "Filk: Chocolate Edition"
			reagents.add_reagent(HOT_COCO, 10)
		if(2)
			name = "Filk: Scripture Edition"
			reagents.add_reagent(HOLYWATER, 30)
		if(3)
			name = "Filk: Carribean Edition"
			reagents.add_reagent(RUM, 30)
		if(4)
			name = "Filk: Sugar Blast Editon"
			reagents.add_reagent(SUGAR, 30)
			reagents.add_reagent(RADIUM, 10) // le epik fallout may mays
			reagents.add_reagent(TOXICWASTE, 10)
		if(5)
			name = "Filk: Pure Filk Edition"
			reagents.add_reagent(DISCOUNT, 20)
	reagents.add_reagent(DISCOUNT, 10)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo
	name = "Grifeo"
	desc = "A quality drink."
	icon_state = "griefo"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo/New()
	..()
	switch(pick(1,2,3,4,5))
		if(1)
			name = "Grifeo: Spicy"
			reagents.add_reagent(CONDENSEDCAPSAICIN, 30)
		if(2)
			name = "Grifeo: Frozen"
			reagents.add_reagent(FROSTOIL, 30)
		if(3)
			name = "Grifeo: Crystallic"
			reagents.add_reagent(SUGAR, 20)
			reagents.add_reagent(ICE, 20, reagtemp = T0C)
			reagents.add_reagent(SPACE_DRUGS, 20)
		if(4)
			name = "Grifeo: Rich"
			reagents.add_reagent(TEQUILA, 10)
			reagents.add_reagent(CHEMICAL_WASTE, 10)
		if(5)
			name = "Grifeo: Pure"
			reagents.add_reagent(DISCOUNT, 20)
	reagents.add_reagent(DISCOUNT, 10)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/groansbanned
	name = "Groans: Banned Edition"
	desc = "Banned literally everywhere."
	icon_state = "groansevil"
/obj/item/weapon/reagent_containers/food/drinks/groansbanned/New()
	..()
	switch(pick(1,2,3,4,5))
		if(1)
			name = "Groans Banned Soda: Fish Suprise"
			reagents.add_reagent(CARPOTOXIN, 10)
		if(2)
			name = "Groans Banned Soda: Bitter Suprise"
			reagents.add_reagent(TOXIN, 20)
		if(3)
			name = "Groans Banned Soda: Sour Suprise"
			reagents.add_reagent(PACID, 20)
		if(4)
			name = "Groans Banned Soda: Sleepy Suprise"
			reagents.add_reagent(STOXIN, 10)
		if(5)
			name = "Groans Banned Soda: Quadruple Dan"
			reagents.add_reagent(DISCOUNT, 40)
	reagents.add_reagent(DISCOUNT, 10)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/zam_nitrofreeze
	name = "Zam Nitro Freeze"
	desc = "The mothership has synthesized the coldest of cold drinks! Can your brain handle the freeze?" // It is not wise to chug this whole drink.
	icon_state = "Zam_NitroFreeze"
/obj/item/weapon/reagent_containers/food/drinks/zam_nitrofreeze/New()
	..()
	reagents.add_reagent(NITROGEN, 25)
	reagents.add_reagent(FROSTOIL, 15)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink
	name = "Mann's Drink"
	desc = "The only thing a <B>REAL MAN</B> needs."
	icon_state = "mannsdrink"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink/New()
	..()
	reagents.add_reagent(DISCOUNT, 30)
	reagents.add_reagent(MANNITOL, 20)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/groans
	name = "Groan-o-matic 9000"
	desc = "This is for testing reasons."
	icon_state = "toddler"

/obj/item/weapon/groans/attack_self(mob/user as mob)
	to_chat(user, "Now spawning groans.")
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/groans/A = new /obj/item/weapon/reagent_containers/food/drinks/groans(T)
	A.desc += " It also smells like a toddler." //This is required

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot
	name = "Discount Dan's Noodle Soup"
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	icon_state = "ramen"
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Sm?rg?sbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")
/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot/New()
	..()
	name = pick(ddname)
	reagents.add_reagent(HOT_RAMEN, 20)
	reagents.add_reagent(DISCOUNT, 10)
	reagents.add_reagent(GLOWINGRAMEN, 8)
	reagents.add_reagent(TOXICWASTE, 8)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen
	name = "Discount Dan's Noodle Soup"
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	icon_state = "ramen"
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Sm?rg?sbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")
/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/New()
	..()
	name = pick(ddname)
	reagents.add_reagent(DRY_RAMEN, 20)
	reagents.add_reagent(DISCOUNT, 10)
	reagents.add_reagent(TOXICWASTE, 4)
	reagents.add_reagent(GREENRAMEN, 4)
	reagents.add_reagent(GLOWINGRAMEN, 4)
	reagents.add_reagent(DEEPFRIEDRAMEN, 4)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/attack_self(mob/user as mob)
	to_chat(user, "You pull the tab, you feel the drink heat up in your hands, and its horrible fumes hits your nose like a ton of bricks. You drop the soup in disgust.")
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot/A = new /obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot(T)
	A.desc += " It feels warm.." //This is required
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/discount_sauce
	name = "Discount Dan's Special Sauce"
	desc = "Discount Dan brings you his very own special blend of delicious ingredients in one discount sauce!"
	icon_state = "discount_sauce"
	volume = 3

/obj/item/weapon/reagent_containers/food/drinks/discount_sauce/New()
	..()
	reagents.add_reagent(DISCOUNT, 3)


/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. In space."
	icon_state = "beer"
	vending_cat = "fermented"
	molotov = -1 //can become a molotov
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/beer/New()
	..()
	reagents.add_reagent(BEER, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	vending_cat = "fermented"
	molotov = -1 //can become a molotov
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/ale/New()
	..()
	reagents.add_reagent(ALE, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans
	vending_cat = "carbonated drinks"
	flags = FPRINT //Starts sealed until you pull the tab! Lacks OPENCONTAINER for this purpose
	//because playsound(user, 'sound/effects/can_open[rand(1,3)].ogg', 50, 1) just wouldn't work. also so badmins can varedit these
	var/list/open_sounds = list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/update_icon()
	overlays.len = 0
	if (flags & OPENCONTAINER)
		overlays += image(icon = icon, icon_state = "soda_open")

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/attack_self(var/mob/user)
	if(!is_open_container())
		return pop_open(user)
	if (reagents.total_volume > 0)
		return ..()
	else if (user.a_intent == I_HURT)
		var/turf/T = get_turf(user)
		user.drop_item(src, T, 1)
		var/obj/item/trash/soda_cans/crushed_can = new (T, icon_state = icon_state)
		crushed_can.name = "crushed [name]"
		user.put_in_active_hand(crushed_can)
		playsound(user, 'sound/items/can_crushed.ogg', 75, 1)
		qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/proc/pop_open(var/mob/user)
	to_chat(user, "You pull back the tab of \the [src] with a satisfying pop.")
	flags |= OPENCONTAINER
	src.verbs |= /obj/item/weapon/reagent_containers/verb/empty_contents
	playsound(user, pick(open_sounds), 50, 1)
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola/New()
	..()
	reagents.add_reagent(COLA, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic/New()
	..()
	reagents.add_reagent(TONIC, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater/New()
	..()
	reagents.add_reagent(SODAWATER, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime/New()
	..()
	reagents.add_reagent(LEMON_LIME, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up/New()
	..()
	reagents.add_reagent(SPACE_UP, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist/New()
	..()
	if(prob(30))
		new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime(get_turf(src))
		qdel(src) //You wanted ORANGE. It gave you lemon lime!
		return
	reagents.add_reagent(COLA, 15)
	reagents.add_reagent(ORANGEJUICE, 15)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind/New()
	..()
	reagents.add_reagent(SPACEMOUNTAINWIND, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsably."
	icon_state = "thirteen_loko"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko/New()
	..()
	reagents.add_reagent(THIRTEENLOKO, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb/New()
	..()
	reagents.add_reagent(DR_GIBB, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka
	name = "Nuka Cola"
	desc = "Cool, refreshing, Nuka Cola."
	icon_state = "nuka"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka/New()
	..()
	reagents.add_reagent(NUKA_COLA, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum
	name = "Nuka Cola Quantum"
	desc = "Take the leap... enjoy a Quantum!"
	icon_state = "quantum"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum/New()
	..()
	reagents.add_reagent(QUANTUM, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink
	name = "Brawndo"
	icon_state = "brawndo"
	desc = "It has what plants crave! Electrolytes!"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink/New()
	..()
	reagents.add_reagent(SPORTDRINK, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola
	name = "Gunka-Cola Family Sized"
	desc = "An unnaturally-sized can for unnaturally-sized men. Taste the Consumerism!"
	icon_state = "gunka_cola"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	volume = 100
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola/New()
	..()
	reagents.add_reagent(COLA, 60)
	reagents.add_reagent(SUGAR, 20)
	reagents.add_reagent(SODIUM, 10)
	reagents.add_reagent(COCAINE, 5)
	reagents.add_reagent(BLACKCOLOR, 5)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/roentgen_energy
	name = "Roentgen Energy"
	desc = "Roentgen Energy, a meltdown in your mouth! Contains real actinides!"
	icon_state = "roentgenenergy"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/roentgen_energy/New()
	..()
	reagents.add_reagent(CAFFEINE, 5)
	reagents.add_reagent(COCAINE, 1.4)
	reagents.add_reagent(URANIUM, 3.6)
	reagents.add_reagent(SPORTDRINK, 20)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_bread
	name = "\improper canned bread"
	desc = "Wow, they have it!"
	icon_state = "cannedbread"
	//no actual chemicals in the can

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_bread/pop_open(var/mob/user)
	. = ..()
	spawn(0.5 SECONDS)
		playsound(src, pick('sound/effects/splat_pie1.ogg','sound/effects/splat_pie2.ogg'), 50)
		var/obj/B = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread(get_turf(src))
		user.put_in_hands(B)

/obj/item/weapon/reagent_containers/food/drinks/coloring
	name = "\improper vial of food coloring"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vial"
	volume = 25
	possible_transfer_amounts = list(1,5)
/obj/item/weapon/reagent_containers/food/drinks/coloring/New()
	..()
	reagents.add_reagent(BLACKCOLOR, 25)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "\improper paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
/obj/item/weapon/reagent_containers/food/drinks/sillycup/New()
	..()
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

/obj/item/weapon/reagent_containers/food/drinks/danswhiskey
	name = "Discount Dan's 'Malt' Whiskey"
	desc = "The very cheapest and most sickening method of liver failure."
	icon_state = "dans_whiskey"

/obj/item/weapon/reagent_containers/food/drinks/danswhiskey/New()
	..()
	reagents.add_reagent(DANS_WHISKEY, 30)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

//Beer cans for the Off Licence
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/blebweiser
	name = "Blebweiser"
	desc = "Based on an American classic, this lager has seen little improvement over the years."
	icon_state = "blebweiser"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/blebweiser/New()
	..()
	reagents.add_reagent(BEER, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bluespaceribbon
	name = "Bluespace Ribbon"
	desc = "A cheap lager brewed in enormous bluespace pockets, the brewing process has done little for the flavour."
	icon_state = "bluespaceribbon"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bluespaceribbon/New()
	..()
	reagents.add_reagent(BEER, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/codeone
	name = "Code One"
	desc = "The Code One Brewery prides itself on creating the very best beer for cracking open with the boys."
	icon_state = "codeone"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/codeone/New()
	..()
	reagents.add_reagent(BEER, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gibness
	name = "Gibness"
	desc = "Derived from a classic Irish recipe, there's a strong taste of starch in this dry stout."
	icon_state = "gibness"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gibness/New()
	..()
	reagents.add_reagent(BEER, 25)
	reagents.add_reagent(POTATO, 25)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer
	name = "Geometer"
	desc = "Summon the Beast."
	icon_state = "geometer"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer/New()
	..()
	reagents.add_reagent(GEOMETER, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer/blanco
	name = "Geometer Blanco"
	desc = "'member when we had to research words..."
	icon_state = "geometer_blanco"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/greyshitvodka
	name = "Greyshit Vodka"
	desc = "Experts spent a long time squatting around a mixing bench to bring you this."
	icon_state = "greyshitvodka"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/greyshitvodka/New()
	..()
	reagents.add_reagent(GREYVODKA, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/orchardtides
	name = "Orchard Tides"
	desc = "A sweet apple cider that might quench that kleptomania if only for a while."
	icon_state = "orchardtides"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/orchardtides/New()
	..()
	reagents.add_reagent(BEER, 20)
	reagents.add_reagent(APPLEJUICE, 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sleimiken
	name = "Sleimiken"
	desc = "This Belgium original has been enhanced over the years with the delicious taste of DNA-dissolving slime extract."
	icon_state = "sleimiken"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sleimiken/New()
	..()
	reagents.add_reagent(BEER, 45)
	reagents.add_reagent(SLIMEJELLY, 5)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/strongebow
	name = "Strong-eBow"
	desc = "A Syndicate favourite, the sharp flavour of this Cider has been compared to getting shot by an Energy Bow."
	icon_state = "strongebow"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/strongebow/New()
	..()
	reagents.add_reagent(BEER, 30)
	reagents.add_reagent(APPLEJUICE, 20)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcoffee
	name = "Kiririn FIRE"
	desc = "Fine, sweet coffee, easy to drink in any scene."
	icon_state = "cannedcoffee"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcoffee/New()
	..()
	reagents.add_reagent(CAFE_LATTE, 50)


/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee
	name = "HOSS Rainbow Donut Blend"
	desc = "All the essentials, for on the go."
	icon_state = "cannedcopcoffee"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee/New()
	..()
	reagents.add_reagent(SECCOFFEE, 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_white
	name = "Picomed: White edition"
	desc = "Good for the body and good for the bones."
	icon_state = "lifeline_white"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_white/New()
	..()
	reagents.add_reagent(MEDCOFFEE, 48)
	reagents.add_reagent(MILK, 2)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_red
	name = "Picomed: Red edition"
	desc = "I need 50ccs of coffee, stat!"
	icon_state = "lifeline_red"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_red/New()
	..()
	reagents.add_reagent(MEDCOFFEE, 48)
	reagents.add_reagent(REDTEA, 2)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_cryo
	name = "Picomed: Cryo edition"
	desc = "Remember to strip before consuming."
	icon_state = "lifeline_cryo"
	var/list/tubeoverlay = list()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_cryo/on_reagent_change()
	..()
	for(var/image/ol in tubeoverlay)
		overlays -= ol
		tubeoverlay -= ol
	var/remaining = Ceiling(reagents.total_volume/reagents.maximum_volume*100,20)
	var/image/status_overlay = image("icon" = 'icons/obj/drinks.dmi', "icon_state" = "cryoverlay_[remaining]")
	overlays += status_overlay
	tubeoverlay += status_overlay

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_cryo/New()
	..()
	reagents.add_reagent(MEDCOFFEE, 48)
	reagents.add_reagent(LEPORAZINE, 1)
	reagents.add_reagent(FROSTOIL, 1)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bear
	name = "Bear Arms Beer"
	desc = "Crack open a Bear at the end of a long shift."
	icon_state = "bearbeer"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bear/New()
	..()
	reagents.add_reagent(BEER, 30)
	reagents.add_reagent(HYPERZINE, rand(3,5))

// Here be ayy canned drinks

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash
	name = "Zam Sulphuric Splash"
	desc = "Taste the splashy tang! The flavor will melt your taste buds."
	icon_state = "Zam_SulphuricSplash"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash/New()
	..()
	reagents.add_reagent(LEMONJUICE, 25)
	reagents.add_reagent(SACID, 15)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz
	name = "Zam Formic Fizz"
	desc = "Sulphuric Splash is for brainless minions. This is a REAL grey's drink."
	icon_state = "Zam_FormicFizz"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz/New()
	..()
	reagents.add_reagent(LIMEJUICE, 25)
	reagents.add_reagent(FORMIC_ACID, 15)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_tannicthunder
	name = "Zam Tannic Thunder"
	desc = "Humans and lightweights may find this beverage agreeable if they dislike the stronger acids." // This is supposed to be a way to heal burns caused by consuming the more acidic drinks. But humans take brute damage from ingesting acid for some reason?
	icon_state = "Zam_TannicThunder"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_tannicthunder/New()
	..()
	reagents.add_reagent(ORANGEJUICE, 25)
	reagents.add_reagent(TANNIC_ACID, 15)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea
	name = "Zam Trusty Tea"
	desc = "All trusty tea is made with real opok juice. Zam's honor!" // Now with REAL Opok Juice!
	icon_state = "Zam_TrustyTea"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea/New()
	..()
	if(prob(5))
		name = "Zam Old Fashioned Tea"
		desc = "One of the original cans! The design has been discontinued, and it might be worth something to a collector."
		icon_state = "Zam_TrustyClassic"
	reagents.add_reagent(ACIDTEA, 25)
	reagents.add_reagent(OPOKJUICE, 10)
	reagents.add_reagent(CAFFEINE, 5)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_humanhydrator
	name = "Zam Human Hydrator"
	desc = "The mothership provides only the best mineral water for humans to drink, REAL minerals included."
	icon_state = "Zam_HumanHydrator"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_humanhydrator/New()
	..()
	reagents.add_reagent(WATER, 35)
	reagents.add_reagent(IRON, 1)
	reagents.add_reagent(COPPER, 1)
	reagents.add_reagent(SILVER, 1)
	reagents.add_reagent(GOLD, 1)
	reagents.add_reagent(DIAMONDDUST, 1)
	pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_polytrinicpalooza
	name = "Zam Polytrinic Palooza"
	desc = "This drink has been banned in all mothership controlled territories. Consume at your own risk."
	icon_state = "Zam_PolytrinicPalooza"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_polytrinicpalooza/New()
	..()
	reagents.add_reagent(HOOCH, 20)
	reagents.add_reagent(PACID, 14)
	reagents.add_reagent(MINDBREAKER, 1)
	reagents.add_reagent(COCAINE, 5)
	src.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "\improper Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	origin_tech = Tc_MATERIALS + "=1"
	amount_per_transfer_from_this = 10
	volume = 100
	flags = FPRINT  | OPENCONTAINER | NOREACT | SILENTCONTAINER
	var/shaking = FALSE
	var/obj/item/weapon/reagent_containers/food/drinks/shaker/reaction/reaction = null

/obj/item/weapon/reagent_containers/food/drinks/shaker/New()
	..()
	if (flags & NOREACT)
		reaction = new(src)

/obj/item/weapon/reagent_containers/food/drinks/shaker/Destroy()
	if (reaction)
		qdel(reaction)
	..()

/obj/item/weapon/reagent_containers/food/drinks/shaker/attack_self(var/mob/user)
	if (reagents.is_empty())
		to_chat(user, "<span class='warning'>You won't shake an empty shaker now, will you?</span>")
		return
	if (!shaking)
		shaking = TRUE
		var/adjective = pick("furiously","passionately","with vigor","with determination","like a devil","with care and love","like there is no tomorrow")
		user.visible_message("<span class='notice'>\The [user] shakes \the [src] [adjective]!</span>","<span class='notice'>You shake \the [src] [adjective]!</span>")
		icon_state = "shaker-shake"
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
		playsound(user, 'sound/items/boston_shaker.ogg', 80, 1)
		if(do_after(user, src, 30))
			reagents.trans_to(reaction,volume)
			reaction.reagents.trans_to(reagents,volume)
		icon_state = "shaker"
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
		shaking = FALSE

/obj/item/weapon/reagent_containers/food/drinks/shaker/reaction
	flags = FPRINT  | OPENCONTAINER | SILENTCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/discount_shaker
	name = "\improper Discount Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	origin_tech = Tc_MATERIALS + "=1"
	amount_per_transfer_from_this = 10
	volume = 100
	flags = FPRINT  | OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/thermos
	name = "\improper Thermos"
	desc = "A metal flask which insulates its contents from temperature - keeping hot beverages hot, and cold ones cold."
	icon_state = "vacuumflask"
	origin_tech = Tc_MATERIALS + "=1"
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/thermos/full/New()
	..()
	var/new_reagent = pick(COFFEE, HOT_COCO, ICECOFFEE, TEA, ICETEA, WATER, ICE, ICED_BEER)
	reagents.add_reagent(new_reagent, rand(50,100))

/obj/item/weapon/reagent_containers/food/drinks/plastic
	name = "\improper plastic bottle"
	desc = "Remember to recycle."
	icon_state = "plasticbottle"
	origin_tech = Tc_MATERIALS + "=1"
	melt_temperature = MELTPOINT_PLASTIC
	starting_materials = list(MAT_PLASTIC = 500)
	volume = 100
	amount_per_transfer_from_this = 10

/obj/item/weapon/reagent_containers/food/drinks/plastic/water
	name = "\improper water bottle"
	desc = "Chemically enhanced mineral water."
	icon_state = "waterbottle"

/obj/item/weapon/reagent_containers/food/drinks/plastic/water/New()
	..()
	reagents.add_reagent(WATER, volume)

/obj/item/weapon/reagent_containers/food/drinks/plastic/water/small
	name = "\improper small water bottle"
	icon_state = "waterbottle_small"
	volume = 50
	amount_per_transfer_from_this = 5

/obj/item/weapon/reagent_containers/food/drinks/plastic/sodawater
	name = "\improper Soda Water bottle"
	desc = "Good ole carbonated water."
	icon_state = "sodawaterbottle"

/obj/item/weapon/reagent_containers/food/drinks/plastic/sodawater/New()
	..()
	reagents.add_reagent(SODAWATER, volume)

/obj/item/weapon/reagent_containers/food/drinks/plastic/cola
	name = "\improper Space Cola bottle"
	desc = "During hard times, place your trust in mega corporations, and their sponsored drinks."
	icon_state = "colaplasticbottle"

/obj/item/weapon/reagent_containers/food/drinks/plastic/cola/New()
	..()
	reagents.add_reagent(COLA, volume)

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "\improper Captain's flask"
	desc = "A metal flask belonging to the captain."
	icon_state = "flask"
	origin_tech = Tc_MATERIALS + "=1"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "\improper Detective's flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	name = "\improper flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/ancient
	name = "\improper ancient flask"
	desc = "A flask recovered from the asteroid. How old is it?"
	icon_state = "oldflask"
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/reagent_containers/food/drinks/flask/ancient/New()
	..()
	reagents.add_reagent(KARMOTRINE, 15)

/obj/item/weapon/reagent_containers/food/drinks/flagmug
	name = "mug"
	desc = "A simple mug."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "mug_empty"
	isGlass = 0
	amount_per_transfer_from_this = 10
	volume = 30
	starting_materials = list(MAT_IRON = 500)

/obj/item/weapon/reagent_containers/food/drinks/flagmug/on_reagent_change()
	if (reagents.reagent_list.len > 0)
		mug_reagent_overlay()
	else
		overlays.len = 0

/obj/item/weapon/reagent_containers/food/drinks/flagmug/britcup
	name = "\improper cup"
	desc = "A cup with the British flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "britcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/americup
	name = "\improper cup"
	desc = "A cup with the American flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "americup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/francecup
	name = "\improper cup"
	desc = "A cup with the French flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "francecup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/italycup
	name = "\improper cup"
	desc = "A cup with the Italian flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "italycup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/germancup
	name = "\improper cup"
	desc = "A cup with the German flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "germancup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/spanishcup
	name = "\improper cup"
	desc = "A cup with the Spanish flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "spanishcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/irelandcup
	name = "\improper cup"
	desc = "A cup with the Irish flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "irelandcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/uruguaycup
	name = "\improper cup"
	desc = "A cup with the Uruguayan flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "uruguaycup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/argentinacup
	name = "\improper cup"
	desc = "A cup with the Argentine flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "argentinacup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/brasilcup
	name = "\improper cup"
	desc = "A cup with the Brasilian flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "brasilcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/chilecup
	name = "\improper cup"
	desc = "A cup with the Chilean flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "chilecup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/uncup
	name = "\improper cup"
	desc = "A cup with the United Nations flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "uncup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flagmug/eucup
	name = "\improper cup"
	desc = "A cup with the European flag emblazoned on it."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "eucup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/gromitmug
	name = "\improper Gromit Mug"
	desc = "Gromit Mug."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "gromitmug"
	volume = 30

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom


/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	starting_materials = list(MAT_GLASS = 500)
	bottleheight = 31
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/weapon/broken_bottle

	name = "broken bottle" // changed to lowercase - Hinaichigo
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	sharpness = 0.8 //same as glass shards
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	w_class = W_CLASS_TINY
	item_state = "beer"
	attack_verb = list("stabs", "slashes", "attacks")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	starting_materials = list(MAT_GLASS = 500)
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	vending_cat = "spirits"
	bottleheight = 30
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/gin/New()
	..()
	reagents.add_reagent(GIN, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey/New()
	..()
	reagents.add_reagent(WHISKEY, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/New()
	..()
	reagents.add_reagent(VODKA, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila/New()
	..()
	reagents.add_reagent(TEQUILA, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Bluespace Curacao"
	desc = "This is either Blue Curacao, or window cleaner. Take a sip and find out."
	icon_state = "bluecuracaobottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao/New()
	..()
	reagents.add_reagent(BLUECURACAO, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bitters
	name = "Wizard's Bitters"
	desc = "Named for it's seemingly magical ability to take the place of any variety of bitters. Abracadabra, Angostura!"
	icon_state = "bittersbottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/bitters/New()
	..()
	reagents.add_reagent(BITTERS, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/triplesec
	name = "Cufftreau Triple Sec"
	desc = "Named for what'll be wrapped around your wrists by the end of the night if you keep drinking like this."
	icon_state = "triplesecbottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/triplesec/New()
	..()
	reagents.add_reagent(TRIPLESEC, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/schnapps
	name = "All-in-One Fancy Space Schnapps"
	desc = "For when you can't be bothered to stock a dozen varieties of Schnapps - just don't complain when it doesn't taste quite right."
	icon_state = "schnappsbottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/schnapps/New()
	..()
	reagents.add_reagent(SCHNAPPS, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne
	name = "Captain's Finest Champagne"
	desc = "A premium brand of champagne, intended for only the most discerning of tastes - for Captains, by Captains."
	icon_state = "champagnebottle"
	vending_cat = "fermented"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne/New()
	..()
	reagents.add_reagent(CHAMPAGNE, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/fireballwhisky
	name = "Oni Soma's Fireball Whisky"
	desc = "A cinnamon flavored Whisky - without the E - favored by cheap drunks with no taste buds."
	icon_state = "fireballwhiskybottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/fireballwhisky/New()
	..()
	reagents.add_reagent(CINNAMONWHISKY, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	icon_state = "bottleofnothing"
	desc = ""
	isGlass = 1
	molotov = -1
	smashtext = ""
/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		name = "Bottle of Something"
		desc = "A bottle filled with something."
		reagents.add_reagent(pick(BEER, VOMIT, ZOMBIEPOWDER, SOYSAUCE, KETCHUP, HONEY, BANANA, ABSINTHE, SALTWATER, WATER, BLOOD, LUBE, MUTATIONTOXIN, AMUTATIONTOXIN, GOLD, TRICORDRAZINE, GRAVY), 100)
	else
		desc = "A bottle filled with nothing."
		reagents.add_reagent(NOTHING, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	bottleheight = 26 //has a cork but for now it goes on top of the cork
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/patron/New()
	..()
	reagents.add_reagent(PATRON, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	vending_cat = "spirits"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/rum/New()
	..()
	reagents.add_reagent(RUM, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	vending_cat = "fermented"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth/New()
	..()
	reagents.add_reagent(VERMOUTH, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	vending_cat = "fermented"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua/New()
	..()
	reagents.add_reagent(KAHLUA, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager/New()
	..()
	reagents.add_reagent(GOLDSCHLAGER, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	vending_cat = "spirits"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac/New()
	..()
	reagents.add_reagent(COGNAC, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	vending_cat = "fermented"
	bottleheight = 30
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/wine/New()
	..()
	reagents.add_reagent(WINE, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine
	name = "Vintage 2018 Special Reserve"
	desc = "Fermented during tumultuous years, and aged to perfection over several centuries."
	icon_state = "pwinebottle"
	vending_cat = "fermented" //doesn't actually matter, will appear under premium
	bottleheight = 30
	molotov = -1
	isGlass = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine/New()
	..()
	reagents.add_reagent(PWINE, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	bottleheight = 27
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/New()
	..()
	reagents.add_reagent(ABSINTHE, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/sake
	name = "Uchuujin Junmai Ginjo Sake"
	desc = "An exotic rice wine from the land of the space ninjas."
	icon_state = "sakebottle"
	vending_cat = "fermented"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/sake/New()
	..()
	reagents.add_reagent(SAKE, 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	vending_cat = "fruit juices"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice/New()
	..()
	reagents.add_reagent(ORANGEJUICE, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	vending_cat = "dairy products"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream/New()
	..()
	reagents.add_reagent(CREAM, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	vending_cat = "fruit juices"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice/New()
	..()
	reagents.add_reagent(TOMATOJUICE, 100)


/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	vending_cat = "fruit juices"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice/New()
	..()
	reagents.add_reagent(LIMEJUICE, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/greyvodka
	name = "Greyshirt Vodka"
	desc = "Experts spent a long time squatting around a mixing bench to bring you this."
	icon_state = "grey_vodka"
	vending_cat = "spirits"
	starting_materials = null
	isGlass = 1
	molotov = -1

/obj/item/weapon/reagent_containers/food/drinks/bottle/greyvodka/New()
	..()
	reagents.add_reagent(GREYVODKA, 100)

/obj/item/weapon/reagent_containers/food/drinks/proc/smash(mob/living/M as mob, mob/living/user as mob)
	if(molotov == 1) //for molotovs
		if(lit)
			new /obj/effect/decal/cleanable/ash(get_turf(src))
		else
			new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.drop_item(force_drop = 1)
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(user.loc)
	B.icon_state = src.icon_state
	B.name = src.smashname

	if(istype(src, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))  //for drinking glasses
		B.icon_state = "glass_empty"

	if(prob(33))
		new /obj/item/weapon/shard(get_turf(M || src)) // Create a glass shard at the target's location! O)

	var/icon/I = new('icons/obj/drinks.dmi', B.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	user.put_in_active_hand(B)
	src.transfer_fingerprints_to(B)
	playsound(src, "shatter", 70, 1)

	qdel(src)

//smashing when thrown
/obj/item/weapon/reagent_containers/food/drinks/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	if(isGlass && isturf(loc)) // don't shatter if we got caught mid-flight
		isGlass = 0 //to avoid it from hitting the wall, then hitting the floor, which would cause two broken bottles to appear
		visible_message("<span  class='warning'>The [smashtext][name] shatters!</span>","<span  class='warning'>You hear a shatter!</span>")
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		if(reagents.total_volume)
			if(molotov == 1 || reagents.has_reagent(FUEL))
				user?.attack_log += text("\[[time_stamp()]\] <span class='danger'>Threw a [lit ? "lit" : "unlit"] molotov to \the [hit_atom], containing [reagents.get_reagent_ids()]</span>")
				log_attack("[lit ? "Lit" : "Unlit"] molotov shattered at [formatJumpTo(get_turf(hit_atom))], thrown by [key_name(user)] and containing [reagents.get_reagent_ids()]")
				message_admins("[lit ? "Lit" : "Unlit"] molotov shattered at [formatJumpTo(get_turf(hit_atom))], thrown by [key_name_admin(user)] and containing [reagents.get_reagent_ids()]")
			reagents.reaction(get_turf(src), TOUCH) //splat the floor AND the thing we hit, otherwise fuel wouldn't ignite when hitting anything that wasn't a floor
			if(hit_atom != get_turf(src)) //prevent spilling on the floor twice though
				reagents.reaction(hit_atom, TOUCH)  //maybe this could be improved?
		invisibility = INVISIBILITY_MAXIMUM  //so it stays a while to ignite any fuel

		if(molotov == 1) //for molotovs
			if(lit)
				new /obj/effect/decal/cleanable/ash(get_turf(src))
				var/turf/loca = get_turf(src)
				if(loca)
//					to_chat(world, "<span  class='warning'>Burning...</span>")
					loca.hotspot_expose(700, 1000,surfaces=istype(loc,/turf))
			else
				new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))

		create_broken_bottle()

/obj/item/weapon/reagent_containers/food/drinks/proc/create_broken_bottle()
	//create new broken bottle
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(loc)
	B.name = smashname
	B.icon_state = icon_state

	if(istype(src, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))  //for drinking glasses
		B.icon_state = "glass_empty"

	if(prob(33))
		new /obj/item/weapon/shard(get_turf(src)) // Create a glass shard at the hit location)

	var/icon/Q = new('icons/obj/drinks.dmi', B.icon_state)
	Q.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	Q.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = Q
	src.transfer_fingerprints_to(B)
	playsound(src, "shatter", 70, 1)
	qdel(src)

//////////////////////
// molotov cocktail //
//  by Hinaichigo   //
//////////////////////

/obj/item/weapon/reagent_containers/food/drinks/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/glass/rag) && molotov == -1)  //check if it is a molotovable drink - just beer and ale for now - other bottles require different rag overlay positions - if you can figure this out then go for it
		to_chat(user, "<span  class='notice'>You stuff the [I] into the mouth of the [src].</span>")
		qdel(I)
		I = null //??
		var/obj/item/weapon/reagent_containers/food/drinks/dummy = /obj/item/weapon/reagent_containers/food/drinks/molotov
		molotov = initial(dummy.molotov)
		flags = initial(dummy.flags)
		name = initial(dummy.name)
		smashtext = initial(dummy.smashtext)
		desc = initial(dummy.desc)
		slot_flags = initial(dummy.slot_flags)
		update_icon()
		return 1
	else if(I.is_hot())
		attempt_heating(I, user)
		light(user,I)
		update_brightness(user)
	else if(istype(I, /obj/item/device/assembly/igniter))
		var/obj/item/device/assembly/igniter/C = I
		C.activate()
		light(user,I)
		update_brightness(user)
		return
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/donut))
		if(reagents.total_volume)
			var/obj/item/weapon/reagent_containers/food/snacks/donut/D = I
			D.dip(src, user)

/obj/item/weapon/reagent_containers/food/drinks/molotov
	name = "incendiary cocktail"
	smashtext = ""
	desc = "A rag stuffed into a bottle."
	slot_flags = SLOT_BELT
	flags = FPRINT
	molotov = 1
	isGlass = 1
	icon_state = "vodkabottle" //not strictly necessary for the "abstract" molotov type that the molotov-making-process copies variables from, but is used for pre-spawned molotovs

/obj/item/weapon/reagent_containers/food/drinks/molotov/New()
	..()
	reagents.add_reagent(FUEL, 100) //not strictly necessary for the "abstract" molotov type that the molotov-making-process copies variables from, but is used for pre-spawned molotovs
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/proc/light(mob/user,obj/item/I)
	var/flavor_text = "<span  class='rose'>[user] lights \the [name] with \the [I].</span>"
	if(!lit && molotov == 1)
		lit = 1
		visible_message(flavor_text)
		processing_objects.Add(src)
		update_icon()
	if(!lit && flammable)
		lit = 1
		visible_message(flavor_text)
		flammable = 0
		name = "Flaming [name]"
		desc += " Damn that looks hot!"
		icon_state += "-flamin"
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/proc/update_brightness(var/mob/user = null)
	if(lit)
		set_light(src.brightness_lit)
	else
		kill_light()

//todo: can light cigarettes with
//todo: is force = 15 overwriting the force? //Yes, of broken bottles, but that's been fixed now

////////  Could be expanded upon:
//  make it work with more chemicals and reagents, more like a chem grenade
//  only allow the bottle to be stuffed if there are certain reagents inside, like fuel
//  different flavor text for different means of lighting
//  new fire overlay - current is edited version of the IED one
//  a chance to not break, if desired
//  fingerprints appearing on the object, which might already happen, and the shard
//  belt sprite and new hand sprite
//	ability to put out with water or otherwise
//	burn out after a time causing the contents to ignite
//	make into its own item type so they could be spawned full of fuel with New()
//  colored light instead of white light
//	the rag can store chemicals as well so maybe the rag's chemicals could react with the bottle's chemicals before or upon breaking
//  somehow make it possible to wipe down the bottles instead of exclusively stuffing rags into them
//  make rag retain chemical properties or color (if implemented) after smashing
////////

/obj/item/weapon/reagent_containers/food/drinks/update_icon()
	src.overlays.len = 0
	var/image/Im
	if(molotov == 1)
		Im = image('icons/obj/grenade.dmi', icon_state = "molotov_rag")
		Im.pixel_y += src.bottleheight-23 * PIXEL_MULTIPLIER //since the molotov rag and fire are placed one pixel above the mouth of the bottle, and start out at a height of 23 (for beer and ale)
		overlays += Im
	if(molotov == 1 && lit)
		Im = image('icons/obj/grenade.dmi', icon_state = "molotov_fire")
		Im.pixel_y += src.bottleheight-23 * PIXEL_MULTIPLIER
		overlays += Im
	else
		item_state = initial(item_state)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.update_inv_belt()

	return


/obj/item/weapon/reagent_containers/food/drinks/process()
	var/turf/loca = get_turf(src)
	if(lit && loca)
//		to_chat(world, "<span  class='warning'>Burning...</span>")
		loca.hotspot_expose(700, 1000,surfaces=istype(loc,/turf))
	return

// Sliding from one table to another
/obj/item/weapon/reagent_containers/food/drinks/MouseDropFrom(atom/over_object,atom/src_location,atom/over_location,src_control,over_control,params)
	var/mob/user = usr
	if (!istype(src_location))
		return
	if (!user || user.incapacitated())
		return
	// Attempted drink sliding
	if (locate(/obj/structure/table) in src_location)
		if (M_SOBER in user.mutations)
			if (!user.Adjacent(src))
				return
			var/distance = manhattan_distance(over_location, src)
			if (distance >= 8 || distance == 0) // More than a full screen to go, or we're not moving at all
				return ..()

			// Geometrically checking if we're on a straight line.
			var/vector/V = atoms2vector(src, over_location)
			var/vector/V_norm = V.normalized()
			if (!V_norm.is_integer())
				return ..() // Only a cardinal vector (north, south, east, west) can pass this test

			// Checks if there's tables on the path.
			var/turf/dest = get_translated_turf(V)
			var/turf/temp_turf = src_location

			do
				temp_turf = temp_turf.get_translated_turf(V_norm)
				if (!locate(/obj/structure/table) in temp_turf)
					var/vector/V2 = atoms2vector(src, temp_turf)
					vector_translate(V2, 0.1 SECONDS)
					user.visible_message("<span class='warning'>\The [user] slides \the [src] down the table... and straight into the ground!</span>", "<span class='warning'>You slide \the [src] down the table, and straight into the ground!</span>")
					create_broken_bottle()
					return
			while (temp_turf != dest)

			vector_translate(V, 0.1 SECONDS)
			user.visible_message("<span class='notice'>\The [user] expertly slides \the [src] down the table.</span>", "<span class='notice'>You slide \the [src] down the table. What a pro.</span>")
			return
		else
			if (!(locate(/obj/structure/table) in over_location))
				return ..()
			if (!user.Adjacent(src) || !src_location.Adjacent(over_location)) // Regular users can only do short slides.
				return ..()
			if ((M_CLUMSY in user.mutations) && prob(10))
				user.visible_message("<span class='warning'>\The [user] tries to slide \the [src] down the table, but fails miserably.</span>", "<span class='warning'>You <b>fail</b> to slide \the [src] down the table!</span>")
				create_broken_bottle()
				return
			user.visible_message("<span class='notice'>\The [user] slides \the [src] down the table.</span>", "<span class='notice'>You slide \the [src] down the table!</span>")
			forceMove(over_location, glide_size_override = DELAY2GLIDESIZE(0.4 SECONDS))
			return
	return ..()
