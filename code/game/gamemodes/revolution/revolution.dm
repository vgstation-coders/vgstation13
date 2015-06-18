// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/*
 * Welcome to the New Revolution gamemode. Basically, shit changed for the better
 * Revolution used to be about flashing a few people and then Team Deathmach between Security and the Heads and the entire crew
 * Now it's a bit more tactical. Notably, being caught converting people will get you fucked over very quickly
 * No more flash flash flash at the start of the round and three of the five heads dead within ten minutes
 * Instead, all of the Revolution now comes in implant form. This includes new detection methods and counters, and makes conversion harder
 * Head Revs still have their flash, but flashes don't shut people up, so be careful
 */

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg", "Mobile MMI", "Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent", "Chaplain")
	required_players = 4
	required_players_secret = 25
	required_enemies = 3
	recommended_enemies = 3

	uplink_welcome = "Revolutionary Uplink Console:"
	uplink_uses = 10

	var/finished = 0
	var/checkwin_counter = 0
	var/max_headrevs = 3
	var/const/waittime_l = 600 //Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper bound on time before intercept arrives (in tenths of seconds)

///////////////////////////
//Announces the game type//
///////////////////////////

/datum/game_mode/revolution/announce()
	world << "<B>The current game mode is - Revolution!</B>"
	world << "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>"


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
			head_check = 1
			break

	for(var/datum/mind/player in possible_headrevs)
		for(var/job in restricted_jobs) //Removing heads and such from the list
			if(player.assigned_role == job)
				possible_headrevs -= player

	for(var/i = 1 to max_headrevs)
		if(possible_headrevs.len == 0)
			break
		var/datum/mind/lenin = pick(possible_headrevs)
		possible_headrevs -= lenin
		head_revolutionaries += lenin

	if((head_revolutionaries.len == 0) || (!head_check))
		return 0

	return 1

/datum/game_mode/revolution/post_setup()

	//Begin setting up the initial rev heads
	for(var/datum/mind/rev_mind in head_revolutionaries)
		forge_revolutionary_objectives(rev_mind) //Give them their objectives
		equip_revolutionary(rev_mind.current) //Give them their equipment
		update_rev_icons_added(rev_mind) //Give them their icons
		greet_revolutionary(rev_mind) //Give them directions

	modePlayer += head_revolutionaries //Put that in our magic ledger and let's go

	spawn(rand(waittime_l, waittime_h))
		send_intercept()
	..()

//We check victory every five ticks, because it's expensive, I suppose ?
/datum/game_mode/revolution/process()

	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

//Alright boys let's create those objectives
/datum/game_mode/proc/forge_revolutionary_objectives(var/datum/mind/rev_mind)

	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

//Tell them what the fuck is going on, we want to give thorough explanation without flooding them. The wiki exists
/datum/game_mode/proc/greet_revolutionary(var/datum/mind/rev_mind)

	var/obj_count = 1
	rev_mind.current << "<span class='danger'>Welcome to the Revolution, you are now part of its leadership!</span>"
	rev_mind.current << "<span class='warning'>You are part of a small Revolutionary cell implanted aboard [station_name].</span>"
	rev_mind.current << "<span class='warning'>Your special implant allows you to recognize all Revolutionaries, unlike standard implants. For safety reasons, your implant will kill you if it is extracted!</span>"
	for(var/datum/objective/objective in rev_mind.objectives) //Dump objectives at the end
		rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		rev_mind.special_role = "Head Revolutionary"
		obj_count++
	rev_mind.current << "<span class='danger'>Your cell is still small. Remember to stay undercover. Good luck.</span>"

/////////////////////////////////////////////////////////////////////////////
//This equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)

	if(!istype(mob))
		return

	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.mutations.Remove(M_CLUMSY)

	mob.equip_to_slot_or_del(new /obj/item/device/flash(mob), slot_in_backpack)
	mob.equip_to_slot_or_del(new /obj/item/weapon/storage/lockbox/revolution(mob), slot_in_backpack)
	mob.equip_to_slot_or_del(new /obj/item/weapon/implanter(mob), slot_in_backpack)
	var/obj/item/weapon/implant/revolution/head/revhead = new/obj/item/weapon/implant/revolution/head(mob)
	revhead.imp_in = mob
	revhead.implanted = 1
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
	else if(emergency_shuttle.location == 2)
		finished = 3
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////

/datum/game_mode/revolution/check_finished()

	if(finished)
		return 1
	else
		return 0

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////

