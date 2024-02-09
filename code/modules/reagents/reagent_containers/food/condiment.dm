
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
	var/condiment_overlay = null
	var/overlay_colored = FALSE
	var/image/extra_condiment_overlay

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
			reagents.reaction(M, INGEST, amount_override = min(reagents.total_volume,amount_per_transfer_from_this)/(reagents.reagent_list.len))
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
			M.assaulted_by(user)

		if(reagents.total_volume) //Deal with the reagents in the food
			reagents.reaction(M, INGEST, amount_override = min(reagents.total_volume,amount_per_transfer_from_this)/(reagents.reagent_list.len))
			spawn(5)
				reagents.trans_to(M, amount_per_transfer_from_this)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/condiment/afterattack(obj/target, mob/user , flag, params)
	if(!flag || ismob(target))
		return 0
	if(!istype(target, /obj/structure/reagent_dispensers/cauldron) && istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

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
		if (condiment_overlay && istype (target, /obj/item/weapon/reagent_containers/food/snacks))
			var/obj/item/weapon/reagent_containers/food/snacks/snack = target
			var/list/params_list = params2list(params)
			var/image/I = image('icons/obj/condiment_overlays.dmi',snack,condiment_overlay)
			I.pixel_x = clamp(text2num(params_list["icon-x"]) - WORLD_ICON_SIZE/2 - pixel_x,-WORLD_ICON_SIZE/2,WORLD_ICON_SIZE/2)
			I.pixel_y = clamp(text2num(params_list["icon-y"]) - WORLD_ICON_SIZE/2 - pixel_y,-WORLD_ICON_SIZE/2,WORLD_ICON_SIZE/2)
			if (overlay_colored)
				I.color = mix_color_from_reagents(reagents.reagent_list)
			snack.extra_food_overlay.overlays += I
			snack.overlays += I
			snack.visible_condiments[condiment_overlay] = I.color
	else if(isfloor(target))
		if (amount_per_transfer_from_this > 1)
			transfer(target, user, splashable_units = amount_per_transfer_from_this)
		else
			to_chat(user, "<span class='warning'>You have to open the lid at least a bit more to spill condiments on \the [target].</span>")

/obj/item/weapon/reagent_containers/food/condiment/New(loc,altvol)
	if(altvol)
		volume = altvol

	extra_condiment_overlay = image('icons/effects/32x32.dmi',null,"blank")
	..(loc)

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change() //Due to the way condiment bottles work, we define "special types" here

	..()

	if(reagents.reagent_list.len > 0)
		condiment_overlay = null
		overlay_colored = FALSE
		item_state = null
		extra_condiment_overlay.overlays.len = 0
		switch(reagents.get_master_reagent_id())

			if(KETCHUP)
				name = KETCHUP
				desc = "You feel more American already."
				icon_state = KETCHUP
				condiment_overlay = KETCHUP
			if(MUSTARD)
				name = "mustard"
				desc = "A spicy yellow paste."
				icon_state = MUSTARD
				condiment_overlay = MUSTARD
			if(RELISH)
				name = "relish"
				desc = "A pickled cucumber jam. Tasty!"
				icon_state = RELISH
				condiment_overlay = RELISH
			if(CAPSAICIN)
				name = "hotsauce"
				desc = "You can almost TASTE the stomach ulcers now!"
				icon_state = "hotsauce"
				condiment_overlay = "hotsauce"
			if(ENZYME)
				name = "universal enzyme"
				desc = "A universal enzyme used in the preperation of certain chemicals and foods."
				icon_state = ENZYME
			if(FLOUR)
				name = "flour sack"
				desc = "A big bag of flour. Good for baking!"
				icon_state = FLOUR
				condiment_overlay = FLOUR
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
				condiment_overlay = SOYSAUCE
			if(FROSTOIL)
				name = "coldsauce"
				desc = "Leaves the tongue numb in its passage."
				icon_state = "coldsauce"
				condiment_overlay = "coldsauce"
			if(SODIUMCHLORIDE)
				name = "salt shaker"
				desc = "Salt. From space oceans, presumably."
				icon_state = "saltshakersmall"
				condiment_overlay = "salt"
			if(BLACKPEPPER)
				name = "pepper mill"
				desc = "Often used to flavor food or make people sneeze."
				icon_state = "peppermillsmall"
				condiment_overlay = "pepper"
			if(HOLYSALTS)
				name = "holy salts"
				desc = "Blessed salts have been used for centuries as a sacramental. Pouring it on the floor in large enough quantity will offer protection from sources of evil and mend boundaries."
				icon_state = HOLYSALTS
				condiment_overlay = HOLYSALTS
			if(CORNOIL)
				name = "corn oil"
				desc = "A delicious oil used in cooking. Made from corn."
				icon_state = CORNOIL
			if(SUGAR)
				name = SUGAR
				desc = "Tasty space sugar!"
				icon_state = SUGAR
				condiment_overlay = SUGAR
			if(CARAMEL)
				name = CARAMEL
				desc = "Tasty caramel cubes!"
				icon_state = CARAMEL
				condiment_overlay = CARAMEL
			if(CHEFSPECIAL)
				name = "\improper Chef Excellence's Special Sauce"
				desc = "A potent sauce distilled from the toxin glands of 1000 Space Carp with an extra touch of LSD, because why not?"
				icon_state = "emptycondiment"
			if(VINEGAR)
				name = "malt vinegar bottle"
				desc = "Perfect for fish and chips!"
				icon_state = "vinegar_container"
				condiment_overlay = VINEGAR
			if(HONEY)
				name = "honey pot"
				desc = "Sweet and healthy!"
				icon_state = HONEY
				condiment_overlay = HONEY
				var/image/I = image(icon, src, "honey-color")
				I.color = mix_color_from_reagents(reagents.reagent_list)
				extra_condiment_overlay.overlays += I
				var/image/L = image(icon, src, "honey-light") // makes the honey a bit more shiny
				L.blend_mode = BLEND_ADD
				extra_condiment_overlay.overlays += L
				overlay_colored = TRUE
			if(ROYALJELLY)
				name = "royal jelly pot"
				desc = "Spicy and healthy!"
				icon_state = ROYALJELLY
				item_state = HONEY
				condiment_overlay = ROYALJELLY
				var/image/I = image(icon, src, "royaljelly-color")
				I.color = mix_color_from_reagents(reagents.reagent_list)
				extra_condiment_overlay.overlays += I
				overlay_colored = TRUE
			if(CHILLWAX)
				name = "chill wax pot"
				desc = "A bluish wax produced by insects found on Vox worlds. Sweet to the taste, albeit trippy."
				icon_state = CHILLWAX
				condiment_overlay = HONEY
				var/image/I = image(icon, src, "honey-color")
				I.color = mix_color_from_reagents(reagents.reagent_list)
				extra_condiment_overlay.overlays += I
				var/image/L = image(icon, src, "honey-light") // makes the honey a bit more shiny
				L.blend_mode = BLEND_ADD
				extra_condiment_overlay.overlays += L
				overlay_colored = TRUE
			if(CINNAMON)
				name = "cinnamon shaker"
				desc = "A spice, obtained from the bark of cinnamomum trees."
				icon_state = CINNAMON
				condiment_overlay = CINNAMON
			if(GRAVY)
				name = "gravy cruise"
				desc = "Still a bit too small to sail on."
				icon_state = GRAVY
				condiment_overlay = GRAVY
			if(COCO)
				name = "cocoa powder"
				desc = "A vital component for making chocolate."
				icon_state = COCO
				condiment_overlay = COCO
			if(MAYO)
				name = "mayonnaise jar"
				desc = "Not an instrument."
				icon_state = MAYO
				condiment_overlay = MAYO
			if(ZAMSPICES)
				name = "Zam Spice Bottle"
				desc = "A blend of several mothership spices. It has a sharp, tangy aroma."
				icon_state = ZAMSPICES
				condiment_overlay = ZAMSPICES
			if(ZAMMILD)
				name = "Zam's Mild Sauce"
				desc = "A tasty sauce made from mothership spices and acid."
				icon_state = ZAMMILD
				condiment_overlay = ZAMMILD
			if(ZAMSPICYTOXIN)
				name = "Zam's Spicy Sauce"
				desc = "A dangerously flavorful sauce made from mothership spices and powerful acid."
				icon_state = ZAMSPICYTOXIN
				condiment_overlay = ZAMSPICYTOXIN
			if(POLYPGELATIN)
				name = "Polyp Gelatin"
				desc = "A thick and nutritious gelatin collected from space polyps that has a mild, salty taste."
				icon_state = POLYPGELATIN
				condiment_overlay = POLYPGELATIN
			if(CREAM)
				name = "whipped cream dispenser"
				desc = "Instant delight." //placeholder desc
				icon_state = CREAM
				item_state = "whippedcream"
				condiment_overlay = CREAM
			if(LIQUIDBUTTER)
				name = "liquid butter bottle"
				desc = "A one way trip to obesity."
				icon_state = LIQUIDBUTTER
				condiment_overlay = LIQUIDBUTTER
			if(MAPLESYRUP)
				name = "maple syrup"
				desc = "Reddish brown Canadian maple syrup, perfectly sweet and thick. Nutritious and effective at healing."
				icon_state = MAPLESYRUP
				condiment_overlay = MAPLESYRUP
			if(DISCOUNT)
				name = "Discount Dan's Special Sauce"
				desc = "Discount Sauce now in a family sized package."
				icon_state = "discount_sauce"
				condiment_overlay = DISCOUNT
			else
				name = "misc condiment bottle"
				desc = "Just your average condiment container."
				icon_state = "emptycondiment"

				if(reagents.reagent_list.len == 1)
					desc = "It looks like [reagents.get_master_reagent_name()], but you're not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
				icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."

	update_icon()

	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

/obj/item/weapon/reagent_containers/food/condiment/update_icon()
	overlays.len = 0//no choice here but to redraw everything in the correct order so condiments etc don't appear over ice and fire.
	overlays += extra_condiment_overlay
	update_temperature_overlays()
	update_blood_overlay()//re-applying blood stains
	if (on_fire && fire_overlay)
		overlays += fire_overlay

//Specific condiment bottle entities for mapping and potentially spawning (these are NOT used for any above procs)

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "A universal enzyme used in the preperation of certain chemicals and foods."
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

/obj/item/weapon/reagent_containers/food/condiment/mustard
	name = "mustard"
	desc = "A spicy yellow paste."

/obj/item/weapon/reagent_containers/food/condiment/mustard/New()
	..()
	reagents.add_reagent(MUSTARD, 50)

/obj/item/weapon/reagent_containers/food/condiment/relish
	name = "relish"
	desc = "A pickled cucumber jam. Tasty!"

/obj/item/weapon/reagent_containers/food/condiment/relish/New()
	..()
	reagents.add_reagent(RELISH, 50)

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

/obj/item/weapon/reagent_containers/food/condiment/caramel
	name = "caramel"
	desc = "Tasty caramel cubes!"

/obj/item/weapon/reagent_containers/food/condiment/caramel/New()
	..()
	reagents.add_reagent(CARAMEL, 50)

/obj/item/weapon/reagent_containers/food/condiment/honey
	name = "honey pot"
	desc = "Sweet and healthy!"

/obj/item/weapon/reagent_containers/food/condiment/honey/New()
	..()
	reagents.add_reagent(HONEY, 50)

/obj/item/weapon/reagent_containers/food/condiment/royaljelly
	name = "royal jelly pot"
	desc = "Spicy and healthy!"

/obj/item/weapon/reagent_containers/food/condiment/royaljelly/New()
	..()
	reagents.add_reagent(ROYALJELLY, 50)

/obj/item/weapon/reagent_containers/food/condiment/cinnamon
	name = "cinnamon shaker"
	desc = "A spice, obtained from the bark of cinnamomum trees."

/obj/item/weapon/reagent_containers/food/condiment/cinnamon/New()
	..()
	reagents.add_reagent(CINNAMON, 50)

/obj/item/weapon/reagent_containers/food/condiment/discount
	name = "Discount Dan's Special Sauce"
	desc = "Discount Sauce now in a family sized package."

/obj/item/weapon/reagent_containers/food/condiment/discount/New()
	..()
	reagents.add_reagent(DISCOUNT, 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker
	name = "salt shaker"
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1, 10, 50)
	amount_per_transfer_from_this = 1

/obj/item/weapon/reagent_containers/food/condiment/saltshaker/New()
	..()
	reagents.add_reagent(SODIUMCHLORIDE, 50)

/obj/item/weapon/reagent_containers/food/condiment/holysalts
	name = "holy salts"
	desc = "Blessed salts have been used for centuries as a sacramental. Pouring it on the floor in large enough quantity will offer protection from sources of evil and mend boundaries."
	icon_state = "holysalts"
	possible_transfer_amounts = list(1, 10, 50)
	amount_per_transfer_from_this = 10

/obj/item/weapon/reagent_containers/food/condiment/holysalts/New()
	..()
	reagents.add_reagent(HOLYSALTS, 50)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1, 10, 50)
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
	//~6.5% chance of anything but special sauce, which is 0.65% chance
	var/global/list/possible_exotic_condiments = list(
	ENZYME=10,
	BLACKPEPPER=10,
	VINEGAR=10,
	SODIUMCHLORIDE=10,
	CINNAMON=10,
	FROSTOIL=10,
	SOYSAUCE=10,
	CAPSAICIN=10,
	HONEY=10,
	KETCHUP=10,
	MUSTARD=10,
	RELISH=10,
	COCO=10,
	ZAMSPICES=10,
	DISCOUNT=10,
	ZAMMILD=5,
	ZAMSPICYTOXIN=3,
	ROYALJELLY=5,
	CHEFSPECIAL=1)

