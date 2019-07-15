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
	var/display_chance = 0   //Out of 100
	var/list/sps_chances = list(5, 10, 30) //Chance for SPS alert for each delivery method out of 100. Cheap, Normal, Expensive.
	var/list/delivery_fees = list(0,0.3,0.6) //Delivery fees are a percentage of the base cost. E.g. expensive will be base + 0.6*base. Cheap, Normal, Expensive.
	var/list/delivery_available = list(1,1,1) //Disables the given delivery method if it is 0. Cheap, Normal, Expensive

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

	
/datum/black_market_item/proc/spawn_item(var/turf/loc, var/obj/item/device/illegalradio/radio, mob/user)
	radio.money_stored -= get_cost()
	return new item(loc,user)

/datum/black_market_item/proc/log_transaction(var/delivery_method, var/mob/user)
	feedback_add_details("black_market_items_bought", name)
	message_admins("[key_name(user)] just purchased the [src.name] from the black market. [delivery_method] ([formatJumpTo(get_turf(user))])")
	var/text = "[key_name(user)] just purchased the [src.name] from the black market."
	log_game(text)
	log_admin(text)
	
/datum/black_market_item/proc/buy(var/obj/item/device/illegalradio/radio, var/delivery_method, var/mob/user)
	..()
	if(!istype(radio)) 
		return 0
	if(user.stat || user.restrained())
		return 0
	if(!(istype(user,/mob/living/carbon/human)))
		return 0
	if(get_stock() <= 0)
		to_chat(user, "<span class='warning'>This item is out of stock. Scram.</span>")
		return 0
	if(!((radio.loc in user.contents) || (in_range(radio.loc, user) && istype(radio.loc.loc, /turf))))
		return 0
	if(get_cost() > radio.money_stored)
		return 0

	if(delivery_method == 1)
		spawn_cheap(radio,user)
	else if(delivery_method == 2)
		spawn_normal(radio,user)
	else
		spawn_expensive(radio,user)

/datum/black_market_item/proc/spawn_cheap(var/obj/item/device/illegalradio/radio, var/mob/user)
	var/direction = pick(list(NORTH,EAST,SOUTH,WEST))
	var/direction_string
	if(direction == NORTH) //Look, I'm not sure why directions are 1/2/4/8 and why arrays start at 1 and why I can't just do direction/2+1 to get the index of an array because integer division is fucked or something with nonstatic typing, just let it be beautiful gunk :)
		direction_string = "north"
	else if(direction == EAST)
		direction_string = "east"
	else if(direction == SOUTH)
		direction_string = "south"
	else if(direction == WEST)
		direction_string = "west"
	log_transaction("The item was launched at the station from the [direction_string].", user)
	radio.visible_message("The uplink beeps: <span class='warning'>Your item was launched from the [direction_string]. It will impact the station in less than a minute.</span>")
	spawn(rand(150,450))
		var/obj/item = spawn_item(get_turf(user), radio, user)
		if(!item)
			return 0
		after_spawn(item,1,user)
		item.ThrowAtStation(30,2,direction)
		if(get_stock() != 0)
			round_stock -= 1	
		spawn(rand(300,600))
			if(!radio.nanotrasen_variant && prob(sps_chances[1]))
				SPS_black_market_alert(src, "The SPS decryption complex has detected an illegal black market purchase of item [name]. It was launched at the station recently.")
	
