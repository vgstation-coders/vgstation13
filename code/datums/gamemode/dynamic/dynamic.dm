var/list/forced_roundstart_ruleset = list()

// -- Distribution parameters chosen prior to roundstart --
var/dynamic_curve_centre = 0
var/dynamic_curve_width = 1.8
var/dynamic_chosen_mode = LORENTZ

// -- Dynamic tweaks chosen prior to roundstart --
var/dynamic_no_stacking = 1 // NO STACKING : only one "round-ender", except if we're above 80 threat
var/dynamic_classic_secret = 0 // Only one roundstart ruleset, and only autotraitor + minor rules allowed
var/dynamic_high_pop_limit = 45 // Will switch to "high pop override" if the roundstart population is above this
var/dynamic_forced_extended = 0 // No rulesets will be drated, ever

var/stacking_limit = 90

#define BASE_SOLO_REFUND 10

/datum/gamemode/dynamic
	name = "Dynamic Mode"

	//Threat logging vars
	var/threat_level = 0//the "threat cap", threat shouldn't normally go above this and is used in ruleset calculations
	var/starting_threat = 0 //threat_level's initially rolled value. Threat_level isn't changed by many things.
	var/threat = 0//set at the beginning of the round. Spent by the mode to "purchase" rules.
	var/list/threat_log = list() //Running information about the threat. Can store text or datum entries.

	var/list/roundstart_rules = list()
	var/list/latejoin_rules = list()
	var/list/midround_rules = list()
	var/list/second_rule_req = list(100,100,100,80,60,40,20,0,0,0)//requirements for extra round start rules
	var/list/third_rule_req = list(100,100,100,100,100,70,50,30,10,0)
	var/roundstart_pop_ready = 0
	var/list/candidates = list()
	var/list/current_rules = list()
	var/list/executed_rules = list()

	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

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

	// -- Special tweaks --
	var/no_stacking = 1
	var/classic_secret = 0
	var/high_pop_limit = 45
	var/forced_extended = 0

/datum/gamemode/dynamic/AdminPanelEntry()
	var/dat = list()
	dat += "Dynamic Mode <a href='?_src_=vars;Vars=\ref[src]'>\[VV\]</A><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Threat to Spend: <b>[threat]</b> <a href='?_src_=holder;adjustthreat=1'>\[Adjust\]</A> <a href='?_src_=holder;threatlog=1'>\[View Log\]</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [curve_centre_of_round] ; width = [curve_width_of_round].<br/>"
	dat += "<i>On average, <b>[peaceful_percentage]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "Forced extended: <a href='?src=\ref[src];forced_extended=1'><b>[forced_extended ? "On" : "Off"]</b></a><br/>"
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
	if (href_list["forced_extended"])
		forced_extended =! forced_extended
		message_admins("[key_name(usr)] has set 'forced extended' to [forced_extended].")
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

	var/out = "<TITLE>Threat Log</TITLE><B><font size='3'>Threat Log</font></B><br><B>Starting Threat:</B> [starting_threat]<BR>"

	for(var/entry in threat_log)
		if(istext(entry))
			out += "[entry]<BR>"
		if(istype(entry,/datum/role/catbeast))
			var/datum/role/catbeast/C = entry
			out += "Catbeast threat regenerated/threat_level inflated: [C.threat_generated]/[C.threat_level_inflated]<BR>"

	out += "<B>Remaining threat/threat_level:</B> [threat]/[threat_level]"

	usr << browse(out, "window=threatlog;size=700x500")

/datum/gamemode/dynamic/GetScoreboard()

	dat += "<h2>Dynamic Mode v1.0 - Threat Level = <font color='red'>[threat_level]%</font></h2><a href='?src=\ref[src];threatlog=1'>\[View Log\]</a>"

	var/rules = list()
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
			rules += "[ruletype] - **[DR.name]** [DR.calledBy ? " (called by [DR.calledBy])" : ""]"
	else
		dat += "(extended)"
	dat += "<HR>"
	. = ..()
	send2mainirc("A round of [src.name] has ended - [living_players.len] survivors, [dead_players.len] ghosts.")
	send2maindiscord("A round of **[name]** has ended - **[living_players.len]** survivors, **[dead_players.len]** ghosts.")
	send2mainirc("Dynamic mode Threat Level: [starting_threat][(starting_threat!=threat_level)?" ([threat_level])":""], rulesets: [jointext(rules, ", ")].")
	send2maindiscord("Dynamic mode Threat Level: **[starting_threat][(starting_threat!=threat_level)?" ([threat_level])":""]**, rulesets: [jointext(rules, ", ")]")