/obj/item/weapon/reagent_containers/food/condiment/exotic/New()
	..()
	reagents.add_reagent(pickweight(possible_exotic_condiments), 30)

/obj/item/weapon/reagent_containers/food/condiment/coco
	name = "cocoa powder"
	desc = "A vital component for making chocolate."

/obj/item/weapon/reagent_containers/food/condiment/coco/New()
	..()
	reagents.add_reagent(COCO, 50)


/obj/item/weapon/reagent_containers/food/condiment/mayo
	name = "mayonnaise jar"
	desc = "we have such sights to show you."

/obj/item/weapon/reagent_containers/food/condiment/mayo/New()
	..()
	reagents.add_reagent(MAYO, 50)


/obj/item/weapon/reagent_containers/food/condiment/zamspices
	name = "Zam Spice Bottle"
	desc = "A blend of several mothership spices. It has a sharp, tangy aroma."

/obj/item/weapon/reagent_containers/food/condiment/zamspices/New()
	..()
	reagents.add_reagent(ZAMSPICES, 50)

/obj/item/weapon/reagent_containers/food/condiment/zammild
	name = "Zam's Mild Sauce"
	desc = "A tasty sauce made from mothership spices and acid."

/obj/item/weapon/reagent_containers/food/condiment/zammild/New()
	..()
	reagents.add_reagent(ZAMMILD, 50)

