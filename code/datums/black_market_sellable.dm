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
	var/teleport_modifier = 1 //Multiplier for time it takes to teleport.

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
		
/datum/black_market_sellable/proc/reduce_demand()
	if(round_demand != -1 || round_demand != 0)
		round_demand--

/datum/black_market_sellable/proc/purchase_check(var/obj/input, var/mob/user) //Returns "VALID" if the purchase is valid, otherwise will give an error message with what is returned.
	return VALID
	
/datum/black_market_sellable/proc/determine_payout(var/obj/input, var/mob/user, var/payout) //Override for extra price calculations. Be sure to cast the given var/obj/ into the proper type.
	return 0
	
/datum/black_market_sellable/proc/after_sell(var/obj/input, var/mob/user)
	return
	
/datum/black_market_sellable/weapons
	category = "Firearms and War Implements"
	
/datum/black_market_sellable/weapons/ion_rifle
	name = "Ion Rifle"
	item = /obj/item/weapon/gun/energy/ionrifle
	no_children = 1
	demand_min = 1
	demand_max = 3
	price_min = 100
	price_max = 200
	sps_chance = 10
	display_chance = 40
	
/datum/black_market_sellable/weapons/railgun
	name = "Railgun"
	item = /obj/item/weapon/gun/projectile/railgun
	no_children = 1
	desc = "We'll pay triple for a railgun loaded with a capacitor of 1 GW charge or greater."
	demand_min = 1
	demand_max = 1
	price_min = 200
	price_max = 300
	sps_chance = 15
	display_chance = 100
	
/datum/black_market_sellable/weapons/railgun/determine_payout(var/obj/input, var/mob/user, var/payout)
	if(istype(input,/obj/item/weapon/gun/projectile/railgun))
		var/obj/item/weapon/gun/projectile/railgun/gun = input
		if(gun.loadedcapacitor && gun.loadedcapacitor.stored_charge/5000000 >= 200) //1 GW
			return payout*3
	return payout
	
/datum/black_market_sellable/weapons/transfer_valve
	name = "Tank Transfer Valve"
	item = /obj/item/device/transfer_valve/
	no_children = 0
	desc = "Looking for NT-brand explosive valves. The tanks attached are irrelevant, send it empty if you want."
	demand_min = 1
	demand_max = 2
	price_min = 400
	price_max = 500
	sps_chance = 70
	display_chance = 50

/datum/black_market_sellable/weapons/ied
	name = "Improvised Explosive Device"
	item = /obj/item/weapon/grenade/iedcasing/
	no_children = 1
	desc = "Looking for cheap explosives made from soda cans or something."
	demand_min = 3
	demand_max = 7
	price_min = 50
	price_max = 120
	sps_chance = 5
	display_chance = 80
	
/datum/black_market_sellable/animals
	category = "Living Creatures"	
	
/datum/black_market_sellable/animals/ian
	name = "Ian the Corgi"
	item = /mob/living/simple_animal/corgi/Ian
	no_children = 1
	desc = "Ian must be alive. And cute."
	demand_min = 1
	demand_max = 1
	price_min = 700
	price_max = 800
	sps_chance = 0
	display_chance = 100
	teleport_modifier = 3
	
/datum/black_market_sellable/animals/ian/purchase_check(var/obj/input, var/mob/user)
	if(istype(input,/mob/))
		var/mob/ian = input
		if(ian.isDead())
			return "Ian is dead. This just won't do."
	return VALID
	
/datum/black_market_sellable/animals/ian/after_sell(var/obj/input, var/mob/user)
	spawn(rand(350,650))
		command_alert(new /datum/command_alert/ian_sold(user))
	
/datum/black_market_sellable/animals/runtime
	name = "Runtime the Cat"
	item = /mob/living/simple_animal/cat/Runtime
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 150
	price_max = 200
	sps_chance = 15
	display_chance = 100
	teleport_modifier = 3	

/datum/black_market_sellable/animals/salem
	name = "Salem the Cat"
	item = /mob/living/simple_animal/cat/salem
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 100
	price_max = 150
	sps_chance = 15
	display_chance = 100
	teleport_modifier = 3		
	
	
	
	
	
	
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
	
/datum/black_market_sellable/weapons/energy_gun/determine_payout(var/obj/input, var/mob/user, var/payout)
	if(istype(input,/obj/item/weapon/gun/energy/))
		var/obj/item/weapon/gun/energy/gun = input
		if(gun.power_supply.charge >= gun.power_supply.maxcharge)
			return payout //Doubles payout, since return value is added onto current payout
	return 0
*/

#undef VALID