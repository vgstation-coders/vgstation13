var/list/forced_roundstart_ruleset = list()

var/list/threat_by_job = list(
	"Captain" = 12,
	"Head of Security" = 10,
	"Head of Personnel" = 8,
	"Warden" = 8,
	"Security Officer" = 4,
	"Detective" = 3,
)

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
	//var/list/second_rule_req = list(100,100,100,80,60,40,20,0,0,0)//requirements for extra round start rules
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

/datum/gamemode/dynamic/AdminPanelEntry()
	var/dat = list()
	dat += "Dynamic Mode <a href='?_src_=vars;Vars=\ref[src]'>\[VV\]</A><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Threat to Spend: <b>[threat]</b> <a href='?_src_=holder;adjustthreat=1'>\[Adjust\]</A> <a href='?_src_=holder;threatlog=1'>\[View Log\]</a><br/>"
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

/datum/gamemode/dynamic/proc/show_threatlog(mob/admin)
	if(!ticker || !ticker.mode)
		alert("Ticker and Game Mode aren't initialized yet!", "Alert")
		return

	if(!admin.check_rights(R_ADMIN))
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
	dat += "<h2>Dynamic Mode v1.0 - Threat Level = <font color='red'>[threat_level]%</font></h2>"
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
			dat += "([ruletype]) - <b>[DR.name]</b><br>"
			rules += "[ruletype] - **[DR.name]**"
	else
		dat += "(extended)"
	dat += "<HR>"
	. = ..()
	send2mainirc("A round of [src.name] has ended - [living_players.len] survivors, [dead_players.len] ghosts.")
	send2maindiscord("A round of **[name]** has ended - **[living_players.len]** survivors, **[dead_players.len]** ghosts.")
	send2mainirc("Dynamic mode threat: [threat_level], rulesets: [jointext(rules, ", ")].")
	send2maindiscord("Dynamic mode threat: **[threat_level]**, rulesets: [jointext(rules, ", ")]")

/datum/gamemode/dynamic/can_start()
	threat_level = rand(1,100)*0.6 + rand(1,100)*0.4//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388
	threat = threat_level
	starting_threat = threat_level
	latejoin_injection_cooldown = rand(330,510)
	midround_injection_cooldown = rand(600,1050)
	message_admins("Dynamic Mode initialized with a Threat Level of... <font size='8'>[threat_level]</font>!")
	log_admin("Dynamic Mode initialized with a Threat Level of... [threat_level]!")
	dynamic_stats = new
	dynamic_stats.starting_threat_level = threat_level

	if (threat_level == 66.6)
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
	dynamic_stats.roundstart_pop = candidates.len
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
	dynamic_stats.roundstart_rulesets = starting_rulesets
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
	var/list/drafted_rules = list()
	var/i = 0
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (rule.acceptable(roundstart_pop_ready,threat_level) && threat >= rule.cost)	//if we got the population and threat required
			i++																			//we check whether we've got elligible players
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready())
				drafted_rules[rule] = rule.weight

	var/indice_pop = min(10,round(roundstart_pop_ready/5)+1)
	message_admins("[i] rulesets qualify for the current pop and threat level, including [drafted_rules.len] with elligible candidates.")
	if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
		if (threat_level >= second_rule_req[indice_pop])//we've got enough population and threat for a second rulestart rule
			for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
				if (rule.cost > threat)
					drafted_rules -= rule
			message_admins("The current pop and threat level allow for a second round start ruleset, there remains [candidates.len] elligible candidates and [drafted_rules.len] elligible rulesets")
			if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
				if (threat_level >= third_rule_req[indice_pop])//we've got enough population and threat for a third rulestart rule
					for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
						if (rule.cost > threat)
							drafted_rules -= rule
					message_admins("The current pop and threat level allow for a third round start ruleset, there remains [candidates.len] elligible candidates and [drafted_rules.len] elligible rulesets")
					if (!drafted_rules.len > 0 || !picking_roundstart_rule(drafted_rules))
						message_admins("The mode failed to pick a third ruleset.")
			else
				message_admins("The mode failed to pick a second ruleset.")
	else
		message_admins("The mode failed to pick a first ruleset. The round will begin without any roles assigned.")
		return 0
	return 1

/datum/gamemode/dynamic/proc/picking_roundstart_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/roundstart/starting_rule = pickweight(drafted_rules)

	if (starting_rule)
		message_admins("Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[starting_rule.name]</font>!")
		log_admin("Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[starting_rule.name]</font>!")

		roundstart_rules -= starting_rule
		drafted_rules -= starting_rule

		if (istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/))
			message_admins("Delayed ruleset, with a delay of [starting_rule:delay/10] seconds.")
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
						drafted_rules -= rule//and removing rules that are no longer elligible
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

/datum/gamemode/dynamic/proc/picking_specific_rule(var/ruletype,var/forced=0)//an experimental proc to allow admins to call rules on the fly or have rules call other rules
	var/datum/dynamic_ruleset/midround/new_rule
	if(ispath(ruletype))
		new_rule = new ruletype()//you should only use it to call midround rules though.
	else if(istype(ruletype,/datum/dynamic_ruleset))
		new_rule = ruletype
	else
		message_admins("The specific ruleset failed beacuse a type other than a path or rule was sent.")
		return
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
			message_admins("The ruleset couldn't be executed due to lack of elligible players.")
			log_admin("The ruleset couldn't be executed due to lack of elligible players.")
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
		//time to inject some threat into the round
		if(emergency_shuttle.departed)//unless the shuttle is gone
			return

		message_admins("DYNAMIC MODE: Checking state of the round.")
		log_admin("DYNAMIC MODE: Checking state of the round.")

		update_playercounts()

		if (injection_attempt())
			midround_injection_cooldown = rand(600,1050)//20 to 35 minutes inbetween midround threat injections attempts
			var/list/drafted_rules = list()
			var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
			current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
			current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
			current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
			current_players[CURRENT_OBSERVERS] = list_observers.Copy()
			for (var/datum/dynamic_ruleset/midround/rule in midround_rules)
				if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
					rule.candidates = current_players.Copy()
					rule.trim_candidates()
					if (rule.ready())
						drafted_rules[rule] = rule.get_weight()

			if (drafted_rules.len > 0)
				message_admins("DYNAMIC MODE: [drafted_rules.len] elligible rulesets.")
				log_admin("DYNAMIC MODE: [drafted_rules.len] elligible rulesets.")
				picking_midround_rule(drafted_rules)
			else
				message_admins("DYNAMIC MODE: Couldn't ready-up a single ruleset. Lack of elligible candidates, population, or threat.")
				log_admin("DYNAMIC MODE: Couldn't ready-up a single ruleset. Lack of elligible candidates, population, or threat.")
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
	var/max_pop_per_antag = max(5,15 - round(threat_level/10) - round(living_players.len/5))//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=2053826290
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
				rule.candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && picking_latejoin_rule(drafted_rules))
			latejoin_injection_cooldown = rand(330,510)//11 to 17 minutes inbetween antag latejoiner rolls

	// -- No injection, we'll just update the threat
	else
		var/jobthreat = threat_by_job[newPlayer.mind.assigned_role]
		if(jobthreat)
			refund_threat(jobthreat)
			threat_log += "[worldtime2text()]: [newPlayer] refunded [jobthreat] by joining as [newPlayer.mind.assigned_role]."

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
