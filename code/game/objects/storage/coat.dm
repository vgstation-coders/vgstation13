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

/obj/item/clothing/suit/storage/on_mousedrop_to_inventory_slot()
	playsound(src, "rustle", 50, 1, -5)

/obj/item/clothing/suit/storage/MouseDropFrom(atom/over_object)
	if(over_object == usr) //show container to user
		return hold.MouseDropFrom(over_object)
	else if(istype(over_object, /obj/structure/table)) //empty on table
		return hold.MouseDropFrom(over_object)
	return ..()

/obj/item/clothing/suit/storage/AltClick(mob/user as mob)
	if(user == src.loc)
		return hold.attack_hand(user)
	else
		return ..()
	
