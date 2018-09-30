/**
 * vox heist roundtype
 */

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	required_players = 15
	required_players_secret = 25
	required_enemies = 4
	recommended_enemies = 6

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/raid_objectives = list()     //Raid objectives.

/datum/game_mode/heist/announce()
	to_chat(world, {"
		<B>The current game mode is - Heist!</B>
		<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>
		Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!
		<B>Raiders:</B> Loot [station_name()] for anything and everything you need.
		<B>Personnel:</B> Repel the raiders and their low, low prices and/or crossbows."})

/datum/game_mode/heist/pre_setup()
	var/list/candidates = get_players_for_role(ROLE_VOXRAIDER)
	var/raider_num = 0

	//Check that we have enough vox.
	if(candidates.len < required_enemies)
		log_admin("Failed to set-up a round of heist. Couldn't find enough volunteers to be vox raiders.(only [candidates.len] volunteers out of at least [required_enemies])")
		message_admins("Failed to set-up a round of heist. Couldn't find enough volunteers to be vox raiders.(only [candidates.len] volunteers out of at least [required_enemies])")
		return 0
	else if(candidates.len < recommended_enemies)
		raider_num = candidates.len
	else
		raider_num = recommended_enemies

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(candidates)
		raiders += new_raider
		candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = "Vox Raider"

	log_admin("Starting a round of heist with [raiders.len] vox raiders.")
	message_admins("Starting a round of heist with [raiders.len] vox raiders.")
	return 1

/datum/game_mode/heist/post_setup()

	//Build a list of spawn points.
	var/list/turf/raider_spawn = list()

	for(var/obj/effect/landmark/start in landmarks_list)
		if(start.name == "voxstart")
			raider_spawn += get_turf(start)
			qdel(start)

	// generate objectives for the group.
	forge_vox_objectives()

	var/index = 1

	//Spawn the vox!
	for(var/datum/mind/raider in raiders)

		if(index > raider_spawn.len)
			index = 1

		raider.current.forceMove(raider_spawn[index])
		index++


		var/mob/living/carbon/human/vox = raider.current
		raider.name = vox.name
		vox.age = rand(12,20)
		if(vox.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
			vox.overeatduration = 0 //Fat-B-Gone
			if(vox.nutrition > 400) //We are also overeating nutriment-wise
				vox.nutrition = 400 //Fix that
			vox.mutations.Remove(M_FAT)
			vox.update_mutantrace(0)
			vox.update_mutations(0)
			vox.update_inv_w_uniform(0)
			vox.update_inv_wear_suit()

		vox.s_tone = random_skin_tone("Vox")
		vox.dna.mutantrace = "vox"
		vox.set_species("Vox")
		vox.fully_replace_character_name(vox.real_name, vox.generate_name())
		//vox.languages = HUMAN // Removing language from chargen.
		vox.default_language = all_languages[LANGUAGE_VOX]
		vox.flavor_text = ""
		vox.species.default_language = LANGUAGE_VOX
		vox.remove_language(LANGUAGE_GALACTIC_COMMON)
		vox.h_style = "Short Vox Quills"
		vox.f_style = "Shaved"
		for(var/datum/organ/external/limb in vox.organs)
			limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT | ORGAN_PEG)
		vox.equip_vox_raider()
		vox.regenerate_icons()

		raider.objectives = raid_objectives
		greet_vox(raider)

	spawn (rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept()

/datum/game_mode/heist/proc/is_raider_crew_alive()
	var/raider_crew_count = raiders.len

	for(var/datum/mind/raider in raiders)
		if(raider && ishuman(raider.current) && raider.current.stat != DEAD)
			continue

		raider_crew_count--

	if(raider_crew_count <= 0)
		return FALSE

	return TRUE

/datum/game_mode/heist/proc/is_raider_crew_safe()
	if(!is_raider_crew_alive())
		return FALSE

	var/end_area = get_area(locate(/area/shuttle/vox/station))

	for(var/datum/mind/raider in raiders)
		if(get_area(raider.current) != end_area)
			return FALSE

	return TRUE

/datum/game_mode/heist/proc/forge_vox_objectives()
	if(prob(50))
		raid_objectives += new/datum/objective/heist/kidnap
	else
		raid_objectives += new/datum/objective/steal/heist_easy
		raid_objectives += new/datum/objective/steal/heist_easy
	raid_objectives += new/datum/objective/steal/heist_hard
	//raid_objectives += new/datum/objective/steal/salvage
	raid_objectives += new/datum/objective/heist/inviolate_crew
	//raid_objectives += new/datum/objective/heist/inviolate_death // Crew death permitted. No tears.

	for(var/datum/objective/heist/O in raid_objectives)
		O.choose_target()

	for(var/datum/objective/steal/O in raid_objectives)
		O.find_target()


/datum/game_mode/heist/proc/greet_vox(const/datum/mind/raider)
	to_chat(raider.current, {"<span class='notice'><B>You are a Vox Raider, fresh from the Shoal!</b>
Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.
Use :V to voxtalk, :H to talk on your encrypted channel, and <b>don't forget to turn on your nitrogen internals!</span>"})
	to_chat(raider.current, {"<span class='danger'>The Shoal forbids excessive bloodletting.  Minimize casualties or face banishment.</span>"})

	var/obj_count = 0

	for(var/datum/objective/objective in raider.objectives)
		to_chat(raider.current, "<B>Objective #[obj_count++]</B>: [objective.explanation_text]")

/datum/game_mode/heist/declare_completion()
	// no objectives, go straight to the feedback
	if(isnull(raid_objectives) || raid_objectives.len <= 0)
		return ..()

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = raid_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion()))
			success--

	//Set result by objectives.
	if(success == raid_objectives.len)
		win_type = "Major"
		win_group = "Vox"
	else if(success > 2)
		win_type = "Minor"
		win_group = "Vox"
	else
		win_type = "Minor"
		win_group = "Crew"

	// now we modify that result by the state of the vox crew
	if(!is_raider_crew_alive())
		win_type = "Major"
		win_group = "Crew"
		win_msg += "<B>The Vox Raiders have been wiped out!</B>"
	else if(!is_raider_crew_safe())
		if(win_group == "Crew" && win_type == "Minor")
			win_type = "Major"

		win_group = "Crew"
		win_msg += "<B>The Vox Raiders have left someone behind!</B>"
	else
		if(win_group == "Vox")
			if(win_type == "Minor")
				win_type = "Major"

			win_msg += "<B>The Vox Raiders escaped the station!</B>"
		else
			win_msg += "<B>The Vox Raiders were repelled!</B>"

	completion_text += "<br><span class='danger'><FONT size = 3>[win_type] [win_group] victory!</FONT><br>[win_msg]</span>"

	feedback_set_details("round_end_result","heist - [win_type] [win_group]")

	var/count = 0

	for(var/datum/objective/objective in raid_objectives)
		count++

		if(objective.check_completion())
			completion_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
			feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			completion_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
			feedback_add_details("traitor_objective","[objective.type]|FAIL")

	var/icon/logo = icon('icons/mob/mob.dmi', "vox-logo")
	end_icons += logo
	var/tempstate = end_icons.len
	var/text = {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The vox raiders were:</B></FONT> <img src="logo_[tempstate].png">"}
	var/end_area = get_area(locate(/area/shuttle/vox/station))

	for(var/datum/mind/vox in raiders)

		if(vox.current)
			var/icon/flat = getFlatIcon(vox.current, SOUTH, 1, 1)
			end_icons += flat
			tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[vox.key]</b> was <b>[vox.name]</b> ("}
			if(get_area(vox.current) != end_area)
				text += "left behind, "

			if(vox.current.stat != DEAD)
				text += "survived"
			else
				text += "died"
				flat.Turn(90)
				end_icons[tempstate] = flat

			if(vox.current.real_name != vox.name)
				text += " as [vox.current.real_name]"
		else
			var/icon/sprotch = icon('icons/effects/blood.dmi', "voxblood")
			end_icons += sprotch
			tempstate = end_icons.len
			text += {"<br><img src="logo_[tempstate].png"> <b>[vox.key]</b> was <b>[vox.name]</b> ("}
			text += "body destroyed"

		text += ")"

	completion_text += text
	..()
	return 1

/datum/game_mode/heist/check_finished()
	if(!is_raider_crew_alive() || (vox_shuttle && vox_shuttle.returned_home))
		return 1

	return ..()