/obj/item/weapon/reagent_containers/food/condiment/zamspicytoxin
	name = "Zam's Spicy Sauce"
	desc = "A dangerously flavorful sauce made from mothership spices and powerful acid."

/obj/item/weapon/reagent_containers/food/condiment/zamspicytoxin/New()
	..()
	reagents.add_reagent(ZAMSPICYTOXIN, 50)

/obj/item/weapon/reagent_containers/food/condiment/polypgelatin
	name = "Polyp Gelatin Bottle"
	desc = "A thick, nutritious gelatin collected from space polyps. It has a mild flavor with a hint of salt."

/obj/item/weapon/reagent_containers/food/condiment/polypgelatin/New()
	..()
	reagents.add_reagent(POLYPGELATIN, 50)


/obj/item/weapon/reagent_containers/food/condiment/cream
	name = "whipped cream dispenser"
	desc = "Instant delight!"

/obj/item/weapon/reagent_containers/food/condiment/cream/New()
	..()
	reagents.add_reagent(CREAM, 50)


/obj/item/weapon/reagent_containers/food/condiment/liquidbutter
	name = "liquid butter bottle"
	desc = "A one way trip to obesity."

/obj/item/weapon/reagent_containers/food/condiment/liquidbutter/New()
	..()
	reagents.add_reagent(LIQUIDBUTTER, 50)


