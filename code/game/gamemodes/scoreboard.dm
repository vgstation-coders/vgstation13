/datum/controller/gameticker/proc/scoreboard(var/completions)

	mode.declare_completion()
	completions += "[mode.dat]<HR>"

	/*//Calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/gamemode/proc))
		if(findtext("[handler]","auto_declare_completion_"))
			completions += "[call(mode, handler)()]"*/

	//completions += "<br>[ert_declare_completion()]"
	//completions += "<br>[deathsquad_declare_completion()]"

	if(bomberman_mode)
		completions += "<br>[bomberman_declare_completion()]"

	if(ticker.achievements.len)
		completions += "<br>[achievement_declare_completion()]"

	var/ai_completions = ""
	for(var/mob/living/silicon/ai/ai in mob_list)
		var/icon/flat = getFlatIcon(ai)
		end_icons += flat
		var/tempstate = end_icons.len
		if(ai.stat != 2)
			ai_completions += {"<br><b><img src="logo_[tempstate].png"> [ai.name] (Played by: [get_key(ai)])'s laws at the end of the game were:</b>"}
		else
			ai_completions += {"<br><b><img src="logo_[tempstate].png"> [ai.name] (Played by: [get_key(ai)])'s laws when it was deactivated were:</b>"}
		ai_completions += "<br>[ai.write_laws()]"

		if (ai.connected_robots.len)
			var/robolist = "<br><b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in ai.connected_robots)
				if (!robo.connected_ai || !isMoMMI(robo)) // Don't report MoMMIs or unslaved robutts
					continue
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [get_key(robo)]), ":" (Played by: [get_key(robo)]), "]"
			ai_completions += "[robolist]"

	for (var/mob/living/silicon/robot/robo in mob_list)
		if(!robo)
			continue
		var/icon/flat = getFlatIcon(robo)
		end_icons += flat
		var/tempstate = end_icons.len
		if (!robo.connected_ai)
			if (robo.stat != 2)
				ai_completions += {"<br><b><img src="logo_[tempstate].png"> [robo.name] (Played by: [get_key(robo)]) survived as an AI-less [isMoMMI(robo)?"MoMMI":"borg"]! Its laws were:</b>"}
			else
				ai_completions += {"<br><b><img src="logo_[tempstate].png"> [robo.name] (Played by: [get_key(robo)]) was unable to survive the rigors of being a [isMoMMI(robo)?"MoMMI":"cyborg"] without an AI. Its laws were:</b>"}
		else
			ai_completions += {"<br><b><img src="logo_[tempstate].png"> [robo.name] (Played by: [get_key(robo)]) [robo.stat!=2?"survived":"perished"] as a [isMoMMI(robo)?"MoMMI":"cyborg"] slaved to [robo.connected_ai]! Its laws were:</b>"}
		ai_completions += "<br>[robo.write_laws()]"

	for(var/mob/living/silicon/pai/pAI in mob_list)
		var/icon/flat
		flat = getFlatIcon(pAI)
		end_icons += flat
		var/tempstate = end_icons.len
		ai_completions += {"<br><b><img src="logo_[tempstate].png"> [pAI.name] (Played by: [get_key(pAI)]) [pAI.stat!=2?"survived":"perished"] as a pAI whose master was [pAI.master]! Its directives were:</b><br>[pAI.write_directives()]"}

	if (ai_completions)
		completions += "<h2>Silicons Laws</h2>"
		completions += ai_completions
		completions += "<HR>"

	//Score Calculation and Display
	for (var/ID in disease2_list)
		var/disease_spread_count = 0
		var/datum/disease2/disease/D = disease2_list[ID]
		var/disease_score = 0
		for (var/datum/disease2/effect/E in D.effects)
			disease_score += text2num(E.badness)

		//diseases only count if the mob is still alive
		if (disease_score <3)
			for (var/mob/living/L in mob_list)
				if (ID in L.virus2)
					disease_spread_count++
					if (L.stat != DEAD)
						score["disease_good"]++
		else
			for (var/mob/living/L in mob_list)
				if(!L.mind) //No ballooning the negative score with infected monkeymen
					continue
				if (ID in L.virus2)
					disease_spread_count++
					if (L.stat != DEAD)
						score["disease_bad"]++

		if (disease_spread_count > score["disease_most_count"])
			score["disease_most_count"] = disease_spread_count
			score["disease_most"] = ID

	//Run through humans for diseases, also the Clown
	for(var/mob/living/carbon/human/I in mob_list)
		/*
		if(I.viruses) //Do this guy have any viruses ?
			for(var/datum/disease/D in I.viruses) //Alright, start looping through those viruses
				score["disease"]++ //One point for every disease
		*/

		if(I.job == "Clown")
			for(var/thing in I.attack_log)
				if(findtext(thing, "<font color='orange'>")) //I just dropped 10 IQ points from seeing this
					score["clownabuse"]++

	score["money_leaderboard"] = SSpersistence_misc.tasks[/datum/persistence_task/highscores]
	var/list/rich_escapes = list()
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/T = get_turf(player)
			if(!T)
				continue

			if(istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
				score["escapees"]++
				var/cashscore = 0
				var/dmgscore = 0

				for(var/obj/item/weapon/card/id/C1 in get_contents_in_object(player, /obj/item/weapon/card/id))
					cashscore += C1.GetBalance() //From bank account
					if(istype(C1.virtual_wallet))
						cashscore += C1.virtual_wallet.money

				for(var/obj/item/weapon/spacecash/C2 in get_contents_in_object(player, /obj/item/weapon/spacecash))
					cashscore += (C2.amount * C2.worth)

				var/datum/record/money/record = new(player.key, player.job, cashscore)
				rich_escapes += record

				if(cashscore > score["richestcash"])
					score["richestcash"] = cashscore
					score["richestname"] = player.real_name
					score["richestjob"] = player.job
					score["richestkey"] = player.key
				dmgscore = player.bruteloss + player.fireloss + player.toxloss + player.oxyloss
				if(dmgscore > score["dmgestdamage"])
					score["dmgestdamage"] = dmgscore
					score["dmgestname"] = player.real_name
					score["dmgestjob"] = player.job
					score["dmgestkey"] = player.key

	var/datum/persistence_task/highscores/leaderboard = score["money_leaderboard"]
	leaderboard.insert_records(rich_escapes)

	/*

	var/nukedpenalty = 1000
	if(ticker.mode.config_tag == "nuclear")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
			if(!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if(T && istype(T.loc, /area/security/brig))
				score["arrested"]++
			else if(M.current.stat == DEAD)
				score["opkilled"]++
		if(foecount == score["arrested"])
			score["allarrested"] = 1

		score["disc"] = 1
		for(var/obj/item/weapon/disk/nuclear/A in world)
			if(A.loc != /mob/living/carbon)
				continue
			var/turf/location = get_turf(A.loc)
			var/area/bad_zone1 = locate(/area)
			var/area/bad_zone2 = locate(/area/syndicate_station)
			var/area/bad_zone3 = locate(/area/wizard_station)
			if(location in bad_zone1)
				score["disc"] = 0
			if(location in bad_zone2)
				score["disc"] = 0
			if(location in bad_zone3)
				score["disc"] = 0
			if(A.loc.z != map.zMainStation)
				score["disc"] = 0

		if(score["nuked"])
			nukedpenalty = 50000 //Congratulations, your score was nuked

			for(var/obj/machinery/nuclearbomb/nuke in machines)
				if(nuke.r_code == "Nope")
					continue
				var/turf/T = get_turf(nuke)
				if(istype(T, /area/syndicate_station) || istype(T, /area/wizard_station) || istype(T, /area/solar))
					nukedpenalty = 1000
				else if(istype(T, /area/security/main) || istype(T, /area/security/brig) || istype(T, /area/security/armory) || istype(T, /area/security/checkpoint2))
					nukedpenalty = 50000
				else if(istype(T, /area/engine))
					nukedpenalty = 100000
				else
					nukedpenalty = 10000


	if(ticker.mode.config_tag == "revolution")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			foecount++
			if(!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if(istype(T.loc, /area/security/brig))
				score["arrested"]++
			else if (M.current.stat == DEAD)
				score["opkilled"]++
		if(foecount == score["arrested"])
			score["allarrested"] = 1
		for(var/mob/living/carbon/human/player in mob_list)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if(player.stat == DEAD)
						score["deadcommand"]++

	*/

	//Check station's power levels
	var/skip_power_loss = 0
	for(var/datum/event/grid_check/check in events)
		if(check.activeFor > check.startWhen && check.activeFor < check.endWhen)
			skip_power_loss = 1
	if(!skip_power_loss)
		for(var/obj/machinery/power/apc/A in power_machines)
			if(A.z != map.zMainStation)
				continue
			for(var/obj/item/weapon/cell/C in A.contents)
				if(C.percent() < 30)
					score["powerloss"]++ //Enough to auto-cut equipment, so alarm
	for(var/datum/powernet/PN in powernets)
		if(PN.avail > score["maxpower"])
			score["maxpower"] = PN.avail

	var/roundlength = world.time/10 //Get a value in seconds
	score["time"] = round(roundlength) //One point for every five seconds. One minute is 12 points, one hour 720 points

	//Check how many uncleaned mess are on the station. We can't run through cleanable for reasons, so yeah, long
	for(var/obj/effect/decal/cleanable/M in decals)
		if(M.z != STATION_Z) //Won't work on multi-Z stations, but will do for now
			continue
		if(M.messcheck())
			score["mess"]++

	for(var/obj/item/trash/T in trash_items)
		if(T.z != STATION_Z) //Won't work on multi-Z stations, but will do for now
			continue
		var/area/A = get_area(T)
		if(istype(A,/area/surface/junkyard))
			continue
		score["litter"]++

	for(var/mob/living/simple_animal/SA in dead_mob_list)
		if(SA.is_pet)
			score["deadpets"]++

	//Bonus Modifiers
	//--General--
	//var/traitorwins = score["traitorswon"]
	var/deathpoints = score["deadcrew"] * 250 //Human beans aren't free
	var/siliconpoints = score["deadsilicon"] * 500 //Silicons certainly aren't either
	//var/researchpoints = score["researchdone"] * 20 //One discovered design is 20 points. You'll usually find hundreds
	var/eventpoints = score["eventsendured"] * 200 //Events fine every 10 to 15 and are uncommon
	var/escapoints = score["escapees"] * 100 //Two rescued human beans are worth a dead one

	//--Service--
	var/harvests = score["stuffharvested"] * 1 //One harvest is one product. So 5 wheat is 5 points
	var/meals = score["meals"] * 5 //Every item cooked (needs to fire make_food()) awards five points
	//var/drinks = score["drinks"] * 5 //All drinks that ever existed award five points. No better way to do it yet
	var/litter = score["litter"] //Every item listed under /obj/item/trash will cost one point if it exists
	var/messpoints
	if(score["mess"] != 0)
		messpoints = score["mess"] //If there are any messes, let's count them

	//--Supply--
	var/shipping = score["stuffshipped"] * 100 //Centcom Orders fulfilled
	var/plasmashipped = score["plasmashipped"] * 0.5 //Plasma Sheets shipped
	var/mining = score["oremined"] * 1 //Not actually counted at mining, but at processing. One ore smelted is one point

	//--Engineering--
	var/power = score["powerloss"] * 50 //Power issues are BAD, they mean the Engineers aren't doing their job at all
	var/time = round(score["time"] * 0.2) //Every five seconds the station survives is one point. One minute is 12, one hour 720
	//var/atmos
	//if(score["airloss"] != 0)
		//atmos = score["airloss"] * 20 //Air issues are bad, but since it's space, don't stress it too much

	//--Medical--
	//var/beneficialpoints = score["disease_good"] * 20
	score["disease_vaccine"] = ""
	for (var/antigen in all_antigens)
		if (isolated_antibodies[antigen] == 1)
			score["disease_vaccine"] += "[antigen]"
			if (antigen in blood_antigens)
				score["disease_vaccine_score"] += 10
			else if (antigen in common_antigens)
				score["disease_vaccine_score"] += 30
			else if (antigen in rare_antigens)
				score["disease_vaccine_score"] += 50
			else if (antigen in alien_antigens)
				score["disease_vaccine_score"] += 100
		else
			score["disease_vaccine"] += "-"

	if (score["disease_vaccine_score"] == 580)
		score["disease_vaccine_score"] = 1000

	var/plaguepoints = score["disease_bad"] * 50 //A diseased crewman is half-dead, as they say, and a double diseased is double half-dead

	//--Science--
	var/artifacts = score["artifacts"] * 400 //How many large artifacts were analyzed and activated


	/*//Mode Specific
	if(ticker.mode.config_tag == "nuclear")
		if(score["disc"])
			score["crewscore"] += 500
		var/killpoints = score["opkilled"] * 250
		var/arrestpoints = score["arrested"] * 1000
		score["crewscore"] += killpoints
		score["crewscore"] += arrestpoints
		//if(score["nuked"])
			//score["crewscore"] -= nukedpenalty

	if(ticker.mode.config_tag == "revolution")
		var/arrestpoints = score["arrested"] * 1000
		var/killpoints = score["opkilled"] * 500
		var/comdeadpts = score["deadcommand"] * 500
		if(score["traitorswon"])
			score["crewscore"] -= 10000
		score["crewscore"] += arrestpoints
		score["crewscore"] += killpoints
		score["crewscore"] -= comdeadpts*/

	//Good Things
	score["crewscore"] += plasmashipped
	score["crewscore"] += shipping
	score["crewscore"] += harvests
	score["crewscore"] += mining
	score["crewscore"] += eventpoints
	score["crewscore"] += escapoints
	score["crewscore"] += meals
	score["crewscore"] += time
	score["crewscore"] += artifacts
	//score["crewscore"] += beneficialpoints
	score["crewscore"] += score["disease_vaccine_score"]
	score["crewscore"] += score["disease_effects"]

	if(!power) //No APCs with bad power
		score["crewscore"] += 2500 //Give the Engineers a pat on the back for bothering
		score["powerbonus"] = 1
	if(!messpoints && !litter) //Not a single mess or litter on station
		score["crewscore"] += 10000 //Congrats, not even a dirt patch or chips bag anywhere
		score["messbonus"] = 1
	//if(!atmos) //No air alarms anywhere
		//score["crewscore"] += 5000 //Give the Atmospheric Technicians a good pat on the back for caring
		//score["atmosbonus"] = 1
	if(score["allarrested"])
		score["crewscore"] *= 3 //This needs to be here for the bonus to be applied properly

	//Bad Things
	score["crewscore"] -= deathpoints

	var/multi = find_active_faction_by_type(/datum/faction/malf) ? 1 : -1 //Dead silicons on malf are good
	score["crewscore"] += (siliconpoints*multi)
	if(score["deadaipenalty"])
		score["crewscore"] += (1000*multi) //Give a harsh punishment for killing the AI

	score["crewscore"] -= power
	//score["crewscore"] -= atmos
	//if(score["crewscore"] != 0) //Dont divide by zero!
	//	while(traitorwins > 0)
	//		score["crewscore"] /= 2
	//		traitorwins -= 1
	score["crewscore"] -= messpoints
	score["crewscore"] -= litter
	score["crewscore"] -= plaguepoints
	score["arenafights"] = arena_rounds

	var/transfer_total = 0
	for(var/datum/money_account/A in all_money_accounts)
		for(var/datum/transaction/T in A.transaction_log)
			var/amt = text2num(T.amount)
			if(amt <= 0) // This way we don't track payouts or starting funds, only money transferred to terminals or between players
				transfer_total += abs(amt)
	score["totaltransfer"] = transfer_total

	arena_top_score = 0
	for(var/x in arena_leaderboard)
		if(arena_leaderboard[x] > arena_top_score)
			arena_top_score = arena_leaderboard[x]
	for(var/x in arena_leaderboard)
		if(arena_leaderboard[x] == arena_top_score)
			score["arenabest"] += "[x] "

	//Show the score - might add "ranks" later
	to_chat(world, "<b>The crew's final score is:</b>")
	to_chat(world, "<b><font size='4'>[score["crewscore"]]</font></b>")

	for(var/mob/E in player_list)
		if(E.client)
			E.scorestats(completions)
			winset(E.client, "rpane.round_end", "is-visible=true")
	return

/mob/proc/scorestats(var/completions)
	var/dat = completions
	dat += {"<BR><h2>Round Statistics and Score</h2>"}

	/*

	if(ticker.mode.name == "nuclear emergency")
		var/foecount = 0
		var/crewcount = 0
		var/diskdat = ""
		var/bombdat = null
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
		for(var/mob/living/C in mob_list)
			if(!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai))
				continue
			if(C.stat == DEAD)
				continue
			if(!C.client)
				continue
			crewcount++

		for(var/obj/item/weapon/disk/nuclear/N in world)
			if(!N)
				continue
			var/atom/disk_loc = N.loc
			while(!istype(disk_loc, /turf))
				if(istype(disk_loc, /mob))
					var/mob/M = disk_loc
					diskdat += "Carried by [M.real_name] "
				if(istype(disk_loc, /obj))
					var/obj/O = disk_loc
					diskdat += "in \a [O.name] "
				disk_loc = disk_loc.loc
			diskdat += "in [disk_loc.loc]"
			break // Should only need one go-round, probably

		for(var/obj/machinery/nuclearbomb/nuke in machines)
			if(nuke.r_code == "Nope")
				continue
			var/turf/T = NUKE.loc
			bombdat = T.loc
			if(istype(T,/area/syndicate_station) || istype(T,/area/wizard_station) || istype(T,/area/solar/) || istype(T,/area))
				nukedpenalty = 1000
			else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armory) || istype(T,/area/security/checkpoint2))
				nukedpenalty = 50000
			else if (istype(T,/area/engine))
				nukedpenalty = 100000
			else
				nukedpenalty = 10000
			break
		if(!diskdat)
			diskdat = "Uh oh. Something has fucked up! Report this."

		<B>Final Location of Nuke:</B> [bombdat]<BR>
		<B>Final Location of Disk:</B> [diskdat]<BR><BR>

		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Operatives:</B> [foecount]<BR>
		<B>Number of Surviving Crew:</B> [crewcount]<BR>
		<B>Final Location of Nuke:</B> [bombdat]<BR>
		<B>Final Location of Disk:</B> [diskdat]<BR><BR>
		<B>Operatives Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
		<B>Operatives Killed:</B> [score["opkilled"]] ([score["opkilled"] * 250] Points)<BR>
		<B>Station Destroyed:</B> [score["nuked"] ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
		<B>All Operatives Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}
//		<B>Nuclear Disk Secure:</B> [score["disc"] ? "Yes" : "No"] ([score["disc"] * 500] Points)<BR>

	if(ticker.mode.name == "revolution")
		var/foecount = 0
		var/comcount = 0
		var/revcount = 0
		var/loycount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			if(M.current && M.current.stat != 2)
				foecount++
		for(var/datum/mind/M in ticker.mode:revolutionaries)
			if(M.current && M.current.stat != 2)
				revcount++
		for(var/mob/living/carbon/human/player in mob_list)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if(player.stat != 2)
						comcount++
				else
					if(player.mind in ticker.mode:revolutionaries)
						continue
					loycount++
		for(var/mob/living/silicon/X in mob_list)
			if (X.stat != 2)
				loycount++
		var/revpenalty = 10000

		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
		<B>Number of Surviving Command Staff:</B> [comcount]<BR>
		<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
		<B>Number of Surviving Loyal Crew:</B> [loycount]<BR><BR>
		<B>Revolution Heads Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
		<B>Revolution Heads Slain:</B> [score["opkilled"]] ([score["opkilled"] * 500] Points)<BR>
		<B>Command Staff Slain:</B> [score["deadcommand"]] (-[score["deadcommand"] * 500] Points)<BR>
		<B>Revolution Successful:</B> [score["traitorswon"] ? "Yes" : "No"] (-[score["traitorswon"] * revpenalty] Points)<BR>
		<B>All Revolution Heads Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}

	*/

//	var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
//	<B>Beneficial diseases in living mobs:</B> [score["disease_good"]] ([score["disease_good"] * 20] Points)<BR><BR>

	dat += {"<B><U>GENERAL STATS</U></B><BR>

	<U>THE GOOD:</U><BR>
	<B>Length of Shift:</B> [round(world.time/600)] Minutes ([round(score["time"] * 0.2)] Points)<BR>
	<B>Shuttle Escapees:</B> [score["escapees"]] ([score["escapees"] * 100] Points)<BR>
	<B>Random Events Endured:</B> [score["eventsendured"]] ([score["eventsendured"] * 200] Points)<BR>
	<B>Meals Prepared:</B> [score["meals"]] ([score["meals"] * 5] Points)<BR>
	<B>Hydroponics Harvests:</B> [score["stuffharvested"]] ([score["stuffharvested"] * 1] Points)<BR>
	<B>Ultra-Clean Station:</B> [score["messbonus"] ? "Yes" : "No"] ([score["messbonus"] * 10000] Points)<BR>
	<B>Plasma Shipped:</B> [score["plasmashipped"]] ([score["plasmashipped"] * 0.5] Points)<BR>
	<B>Centcom Orders Fulfilled:</B> [score["stuffshipped"]] ([score["stuffshipped"] * 100] Points)<BR>
	<B>Ore Smelted:</B> [score["oremined"]] ([score["oremined"] * 1] Points)<BR>
	<B>Whole Station Powered:</B> [score["powerbonus"] ? "Yes" : "No"] ([score["powerbonus"] * 2500] Points)<BR>
	<B>Isolated Vaccines:</B> [score["disease_vaccine"]] ([score["disease_vaccine_score"]] Points)<BR>
	<B>Extracted Symptoms:</B> [score["disease_extracted"]] ([score["disease_effects"]] Points)<BR>
	<B>Analyzed & Activated Large Artifacts:</B> [score["artifacts"]] ([score["artifacts"] * 400] Points)<BR><BR>

	<U>THE BAD:</U><BR>
	<B>Dead Crewmen:</B> [score["deadcrew"]] (-[score["deadcrew"] * 250] Points)<BR>
	<B>Destroyed Silicons:</B> [score["deadsilicon"]] ([find_active_faction_by_type(/datum/faction/malf) ? score["deadsilicon"] * 500 : score["deadsilicon"] * -500] Points)<BR>
	<B>AIs Destroyed:</B> [score["deadaipenalty"]] ([find_active_faction_by_type(/datum/faction/malf) ? score["deadaipenalty"] * 1000 : score["deadaipenalty"] * -1000] Points)<BR>
	<B>Uncleaned Messes:</B> [score["mess"]] (-[score["mess"]] Points)<BR>
	<B>Trash on Station:</B> [score["litter"]] (-[score["litter"]] Points)<BR>
	<B>Station Power Issues:</B> [score["powerloss"]] (-[score["powerloss"] * 50] Points)<BR>
	<B>Bad diseases in living mobs:</B> [score["disease_bad"]] (-[score["disease_bad"] * 50] Points)<BR><BR>

	<U>THE WEIRD</U><BR>"}
/*	<B>Final Station Budget:</B> $[num2text(totalfunds,50)]<BR>"}
	var/profit = totalfunds - 100000
	if (profit > 0)
		dat += "<B>Station Profit:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0)
		dat += "<B>Station Deficit:</B> [num2text(profit,50)]<BR>"}*/
	dat += "<B>Food Eaten:</b> [score["foodeaten"]]<BR>"
	dat += "<B>Times a Clown was Abused:</B> [score["clownabuse"]]<BR>"
	dat += "<B>Number of Times Someone was Slipped: </B> [score["slips"]]<BR>"
	dat += "<B>Number of Explosions This Shift:</B> [score["explosions"]]<BR>"
	dat += "<B>Number of Arena Rounds:</B> [score["arenafights"]]<BR>"
	dat += "<B>Total money transferred:</B> [score["totaltransfer"]]<BR>"
	if(score["dimensionalpushes"] > 0)
		dat += "<B>Dimensional Pushes:</B> [score["dimensionalpushes"]]<BR>"
	if(score["assesblasted"] > 0)
		dat += "<B>Asses Blasted:</B> [score["assesblasted"]]<BR>"
	if(score["shoesnatches"] > 0)
		dat += "<B>Pairs of Shoes Snatched:</B> [score["shoesnatches"]]<BR>"
	if(score["buttbotfarts"] > 0)
		dat += "<B>Buttbot Farts:</B> [score["buttbotfarts"]]<BR>"
	if(score["shardstouched"] > 0)
		dat += "<B>Number of Times the Crew went Shard to Shard:</B> [score["shardstouched"]]<BR>"
	if(score["lawchanges"] > 0)
		dat += "<B>Law Upload Modules Used:</B> [score["lawchanges"]]<BR>"
	if(score["gunsspawned"] > 0)
		dat += "<B>Guns Magically Spawned:</B> [score["gunsspawned"]]<BR>"
	if(score["nukedefuse"] < 30)
		dat += "<B>Seconds Left on the Nuke When It Was Defused:</B> [score["nukedefuse"]]<BR>"
	if(score["disease_most"] != null)
		var/datum/disease2/disease/D = disease2_list[score["disease_most"]]
		var/nickname = ""
		var/dis_name = ""
		if (score["disease_most"] in virusDB)
			var/datum/data/record/v = virusDB[score["disease_most"]]
			nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
			dis_name = v.fields["name"]
		dat += "<B>Most Spread Disease:</B> [dis_name ? "[dis_name]":"[D.form] #[add_zero("[D.uniqueID]", 4)]-[add_zero("[D.subID]", 4)]"][nickname] (Origin: [D.origin], Strength: [D.strength]%, spread among [score["disease_most_count"]] mobs)<BR>"
		for(var/datum/disease2/effect/e in D.effects)
			dat += "&#x25CF; Stage [e.stage] - <b>[e.name]</b><BR>"
	if(weathertracker.len && map.climate)
		dat += "<B>Climate Composition: ([map.climate])</B> "
		//first, total ticks
		var/totalticks = total_list(get_list_of_elements(weathertracker))
		for(var/element in weathertracker)
			dat += "[element] ([round(weathertracker[element]*100/totalticks)]%) "
		dat += "<BR>"

	//Vault and away mission specific scoreboard elements
	//The process_scoreboard() proc returns a list of strings associated with their score value (the number that's added to the total score)
	for(var/datum/map_element/ME in map_elements)
		var/list/L = ME.process_scoreboard()
		if(!L || !L.len)
			continue

		dat += "<br><u>[ME.name ? uppertext(ME.name) : "UNKNOWN SPACE STRUCTURE"]</u><br>"

		for(var/score_value in L)
			dat += "<b>[score_value]</b>[L[score_value] ? "<b>:</b> [L[score_value]]" : ""]<br>"
			score["crewscore"] += L[score_value]
		dat += "<br>"

	if(arena_top_score)
		dat += "<B>Best Arena Fighter (won [arena_top_score] rounds!):</B> [score["arenabest"]]<BR>"

	if(score["escapees"])
		if(score["dmgestdamage"])
			dat += "<B>Most Battered Escapee:</B> [score["dmgestname"]], [score["dmgestjob"]]: [score["dmgestdamage"]] damage ([score["dmgestkey"]])<BR>"
		if(score["richestcash"])
			dat += "<B>Richest Escapee:</B> [score["richestname"]], [score["richestjob"]]: $[score["richestcash"]] ([score["richestkey"]])<BR>"
	else
		dat += "The station wasn't evacuated or there were no survivors!<BR>"

	dat += "<B>Department Leaderboard:</B><BR>"
	var/list/dept_leaderboard = get_dept_leaderboard()
	for (var/i = 1 to dept_leaderboard.len)
		dat += "<B>#[i] - </B>[dept_leaderboard[i]] ($[dept_leaderboard[dept_leaderboard[i]]])<BR>"

	dat += {"<HR><BR>

	<B><U>FINAL SCORE: [score["crewscore"]]</U></B><BR>"}
	score["rating"] = "A Rating"

	switch(score["crewscore"])
		if(-INFINITY to -50000)
			score["rating"] = "Even the Singularity Deserves Better"
		if(-49999 to -5000)
			score["rating"] = "Singularity Fodder"
		if(-4999 to -1000)
			score["rating"] = "You're All Fired"
		if(-999 to -500)
			score["rating"] = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250)
			score["rating"] = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100)
			score["rating"] = "Outclassed by Lab Monkeys"
		if(-99 to -21)
			score["rating"] = "The Undesirables"
		if(-20 to -1)
			score["rating"] = "Not So Good"
		if(0)
			score["rating"] = "Nothing of Value"
		if(1 to 20)
			score["rating"] = "Ambivalently Average"
		if(21 to 99)
			score["rating"] = "Not Bad, but Not Good"
		if(100 to 249)
			score["rating"] = "Skillful Servants of Science"
		if(250 to 499)
			score["rating"] = "Best of a Good Bunch"
		if(500 to 999)
			score["rating"] = "Lean Mean Machine Thirteen"
		if(1000 to 4999)
			score["rating"] = "Promotions for Everyone"
		if(5000 to 9999)
			score["rating"] = "Ambassadors of Discovery"
		if(10000 to 49999)
			score["rating"] = "The Pride of Science Itself"
		if(50000 to INFINITY)
			score["rating"] = "Nanotrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score["rating"]]<br><br>"

	var/datum/persistence_task/highscores/leaderboard = score["money_leaderboard"]
	dat += "<b>TOP 5 RICHEST ESCAPEES:</b><br>"
	if(!leaderboard.data.len)
		dat += "Nobody has set up a rich escape yet."
	else
		var/i = 1
		for(var/datum/record/money/entry in leaderboard.data)
			var/cash = num2text(entry.cash, 12)
			dat += "[i++]) <b>$[cash]</b> by <b>[entry.ckey]</b> ([entry.role]). That shift lasted [entry.shift_duration]. Date: [entry.date]<br>"

	for(var/i = 1; i <= end_icons.len; i++)
		src << browse_rsc(end_icons[i],"logo_[i].png")

	if(!endgame_info_logged) //So the End Round info only gets logged on the first player.
		endgame_info_logged = 1
		round_end_info = dat
		log_game(dat)

		stat_collection.crew_score = score["crewscore"]

	var/datum/browser/popup = new(src, "roundstats", "Round End Summary", 1000, 600)
	popup.set_content(dat)
	popup.open()

	return

/datum/achievement
    var/item
    var/ckey
    var/mob_name
    var/award_name
    var/award_desc

/datum/achievement/New(var/item, var/ckey, var/mob_name, var/award_name, var/award_desc)
	src.item = item
	src.ckey = ckey
	src.mob_name = mob_name
	src.award_name = award_name
	src.award_desc = award_desc
