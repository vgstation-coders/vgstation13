/datum/job

	//The name of the job
	var/title = "NOPE"

	//Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/minimal_access = list()		//Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()				//Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)

	//Bitflags for the job
	var/flag = 0
	var/info_flag = 0
	var/department_flag = 0

	//Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"

	//How many players can be this job
	var/total_positions = 0
	var/xtra_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	//Sellection screen color
	var/selection_color = "#ffffff"

	//the type of the ID the player will have
	var/idtype = /obj/item/weapon/card/id

	//List of alternate titles, if any
	var/list/alt_titles

	//If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	var/pdatype=/obj/item/device/pda
	var/pdaslot=slot_belt

	var/list/species_blacklist = list() //Job not available to species in this list
	var/list/species_whitelist = list() //If this list isn't empty, job is only available to species in this list

	var/must_be_map_enabled = 0	//If 1, this job only appears on maps on which it's enabled (its type must be in the map's "enabled_jobs" list)
								//Example:      enabled_jobs = list(/datum/job/trader) //Enable "trader" job for this map

	var/no_crew_manifest = 0 //If 1, don't inject players with this job into the crew manifest
	var/no_starting_money = 0 //If 1, don't start with a bank account or money
	var/wage_payout = 50 //Default wage payout
	var/no_id = 0 //If 1, don't spawn with an ID
	var/no_pda= 0 //If 1, don't spawn with a PDA
	var/no_headset = 0 //If 1, don't spawn with a headset
	var/spawns_from_edge = 0 //Instead of spawning on the shuttle, spawns in space and gets thrown

	var/no_random_roll = 0 //If 1, don't select this job randomly!

	var/priority = FALSE //If TRUE, job will display in red in the latejoin menu and grant a priority_reward_equip on spawn.

/datum/job/proc/get_total_positions()
	return clamp(total_positions + xtra_positions, 0, 99)

/datum/job/proc/set_total_positions(var/nu)
	total_positions = nu

/datum/job/proc/bump_position_limit()
	xtra_positions++

/datum/job/proc/reject_new_slots()
	return FALSE

/datum/job/proc/equip(var/mob/living/carbon/human/H)
	return 1

/datum/job/proc/priority_reward_equip(var/mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>You've been granted a little bonus for filling a high-priority job. Enjoy!</span>")
	H.equip_or_collect(new /obj/item/weapon/storage/box/priority_care(H.back), slot_in_backpack)
	return 1

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return src.minimal_access.Copy()

	if(config.jobs_have_minimal_access)
		return src.minimal_access.Copy()
	else
		return src.access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/introduce(mob/M, job_title)
	if(!job_title)
		job_title = title
	log_admin("([M.ckey]/[M]) started the game as a [job_title].")
	to_chat(M, "<B>You are the [job_title].</B>")
	to_chat(M, "<b>As the [job_title] you answer directly to [src.supervisors]. Special circumstances may change this.</b>")

	if(src.req_admin_notify)
		to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