//The special returns are now useless since implants check for all of those first. Still keeping them for legacy
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)

	if(rev_mind.assigned_role in restricted_jobs) //Some crewmen are beyond brainwashing (Read : Command, Security, the Chaplain)
		return -1

	var/mob/living/carbon/human/H = rev_mind.current

	if(jobban_isbanned(H, "revolutionary")) //Was an assburger as a Revolutionary before, so he can fuck right off
		return -2

	for(var/obj/item/weapon/implant/loyalty/L in H) //Loyalty implanted. Beyond brainwashed
		if(L.imp_in == H) //Make sure the loyalty implant is actually implanted, because HONK
			return -3

	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries)) //Already a Rev, you idiot
		return -4

	revolutionaries += rev_mind
	rev_mind.current << "<span class='danger'>Your feeble loyalty to Nanotrasen has been subverted. You are now part of the Revolution! Your implant only allows you to recognize the heads of the Revolution, so be careful and start taking orders.</span>"
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)

	log_admin("[rev_mind.current] ([ckey(rev_mind.current.key)] has been converted to the revolution")

	return 1

//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind, beingborged)

	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null

		if(beingborged)
			rev_mind.current.visible_message("<span class='notice'>The frame hums while it purges the hostile neural reprogramming from [rev_mind.current]'s brain.</span>", \
			"<span class='danger'>The frame's firmware detects and deletes your neural reprogramming in an uncomfortable hum!  You remember nothing from the moment you were brainwashed until now.</span>")

		else
			rev_mind.current.visible_message("<span class='notice'>[rev_mind.current] stares blankly, it looks like \he just remembered \his true allegiance!</span>", \
			"<span class='danger'>You suddenly come back to your senses, you are no longer a Revolutionary! Your memory is still hazy, the only thing you remember is what happened before you were brainwashed.</span>")

		update_rev_icons_removed(rev_mind)

		log_admin("[rev_mind.current] ([ckey(rev_mind.current.key)] has been deconverted from the revolution")


///////////////////////////////////////////////////
//Keeps track of players having the correct icons//
///////////////////////////////////////////////////

/*
 * Important note : Gameplay change ahoy
 * Head Revs recognize other Head Revs and Revs, but Revs only recognize Head Revs
 * Since only Head Revs convert people (in theory), this won't cause convertion problems, but it forces Revs to actually fucking ORGANIZE
 * No more Rev bubble tides. If you can't get a Head Rev to tell who is really a Rev and who is shitting you, you'll have a bad time
 */

