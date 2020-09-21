/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	storage_slots = 20
	icon = 'icons/obj/wallet.dmi'
	icon_state = "wallet"
	w_class = W_CLASS_SMALL
	use_to_pickup = TRUE
	can_only_hold = list(
		"/obj/item/spacecash",
		"/obj/item/card",
		"/obj/item/clothing/mask/cigarette",
		"/obj/item/device/flashlight/pen",
		"/obj/item/seeds",
		"/obj/item/stack/medical",
		"/obj/item/toy/crayon",
		"/obj/item/coin",
		"/obj/item/reagent_containers/food/snacks/customizable/candy/coin",
		"/obj/item/reagent_containers/food/snacks/chococoin",
		"/obj/item/dice",
		"/obj/item/disk",
		"/obj/item/implanter",
		"/obj/item/lighter",
		"/obj/item/match",
		"/obj/item/paper",
		"/obj/item/pen",
		"/obj/item/photo",
		"/obj/item/reagent_containers/dropper",
		"/obj/item/screwdriver",
		"/obj/item/blueprints/construction_permit",
		"/obj/item/stamp")
	slot_flags = SLOT_ID|SLOT_BELT

	var/obj/item/card/id/front_id = null


/obj/item/storage/wallet/remove_from_storage(obj/item/W as obj, atom/new_location, var/force = 0, var/refresh = 1)
	. = ..(W, new_location)
	if(.)
		if(W == front_id)
			front_id = null
			update_icon()

/obj/item/storage/wallet/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		if(!front_id && istype(W, /obj/item/card/id))
			front_id = W
			update_icon()

/obj/item/storage/wallet/update_icon()
	if(front_id)
		icon_state = "walletid_[front_id.icon_state]"
	else
		icon_state = "wallet"


/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/get_owner_name_from_ID()
	if(front_id)
		return front_id.get_owner_name_from_ID()
	return ..()

/obj/item/storage/wallet/GetAccess()
	var/obj/item/I = GetID()
	if(I)
		return I.GetAccess()
	else
		return ..()



/obj/item/storage/wallet/random/New()
	..()
	var/item1_type = pick(/obj/item/spacecash,
		/obj/item/spacecash/c10,
		/obj/item/spacecash/c100,
		/obj/item/spacecash/c1000)
	var/item2_type
	if(prob(50))
		item2_type = pick(/obj/item/spacecash,
		/obj/item/spacecash/c10,
		/obj/item/spacecash/c100,
		/obj/item/spacecash/c1000)
	var/item3_type = pick( /obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/gold, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/iron )

	spawn(2)
		if(item1_type)
			new item1_type(src)
		if(item2_type)
			new item2_type(src)
		if(item3_type)
			new item3_type(src)

/obj/item/storage/wallet/trader/New()
	..()
	dispense_cash(rand(150,250),src)
