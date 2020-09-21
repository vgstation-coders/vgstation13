/obj/item/storage/bag/clipboard
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
	can_only_hold = list("/obj/item/photo", "/obj/item/paper", "/obj/item/pen")
	var/obj/item/paper/toppaper = null

/obj/item/storage/bag/clipboard/New()
	. = ..()
	update_icon()

/obj/item/storage/bag/clipboard/update_icon()
	overlays.len = 0
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	else
		var/obj/item/photo/Ph = locate(/obj/item/photo) in src
		if(Ph)
			overlays += image(Ph.icon)
	if(locate(/obj/item/pen) in src)
		overlays += image(icon, "clipboard_pen")
	overlays += image(icon, "clipboard_over")
	return

/obj/item/storage/bag/clipboard/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	//No special sanity needed since all checks handled in can_be_inserted(), see storage.dm
	if(istype(W,/obj/item/paper))
		toppaper = W
	..() //also calls update_icon()

/obj/item/storage/bag/clipboard/remove_from_storage(obj/item/W as obj, atom/new_location, var/force = 0, var/refresh = 1)
	. = ..()
	for(var/i = contents.len; i>0; i--)
		if(istype(contents[i],/obj/item/paper))
			toppaper = contents[i]
			update_icon()
			return
	//If we looped through everything and there's still no paper
	toppaper = null
	update_icon()
	return .