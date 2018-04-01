//This one's from bay12
/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access_txt = "11"
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,
		            /obj/item/clothing/under/rank/engineer = 4,
		            /obj/item/clothing/shoes/sneakers/orange = 4,
		            /obj/item/clothing/head/hardhat = 4,
					/obj/item/storage/belt/utility = 4,
					/obj/item/clothing/glasses/meson/engine = 4,
					/obj/item/clothing/gloves/color/yellow = 4,
					/obj/item/screwdriver = 12,
					/obj/item/crowbar = 12,
					/obj/item/wirecutters = 12,
					/obj/item/device/multitool = 12,
					/obj/item/wrench = 12,
					/obj/item/device/t_scanner = 12,
					/obj/item/stock_parts/cell = 8,
					/obj/item/weldingtool = 8,
					/obj/item/clothing/head/welding = 8,
					/obj/item/light/tube = 10,
					/obj/item/clothing/suit/fire = 4,
					/obj/item/stock_parts/scanning_module = 5,
					/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,
					/obj/item/stock_parts/manipulator = 5)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
