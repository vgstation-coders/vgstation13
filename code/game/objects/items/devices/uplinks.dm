//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message. //WHY

*/

/obj/item/device/uplink
	var/uses = 20 // Number of crystals
	var/list/purchase_log = list()
	var/active = 0
	var/job = null
	var/list/roles = list()
	var/lockable = TRUE
	var/compact_mode = FALSE
	var/selected_category

/obj/item/device/uplink/proc/refund(mob/living/carbon/human/user, obj/item/I)
	if(!user || !I)
		return
	if (istype(I, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/S = I
		uses += S.amount
		user.drop_item(S, src)
		to_chat(user, "<span class='notice'>You insert [S.amount] telecrystal[S.amount > 1 ? "s" : ""] into the uplink.</span>")
		qdel(S)
	if(!uplink_items)
		get_uplink_items()
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/UI = item
			var/path = UI.refund_path || UI.item
			var/cost = UI.refund_amount || UI.cost
			if(istype(I, path) && UI.refundable && I.check_uplink_validity())
				uses += cost
				to_chat(user, "<span class='notice'>[I] refunded.</span>")
				qdel(I)
				return TRUE
	return FALSE

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/interact(mob/user)
	tgui_interact(user)

/obj/item/device/uplink/ui_host(mob/user, datum/tgui/ui)
	return loc

/obj/item/device/uplink/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Uplink")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/device/uplink/ui_data(mob/user)
	var/list/data = list()
	data["telecrystals"] = uses
	data["lockable"] = lockable
	data["compactMode"] = compact_mode
	data["selectedCategory"] = selected_category
	return data

/obj/item/device/uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in get_uplink_items(uplink_items))
		var/list/cat = list(
			"name" = category,
			"items" = list()
		)
		for(var/datum/uplink_item/I in uplink_items[category])
			if(!I.available_for_job(job) || !I.available_for_role(roles))
				continue
			cat["items"] += list(list(
				"name" = I.name,
				"cost" = I.get_cost(job),
				"desc" = I.desc,
				"discounted" = I.gives_discount(job) || length(I.jobs_exclusive),
				"refundable" = I.refundable,
			))
		if(!length(cat["items"]))
			continue
		data["categories"] += list(cat)
	return data

/obj/item/device/uplink/ui_state(mob/user)
	return global.deep_inventory_state

/obj/item/device/uplink/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!active)
		return
	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = get_uplink_items(job)
			var/datum/uplink_item/item
			for(var/category in buyable_items)
				for(var/datum/uplink_item/category_item in buyable_items[category])
					if(category_item.name == item_name)
						item = category_item
						break
			if(!item)
				CRASH("unknown uplink_item [item_name]")
			item.buy(src, usr)
		if("lock")
			active = FALSE
			SStgui.close_uis(src)
		if("select")
			selected_category = params["category"]
			return TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE
		if("get_tc")
			var/amount = clamp(text2num(params["amount"]), 0, uses)
			if(amount == 0)
				return
			uses -= amount
			var/obj/item/stack/telecrystal/R = new(get_turf(usr), amount)
			to_chat(usr, "<span class='notice'>You withdraw [amount] telecrystal[amount > 1 ? "s" : ""] from the uplink.</span>")
			usr.put_in_hands(R)
			return TRUE

// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "Hidden Uplink."
	desc = "There is something wrong if you're examining this."
	var/datum/role/traitor/associated_role

/obj/item/device/uplink/hidden/Destroy()
	var/obj/item/I = loc
	I.hidden_uplink = null
	if (associated_role)
		associated_role.uplink = null
		associated_role = null
	..()

/obj/item/device/uplink/hidden/Topic(href, href_list)
	..()
	if(href_list["lock"])
		toggle()
		usr << browse(null, "window=hidden")
		return 1

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user as mob)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user as mob, var/value, var/target)
	if(value == target)
		trigger(user)
		return 1
	return 0

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	hidden_uplink = new(src)
	icon_state = "radio"

/obj/item/device/radio/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)


/obj/item/device/radio/uplink/nukeops/New()
	..()
	hidden_uplink.uses = 80 //haha fuck OOP
	hidden_uplink.job = "Nuclear Operative"

/obj/item/device/multitool/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 20
