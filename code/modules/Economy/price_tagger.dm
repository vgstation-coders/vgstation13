/obj/item/device/price_tagger
	name = "price tagger"
	desc = "Used to set the price of items."
	icon_state = "dest_tagger"
	starting_materials = list(MAT_IRON = 300)
	w_type = RECYK_METAL

	var/current_price = 0

	w_class = W_CLASS_TINY
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

/obj/item/device/price_tagger/attack_self()
	current_price = input("Enter a price", current_price, current_price) as null|num

/obj/item/device/price_tagger/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(istype(target, /obj))
		var/obj/O = target
		O.price = current_price
		playsound(get_turf(src), 'sound/machines/twobeep.ogg', 100, 1)
		to_chat(user, "<span class='notice'>Changed price to [current_price] credits.</span>")