/datum/game_mode/proc/update_all_rev_icons()

	for(var/datum/mind/head_rev_mind in head_revolutionaries)
		if(head_rev_mind.current)
			if(head_rev_mind.current.client)
				for(var/image/I in head_rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						head_rev_mind.current.client.images -= I

	for(var/datum/mind/rev_mind in revolutionaries)
		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						rev_mind.current.client.images -= I

	for(var/datum/mind/head_rev in head_revolutionaries)
		if(head_rev.current)
			if(head_rev.current.client)
				for(var/datum/mind/rev in revolutionaries)
					if(rev.current)
						var/I = image('icons/mob/mob.dmi', loc = rev.current, icon_state = "rev")
						head_rev.current.client.images += I
				for(var/datum/mind/head_rev_1 in head_revolutionaries)
					if(head_rev_1.current)
						var/I = image('icons/mob/mob.dmi', loc = head_rev_1.current, icon_state = "rev_head")
						head_rev.current.client.images += I

	for(var/datum/mind/rev in revolutionaries)
		if(rev.current)
			if(rev.current.client)
				for(var/datum/mind/head_rev in head_revolutionaries)
					if(head_rev.current)
						var/I = image('icons/mob/mob.dmi', loc = head_rev.current, icon_state = "rev_head")
						rev.current.client.images += I
				//We're not telling Revs who other Revs are, but to avoid an existential crisis we need to tell the Rev he is one
				var/I = image('icons/mob/mob.dmi', loc = rev.current, icon_state = "rev")
				rev.current.client.images += I
				/*
				 * See notes above
				for(var/datum/mind/rev_1 in revolutionaries)
					if(rev_1.current)
						var/I = image('icons/mob/mob.dmi', loc = rev_1.current, icon_state = "rev")
						rev.current.client.images += I
				 */

///////////////////////////////////////
//Keeps track of converted revs icons//
///////////////////////////////////////

/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)

	for(var/datum/mind/head_rev_mind in head_revolutionaries)
		if(head_rev_mind.current)
			if(head_rev_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev_head")
				head_rev_mind.current.client.images += I
		if(rev_mind.current)
			if(rev_mind.current.client)
				var/image/J = image('icons/mob/mob.dmi', loc = head_rev_mind.current, icon_state = "rev_head")
				rev_mind.current.client.images += J

	//We're not telling Revs who other Revs are, but to avoid an existential crisis we need to tell the Rev he is one
	if(rev_mind in head_revolutionaries)
		var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev_head")
		rev_mind.current.client.images += I
	else
		var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
		rev_mind.current.client.images += I

	/*
	 * Normal Revs don't get to see new converts, period. See notes above
	for(var/datum/mind/rev_mind_1 in revolutionaries)
		if(rev_mind_1.current)
			if(rev_mind_1.current.client)
				var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
				rev_mind_1.current.client.images += I
		if(rev_mind.current)
			if(rev_mind.current.client)
				var/image/J = image('icons/mob/mob.dmi', loc = rev_mind_1.current, icon_state = "rev")
				rev_mind.current.client.images += J
	 */

///////////////////////////////////
//Keeps track of deconverted revs//
///////////////////////////////////

/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)

	for(var/datum/mind/head_rev_mind in head_revolutionaries)
		if(head_rev_mind.current)
			if(head_rev_mind.current.client)
				for(var/image/I in head_rev_mind.current.client.images)
					if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
						head_rev_mind.current.client.images -= I

	for(var/datum/mind/rev_mind_1 in revolutionaries)
		if(rev_mind_1.current)
			if(rev_mind_1.current.client)
				for(var/image/I in rev_mind_1.current.client.images)
					if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
						rev_mind_1.current.client.images -= I

	if(rev_mind.current)
		if(rev_mind.current.client)
			for(var/image/I in rev_mind.current.client.images)
				if(I.icon_state == "rev" || I.icon_state == "rev_head")
					rev_mind.current.client.images -= I

//////////////////////////////////
//Checks for Revoulution victory//
//////////////////////////////////

/datum/game_mode/revolution/proc/check_rev_victory()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0
		return 1

/////////////////////////////
//Checks for a Head victory//
/////////////////////////////

/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2))
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevent information stated//
//////////////////////////////////////////////////////////////////////