/obj/item/weapon/reagent_containers/food/condiment/maple_syrup
	name = "maple syrup"
	desc = "Reddish brown Canadian maple syrup, perfectly sweet and thick. Nutritious and effective at healing."

/obj/item/weapon/reagent_containers/food/condiment/maple_syrup/New()
	..()
	reagents.add_reagent(MAPLESYRUP, 50)


/obj/item/weapon/reagent_containers/food/condiment/chillwax
	name = "chill wax pot"
	desc = "A bluish wax produced by insects found on Vox worlds. Sweet to the taste, albeit trippy."

/obj/item/weapon/reagent_containers/food/condiment/chillwax/New()
	..()
	reagents.add_reagent(CHILLWAX, 50)

//////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/condiment/small
	icon_state = "packet_"
	possible_transfer_amounts = list(1, 5)
	amount_per_transfer_from_this = 1
	var/trash_type = /obj/item/trash/misc_packet
	var/custom = FALSE

/obj/item/weapon/reagent_containers/food/condiment/small/afterattack(obj/target, mob/user , flag, params)
	if(!istype(target, /obj/structure/reagent_dispensers/cauldron) && istype(target, /obj/structure/reagent_dispensers))
		return FALSE
	. = ..()

/obj/item/weapon/reagent_containers/food/condiment/small/is_open_container()
	return FALSE	// This should prevent most ways the packet could emptied other than by being applied on food.
					// Worst case scenario, the empty packet will appear on the ground.

