/obj/item/clothing/suit/storage
	body_parts_covered = FULL_TORSO|ARMS

	var/obj/item/weapon/storage/internal/hold
	var/list/can_only_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (even if it's in the can_only_hold list)
	var/fits_max_w_class = W_CLASS_SMALL //Max size of objects that this object can store (in effect even if can_only_hold is set)
	var/max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 2 //The number of storage slots in this container.

/obj/item/clothing/suit/storage/New()
	..()
	hold = new (src)
	hold.name = name //So that you don't just put things into "the storage"
	hold.master_item = src
	hold.can_only_hold = can_only_hold
	hold.cant_hold = cant_hold
	hold.fits_max_w_class = fits_max_w_class
	hold.max_combined_w_class = max_combined_w_class
	hold.storage_slots = storage_slots

/obj/item/clothing/suit/storage/Destroy()
	if(hold)
		qdel(hold)
		hold = null
	return ..()

/obj/item/clothing/suit/storage/attack_hand(mob/user)
	if(user == src.loc)
		return hold.attack_hand(user)
	else
		return ..()

/obj/item/clothing/suit/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	hold.attackby(W,user)
	return 1

/obj/item/clothing/suit/storage/emp_act(severity)
	hold.emp_act(severity)
	..()

/obj/item/clothing/suit/storage/MouseDrop(atom/over_object)
	if(ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen/inventory) ))
			return ..()

		if(!(src.loc == usr) || (src.loc && src.loc.loc == usr))
			return

		playsound(get_turf(src), "rustle", 50, 1, -5)
		if (!M.incapacitated())
			var/obj/screen/inventory/OI = over_object

			if(OI.hand_index && M.put_in_hand_check(src, OI.hand_index))
				M.u_equip(src, 0)
				M.put_in_hand(OI.hand_index, src)
				M.update_inv_wear_suit()
				src.add_fingerprint(usr)
			return

		usr.attack_hand(src)
