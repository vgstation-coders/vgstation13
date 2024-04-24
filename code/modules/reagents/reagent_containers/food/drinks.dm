#define FLIPPING_DURATION	7
#define FLIPPING_ROTATION	360
#define FLIPPING_INCREMENT	FLIPPING_ROTATION / 8

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
	var/randpix = FALSE // Does it offset itself on spawn?
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

	//bottle flipping
	var/can_flip = FALSE
	var/last_flipping = 0
	var/atom/movable/overlay/flipping = null

/obj/item/weapon/reagent_containers/food/drinks/on_reagent_change()
	..()
	if(gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)

	if(is_empty())
		update_icon() //we just got emptied, so let's update our icon once, if only to remove the ice overlay.

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

/obj/item/weapon/reagent_containers/food/drinks/arcane_act(mob/user)
	..()
	cant_drop = 1
	return prob(50) ? "D'TA EX'P'GED!" : "R'D'CTED!"

/obj/item/weapon/reagent_containers/food/drinks/bless()
	..()
	cant_drop = 0

/obj/item/weapon/reagent_containers/food/drinks/pickup(var/mob/user)
	..()
	if(ishuman(user) && arcanetampered) // wizards turn it into SCP-198
		var/mob/living/carbon/human/H = user
		reagents.clear_reagents()
		H.audible_scream()
		H.adjustHalLoss(50)
		H.vessel.trans_to(reagents,reagents.maximum_volume)
	update_icon()
	if (can_flip && (M_SOBER in user.mutations) && (user.a_intent == I_GRAB))
		if (flipping && (M_CLUMSY in user.mutations) && prob(20))
			to_chat(user, "<span class='warning'>Your clumsy fingers fail to catch back \the [src].</span>")
			user.drop_item(src, user.loc, 1)
			throw_impact(user.loc,1,user)
		else
			bottleflip(user)

/obj/item/weapon/reagent_containers/food/drinks/dropped(var/mob/user)
	..()
	if(flipping)
		QDEL_NULL(flipping)
		last_flipping = world.time
		item_state = initial(item_state)
		playsound(loc,'sound/effects/slap2.ogg', 5, 1, -2)