/obj/item/weapon/reagent_containers/food/condiment/small/on_reagent_change() //Due to the way condiment bottles work, we define "special types" here
	if(reagents.reagent_list.len > 0)
		condiment_overlay = null
		overlay_colored = FALSE
		item_state = null
		extra_condiment_overlay.overlays.len = 0
		switch(reagents.get_master_reagent_id())
			if(KETCHUP)
				name = KETCHUP
				desc = "You feel more American already."
				condiment_overlay = KETCHUP
			if(MAYO)
				name = "mayonnaise packet"
				desc = "Still not an instrument."
				condiment_overlay = MAYO
			if(CAPSAICIN)
				name = "hotsauce packet"
				desc = "For those who can't handle the real heat."
				condiment_overlay = "hotsauce"
			if(SOYSAUCE)
				name = "soy sauce"
				desc = "Tasty soy sauce in a convenient tiny packet."
				condiment_overlay = SOYSAUCE
			if(VINEGAR)
				name = "malt vinegar packet"
				desc = "Perfect for smaller portions of fish and chips."
				condiment_overlay = VINEGAR
			if(DISCOUNT)
				name = "Discount Dan's Special Sauce"
				desc = "Discount Dan brings you his very own special blend of delicious ingredients in one discount sauce!"
				condiment_overlay = DISCOUNT
			if(ZAMSPICES)
				name = "Zam Spice packet"
				desc = "A tiny packet of mothership spices."
				condiment_overlay = ZAMSPICES
			if(ZAMMILD)
				name = "Zam's Mild Sauce packet"
				desc = "More portable than the bottle, just as tasty."
				condiment_overlay = ZAMMILD
			if(ZAMSPICYTOXIN)
				name = "Zam's Spicy Sauce packet"
				desc = "More portable than the bottle, just as spicy."

				condiment_overlay = ZAMSPICYTOXIN
			else
				if(!name) //these should probably just be ternaries
					name = "misc condiment packet"
				if (!desc)
					desc = "A varied condiment packet."
				if(!has_icon(icon, "packet_"))
					icon_state = "packet_misc"
				overlay_colored = TRUE
				var/image/packetcolor = image('icons/obj/food_condiment.dmi', src, "packet_overlay")
				packetcolor.icon += mix_color_from_reagents(reagents.reagent_list)
				packetcolor.alpha = mix_alpha_from_reagents(reagents.reagent_list)
				extra_condiment_overlay.overlays += packetcolor
		icon_state = "[initial(icon_state)]" + condiment_overlay
		update_icon()
	else
		if(is_empty() && trash_type)
			var/obj/item/trash/trash = new trash_type(get_turf(src))
			if (ismob(loc))
				var/mob/M = loc
				var/hand_index = M.is_holding_item(src)
				M.drop_item(src, M.loc)
				if (hand_index)
					M.put_in_hand(hand_index, trash)
					M.update_inv_hands()
			qdel(src)
		else
			update_icon()

//-------------------------------------------------------------------------

/obj/item/weapon/reagent_containers/food/condiment/small/ketchup
	name = "ketchup packet"
	desc = "You feel more American already."
	condiment_overlay = KETCHUP
	trash_type = /obj/item/trash/ketchup_packet

