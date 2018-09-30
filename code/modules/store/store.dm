/*****************************
 * /vg/station In-Game Store *
 *****************************

By Nexypoo

The idea is to give people who do their jobs a reward.

Ideally, these items should be cosmetic in nature to avoid fucking up round balance.
People joining the round get between $100 and $500.  Keep this in mind.

Money should not persist between rounds, although a "bank" system to voluntarily store
money between rounds might be cool.  It'd need to be a bit volatile:  perhaps completing
job objectives = good stock market, shitty job objective completion = shitty economy.

Goal for now is to get the store itself working, however.
*/

var/global/datum/store/centcomm_store=new

/datum/store
	var/list/datum/storeitem/items=list()
	var/list/datum/storeorder/orders=list()

	var/obj/machinery/account_database/linked_db

/datum/store/New()
	for(var/itempath in typesof(/datum/storeitem) - /datum/storeitem/)
		items += new itempath()

/datum/store/proc/charge(var/mob/user,var/amount,var/datum/storeitem/item,var/obj/machinery/computer/merch/merchcomp)
	if(!user)
		//testing("No initial_account")
		return 0
	var/obj/item/weapon/card/card = user.get_card()
	if(!card)
		return 0

	reconnect_database()
	if(merchcomp.charge_flow(linked_db, card, user, amount, vendor_account, "Purchase of [item.name]", merchcomp.machine_id) != CARD_CAPTURE_SUCCESS)
		return 0
	
	return 1

/datum/store/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if(DB.z == STATION_Z)
			if(!(DB.stat & NOPOWER) && DB.activated )//If the database if damaged or not powered, people won't be able to use the store anymore
				linked_db = DB
				break

/datum/store/proc/PlaceOrder(var/mob/living/usr, var/itemID, var/obj/machinery/computer/merch/merchcomp)
	// Get our item, first.

	var/datum/storeitem/item = new itemID()
	if(!item)
		return 0
	// Try to deduct funds.
	if(!charge(usr,item.cost,item,merchcomp))
		return 0
	// Give them the item.
	item.deliver(usr,merchcomp)
	return 1
