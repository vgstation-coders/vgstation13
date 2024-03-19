var/list/forced_roundstart_ruleset = list()

// -- Distribution parameters chosen prior to roundstart --
var/dynamic_curve_centre = 0 // 0 for LORENTZ 1 for EXPONENTIAL
var/dynamic_curve_width = 1.8
var/dynamic_chosen_mode = LORENTZ

// -- Dynamic tweaks chosen prior to roundstart --
var/dynamic_no_stacking = 1 // NO STACKING : only one "round-ender", except if we're above 80 threat
var/dynamic_classic_secret = 0 // Only one roundstart ruleset, and only autotraitor + minor rules allowed
var/dynamic_high_pop_limit = 45 // Will switch to "high pop override" if the roundstart population is above this

var/stacking_limit = 90

#define BASE_SOLO_REFUND 10

/datum/gamemode/dynamic
	name = "Dynamic Mode"

	//Threat logging vars
	var/threat_level = 0//the "threat cap", threat shouldn't normally go above this and is used in ruleset calculations
	var/starting_threat = 0 //threat_level's initially rolled value. Threat_level isn't changed by many things.
	var/threat = 0//set at the beginning of the round. Spent by the mode to "purchase"  roundstart rules.
	var/list/threat_log = list() //Running information about the threat. Can store text or datum entries.

	// Midround threat
	var/midround_threat_level = 0
	var/midround_starting_threat = 0
	var/midround_threat = 0
	var/list/midround_threat_log = list()

	var/list/roundstart_rules = list()
	var/list/latejoin_rules = list()
	var/list/midround_rules = list()
	var/list/second_rule_req = list(100,100,100,80,60,40,20,0,0,0)//requirements for extra round start rules
	var/list/third_rule_req = list(100,100,100,100,100,70,50,30,10,0)
	var/roundstart_pop_ready = 0
	var/list/candidates = list()
	var/list/current_rules = list()
	var/list/executed_rules = list()
	var/list/previously_executed_rules = list()
	var/list/rules_text = list()

	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()
	var/last_time_of_population = 0

	var/latejoin_injection_cooldown = 0
	var/midround_injection_cooldown = 0

	var/datum/dynamic_ruleset/latejoin/forced_latejoin_rule = null

	var/datum/stat/dynamic_mode/dynamic_stats = null
	var/pop_last_updated = 0

	var/distribution_mode = LORENTZ
	var/relative_threat = 0 // Relative threat, Lorentz-distributed.
	var/curve_centre_of_round = 0
	var/curve_width_of_round = 1.8

	var/peaceful_percentage = 50
	var/highlander_rulesets_favoured = 0

	// -- Special tweaks --
	var/no_stacking = 1
	var/classic_secret = 0
	var/high_pop_limit = 45

	var/list/ruleset_category_weights = list()
	var/dynamic_weight_increment = 1


/datum/gamemode/dynamic/AdminPanelEntry()
	var/dat = list()
	dat += "Dynamic Mode <a href='?_src_=vars;Vars=\ref[src]'>\[VV\]</A><BR>"
	dat += "Threat Level: <b>[threat_level]</b>, in-round injection threat level: <b>[midround_threat_level]</b><br/>"
	dat += "Threat to Spend: <b>[midround_threat]</b> <a href='?_src_=holder;adjustthreat=1'>\[Adjust\]</A> <a href='?_src_=holder;threatlog=1'>\[View Log\]</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [curve_centre_of_round] ; width = [curve_width_of_round].<br/>"
	dat += "<i>On average, <b>[peaceful_percentage]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "No stacking (only one round-ender): <a href='?src=\ref[src];no_stacking=1'><b>[no_stacking ? "On" : "Off"]</b></a><br/>"
	dat += "Classic secret (only autotraitor): <a href='?src=\ref[src];classic_secret=1'><b>[classic_secret ? "On" : "Off"]</b></a><br/>"
	dat += "Stacking limit: <a href='?src=\ref[usr.client.holder];stacking_limit=1'>[stacking_limit]</a>"
	dat += "<br/>"
	dat += "Executed rulesets: "
	if (executed_rules.len > 0)
		dat += "<br/>"
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			var/ruletype = ""
			if (istype (DR, /datum/dynamic_ruleset/roundstart))
				ruletype = "Roundstart"
			if (istype (DR, /datum/dynamic_ruleset/latejoin))
				ruletype = "Latejoin"
			if (istype (DR, /datum/dynamic_ruleset/midround))
				ruletype = "Midround"
			dat += "[ruletype] - <b>[DR.name]</b><br>"
	else
		dat += "none.<br>"
	dat += "<br>Injection Timers: (<b>[GetInjectionChance()]%</b> chance)<BR>"
	dat += "Latejoin: [latejoin_injection_cooldown>60 ? "[round(latejoin_injection_cooldown/60,0.1)] minutes" : "[latejoin_injection_cooldown] seconds"] <a href='?_src_=holder;injectnow=1'>\[Now!\]</A><BR>"
	dat += "Midround: [midround_injection_cooldown>60 ? "[round(midround_injection_cooldown/60,0.1)] minutes" : "[midround_injection_cooldown] seconds"] <a href='?_src_=holder;injectnow=2'>\[Now!\]</A><BR>"
	return jointext(dat, "")

