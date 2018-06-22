// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.



/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Mobile MMI","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
	required_players = 4
	required_players_secret = 25
	required_enemies = 3
	recommended_enemies = 3


	uplink_welcome = "Revolutionary Uplink Console:"
	uplink_uses = 20

	var/finished = 0
	var/checkwin_counter = 0
	var/max_headrevs = 3
	var/minimum_heads = 2
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_headrevs = get_players_for_role(ROLE_REV)

	var/head_check = 0
	for(var/mob/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check++

	for(var/datum/mind/player in possible_headrevs)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				possible_headrevs -= player

	for (var/i=1 to max_headrevs)
		if (possible_headrevs.len==0)
			break
		var/datum/mind/lenin = pick(possible_headrevs)
		possible_headrevs -= lenin
		head_revolutionaries += lenin

	// If an admin forces this mode, we set the minimum head count to 1, otherwise check minimum heads
	if(master_mode=="secret" && secret_force_mode=="secret")
		if(head_revolutionaries.len==0 || head_check < minimum_heads)
			log_admin("Failed to set-up a round of revolution. Couldn't find enough heads of staffs or any volunteers to be head revolutionaries.")
			log_admin("Number of headrevs: [head_revolutionaries.len] Number of heads: [head_check]")
			message_admins("Failed to set-up a round of revolution. Couldn't find enough heads of staffs or any volunteers to be head revolutionaries.")
			message_admins("Number of headrevs: [head_revolutionaries.len] Heads of Staff: [get_assigned_head_roles()]")
			return 0

	else if (head_revolutionaries.len==0 || head_check < 1)
		log_admin("Failed to setup a round of revolution while secret forced mode: there was not at least one head. Headcount: [head_check]")
		message_admins("Failed to setup a round of revolution while secret forced mode: there was not at least one head. Headcount: [head_check]")
		return 0

	log_admin("Starting a round of revolution with [head_revolutionaries.len] head revolutionaries and [head_check] heads of staff.")
	message_admins("Starting a round of revolution with [head_revolutionaries.len] head revolutionaries and [head_check] heads of staff.")
	return 1


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

	//	equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO
	//	Removing revolutionary uplinks.	-Pete
		equip_revolutionary(rev_mind.current)
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 0
	spawn (rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept()
	..()


/datum/game_mode/revolution/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0


/datum/game_mode/proc/forge_revolutionary_objectives(var/datum/mind/rev_mind)
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='notice'>You are a member of the revolutionaries' leadership!</span>")
	for(var/datum/objective/objective in rev_mind.objectives)
		to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	var/obj/item/device/flash/T = new(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
	)
	var/where = mob.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 1)

	if (!where)
		to_chat(mob, "The Syndicate were unfortunately unable to get you a flash.")
	else
		to_chat(mob, "The flash in your [where] will help you to persuade the crew to join your cause.")
		mob.update_icons()
		return 1

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(config.continous_rounds)
		if(finished != 0)
			if(emergency_shuttle)
				emergency_shuttle.always_fake_recall = 0
		return ..()
	if(finished != 0)
		return 1
	else
		return 0

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in command_positions)
		return ADD_REVOLUTIONARY_FAIL_IS_COMMAND

	var/mob/living/carbon/human/H = rev_mind.current

	if(jobban_isbanned(H, "revolutionary"))
		return ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED

	for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
		if(L.imp_in == H) // a check if it's actually implanted
			return ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED

	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return ADD_REVOLUTIONARY_FAIL_IS_REV

	revolutionaries += rev_mind
	to_chat(rev_mind.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)

	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null

		if(beingborged)
			rev_mind.current.visible_message(
				"<span class='big danger'>The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.</span>",
				"<span class='big danger'>The frame's firmware detects and deletes your neural reprogramming! You remember nothing from the moment you were flashed until now.</span>")
		else
			rev_mind.current.visible_message("<span class='big danger'>It looks like [rev_mind.current] just remembered their real allegiance!</span>",
				"<span class='big danger'>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</span>")

		update_rev_icons_removed(rev_mind)
		log_admin("[rev_mind.current] ([ckey(rev_mind.current.key)] has been deconverted from the revolution")


