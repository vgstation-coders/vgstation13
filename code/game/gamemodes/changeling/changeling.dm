var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 1
	required_players_secret = 20
	required_enemies = 1
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/changeling_amount = 4

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>The current game mode is - Changeling!</B>")
	to_chat(world, "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>")

/datum/game_mode/changeling/pre_setup()
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	for(var/datum/mind/player in possible_changelings)
		if(mixed && (player in ticker.mode.modePlayer))
			possible_changelings -= player
			continue
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	changeling_amount = 1 + round(num_players() / 10)

// mixed mode scaling
	if(mixed)
		changeling_amount = min(2, changeling_amount)

	if(possible_changelings.len>0)
		for(var/i = 0, i < changeling_amount, i++)
			if(!possible_changelings.len) break
			var/datum/mind/changeling = pick(possible_changelings)
			possible_changelings -= changeling
			if(changeling.special_role)
				continue
			changelings += changeling
			modePlayer += changelings
		log_admin("Starting a round of changeling with [changelings.len] changelings.")
		message_admins("Starting a round of changeling with [changelings.len] changelings.")
		if(mixed)
			ticker.mode.modePlayer += changelings //merge into master antag list
			ticker.mode.changelings += changelings
		return 1
	else
		log_admin("Failed to set-up a round of changeling. Couldn't find any volunteers to be changeling.")
		message_admins("Failed to set-up a round of changeling. Couldn't find any volunteers to be changeling.")
		if(mixed)
			ticker.mode.modePlayer -= changelings //merge into master antag list
			ticker.mode.traitors -= changelings
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	if(!mixed)
		spawn (rand(waittime_l, waittime_h))
			if(!mixed) send_intercept()
		..()
	return


/datum/game_mode/proc/forge_changeling_objectives(var/datum/mind/changeling)
	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 3)
	changeling.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = changeling
	kill_objective.find_target()
	changeling.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective


	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/game_mode/proc/greet_changeling(var/datum/mind/changeling, var/you_are=1)
	if (you_are)
		to_chat(changeling.current, "<span class='danger'>You are a changeling!</span>")
	to_chat(changeling.current, "<span class='danger'>Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</span>")
	to_chat(changeling.current, "<B>You must complete the following tasks:</B>")

	if (changeling.current.mind)
		if (changeling.current.mind.assigned_role == "Clown")
			to_chat(changeling.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
			changeling.current.mutations.Remove(M_CLUMSY)

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		to_chat(changeling.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/changeling_mob)
	if(!istype(changeling_mob))	return
	changeling_mob.make_changeling()

/datum/game_mode/proc/auto_declare_completion_changeling()
	var/text = ""
	if(changelings.len)
		var/icon/logoa = icon('icons/mob/mob.dmi', "change-logoa")
		var/icon/logob = icon('icons/mob/mob.dmi', "change-logob")
		end_icons += logoa
		var/tempstatea = end_icons.len
		end_icons += logob
		var/tempstateb = end_icons.len
		text += {"<BR><img src="logo_[tempstatea].png"> <FONT size = 2><B>The changelings were:</B></FONT> <img src="logo_[tempstateb].png">"}
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = 1

			if(changeling.current)
				var/icon/flat = getFlatIcon(changeling.current, SOUTH, 1, 1)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[changeling.key]</b> was <b>[changeling.name]</b> ("}
				if(changeling.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(changeling.current.real_name != changeling.name)
					text += " as [changeling.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[changeling.key]</b> was <b>[changeling.name]</b> ("}
				text += "body destroyed"
				changelingwin = 0
			text += ")"

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.

			text += {"<br><b>Changeling ID:</b> [changeling.changeling.changelingID].
<b>Genomes Absorbed:</b> [changeling.changeling.absorbedcount]"}
			if(changeling.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in changeling.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("changeling_objective","[objective.type]|FAIL")
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><B>The changeling was successful!</B></font>"
				feedback_add_details("changeling_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The changeling has failed.</B></font>"
				feedback_add_details("changeling_success","FAIL")

			if(changeling.total_TC)
				if(changeling.spent_TC)
					text += "<br><span class='sinister'>TC Remaining: [changeling.total_TC - changeling.spent_TC]/[changeling.total_TC] - The tools used by the Changeling were: "
					for(var/entry in changeling.uplink_items_bought)
						text += "<br>[entry]"
				else
					text += "<br><span class='sinister'>The Changeling was a smooth operator this round (did not purchase any uplink items)</span>"
		text += "<BR><HR>"
	return text

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/purchasedpowers = list()
	var/mimicing = ""

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/changeling/proc/regenerate()
	chem_charges = Clamp(chem_charges + chem_recharge_rate, 0, chem_storage)
	geneticdamage = max(0, geneticdamage-1)

/datum/changeling/proc/GetDNA(var/dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna

/datum/mind/proc/make_new_changeling(var/show_message = 1, var/generate_objectives = 1)
	if(!ischangeling(current))
		ticker.mode.changelings += src
		ticker.mode.grant_changeling_powers(current)
		special_role = "Changeling"
		if(show_message)
			to_chat(current, "<B><font color='red'>Your powers are awoken. A flash of memory returns to us...we are a changeling!</font></B>")
			var/wikiroute = role_wiki[ROLE_CHANGELING]
			to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
		if(generate_objectives)
			ticker.mode.forge_changeling_objectives(src)
		return 1
	return 0

/datum/mind/proc/remove_changeling_status(var/show_message = 1)
	if(ischangeling(current))
		ticker.mode.changelings -= src
		special_role = null
		current.remove_changeling_powers()
		current.verbs -= /datum/changeling/proc/EvolutionMenu
		if(changeling)
			qdel(changeling)
			changeling = null
		if(show_message)
			to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")
		return 1
	return 0