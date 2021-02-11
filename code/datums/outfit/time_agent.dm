/datum/outfit/time_agent
	var/is_twin = FALSE
	outfit_name = "Time Agent"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel_tox,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/scientist,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/death_commando,
			slot_wear_suit_str = /obj/item/clothing/suit/space/time,
			slot_s_store_str = /obj/item/weapon/tank/emergency_oxygen/double,
			slot_belt_str = /obj/item/weapon/storage/belt/grenade/chrono,
			slot_head_str = /obj/item/clothing/head/helmet/space/time,
		)
	)

	items_to_collect = list(
		/obj/item/device/jump_charge,
		/obj/item/device/timeline_eraser,
		/obj/item/weapon/gun/projectile/automatic/rewind,
		/obj/item/device/chronocapture,
		/obj/item/weapon/pinpointer/advpinpointer,
	)

/datum/outfit/time_agent/pre_equip(var/mob/living/carbon/human/H)
	if (is_twin)
		items_to_collect -= /obj/item/device/jump_charge
		items_to_collect += /obj/item/weapon/storage/box/chrono_grenades/future

	if(H.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		to_chat(H, "<span class='notice'>Your intensive physical training to become a Time Agent has paid off and made you fit again!</span>")
		H.overeatduration = 0 //Fat-B-Gone
		if(H.nutrition > 400) //We are also overeating nutriment-wise
			H.nutrition = 400
		H.mutations.Remove(M_FAT)
		H.update_mutantrace(0)
		H.update_mutations(0)
		H.update_inv_w_uniform(0)
		H.update_inv_wear_suit()

/datum/outfit/time_agent/spawn_id(var/mob/living/carbon/human/H)
	return
