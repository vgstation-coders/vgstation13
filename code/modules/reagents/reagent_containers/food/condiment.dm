
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind
//To clarify, these are special containers used to hold reagents specific to cooking, produced from the Kitchen CondiMaster
/obj/item/weapon/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/drinkingglass.dmi', "right_hand" = 'icons/mob/in-hand/right/drinkingglass.dmi')
	icon = 'icons/obj/food_condiment.dmi'
	icon_state = "emptycondiment"
	item_state = null
	flags = FPRINT  | OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/weapon/W as obj, mob/user as mob)

	return

/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user as mob)

	attack(user, user)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/living/M as mob, mob/user as mob, def_zone)

	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		to_chat(user, "<span class='warning'>\The [src] is empty.</span>")
		return 0

	if(M == user) //user drinking it

		to_chat(M, "<span class='notice'>You swallow some of the contents of \the [src].</span>")
		if(reagents.total_volume) //Deal with the reagents in the food
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, amount_per_transfer_from_this)

		playsound(M.loc,'sound/items/drink.ogg', rand(10, 50), 1)
		return 1

	else if(istype(M, /mob/living/carbon)) //user feeding M the condiment. M also being carbon

		M.visible_message("<span class='danger'>[user] attempts to feed [M] \the [src]</span>", \
		"<span class='danger'>[user] attempts to feed you \the [src]</span>")

		if(!do_mob(user, M))
			return

		M.visible_message("<span class='danger'>[user] feeds [M] \the [src]</span>", \
		"<span class='danger'>[user] feeds you \the [src]</span>")

		//Logging shit
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(reagents.total_volume) //Deal with the reagents in the food
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, amount_per_transfer_from_this)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/I as obj, mob/user as mob) //We already have an attackby for weapons, but sure, whatever

	return

/obj/item/weapon/reagent_containers/food/condiment/afterattack(obj/target, mob/user , flag)
	if(!flag || ismob(target))
		return 0
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume) //Nothing in the dispenser
			to_chat(user, "<span class='warning'>\The [target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume) //Our condiment bottle is full
			to_chat(user, "<span class='warning'>\The [src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>\The [src] is empty.</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>You can't add anymore to \the [target].</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to \the [target].</span>")

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change() //Due to the way condiment bottles work, we define "special types" here

	if(reagents.reagent_list.len > 0)

		item_state = null
		switch(reagents.get_master_reagent_id())

			if(KETCHUP)
				name = KETCHUP
				desc = "You feel more American already."
				icon_state = KETCHUP
			if(CAPSAICIN)
				name = "hotsauce"
				desc = "You can almost TASTE the stomach ulcers now!"
				icon_state = "hotsauce"
			if(ENZYME)
				name = "universal enzyme"
				desc = "Used in cooking various dishes."
				icon_state = ENZYME
			if(FLOUR)
				name = "flour sack"
				desc = "A big bag of flour. Good for baking!"
				icon_state = FLOUR
			if(MILK)
				name = "space milk"
				desc = "It's milk. White and nutritious goodness!"
				icon_state = MILK
			if(SOYMILK)
				name = "soy milk"
				desc = "It's soy milk. White and nutritious goodness!"
				icon_state = SOYMILK
			if(RICE)
				name = "rice sack"
				desc = "A taste of Asia in the kitchen."
				icon_state = RICE
			if(SOYSAUCE)
				name = "soy sauce"
				desc = "A salty soy-based flavoring."
				icon_state = SOYSAUCE
			if(FROSTOIL)
				name = "coldsauce"
				desc = "Leaves the tongue numb in its passage."
				icon_state = "coldsauce"
			if(SODIUMCHLORIDE)
				name = "salt shaker"
				desc = "Salt. From space oceans, presumably."
				icon_state = "saltshakersmall"
			if(BLACKPEPPER)
				name = "pepper mill"
				desc = "Often used to flavor food or make people sneeze."
				icon_state = "peppermillsmall"
			if(CORNOIL)
				name = "corn oil"
				desc = "A delicious oil used in cooking. Made from corn."
				icon_state = CORNOIL
			if(SUGAR)
				name = SUGAR
				desc = "Tasty space sugar!"
				icon_state = SUGAR
			if(CHEFSPECIAL)
				name = "\improper Chef Excellence's Special Sauce"
				desc = "A potent sauce distilled from the toxin glands of 1000 Space Carp with an extra touch of LSD, because why not?"
				icon_state = "emptycondiment"
			if(VINEGAR)
				name = "malt vinegar bottle"
				desc = "Perfect for fish and chips!"
				icon_state = "vinegar_container"
				item_state = null
			if(HONEY)
				name = "honey pot"
				desc = "Sweet and healthy!"
				icon_state = HONEY
				item_state = null
			if(CINNAMON)
				name = "cinnamon shaker"
				desc = "A spice, obtained from the bark of cinnamomum trees."
				icon_state = CINNAMON
			if(GRAVY)
				icon_state = GRAVY
			else
				name = "misc condiment bottle"
				desc = "Just your average condiment container."
				icon_state = "emptycondiment"

				if(reagents.reagent_list.len == 1)
					desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
				icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."

	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

//Specific condiment bottle entities for mapping and potentially spawning (these are NOT used for any above procs)

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = ENZYME

/obj/item/weapon/reagent_containers/food/condiment/enzyme/New()
	..()
	reagents.add_reagent(ENZYME, 50)

/obj/item/weapon/reagent_containers/food/condiment/enzyme/restock()
	if(istype(src,/obj/item/weapon/reagent_containers/food/condiment/enzyme))
		if(reagents.get_reagent_amount(ENZYME) < 50)
			reagents.add_reagent(ENZYME, 2)

/obj/item/weapon/reagent_containers/food/condiment/ketchup
	name = "ketchup"
	desc = "You feel more American already."

/obj/item/weapon/reagent_containers/food/condiment/ketchup/New()
	..()
	reagents.add_reagent(KETCHUP, 50)

/obj/item/weapon/reagent_containers/food/condiment/hotsauce
	name = "hotsauce"
	desc = "You can almost TASTE the stomach ulcers now!"

/obj/item/weapon/reagent_containers/food/condiment/hotsauce/New()
	..()
	reagents.add_reagent(CAPSAICIN, 50)

/obj/item/weapon/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"

/obj/item/weapon/reagent_containers/food/condiment/flour/New()
	..()
	reagents.add_reagent(FLOUR, 50)

/obj/item/weapon/reagent_containers/food/condiment/spacemilk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"

/obj/item/weapon/reagent_containers/food/condiment/spacemilk/New()
	..()
	reagents.add_reagent(MILK, 50)

/obj/item/weapon/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"

/obj/item/weapon/reagent_containers/food/condiment/soymilk/New()
	..()
	reagents.add_reagent(SOYMILK, 50)

/obj/item/weapon/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "A taste of Asia in the kitchen."

/obj/item/weapon/reagent_containers/food/condiment/rice/New()
	..()
	reagents.add_reagent(RICE, 50)

/obj/item/weapon/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."

/obj/item/weapon/reagent_containers/food/condiment/soysauce/New()
	..()
	reagents.add_reagent(SOYSAUCE, 50)

/obj/item/weapon/reagent_containers/food/condiment/coldsauce
	name = "coldsauce"
	desc = "Leaves the tongue numb in its passage."

/obj/item/weapon/reagent_containers/food/condiment/coldsauce/New()
	..()
	reagents.add_reagent(FROSTOIL, 50)

/obj/item/weapon/reagent_containers/food/condiment/cornoil
	name = "corn oil"
	desc = "A delicious oil used in cooking. Made from corn."

/obj/item/weapon/reagent_containers/food/condiment/cornoil/New()
	..()
	reagents.add_reagent(CORNOIL, 50)

/obj/item/weapon/reagent_containers/food/condiment/sugar
	name = "sugar"
	desc = "Tasty space sugar!"

/obj/item/weapon/reagent_containers/food/condiment/sugar/New()
	..()
	reagents.add_reagent(SUGAR, 50)

/obj/item/weapon/reagent_containers/food/condiment/honey
	name = "honey pot"
	desc = "Sweet and healthy!"

/obj/item/weapon/reagent_containers/food/condiment/honey/New()
	..()
	reagents.add_reagent("honey", 50)

/obj/item/weapon/reagent_containers/food/condiment/cinnamon
	name = "cinnamon shaker"
	desc = "A spice, obtained from the bark of cinnamomum trees."

/obj/item/weapon/reagent_containers/food/condiment/cinnamon/New()
	..()
	reagents.add_reagent(CINNAMON, 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker
	name = "salt shaker"
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1, 50) //For clowns turning the lid off.
	amount_per_transfer_from_this = 1

/obj/item/weapon/reagent_containers/food/condiment/saltshaker/New()
	..()
	reagents.add_reagent(SODIUMCHLORIDE, 50)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1, 50) //For clowns turning the lid off.
	amount_per_transfer_from_this = 1

