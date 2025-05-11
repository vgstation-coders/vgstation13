/datum/job/rd
	title = "Research Director"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#ffddff"
	req_admin_notify = 1
	access = list(access_rd, access_heads, access_rnd, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors, access_tech_storage,
			            access_science, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_mechanic)
	minimal_access = list(access_rd, access_heads, access_rnd, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors, access_tech_storage,
			            access_science, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_mechanic)
	minimal_player_age = 20

	outfit_datum = /datum/outfit/rd

/datum/job/scientist
	title = "Scientist"
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	wage_payout = 55
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_rnd, access_robotics, access_tox_storage, access_science, access_xenobiology)
	minimal_access = list(access_rnd, access_tox_storage, access_science, access_xenobiology)
	alt_titles = list("Plasma Researcher", "Research Botanist")

	outfit_datum = /datum/outfit/scientist

/datum/job/xenoarchaeologist
	title = "Xenoarchaeologist"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	wage_payout = 55
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_rnd, access_robotics, access_tox_storage, access_science, access_xenobiology)
	minimal_access = list(access_rnd, access_tox_storage, access_science, access_xenobiology)
	alt_titles = list("Anomalist")

	outfit_datum = /datum/outfit/xenoarchaeologist

/datum/job/xenobiologist
	title = "Xenobiologist"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	wage_payout = 55
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_rnd, access_robotics, access_tox_storage, access_science, access_xenobiology)
	minimal_access = list(access_rnd, access_tox_storage, access_science, access_xenobiology)

	outfit_datum = /datum/outfit/xenobiologist

/datum/job/roboticist
	title = "Roboticist"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	wage_payout = 55
	selection_color = "#ffeeff"
	access = list(access_rnd, access_robotics, access_tech_storage, access_morgue, access_science) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_science) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")

	outfit_datum = /datum/outfit/roboticist
