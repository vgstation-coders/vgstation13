/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#ffdddd"
	req_admin_notify = 1
	access = list(access_weapons, access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_science, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_eva)
	minimal_access = list(access_weapons, access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_science, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_player_age = 30

	species_whitelist = list("Human")

	outfit_datum = /datum/outfit/hos

/datum/job/hos/reject_new_slots()
	if(security_level == SEC_LEVEL_RED)
		return FALSE
	else
		return "Red Alert"

/datum/job/hos/priority_reward_equip(var/mob/living/carbon/human/H)
	equip_accessory(H, /obj/item/clothing/accessory/holster/handgun/preloaded/glock/fancy, /obj/item/clothing/under, 5)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/donut/normal(H.back), slot_in_backpack)


/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	wage_payout = 65
	selection_color = "#ffeeee"
	access = list(access_weapons, access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels, access_morgue, access_eva)
	minimal_access = list(access_weapons, access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels)
	outfit_datum = /datum/outfit/warden
	minimal_player_age = 7

/datum/job/warden/priority_reward_equip(var/mob/living/carbon/human/H)
	equip_accessory(H, /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical, /obj/item/clothing/shoes, 5)
	equip_accessory(H, /obj/item/clothing/accessory/holster/handgun/preloaded/glock, /obj/item/clothing/under, 5)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/storage/fancy/donut_box(H.back), slot_in_backpack)

/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	wage_payout = 55
	selection_color = "#ffeeee"
	access = list(access_weapons, access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court, access_eva)
	minimal_access = list(access_weapons, access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
	alt_titles = list("Forensic Technician","Gumshoe", "Private Eye")
	outfit_datum = /datum/outfit/detective
	minimal_player_age = 7

/datum/job/detective/priority_reward_equip(var/mob/living/carbon/human/H)
	equip_accessory(H, /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical, /obj/item/clothing/shoes, 5)
	var/obj/item/weapon/reagent_containers/food/drinks/flask/detflask/bonusflask = new /obj/item/weapon/reagent_containers/food/drinks/flask/detflask(H.back)
	bonusflask.reagents.add_reagent(DETCOFFEE, 60)
	H.equip_or_collect(bonusflask, slot_in_backpack)

/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security"
	wage_payout = 55
	selection_color = "#ffeeee"
	access = list(access_weapons, access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue, access_eva)
	minimal_access = list(access_weapons, access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels)
	minimal_player_age = 7
	outfit_datum = /datum/outfit/officer

/datum/job/officer/get_total_positions()
	. = ..()
	var/datum/job/assistant = job_master.GetJob("Assistant")
	if(assistant.current_positions > 5)
		. = clamp(. + assistant.current_positions - 5, 0, 99)

/datum/job/officer/priority_reward_equip(var/mob/living/carbon/human/H)
	equip_accessory(H, /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical, /obj/item/clothing/shoes, 5)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee(H.back), slot_in_backpack)
