var/global/list/trades = list()

proc/trade_setup()
	add_trade(new /datum/trade/scanner)

proc/add_trade(var/datum/trade/T)
	trades.Add(T)
	log_admin("Added trade #[1] of type [T.type]")	

/client/proc/view_trades()
	set name = "View Trades"
	set category = "Debug"
	for(var/i=0 to trades.len)
		to_chat(usr, "[i] [trades[i].type]")
	return

/datum/trade/donut
	items = list(/obj/item/weapon/reagent_containers/food/snacks/donut = 3)
	reagents = null
	reward = 50
	display = list(
		"3 donuts"
	)

/datum/trade/scanner
	items = list(/obj/item/device/reagent_scanner/adv = 1)
	reagents = null
	reward = 200
	display = list(
		"1 advanced reagent scanner"
	)
