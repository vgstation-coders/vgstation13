/obj/item/weapon/storage/bag/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 10
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	storage_slots = 28
	can_only_hold = list("/obj/item/weapon/photo", "/obj/item/weapon/paper", "/obj/item/weapon/pen")
	var/obj/item/weapon/paper/toppaper = null

/obj/item/weapon/storage/bag/clipboard/New()
	. = ..()
	update_icon()

/obj/item/weapon/storage/bag/clipboard/update_icon()
	overlays.len = 0
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	else
		var/obj/item/weapon/photo/Ph = locate(/obj/item/weapon/photo) in src
		if(Ph)
			overlays += image(Ph.icon)
	if(locate(/obj/item/weapon/pen) in src)
		overlays += image(icon, "clipboard_pen")
	overlays += image(icon, "clipboard_over")
	return

/obj/item/weapon/storage/bag/clipboard/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	//No special sanity needed since all checks handled in can_be_inserted(), see storage.dm
	if(istype(W,/obj/item/weapon/paper))
		toppaper = W
	..() //also calls update_icon()

/obj/item/weapon/storage/bag/clipboard/remove_from_storage(obj/item/W as obj, atom/new_location, var/force = 0, var/refresh = 1)
	. = ..()
	for(var/i = contents.len; i>0; i--)
		if(istype(contents[i],/obj/item/weapon/paper))
			toppaper = contents[i]
			update_icon()
			return
	//If we looped through everything and there's still no paper
	toppaper = null
	update_icon()
	return .