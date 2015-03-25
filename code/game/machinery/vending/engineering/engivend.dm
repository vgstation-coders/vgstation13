/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	req_access_txt = "11" //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/device/multitool = 4,/obj/item/weapon/circuitboard/airlock = 10,/obj/item/weapon/module/power_control = 10,/obj/item/weapon/circuitboard/air_alarm = 10,/obj/item/weapon/intercom_electronics = 10,/obj/item/weapon/cell/high = 10)
	contraband = list(/obj/item/weapon/cell/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)

	pack = /obj/structure/vendomatpack/engivend