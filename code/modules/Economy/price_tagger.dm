/obj/item/device/priceTagger
	name = "price tagger"
	desc = "Used to set the price of items."
	icon_state = "dest_tagger" //placeholder, feel free to add a sprite
	starting_materials = list(MAT_IRON = 300)
	w_type = RECYK_METAL

	var/current_price = 0

	w_class = W_CLASS_TINY
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

/obj/item/device/priceTagger/attack_self(mob/user)
	var/new_price = input("Enter a price", "Price tagger", current_price) as null|num
	if(new_price == null || new_price < 0)
		new_price = current_price
	if(!user.is_holding_item(src))
		return
	current_price = new_price

/obj/item/device/priceTagger/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(istype(target, /obj))
		var/obj/O = target
		O.price = current_price
		playsound(src, 'sound/machines/twobeep.ogg', 100, 1)
		to_chat(user, "<span class='notice'>Changed price to [current_price] credits.</span>")