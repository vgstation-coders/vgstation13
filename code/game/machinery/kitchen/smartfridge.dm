/* SmartFridge.  Much todo
*/
/obj/machinery/vending/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	flags = NOREACT
	smartfridge = 1
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/opened = 0.0
	accepted_types = list(	/obj/item/weapon/reagent_containers/food/snacks/grown,
									/obj/item/weapon/grown,
									/obj/item/seeds/,
									/obj/item/weapon/reagent_containers/food/snacks/meat,
									/obj/item/weapon/reagent_containers/food/snacks/egg)

	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)


/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/

/obj/machinery/vending/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."

	accepted_types = list(	/obj/item/weapon/storage/pill_bottle,
							/obj/item/weapon/reagent_containers)


/obj/machinery/vending/smartfridge/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"

	accepted_types = list(/obj/item/slime_extract)


/obj/machinery/vending/smartfridge/power_change()
	if( powered() )
		stat &= ~NOPOWER
		if(!(stat & BROKEN))
			icon_state = icon_on
	else
		spawn(rand(0, 15))
		stat |= NOPOWER
		if(!(stat & BROKEN))
			icon_state = icon_off