/datum/gamemode/dynamic/can_start()
	distribution_mode = dynamic_chosen_mode
	message_admins("Distribution mode is : [dynamic_chosen_mode].")
	curve_centre_of_round = dynamic_curve_centre
	curve_width_of_round = dynamic_curve_width
	message_admins("Curve centre and curve width are : [curve_centre_of_round], [curve_width_of_round]")
	forced_extended = dynamic_forced_extended
	if (forced_extended)
		message_admins("The round will be forced to extended.")
	no_stacking = dynamic_no_stacking
	if (no_stacking)
		message_admins("Round-ending rulesets won't stack, unless the threat is above stacking_limit ([stacking_limit]).")
	classic_secret = dynamic_classic_secret
	if (classic_secret)
		message_admins("Classic secret mode active: only autotraitors will spawn, and we will only have one roundstart ruleset.")
	log_admin("Dynamic mode parameters for the round: distrib mode = [distribution_mode], centre = [curve_centre_of_round], width is [curve_width_of_round]. Extended : [forced_extended], no stacking : [no_stacking], classic secret: [classic_secret].")

	generate_threat()


	var/latejoin_injection_cooldown_middle = 0.5*(LATEJOIN_DELAY_MAX + LATEJOIN_DELAY_MIN)
	latejoin_injection_cooldown = round(Clamp(exp_distribution(latejoin_injection_cooldown_middle), LATEJOIN_DELAY_MIN, LATEJOIN_DELAY_MAX))

	var/midround_injection_cooldown_middle = 0.5*(MIDROUND_DELAY_MAX + MIDROUND_DELAY_MIN)
	midround_injection_cooldown = round(Clamp(exp_distribution(midround_injection_cooldown_middle), MIDROUND_DELAY_MIN, MIDROUND_DELAY_MAX))

	message_admins("Dynamic Mode initialized with a Threat Level of... <font size='8'>[threat_level]</font>!")
	log_admin("Dynamic Mode initialized with a Threat Level of... [threat_level]!")

	message_admins("Parameters were: centre = [curve_centre_of_round], width = [curve_width_of_round].")
	log_admin("Parameters were: centre = [curve_centre_of_round], width = [curve_width_of_round].")

	var/rst_pop = 0
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			rst_pop++
	if (rst_pop >= high_pop_limit)
		message_admins("High Population Override is in effect! ([rst_pop]/[high_pop_limit]) Threat Level will have more impact on which roles will appear, and player population less.")
		log_admin("High Population Override is in effect! ([rst_pop]/[high_pop_limit]) Threat Level will have more impact on which roles will appear, and player population less.")
	dynamic_stats = new
	dynamic_stats.starting_threat_level = threat_level

	if (round(threat_level*10) == 666)
		forced_roundstart_ruleset += new /datum/dynamic_ruleset/roundstart/bloodcult()
		forced_roundstart_ruleset += new /datum/dynamic_ruleset/roundstart/vampire()
		log_admin("666 threat override.")
		message_admins("666 threat override.", 1)

	return 1

/datum/gamemode/dynamic/Setup()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart) - /datum/dynamic_ruleset/roundstart/delayed/)
		roundstart_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/latejoin))
		latejoin_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/midround))
		var/datum/dynamic_ruleset/midround/DR = rule
		if (initial(DR.weight))
			midround_rules += new rule()
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			roundstart_pop_ready++
			candidates.Add(player)
	message_admins("Listing [roundstart_rules.len] round start rulesets, and [candidates.len] players ready.")
	if (candidates.len <= 0)
		message_admins("Not a single player readied-up. The round will begin without any roles assigned.")
		return 1
	if (roundstart_rules.len <= 0)
		message_admins("There are no roundstart rules within the code, what the fuck? The round will begin without any roles assigned.")
		return 1
	if (forced_roundstart_ruleset.len > 0)
		rigged_roundstart()
	else
		roundstart()

	var/starting_rulesets = ""
	for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
		starting_rulesets += "[DR.name], "
	dynamic_stats.round_start_pop = candidates.len
	dynamic_stats.round_start_rulesets = starting_rulesets
	dynamic_stats.measure_threat(threat)
	return 1

