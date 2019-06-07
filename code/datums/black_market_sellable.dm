var/list/black_market_sellables = list()

/proc/get_black_market_sellables()
	if(!black_market_sellables.len)
		for(var/item in typesof(/datum/black_market_sellable))
			var/datum/black_market_sellable/I = new item()
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
			if(!black_market_sellables[I.category])
				black_market_sellables[I.category] = list()

			black_market_sellables[I.category] += I

	return black_market_sellables

// You can change the order of the list by putting datums before/after one another

/datum/black_market_sellable
	var/name = "item name"
	var/category = "item category"
	var/list/desc_list = list() //Not mandatory. Leave blank if you don't want one. Message is shown as "Cited reason: " + pick(desc_list)
	var/item = null
	var/no_children = 0 //If 1, will only allow that specific given path
	var/demand_min	// The demand min and max. Setting demand_min and demand_max to -1 will make it infinite. Demand is how many items are wanted, once it hits 0 you can't sell anymore.
	var/demand_max  
	var/price_min
	var/price_max
	var/display_chance = 0   //Base out of 100.

	var/round_demand
	var/round_demand_calculated = 0         
	var/round_price
	var/round_price_calculated = 0
	var/active_this_round = 0
	var/active_this_round_calculated = 0
	
	var/only_on_month	//two-digit month as string
	var/only_on_day		//two-digit day as string
	
/datum/black_market_sellable/proc/is_active()
	if(!active_this_round_calculated)
		if(rand(0,100) <= display_chance)
			active_this_round = 1
		active_this_round_calculated = 1
	. = active_this_round
	
/datum/black_market_sellable/proc/get_price(var/price_modifier = 1)
	if(!round_price_calculated)
		round_price = rand(price_min, price_max)
		round_price_calculated = 1
	. = Ceiling(round_price * price_modifier)

/datum/black_market_sellable/proc/get_demand()
	if(!round_demand_calculated)
		round_demand = rand(demand_min, demand_max)
		round_demand_calculated = 1
	if(round_demand == -1)
		. = 999
	else
		. = round_demand
		
/datum/black_market_sellable/proc/get_desc()
	if(!desc_list.len)
		return ""
	return "Cited reason: " + pick(desc_list)
		
/datum/black_market_sellable/proc/determine_payout(var/obj/input, var/mob/user) //Override for extra price calculations. Be sure to cast the given var/obj/ into the proper type.
	return

/datum/black_market_sellable/weapons
	category = "Firearms and Weaponry"
	
/datum/black_market_sellable/weapons/ion_rifle
	name = "Ion Rifle"
	desc_list = list("Robot uprising.","Keeping silicons in check.","Disassembly - flux capacitor parts.","Delicious food.")
	item = /obj/item/weapon/gun/energy/ionrifle
	no_children = 1
	demand_min = 1
	demand_max = 3
	price_min = 100
	price_max = 200
	display_chance = 80