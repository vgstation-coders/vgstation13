var/list/black_market_items = list()

/proc/get_black_market_items()
	if(!black_market_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		for(var/item in typesof(/datum/black_market_item))
			var/datum/black_market_item/I = new item()
			if(!I.item)
				continue
			if(I.only_on_month)
				if(time2text(world.realtime,"MM") != I.only_on_month)
					continue
			if(I.only_on_day)
				if(time2text(world.realtime,"DD") != I.only_on_day)
					continue

			if(!black_market_items[I.category])
				black_market_items[I.category] = list()

			black_market_items[I.category] += I

	return black_market_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/black_market_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/num_in_stock = 0	// The stock avaliable. -1 is infinite if stock_deviation is 0.
	var/stock_deviation = 0   //The range of stock RNG. 2 deviation with stock 5 will be anywhere from 3-7.
	var/cost = 0
	var/cost_deviation        //Same as stock deviation, but for cost.
	var/display_chance = 0
	var/abstract = 0 //Indicates if datum is to actually be displayed

	var/only_on_month	//two-digit month as string
	var/only_on_day		//two-digit day as string
	var/static/round_stock                         //God I love if statements
	var/static/round_stock_calculated = 0          //Allows for round-to-round variance instead of changing every time you open it
	var/static/round_cost
	var/static/round_cost_calculated = 0
	var/static/active_this_round = 0
	var/static/active_this_round_calculated = 0
	
/datum/black_market_item/proc/is_active()
	if(!active_this_round_calculated)
		if(rand(0,100) <= display_chance)
			active_this_round = 1
		active_this_round_calculated = 1
	. = active_this_round
	
/datum/black_market_item/proc/get_cost(var/cost_modifier = 1)
	if(!round_cost_calculated)
		round_cost = rand(cost-cost_deviation,cost+cost_deviation)
		round_cost_calculated = 1
	. = Ceiling(round_cost * cost_modifier)

/datum/black_market_item/proc/get_stock()
	if(!round_stock_calculated)
		round_stock = rand(num_in_stock-stock_deviation,num_in_stock+stock_deviation)
		round_stock_calculated = 1
	. = round_stock

	
/datum/black_market_item/proc/spawn_item(var/turf/loc, var/obj/item/device/illegalradio/U, mob/user)
	U.money_stored -= get_cost()
	feedback_add_details("traitor_black_market_items_bought", name)
	message_admins("[key_name(user)] just purchased the [src.name] from the black market. ([formatJumpTo(get_turf(U))])")
	return new item(loc,user)

/datum/black_market_item/proc/buy(var/obj/item/device/illegalradio/U, var/mob/user)
	..()
	if(!istype(U)) 
		return 0

	if(user.stat || user.restrained())
		return 0

	if(!(istype(user,/mob/living/carbon/human)))
		return 0

	if(get_stock() <= 0)
		to_chat(user, "<span class='warning'>This item is out of stock. Scram.</span>")
		return 0

	// If the black_market's holder is in the user's content
	if((U.loc in user.contents) || (in_range(U.loc, user) && istype(U.loc.loc, /turf)))
		user.set_machine(U)
		if(get_cost() > U.money_stored)
			return 0

		var/obj/I = spawn_item(get_turf(user), U, user)
		if(!I)
			return 0
		on_item_spawned(I,user)
		var/icon/tempimage = icon(I.icon, I.icon_state)
		end_icons += tempimage
		var/tempstate = end_icons.len

		if(ishuman(user))
			var/mob/living/carbon/human/A = user

			if(istype(I, /obj/item))
				A.put_in_any_hand_if_possible(I)

			U.purchase_log += {"[user] ([user.ckey]) bought <img src="logo_[tempstate].png"> [name] for [get_cost()]."}
			//stat_collection.black_market_purchase(src, I, user)
			if(get_stock() != 0)
				round_stock -= 1

		U.interact(user)

		return 1
	return 0

/datum/black_market_item/proc/on_item_spawned(var/obj/I, var/mob/user)
	return

	
/*
//
//	BLACK MARKET ITEMS
//
*/

/*   Examples
/datum/black_market_item/example_category
	category = "Pomf's Collection" //Header of category
	only_on_month = "05" //Month and day as 2-digit string, this item can only be bought on May 15th. Can use one or both fields. Leaving it blank makes it avaliable always.
	only_on_day = "15"
	
/datum/black_market_item/example_category/example_item
	name = "Pomf's Feather Drawing Tool" //As a child of example_category, it is only shown when example_category is shown (May 15th)
	desc = "Yeah, this stuff's the real shit. You'll be the best chicken around town - just be sure not to poke yourself with it." //Thematically, descriptions should be written in the persona of a shady drug dealer.
	item = /obj/item/weapon/pen/paralysis/pomf //Path to item.
	num_in_stock = 6       //With these two variables there will be anywhere from 4-6 avaliable in stock.
	stock_deviation = 2 
	cost = 500 //Pomf ain't cheap. Items should be overpriced.
	cost_deviation = 50 //Like stock above, cost will be anywhere from 450 to 550.
	display_chance = 100 //Odds out of 100 that the item will be displayed. Randomized every round. 
	
/datum/black_market_item/example_category/example_item/on_item_spawned(var/obj/I, var/mob/user) //This is called right after spawning the item. Override it since there are no delegates in BYOND (tm)
	I/ownerEngraving = user.name
	
Note by GlassEclipse:
The idea of the black market is to have a place to spend excess cash to get items that are both rare and dangerous.
Since having the black market radio makes you valid to everybody (unless you use the captain's legal version), your 
item should be dangerous. It wouldn't be on the illegal market if it wasn't. A good item has the following qualities:
- Can be used for more than murder. I would grab a toolbox if I wanted to just kill someone.
- Usable in many situations; flexible. 
- Fun. A remote controlled robot that can carry and use items is fun. 15dev bombcap-breaking bomb is "fun". 
  A rifle that shoots bullets that do an extra 50 damage is not fun.
Of course, that's not to mean you can't add ANY plain ol' guns. But try to find a good balance.
*/

/datum/black_market_item/gear
	category = "Tools and Gear" 
	
/datum/black_market_item/gear
	name = "Modified Organ Extractor" 
	desc = "This baby, she's our bread and butter. She can extract any organ out of an unconscious body in the blink of an eye - except the heart, that is. Why do we want organs from real people instead of growing them? Beats me."
	item = /obj/item/weapon/organ_remover/traitor
	num_in_stock = 4
	stock_deviation = 2
	cost = 1000
	cost_deviation = 200
	display_chance = 100 