/datum/gamemode/dynamic/Topic(href, href_list)
	if (..()) // Sanity, maybe ?
		return
	if(!usr || !usr.client)
		return
	if(href_list["threatlog"]) //don't need admin for this
		show_threatlog(usr)
		return
	if(!usr.check_rights(R_ADMIN))
		return
	else if (href_list["no_stacking"])
		no_stacking =! no_stacking
		message_admins("[key_name(usr)] has set 'no stacking' to [no_stacking].")
	else if (href_list["classic_secret"])
		classic_secret =! classic_secret
		message_admins("[key_name(usr)] has set 'classic secret' to [classic_secret].")

	usr.client.holder.check_antagonists() // Refreshes the window

/datum/gamemode/dynamic/proc/show_threatlog(mob/admin)
	if(!ticker || !ticker.mode)
		alert("Ticker and Game Mode aren't initialized yet!", "Alert")
		return

	if(!admin.check_rights(R_ADMIN) && (ticker.current_state != GAME_STATE_FINISHED))
		return

	var/out = "<TITLE>Threat Log</TITLE><B><font size='3'>Threat Log</font></B><br><B>Starting Threat:</B> [starting_threat], <b>midround</b>: [midround_starting_threat]<BR>"

	for(var/entry in threat_log)
		if(istext(entry))
			out += "[entry]<BR>"
		if(istype(entry,/datum/role/catbeast))
			var/datum/role/catbeast/C = entry
			out += "Catbeast threat regenerated/threat_level inflated: [C.threat_generated]/[C.threat_level_inflated]<BR>"

	out += "<B>Remaining threat/threat_level:</B> [threat]/[threat_level]<br/>"
	out += "<B>Remaining midround threat/threat_level:</B> [midround_threat]/[midround_threat_level]"

	usr << browse(out, "window=threatlog;size=700x500")

/datum/gamemode/dynamic/GetScoreboard()

	dat += "<h2>Dynamic Mode - Roundstart Threat = <font color='red'>[threat_level]%</font>, Midround Threat = <font color='red'>[midround_threat_level]%</font></h2>"
	if (executed_rules.len > 0)
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			var/ruletype = ""
			if (istype (DR, /datum/dynamic_ruleset/roundstart))
				ruletype = "roundstart"
			if (istype (DR, /datum/dynamic_ruleset/latejoin))
				ruletype = "latejoin"
			if (istype (DR, /datum/dynamic_ruleset/midround))
				ruletype = "midround"
			dat += "([ruletype]) - <b>[DR.name]</b>[DR.calledBy ? " (called by [DR.calledBy])" : ""]<br>"
			rules_text += "[ruletype] - **[DR.name]** [DR.calledBy ? " (called by [DR.calledBy])" : ""]"
		dat += "<a href='?src=\ref[src];threatlog=1'>\[View Log\]</a>"
	else
		dat += "(extended)"
		rules_text += "None"
	dat += "<HR>"
	. = ..()

/datum/gamemode/dynamic/send2servers()
	send2mainirc("A round of [name] has ended - [living_players.len] survivors, [dead_players.len] ghosts. Final crew score: [score.crewscore]. ([score.rating])")
	send2maindiscord("A round of **[name]** has ended - **[living_players.len]** survivors, **[dead_players.len]** ghosts. Final crew score: **[score.crewscore]**. ([score.rating])")
	send2mainirc("Dynamic mode Roundstart Threat: [starting_threat][(starting_threat!=threat_level)?" ([threat_level])":""], Midround Threat: [midround_starting_threat][(midround_starting_threat!=midround_threat_level)?" ([midround_threat_level])":""], rulesets: [jointext(rules_text, ", ")].")
	send2maindiscord("Dynamic mode Roundstart Threat: **[starting_threat][(starting_threat!=threat_level)?" ([threat_level])":""]**, Midround Threat: **[midround_starting_threat][(midround_starting_threat!=midround_threat_level)?" ([midround_threat_level])":""]**, rulesets: [jointext(rules_text, ", ")]")

/datum/gamemode/dynamic/can_start()
	read_previous_dynamic_rounds()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart) - /datum/dynamic_ruleset/roundstart/delayed/)
		roundstart_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/latejoin))
		latejoin_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/midround))
		var/datum/dynamic_ruleset/midround/DR = rule
		if (initial(DR.weight))
			midround_rules += new rule()
	for(var/mob/new_player/player in player_list)
		if(player.mind && player.ready)
			roundstart_pop_ready++
			candidates.Add(player)

	message_admins("DYNAMIC MODE: Listing [roundstart_rules.len] round start rulesets, and [roundstart_pop_ready] players ready.")
	log_admin("DYNAMIC MODE: Listing [roundstart_rules.len] round start rulesets, and [roundstart_pop_ready] players ready.")

	distribution_mode = dynamic_chosen_mode
	message_admins("Distribution mode is : [dynamic_chosen_mode].")
	curve_centre_of_round = dynamic_curve_centre
	curve_width_of_round = dynamic_curve_width
	message_admins("Curve centre and curve width are : [curve_centre_of_round], [curve_width_of_round]")
	if (admin_disable_rulesets)
		message_admins("Rulesets are currently disabled.")
	no_stacking = dynamic_no_stacking
	if (no_stacking)
		message_admins("Round-ending rulesets won't stack, unless the threat is above stacking_limit ([stacking_limit]).")
	classic_secret = dynamic_classic_secret
	if (classic_secret)
		message_admins("Classic secret mode active: only autotraitors will spawn, and we will only have one roundstart ruleset.")
	log_admin("Dynamic mode parameters for the round: distrib mode = [distribution_mode], centre = [curve_centre_of_round], width is [curve_width_of_round]. Rulesets Disabled : [admin_disable_rulesets], no stacking : [no_stacking], classic secret: [classic_secret].")

	generate_threat()

	var/latejoin_injection_cooldown_middle = 0.5*(LATEJOIN_DELAY_MAX + LATEJOIN_DELAY_MIN)
	latejoin_injection_cooldown = round(clamp(exp_distribution(latejoin_injection_cooldown_middle), LATEJOIN_DELAY_MIN, LATEJOIN_DELAY_MAX))

	var/midround_injection_cooldown_middle = 0.5*(MIDROUND_DELAY_MAX + MIDROUND_DELAY_MIN)
	midround_injection_cooldown = round(clamp(exp_distribution(midround_injection_cooldown_middle), MIDROUND_DELAY_MIN, MIDROUND_DELAY_MAX))

	message_admins("Dynamic Mode initialized with a Threat Level of... <font size='8'>[threat_level]</font> and <font size='8'>[midround_threat_level]</font> for midround!")
	log_admin("Dynamic Mode initialized with a Threat Level of... [threat_level] and [midround_threat_level]</font> for midround!")

	message_admins("Parameters were: centre = [curve_centre_of_round], width = [curve_width_of_round].")
	log_admin("Parameters were: centre = [curve_centre_of_round], width = [curve_width_of_round].")

	dynamic_stats = new
	dynamic_stats.starting_threat_level = threat_level

	if (round(threat_level*10) == 666)
		forced_roundstart_ruleset += new /datum/dynamic_ruleset/roundstart/bloodcult()
		forced_roundstart_ruleset += new /datum/dynamic_ruleset/roundstart/vampire()
		log_admin("DYNAMIC MODE: 666 threat override.")
		message_admins("DYNAMIC MODE: 666 threat override.", 1)


	return 1

