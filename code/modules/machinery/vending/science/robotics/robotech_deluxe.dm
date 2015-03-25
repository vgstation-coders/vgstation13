//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "29"
	products = list(/obj/item/clothing/suit/storage/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/stack/cable_coil = 4,/obj/item/device/flash = 4,
					/obj/item/weapon/cell/high = 12, /obj/item/device/assembly/prox_sensor = 3,/obj/item/device/assembly/signaler = 3,/obj/item/device/healthanalyzer = 3,
					/obj/item/weapon/scalpel = 2,/obj/item/weapon/circular_saw = 2,/obj/item/weapon/tank/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/weapon/screwdriver = 5,/obj/item/weapon/crowbar = 5)
	//everything after the power cell had no amounts, I improvised.  -Sayu

	pack = /obj/structure/vendomatpack/undefined