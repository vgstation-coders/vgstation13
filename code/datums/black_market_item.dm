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
			if(!I.is_active())
				continue
			if(!black_market_items[I.category])
				black_market_items[I.category] = list()

			black_market_items[I.category] += I

	return black_market_items

// You can change the order of the list by putting datums before/after one another 

/datum/black_market_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/stock_min	// The stock min and max. Setting stock_min and stock_max to -1 will make it infinite.
	var/stock_max  
	var/cost_min    //Same as stock
	var/cost_max
	var/sps_chance = 30
	var/display_chance = 0   //Out of 100

	var/round_stock                         //God I love if statements
	var/round_stock_calculated = 0          //Allows for round-to-round variance instead of changing every time you open it
	var/round_cost
	var/round_cost_calculated = 0
	var/active_this_round = 0
	var/active_this_round_calculated = 0
	
	var/only_on_month	//two-digit month as string
	var/only_on_day		//two-digit day as string
	
/datum/black_market_item/proc/is_active()
	if(!active_this_round_calculated)
		if(rand(0,100) <= display_chance)
			active_this_round = 1
		active_this_round_calculated = 1
	. = active_this_round
	
/datum/black_market_item/proc/get_cost(var/cost_modifier = 1)
	if(!round_cost_calculated)
		round_cost = rand(cost_min, cost_max)
		round_cost_calculated = 1
	. = Ceiling(round_cost * cost_modifier)

/datum/black_market_item/proc/get_stock()
	if(!round_stock_calculated)
		round_stock = rand(stock_min, stock_max)
		round_stock_calculated = 1
	if(round_stock == -1)
		. = 999
	else
		. = round_stock

	
/datum/black_market_item/proc/spawn_item(var/turf/loc, var/obj/item/device/illegalradio/U, mob/user)
	U.money_stored -= get_cost()
	feedback_add_details("traitor_black_market_items_bought", name)
	message_admins("[key_name(user)] just purchased the [src.name] from the black market. ([formatJumpTo(get_turf(U))])")
	var/text = "[key_name(user)] just purchased the [src.name] from the black market."
	log_game(text)
	log_admin(text)
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
		after_spawn(I,user)
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
	
/datum/black_market_item/proc/after_spawn(var/obj/spawned, var/mob/user) //Called immediately after spawning. Override for post-spawn behavior.
	return

	
/*
//
//	BLACK MARKET ITEMS
//
*/

/*  
Note by GlassEclipse:
The idea of the black market is to have a place to spend excess cash to get items that are both rare and dangerous.
Since having the black market radio is contraband (unless you use the captain's legal version), your item should be 
dangerous or highly unique. It wouldn't be on the illegal market if it wasn't. A good item has the following qualities:
- Can be used for more than murder. I would grab a toolbox if I wanted to just kill someone.
- Usable in many situations; flexible. 
- Fun. A cyborg board that turns them into a peaceful cultist is fun. 
  A 15dev bombcap-breaking bomb that announces its location and can be defused is "fun", as in, it better have one hell of a drawback. 
  A rifle that shoots bullets that do an extra 50 damage is not fun.
Of course, that's not to mean you can't add ANY plain ol' guns. But try to find a good balance.
*/


/datum/black_market_item/tech
	category = "Advanced Technology" 

/datum/black_market_item/tech/chronocarbon
	name = "Chrono-Carbon Grenade" 
	desc = "You ever dream of becoming a master of time? This is the closest thing we got. This grenade explodes into a field of frozen time that has no effect on carbon-based lifeforms. Try not to walk in the path of frozen bullets, they'll hurt once they unfreeze."
	item = /obj/item/weapon/grenade/chronogrenade/carbon
	stock_min = 5
	stock_max = 7
	cost_min = 400
	cost_max = 500
	display_chance = 60

/datum/black_market_item/tech/portalgun
	name = "Portal Gun"
	desc = "This \"gun\" has two options: blue and orange. Shoot twice, and you'll have a wormhole connecting the two. Bluespace technology this potent is... rare. Real rare. That's why you're going to pay us a shitload of cash for it."
	item = /obj/item/weapon/gun/portalgun
	stock_min = 1
	stock_max = 1
	cost_min = 1800
	cost_max = 2200
	display_chance = 80

/datum/black_market_item/tech/lightcycle
	name = "Light Cycle"
	desc = "Fueled by raw energy, this motorbike transcends the boundaries between reality and the virtual world so that you can look cool as shit. We highly suggest to never hit anything that isn't a door. It doesn't end well. They key you receive can be broken to summon the bike, then broken again to dismount."
	item = /obj/item/key/lightcycle/black_market
	stock_min = 1
	stock_max = 1
	cost_min = 3000
	cost_max = 4000
	display_chance = 50
	
/datum/black_market_item/arcane
	category = "Supernatural and Arcane Objects" 
	
/datum/black_market_item/arcane/levitation
	name = "Potion of Levitation"
	desc = "Potions come in many shapes and sizes, but this one makes you float! Why? Because it looks fucking cool."
	item = /obj/item/potion/levitation
	stock_min = 2
	stock_max = 4
	cost_min = 600
	cost_max = 800
	display_chance = 50
	
/datum/black_market_item/arcane/health_potion
	name = "Potion of Health?"
	desc = "Unfortunately, some idiot managed to mix together the shipment of health potions and fake death potions. He's dead now. Test out your luck!"
	item = /obj/item/potion/deception
	stock_min = 2
	stock_max = 4
	cost_min = 600
	cost_max = 800
	display_chance = 70
	
/datum/black_market_item/arcane/health_potion/after_spawn(var/obj/spawned, var/mob/user)
	if(prob(25))
		spawned = /obj/item/potion/healing
	
/*
/datum/black_market_item/arcane/cultist_module //Unfinished
	name = "Cyborg Cultist Module"
	desc = "Apparently some follower of the Geometer of Blood found out a way to peacefully spread the religion of Nar-sie by mass producing cyborg modules. Unfortunately, as you would expect, he got lynched and burned at the stake. Rumors say real cultists can convert cyborgs with this installed."
	item = /obj/item/borg/upgrade/cult
	stock_min = 1
	stock_max = 3
	cost_min = 1400
	cost_max = 2000
	display_chance = 100	
*/

/datum/black_market_item/other
	category = "Miscellaneous Goods" 	

/datum/black_market_item/other/japanese_nanites
	name = "Package of Japanese Nanites"
	desc = "Uh. So, these little nanites turn you into an anime girl in both body and mind. Only a single unit is needed to begin transformation. The black market doesn't judge people's interests..."
	item = /obj/item/weapon/storage/japanese_nanites
	stock_min = 1
	stock_max = 2
	cost_min = 700
	cost_max = 1100
	sps_chance = 70
	display_chance = 65

