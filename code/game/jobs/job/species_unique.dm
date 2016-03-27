/datum/job/trader
	title = "Trader"
	flag = TRADER
	department_flag = MISC
	faction = "Station"
	total_positions = 0
	spawn_positions = 3
	supervisors = "nobody"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	alt_titles = list("Merchant","Traveller","Vagabond")

	species_whitelist = list("Vox")

	no_crew_manifest = 1
	no_starting_money = 1
	no_random_roll = 1 //Don't become a vox trader randomly
	no_id = 1

/datum/job/trader/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/vox/vox_robes(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/magboots/vox(H), slot_shoes)
	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	return 1

/datum/job/trader/introduce(mob/M, job_title)
	if(!job_title) job_title = src.title

	to_chat(M, "<B>You are a [job_title].</B>")
	to_chat(M, "<b>You've finally got your equipment together, such as it is. Now it's time for action and adventure! In the rush of excitement, you've forgotten where you were going to go. If only you had any friends that could remind you...</b>")
	if(req_admin_notify)
		to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
