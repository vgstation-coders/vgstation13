var/global/list/trades = list()

proc/trade_setup()
	add_trade(new /datum/trade/scanner)	
	add_trade(new /datum/trade/nutriment)

proc/add_trade(var/datum/trade/T)
	trades.Add(T)
	T.id = trades.len

proc/remove_trade(var/trade_id)
	if(trades[trade_id])
		trades[trade_id] = null

proc/pick_trade()
	var/total_weight = 0
	var/pick_threshholds = list()
	for(var/type in subtypesof(/datum/trade))
		var/datum/trade/T = new type
		total_weight += T.weight
		var/min
		var/max
		if(T.weight == 1)
			min = total_weight
			max = total_weight
		else
			min = total_weight - T.weight + 1
			max = total_weight
		pick_threshholds[type] = list(min, max)

	var/value = rand(1, total_weight)
	message_admins("total_weight: [total_weight] value: [value]") //debug
	var/choice
	for(var/type in subtypesof(/datum/trade))
		var/min = pick_threshholds[type][1]
		var/max = pick_threshholds[type][2]		
		message_admins("TYPE: [type] MIN: [min] MAX: [max]") //debug
		if(value >= min && value <= max)
			choice = type

	return choice

/client/proc/view_trades()
	set name = "View Trades"
	set category = "Debug"
	for(var/i=1 to trades.len)
		to_chat(usr, "[i] [trades[i].type]")
	return

/client/proc/debug_pick_trade()
	set name = "Pick Trade"
	set category = "Debug"
	var/type = pick_trade()
	to_chat(usr, "CHOICE: [type]")
	return

/datum/trade/scanner
	items = list(/obj/item/device/reagent_scanner/adv = 1)
	reagents = null
	reward = 100
	display = list(
		"1 advanced reagent scanner"
	)

/datum/trade/nutriment
	items = list(/obj/item/weapon/reagent_containers/glass/beaker/large = 1)
	reagents = list(NUTRIMENT = 20)
	reward = 100
	display = list(
		"1 large beaker",
		"20 units of Nutriment"
	)