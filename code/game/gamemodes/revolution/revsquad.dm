//A variant of revolution, with an emphasis on a small group with co-ordinated efforts instead of greytiding

#define REVSQUAD_FLASH_USES 2 // Number of times a specially spawned flash can convert normal crew members.

#define REVSQUAD_VICTORY_REVS 1
#define REVSQUAD_VICTORY_HEADS 2
/datum/game_mode/revsquad
	name = "Revolution Squad"
	config_tag = "revsquad"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Mobile MMI","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent", "Trader")

	required_players = 4
	required_players_secret = 25
	required_enemies = 3
	recommended_enemies = 3
	var/finished = 0
	var/checkwin_counter = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/minimum_heads = 2
	var/list/possible_items = list(/obj/item/weapon/card/emag,
								   /obj/item/clothing/gloves/yellow,
								   /obj/item/weapon/gun/projectile/automatic,
								   /obj/item/device/flash/revsquad,
								   /obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff,
								   /obj/item/weapon/plastique,
								   /obj/item/weapon/gun/projectile/pistol,
								   /obj/item/weapon/aiModule/freeform/syndicate
								  )

/datum/game_mode/revsquad/announce()
	to_chat(world, "<b>The current game mode is - Revolution Squad!</B>")
	to_chat(world, "<b>Some crewmembers are members of an organized group attempting to assassinate the heads of this station!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. \nPersonnel - Protect the heads of staff. Kill the revolutionaries.</B>")


