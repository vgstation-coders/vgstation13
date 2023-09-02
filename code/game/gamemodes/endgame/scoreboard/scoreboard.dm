var/global/datum/controller/gameticker/scoreboard/score = new()

/datum/controller/gameticker/scoreboard
	var/crewscore 			= 0 //This is the overall var/score for the whole round
	var/plasmashipped		= 0 //How much plasma has been sent to centcom?
	var/stuffshipped		= 0 //How many centcom orders have cargo fulfilled?
	var/stuffforwarded		= 0 //How many cargo forwards have been fulfilled?
	var/stuffnotforwarded	= 0 //How many cargo forwards have not been fulfilled?
	var/stuffharvested		= 0 //How many harvests have hydroponics done (per crop)?
	var/oremined			= 0 //How many chunks of ore were smelted
	var/eventsendured		= 0 //How many random events did the station endure?
	var/powerloss			= 0 //How many APCs have alarms (under 30 %)?
	var/atmoloss			= 0 //How many air alarms are giving issues?
	var/maxpower			= 0 //Most watts in grid on any of the world's powergrids.
	var/escapees			= 0 //How many people got out alive?
	var/deadcrew			= 0 //Humans who died during the round
	var/deadsilicon			= 0 //Silicons who died during the round
	var/mess				= 0 //How much messes on the floor went uncleaned
	var/litter				= 0 //How much trash is laying on the station floor
	var/meals				= 0 //How much food was actively cooked that day
	var/slimes				= 0 //How many slimes were harvested
	var/artifacts			= 0 //How many large artifacts were analyzed and activated
	var/disease_good		= 0 //How many unique diseases currently affecting living mobs of cumulated danger <3
	var/disease_vaccine		= null //Which many vaccine antibody isolated
	var/disease_vaccine_score= 0 //the associated score
	var/disease_extracted	= 0 //Score based on the unique extracted effects
	var/disease_effects		= 0 //Score based on the unique extracted effects
	var/disease_bad			= 0 //How many unique diseases currently affecting living mobs of cumulated danger >= 3
	var/disease_most		= null //Most spread disease
	var/disease_most_count	= 0 //Most spread disease

	//These ones are mainly for the stat panel
	var/powerbonus			= 0 //If all APCs on the station are running optimally, big bonus
	var/atmobonus			= 0 //If all air alarms on the station are running optimally, big bonus
	var/messbonus			= 0 //If there are no messes on the station anywhere, huge bonus
	var/deadaipenalty		= 0 //AIs who died during the round
	var/foodeaten			= 0 //How much food was consumed
	var/clownabuse			= 0 //How many times a clown was punched, struck or otherwise maligned
	var/slips				= 0 //How many people have slipped during this round
	var/gunsspawned			= 0 //Guns spawned by the Summon Guns spell. Only guns, not other artifacts.
	var/dimensionalpushes	= 0 //Amount of times a wizard casted Dimensional Push.
	var/assesblasted		= 0 //Amount of times a wizard casted Buttbot's Revenge.
	var/shoesnatches		= 0 //Amount of shoes magically snatched.
	var/greasewiz			= 0 //Amount of times a wizard casted Grease.
	var/lightningwiz		= 0 //Amount of times a wizard casted Lighting.
	var/random_soc			= 0 //Staff of Change bolts set to "random" that hit a human.
	var/heartattacks		= 0 //Amount of times the "Heart Attack" virus reached final stage, unleashing a hostile floating heart.
	var/hangmanname			= null //Player with most correct letter guesses from Curse of the Hangman
	var/hangmanjob			= null
	var/hangmanrecord		= 0
	var/hangmankey			= null
	var/richestname			= null //This is all stuff to show who was the richest alive on the shuttle
	var/richestjob			= null  //Kinda pointless if you dont have a money system i guess
	var/richestcash			= 0
	var/richestkey			= null
	var/biggestshoalname	= null
	var/biggestshoalcash	= 0
	var/biggestshoalkey		= null
	var/dmgestname			= null //Who had the most damage on the shuttle (but was still alive)
	var/dmgestjob			= null
	var/dmgestdamage		= 0
	var/dmgestkey			= null
	var/explosions			= 0 //How many explosions happened total
	var/largeexplosions		= 0 // >1 devastation range
	var/largest_TTV			= 0 //The largest Tank Transfer Valve explosion this round
	var/deadpets			= 0 //Only counts 'special' simple_mobs, like Ian, Poly, Runtime, Sasha etc
	var/buttbotfarts		= 0 //Messages mimicked by buttbots.
	var/turfssingulod		= 0 //Amount of turfs eaten by singularities.
	var/shardstouched		= 0 //+1 for each pair of shards that bump into eachother.
	var/kudzugrowth			= 0 //Amount of kudzu tiles successfully grown, even if they were later eradicated.
	var/nukedefuse			= 9999 //Seconds the nuke had left when it was defused.
	var/tobacco				= 0 //Amount of cigarettes, pipes, cigars, etc. lit
	var/lawchanges			= 0 //Amount of AI modules used.
	var/syndiphrases		= 0 //Amount of times a syndicate code phrase was used
	var/syndisponses		= 0 //Amount of times a syndicate code response was used
	var/arenafights			= 0
	var/arenabest			= null
	var/rating				= 0
	var/time				= 0
	var/totaltransfer		= 0
	var/turfsonfire			= 0
	var/shuttlebombed		= 0
	var/bagelscooked		= 0
	var/disease				= 0
	var/list/money_leaderboard = list()
	var/list/shoal_leaderboard = list()
	var/list/implant_phrases = list()
	var/list/global_paintings = list()

