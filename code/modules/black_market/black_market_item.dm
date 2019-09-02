var/list/grey_market_items = list()

//BM stands for black market
#define BM_CHEAP 1
#define BM_NORMAL 2
#define BM_EXPENSIVE 3

/proc/get_grey_market_items()
	if(!grey_market_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		for(var/item in typesof(/datum/grey_market_item))
			var/datum/grey_market_item/I = new item()
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
			if(!grey_market_items[I.category])
				grey_market_items[I.category] = list()

			grey_market_items[I.category] += I

	return grey_market_items

// You can change the order of the list by putting datums before/after one another

/datum/grey_market_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/stock_min	// The stock min and max. Setting stock_min and stock_max to -1 will make it infinite.
	var/stock_max
	var/cost_min    //Same as stock
	var/cost_max
	var/display_chance = 0   //Out of 100
	var/list/delivery_fees = list(0,0.3,0.6) //Delivery fees are a percentage of the base cost. E.g. BM_EXPENSIVE will be base + 0.6*base. BM_CHEAP, BM_NORMAL, BM_EXPENSIVE.
	var/list/delivery_available = list(1,1,1) //Disables the given delivery method if it is 0. BM_CHEAP, BM_NORMAL, BM_EXPENSIVE

	var/round_stock                         //God I love if statements
	var/round_stock_calculated = 0          //Allows for round-to-round variance instead of changing every time you open it
	var/round_cost
	var/round_cost_calculated = 0
	var/active_this_round = 0
	var/active_this_round_calculated = 0

	var/only_on_month	//two-digit month as string
	var/only_on_day		//two-digit day as string

/datum/grey_market_item/proc/is_active()
	if(!active_this_round_calculated)
		if(prob(display_chance))
			active_this_round = 1
		active_this_round_calculated = 1
	. = active_this_round

/datum/grey_market_item/proc/get_cost(var/cost_modifier = 1)
	if(!round_cost_calculated)
		round_cost = rand(cost_min, cost_max)
		round_cost_calculated = 1
	. = Ceiling(round_cost * cost_modifier)

/datum/grey_market_item/proc/get_stock()
	if(!round_stock_calculated)
		round_stock = rand(stock_min, stock_max)
		round_stock_calculated = 1
	if(round_stock == -1)
		. = 999
	else
		. = round_stock

/datum/grey_market_item/proc/process_transaction(var/obj/item/device/illegalradio/radio, var/delivery_method)
	radio.money_stored -= get_cost()
	radio.money_stored -= get_cost()*delivery_fees[delivery_method]
	if(get_stock() && round_stock != -1)
		round_stock -= 1

/datum/grey_market_item/proc/log_transaction(var/delivery_method, var/mob/user)
	feedback_add_details("grey_market_items_bought", name)
	message_admins("[key_name(user)] just purchased the [src.name] from the black market. [delivery_method] ([formatJumpTo(get_turf(user))])")
	var/text = "[key_name(user)] just purchased the [src.name] from the black market."
	log_game(text)
	log_admin(text)

/datum/grey_market_item/proc/buy(var/obj/item/device/illegalradio/radio, var/delivery_method, var/mob/user)
	..()
	if(!istype(radio))
		return FALSE
	if(user.stat || user.restrained())
		return FALSE
	if(!(istype(user,/mob/living/carbon/human)))
		return FALSE
	if(get_stock() <= 0)
		to_chat(user, "<span class='warning'>This item is out of stock. Scram.</span>")
		return FALSE
	if(!((radio.loc in user.contents) || (in_range(radio.loc, user) && istype(radio.loc.loc, /turf))))
		return FALSE
	if(get_cost() > radio.money_stored)
		return FALSE

	switch(delivery_method)
		if(BM_CHEAP)
			spawn_cheap(radio,user)
		if(BM_NORMAL)
			spawn_normal(radio,user)
		if(BM_EXPENSIVE)
			spawn_expensive(radio,user)

/datum/grey_market_item/proc/spawn_cheap(var/obj/item/device/illegalradio/radio, var/mob/user)
	var/direction = pick(list(NORTH,EAST,SOUTH,WEST))
	var/direction_string
	switch(direction)
		if(NORTH)
			direction_string = "north"
		if(EAST)
			direction_string = "east"
		if(SOUTH)
			direction_string = "south"
		if(WEST)
			direction_string = "west"

	log_transaction("The item was launched at the station from the [direction_string].", user)
	radio.visible_message("\The [radio] beeps: <span class='warning'>Your item was launched from the [direction_string]. It will impact the station in less than a minute.</span>")
	process_transaction(radio, BM_CHEAP)
	radio.interact(user)

	spawn(rand(15 SECONDS, 45 SECONDS))
		var/obj/spawned_item = new item(get_turf(user))
		if(!spawned_item)
			if(radio)
				radio.visible_message("\The [radio] beeps: <span class='warning'>Okay, somehow we lost an item we were going to send to you. You've been refunded. Not really sure how that managed to happen.</span>")
				radio.money_stored += get_cost()*delivery_fees[BM_CHEAP]
			if(round_stock != -1)
				round_stock += 1
			return 0
		after_spawn(spawned_item,BM_CHEAP,user)
		spawned_item.ThrowAtStation(30,0.4,direction)

var/list/potential_locations = list()
var/locations_calculated = 0

/datum/grey_market_item/proc/spawn_normal(var/obj/item/device/illegalradio/radio, var/mob/user)
	var/turf/spawnloc
	if(!locations_calculated)
		for(var/area/maintenance/A in areas)
			if(!istype(A,/area/maintenance/atmos) && A.z == STATION_Z)
				potential_locations.Add(A)
		locations_calculated = 1
	var/area/selected_area
	var/list/selection_list = potential_locations.Copy()
	while(selection_list.len)
		selected_area = pick(selection_list)
		selection_list.Remove(selected_area)
		for(var/turf/simulated/floor/floor in selected_area.contents)
			if(!floor.has_dense_content() && !floor.density)
				spawnloc = floor
				break
	if(!spawnloc)
		sleep(2 SECONDS)
		radio.visible_message("\The [radio] beeps: <span class='warning'>Unable to find a proper location for teleportation. You've been downgraded to cheap. No refunds.</span>")
		sleep(2 SECONDS)
		spawn_cheap(radio, user)
		return

	var/time_to_spawn = rand(30 SECONDS, 60 SECONDS)
	log_transaction("The item was teleported to the [selected_area.name].", user)
	radio.visible_message("\The [radio] beeps: <span class='warning'>Your item has been sent through bluespace. It will appear somewhere in [selected_area.name] in [time_to_spawn/10] seconds.</span>")
	process_transaction(radio, BM_NORMAL)
	radio.interact(user)

	spawn(time_to_spawn)
		var/obj/spawned_item = new item(spawnloc,user)
		after_spawn(spawned_item,BM_NORMAL,user)


/datum/grey_market_item/proc/spawn_expensive(var/obj/item/device/illegalradio/radio, var/mob/user)
	process_transaction(radio, BM_EXPENSIVE)
	var/obj/spawned_item = new item(get_turf(user),user)
	if(!spawned_item)
		if(radio)
			radio.visible_message("\The [radio] beeps: <span class='warning'>Okay, somehow we lost an item we were going to send to you. You've been refunded. Not really sure how that managed to happen.</span>")
			radio.money_stored += get_cost()*delivery_fees[BM_EXPENSIVE]
		if(round_stock != -1)
			round_stock += 1
		return 0
	after_spawn(spawned_item,BM_EXPENSIVE,user)
	if(ishuman(user))
		var/mob/living/carbon/human/A = user
		if(istype(spawned_item, /obj/item))
			A.put_in_any_hand_if_possible(spawned_item)

	log_transaction("The item was teleported directly to him.", user)
	radio.visible_message("\The [radio] beeps: <span class='warning'>Thank you for your purchase!</span>")
	radio.interact(user)


/datum/grey_market_item/proc/after_spawn(var/obj/spawned, var/delivery_method, var/mob/user) //Called immediately after spawning. Override for post-spawn behavior.
	return

/*
//
//	PLAYER MARKET DATUM
//
*/	
	
var/list/player_market_items = list()

/datum/grey_market_player_item
	var/atom/item
	var/obj/item/device/grey_market_beacon/attached_beacon
	var/obj/item/device/illegalradio/seller_radio
	var/mob/living/seller
	var/selected_name = ""
	var/selected_price = 100
	var/selected_description = "Enter description here."

/datum/grey_market_player_item/Destroy()
	if(attached_beacon)
		attached_beacon.on_unlist()
	player_market_items -= src
	buzz_grey_market()
	
/datum/grey_market_player_item/proc/buy(var/obj/item/device/illegalradio/radio, var/mob/user)
	..()
	if(!istype(radio))
		return FALSE
	if(user.stat || user.restrained())
		return FALSE
	if(!ishuman(user))
		return FALSE
	if(!user.Adjacent(radio))
		to_chat(user,"<span class='warning'>WARNING: Connection failure. Reduce range.</span>")
		return FALSE
	if(selected_price > radio.money_stored)
		return FALSE
	if(!item)
		radio.visible_message("\The [radio] beeps: <span class='warning'>Uh, so it seems your item has been destroyed. No money charged. Sorry.</span>")
		player_market_items -= src
		qdel(src)

	do_teleport(item, get_turf(user), 0)
	if(ishuman(user))
		var/mob/living/carbon/human/A = user
		if(istype(item, /obj/item))
			A.put_in_any_hand_if_possible(item)
	

	log_transaction(user)
	
	radio.visible_message("The [radio.name] beeps: <span class='warning'>Thank you for your purchase!</span>")
	radio.money_stored -= selected_price
	radio.interact(user)
	
	if(seller_radio)
		seller_radio.money_stored += selected_price*(1-seller_radio.market_cut)
		
	qdel(src)
	
/datum/grey_market_player_item/proc/log_transaction(var/mob/user)
	feedback_add_details("grey_market_items_bought", "[item]")
	message_admins("[key_name(user)] just purchased the [item] from the black market from [key_name(seller)]. ([formatJumpTo(get_turf(user))])")
	var/text = "[key_name(user)] just purchased the [item] from the black market from [key_name(seller)]."
	log_game(text)
	log_admin(text)
	
/datum/grey_market_player_item/proc/on_beacon_destroy()
	attached_beacon = null //Prevents infinite loop
	qdel(src)
		
/*
//
//	BLACK MARKET ITEMS
//
*/

/*
Note by GlassEclipse:
The Grey Market is designed to sell contraband. Typically it sells cheap, low-quality junk
with some potentially dangerous uses. Imagine you go to a dark alley and some guy drags you into a 
boarded, vacant store's backroom and shows you a bunch of dusty goods. Items ought to fit in this store,
but of course don't let me limit your imagination.
There will also be some more rare stuff. Sometimes you walk into a store looking for a grenade and come out
with an atomic bomb. But those are rare and expensive.
*/


/datum/grey_market_item/agriculture
	category = "Agriculture-based Goods"

/datum/grey_market_item/agriculture/carp
	name = "Space Carp"
	desc = "One baby space carp. No refunds."
	item = /mob/living/simple_animal/hostile/carp/baby
	stock_min = 1
	stock_max = 10
	cost_min = 200
	cost_max = 600
	display_chance = 80

/datum/grey_market_item/agriculture/monkeyhide
	name = "Monkey Hide"
	desc = "Your own piece of leather, some assembly required."
	item = /obj/item/stack/sheet/animalhide/monkey
	sps_chances = list(0, 5, 10)
	stock_min = 15
	stock_max = 20
	cost_min = 25
	cost_max = 50
	display_chance = 80

/datum/grey_market_item/agriculture/lizardskin
	name = "Lizard Skin"
	desc = "High quality skins for leather making."
	item = /obj/item/stack/sheet/animalhide/lizard
	sps_chances = list(0, 5, 10)
	stock_min = 10
	stock_max = 20
	cost_min = 50
	cost_max = 100
	display_chance = 70

/datum/grey_market_item/agriculture/humanskin
	name = "Human Skin"
	desc = "Used medical waste."
	item = /obj/item/stack/sheet/animalhide/human
	sps_chances = list(5, 10, 15)
	stock_min = 10
	stock_max = 20
	cost_min = 75
	cost_max = 100
	display_chance = 70

/datum/grey_market_item/agriculture/mushroommanspore
	name = "Packet of Walking Mushroom Seeds"
	desc = "Sentient mushfriends for all your mushy needs."
	item = /obj/item/seeds/mushroommanspore
	delivery_available = list(1, 1, 1)
	stock_min = 3
	stock_max = 3
	cost_min = 50
	cost_max = 100
	display_chance = 99	

/datum/grey_market_item/agriculture/bearmeat
	name = "Bear Meat"
	desc = "A slab of bear meat for the manliest men."
	item = /obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	sps_chances = list(0, 5, 10)
	stock_min = 3
	stock_max = 9
	cost_min = 50
	cost_max = 75
	display_chance = 40

/datum/grey_market_item/agriculture/xenomeat
	name = "Strange Meat"
	desc = "An alien slab of meat."
	item = /obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	sps_chances = list(0, 5, 10)
	stock_min = 3
	stock_max = 9
	cost_min = 50
	cost_max = 75
	display_chance = 40

/datum/grey_market_item/agriculture/humanmeat
	name = "Human Meat"
	desc = "Don't ask questions."
	item = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	sps_chances = list(5, 10, 15)
	stock_min = 9
	stock_max = 18
	cost_min = 100
	cost_max = 150
	display_chance = 69

/datum/grey_market_item/agriculture/blackfoodcolor
	name = "Black Food Color"
	desc = "The namesake for this whole market. You should buy one for that reason alone."
	item = /obj/item/weapon/reagent_containers/food/drinks/coloring
	sps_chances = list(5, 25, 30)
	delivery_available = list(0, 1, 1)
	stock_min = 1
	stock_max = 5
	cost_min = 150
	cost_max = 225
	display_chance = 90

/datum/grey_market_item/tool
	category = "Tools and Utility"

/datum/grey_market_item/tool/stethoscope
	name = "Stethoscope"
	desc = "For medical use only, honest!"
	item = /obj/item/clothing/accessory/stethoscope
	sps_chances = list(5, 25, 30)
	stock_min = 1
	stock_max = 50
	cost_min = 50
	cost_max = 150
	display_chance = 90

/datum/grey_market_item/toy
	category = "Recreational Goods"

/datum/grey_market_item/toy/levitation
	name = "Potion of Levitation"
	desc = "This potion makes you float! How does it work? We've got no clue whatsoever, you'll have to ask the Wizard Federation."
	item = /obj/item/potion/levitation
	delivery_available = list(0, 1, 1)
	stock_min = 2
	stock_max = 4
	cost_min = 200
	cost_max = 300
	display_chance = 70
	
/datum/grey_market_item/toy/dorkcube
	name = "Strange Box"
	desc = "A stolen box filled with unknown loot. Something is sloshing inside."
	item = /obj/item/weapon/winter_gift/dorkcube
	stock_min = 1
	stock_max = 5
	cost_min = 25
	cost_max = 500
	display_chance = 80
	
/datum/grey_market_item/toy/skub
	name = "Skub"
	desc = "Skub."
	item = /obj/item/toy/gasha/skub
	stock_min = -1
	stock_max = -1
	cost_min = 150
	cost_max = 500
	display_chance = 100

#undef BM_CHEAP
#undef BM_NORMAL
#undef BM_EXPENSIVE