/datum/game_mode/revsquad/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_revs = get_players_for_role(ROLE_REV)

	var/head_check = 0
	for(var/mob/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check++

	for(var/datum/mind/player in possible_revs)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				possible_revs -= player
	// Depending how this mode performs, might need to change this to have a minimum number of revs as required and a maximum as recommended.
	for (var/i=1 to required_enemies)
		if (possible_revs.len==0)
			break
		var/datum/mind/lenin = pick(possible_revs)
		possible_revs -= lenin
		head_revolutionaries += lenin

	// If an admin forces this mode, we set the minimum head count to 1, otherwise check minimum heads
	if(master_mode=="secret" && secret_force_mode=="secret")
		if(head_revolutionaries.len==0 || head_check < minimum_heads)
			log_admin("Failed to set-up a round of revsquad. Couldn't find any heads of staffs or any volunteers to be revolutionaries.")
			log_admin("Number of headrevs: [head_revolutionaries.len] Number of heads: [head_check]")
			message_admins("Failed to set-up a round of revsquad. Couldn't find any heads of staffs or any volunteers to be revolutionaries.")
			message_admins("Number of headrevs: [head_revolutionaries.len] Heads of Staff: [get_assigned_head_roles()]")
			return 0

	else if (head_revolutionaries.len==0 || head_check < 1)
		log_admin("Failed to set-up a secret-forced round of revsquad. Couldn't find any heads of staffs or any volunteers to be revolutionaries.")
		message_admins("Failed to set-up a secret-forced round of revsquad. Couldn't find any heads of staffs or any volunteers to be revolutionaries.")
		return 0

	log_admin("Starting a round of revsquad with [head_revolutionaries.len] revolutionaries and [head_check] heads of staff.")
	message_admins("Starting a round of revsquad with [head_revolutionaries.len] revolutionaries and [head_check] heads of staff.")
	return 1

/datum/game_mode/revsquad/post_setup()
	var/list/heads = get_living_heads()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

		equip_revsquad(rev_mind.current)
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revsquad(rev_mind)

	modePlayer += head_revolutionaries

	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1

	spawn (rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept()
	..()

/datum/game_mode/revsquad/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/revsquad/proc/greet_revsquad(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='big bold center red'>You are a member of the organized revolutionary organization that has infiltrated this station!</span>")
		to_chat(rev_mind.current, "<span class='info'><a HREF='?src=\ref[rev_mind.current];getwiki=["Revolutionary Squad"]'>(Wiki Guide)</a></span>") // Hacky but revsquad doesn't have a pref define or anything
	for(var/datum/objective/objective in rev_mind.objectives)
		to_chat(rev_mind.current, "<b>Objective #[obj_count]</B>: [objective.explanation_text]")
		rev_mind.special_role = "Revolutionary Squad Member"
		obj_count++

	to_chat(rev_mind.current, "<br/><b>Your fellow revolutionaries are:</b>")
	rev_mind.store_memory("<br/><b>Your fellow revolutionaries are:</b>")
	for(var/datum/mind/M in head_revolutionaries)
		if(M.assigned_role)
			rev_mind.store_memory("[M.name] the [M.assigned_role]")
			to_chat(rev_mind.current, "[M.name] the [M.assigned_role]")
		else
			log_debug("Headrev for revsquad with no assigned role: [M.name]")
			rev_mind.store_memory("[M.name]")
			to_chat(rev_mind.current, "[M.name]")

/datum/game_mode/revsquad/proc/get_revsquad_item(var/mob/living/carbon/human/M)
	var/obj/item/requisitioned = pick(possible_items)
	possible_items.Remove(requisitioned) // No 3 pairs of insulated gloves
	if(istype(requisitioned, /obj/item/device/flash/revsquad))
		var/obj/item/device/flash/revsquad/FR = new(M)
		requisitioned = FR
	else
		requisitioned = new requisitioned(M)
	return requisitioned

// Since it's part of the revsquad type, this will not currently work with make antags. Which is fine because this is a variant on rev.
/datum/game_mode/revsquad/proc/equip_revsquad(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(M_CLUMSY)

	var/obj/item/T = get_revsquad_item(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
	)
	var/where = mob.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 0)

	if (!where)
		to_chat(mob, "The Syndicate were unfortunately unable to get you any special equipment.")
	else
		to_chat(mob, "The [T] in your [where] will help you to persuade the crew to join your cause.")
		if(istype(T, /obj/item/device/flash/revsquad))
			var/obj/item/device/flash/revsquad/FR = T
			to_chat(mob, "<span class = 'warning'>Your [FR] has [FR.limited_conversions] uses for conversions, and not all of your comrades have one like it. Use it wisely.</span>")
		mob.update_icons()
		stat_collection.revsquad.revsquad_items += T.name
		return 1

/datum/game_mode/revsquad/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			if(!objective.check_completion())
				return 0
		return 1

/datum/game_mode/revsquad/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if(rev_mind && rev_mind.current && !rev_mind.current.isDead() && T && T.z == map.zMainStation)
			if(ishuman(rev_mind.current))
				return 0

	return 1


/datum/game_mode/revsquad/check_win()
	if(check_rev_victory())
		finished = REVSQUAD_VICTORY_REVS
	else if(check_heads_victory())
		finished = REVSQUAD_VICTORY_HEADS

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revsquad/check_finished()
	if(config.continous_rounds)
		// if(finished != 0)
		// 	if(emergency_shuttle)
		// 		emergency_shuttle.always_fake_recall = 0
		return ..()
	return finished != 0

/datum/game_mode/revsquad/declare_completion()
	if(finished == REVSQUAD_VICTORY_REVS)
		feedback_set_details("round_end_result","win - heads killed")
		completion_text = "<br><span class='danger'><FONT size = 3> The heads of staff were killed or abandoned the station! The revolutionaries win!</FONT></span>"
		stat_collection.revsquad.revsquad_won = 1
	else if(finished == REVSQUAD_VICTORY_HEADS)
		feedback_set_details("round_end_result","loss - rev heads killed")
		completion_text = "<br><span class='danger'>The heads of staff managed to stop the revolution!</FONT></span>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revsquad()
	var/list/targets = list()
	var/text = ""
	if(head_revolutionaries.len || istype(ticker.mode,/datum/game_mode/revsquad))
		var/icon/logo1 = icon('icons/mob/mob.dmi', "rev_head-logo")
		end_icons += logo1
		var/tempstate = end_icons.len
		text += "<img src='logo_[tempstate].png'><span class = 'big bold'The revolutionary squad members were:</span> <img src='logo_[tempstate].png'>"

		for(var/datum/mind/headrev in head_revolutionaries)
			if(headrev.current)
				var/icon/flat = getFlatIcon(headrev.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += "<br><img src='logo_[tempstate].png'> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("
				if(headrev.current.isDead())
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(headrev.current.z != map.zMainStation)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as [headrev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += "<br><img src='logo_[tempstate].png'> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("
				text += "body destroyed"
			text += ")"

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target


	if(revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/icon/logo2 = icon('icons/mob/mob.dmi', "rev-logo")
		end_icons += logo2
		var/tempstate = end_icons.len
		text += "<br><img src='logo_[tempstate].png'> <FONT size = 2><b>The recruited revolutionaries were:</B></FONT> <img src='logo_[tempstate].png'>"

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				var/icon/flat = getFlatIcon(rev.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += "<br><img src='logo_[tempstate].png'> <b>[rev.key]</b> was <b>[rev.name]</b> ("
				if(rev.current.isDead())
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(rev.current.z != map.zMainStation)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(rev.current.real_name != rev.name)
					text += " as [rev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += "<br><img src='logo_[tempstate].png'> <b>[rev.key]</b> was <b>[rev.name]</b> ("
				text += "body destroyed"
			text += ")"



	if( head_revolutionaries.len || revolutionaries.len )
		var/icon/logo3 = icon('icons/mob/mob.dmi', "nano-logo")
		end_icons += logo3
		var/tempstate = end_icons.len
		text += "<br><img src='logo_[tempstate].png'> <span class = 'big bold'>The heads of staff were:</span> <img src='logo_[tempstate].png'>"

		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<span class='red'>"
			if(head.current)
				var/icon/flat = getFlatIcon(head.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += "<br><img src='logo_[tempstate].png'> <b>[head.key]</b> was <b>[head.name]</b> ("
				if(head.current.isDead())
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(head.current.z != map.zMainStation)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(head.current.real_name != head.name)
					text += " as [head.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += "<br><img src='logo_[tempstate].png'> <b>[head.key]</b> was <b>[head.name]</b> ("
				text += "body destroyed"
			text += ")"
			if(target)
				text += "</span>"

		text += "<br /><hr>"
	return text
