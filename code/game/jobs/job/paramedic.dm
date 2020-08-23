/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 2
	supervisors = "the chief medical officer"
	wage_payout = 55
	selection_color = "#ffeef0"
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue, access_surgery)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue, access_surgery)
	outfit_datum = /datum/outfit/paramedic

/datum/job/paramedic/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/storage/belt/medical(H.back), slot_in_backpack)
