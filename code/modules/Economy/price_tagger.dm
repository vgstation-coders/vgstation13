/obj/item/device/price_tagger
	name = "price tagger"
	desc = "Used to set the price of items."
	icon_state = "dest_tagger"
	starting_materials = list(MAT_IRON = 300)
	w_type = RECYK_METAL

	var/current_price = 1

	w_class = W_CLASS_TINY
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

/obj/item/device/price_tagger/attack_self()
  current_price = input("Enter a price", current_price, current_price)

/obj/item/device/price_tagger/attack(obj/item/I, mob/user)