/datum/controller/gameticker/scoreboard/proc/main(var/dat)
	var/datum/faction/syndicate/nuke_op/NO = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	var/datum/faction/revolution/RV = find_active_faction_by_type(/datum/faction/revolution)

	ticker.mode.declare_completion()
	dat += "[ticker.mode.dat]<HR>"

	//populate scores
	dat += medbay_score()
	dat += engineering_score()
	dat += service_score()
	dat += supply_score()
	dat += science_score()
	if(NO)
		dat += nuke_op_score(NO)
	if(RV)
		dat += revolution_score(RV)
	dat += syndicate_score()
	dat += silicon_score()
	dat += misc_score()
	dat += display()

	round_end_info = dat
	round_end_info_no_img = remove_images(dat)
	log_game(round_end_info_no_img)
	stat_collection.crew_score = score.crewscore

	to_chat(world, "<b>The crew's final score is:</b>")
	to_chat(world, "<b><font size='4'>[score.crewscore]</font></b>")

	for(var/mob/E in player_list)
		E.display_round_end_scoreboard()

	ticker.mode.send2servers()
	return

/datum/controller/gameticker/scoreboard/proc/display()
	var/dat = "<h2>Round Statistics and Score</h2>"
	dat += "<U>THE GOOD:</U><BR>"
	dat += "<B>Length of Shift:</B> [round(world.time/600)] Minutes ([round(score.time * 0.2)] Points)<BR>"
	dat += "<B>Shuttle Escapees:</B> [score.escapees] ([score.escapees * 100] Points)<BR>"
	if(score.eventsendured > 0)
		dat += "<B>Random Events Endured:</B> [score.eventsendured] ([score.eventsendured * 200] Points)<BR>"
	if(score.meals > 0)
		dat += "<B>Meals Prepared:</B> [score.meals] ([score.meals * 5] Points)<BR>"
	if(score.stuffharvested > 0)
		dat += "<B>Hydroponics Harvests:</B> [score.stuffharvested] ([score.stuffharvested] Points)<BR>"
	dat += "<B>Ultra-Clean Station:</B> [score.messbonus ? "Yes" : "No"] ([score.messbonus] Points)<BR>"
	if(score.plasmashipped > 0)
		dat += "<B>Plasma Shipped:</B> [score.plasmashipped] ([score.plasmashipped * 0.5] Points)<BR>"
	if(score.stuffshipped > 0)
		dat += "<B>Centcom Orders Fulfilled:</B> [score.stuffshipped] ([score.stuffshipped * 100] Points)<BR>"
	if(score.stuffforwarded > 0)
		dat += "<B>Cargo Crates Forwarded:</B> [score.stuffforwarded] ([score.stuffforwarded * 50] Points)<BR>"
	if(score.oremined > 0)
		dat += "<B>Ore Smelted:</B> [score.oremined] ([score.oremined] Points)<BR>"
	dat += "<B>Whole Station Powered:</B> [score.powerbonus ? "Yes" : "No"] ([score.powerbonus] Points)<BR>"
	dat += "<B>Whole Station Airtight:</B> [score.atmobonus ? "Yes" : "No"] ([score.atmobonus] Points)<BR>"
	if (score.disease_vaccine_score > 0)
		dat += "<B>Isolated Vaccines:</B> [score.disease_vaccine] ([score.disease_vaccine_score] Points)<BR>"
	if (score.disease_extracted > 0)
		dat += "<B>Extracted Symptoms:</B> [score.disease_extracted] ([score.disease_effects] Points)<BR>"
	if(score.disease_good > 0)
		dat += "<B>Good diseases in living mobs:</B> [score.disease_good] ([score.disease_good * 20] Points)<BR>"
	if (score.slimes > 0)
		dat += "<B>Harvested Slimes:</B> [score.slimes] ([score.slimes * 20] Points)<BR>"
	if (score.artifacts > 0)
		dat += "<B>Analyzed & Activated Large Artifacts:</B> [score.artifacts] ([score.artifacts * 400] Points)<BR>"

	dat += "<BR><U>THE BAD:</U><BR>"
	if (score.deadcrew > 0)
		dat += "<B>Dead Crewmen:</B> [score.deadcrew] (-[score.deadcrew * 250] Points)<BR>"
	if (score.deadsilicon > 0)
		dat += "<B>Destroyed Silicons:</B> [score.deadsilicon] ([find_active_faction_by_type(/datum/faction/malf) ? score.deadsilicon * 500 : score.deadsilicon * -500] Points)<BR>"
	if (score.deadaipenalty > 0)
		dat += "<B>AIs Destroyed:</B> [score.deadaipenalty] ([find_active_faction_by_type(/datum/faction/malf) ? score.deadaipenalty * 1000 : score.deadaipenalty * -1000] Points)<BR>"
	dat += "<B>Uncleaned Messes:</B> [score.mess] (-[score.mess] Points)<BR>"
	dat += "<B>Trash on Station:</B> [score.litter] (-[score.litter] Points)<BR>"
	if(score.stuffnotforwarded > 0)
		dat += "<B>Cargo Crates Not Forwarded:</B> [score.stuffnotforwarded] (-[score.stuffnotforwarded * 25] Points)<BR>"
	if (score.powerloss > 0)
		dat += "<B>Station Power Issues:</B> [score.powerloss] (-[score.powerloss * 50] Points)<BR>"
	if (score.atmoloss > 0)
		dat += "<B>Station Atmospheric Issues:</B> [score.atmoloss] (-[score.atmoloss * 50] Points)<BR>"
	if(score.turfssingulod > 0)
		dat += "<B>Tiles destroyed by a singularity:</B> [score.turfssingulod] (-[round(score.turfssingulod/2)] Points)<BR>"
	if(score.disease_bad > 0)
		dat += "<B>Bad diseases in living mobs:</B> [score.disease_bad] (-[score.disease_bad * 50] Points)<BR>"

	dat += "<BR><U>THE WEIRD</U><BR>"
