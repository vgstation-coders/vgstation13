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
			I.on_setup()

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

/datum/black_market_sellable/proc/on_setup()
	return
		
/datum/black_market_sellable/proc/purchase_check(var/obj/input, var/mob/user) //Returns "VALID" if the purchase is valid, otherwise will give an error message with what is returned.
	return VALID
	
/datum/black_market_sellable/proc/determine_payout(var/obj/input, var/mob/user, var/payout) //Override for extra price calculations. Be sure to cast the given var/obj/ into the proper type.
	return get_price()
	
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
	
/datum/black_market_sellable/weapons/vector
	name = "Kriss Vector"
	item = /obj/item/weapon/gun/projectile/automatic/vector
	no_children = 1
	desc = "The submachine gun, silly."
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
	
/datum/black_market_sellable/weapons/dermal
	name = "Dermal Armour Patch"
	item = /obj/item/clothing/head/helmet/tactical/HoS/dermal
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 300
	price_max = 350
	sps_chance = 30
	display_chance = 40	
	
	
	
/datum/black_market_sellable/machinery
	category = "Machinery and Technology"
	
/datum/black_market_sellable/machinery/janicart
	name = "Nanotrasen-Brand Janicart"
	item = /obj/structure/bed/chair/vehicle/janicart
	no_children = 1
	desc = "Don't need the key or anything."
	demand_min = 1
	demand_max = 1
	price_min = 300
	price_max = 350
	sps_chance = 35
	display_chance = 35

/datum/black_market_sellable/machinery/plasmaminer
	name = "Plasma Gas Miner"
	item = /obj/machinery/atmospherics/miner/toxins
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 250
	price_max = 300
	sps_chance = 20
	display_chance = 30
	
/datum/black_market_sellable/machinery/sleepingminer
	name = "N2O Gas Miner"
	item = /obj/machinery/atmospherics/miner/sleeping_agent
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 125
	price_max = 175
	sps_chance = 10
	display_chance = 30
	
/datum/black_market_sellable/machinery/planningframe
	name = "AI Law Module Planning Frame"
	item = /obj/item/weapon/planning_frame
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 200
	price_max = 300
	sps_chance = 40
	display_chance = 45	

	
	

/datum/black_market_sellable/animals
	category = "Living Creatures"	
	
/datum/black_market_sellable/animals/slime
	name = "? Slime"
	item = /mob/living/carbon/slime/adult
	no_children = 0
	desc = "Slime must be an adult."
	demand_min = 1
	demand_max = 3
	price_min = 200
	price_max = 400
	sps_chance = 0
	display_chance = 60
	teleport_modifier = 1.5
	var/list/potential_slimes = list("sepia","adamantine","pyrite","bluespace","cerulean")
	var/selected_slime
	
/datum/black_market_sellable/animals/slime/purchase_check(var/obj/input, var/mob/user)
	if(istype(input,/mob/living/carbon/slime/adult))
		var/mob/living/carbon/slime/adult/input_slime = input
		if(input_slime.colour == selected_slime)
			return VALID
	return "Our buyer is looking for a [selected_slime] slime, not whatever the hell that is."
	
/datum/black_market_sellable/animals/slime/on_setup()
	selected_slime = pick(potential_slimes)
	name = capitalize(selected_slime) + " Slime"
	
/datum/black_market_sellable/animals/cockatrice
	name = "Cockatrice"
	item = /mob/living/simple_animal/hostile/retaliate/cockatrice
	no_children = 1
	desc = "We'll pay quadruple if it's alive."
	demand_min = 1
	demand_max = 1
	price_min = 200
	price_max = 400
	sps_chance = 0
	display_chance = 60
	teleport_modifier = 2
	
/datum/black_market_sellable/animals/cockatrice/determine_payout(var/obj/input, var/mob/user, var/payout)
	if(istype(input,/mob/))
		var/mob/cockatrice = input
		if(!cockatrice.isDead())
			return payout*4
	return payout
	
/datum/black_market_sellable/animals/ian
	name = "Ian the Corgi"
	item = /mob/living/simple_animal/corgi/Ian
	no_children = 1
	desc = "Ian must be alive. Very alive."
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
		
/datum/black_market_sellable/animals/sasha
	name = "Sasha the Doberman"
	item = /mob/living/simple_animal/corgi/sasha
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 300
	price_max = 400
	sps_chance = 0
	display_chance = 35
	teleport_modifier = 3
	
/datum/black_market_sellable/animals/punpun
	name = "Punpun the Monkey"
	item = /mob/living/carbon/monkey/punpun
	no_children = 1
	demand_min = 1
	demand_max = 1	
	price_min = 50
	price_max = 100
	sps_chance = 5
	display_chance = 35
	teleport_modifier = 2

/datum/black_market_sellable/animals/poly
	name = "Poly the Parrot"
	item = /mob/living/simple_animal/parrot/Poly
	no_children = 1
	demand_min = 1
	demand_max = 1	
	price_min = 150
	price_max = 300
	sps_chance = 15
	display_chance = 35
	teleport_modifier = 2
		
/datum/black_market_sellable/animals/corpus
	name = "Corpus the Snake"
	item = /mob/living/simple_animal/cat/snek/corpus
	no_children = 1
	desc = "sssSSSSsss"
	demand_min = 1
	demand_max = 1	
	price_min = 100
	price_max = 200
	sps_chance = 15
	display_chance = 35
	teleport_modifier = 2
	
/datum/black_market_sellable/animals/runtime
	name = "Runtime the Cat"
	item = /mob/living/simple_animal/cat/Runtime
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 150
	price_max = 200
	sps_chance = 15
	display_chance = 35
	teleport_modifier = 2	

/datum/black_market_sellable/animals/salem
	name = "Salem the Neglected Cat"
	item = /mob/living/simple_animal/cat/salem
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 100
	price_max = 150
	sps_chance = 15
	display_chance = 35
	teleport_modifier = 2		

	
	
	
/datum/black_market_sellable/misc
	category = "Miscellaneous Items"
	
/datum/black_market_sellable/misc/tome
	name = "Occult Tome"
	item = /obj/item/weapon/tome
	no_children = 1
	desc = "Looking for the one from the cult of Nar-Sie. Teleporting magical items will likely send an alert to Centcomm."
	demand_min = 1
	demand_max = 3
	price_min = 350
	price_max = 450
	sps_chance = 75
	display_chance = 60
	
/datum/black_market_sellable/misc/slimeheart
	name = "Slime Heart"
	item = /obj/item/slime_heart
	no_children = 1
	demand_min = 1
	demand_max = 2
	price_min = 150
	price_max = 200
	sps_chance = 10
	display_chance = 35

/datum/black_market_sellable/misc/deathnettle
	name = "Deathnettle"
	item = /obj/item/weapon/grown/deathnettle
	no_children = 1
	desc = "Paying 1.5x if the potency is 80 or above."
	demand_min = 3
	demand_max = 6
	price_min = 40
	price_max = 60
	sps_chance = 15
	display_chance = 40
	
/datum/black_market_sellable/misc/deathnettle/determine_payout(var/obj/input, var/mob/user, var/payout)
	if(istype(input,/obj/item/weapon/grown/deathnettle))
		var/obj/item/weapon/grown/deathnettle/nettle = input
		if(nettle.potency >= 80)
			return payout*1.5
	return payout	
	
/datum/black_market_sellable/misc/poutine
	name = "Poutine Ocean"
	item = /obj/structure/poutineocean	
	no_children = 1
	demand_min = 1
	demand_max = 1
	price_min = 700
	price_max = 800
	sps_chance = 0
	display_chance = 25

#undef VALID