var/list/black_market_items = list()

//BM stands for black market
#define BM_CHEAP 1
#define BM_NORMAL 2
#define BM_EXPENSIVE 3

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
	var/display_chance = 0   //Out of 100
	var/list/sps_chances = list(5, 10, 30) //Chance for SPS alert for each delivery method out of 100. BM_CHEAP, BM_NORMAL, BM_EXPENSIVE.
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

/datum/black_market_item/proc/is_active()
	if(!active_this_round_calculated)
		if(prob(display_chance))
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

/datum/black_market_item/proc/process_transaction(var/obj/item/device/illegalradio/radio, var/delivery_method)
	radio.money_stored -= get_cost()
	radio.money_stored -= get_cost()*delivery_fees[delivery_method]
	if(get_stock() && round_stock != -1)
		round_stock -= 1

/datum/black_market_item/proc/log_transaction(var/delivery_method, var/mob/user)
	feedback_add_details("black_market_items_bought", name)
	message_admins("[key_name(user)] just purchased the [src.name] from the black market. [delivery_method] ([formatJumpTo(get_turf(user))])")
	var/text = "[key_name(user)] just purchased the [src.name] from the black market."
	log_game(text)
	log_admin(text)

/datum/black_market_item/proc/buy(var/obj/item/device/illegalradio/radio, var/delivery_method, var/mob/user)
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

/datum/black_market_item/proc/spawn_cheap(var/obj/item/device/illegalradio/radio, var/mob/user)
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
	radio.visible_message("The [radio.name] beeps: <span class='warning'>Your item was launched from the [direction_string]. It will impact the station in less than a minute.</span>")
	process_transaction(radio, BM_CHEAP)
	radio.interact(user)

	spawn(rand(15 SECONDS, 45 SECONDS))
		var/obj/spawned_item = new item(get_turf(user))
		if(!spawned_item)
			if(radio)
				radio.visible_message("The [radio.name] beeps: <span class='warning'>Okay, somehow we lost an item we were going to send to you. You've been refunded. Not really sure how that managed to happen.</span>")
				radio.money_stored += get_cost()*delivery_fees[BM_CHEAP]
			if(round_stock != -1)
				round_stock += 1
			return 0
		after_spawn(spawned_item,BM_CHEAP,user)
		spawned_item.ThrowAtStation(30,0.4,direction)
		spawn(rand(30 SECONDS, 60 SECONDS))
			if(!radio.nanotrasen_variant && prob(sps_chances[BM_CHEAP]))
				SPS_black_market_alert("Centcomm has detected a black market purchase of item: [name]. It was launched at the station recently.")


var/list/potential_locations = list()
var/locations_calculated = 0

/datum/black_market_item/proc/spawn_normal(var/obj/item/device/illegalradio/radio, var/mob/user)
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
		radio.visible_message("The [radio.name] beeps: <span class='warning'>Unable to find a proper location for teleportation. You've been downgraded to cheap. No refunds.</span>")
		sleep(2 SECONDS)
		spawn_cheap(radio, user)
		return

	var/time_to_spawn = rand(30 SECONDS, 60 SECONDS)
	log_transaction("The item was teleported to the [selected_area.name].", user)
	radio.visible_message("The [radio.name] beeps: <span class='warning'>Your item has been sent through bluespace. It will appear somewhere in [selected_area.name] in [time_to_spawn/10] seconds.</span>")
	process_transaction(radio, BM_NORMAL)
	radio.interact(user)

	spawn(time_to_spawn)
		var/obj/spawned_item = new item(spawnloc)
		after_spawn(spawned_item,BM_NORMAL,user)
		spawn(rand(30 SECONDS, 60 SECONDS))
			if(!radio.nanotrasen_variant && prob(sps_chances[BM_NORMAL]))
				SPS_black_market_alert("Centcomm has detected a black market purchase of item: [name]. It was teleported to your station's maintenance recently.")

/datum/black_market_item/proc/spawn_expensive(var/obj/item/device/illegalradio/radio, var/mob/user)
	process_transaction(radio, BM_EXPENSIVE)
	var/obj/spawned_item = new item(get_turf(user))
	if(!spawned_item)
		if(radio)
			radio.visible_message("The [radio.name] beeps: <span class='warning'>Okay, somehow we lost an item we were going to send to you. You've been refunded. Not really sure how that managed to happen.</span>")
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
	radio.visible_message("The [radio.name] beeps: <span class='warning'>Thank you for your purchase!</span>")
	radio.interact(user)

	spawn(rand(30 SECONDS, 60 SECONDS))
		if(!radio.nanotrasen_variant && prob(sps_chances[BM_EXPENSIVE]))
			SPS_black_market_alert("Centcomm has detected a black market purchase of item: [name]. It was teleported directly to the buyer in the past minute.")


