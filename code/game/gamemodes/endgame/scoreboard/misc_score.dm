/datum/controller/gameticker/scoreboard/proc/misc_score()
	var/completions = ""

	//Painting
	var/list/gallery = score.global_paintings
	var/painting_completions = ""
	if(gallery.len) //the list of all artworks
		var/list/artworks = list() //list of authors, for sorting later
		for(var/obj/structure/painting/custom/painting in gallery)
			if(painting.painting_data.show_on_scoreboard && !painting.painting_data.is_blank())
				var/painting_author = painting.painting_data.author
				if(!painting_author)
					painting_author = "Anonymous"
				if(!artworks[painting_author])
					artworks[painting_author] = list()
				artworks[painting_author] += painting

		var/list/sorted_artists_list = sortList(artworks)
		var/currentartist = ""

		for(var/artistsandworks in sorted_artists_list) //list of lists of paintings
			var/tooble = ""
			var/row1 = ""
			var/row2 = ""
			var/list/artist_and_their_works = sorted_artists_list[artistsandworks]
			for(var/obj/structure/painting/custom/painting in artist_and_their_works)
				var/title = painting.painting_data.title
				if(!title)
					title = "Nameless"
				var/icon/flat = getFlatIcon(painting)
				row1 += {"<td><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'></td>"}
				row2 += {"<td>"[title]"</td>"}

			tooble += {"<tr>[row1]</tr><tr>[row2]</tr>"}
			if(artistsandworks != currentartist)
				currentartist = artistsandworks
				painting_completions += {"<h3>[artistsandworks]</h3>"}
				painting_completions += {"<table>[tooble]</table>"}

		completions += "<h2>Artisans and their artworks</h2>"
		completions += painting_completions
		completions += "<HR>"

	if(bomberman_mode)
		completions += "<br>[bomberman_declare_completion()]"

	if(ticker.achievements.len)
		completions += "<br>[achievement_declare_completion()]"

	score.money_leaderboard = SSpersistence_misc.tasks["/datum/persistence_task/highscores"]
	score.shoal_leaderboard = SSpersistence_misc.tasks["/datum/persistence_task/highscores/trader"]
	var/list/rich_escapes = list()
	var/list/rich_shoals = list()

	for(var/mob/living/player in player_list)
		if(player.stat == DEAD)
			continue
		var/turf/T = get_turf(player)
		if(!T)
			continue
		if(istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
			score.escapees++
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

			if(cashscore > score.richestcash)
				score.richestcash = cashscore
				score.richestname = player.real_name
				score.richestjob = player.job
				score.richestkey = player.key
			dmgscore = player.bruteloss + player.fireloss + player.toxloss + player.oxyloss
			if(dmgscore > score.dmgestdamage)
				score.dmgestdamage = dmgscore
				score.dmgestname = player.real_name
				score.dmgestjob = player.job
				score.dmgestkey = player.key
		if(trader_account)
			var/shoal_amount = 0
			for(var/datum/transaction/TR in trader_account.transaction_log)
				if(TR.source_name == player.real_name)
					shoal_amount += text2num(TR.amount)
			if(shoal_amount > 0)
				var/datum/record/money/record = new(player.key, player.job, shoal_amount)
				rich_shoals += record
				if(shoal_amount > score.biggestshoalcash)
					score.biggestshoalcash = shoal_amount
					score.biggestshoalname = player.real_name
					score.biggestshoalkey = player.key
		if(player.hangman_score > score.hangmanrecord)
			score.hangmanrecord = player.hangman_score
			score.hangmanname = player.real_name
			score.hangmanjob = player.job
			score.hangmankey = player.key
		if(player.job == "Clown")
			for(var/thing in player.attack_log)
				if(findtext(thing, "<font color='orange'>")) //I just dropped 10 IQ points from seeing this
					score.clownabuse++
	//Money
	var/datum/persistence_task/highscores/leaderboard = score.money_leaderboard
	leaderboard.insert_records(rich_escapes)
	var/datum/persistence_task/highscores/trader/leaderboard2 = score.shoal_leaderboard
	leaderboard2.insert_records(rich_shoals)

	var/transfer_total = 0
	for(var/datum/money_account/A in all_money_accounts)
		for(var/datum/transaction/T in A.transaction_log)
			var/amt = text2num(T.amount)
			if(amt <= 0) // This way we don't track payouts or starting funds, only money transferred to terminals or between players
				transfer_total += abs(amt)

	score.totaltransfer = transfer_total

	for(var/mob/living/simple_animal/SA in dead_mob_list)
		if(SA.is_pet)
			score.deadpets++

	score.time = round(world.time/10) //One point for every five seconds. One minute is 12 points, one hour 720 points
	if(is_research_fully_archived())
		score.crewscore += 1800
	score.crewscore -= score.deadcrew * 250 //Human beans aren't free
	score.crewscore += score.eventsendured * 200 //Events fine every 10 to 15 and are uncommon
	score.crewscore += score.escapees * 100 //Two rescued human beans are worth a dead one
	score.arenafights = arena_rounds

	arena_top_score = 0
	for(var/x in arena_leaderboard)
		if(arena_leaderboard[x] > arena_top_score)
			arena_top_score = arena_leaderboard[x]
	for(var/x in arena_leaderboard)
		if(arena_leaderboard[x] == arena_top_score)
			score.arenabest += "[x] "

	return completions