/obj/item/weapon/reagent_containers/food/condiment/small/ketchup/New()
	..()
	reagents.add_reagent(KETCHUP, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/mayo
	name = "mayonnaise packet"
	desc = "Still not an instrument."
	condiment_overlay = MAYO
	trash_type = /obj/item/trash/mayo_packet

/obj/item/weapon/reagent_containers/food/condiment/small/mayo/New()
	..()
	reagents.add_reagent(MAYO, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/soysauce
	name = "soy sauce packet"
	desc = "Tasty soy sauce in a convenient tiny packet."
	condiment_overlay = SOYSAUCE
	trash_type = /obj/item/trash/soysauce_packet

/obj/item/weapon/reagent_containers/food/condiment/small/soysauce/New()
	..()
	reagents.add_reagent(SOYSAUCE, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/vinegar
	name = "malt vinegar packet"
	desc = "Perfect for smaller portions of fish and chips."
	condiment_overlay = VINEGAR
	trash_type = /obj/item/trash/vinegar_packet

/obj/item/weapon/reagent_containers/food/condiment/small/vinegar/New()
	..()
	reagents.add_reagent(VINEGAR, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/hotsauce
	name = "hotsauce packet"
	desc = "For those who can't handle the real heat."
	condiment_overlay = "hotsauce"
	trash_type = /obj/item/trash/hotsauce_packet

/obj/item/weapon/reagent_containers/food/condiment/small/hotsauce/New()
	..()
	reagents.add_reagent(CAPSAICIN, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/zamspices
	name = "Zam Spices Packet"
	desc = "A tiny packet of mothership spices."
	condiment_overlay = ZAMSPICES
	trash_type = /obj/item/trash/zamspices_packet

/obj/item/weapon/reagent_containers/food/condiment/small/zamspices/New()
	..()
	reagents.add_reagent(ZAMSPICES, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/zammild
	name = "Zam's Mild Sauce Packet"
	desc = "More portable than the bottle, just as tasty."
	condiment_overlay = ZAMMILD
	trash_type = /obj/item/trash/zammild_packet

/obj/item/weapon/reagent_containers/food/condiment/small/zammild/New()
	..()
	reagents.add_reagent(ZAMMILD, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/zamspicytoxin
	name = "Zam's Spicy Sauce Packet"
	desc = "More portable than the bottle, just as spicy."
	condiment_overlay = ZAMSPICYTOXIN
	trash_type = /obj/item/trash/zamspicytoxin_packet

/obj/item/weapon/reagent_containers/food/condiment/small/zamspicytoxin/New()
	..()
	reagents.add_reagent(ZAMSPICYTOXIN, 5)

/obj/item/weapon/reagent_containers/food/condiment/small/discount
	name = "Discount Dan's Special Sauce"
	desc = "Discount Dan brings you his very own special blend of delicious ingredients in one discount sauce!"
	condiment_overlay = DISCOUNT
	trash_type = /obj/item/trash/discount_packet

/obj/item/weapon/reagent_containers/food/condiment/small/discount/New()
	..()
	reagents.add_reagent(DISCOUNT, 3)

//////////////////////////////////////////////////////////////////////////////////////////////
//I hate it but it works

/obj/item/weapon/reagent_containers/food/condiment/fake_bottle
	invisibility = 101

/obj/item/weapon/reagent_containers/food/condiment/fake_bottle/proc/splash_that(var/obj/item/weapon/reagent_containers/food/snacks/snack, var/datum/reagent/source_reagent)
	if (!istype(snack) || !source_reagent)
		qdel(src)
		return
	if(snack.reagents.total_volume >= snack.reagents.maximum_volume)
		qdel(src)
		return
	reagents.add_reagent(source_reagent.id, source_reagent.volume*2, source_reagent.data)
	reagents.trans_to(snack.reagents, source_reagent.volume)
	if (condiment_overlay)
		var/image/I = image('icons/obj/condiment_overlays.dmi',snack,condiment_overlay)
		I.pixel_x = rand(-3,3)
		I.pixel_y = rand(-3,3)
		if (overlay_colored)
			I.color = mix_color_from_reagents(source_reagent.holder.reagent_list)
		snack.extra_food_overlay.overlays += I
		snack.overlays += I
	qdel(src)