/obj/item/weapon/reagent_containers/food/drinks/proc/bottleflip(var/mob/user)
	playsound(loc,'sound/effects/woosh.ogg', 10, 1, -2)
	last_flipping = world.time
	var/this_flipping = last_flipping
	item_state = "invisible"
	user.update_inv_hands()
	if (flipping)
		qdel(flipping)
	var/pixOffX = 0
	var/list/offsets = user.get_item_offset_by_index(user.active_hand)
	var/pixOffY = offsets["y"]
	var/fliplay = user.layer + 1
	var/rotate = 1
	var/anim_icon_state = initial(item_state)
	if (!anim_icon_state)
		anim_icon_state = initial(icon_state)
	switch (user.get_direction_by_index(user.active_hand))
		if ("right_hand")
			switch(user.dir)
				if (NORTH)
					pixOffX = 3
					fliplay = user.layer - 1
					rotate = -1
				if (SOUTH)
					pixOffX = -4
				if (WEST)
					pixOffX = -7
				if (EAST)
					pixOffX = 2
					rotate = -1
		if ("left_hand")
			switch(user.dir)
				if (NORTH)
					pixOffX = -4
					fliplay = user.layer - 1
				if (SOUTH)
					pixOffX = 3
					rotate = -1
				if (WEST)
					pixOffX = -2
				if (EAST)
					pixOffX = 7
					rotate = -1
	flipping = anim(target = user, a_icon = 'icons/obj/bottleflip.dmi', a_icon_state = anim_icon_state, sleeptime = FLIPPING_DURATION, offX = pixOffX, lay = fliplay, offY = pixOffY)
	animate(flipping, pixel_y = pixOffY + 12, transform = turn(matrix(), rotate*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 18, transform = turn(matrix(), rotate*2*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 21, transform = turn(matrix(), rotate*3*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 24, transform = turn(matrix(), rotate*4*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 21, transform = turn(matrix(), rotate*5*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 18, transform = turn(matrix(), rotate*6*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 12, transform = turn(matrix(), rotate*7*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = pixOffY + 0, transform = turn(matrix(), rotate*8*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	spawn (FLIPPING_DURATION)
		if ((loc == user) && (this_flipping == last_flipping))//only the last flipping action will reset the bottle's vars
			QDEL_NULL(flipping)
			last_flipping = world.time
			item_state = initial(item_state)
			if ((M_CLUMSY in user.mutations) && prob(20))
				to_chat(user, "<span class='warning'>Your clumsy fingers fail to catch back \the [src].</span>")
				user.drop_item(src, user.loc, 1)
				throw_impact(user.loc,1,user)
			else
				user.update_inv_hands()
				playsound(loc,'sound/effects/slap2.ogg', 10, 1, -2)

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/living/M as mob, mob/user as mob, def_zone)
	//Smashing on someone
	if(!controlled_splash && user.a_intent == I_HURT && isGlass && molotov != 1)  //To smash a bottle on someone, the user must be harm intent, the bottle must be out of glass, and we don't want a rag in here

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
		M.assaulted_by(user)

		//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
		if(src.reagents)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='bnotice'>The contents of \the [smashtext][src] splashes all over [M]!</span>"), 1)
			src.reagents.reaction(M, TOUCH, zone_sels = list(user.zone_sel.selecting))

		//Finally, smash the bottle. This kills (del) the bottle.
		src.smash(M, user)

		return

	else if(!is_open_container())
		to_chat(user, "<span class='warning'>You can't, \the [src] is closed.</span>")//Added this here and elsewhere to prevent drinking, etc. from closed drink containers. - Hinaichigo

		return 0

	else if(!reagents?.total_volume)
		to_chat(user, "<span class='warning'>\The [src] is empty.<span>")
		return 0

	else if(M == user)
		imbibe(user)
		return 0

	else if(istype(M, /mob/living/carbon/human) && (!controlled_splash || user.a_intent == I_HELP))

		user.visible_message("<span class='danger'>[user] attempts to feed [M] \the [src].</span>", "<span class='danger'>You attempt to feed [M] \the [src].</span>")

		if(!do_mob(user, M))
			return

		user.visible_message("<span class='danger'>[user] feeds [M] \the [src].</span>", "<span class='danger'>You feed [M] \the [src].</span>")

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		M.assaulted_by(user)

		if(reagents.total_volume)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.chem_flags & NO_DRINK)
					reagents.reaction(get_turf(H), TOUCH)
					H.visible_message("<span class='warning'>The contents in [src] fall through and splash onto the ground, what a mess!</span>")
					reagents.remove_any(gulp_size)
					return 0

			reagents.reaction(M, INGEST, amount_override = min(reagents.total_volume,gulp_size)/(reagents.reagent_list.len))
			spawn(5)
				reagents.trans_to(M, gulp_size)

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			var/refill = reagents.get_master_reagent_id()
			spawn(600)
				reagents.add_reagent(refill, gulp_size)

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

	if (!controlled_splash)
		// Attempt to transfer from our glass
		transfer(target, user, can_send = TRUE, can_receive = FALSE)
		return

	var/transfer_result = transfer(target, user, splashable_units = amount_per_transfer_from_this)
	if (transfer_result)
		splash_special()
	if((transfer_result >= 10) && (isturf(target) || istype(target, /obj/machinery/portable_atmospherics/hydroponics)))	//if we're splashing a decent amount of reagent on the floor
		playsound(target, 'sound/effects/slosh.ogg', 25, 1)

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

	if(arcanetampered && ishuman(user) && !reagents.total_volume)
		var/mob/living/carbon/human/H = user
		H.vessel.trans_to(reagents,reagents.maximum_volume)
		return 0

/obj/item/weapon/reagent_containers/food/drinks/New()
	..()
	if(randpix)
		pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
		pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
	base_icon_state = icon_state

/obj/item/weapon/reagent_containers/food/drinks/attack_ghost(mob/dead/observer/user)
	if(!src || !user)
		return
	if(get_dist(src, user) > 1)
		return
	if(reagents?.has_reagent(ECTOPLASM))
		if(!is_open_container())
			to_chat(user, "<span class='warning'>You can't, [src] is closed.</span>")
			return

		else if(!reagents?.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.<span>")
			return

		else
			//user.delayNextAttack(1 SECONDS) Since humans can rapid-drink, we'll leave this commented out for now.
			to_chat(user, "<span  class='notice'>You swallow a gulp of [src].</span>")
			reagents.remove_any(gulp_size)
			playsound(user.loc,'sound/items/drink_ghost.ogg', rand(10,50), 1)
	else
		to_chat(user, "<span class='notice'>You pass right through [src].</span>")

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
	can_flip = TRUE
	reagents_to_add = MILK
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/flour
	name = "\improper flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon = 'icons/obj/food_condiment.dmi'
	icon_state = "flour"
	reagents_to_add = FLOUR
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon = 'icons/obj/food_condiment.dmi'
	icon_state = "soymilk"
	vending_cat = "dairy products"//it's not a dairy product but oh come on who cares
	can_flip = TRUE
	reagents_to_add = SOYMILK
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	reagents_to_add = list(COFFEE = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/coffee/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/latte
	name = "Smooth Latte"
	desc = "A pleasant soft taste of latte will sooth any and all pain, while relaxing music plays in your head."
	icon_state = "coffee"
	reagents_to_add = list(CAFE_LATTE = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/latte/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/soy_latte
	name = "Soy Latte"
	desc = "Soy version of a latte for soy people."
	icon_state = "coffee"
	reagents_to_add = list(SOY_LATTE = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/soy_latte/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/cappuccino
	name = "Cappuccino"
	desc = "You will ask yourself: how is cappuccino different from latte? It tastes the same; and you will be right."
	icon_state = "coffee"
	reagents_to_add = list(CAPPUCCINO = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/cappuccino/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/espresso
	name = "Zip Espresso"
	desc = "When you need a small and quick kick."
	icon_state = "coffee"
	reagents_to_add = list(ESPRESSO = 15)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/espresso/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/doppio
	name = "Doppio x2"
	desc = "Double espresso made only out of the finest twin coffee beans."
	icon_state = "coffee"
	reagents_to_add = list(DOPPIO = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/doppio/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Tea"
	icon = 'icons/obj/cafe.dmi'
	icon_state = "mug_empty"
	item_state = "mug_empty"
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/tea/New()
	switch(rand(1,3))
		if(1)
			name = "Duke Purple Tea"
			desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
			reagents_to_add = list(TEA = 30)
		if(2)
			name = "Century Tea"
			desc = "In most cultures, if you leave tea out for months it's considered spoiled. Although this tea is black, we still consider it good for cultural reasons. Taste the century."
			reagents_to_add = list(REDTEA = 30)
		if(3)
			name = "Hippie Farms Eco-Tea"
			desc = "Remember when the station was powered by solar panels instead of raping space for its plasma, then creating an engine of destruction? Hippie Farms remembers, maaaan."
			reagents_to_add = list(GREENTEA = 30)
	..()

/obj/item/weapon/reagent_containers/food/drinks/tea/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/tea/update_icon()
	..()
	if (reagents.reagent_list.len > 0)
		mug_reagent_overlay()

/obj/item/weapon/reagent_containers/food/drinks/tea/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/chifir
	name = "Siberian Chifir"
	desc = "Only a true siberian can appreciate its deep and rich flavor. Embrace siberian tradition!"
	icon_state = "tea"
	item_state = "mug_empty"
	reagents_to_add = list(CHIFIR = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/chifir/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "\improper ice cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "icecup"
	randpix = TRUE
	reagents_to_add = list(ICE = list("volume" = 30,"temp" = T0C))

/obj/item/weapon/reagent_containers/food/drinks/tomatosoup
	name = "Tomato Soup"
	desc = "Tomato Soup! In a cup!"
	icon_state = "tomatosoup"
	randpix = TRUE
	reagents_to_add = list(TOMATO_SOUP = list("volume" = 30,"temp" = T80C))

/obj/item/weapon/reagent_containers/food/drinks/tomatosoup/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "mug_empty"
	item_state = "mug_empty"
	reagents_to_add = list(HOT_COCO = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate/update_icon()
	..()
	if (reagents.reagent_list.len > 0)
		mug_reagent_overlay()

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate/on_vending_machine_spawn()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "\improper cup ramen"
	desc = "A taste that reminds you of your school years."
	icon_state = "ramen"
	reagents_to_add = list(DRY_RAMEN = 30)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating //vendor version
	name = "\improper cup ramen"
	desc = "Just add 12ml water, self heats!"
	icon_state = "ramen"
	reagents_to_add = list(DRY_RAMEN = 30, CALCIUMOXIDE = 2)
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/zam_nitrofreeze
	name = "Zam Nitro Freeze"
	desc = "The mothership has synthesized the coldest of cold drinks! Can your brain handle the freeze?" // It is not wise to chug this whole drink.
	icon_state = "Zam_NitroFreeze"
	randpix = TRUE
	reagents_to_add = list(NITROGEN, FROSTOIL = 15)

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen
	name = "Discount Dan's Noodle Soup"
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	icon_state = "ramen"
	randpix = TRUE
	reagents_to_add = list(DRY_RAMEN = 20, DISCOUNT = 10, TOXICWASTE = 4, GREENRAMEN = 4, GLOWINGRAMEN = 4, DEEPFRIEDRAMEN = 4)
	var/pulled = FALSE
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Sm?rg?sbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/New()
	..()
	name = pick(ddname)

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/attack_self(mob/user as mob)
	if(!pulled)
		to_chat(user, "You pull the tab, you feel the drink heat up in your hands, and its horrible fumes hits your nose like a ton of bricks. You drop the soup in disgust.")
		desc += " It feels warm..." //This is required
		pulled = TRUE
		reagents_to_add = list(DRY_RAMEN = 20, DISCOUNT = 10, TOXICWASTE = 8, GLOWINGRAMEN = 8)
		refill()
		user.drop_from_inventory(src)

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/hot
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates! It feels warm..."
	randpix = TRUE
	pulled = TRUE
	reagents_to_add = list(DRY_RAMEN = 20, DISCOUNT = 10, TOXICWASTE = 8, GLOWINGRAMEN = 8)

/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. In space."
	icon_state = "beer"
	vending_cat = "fermented"
	molotov = -1 //can become a molotov
	isGlass = 1
	can_flip = TRUE
	randpix = TRUE
	reagents_to_add = list(BEER = 30)

/obj/item/weapon/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	vending_cat = "fermented"
	molotov = -1 //can become a molotov
	isGlass = 1
	can_flip = TRUE
	randpix = TRUE
	reagents_to_add = list(ALE = 30)

/obj/item/weapon/reagent_containers/food/drinks/coloring
	name = "\improper vial of food coloring"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vial"
	volume = 25
	possible_transfer_amounts = list(1,5)
	randpix = TRUE
	reagents_to_add = BLACKCOLOR

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "\improper paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
	randpix = TRUE

/obj/item/weapon/reagent_containers/food/drinks/sillycup/on_reagent_change()
	..()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

/obj/item/weapon/reagent_containers/food/drinks/danswhiskey
	name = "Discount Dan's 'Malt' Whiskey"
	desc = "The very cheapest and most sickening method of liver failure."
	icon_state = "dans_whiskey"
	randpix = TRUE
	reagents_to_add = list(DANS_WHISKEY = 30)

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
	can_flip = TRUE
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
		if(flipping)
			QDEL_NULL(flipping)
			last_flipping = world.time
			item_state = initial(item_state)
			playsound(loc,'sound/effects/slap2.ogg', 10, 1, -2)
		shaking = TRUE
		var/adjective = pick("furiously","passionately","with vigor","with determination","like a devil","with care and love","like there is no tomorrow")
		user.visible_message("<span class='notice'>\The [user] shakes \the [src] [adjective]!</span>","<span class='notice'>You shake \the [src] [adjective]!</span>")
		icon_state = icon_state + "-shake"
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
		playsound(user, 'sound/items/boston_shaker.ogg', 80, 1)
		if(do_after(user, src, 30))
			reagents.trans_to(reaction,volume)
			reaction.reagents.trans_to(reagents,volume)
		icon_state = initial(icon_state)
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
		shaking = FALSE

/obj/item/weapon/reagent_containers/food/drinks/shaker/reaction
	flags = FPRINT  | OPENCONTAINER | SILENTCONTAINER
	volume = 300

//bluespace shaker

/obj/item/weapon/reagent_containers/food/drinks/shaker/bluespaceshaker
	name = "\improper bluespace shaker"
	desc = "A bluespace shaker to mix drinks in."
	icon_state = "bluespaceshaker"
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_MATERIALS + "=6"
	starting_materials = list(MAT_IRON = 5000, MAT_GLASS = 5000)
	w_type = RECYK_GLASS
	w_class = W_CLASS_SMALL
	volume = 300

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
	desc = "A metal flask which insulates its contents from temperature - keeping hot beverages hot, and cold ones cold. You can remove its cap to use as a cup."
	icon_state = "vacuumflask"
	origin_tech = Tc_MATERIALS + "=1"
	amount_per_transfer_from_this = 10
	volume = 100
	thermal_variation_modifier = 0
	var/obj/item/weapon/reagent_containers/food/drinks/thermos_cap/cap

/obj/item/weapon/reagent_containers/food/drinks/thermos/New()
	..()
	cap = new(src)

/obj/item/weapon/reagent_containers/food/drinks/thermos/attack_self(var/mob/user)
	if (cap)
		to_chat(user, "<span class='warning'>Remove the cap with your other hand first.</span>")
		return
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/thermos/attack_hand(var/mob/user)
	if (cap && (loc == user) && (src == user.get_inactive_hand()))
		user.put_in_hands(cap)
		cap = null
		to_chat(user, "<span class='notice'>You remove the Thermos' cap.</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1, -3)
		icon_state = "vacuumflask_open"
		update_temperature_overlays()
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/thermos/attackby(var/obj/item/I, var/mob/user, params)
	..()
	if (!cap && istype(I, /obj/item/weapon/reagent_containers/food/drinks/thermos_cap))
		var/obj/item/weapon/reagent_containers/food/drinks/thermos_cap/C = I
		if (C.reagents.total_volume)
			return ..()
		if(user.drop_item(C, src))
			cap = C
		playsound(loc, 'sound/effects/slap2.ogg', 50, 1, -3)
		to_chat(user, "<span class='notice'>You place the Thermos' cap back on.</span>")
		icon_state = "vacuumflask"
		update_temperature_overlays()
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/thermos/thermal_entropy()
	thermal_entropy_containers.Remove(src)
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/thermos/update_temperature_overlays()
	//we only care about the steam

	if(!cap && reagents && reagents.total_volume)
		steam_spawn_adjust(reagents.chem_temp)
	else
		steam_spawn_adjust(0)

/obj/item/weapon/reagent_containers/food/drinks/thermos/full/New()
	reagents_to_add = list(pick(COFFEE, HOT_COCO, ICECOFFEE, TEA, ICETEA, WATER, ICE, ICED_BEER) = rand(50,100))
	..()
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/drinks/thermos_cap
	name = "\improper Thermos cap"
	desc = "You can use the Thermos' cap as a small cup. The liquids in the cap will react to the environment's temperature."
	amount_per_transfer_from_this = 30
	volume = 30
	icon_state = "vacuumflask_cap"

/obj/item/weapon/reagent_containers/food/drinks/thermos_cap/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/thermos_cap/update_icon()
	..()
	if (reagents.reagent_list.len > 0)
		icon_state = base_icon_state
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "thermos_cap")
		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += filling


/obj/item/weapon/reagent_containers/food/drinks/plastic
	name = "\improper plastic bottle"
	desc = "Remember to recycle."
	icon_state = "plasticbottle"
	origin_tech = Tc_MATERIALS + "=1"
	melt_temperature = MELTPOINT_PLASTIC
	starting_materials = list(MAT_PLASTIC = 500)
	w_type = RECYK_PLASTIC
	volume = 100
	amount_per_transfer_from_this = 10

/obj/item/weapon/reagent_containers/food/drinks/plastic/water
	name = "\improper water bottle"
	desc = "Chemically enhanced mineral water."
	icon_state = "waterbottle"
	reagents_to_add = WATER

/obj/item/weapon/reagent_containers/food/drinks/plastic/water/small
	name = "\improper small water bottle"
	icon_state = "waterbottle_small"
	volume = 50
	amount_per_transfer_from_this = 5

/obj/item/weapon/reagent_containers/food/drinks/plastic/sodawater
	name = "\improper Soda Water bottle"
	desc = "Good ole carbonated water."
	icon_state = "sodawaterbottle"
	reagents_to_add = SODAWATER

/obj/item/weapon/reagent_containers/food/drinks/plastic/cola
	name = "\improper Space Cola bottle"
	desc = "During hard times, place your trust in mega corporations, and their sponsored drinks."
	icon_state = "colaplasticbottle"
	reagents_to_add = COLA

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "\improper Captain's flask"
	desc = "A metal flask belonging to the captain."
	icon_state = "flask"
	origin_tech = Tc_MATERIALS + "=1"
	volume = 60
	can_flip = TRUE

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
	reagents_to_add = list(KARMOTRINE = 15)

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
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/flagmug/update_icon()
	..()
	if (reagents.reagent_list.len > 0)
		mug_reagent_overlay()
	update_blood_overlay()

/obj/item/weapon/reagent_containers/food/drinks/flagmug/britcup
	name = "\improper cup"
	desc = "A cup with the British flag emblazoned on it."
	icon_state = "britcup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/americup
	name = "\improper cup"
	desc = "A cup with the American flag emblazoned on it."
	icon_state = "americup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/francecup
	name = "\improper cup"
	desc = "A cup with the French flag emblazoned on it."
	icon_state = "francecup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/italycup
	name = "\improper cup"
	desc = "A cup with the Italian flag emblazoned on it."
	icon_state = "italycup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/germancup
	name = "\improper cup"
	desc = "A cup with the German flag emblazoned on it."
	icon_state = "germancup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/spanishcup
	name = "\improper cup"
	desc = "A cup with the Spanish flag emblazoned on it."
	icon_state = "spanishcup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/irelandcup
	name = "\improper cup"
	desc = "A cup with the Irish flag emblazoned on it."
	icon_state = "irelandcup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/uruguaycup
	name = "\improper cup"
	desc = "A cup with the Uruguayan flag emblazoned on it."
	icon_state = "uruguaycup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/argentinacup
	name = "\improper cup"
	desc = "A cup with the Argentine flag emblazoned on it."
	icon_state = "argentinacup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/brasilcup
	name = "\improper cup"
	desc = "A cup with the Brasilian flag emblazoned on it."
	icon_state = "brasilcup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/chilecup
	name = "\improper cup"
	desc = "A cup with the Chilean flag emblazoned on it."
	icon_state = "chilecup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/uncup
	name = "\improper cup"
	desc = "A cup with the United Nations flag emblazoned on it."
	icon_state = "uncup"

/obj/item/weapon/reagent_containers/food/drinks/flagmug/eucup
	name = "\improper cup"
	desc = "A cup with the European flag emblazoned on it."
	icon_state = "eucup"

/obj/item/weapon/reagent_containers/food/drinks/gromitmug
	name = "\improper Gromit Mug"
	desc = "Gromit Mug."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "gromitmug"
	volume = 30

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

#undef FLIPPING_DURATION
#undef FLIPPING_ROTATION
#undef FLIPPING_INCREMENT
