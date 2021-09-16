//Price fluxuations: swings -20% to +20%
//Prestige: money kept in Shoal account (each $250 gives -1%, max -20%)
//Loyal customer: each $100 spent gives -1% (max -10%)

var/datum/subsystem/trade_system/SStrade

/datum/subsystem/trade_system
	name       = "Trade System"
	//unspecified init order
	flags      = SS_TICKER
	wait       = 30 SECONDS //check in no more than once every thirty seconds
	var/list/all_twindows = list() //All trade windows
	var/list/all_trade_merch = list() //The list of all trade products, kept as elements
	var/list/trade_databank = list() //The above, converted to associative list format for use in UI
	var/list/loyal_customers = list() //Associative list, associates face identities with cash spent.

/datum/subsystem/trade_system/Initialize(timeofday)
	SStrade = src
	for(var/path in subtypesof(/datum/trade_product))
		all_trade_merch += new path
	market_flux(FALSE)
	..()

/datum/subsystem/trade_system/fire(resumed = FALSE)
	if(prob(FLUX_CHANCE))
		market_flux()

/datum/subsystem/trade_system/proc/market_flux(var/update_windows = TRUE)
	for(var/datum/trade_product/TP in all_trade_merch)
		TP.flux_rate = 1+(rand(-20,20)/100) //Anywhere from 0.8 to 1.2
	if(update_windows)
		for(var/obj/structure/trade_window/TW in all_twindows)
			TW.market_flux()

/datum/subsystem/trade_system/proc/rebuild_databank(mob/user)
	trade_databank.Cut() //empty the list
	for(var/datum/trade_product/TP in all_trade_merch)
		if(TP.totalsold >= TP.maxunits)
			continue //Sold out

		//Adds a list of lists. BYOND's default behavior is to append the contents of one list to the list
		//So the outer list "dissolves", leaving only the list, which is associative and contains name, category, etc data
		var/product_to_list = list()
		product_to_list["name"] = TP.name
		product_to_list["price"] = TP.current_price(user)
		product_to_list["marketforces"] = 100*(TP.flux_rate - 1)
		product_to_list["category"] = TP.sales_category
		product_to_list["remaining"] = TP.maxunits - TP.totalsold
		trade_databank += list(product_to_list)

/datum/subsystem/trade_system/proc/shoal_prestige_factor()
	if(trader_account.money >= 5000)
		return 0.8
	return 1-round(trader_account.money / 25000, 0.01)

/datum/subsystem/trade_system/proc/loyal_customer(mob/living/carbon/human/user)
	if(!istype(user))
		return 1.5
	if(!(user.get_face_name() in loyal_customers))
		return 1.5
	if(loyal_customers[user.get_face_name()] >= 1000)
		return 0.9
	return 1-round(loyal_customers[user.get_face_name()]/10000,0.01) //1% off per $100 spent, up to 10% off