/datum/gamemode/dynamic/proc/read_previous_dynamic_rounds()
	//Recapping the rulesets of the last 3 rounds
	previously_executed_rules = list(
		"one_round_ago" = list(),
		"two_rounds_ago" = list(),
		"three_rounds_ago" = list()
	)
	var/list/data = SSpersistence_misc.read_data(/datum/persistence_task/latest_dynamic_rulesets)
	if(length(data))
		for (var/entries in data)
			var/previous_rulesets_text = data[entries]
			var/list/previous_rulesets = list()
			for(var/entry in previous_rulesets_text)
				var/entry_path = text2path(entry)
				if(entry_path) // It's possible that a ruleset that existed last round doesn't exist anymore
					previous_rulesets += entry_path
			previously_executed_rules[entries] = previous_rulesets

	//Recapping the weight of the various rulesets according to their categories
	ruleset_category_weights = list()
	data = SSpersistence_misc.read_data(/datum/persistence_task/dynamic_ruleset_weights)
	for (var/rule in subtypesof(/datum/dynamic_ruleset))//first we dress the list of all categories according to the rulesets that currently exist
		var/datum/dynamic_ruleset/ruletype = rule
		var/rulecategory = initial(ruletype.weight_category)
		if (rulecategory)
			ruleset_category_weights[rulecategory] = 0

	if(length(data))//then we update our categories with the weights as they were after last round
		for (var/entry in data)
			ruleset_category_weights[entry] = data[entry]

	for (var/entry in ruleset_category_weights)//finally we increment all entries in the list by 1
		ruleset_category_weights[entry] = ruleset_category_weights[entry] + dynamic_weight_increment

/datum/gamemode/dynamic/Setup()
	if (roundstart_pop_ready >= high_pop_limit)
		message_admins("DYNAMIC MODE: Mode: High Population Override is in effect! ([roundstart_pop_ready]/[high_pop_limit]) Threat Level will have more impact on which roles will appear, and player population less.")
		log_admin("DYNAMIC MODE: High Population Override is in effect! ([roundstart_pop_ready]/[high_pop_limit]) Threat Level will have more impact on which roles will appear, and player population less.")
	if (roundstart_pop_ready <= 0)
		message_admins("DYNAMIC MODE: Not a single player readied-up. The round will begin without any roles assigned.")
		log_admin("DYNAMIC MODE: Not a single player readied-up. The round will begin without any roles assigned.")
		return 1
	if (roundstart_rules.len <= 0)
		message_admins("DYNAMIC MODE: There are no roundstart rules within the code, what the fuck? The round will begin without any roles assigned.")
		log_admin("DYNAMIC MODE: There are no roundstart rules within the code, what the fuck? The round will begin without any roles assigned.")
		return 1
	if (forced_roundstart_ruleset.len > 0)
		rigged_roundstart()
	else
		roundstart()

	var/starting_rulesets = ""
	for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
		starting_rulesets += "[DR.name], "
	dynamic_stats.round_start_pop = roundstart_pop_ready
	dynamic_stats.round_start_rulesets = starting_rulesets
	dynamic_stats.measure_threat(threat)
	candidates.Cut()
	return 1

