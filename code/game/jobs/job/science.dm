/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#ffddff"
	req_admin_notify = 1
	access = list(access_rd, access_heads, access_rnd, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_science, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_mechanic)
	minimal_access = list(access_rd, access_heads, access_rnd, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_science, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_mechanic)
	minimal_player_age = 20

	outfit_datum = /datum/outfit/rd

/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	wage_payout = 55
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_robotics, access_rnd, access_tox_storage, access_science, access_xenobiology)
	minimal_access = list(access_rnd, access_tox_storage, access_science, access_xenobiology)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Plasma Researcher", "Xenobiologist", "Research Botanist")
	
	outfit_datum = /datum/outfit/scientist

/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	wage_payout = 55
	selection_color = "#ffeeff"
	access = list(access_robotics, access_tech_storage, access_morgue, access_science, access_rnd) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_science) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")

	outfit_datum = /datum/outfit/roboticist

/datum/job/roboticist/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/device/flash/synthetic(H.back), slot_in_backpack)
