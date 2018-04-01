/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(/obj/item/stack/cable_coil/random = 10,
		            /obj/item/crowbar = 5,
		            /obj/item/weldingtool = 3,
		            /obj/item/wirecutters = 5,
		            /obj/item/wrench = 5,
		            /obj/item/device/analyzer = 5,
		            /obj/item/device/t_scanner = 5,
		            /obj/item/screwdriver = 5,
		            /obj/item/device/flashlight/glowstick = 3,
		            /obj/item/device/flashlight/glowstick/red = 3,
		            /obj/item/device/flashlight = 5)
	contraband = list(/obj/item/weldingtool/hugetank = 2,
		              /obj/item/clothing/gloves/color/fyellow = 2)
	premium = list(/obj/item/clothing/gloves/color/yellow = 1)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
