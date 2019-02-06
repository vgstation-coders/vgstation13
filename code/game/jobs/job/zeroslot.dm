/datum/job/zeroslot
	//Abstract type
	flag = null
	department_flag = null //only used by prefs and predict manifest
	spawn_positions = 0 //only used by roundstart jobs
	faction = "Station"

	total_positions = 0 //the whole point of this file
	no_crew_manifest = TRUE
	no_starting_money = TRUE
	no_pda = TRUE

/*/datum/job/zeroslot/convict
	title = "Convict"
	supervisors = "the warden"
	idtype = /obj/item/weapon/card/id/convict

/datum/job/zeroslot/convict/equip(var/mob/living/carbon/human/H)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/color/prisoner, slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/orange, slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs, slot_handcuffed)
	H.equip_to_slot_or_del(new /obj/item/weapon/legcuffs, slot_legcuffed)

	var/obj/item/weapon/implant/tracking/T = new/obj/item/weapon/implant/tracking(H)
	T.imp_in = H
	T.implanted = 1
	var/datum/organ/external/affected = H.get_organ(LIMB_HEAD)
	affected.implants += T
	T.part = affected

	var/obj/item/weapon/implant/chem/sleepy/S = new(H)
	S.imp_in = H
	S.implanted = 1
	affected.implants += S
	T.part = affected

/datum/job/convict/priority_reward_equip(var/mob/living/carbon/human/H)
	//Different box
	H.equip_or_collect(new /obj/item/weapon/storage/box/priority_prisoner, slot_in_backpack)
	H.equip_or_collect(new /obj/item/stack/rods(H.loc,2), slot_in_backpack)*/

/datum/job/zeroslot/AIvolunteer
	title = "AIization Volunteer"
	access = list(access_robotics)
	minimal_access = list(access_robotics)
	supervisors = "the roboticist"
	idtype = /obj/item/weapon/card/id/volunteer
	req_admin_notify = 2
	minimal_player_age = 30

/datum/job/zeroslot/AIvolunteer/equip(var/mob/living/carbon/human/H)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/color/white, slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/white, slot_shoes)

	H.equip_or_collect(new /obj/item/weapon/circuitboard/aicore, slot_in_backpack)
	H.equip_or_collect(new /obj/item/stack/sheet/plasteel(H.loc,4), slot_in_backpack)
	H.equip_or_collect(new /obj/item/stack/cable_coil(H.loc,5), slot_in_backpack)

/datum/job/zeroslot/AIvolunteer/priority_reward_equip(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/weapon/storage/bag/plastic/carrots(H), slot_belt)
	//No ..() because no box

/datum/job/zeroslot/Borgvolunteer
	title = "Cyborgification Volunteer"
	access = list(access_robotics)
	minimal_access = list(access_robotics)
	supervisors = "the roboticist"
	idtype = /obj/item/weapon/card/id/volunteer

/datum/job/zeroslot/Borgvolunteer/equip(var/mob/living/carbon/human/H)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/color/white, slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/white, slot_shoes)

	H.equip_or_collect(new /obj/item/stack/sheet/metal(H.loc,45), slot_in_backpack) //Metal cost of one head, torso, and endoskeleton without upgrades/research
	H.equip_or_collect(new /obj/item/robot_parts/l_arm(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/robot_parts/r_arm(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/robot_parts/l_leg(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/robot_parts/r_leg(H), slot_in_backpack)

/datum/job/zeroslot/Borgvolunteer/priority_reward_equip(var/mob/living/carbon/human/H)
	//No box of goodies
	var/list/upgrades = existing_typesof(/obj/item/borg/upgrade) - /obj/item/borg/upgrade/magnetic_gripper
	var/upgradetospawn = pick(upgrades)
	H.equip_or_collect(new upgradetospawn, slot_in_backpack)