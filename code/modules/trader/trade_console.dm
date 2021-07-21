//Many things here cribbed off vendor but with important changes
WIP note - dont forget the coin modules

/obj/structure/trade_console
	name = "Trade Console"
	desc = "Exploits slipspace technology to exchange credits for products, even in the absence of traditional power and accounts data."
	icon = 'icons/obj/computer.dmi'
	icon_state = "old"
	req_access = list(access_trader)
	var/credits_held = 0 //inserted cash
	var/product_selected = null //targets a datum in the list

/obj/structure/trade_console/wrenchable()
	return TRUE

/obj/structure/trade_console/attackby(obj/item/W, mob/user)
	..()
	if(!anchored)
		return
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		pay_with_cash(C, user)

	else if(istype(W, /obj/item/weapon/card) && product_selected)
		//Does not check for linked database because it always connects - POWER OF MONEY!
		var/obj/item/weapon/card/C = W
		pay_with_card(C, user)
		updateUsrDialog()

/obj/structure/trade_console/proc/pay_with_cash(obj/item/weapon/spacecash/C, mob/user)
	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>", "You hear a whirr.")
	credits_held += cashmoney.get_total()
	qdel(cashmoney)
	if(credits_held >= product_selected.current_price())
		credits_held -= product_selected.current_price()
		trade(product_selected, user)
		product_selected = null
		updateUsrDialog()