/obj/item/weapon/reagent_containers/food/condiment/peppermill/New()
	..()
	reagents.add_reagent(BLACKPEPPER, 50)

/obj/item/weapon/reagent_containers/food/condiment/syndisauce
	name = "Chef Excellence's Special Sauce"
	desc = "A potent sauce distilled from the toxin glands of 1000 Space Carp with an extra touch of LSD, because why not?"
	amount_per_transfer_from_this = 1

/obj/item/weapon/reagent_containers/food/condiment/syndisauce/New()
	..()
	reagents.add_reagent(CHEFSPECIAL, 20)

/obj/item/weapon/reagent_containers/food/condiment/vinegar
	name = "malt vinegar bottle"
	desc = "Perfect for fish and chips."

/obj/item/weapon/reagent_containers/food/condiment/vinegar/New()
	..()
	reagents.add_reagent(VINEGAR, 50)

/obj/item/weapon/reagent_containers/food/condiment/gravy
	name = "gravy boat"
	desc = "Too small to set sail on."
	volume = 10 //So nutrment isn't added

/obj/item/weapon/reagent_containers/food/condiment/gravy/New()
	..()
	reagents.add_reagent(GRAVY, 10)

/obj/item/weapon/reagent_containers/food/condiment/gravy/gravybig
	name = "gravy cruise"
	desc = "Still a bit too small to sail on."
	volume = 50

/obj/item/weapon/reagent_containers/food/condiment/gravy/gravybig/New()
	..()
	reagents.add_reagent(GRAVY, 50)

/obj/item/weapon/reagent_containers/food/condiment/exotic
	name = "exotic bottle"
	desc = "If you can see this label, something is wrong."
	//~9% chance of anything but special sauce, which is .09 chance
	var/global/list/possible_exotic_condiments = list(ENZYME=10,BLACKPEPPER=10,VINEGAR=10,SODIUMCHLORIDE=10,CINNAMON=10,CHEFSPECIAL=1,FROSTOIL=10,SOYSAUCE=10,CAPSAICIN=10,HONEY=10,KETCHUP=10,COCO=10)

/obj/item/weapon/reagent_containers/food/condiment/exotic/New()
	..()
	reagents.add_reagent(pickweight(possible_exotic_condiments), 30)