/*	<B>Final Station Budget:</B> $[num2text(totalfunds,50)]<BR>"
	var/profit = totalfunds - 100000
	if (profit > 0)
		dat += "<B>Station Profit:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0)
		dat += "<B>Station Deficit:</B> [num2text(profit,50)]<BR>"*/
	if(score.foodeaten > 0)
		dat += "<B>Food Eaten:</b> [score.foodeaten]<BR>"
	if(score.clownabuse > 0)
		dat += "<B>Times a Clown was Abused:</B> [score.clownabuse]<BR>"
	if(score.slips > 0)
		dat += "<B>Number of Times Someone was Slipped: </B> [score.slips]<BR>"
	if(score.explosions > 0)
		dat += "<B>Number of Explosions This Shift:</B> [score.explosions]<BR>"
	if(score.largest_TTV > 0)
		dat += "<B>Largest Tank Transfer Valve Explosion:</B> [round(score.largest_TTV*0.25)] / [round(score.largest_TTV*0.5)] / [round(score.largest_TTV)][(score.largest_TTV >= MAX_EXPLOSION_RANGE) ? " (That's a maxcap right there. Not bad!)" : ""]<BR>"
	if(score.arenafights > 0)
		dat += "<B>Number of Arena Rounds:</B> [score.arenafights]<BR>"
	if(score.totaltransfer > 0)
		dat += "<B>Total money transferred:</B> [score.totaltransfer]<BR>"
	if(score.dimensionalpushes > 0)
		dat += "<B>Dimensional Pushes:</B> [score.dimensionalpushes]<BR>"
	if(score.assesblasted > 0)
		dat += "<B>Asses Blasted:</B> [score.assesblasted]<BR>"
	if(score.shoesnatches > 0)
		dat += "<B>Pairs of Shoes Snatched:</B> [score.shoesnatches]<BR>"
	if(score.buttbotfarts > 0)
		dat += "<B>Buttbot Farts:</B> [score.buttbotfarts]<BR>"
	if(score.shardstouched > 0)
		dat += "<B>Number of Times the Crew went Shard to Shard:</B> [score.shardstouched]<BR>"
	if(score.lawchanges > 0)
		dat += "<B>Law Upload Modules Used:</B> [score.lawchanges]<BR>"
	if(score.gunsspawned > 0)
		dat += "<B>Guns Magically Spawned:</B> [score.gunsspawned]<BR>"
	if(score.hangmanrecord > 0)
		dat += "<B>Highest Hangman Score:</B> [score.hangmanname], [score.hangmanjob]: [score.hangmanrecord] ([score.hangmankey])<BR>"
	if(score.nukedefuse < 30)
		dat += "<B>Seconds Left on the Nuke When It Was Defused:</B> [score.nukedefuse]<BR>"
	if(score.disease_most != null)
		var/datum/disease2/disease/D = disease2_list[score.disease_most]
		var/nickname = ""
		var/dis_name = ""
		if (score.disease_most in virusDB)
			var/datum/data/record/v = virusDB[score.disease_most]
			nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
			dis_name = v.fields["name"]
		dat += "<B>Most Spread Disease:</B> [dis_name ? "[dis_name]":"[D.form] #[add_zero("[D.uniqueID]", 4)]-[add_zero("[D.subID]", 4)]"][nickname] (Origin: [D.origin], Strength: [D.strength]%, spread among [score.disease_most_count] mobs)<BR>"
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
			score.crewscore += L[score_value]
		dat += "<br>"

	if(arena_top_score)
		dat += "<B>Best Arena Fighter (won [arena_top_score] rounds!):</B> [score.arenabest]<BR>"
	if(score.escapees)
		if(score.dmgestdamage)
			dat += "<B>Most Battered Escapee:</B> [score.dmgestname], [score.dmgestjob]: [score.dmgestdamage] damage ([score.dmgestkey])<BR>"
		if(score.richestcash)
			dat += "<B>Richest Escapee:</B> [score.richestname], [score.richestjob]: $[score.richestcash] ([score.richestkey])<BR>"
	else
		dat += "The station wasn't evacuated or there were no survivors!<BR>"
	if(score.biggestshoalcash)
		dat += "<B>Most Generous Shoal Funder:</B> [score.biggestshoalname]: $[score.biggestshoalcash] ([score.biggestshoalkey])<BR>"
	dat += "<B>Department Leaderboard:</B><BR>"
	var/list/dept_leaderboard = get_dept_leaderboard()
	for (var/i = 1 to dept_leaderboard.len)
		dat += "<B>#[i] - </B>[dept_leaderboard[i]] ($[dept_leaderboard[dept_leaderboard[i]]])<BR>"

	dat += "<HR><BR>"
	dat += "<B><U>FINAL SCORE: [score.crewscore]</U></B><BR>"
	score.rating = "A Rating"

	switch(score.crewscore)
		if(-INFINITY to -50000)
			score.rating = "Even the Singularity Deserves Better"
		if(-49999 to -5000)
			score.rating = "Singularity Fodder"
		if(-4999 to -1000)
			score.rating = "You're All Fired"
		if(-999 to -500)
			score.rating = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250)
			score.rating = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100)
			score.rating = "Outclassed by Lab Monkeys"
		if(-99 to -21)
			score.rating = "The Undesirables"
		if(-20 to -1)
			score.rating = "Not So Good"
		if(0)
			score.rating = "Nothing of Value"
		if(1 to 20)
			score.rating = "Ambivalently Average"
		if(21 to 99)
			score.rating = "Not Bad, but Not Good"
		if(100 to 249)
			score.rating = "Skillful Servants of Science"
		if(250 to 499)
			score.rating = "Best of a Good Bunch"
		if(500 to 999)
			score.rating = "Lean Mean Machine Thirteen"
		if(1000 to 4999)
			score.rating = "Promotions for Everyone"
		if(5000 to 9999)
			score.rating = "Ambassadors of Discovery"
		if(10000 to 49999)
			score.rating = "The Pride of Science Itself"
		if(50000 to INFINITY)
			score.rating = "Nanotrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score.rating]<br><br>"

	var/datum/persistence_task/highscores/leaderboard = score.money_leaderboard
	dat += "<b>MONTHLY TOP 5 RICHEST ESCAPEES:</b><br>"
	var/i = 1
	for(var/datum/record/money/entry in leaderboard.data)
		var/cash = num2text(entry.cash, 12)
		var/list/split_date = splittext(entry.date, "-")
		if(text2num(split_date[2]) != text2num(time2text(world.timeofday, "MM")))
			leaderboard.clear_records()
			dat += "No rich escapees yet!"
			break
		else
			dat += "[i++]) <b>$[cash]</b> by <b>[entry.ckey]</b> ([entry.role]). That shift lasted [entry.shift_duration]. Date: [entry.date]<br>"
	var/datum/persistence_task/highscores/trader/leaderboard2 = score.shoal_leaderboard
	dat += "<br><b>MONTHLY TOP 5 RICHEST TRADERS:</b><br>"
	i = 1
	for(var/datum/record/money/entry in leaderboard2.data)
		var/cash = num2text(entry.cash, 12)
		var/list/split_date = splittext(entry.date, "-")
		if(text2num(split_date[2]) != text2num(time2text(world.timeofday, "MM")))
			leaderboard2.clear_records()
			dat += "No rich traders yet!"
			break
		else
			dat += "[i++]) <b>$[cash]</b> by <b>[entry.ckey]</b>. That shift lasted [entry.shift_duration]. Date: [entry.date]<br>"
	return dat

/mob/proc/display_round_end_scoreboard()
	if (!client)
		return

	var/datum/browser/popup = new(src, "roundstats", "Round End Summary", 1000, 600)
	popup.set_content(round_end_info)
	popup.open()

	winset(client, "rpane.round_end", "is-visible=true")
	winset(client, "rpane.last_round_end", "is-visible=false")

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