/datum/gamemode/dynamic/proc/rigged_roundstart()
	message_admins("[forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	for (var/datum/dynamic_ruleset/roundstart/rule in forced_roundstart_ruleset)
		rule.mode = src
		rule.candidates = candidates.Copy()
		rule.trim_candidates()
		if (rule.ready(1))//ignoring enemy job requirements
			picking_roundstart_rule(list(rule))

/datum/gamemode/dynamic/proc/roundstart()
	if (forced_extended)
		message_admins("Starting a round of forced extended.")
		return 1
	var/list/drafted_rules = list()
	var/i = 0
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (rule.acceptable(roundstart_pop_ready,threat_level) && threat >= rule.cost)	//if we got the population and threat required
			i++																			//we check whether we've got eligible players
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready())
				drafted_rules[rule] = rule.weight

	var/indice_pop = min(10,round(roundstart_pop_ready/5)+1)
	var/extra_rulesets_amount = 0

	if (classic_secret) // Classic secret experience : one & only one roundstart ruleset
		extra_rulesets_amount = 0
	else
		var/rst_pop = 0
		for(var/mob/new_player/player in player_list)
			if(player.ready && player.mind)
				rst_pop++
		if (rst_pop > high_pop_limit)
			if (threat_level > 50)
				extra_rulesets_amount++
				if (threat_level > 75)
					extra_rulesets_amount++
		else
			if (rst_pop >= high_pop_limit - 10)
				if (threat_level >= second_rule_req[indice_pop])
					extra_rulesets_amount++
					if (threat_level >= third_rule_req[indice_pop])
						extra_rulesets_amount++
			else
				classic_secret = 1
				dynamic_classic_secret = 1
				extra_rulesets_amount = 0

	if (classic_secret)
		message_admins("Classic secret was either forced or readied-up amount was low enough secret was rolled.")
	else
		message_admins("[i] rulesets qualify for the current pop and threat level, including [drafted_rules.len] with eligible candidates.")
	if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
		if (extra_rulesets_amount > 0)//we've got enough population and threat for a second rulestart rule
			for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
				if (rule.cost > threat)
					drafted_rules -= rule
			message_admins("The current pop and threat level allow for a second round start ruleset, there remains [candidates.len] eligible candidates and [drafted_rules.len] eligible rulesets")
			if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
				if (extra_rulesets_amount > 1)//we've got enough population and threat for a third rulestart rule
					for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
						if (rule.cost > threat)
							drafted_rules -= rule
					message_admins("The current pop and threat level allow for a third round start ruleset, there remains [candidates.len] eligible candidates and [drafted_rules.len] eligible rulesets")
					if (!drafted_rules.len > 0 || !picking_roundstart_rule(drafted_rules))
						message_admins("The mode failed to pick a third ruleset.")
			else
				message_admins("The mode failed to pick a second ruleset.")
	else
		message_admins("The mode failed to pick a first ruleset. The round will begin without any roles assigned.")
		return 0
	return 1