/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
//CURRENTLY CONTAINS BUGS:///////////////////////////////////////////////////////////////////////
//-PLAYERS THAT HAVE BEEN REVS FOR AWHILE OBTAIN THE BLUE ICON WHILE STILL NOT BEING A REV HEAD//
// -Possibly caused by cloning of a standard rev/////////////////////////////////////////////////
//-UNCONFIRMED: DECONVERTED REVS NOT LOSING THEIR ICON properLY//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_rev_icons()
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							//del(I)
							head_rev_mind.current.client.images -= I

		for(var/datum/mind/rev_mind in revolutionaries)
			if(rev_mind.current)
				if(rev_mind.current.client)
					for(var/image/I in rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							//del(I)
							rev_mind.current.client.images -= I

		for(var/datum/mind/head_rev in head_revolutionaries)
			if(head_rev.current)
				if(head_rev.current.client)
					for(var/datum/mind/rev in revolutionaries)
						if(rev.current)
							var/imageloc = rev.current
							if(istype(rev.current.loc,/obj/mecha))
								imageloc = rev.current.loc
							var/image/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev")
							I.plane = REV_ANTAG_HUD_PLANE
							head_rev.current.client.images += I
					for(var/datum/mind/head_rev_1 in head_revolutionaries)
						if(head_rev_1.current)
							var/imageloc = head_rev_1.current
							if(istype(head_rev_1.current.loc,/obj/mecha))
								imageloc = head_rev_1.current.loc
							var/image/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev_head")
							I.plane = REV_ANTAG_HUD_PLANE
							head_rev.current.client.images += I

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				if(rev.current.client)
					for(var/datum/mind/head_rev in head_revolutionaries)
						if(head_rev.current)
							var/imageloc = head_rev.current
							if(istype(head_rev.current.loc,/obj/mecha))
								imageloc = head_rev.current.loc
							var/image/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev_head")
							I.plane = REV_ANTAG_HUD_PLANE
							rev.current.client.images += I
					for(var/datum/mind/rev_1 in revolutionaries)
						if(rev_1.current)
							var/imageloc = rev_1.current
							if(istype(rev_1.current.loc,/obj/mecha))
								imageloc = rev_1.current.loc
							var/image/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev")
							I.plane = REV_ANTAG_HUD_PLANE
							rev.current.client.images += I

////////////////////////////////////////////////////
//Keeps track of converted revs icons///////////////
//Refer to above bugs. They may apply here as well//
////////////////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					var/imageloc = rev_mind.current
					if(istype(rev_mind.current.loc,/obj/mecha))
						imageloc = rev_mind.current.loc
					var/image/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev")
					I.plane = REV_ANTAG_HUD_PLANE
					head_rev_mind.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/imageloc = head_rev_mind.current
					if(istype(head_rev_mind.current.loc,/obj/mecha))
						imageloc = head_rev_mind.current.loc
					var/image/J = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev_head")
					J.plane = REV_ANTAG_HUD_PLANE
					rev_mind.current.client.images += J

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					var/imageloc = rev_mind.current
					if(istype(rev_mind.current.loc,/obj/mecha))
						imageloc = rev_mind.current.loc
					var/image/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev")
					I.plane = REV_ANTAG_HUD_PLANE
					rev_mind_1.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/imageloc = rev_mind_1.current
					if(istype(rev_mind_1.current.loc,/obj/mecha))
						imageloc = rev_mind_1.current.loc
					var/image/J = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev")
					J.plane = REV_ANTAG_HUD_PLANE
					rev_mind.current.client.images += J

///////////////////////////////////
//Keeps track of deconverted revs//
///////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && ((I.loc == rev_mind.current) || (I.loc == rev_mind.current.loc)))
							//del(I)
							head_rev_mind.current.client.images -= I

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					for(var/image/I in rev_mind_1.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && ((I.loc == rev_mind.current) || (I.loc == rev_mind.current.loc)))
							//del(I)
							rev_mind_1.current.client.images -= I

		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						//del(I)
						rev_mind.current.client.images -= I

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2) && T && (T.z == 1))
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - heads killed")
		completion_text = "<br><span class='danger'><FONT size = 3> The heads of staff were killed or abandoned the station! The revolutionaries win!</FONT></span>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		completion_text = "<br><span class='danger'><FONT size = 3> The heads of staff managed to stop the revolution!</FONT></span>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()
	var/text = ""
	if(head_revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/icon/logo1 = icon('icons/mob/mob.dmi', "rev_head-logo")
		end_icons += logo1
		var/tempstate = end_icons.len
		text += {"<img src="logo_[tempstate].png"> <FONT size = 2><B>The head revolutionaries were:</B></FONT> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/headrev in head_revolutionaries)
			if(headrev.current)
				var/icon/flat = getFlatIcon(headrev.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				if(headrev.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(headrev.current.z != 1)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as [headrev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				text += "body destroyed"
			text += ")"
			if(headrev.total_TC)
				if(headrev.spent_TC)
					text += "<br><span class='sinister'>TC Remaining: [headrev.total_TC - headrev.spent_TC]/[headrev.total_TC] - The tools used by the Head Revolutionary were:"
					for(var/entry in headrev.uplink_items_bought)
						text += "<br>[entry]"
					text += "</span>"
				else
					text += "<br><span class='sinister'>The Head Revolutionary was a smooth operator this round (did not purchase any uplink items)</span>"

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target


	if(revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/icon/logo2 = icon('icons/mob/mob.dmi', "rev-logo")
		end_icons += logo2
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The revolutionaries were:</B></FONT> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				var/icon/flat = getFlatIcon(rev.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				if(rev.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(rev.current.z != 1)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(rev.current.real_name != rev.name)
					text += " as [rev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				text += "body destroyed"
			text += ")"



	if( head_revolutionaries.len || revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution) )
		var/icon/logo3 = icon('icons/mob/mob.dmi', "nano-logo")
		end_icons += logo3
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The heads of staff were:</B></FONT> <img src="logo_[tempstate].png">"}

		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<font color='red'>"
			if(head.current)
				var/icon/flat = getFlatIcon(head.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[head.key]</b> was <b>[head.name]</b> ("}
				if(head.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(head.current.z != 1)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(head.current.real_name != head.name)
					text += " as [head.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[head.key]</b> was <b>[head.name]</b> ("}
				text += "body destroyed"
			text += ")"
			if(target)
				text += "</font>"

		text += "<BR><HR>"
	return text

/proc/is_convertable_to_rev(datum/mind/mind)
	return istype(mind) && \
		istype(mind.current, /mob/living/carbon/human) && \
		!(mind.assigned_role in command_positions) && \
		!(mind.assigned_role in list("Security Officer", "Detective", "Warden"))
