#define VALID	"VALID"

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
	var/desc = "" //Not mandatory. Should be used to give info on extra criteria (E.g. double payout if blood is type O+, or does not accept blood type A+ if buying bloodbags)
	var/item = null
	var/no_children = 1 //If 1, will only allow that specific given path
	var/demand_min	// The demand min and max. Setting demand_min and demand_max to -1 will make it infinite. Demand is how many items are wanted, once it hits 0 you can't sell anymore.
	var/demand_max  
	var/price_min
	var/price_max
	var/sps_chance = 0
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
		if(prob(display_chance))
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

/datum/black_market_sellable/proc/purchase_check(var/obj/input, var/mob/user) //Returns "VALID" if the purchase is valid, otherwise will give an error message with what is returned.
	return VALID
	
/datum/black_market_sellable/proc/determine_payout(var/obj/input, var/mob/user, var/payout) //Override for extra price calculations. Be sure to cast the given var/obj/ into the proper type.
	return get_price()

/datum/black_market_sellable/proc/after_sell(var/obj/input, var/mob/user) 
	return
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/* //EXAMPLE
	
/datum/black_market_sellable/weapons
	category = "Firearms and Weaponry"
	
/datum/black_market_sellable/weapons/ion_rifle
	name = "Ion Rifle"
	item = /obj/item/weapon/gun/energy/ionrifle
	no_children = 1
	demand_min = 1
	demand_max = 3
	price_min = 100
	price_max = 200
	display_chance = 100

/datum/black_market_sellable/weapons/energy_gun
	name = "Energy Gun"
	item = /obj/item/weapon/gun/energy/
	no_children = 0
	desc = "Paying double for fully charged weapons, but guns with no charge will be denied."
	demand_min = 1
	demand_max = 3
	price_min = 100
	price_max = 200
	sps_chance = 100
	display_chance = 100
	
/datum/black_market_sellable/weapons/energy_gun/purchase_check(var/obj/input, var/mob/user)
	if(istype(input,/obj/item/weapon/gun/energy/))
		var/obj/item/weapon/gun/energy/gun = input
		if(gun.power_supply.charge > 0)
			return VALID
	return "The energy gun does not have any charge."
	
/datum/black_market_sellable/weapons/energy_gun/determine_payout(var/obj/input, var/mob/user)
	if(istype(input,/obj/item/weapon/gun/energy/))
		var/obj/item/weapon/gun/energy/gun = input
		if(gun.power_supply.charge >= gun.power_supply.maxcharge)
			return get_price()*2
	return get_price()
*/

#undef VALID