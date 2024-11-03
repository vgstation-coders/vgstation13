/datum/component/uplink
	var/locked = TRUE
	var/lockable = TRUE
	var/list/purchase_log = list()
	var/unlock_code
	var/unlock_frequency
	var/compact_mode
	var/telecrystals = 20
	var/selected_category
	var/job
	var/species
	var/nuke_ops_inventory = FALSE

/datum/component/uplink/initialize()
	if(!isitem(parent))
		return FALSE

	parent.register_event(/event/attackby, src, nameof(src::on_attackby()))
	parent.register_event(/event/item_attack_self, src, nameof(src::on_attack_self()))
	if(istype(parent, /obj/item/device/pda))
		generate_unlock_code()
		parent.register_event(/event/pda_change_ringtone, src, nameof(src::on_pda_change_ringtone()))

	if(istype(parent, /obj/item/device/radio))
		generate_frequency()
		parent.register_event(/event/radio_new_frequency, src, nameof(src::on_radio_new_frequency()))

	return TRUE

/datum/component/uplink/Destroy()
	parent.unregister_event(/event/attackby, src, nameof(src::on_attackby()))
	parent.unregister_event(/event/item_attack_self, src, nameof(src::on_attack_self()))
	parent.unregister_event(/event/pda_change_ringtone, src, nameof(src::on_pda_change_ringtone()))
	parent.unregister_event(/event/radio_new_frequency, src, nameof(src::on_radio_new_frequency()))
	..()

/datum/component/uplink/ui_host(mob/user)
	return parent

/datum/component/uplink/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Uplink")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/component/uplink/ui_data(mob/user)
	var/list/data = list()
	data["telecrystals"] = telecrystals
	data["lockable"] = lockable
	data["compactMode"] = compact_mode
	data["selectedCategory"] = selected_category
	return data

/datum/component/uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in get_uplink_items(uplink_items))
		var/list/cat = list(
			"name" = category,
			"items" = list()
		)
		for(var/datum/uplink_item/I in uplink_items[category])
			if((!I.available_for_job(job) && !I.available_for_job(species)) || (!I.available_for_nuke_ops && nuke_ops_inventory))
				continue
			cat["items"] += list(list(
				"name" = I.name,
				"cost" = I.get_cost(job, species),
				"base_cost" = I.cost,
				"desc" = I.desc,
				"discounted" = I.gives_discount(job) || I.gives_discount(species) || length(I.jobs_exclusive),
				"refundable" = I.refundable,
			))
		if(!length(cat["items"]))
			continue
		data["categories"] += list(cat)
	return data

/datum/component/uplink/ui_state(mob/user)
	return global.deep_inventory_state

/datum/component/uplink/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(locked)
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
			return TRUE
		if("lock")
			locked = TRUE
			SStgui.close_uis(src)
		if("select")
			selected_category = params["category"]
			return TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE
		if("get_tc")
			var/amount = clamp(text2num(params["amount"]), 0, telecrystals)
			if(amount == 0)
				return
			telecrystals -= amount
			var/obj/item/stack/telecrystal/R = new(get_turf(usr), amount)
			to_chat(usr, "<span class='notice'>You withdraw [amount] telecrystal[amount > 1 ? "s" : ""] from the uplink.</span>")
			usr.put_in_hands(R)
			return TRUE

// Dumb oldcode
/datum/component/uplink/proc/generate_frequency()
	var/freq = 1441
	var/static/list/freqlist
	if(!freqlist)
		freqlist = list()
		while (freq <= 1489)
			if (freq < 1451 || freq > 1459)
				freqlist += freq
			freq += 2
			if ((freq % 2) == 0)
				freq += 1
	unlock_frequency = pick(freqlist)

/datum/component/uplink/proc/generate_unlock_code()
	unlock_code = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

/datum/component/uplink/proc/on_attackby(mob/living/attacker, obj/item/item)
	if(locked)
		return
	if(istype(item, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/crystals = item
		telecrystals += crystals.amount
		to_chat(attacker, "<span class='notice'>You insert [crystals.amount] telecrystal[crystals.amount > 1 ? "s" : ""] into the uplink.</span>")
		crystals.use(crystals.amount)
		return
	var/list/items = get_uplink_items()
	for(var/category in items)
		for(var/category_item in items[category])
			var/datum/uplink_item/uplink_item = category_item
			if(!uplink_item.refundable)
				continue

			var/path = uplink_item.refund_path || uplink_item.item
			if(!istype(uplink_item, path) || item.check_uplink_validity())
				continue

			var/cost = uplink_item.refund_amount || uplink_item.cost
			telecrystals += cost
			to_chat(attacker, "<span class='notice'>[item] refunded.</span>")
			qdel(item)

/datum/component/uplink/proc/on_attack_self(mob/user)
	if(locked)
		return
	tgui_interact(user)
	return TRUE

/datum/component/uplink/proc/on_pda_change_ringtone(mob/user, new_ringtone)
	if(trim(lowertext(new_ringtone)) != trim(lowertext(unlock_code)))
		return
	locked = FALSE
	tgui_interact(user)
	return TRUE

/datum/component/uplink/proc/on_radio_new_frequency(mob/user, new_frequency)
	if(new_frequency != unlock_frequency)
		return
	locked = FALSE
	tgui_interact(user)
	return TRUE