/datum/black_market_item/proc/after_spawn(var/obj/spawned, var/delivery_method, var/mob/user) //Called immediately after spawning. Override for post-spawn behavior.
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
  A 15dev bombcap-breaking bomb that announces its location and can be defused is "fun", as in, it better have one hell of a drawback and be used once every 30 rounds at best.
  A rifle that shoots bullets that do an extra 50 damage is not fun.
Of course, that's not to mean you can't add ANY plain guns. But try to find a good balance. Most items shouldn't be for murderboning, it just isn't fun
for anyone but the person committing mass murder.
*/


//datum/black_market_item/tech
	//category = "Advanced Technology"

//datum/black_market_item/arcane
	//category = "Supernatural and Arcane Objects"

/datum/black_market_item/animal
	category = "Living or Once Living Goods."

/datum/black_market_item/animal/carp
	name = "Space Carp"
	desc = "One baby space carp.  No refunds."
	item = /mob/living/simple_animal/hostile/carp/baby
	sps_chances = list(50, 60, 70)
	stock_min = 1
	stock_max = 10
	cost_min = 200
	cost_max = 600
	display_chance = 80

/datum/black_market_item/animal/monkeyhide
	name = "Monkey Hide"
	desc = "Your own piece of leather, some assembly required."
	item = /obj/item/stack/sheet/animalhide/monkey
	sps_chances = list(0, 5, 10)
	stock_min = 15
	stock_max = 20
	cost_min = 25
	cost_max = 50
	display_chance = 80

/datum/black_market_item/animal/lizardskin
	name = "Lizard Skin"
	desc = "High quality skins for leather making."
	item = /obj/item/stack/sheet/animalhide/lizard
	sps_chances = list(0, 5, 10)
	stock_min = 10
	stock_max = 20
	cost_min = 50
	cost_max = 100
	display_chance = 70

/datum/black_market_item/animal/humanskin
	name = "Human Skin"
	desc = "Used medical waste."
	item = /obj/item/stack/sheet/animalhide/human
	sps_chances = list(5, 10, 15)
	stock_min = 10
	stock_max = 20
	cost_min = 75
	cost_max = 100
	display_chance = 70

/datum/black_market_item/plants
	category = "Seeds"

/datum/black_market_item/plants/mushroommanspore
	name = "Packet of Walking Mushroom Seeds"
	desc = "Sentient mushfriends for all your mushy needs"
	item = /obj/item/seeds/mushroommanspore
	sps_chances = list(0, 10, 30)
	delivery_available = list(0, 1, 1)
	stock_min = 3
	stock_max = 3
	cost_min = 50
	cost_max = 100
	display_chance = 99

/datum/black_market_item/food
	category = "Cooked Goods and Kitchen Items."

/datum/black_market_item/food/bearmeat
	name = "Bear Meat"
	desc = "A slab of bear meat for the manliest men."
	item = /obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	sps_chances = list(0, 5, 10)
	stock_min = 3
	stock_max = 9
	cost_min = 50
	cost_max = 75
	display_chance = 40

/datum/black_market_item/food/xenomeat
	name = "Strange Meat"
	desc = "An alien slab of meat."
	item = /obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	sps_chances = list(0, 5, 10)
	stock_min = 3
	stock_max = 9
	cost_min = 50
	cost_max = 75
	display_chance = 40

/datum/black_market_item/food/human
	name = "Human Meat"
	desc = "Don't ask questions."
	item = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	sps_chances = list(5, 10, 15)
	stock_min = 9
	stock_max = 18
	cost_min = 100
	cost_max = 150
	display_chance = 69

/datum/black_market_item/food/blackfoodcolor
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

/datum/black_market_item/tool
	category = "Utility Items"

/datum/black_market_item/tool/stethoscope
	name = "Stethoscope"
	desc = "For medical use only, honest!"
	item = /obj/item/clothing/accessory/stethoscope
	sps_chances = list(5, 25, 30)
	stock_min = 1
	stock_max = 50
	cost_min = 50
	cost_max = 150
	display_chance = 90

/datum/black_market_item/toy
	category = "Recreational and Novelty Items"

/datum/black_market_item/toy/dorkcube
	name = "Strange Box"
	desc = "A stolen box filled with unknown loot.  Something is sloshing inside."
	item = /obj/item/weapon/winter_gift/dorkcube
	sps_chances = list(0, 10, 30)
	stock_min = 1
	stock_max = 5
	cost_min = 25
	cost_max = 500
	display_chance = 80

/datum/black_market_item/toy/skub
	name = "Skub"
	desc = "Skub."
	item = /obj/item/toy/gasha/skub
	sps_chances = list(5, 25, 75)
	stock_min = -1
	stock_max = -1
	cost_min = 200
	cost_max = 500
	display_chance = 100

#undef BM_CHEAP
#undef BM_NORMAL
#undef BM_EXPENSIVE
