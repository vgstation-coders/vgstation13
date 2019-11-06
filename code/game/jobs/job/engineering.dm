/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload, access_mechanic)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload, access_mechanic)
	minimal_player_age = 20
	outfit_datum = /datum/outfit/chief_engineer

/datum/job/chief_engineer/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/clothing/glasses/scanner/meson(H), slot_glasses)
	H.equip_or_collect(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/cracker(H.back), slot_in_backpack) //poly gets part of the divvy, savvy?

/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")
	outfit_datum = /datum/outfit/engineer

/datum/job/engineer/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/clothing/glasses/scanner/meson(H), slot_glasses)
	H.equip_or_collect(new /obj/item/clothing/gloves/yellow(H), slot_gloves)

/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction, access_engine_equip, access_external_airlocks)
	outfit_datum = /datum/outfit/atmos

/datum/job/atmos/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/clothing/glasses/scanner/meson(H), slot_glasses)
	H.equip_or_collect(new /obj/item/clothing/gloves/yellow(H), slot_gloves)

/datum/job/mechanic
	title = "Mechanic"
	flag = MECHANIC
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the research director and the chief engineer"
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_mechanic, access_tcomsat, access_science)
	minimal_access = list(access_maint_tunnels, access_emergency_storage, access_construction, access_engine_equip, access_external_airlocks, access_mechanic, access_tcomsat, access_science)
	alt_titles = list("Telecommunications Technician", "Spacepod Mechanic", "Greasemonkey")
	outfit_datum = /datum/outfit/mechanic