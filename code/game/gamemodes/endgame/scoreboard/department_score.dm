/datum/controller/gameticker/scoreboard/proc/medbay_score()
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
						score.disease_good++
		else
			for (var/mob/living/L in mob_list)
				if(!L.mind) //No ballooning the negative score with infected monkeymen
					continue
				if (ID in L.virus2)
					disease_spread_count++
					if (L.stat != DEAD)
						score.disease_bad++

		if (disease_spread_count > score.disease_most_count)
			score.disease_most_count = disease_spread_count
			score.disease_most = ID
	/*for(var/mob/living/carbon/human/I in mob_list)

		if(I.viruses) //Do this guy have any viruses ?
			for(var/datum/disease/D in I.viruses) //Alright, start looping through those viruses
				score.scores["disease"]++ //One point for every disease
	*/
	//var/beneficialpoints = score.scores["disease_good"] * 20
	score.disease_vaccine = ""
	for (var/antigen in all_antigens)
		if (isolated_antibodies[antigen] == 1)
			score.disease_vaccine += "[antigen]"
			if (antigen in blood_antigens)
				score.disease_vaccine_score += 40
			else if (antigen in common_antigens)
				score.disease_vaccine_score += 120
			else if (antigen in rare_antigens)
				score.disease_vaccine_score += 200
			else if (antigen in alien_antigens)
				score.disease_vaccine_score += 400
		else
			score.disease_vaccine += "-"

	if (score.disease_vaccine_score == 2320)
		score.disease_vaccine_score = 3000 // panacea bonus

	//crewscore
	score.crewscore -= score.disease_bad * 50 //A diseased crewman is half-dead, as they say, and a double diseased is double half-dead
	score.crewscore += score.disease_vaccine_score
	score.crewscore += score.disease_effects

/datum/controller/gameticker/scoreboard/proc/engineering_score()
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
					score.powerloss++ //Enough to auto-cut equipment, so alarm
	for(var/datum/powernet/PN in powernets)
		if(PN.avail > score.maxpower)
			score.maxpower = PN.avail
	//var/atmos
	//if(score.scores["airloss"] != 0)
		//atmos = score.scores["airloss"] * 20 //Air issues are bad, but since it's space, don't stress it too much
	//if(!atmos) //No air alarms anywhere
		//score.crewscore += 5000 //Give the Atmospheric Technicians a good pat on the back for caring
		//score.scores["atmosbonus"] = 1

	if(!score.powerloss) //No APCs with bad power
		score.powerbonus = 2500

	//crewscore
	score.crewscore -= score.powerloss * 50 //Power issues are BAD, they mean the Engineers aren't doing their job at all
	score.crewscore += score.powerbonus
	//score.crewscore -= atmos

/datum/controller/gameticker/scoreboard/proc/service_score()
	//Janitor
	//Check how many uncleaned mess are on the station. We can't run through cleanable for reasons, so yeah, long
	for(var/obj/effect/decal/cleanable/M in decals)
		if(M.z != map.zMainStation) //Won't work on multi-Z stations, but will do for now
			continue
		if(M.messcheck())
			score.mess++
	for(var/obj/item/trash/T in trash_items)
		if(T.z != map.zMainStation) //Won't work on multi-Z stations, but will do for now
			continue
		var/area/A = get_area(T)
		if(istype(A,/area/surface/junkyard))
			continue
		score.litter++
	if(score.mess < 5 && score.litter < 5) //Not a single mess or litter on station
		score.messbonus = 5000

	//crewscore
	score.crewscore += score.meals * 5 //Every item cooked (needs to fire make_food()) awards five points
	//score.crewscore += score.scores["drinks"] * 5 //All drinks that ever existed award five points. No better way to do it yet
	score.crewscore += score.stuffharvested //One harvest is one product. So 5 wheat is 5 points
	score.crewscore -= score.mess //If there are any messes, let's count them
	score.crewscore -= score.litter //Every item listed under /obj/item/trash will cost one point if it exists
	score.crewscore += score.messbonus //Congrats, not even a dirt patch or chips bag anywhere

/datum/controller/gameticker/scoreboard/proc/supply_score()
	score.crewscore += score.stuffshipped * 100 //Centcom Orders fulfilled
	score.crewscore += score.plasmashipped * 0.5 //Plasma Sheets shipped
	score.crewscore += score.stuffforwarded * 50 //Cargo Crates forwarded
	score.crewscore -= score.stuffnotforwarded * 25 //Cargo Crates not forwarded
	score.crewscore += score.oremined //Not actually counted at mining, but at processing. One ore smelted is one point

/datum/controller/gameticker/scoreboard/proc/science_score()
	//var/researchpoints = score.scores["researchdone"] * 20 //One discovered design is 20 points. You'll usually find hundreds
	score.crewscore += score.slimes * 20 //How many slimes were harvested
	score.crewscore += score.artifacts * 400 //How many large artifacts were analyzed and activated

/datum/controller/gameticker/scoreboard/proc/silicon_score()
	var/ai_completions = ""
	var/completions
	for(var/mob/living/silicon/ai/ai in mob_list)
		var/icon/flat = getFlatIcon(ai)
		if(ai.stat != 2)
			ai_completions += {"<br><b><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> [ai.name] (Played by: [get_key(ai)])'s laws at the end of the game were:</b>"}
		else
			ai_completions += {"<br><b><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> [ai.name] (Played by: [get_key(ai)])'s laws when it was deactivated were:</b>"}
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
		if (!robo.connected_ai)
			if (robo.stat != 2)
				ai_completions += {"<br><b><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> [robo.name] (Played by: [get_key(robo)]) survived as an AI-less [isMoMMI(robo)?"MoMMI":"borg"]! Its laws were:</b>"}
			else
				ai_completions += {"<br><b><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> [robo.name] (Played by: [get_key(robo)]) was unable to survive the rigors of being a [isMoMMI(robo)?"MoMMI":"cyborg"] without an AI. Its laws were:</b>"}
		else
			ai_completions += {"<br><b><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> [robo.name] (Played by: [get_key(robo)]) [robo.stat!=2?"survived":"perished"] as a [isMoMMI(robo)?"MoMMI":"cyborg"] slaved to [robo.connected_ai]! Its laws were:</b>"}
		ai_completions += "<br>[robo.write_laws()]"

	for(var/mob/living/silicon/pai/pAI in mob_list)
		var/icon/flat = getFlatIcon(pAI)
		ai_completions += {"<br><b><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> [pAI.name] (Played by: [get_key(pAI)]) [pAI.stat!=2?"survived":"perished"] as a pAI whose master was [pAI.master]! Its directives were:</b><br>[pAI.write_directives()]"}

	var/siliconpoints = score.deadsilicon * 500 //Silicons certainly aren't either
	var/multi = find_active_faction_by_type(/datum/faction/malf) ? 1 : -1 //Dead silicons on malf are good
	score.crewscore += (siliconpoints*multi)
	if(score.deadaipenalty)
		score.crewscore += 1000*multi //Give a harsh punishment for killing the AI

	if(ai_completions)
		completions += "<h2>Silicons Laws</h2>"
		completions += ai_completions
		completions += "<HR>"
		return completions