/datum/gamemode/dynamic/proc/rigged_roundstart()
	message_admins("DYNAMIC MODE: [forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	log_admin("DYNAMIC MODE: [forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	var/forced_rules = 0

	for (var/datum/forced_ruleset/forced_rule in forced_roundstart_ruleset)//By checking in this order we allow admins to set up priorities among the forced rulesets.
		for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
			if (forced_rule.name == rule.name)
				rule.candidates = candidates.Copy()
				rule.trim_candidates()
				if (rule.ready(TRUE))
					forced_rules++
					rule.calledBy = forced_rule.calledBy
					if (!rule.choose_candidates())
						stack_trace("rule [rule] failed to choose candidates despite ready() returning 1.")

					message_admins("DYNAMIC MODE: <font size='3'>[rule.name]</font> successfully forced!")
					log_admin("DYNAMIC MODE: <font size='3'>[rule.name]</font> successfully forced!")

					//we don't spend threat on forced rulesets
					threat_log += "[worldtime2text()]: Roundstart [rule.name] forced"

					if (istype(rule, /datum/dynamic_ruleset/roundstart/delayed/))
						var/datum/dynamic_ruleset/roundstart/delayed/delayed_ruleset = rule
						message_admins("DYNAMIC MODE: with a delay of [delayed_ruleset.delay/10] seconds.")
						log_admin("DYNAMIC MODE: with a delay of [delayed_ruleset.delay/10] seconds.")
						pick_delay(rule)

					if (rule.execute())//this should never fail since ready() returned 1
						rule.stillborn = IsRoundAboutToEnd()
						executed_rules += rule
						if (rule.persistent)
							current_rules += rule
						for(var/mob/M in rule.assigned)
							candidates -= M
					else
						message_admins("DYNAMIC MODE: ....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
						log_admin("DYNAMIC MODE: ....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")

	if (forced_rules == 0)
		message_admins("DYNAMIC MODE: Not a single forced ruleset could be executed. Sad! Will now start a regular round of dynamic.")
		log_admin("DYNAMIC MODE: Not a single forced ruleset could be executed. Sad! Will now start a regular round of dynamic.")
		roundstart()

/datum/gamemode/dynamic/proc/roundstart()
	if (admin_disable_rulesets)
		return 1

	var/indice_pop = min(10,round(roundstart_pop_ready/5)+1)
	var/extra_rulesets_amount = 0

	if (classic_secret) // Classic secret experience : one & only one roundstart ruleset
		extra_rulesets_amount = 0
	else
		if (roundstart_pop_ready > high_pop_limit)
			if (threat_level > 50)
				extra_rulesets_amount++
				if (threat_level > 75)
					extra_rulesets_amount++
		else
			if (threat_level >= second_rule_req[indice_pop])
				extra_rulesets_amount++
				if (threat_level >= third_rule_req[indice_pop])
					extra_rulesets_amount++

	if	(extra_rulesets_amount && prob(50))
		message_admins("DYNAMIC MODE: Rather than extra rulesets, we'll try to draft spicier ones.")
		log_admin("DYNAMIC MODE: Rather than extra rulesets, we'll try to draft spicier ones.")
		highlander_rulesets_favoured = TRUE
		extra_rulesets_amount = 0

	var/i = 0
	var/list/drafted_rules = list()

	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (rule.acceptable())	//if we got the population and threat required
			i++											//we check whether we've got eligible players
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready())
				drafted_rules[rule] = rule.get_weight()

	if (classic_secret)
		message_admins("DYNAMIC MODE: Classic secret was forced.")
		log_admin("DYNAMIC MODE: Classic secret was forced.")
	else
		message_admins("DYNAMIC MODE: [i] rulesets qualify for the current pop and threat level, including [drafted_rules.len] with eligible candidates.")
		log_admin("DYNAMIC MODE: [i] rulesets qualify for the current pop and threat level, including [drafted_rules.len] with eligible candidates.")

	var/list/datum/dynamic_ruleset/roundstart/candidate_rules = list()

	for (var/j = 1 to (1 + extra_rulesets_amount))
		// 1. Scrapping all the rules with cost above remaining threat level
		for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
			if (rule.cost > threat)
				drafted_rules -= rule

		// 2. No rules left? Abort.
		if (drafted_rules.len <= 0)
			break

		// 3. Picking up the CHOSEN ONE.
		var/datum/dynamic_ruleset/chosen_one = picking_roundstart_rule(drafted_rules, candidate_rules)

		// 4. Adding to the LIST.
		if (chosen_one)
			message_admins("DYNAMIC MODE: Picking a [istype(chosen_one, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[chosen_one.name]</font>!")
			log_admin("DYNAMIC MODE: Picking a [istype(chosen_one, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[chosen_one.name]</font>!")
			candidate_rules += chosen_one
			drafted_rules -= chosen_one
			spend_threat(chosen_one.cost)
			if(!chosen_one.choose_candidates())
				stack_trace("rule [chosen_one] failed to choose candidates despite ready() returning 1.")
			drafted_rules = trimming_remaining_rules(chosen_one, drafted_rules)

	// Is THE LIST non-empty ?
	if (candidate_rules.len > 0)
		for (var/datum/dynamic_ruleset/roundstart/DR in candidate_rules)
			executing_roundstart_rule(DR)
		return 1
	else
		message_admins("DYNAMIC MODE: The mode failed to pick a first ruleset. The round will begin without any roles assigned.")
		log_admin("DYNAMIC MODE: The mode failed to pick a first ruleset. The round will begin without any roles assigned.")
		return 0

// -- PICKING a rule, which means checking if you can do it.
// drafted_rules : the eligible rules for this round, after the threat cost of other rules has been taken into account and they have enough candidates
// returns : the chosen dynamic ruleset.
/datum/gamemode/dynamic/proc/picking_roundstart_rule(var/list/drafted_rules = list(), var/list/candidate_rules = list())
	var/datum/dynamic_ruleset/my_rule = null
	while(!my_rule && drafted_rules.len > 0)
		message_admins("DYNAMIC MODE: Drafted rules: [json_encode(drafted_rules)]")
		log_admin("DYNAMIC MODE: Drafted rules: [json_encode(drafted_rules)]")
		my_rule = pickweight(drafted_rules)
		if (threat < stacking_limit && no_stacking)
			for (var/datum/dynamic_ruleset/roundstart/DR in candidate_rules + executed_rules)
				if ((DR.flags & HIGHLANDER_RULESET) && (my_rule.flags & HIGHLANDER_RULESET))
					message_admins("DYNAMIC MODE: Ruleset [my_rule.name] refused as we already have a round-ending ruleset.")
					log_admin("DYNAMIC MODE: Ruleset [my_rule.name] refused as we already have a round-ending ruleset.")
					drafted_rules -= my_rule
					my_rule = null
	return my_rule

// -- A rule has been picked. We have to clean its assigned candidates from other rules to avoid someone getting multiple antags. We also check if that new rule has enough remaining candidates.
// choosen_one : the rule who has just been picked.
// drafted_rules : the rules currently drafted.
// returns : the new drafted rules.
/datum/gamemode/dynamic/proc/trimming_remaining_rules(var/datum/dynamic_ruleset/choosen_one, var/list/drafted_rules)
	for(var/mob/M in choosen_one.assigned)
		candidates -= M
		for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
			rule.candidates -= M//removing the assigned players from the candidates for the other rules
			if (!rule.ready())
				drafted_rules -= rule//and removing rules that are no longer eligible
				message_admins("[rule] no longer valid for picking.")
	return drafted_rules

// -- Executing a rule, which means spawning the traitor, removing the threat cost, etc.
// the_rule: the rule being executed
// returns: 0 or 1 depending on success. (failure meaning something runtimed mid-code.)
/datum/gamemode/dynamic/proc/executing_roundstart_rule(var/datum/dynamic_ruleset/the_rule)
	if (istype(the_rule, /datum/dynamic_ruleset/roundstart/delayed/))
		var/datum/dynamic_ruleset/roundstart/delayed/delayed_ruleset = the_rule
		message_admins("DYNAMIC MODE: Delayed ruleset, with a delay of [delayed_ruleset.delay/10] seconds.")
		log_admin("DYNAMIC MODE: Delayed ruleset, with a delay of [delayed_ruleset.delay/10] seconds.")
		threat_log += "[worldtime2text()]: Roundstart [the_rule.name] spent [the_rule.cost]"
		return pick_delay(the_rule)

	threat_log += "[worldtime2text()]: Roundstart [the_rule.name] spent [the_rule.cost]"
	if (the_rule.execute())//this should never fail since ready() returned 1
		the_rule.stillborn = IsRoundAboutToEnd()
		executed_rules += the_rule
		if (the_rule.persistent)
			current_rules += the_rule
	else
		message_admins("DYNAMIC MODE: ....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
		log_admin("DYNAMIC MODE: ....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
		return 0

/datum/gamemode/dynamic/proc/pick_delay(var/datum/dynamic_ruleset/roundstart/delayed/rule)
	spawn()
		sleep(rule.delay)
		rule.candidates = player_list.Copy()
		rule.trim_candidates()
		if (rule.execute())//this should never fail since ready() returned 1
			rule.stillborn = IsRoundAboutToEnd()
			executed_rules += rule
			if (rule.persistent)
				current_rules += rule
		else
			message_admins("DYNAMIC MODE: ....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
			log_admin("DYNAMIC MODE: ....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
	return 1


/datum/gamemode/dynamic/proc/picking_latejoin_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/latejoin/latejoin_rule = pickweight(drafted_rules)
	if (latejoin_rule)
		if (!latejoin_rule.repeatable)
			latejoin_rules = remove_rule(latejoin_rules,latejoin_rule.type)
		spend_midround_threat(latejoin_rule.cost)
		threat_log += "[worldtime2text()]: Latejoin [latejoin_rule.name] spent [latejoin_rule.cost] (midround budget)"
		dynamic_stats.measure_threat(threat)
		if (latejoin_rule.execute())//this should never fail since ready() returned 1
			latejoin_rule.stillborn = IsRoundAboutToEnd()
			var/mob/M = pick(latejoin_rule.assigned)
			message_admins("DYNAMIC MODE: [key_name(M)] joined the station, and was selected by the <font size='3'>[latejoin_rule.name]</font> ruleset.")
			log_admin("DYNAMIC MODE: [key_name(M)] joined the station, and was selected by the [latejoin_rule.name] ruleset.")
			executed_rules += latejoin_rule
			dynamic_stats.successful_injection(latejoin_rule)
			if (latejoin_rule.persistent)
				current_rules += latejoin_rule
			. = TRUE
		else //Actually it can fail here because latejoin prompts are optional and often called in the execute(), returns 0 if candidate refused
			threat_log += "[worldtime2text()]: Rule [latejoin_rule.name] refunded [latejoin_rule.cost] (selected applicant refused)"
			message_admins("DYNAMIC MODE: [latejoin_rule.name] failed to start due to the candidate refusing to play the role.")
			refund_midround_threat(latejoin_rule.cost)
	for (var/datum/dynamic_ruleset/latejoin/non_executed in drafted_rules)
		non_executed.assigned.Cut()


/datum/gamemode/dynamic/proc/picking_midround_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/midround/midround_rule = pickweight(drafted_rules)
	if (midround_rule)
		if (!midround_rule.repeatable)
			midround_rules = remove_rule(midround_rules,midround_rule.type)
		spend_midround_threat(midround_rule.cost)
		threat_log += "[worldtime2text()]: Midround [midround_rule.name] spent [midround_rule.cost] (midround budget)"
		dynamic_stats.measure_threat(threat)
		if (midround_rule.execute())//this should never fail since ready() returned 1
			midround_rule.stillborn = IsRoundAboutToEnd()
			message_admins("DYNAMIC MODE: Injecting some threats...<font size='3'>[midround_rule.name]</font>!")
			log_admin("DYNAMIC MODE: Injecting some threats...[midround_rule.name]!")
			dynamic_stats.successful_injection(midround_rule)
			executed_rules += midround_rule
			if (midround_rule.persistent)
				current_rules += midround_rule
			return 1
	return 0

/datum/gamemode/dynamic/proc/picking_specific_rule(var/ruletype,var/forced=0,var/caller)//an experimental proc to allow admins to call rules on the fly or have rules call other rules
	var/datum/dynamic_ruleset/midround/new_rule
	if(ispath(ruletype))
		new_rule = new ruletype()//you should only use it to call midround rules though.
	else if(istype(ruletype,/datum/dynamic_ruleset))
		new_rule = ruletype
	else
		message_admins("DYNAMIC MODE: The specific ruleset failed beacuse a type other than a path or rule was sent.")
		log_admin("DYNAMIC MODE: The specific ruleset failed beacuse a type other than a path or rule was sent.")
		return
	if(caller)
		new_rule.calledBy = caller
	update_playercounts()
	var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
	current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
	current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
	current_players[CURRENT_OBSERVERS] = list_observers.Copy()
	if (new_rule && (forced || new_rule.acceptable()))
		new_rule.candidates = current_players.Copy()
		new_rule.trim_candidates()
		if (new_rule.ready(forced))
			spend_threat(new_rule.cost)
			new_rule.choose_candidates()
			threat_log += "[worldtime2text()]: Forced rule [new_rule.name] spent [new_rule.cost]"
			dynamic_stats.measure_threat(threat)
			if (new_rule.execute())//this should never fail since ready() returned 1
				new_rule.stillborn = IsRoundAboutToEnd()
				message_admins("Making a call to a specific ruleset...<font size='3'>[new_rule.name]</font>!")
				log_admin("Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				dynamic_stats.successful_injection(new_rule)
				if (new_rule.persistent)
					current_rules += new_rule
				return 1
		else if (forced)
			message_admins("DYNAMIC MODE: The ruleset couldn't be executed for the above reason.")	//reason provided in the ruleset's ready()
			log_admin("DYNAMIC MODE: The ruleset couldn't be executed for the above reason.")		//generally limited to cases where the antag lacks a necessary spawn point
	return 0

/datum/gamemode/dynamic/process()
	. = ..() // Making the factions & roles process.

	if (pop_last_updated < world.time - (60 SECONDS))
		pop_last_updated = world.time
		update_playercounts()
		dynamic_stats.update_population(src)

	if (latejoin_injection_cooldown)
		latejoin_injection_cooldown--

	if (midround_injection_cooldown)
		midround_injection_cooldown--
	else
		if (admin_disable_rulesets)
			return
		//time to inject some threat into the round
		if(emergency_shuttle.departed)//unless the shuttle is gone
			return

		message_admins("DYNAMIC MODE: Checking state of the round.")
		log_admin("DYNAMIC MODE: Checking state of the round.")

		update_playercounts()

		if (injection_attempt())
			var/midround_injection_cooldown_middle = 0.5*(MIDROUND_DELAY_MAX + MIDROUND_DELAY_MIN)
			midround_injection_cooldown = round(clamp(exp_distribution(midround_injection_cooldown_middle), MIDROUND_DELAY_MIN, MIDROUND_DELAY_MAX))
			var/list/drafted_rules = list()
			var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
			current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
			current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
			current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
			current_players[CURRENT_OBSERVERS] = list_observers.Copy()
			for (var/datum/dynamic_ruleset/midround/rule in midround_rules)
				if (rule.acceptable())
					// Classic secret : only autotraitor/minor roles
					if (classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))
						message_admins("[rule] was refused because we're on classic secret mode.")
						continue
					// No stacking : only one round-enter, unless > stacking_limit threat.
					if (midround_threat < stacking_limit && no_stacking)
						var/skip_ruleset = 0
						for (var/datum/dynamic_ruleset/DR in executed_rules)
							if ((DR.flags & HIGHLANDER_RULESET) && (rule.flags & HIGHLANDER_RULESET))
								skip_ruleset = 1
								break
						if (skip_ruleset)
							message_admins("[rule] was refused because we already have a round-ender ruleset.")
							continue
					rule.candidates = list()
					rule.candidates = current_players.Copy()
					rule.trim_candidates()
					if (rule.ready())
						rule.choose_candidates()
						drafted_rules[rule] = rule.get_weight()

			if (drafted_rules.len > 0)
				message_admins("DYNAMIC MODE: [drafted_rules.len] eligible rulesets.")
				log_admin("DYNAMIC MODE: [drafted_rules.len] eligible rulesets.")
				picking_midround_rule(drafted_rules)
			else
				message_admins("DYNAMIC MODE: Couldn't ready-up a single ruleset. Lack of eligible candidates, population, or threat.")
				log_admin("DYNAMIC MODE: Couldn't ready-up a single ruleset. Lack of eligible candidates, population, or threat.")
		else
			midround_injection_cooldown = rand(600,1050)


/datum/gamemode/dynamic/proc/update_playercounts()
	living_players = list()
	living_antags = list()
	dead_players = list()
	list_observers = list()
	for (var/mob/M in player_list)
		if (!M.client)
			continue
		if (istype(M,/mob/new_player))
			continue
		if (M.stat != DEAD)
			living_players.Add(M)
			if (M.mind && (M.mind.antag_roles.len > 0))
				living_antags.Add(M)
		else
			if (istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if (O.started_as_observer)//Observers
					list_observers.Add(M)
					continue
				if (O.mind && O.mind.current && O.mind.current.ajourn)//Cultists
					living_players.Add(M)//yes we're adding a ghost to "living_players", so make sure to properly check for type when testing midround rules
					continue
			dead_players.Add(M)//Players who actually died (and admins who ghosted, would be nice to avoid counting them somehow)

	if(living_players.len) //if anybody is around and alive in the current round
		last_time_of_population = world.time
	else if(last_time_of_population && world.time - last_time_of_population > 1 HOURS) //if enough time has passed without it
		ticker.station_nolife_cinematic()

/datum/gamemode/dynamic/proc/GetInjectionChance()
	var/chance = 0
	//if the high pop override is in effect, we reduce the impact of population on the antag injection chance
	var/high_pop_factor = (player_list.len >= high_pop_limit)
	var/max_pop_per_antag = max(5,15 - round(threat_level/10) - round(living_players.len/(high_pop_factor ? 10 : 5)))//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=2053826290
	if (!living_antags.len)
		chance += 50//no antags at all? let's boost those odds!
	else
		var/current_pop_per_antag = living_players.len / living_antags.len
		if (current_pop_per_antag > max_pop_per_antag)
			chance += min(50, 25+10*(current_pop_per_antag-max_pop_per_antag))
		else
			chance += 25-10*(max_pop_per_antag-current_pop_per_antag)
	if (dead_players.len > living_players.len)
		chance -= 30//more than half the crew died? ew, let's calm down on antags
	if (threat > 70)
		chance += 15
	if (threat < 30)
		chance -= 15
	return round(max(0,chance))

/datum/gamemode/dynamic/proc/injection_attempt()//will need to gather stats to refine those values later
	var/chance = GetInjectionChance()
	message_admins("DYNAMIC MODE: Chance of injection with the current player numbers and threat level is...[chance]%.")
	log_admin("DYNAMIC MODE: Chance of injection with the current player numbers and threat level is...[chance]%.")
	if (prob(chance))
		message_admins("DYNAMIC MODE: Check passed! Looking for a valid ruleset to execute.")
		log_admin("DYNAMIC MODE: Check passed! Looking for a valid ruleset to execute.")
		return 1
	message_admins("DYNAMIC MODE: Check failed!")
	log_admin("DYNAMIC MODE: Check failed!")
	return 0

/datum/gamemode/dynamic/proc/remove_rule(var/list/rule_list,var/rule_type)
	for(var/datum/dynamic_ruleset/DR in rule_list)
		if(istype(DR,rule_type))
			rule_list -= DR
	return rule_list

/datum/gamemode/dynamic/latespawn(var/mob/living/newPlayer)
	if (admin_disable_rulesets)
		return
	if(emergency_shuttle.departed)//no more rules after the shuttle has left
		return

	update_playercounts()

	if (forced_latejoin_rule)
		forced_latejoin_rule.candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		message_admins("Forcing ruleset [forced_latejoin_rule]")
		if (forced_latejoin_rule.ready(1))
			if (forced_latejoin_rule.choose_candidates())
				picking_latejoin_rule(list(forced_latejoin_rule))
		forced_latejoin_rule = null
	else if (persistent_rule_interaction(newPlayer))
		return
	else if (!latejoin_injection_cooldown && injection_attempt())
		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (rule.acceptable())
				// Classic secret : only autotraitor/minor roles
				if (classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))
					message_admins("[rule] was refused because we're on classic secret mode.")
					continue
				// No stacking : only one round-enter, unless > stacking_limit threat.
				if (midround_threat < stacking_limit && no_stacking)
					var/skip_ruleset = 0
					for (var/datum/dynamic_ruleset/DR in executed_rules)
						if ((DR.flags & HIGHLANDER_RULESET) && (rule.flags & HIGHLANDER_RULESET))
							skip_ruleset = 1
							break
					if (skip_ruleset)
						message_admins("[rule] was refused because we already have a round-ender ruleset.")
						continue
				rule.candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					if (rule.choose_candidates())
						drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && picking_latejoin_rule(drafted_rules))
			var/latejoin_injection_cooldown_middle = 0.5*(LATEJOIN_DELAY_MAX + LATEJOIN_DELAY_MIN)
			latejoin_injection_cooldown = round(clamp(exp_distribution(latejoin_injection_cooldown_middle), LATEJOIN_DELAY_MIN, LATEJOIN_DELAY_MAX))

/datum/gamemode/dynamic/mob_destroyed(var/mob/M)
	for (var/datum/dynamic_ruleset/DR in midround_rules)
		DR.applicants -= M

//Regenerate threat, but no more than our original threat level.
/datum/gamemode/dynamic/proc/refund_threat(var/regain)
	threat = min(threat_level,threat+regain)

//Generate threat and increase the threat_level if it goes beyond, capped at 100
/datum/gamemode/dynamic/proc/create_threat(var/gain)
	threat = min(100, threat+gain)
	if(threat>threat_level)
		threat_level = threat

//Expend threat, but do not fall below 0.
/datum/gamemode/dynamic/proc/spend_threat(var/cost)
	threat = max(threat-cost,0)

// Same as above, but for midround
/datum/gamemode/dynamic/proc/refund_midround_threat(var/regain)
	midround_threat = min(midround_threat_level,midround_threat+regain)

/datum/gamemode/dynamic/proc/create_midround_threat(var/gain)
	midround_threat = min(100, midround_threat+gain)
	if(midround_threat>midround_threat_level)
		midround_threat_level = midround_threat

/datum/gamemode/dynamic/proc/spend_midround_threat(var/cost)
	midround_threat = max(midround_threat-cost,0)

// -- For the purpose of testing & simulation.
/datum/gamemode/dynamic/proc/simulate_roundstart(var/mob/user = usr)
	// Picking part
	var/done = 0
	var/list/rules_to_simulate = list()
	var/list/choices = list()
	for (var/datum/dynamic_ruleset/roundstart/DR in roundstart_rules)
		choices[DR.name] = DR
	choices["None"] = null
	while (!done)
		var/choice = input(user, "Which rule to you want to add to the simulated list? It has currently [rules_to_simulate.len] items.", "Midround rules to simulate") as null|anything in choices
		if (!choice || choice == "None")
			done = 1
		var/datum/dynamic_ruleset/to_test = choices[choice]
		if (threat < stacking_limit && no_stacking)
			var/skip_ruleset = 0
			for (var/datum/dynamic_ruleset/roundstart/DR in rules_to_simulate)
				if ((DR.flags & HIGHLANDER_RULESET) && (to_test.flags & HIGHLANDER_RULESET))
					skip_ruleset = 1
					message_admins("Skipping ruleset")
					break
			if (skip_ruleset)
				message_admins("The rule was not added, because we already have a round-ender.")
			else
				message_admins("The rule was accepted.")
				rules_to_simulate += to_test
		else
			message_admins("The rule was accepted (no-stacking not active.)")
			rules_to_simulate += to_test

/datum/gamemode/dynamic/proc/simulate_midround_injection(var/mob/user = usr)
	// Picking part
	var/done = 0
	var/list/rules_to_simulate = list()
	var/list/choices_a = list()
	for (var/datum/dynamic_ruleset/DR in midround_rules + roundstart_rules)
		choices_a[DR.name] = DR
	choices_a["None"] = null
	while (!done)
		var/choice = input(user, "Which rule to you want to add to the simulated list? It has currently [rules_to_simulate.len] items.", "Midround rules to simulate") as null|anything in choices_a
		if (!choice || choice == "None")
			done = 1
		else
			rules_to_simulate += choices_a[choice]

	var/list/choices_b = list()
	for (var/datum/dynamic_ruleset/midround/DR in midround_rules)
		choices_b[DR.name] = DR
	choices_b["None"] = null

	var/name_to_test = input(user, "What rule to you want to test?", "Midround rule to test") as null|anything in choices_b
	if (!name_to_test || name_to_test == "None")
		return

	var/datum/dynamic_ruleset/midround/to_test = choices_b[name_to_test]

	// Concrete testing

	if (classic_secret && !((to_test.flags & TRAITOR_RULESET) || (to_test.flags & MINOR_RULESET)))
		message_admins("[to_test] was refused because we're on classic secret mode.")
		return
	// No stacking : only one round-enter, unless > stacking_limit threat.
	if (threat < stacking_limit && no_stacking)
		var/skip_ruleset = 0
		for (var/datum/dynamic_ruleset/DR in rules_to_simulate)
			if ((DR.flags & HIGHLANDER_RULESET) && (to_test.flags & HIGHLANDER_RULESET))
				skip_ruleset = 1
			if (skip_ruleset)
				message_admins("[to_test] was refused because we already have a round-ender ruleset.")
				return

	message_admins("The rule was accepted.")

/datum/gamemode/dynamic/proc/simulate_latejoin_injection(var/mob/user = usr)
	// Picking part
	var/done = 0
	var/list/rules_to_simulate = list()
	var/list/choices_a = list()
	for (var/datum/dynamic_ruleset/DR in midround_rules + roundstart_rules)
		choices_a[DR.name] = DR
	choices_a["None"] = null
	while (!done)
		var/choice = input(user, "Which rule to you want to add to the simulated list? It has currently [rules_to_simulate.len] items.", "Midround rules to simulate") as null|anything in choices_a
		if (!choice || choice == "None")
			done = 1
		else
			rules_to_simulate += choices_a[choice]

	var/list/choices_b = list()
	for (var/datum/dynamic_ruleset/latejoin/DR in latejoin_rules)
		choices_b[DR.name] = DR
	choices_b["None"] = null

	var/name_to_test = input(user, "What rule to you want to test?", "Midround rule to test") as null|anything in choices_b
	if (!name_to_test || name_to_test == "None")
		return

	var/datum/dynamic_ruleset/latejoin/to_test = choices_b[name_to_test]

	// Concrete testing

	if (classic_secret && !((to_test.flags & TRAITOR_RULESET) || (to_test.flags & MINOR_RULESET)))
		message_admins("[to_test] was refused because we're on classic secret mode.")
		return
	// No stacking : only one round-enter, unless > stacking_limit threat.
	if (threat < stacking_limit && no_stacking)
		var/skip_ruleset = 0
		for (var/datum/dynamic_ruleset/DR in rules_to_simulate)
			if ((DR.flags & HIGHLANDER_RULESET) && (to_test.flags & HIGHLANDER_RULESET))
				skip_ruleset = 1
				break
		if (skip_ruleset)
			message_admins("[to_test] was refused because we already have a round-ender ruleset.")
			return

	message_admins("The rule was accepted.")

/datum/gamemode/dynamic/proc/update_stillborn_rulesets()
	for (var/datum/dynamic_ruleset/ruleset in executed_rules)
		if (ruleset.stillborn)
			ruleset.stillborn = IsRoundAboutToEnd()

/datum/gamemode/dynamic/proc/persistent_rule_interaction(var/mob/living/newPlayer)
	for (var/datum/dynamic_ruleset/ruleset in executed_rules)
		if (ruleset.latespawn_interaction(newPlayer))
			return TRUE
	return FALSE