/datum/black_market_item/proc/spawn_normal(var/obj/item/device/illegalradio/radio, var/mob/user)
	var/list/potential_locations = list()
	var/turf/spawnloc = null
	for(var/area/maintenance/A in areas)
		if(A != /area/maintenance/atmos)
			potential_locations.Add(A)
	var/area/selected_area 
	while(potential_locations.len)
		selected_area = pick(potential_locations)
		potential_locations.Remove(selected_area)
		for(var/turf/simulated/floor/floor in selected_area.contents)
			if(!floor.has_dense_content())
				spawnloc = floor
				break	
	if(!spawnloc)
		return
	var/time_to_spawn = rand(300,600)
	log_transaction("The item was teleported to the [selected_area.name].", user)
	radio.visible_message("The uplink beeps: <span class='warning'>Your item has been sent through bluespace. It will appear somewhere in [selected_area.name] in [time_to_spawn/10] seconds.</span>")
	spawn(time_to_spawn)
		var/obj/item = spawn_item(spawnloc, radio, user)
		after_spawn(item,2,user)
		if(get_stock() != 0)
			round_stock -= 1
		spawn(rand(300,600))
			if(!radio.nanotrasen_variant && prob(sps_chances[2]))
				SPS_black_market_alert(src, "The SPS decryption complex has detected an illegal black market purchase of item [name]. It was teleported to your station's maintenance recently.")
		
/datum/black_market_item/proc/spawn_expensive(var/obj/item/device/illegalradio/radio, var/mob/user)
	var/obj/item = spawn_item(get_turf(user), radio, user)
	if(!item)
		return 0
	after_spawn(item,3,user)

	if(ishuman(user))
		var/mob/living/carbon/human/A = user
		if(istype(item, /obj/item))
			A.put_in_any_hand_if_possible(item)
		if(get_stock() != 0)
			round_stock -= 1
	log_transaction("The item was teleported directly to him.", user)
	if(prob(99))
		radio.visible_message("The uplink beeps: <span class='warning'>Thank you for your purchase!</span>")	
	else
		radio.visible_message("The uplink beeps: <span class='warning'>Thank you for your purchase! Heh. Fucking scammed that loser. He <i>actually</i> thinks telecrystals are expensive... oh, fuck.</span>")
	user.set_machine(radio)
	radio.interact(user)
	spawn(rand(300,600))
		if(!radio.nanotrasen_variant && prob(sps_chances[3]))
			SPS_black_market_alert(src, "The SPS decryption complex has detected an illegal black market purchase of item [name]. It was teleported directly to the buyer recently.")

	
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


/datum/black_market_item/tech
	category = "Advanced Technology" 

/datum/black_market_item/tech/portalgun
	name = "Portal Gun"
	desc = "This \"gun\" has two options: blue and orange. Shoot twice, and you'll have a wormhole connecting the two. Bluespace technology this potent is... rare. Real rare. That's why you're going to pay us a shitload of cash for it."
	item = /obj/item/weapon/gun/portalgun
	sps_chances = list(0,20,30)
	stock_min = 1
	stock_max = 1
	cost_min = 1800
	cost_max = 2200
	display_chance = 80
	
/datum/black_market_item/arcane
	category = "Supernatural and Arcane Objects" 
	
/datum/black_market_item/arcane/levitation
	name = "Potion of Levitation"
	desc = "Potions come in many shapes and sizes, but this one makes you float! Why? Because it looks fucking cool. Maybe you can convince somebody you're the fourth coming of Jesus."
	item = /obj/item/potion/levitation
	sps_chances = list(0,0,5)
	stock_min = 2
	stock_max = 4
	cost_min = 400
	cost_max = 500
	display_chance = 60
	
/datum/black_market_item/arcane/health_potion
	name = "Potion of Health? Death?"
	desc = "Unfortunately, some idiot managed to mix together the shipment of identical-looking health potions and death potions. He's dead now. Test out your luck!"
	item = /obj/item/potion/deception
	sps_chances = list(0, 10, 30)
	delivery_available = list(0, 1, 1) //Would shatter on impact
	stock_min = 2
	stock_max = 4
	cost_min = 600
	cost_max = 800
	display_chance = 70
	
/datum/black_market_item/arcane/health_potion/after_spawn(var/obj/spawned, var/mob/user)
	if(prob(25))
		spawned = /obj/item/potion/healing

	
