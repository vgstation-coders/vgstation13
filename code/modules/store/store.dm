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

var/global/datum/store/centcomm_store

/datum/store
	var/list/datum/storeitem/items=list()
	var/list/datum/storeorder/orders=list()

	var/obj/machinery/account_database/linked_db

/datum/store/New()
	for(var/itempath in subtypesof(/datum/storeitem))
		var/datum/storeitem/instance = new itempath()
		if(!items[instance.category])
			items[instance.category] = list()
		items[instance.category] += instance
		CHECK_TICK

/datum/store/proc/charge(var/mob/user,var/amount,var/datum/storeitem/item,var/obj/machinery/computer/merch/merchcomp)
	if(!user)
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
		if(DB.z == map.zMainStation)
			if(!(DB.stat & (NOPOWER|FORCEDISABLE)) && DB.activated )//If the database if damaged or not powered, people won't be able to use the store anymore
				linked_db = DB
				break

/datum/store/proc/PlaceOrder(var/mob/living/user, var/itemName, var/obj/machinery/computer/merch/merchcomp)
	// Get our item, first.
	var/datum/storeitem/item
	for(var/category in items)
		var/list/category_items = items[category]
		for(var/datum/storeitem/i in category_items)
			if(i.name == itemName)
				item = i
				break
	ASSERT(item)
	if(item.stock == 0)
		to_chat(user, "<span class='warning'>That item is sold out.</span>")
		return
	if(!item.available_to_user(user))
		to_chat(user, "<span class='warning'>That item is not available to you.</span>")
		return
	// Try to deduct funds.
	if(!charge(user,item.cost,item,merchcomp))
		return 0
	// Give them the item.
	item.deliver(user,merchcomp)
	if(item.stock != -1)
		item.stock--
	return 1