/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","Revolution Major Victory - Objectives Completed")
		completion_text = "<br><span class='danger'>The Revolution has completed all of its objectives! [station_name] has been liberated by their freedom fighters!</span>"
	else if(finished == 2)
		feedback_set_details("round_end_result","Crew Major Victory - Revolution Cell Busted")
		completion_text = "<br><span class='danger'>The Heads of Staff managed to stop the Revolution! [station_name] will not fall to these terrorists!</span>"
	else if(finished == 3)
		feedback_set_details("round_end_result","Crew Minor Victory - Station Evacuated")
		completion_text = "<br><span class='danger'>The station has been evacuated. Nanotrasen will protect the loyal crew, and court-martial the terrorists!</span>"
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
					text += "survived the Revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as [headrev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				text += "body destroyed"
			text += ")"

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
					text += "survived the Revolution"
				if(rev.current.real_name != rev.name)
					text += " as [rev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				text += "body destroyed"
			text += ")"

	if(head_revolutionaries.len || revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
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
					text += "survived the Revolution"
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
		!(mind.assigned_role in list("Security Officer", "Detective", "Warden", "Internal Affairs Agent", "Chaplain"))

//////////////////////////
//The Revolution Implant//
//////////////////////////

/*
 * Replaces magic flash conversions. When implanted into someone, it turns them into a Revolutionary
 * If it is removed from them or a loyalty implant is added, it neutralizes their brainwashing
 * Being hit in the head carries a significant risk of breaking the implant's complex neural link
 * Other things that can fuck up implants like EMP blasts also count
 */

/obj/item/weapon/implant/revolution
	name = "revolutionary implant"
	desc = "A brainwashing implant. Highly dangerous."
	icon_state = "implant_evil"

/obj/item/weapon/implant/revolution/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
<b>Name:</b> CCCP-78-REVCELL Brainwashing Implant<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> Presence of implant causes brainwashing. Loyalty implants and resilience neutralizes the brainwashing. Removing the implant stops it.<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Sends dangerous neural feedback leading to a surge of anarcho-communist sentiments.<BR>
<b>Special Features:</b> Complex neural feedback<BR>
<b>Integrity:</b> Electromagnetic pulses will likely lead to an implant meltdown."}
	return dat

/obj/item/weapon/implant/revolution/implanted(mob/M)

	if(!istype(M, /mob/living/carbon/human))
		return 0
	var/mob/living/carbon/human/H = M

	//Dead, cata or fucked in some other way
	if(!H.mind || !H.client || H.stat == 2)
		H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>")
		return 0

	//Dumb fuck implanting someone who already has a Revolution implant (implant can be neutralized by loyalty)
	for(var/obj/item/weapon/implant/revolution/R in H)
		if(R.imp_in == H) //Make sure the revolution implant is actually implanted, because HONK
			H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", \
			"<span class='warning'>Your revolutionary implant blocks the new revolutionary implant from installing itself in your cranium!</span>")
			return 0

	//Ditto above with Head Revolution implant
	for(var/obj/item/weapon/implant/revolution/head/Q in H)
		if(Q.imp_in == H) //Make sure the revolution implant is actually implanted, because HONK
			H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", \
			"<span class='warning'>Your revolutionary implant blocks the new revolutionary implant from installing itself in your cranium!</span>")
			return 0

	//Mob has a Loyalty implant. Loyalty implants make a crewman uncorruptible, full stop
	for(var/obj/item/weapon/implant/loyalty/L in H)
		if(L.imp_in == H) //Make sure the loyalty implant is actually implanted, because HONK
			H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", \
			"<span class='warning'>Your loyalty implant detects the corrupted implant and prompty blocks it from installing itself in your cranium!</span>")
			return 0

	//Mob cannot be corrupted anyhow
	if(H.mind.assigned_role in command_positions || H.mind.assigned_role in list("Security Officer", "Detective", "Warden", "Internal Affairs Agent", "Chaplain"))
		H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", \
		"<span class='warning'>Your mind manages to ward off the revolutionary implant's corrupting influence!</span>")
		return 0

	if(jobban_isbanned(H, "revolutionary")) //Was an assburger as a Revolutionary before, so he can fuck right off
		H.visible_message("<span class='danger'>As it enters [H]'s cranium, the implant suddenly beeps!</span>", \
		"<span class='danger'>Your mind seems to have triggered some sort of self-defense mechanism in the implant's code. OH SHIT!</span>")
		H.gib()

	ticker.mode:add_revolutionary(H.mind) //All checks are done, implant them and give them Revolution status
	return 1

/obj/item/weapon/implant/revolution/emp_act(severity)

	switch(severity)
		if(1)
			if(prob(80))
				meltdown()
		if(2)
			if(prob(15))
				meltdown()

/obj/item/weapon/implant/revolution/meltdown()

	..()

	var/mob/living/carbon/human/H = imp_in
	ticker.mode:remove_revolutionary(H.mind)

/obj/item/weapon/implant/revolution/Destroy()

	var/mob/living/carbon/human/H = imp_in
	ticker.mode:remove_revolutionary(H.mind)

	..()

//The more evil version. Destruction does not lead to deconversion, but instead to very horrible things
/obj/item/weapon/implant/revolution/head
	name = "head revolutionary implant"


/obj/item/weapon/implant/revolution/head/meltdown()

	..()

	if(imp_in)
		var/mob/living/carbon/human/H = imp_in
		H.gib()

/obj/item/weapon/implant/revolution/head/Destroy()

	if(imp_in)
		var/mob/living/carbon/human/H = imp_in
		H.gib()

	..()

/obj/item/weapon/implantcase/revolution
	name = "Glass Case - 'Revolution'"
	desc = "A case containing a revolution implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

	New()
		src.imp = new /obj/item/weapon/implant/revolution(src)
		..()
		return

//Not intended for gameplay use. Only use for adminbus or testing
/obj/item/weapon/implantcase/revolutionhead
	name = "Glass Case - 'Revolution Head'"
	desc = "A case containing a revolution head implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

	New()
		src.imp = new /obj/item/weapon/implant/revolution/head(src)
		..()
		return

/obj/item/weapon/storage/lockbox/revolution
	name = "Lockbox (Revolution Implants)"
	req_access = list()

/obj/item/weapon/storage/lockbox/revolution/New()
	..()
	new /obj/item/weapon/implantcase/revolution(src)
	new /obj/item/weapon/implantcase/revolution(src)
	new /obj/item/weapon/implantcase/revolution(src)
	new /obj/item/weapon/implantcase/revolution(src)
