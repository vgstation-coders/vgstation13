/datum/outfit/striketeam/ert
	outfit_name = "Emergency response team"
	use_pref_bag = FALSE

	backpack_types = list(
		BACKPACK_STRING = /obj/item/storage/backpack/security
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/ert,
			slot_w_uniform_str = /obj/item/clothing/under/ert,
			slot_l_store_str = /obj/item/device/flashlight,
			slot_belt_str = /obj/item/gun/energy/gun/nuclear,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_shoes_str = /obj/item/clothing/shoes/swat,
			slot_gloves_str = /obj/item/clothing/gloves/swat,
		),
	)

	equip_survival_gear = list(
		"Default" = /obj/item/storage/box/survival/ert,
	)

	implant_types = list(
		/obj/item/implant/loyalty/,
	)

	items_to_collect = list(
		/obj/item/storage/firstaid/regular
	)

	id_type = /obj/item/card/id/emergency_responder
	id_type_leader = /obj/item/card/id/emergency_responder_leader
	assignment_leader = "Emergency Responder Leader"
	assignment_member = "Emergency Responder"

/datum/outfit/striketeam/ert/pre_equip(var/mob/living/carbon/human/H)
	//Adding Camera Network
	var/obj/machinery/camera/camera = new /obj/machinery/camera(H) //Gives all the commandos internals cameras.
	camera.network = list(CAMERANET_ERT)
	camera.c_tag = H.real_name

	if (is_leader)
		items_to_collect += /obj/item/card/shuttle_pass/ert

/datum/outfit/striketeam/ert/post_equip(var/mob/living/carbon/human/H)
	..()
	if (is_leader)
		equip_accessory(H, /obj/item/clothing/accessory/holster/handgun/preloaded/NTUSP/fancy, /obj/item/clothing/under, 5)
	else
		equip_accessory(src, /obj/item/clothing/accessory/holster/handgun/preloaded/NTUSP, /obj/item/clothing/under, 5)
