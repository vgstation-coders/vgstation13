//Due to how large this one is, it gets its own file from civilian.dm
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "The God(s), the Head of Personnel too"
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)
	pdaslot = slot_belt
	pdatype = /obj/item/device/pda/chaplain
	var/datum/religion/chap_religion

/datum/job/chaplain/equip(var/mob/living/carbon/human/H)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.add_language("Spooky") //SPOOK
	H.equip_or_collect(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/weapon/nullrod(H), slot_l_store)//each chaplain brings their own
	//H.equip_or_collect(new /obj/item/device/pda/chaplain(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/shoes/laceup(H), slot_shoes)

	if(H.backbag == 1)
		H.put_in_hands(new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)

	H.put_in_hands(new /obj/item/weapon/thurible(H))

	spawn(0) //We are done giving earthly belongings, now let's move on to spiritual matters
		ChooseReligion(H)
	return 1

/datum/job/chaplain/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater(H.back), slot_in_backpack)