/datum/gamemode/dynamic/proc/picking_roundstart_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/roundstart/starting_rule

	while(!starting_rule && drafted_rules.len > 0)
		starting_rule = pickweight(drafted_rules)
		if (threat < stacking_limit && no_stacking)
			for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
				if ((DR.flags & HIGHLANDER_RULESET) && (starting_rule.flags & HIGHLANDER_RULESET))
					message_admins("Ruleset [starting_rule.name] refused as we already have a round-ending ruleset.")
					log_admin("Ruleset [starting_rule.name] refused as we already have a round-ending ruleset.")
					drafted_rules -= starting_rule
					starting_rule = null

	if (starting_rule)
		message_admins("Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[starting_rule.name]</font>!")
		log_admin("Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[starting_rule.name]</font>!")

		roundstart_rules -= starting_rule
		drafted_rules -= starting_rule

		if (istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/))
			message_admins("Delayed ruleset, with a delay of [starting_rule:delay/10] seconds.")
			spend_threat(starting_rule.cost)
			return pick_delay(starting_rule)

		spend_threat(starting_rule.cost)
		threat_log += "[worldtime2text()]: Roundstart [starting_rule.name] spent [starting_rule.cost]"
		if (starting_rule.execute())//this should never fail since ready() returned 1
			executed_rules += starting_rule
			if (starting_rule.persistent)
				current_rules += starting_rule
			for(var/mob/M in starting_rule.assigned)
				candidates -= M
				for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
					rule.candidates -= M//removing the assigned players from the candidates for the other rules
					if (!rule.ready())
						drafted_rules -= rule//and removing rules that are no longer eligible
			return 1
		else
			message_admins("....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
	return 0

/datum/gamemode/dynamic/proc/pick_delay(var/datum/dynamic_ruleset/roundstart/delayed/rule)
	spawn()
		sleep(rule.delay)
		rule.candidates = player_list.Copy()
		rule.trim_candidates()
		if (rule.execute())//this should never fail since ready() returned 1
			executed_rules += rule
			if (rule.persistent)
				current_rules += rule
		else
			message_admins("....except not because whomever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
	return 1


/datum/gamemode/dynamic/proc/picking_latejoin_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/latejoin/latejoin_rule = pickweight(drafted_rules)
	if (latejoin_rule)
		if (!latejoin_rule.repeatable)
			latejoin_rules = remove_rule(latejoin_rules,latejoin_rule.type)
		spend_threat(latejoin_rule.cost)
		threat_log += "[worldtime2text()]: Latejoin [latejoin_rule.name] spent [latejoin_rule.cost]"
		dynamic_stats.measure_threat(threat)
		if (latejoin_rule.execute())//this should never fail since ready() returned 1
			var/mob/M = pick(latejoin_rule.assigned)
			message_admins("[key_name(M)] joined the station, and was selected by the <font size='3'>[latejoin_rule.name]</font> ruleset.")
			log_admin("[key_name(M)] joined the station, and was selected by the [latejoin_rule.name] ruleset.")
			executed_rules += latejoin_rule
			dynamic_stats.successful_injection(latejoin_rule)
			if (latejoin_rule.persistent)
				current_rules += latejoin_rule
			return 1
	return 0

/datum/gamemode/dynamic/proc/picking_midround_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/midround/midround_rule = pickweight(drafted_rules)
	if (midround_rule)
		if (!midround_rule.repeatable)
			midround_rules = remove_rule(midround_rules,midround_rule.type)
		spend_threat(midround_rule.cost)
		threat_log += "[worldtime2text()]: Midround [midround_rule.name] spent [midround_rule.cost]"
		dynamic_stats.measure_threat(threat)
		if (midround_rule.execute())//this should never fail since ready() returned 1
			message_admins("Injecting some threats...<font size='3'>[midround_rule.name]</font>!")
			log_admin("Injecting some threats...[midround_rule.name]!")
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
		message_admins("The specific ruleset failed beacuse a type other than a path or rule was sent.")
		return
	if(caller)
		new_rule.calledBy = caller
	update_playercounts()
	var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
	current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
	current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
	current_players[CURRENT_OBSERVERS] = list_observers.Copy()
	if (new_rule && (forced || (new_rule.acceptable(living_players.len,threat_level) && new_rule.cost <= threat)))
		new_rule.candidates = current_players.Copy()
		new_rule.trim_candidates()
		if (new_rule.ready(forced))
			spend_threat(new_rule.cost)
			threat_log += "[worldtime2text()]: Forced rule [new_rule.name] spent [new_rule.cost]"
			dynamic_stats.measure_threat(threat)
			if (new_rule.execute())//this should never fail since ready() returned 1
				message_admins("Making a call to a specific ruleset...<font size='3'>[new_rule.name]</font>!")
				log_admin("Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				dynamic_stats.successful_injection(new_rule)
				if (new_rule.persistent)
					current_rules += new_rule
				return 1
		else if (forced)
			message_admins("The ruleset couldn't be executed due to lack of eligible players.")
			log_admin("The ruleset couldn't be executed due to lack of eligible players.")
	return 0

/datum/gamemode/dynamic/process()
	. = ..() // Making the factions & roles process.

	if (pop_last_updated < world.time - (60 SECONDS))
		pop_last_updated = world.time
		update_playercounts()
		dynamic_stats.update_population(src)

	if (latejoin_injection_cooldown)
		latejoin_injection_cooldown--

	for (var/datum/dynamic_ruleset/rule in current_rules)
		rule.process()

	if (midround_injection_cooldown)
		midround_injection_cooldown--
	else
		if (forced_extended)
			return
		//time to inject some threat into the round
		if(emergency_shuttle.departed)//unless the shuttle is gone
			return

		message_admins("DYNAMIC MODE: Checking state of the round.")
		log_admin("DYNAMIC MODE: Checking state of the round.")

		update_playercounts()

		if (injection_attempt())
			var/midround_injection_cooldown_middle = 0.5*(MIDROUND_DELAY_MAX + MIDROUND_DELAY_MIN)
			midround_injection_cooldown = round(Clamp(exp_distribution(midround_injection_cooldown_middle), MIDROUND_DELAY_MIN, MIDROUND_DELAY_MAX))
			var/list/drafted_rules = list()
			var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
			current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
			current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
			current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
			current_players[CURRENT_OBSERVERS] = list_observers.Copy()
			for (var/datum/dynamic_ruleset/midround/rule in midround_rules)
				if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
					// Classic secret : only autotraitor/minor roles
					/*if (classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))*/
					if (classic_secret && !((rule.flags & TRAITOR_RULESET))) //secret should be 1 ruleset only. Admins can bus in stuff if they want.
						message_admins("[rule] was refused because we're on classic secret mode.")
						continue
					// No stacking : only one round-enter, unless > stacking_limit threat.
					if (threat < stacking_limit && no_stacking)
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
	if (forced_extended)
		return
	if(emergency_shuttle.departed)//no more rules after the shuttle has left
		return

	update_playercounts()

	if (forced_latejoin_rule)
		forced_latejoin_rule.candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		message_admins("Forcing ruleset [forced_latejoin_rule]")
		if (forced_latejoin_rule.ready(1))
			picking_latejoin_rule(list(forced_latejoin_rule))
		forced_latejoin_rule = null

	else if (!latejoin_injection_cooldown && injection_attempt())
		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
				// Classic secret : only autotraitor/minor roles
				/*if (classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))*/
				if (classic_secret && !((rule.flags & TRAITOR_RULESET))) //secret should be 1 ruleset only. Admins can bus in stuff if they want.
					message_admins("[rule] was refused because we're on classic secret mode.")
					continue
				// No stacking : only one round-enter, unless > stacking_limit threat.
				if (threat < stacking_limit && no_stacking)
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
					drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && picking_latejoin_rule(drafted_rules))
			var/latejoin_injection_cooldown_middle = 0.5*(LATEJOIN_DELAY_MAX + LATEJOIN_DELAY_MIN)
			latejoin_injection_cooldown = round(Clamp(exp_distribution(latejoin_injection_cooldown_middle), LATEJOIN_DELAY_MIN, LATEJOIN_DELAY_MAX))

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

	/*if (classic_secret && !((to_test.flags & TRAITOR_RULESET) || (to_test.flags & MINOR_RULESET)))*/
	if (classic_secret && !((to_test.flags & TRAITOR_RULESET))) //secret should be 1 ruleset only. Admins can bus in stuff if they want.
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

	/*if (classic_secret && !((to_test.flags & TRAITOR_RULESET) || (to_test.flags & MINOR_RULESET)))*/
	if (classic_secret && !((to_test.flags & TRAITOR_RULESET))) //secret should be 1 ruleset only. Admins can bus in stuff if they want.
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
