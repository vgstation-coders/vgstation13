/datum/controller/gameticker/scoreboard/proc/syndicate_score()
	var/completions
	var/list/boombox = score.implant_phrases
	var/synphra = score.syndiphrases
	var/synspo = score.syndisponses
	if(synphra || synspo || boombox.len)
		completions += "<h2><font color='red'>Syndicate</font> Specials</h2>"
		if(synphra)
			completions += "<BR>The Syndicate code phrases were:<BR>"
			completions += "<font color='red'>[syndicate_code_phrase.Join(", ")]</font><BR>"
			completions += "The phrases were used [synphra] time[synphra > 1 ? "s" : ""]!"
		if(synspo)
			completions += "<BR>The Syndicate code responses were:<BR>"
			completions += "<font color='red'>[syndicate_code_response.Join(", ")]</font><BR>"
			completions += "The responses were used [synspo] time[synspo > 1 ? "s" : ""]!"
		if(boombox.len)
			completions += "<BR>The following explosive implants were used:<BR>"
			for(var/entry in score.implant_phrases)
				completions += "[entry]<BR>"
	return completions

/datum/controller/gameticker/scoreboard/proc/nuke_op_score(var/datum/faction/syndicate/nuke_op/NO)
	var/foecount = 0
	var/crewcount = 0
	var/diskdat = ""
	var/bombdat = null
	var/opkilled
	var/oparrested
	var/alloparrested
	var/dat
	//var/nukedpenalty = 1000
	for(var/datum/role/R in NO.members)
		foecount++
		var/datum/mind/M = R.antag
		if(!M || !M.current)
			opkilled++
			continue
		var/turf/T = M.current.loc
		if(T && istype(T.loc, /area/security/brig))
			oparrested++
		else if(M.current.stat == DEAD)
			opkilled++
	for(var/mob/living/C in player_list)
		if(!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai))
			continue
		if(C.stat == DEAD)
			continue
		if(!C.client)
			continue
		crewcount++
	if(foecount == oparrested)
		alloparrested = 1
		score.crewscore += oparrested * 2000
	score.crewscore += opkilled * 250
	score.crewscore += oparrested * 1000
	//if(score.scores["nuked"])
		//score.scores["crewscore"] -= nukedpenalty

	/*score.scores["disc"] = 1
	for(var/obj/item/weapon/disk/nuclear/A in world)
		if(A.loc != /mob/living/carbon)
			continue
		var/turf/location = get_turf(A.loc)
		var/area/bad_zone1 = locate(/area)
		var/area/bad_zone2 = locate(/area/syndicate_mothership)
		var/area/bad_zone3 = locate(/area/wizard_station)
		if(location in bad_zone1)
			score.scores["disc"] = 0
		if(location in bad_zone2)
			score.scores["disc"] = 0
		if(location in bad_zone3)
			score.scores["disc"] = 0
		if(A.loc.z != map.zMainStation)
			score.scores["disc"] = 0*/

	/*if(score.scores["nuked"])
		nukedpenalty = 50000 //Congratulations, your score was nuked

		for(var/obj/machinery/nuclearbomb/nuke in machines)
			if(nuke.r_code == "Nope")
				continue
			var/turf/T = get_turf(nuke)
			if(istype(T, /area/syndicate_mothership) || istype(T, /area/wizard_station) || istype(T, /area/solar))
				nukedpenalty = 1000
			else if(istype(T, /area/security/main) || istype(T, /area/security/brig) || istype(T, /area/security/armory) || istype(T, /area/security/checkpoint2))
				nukedpenalty = 50000
			else if(istype(T, /area/engine))
				nukedpenalty = 100000
			else
				nukedpenalty = 10000*/


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

	/*for(var/obj/machinery/nuclearbomb/nuke in machines)
		if(nuke.r_code == "Nope")
			continue
		var/turf/T = nuke.loc
		bombdat = T.loc
		if(istype(T,/area/syndicate_mothership) || istype(T,/area/wizard_station) || istype(T,/area/solar/) || istype(T,/area))
			nukedpenalty = 1000
		else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armory) || istype(T,/area/security/checkpoint2))
			nukedpenalty = 50000
		else if (istype(T,/area/engine))
			nukedpenalty = 100000
		else
			nukedpenalty = 5000
		break*/
	if(!diskdat)
		diskdat = "Uh oh. Something has fucked up! Report this."

	return dat += {"<B><U>NUCLEAR ASSAULT STATS</U></B><BR>
	<B>Number of Operatives:</B> [foecount]<BR>
	<B>Number of Surviving Crew:</B> [crewcount]<BR>
	<B>Final Location of Nuke:</B> [bombdat]<BR>
	<B>Final Location of Disk:</B> [diskdat]<BR>
	<B>Operatives Arrested:</B> [oparrested] ([oparrested * 1000] Points)<BR>
	<B>Operatives Killed:</B> [opkilled] ([opkilled * 250] Points)<BR>
	<B>All Operatives Arrested:</B> [alloparrested ? "Yes" : "No"] ([oparrested * 2000])<BR>
	<HR>"}
//		<B>Station Destroyed:</B> [score.scores["nuked"] ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
//		<B>Nuclear Disk Secure:</B> [score.scores["disc"] ? "Yes" : "No"] ([score.scores["disc"] * 500] Points)<BR>

/datum/controller/gameticker/scoreboard/proc/revolution_score(var/datum/faction/revolution/RV)
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0
	var/revarrested = 0
	var/revkilled = 0
	var/allrevarrested = 1
	var/deadcommand = 0
	var/dat
	for(var/datum/role/R in RV.members)
		if(R.antag.current && R.antag.current.stat != 2)
			if(istype(R,/datum/role/revolutionary/leader))
				foecount++
			else
				revcount++
		var/datum/mind/M = R.antag
		if(!M || !M.current)
			revkilled++
			continue
		var/turf/T = M.current.loc
		if(istype(T.loc, /area/security/brig))
			revarrested++
		else if (M.current.stat == DEAD)
			revkilled++
	for(var/mob/living/player in player_list)
		if (istype(player, /mob/living/carbon/human))
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				if(player.stat == DEAD)
					deadcommand++
				else
					comcount++
			else
				if(locate(/datum/role/revolutionary) in player.mind.antag_roles)
					continue
				loycount++
		else if(istype(player, /mob/living/silicon))
			if (player.stat != DEAD)
				loycount++
	//if(score.scores["traitorswon"])
		//score.scores["crewscore"] -= 10000
	if(foecount == revarrested)
		allrevarrested = 1
		score.crewscore += revarrested * 2000
	score.crewscore += revarrested * 1000
	score.crewscore += revkilled * 500
	score.crewscore -= deadcommand * 500

	return dat += {"<B><U>REVOLUTION STATS</U></B><BR>
	<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
	<B>Number of Surviving Command Staff:</B> [comcount]<BR>
	<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
	<B>Number of Surviving Loyal Crew:</B> [loycount]<BR>
	<B>Revolution Heads Arrested:</B> [revarrested] ([revarrested * 1000] Points)<BR>
	<B>Revolution Heads Slain:</B> [revkilled] ([revkilled * 500] Points)<BR>
	<B>Command Staff Slain:</B> [deadcommand] (-[deadcommand * 500] Points)<BR>
	<B>All Revolution Heads Arrested:</B> [allrevarrested ? "Yes" : "No"] ([revarrested * 2000]  Points)<BR>
	<HR>"}
//		<B>Revolution Successful:</B> [score.scores["traitorswon"] ? "Yes" : "No"] (-[score.scores["traitorswon"] * revpenalty] Points)<BR>