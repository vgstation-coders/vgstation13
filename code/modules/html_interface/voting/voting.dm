var/global/datum/controller/vote/vote = new()
#define vote_head "<script type=\"text/javascript\" src=\"3-jquery.timers.js\"></script><script type=\"text/javascript\" src=\"libraries.min.js\"></script><link rel=\"stylesheet\" type=\"text/css\" href=\"html_interface_icons.css\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"voting.css\" /><script type=\"text/javascript\" src=\"voting.js\"></script>"

#define VOTE_SCREEN_WIDTH 400
#define VOTE_SCREEN_HEIGHT 400
#define WEIGHTED 1
#define MAJORITY 2
#define PERSISTENT 3
#define RANDOM 4

/datum/html_interface/nanotrasen/vote/registerResources()
	. = ..()

	register_asset("voting.js", 'voting.js')
	register_asset("voting.css", 'voting.css')

/datum/html_interface/nanotrasen/vote/sendAssets(var/client/client)
	..()

	send_asset(client, "voting.js")
	send_asset(client, "voting.css")

/datum/html_interface/nanotrasen/vote/Topic(href, href_list[])
	..()
	if(href_list["html_interface_action"] == "onclose")
		var/datum/html_interface_client/hclient = getClient(usr.client)
		if (istype(hclient))
			src.hide(hclient)
			vote.cancel_vote(usr)

/datum/controller/vote
	var/initiator      = null
	var/started_time   = null
	var/time_remaining = 0
	var/mode           = null
	var/question       = null
	var/currently_voting = FALSE // If we are already voting, don't allow another one
	var/datum/html_interface/nanotrasen/vote/interface

	//vote data
	var/list/voters		//assoc. list: user.ckey, choice
	var/list/tally		//assoc. list: choices, count
	var/list/choices = list() //choices
	var/list/map_paths	//assoc. list: map.name, map.path from next_map.dm
	var/winner 		 	= null

	var/list/status_data
	var/last_update    = 0
	var/initialized    = 0
	var/lastupdate     = 0

	// Jesus fuck some shitcode is breaking because it's sleeping and the SS doesn't like it.
	var/lock = FALSE
	name               = "datum"

/datum/controller/vote/New()
	. = ..()
	src.voters = list()
	src.tally = list()
	src.status_data = list()

	spawn(5)
		if(!src.interface)
			src.interface = new/datum/html_interface/nanotrasen/vote(src, "Voting Panel", VOTE_SCREEN_WIDTH, VOTE_SCREEN_HEIGHT, vote_head)
			src.interface.updateContent("content", "<div id='vote_main'></div><div id='vote_choices'></div><div id='vote_admin'></div>")
		initialized = 1
	if (vote != src)
		if (istype(vote))
			qdel(vote)
		vote = src

/datum/controller/vote/proc/reset()
	currently_voting = FALSE
	lock = FALSE
	initiator = null
	time_remaining = 0
	mode = null
	question = null
	choices.len = 0
	voters.len = 0
	tally.len = 0
	update(1)

/datum/controller/vote/proc/process()	//called by master_controller
	if (lock)
		return
	if(mode)
		lock = TRUE
		// No more change mode votes after the game has started.
		// 3 is GAME_STATE_PLAYING, but that #define is undefined for some reason
		if(mode == "gamemode" && ticker.current_state >= 2)
			to_chat(world, "<b>Voting aborted due to game start.</b>")
			src.reset()
			return

		// Calculate how much time is remaining by comparing current time, to time of vote start,
		// plus vote duration
		if (choices.len)
			time_remaining = round((started_time + 600 - world.time)/10)
		else
			time_remaining = round((started_time + config.vote_period - world.time)/10)

		if(time_remaining <= 0 || player_list.len < 1)
			//if no players, select at random
			if(player_list.len < 1)
				config.toggle_vote_method = RANDOM
			result()
			for(var/ckey in voters) //hide voting interface using ckeys
				var/client/C = directory[ckey]
				if(C)
					src.interface.hide(C)
			src.reset()
		else
			update(1)
		lock = FALSE

/datum/controller/vote/proc/get_result()
	//default-vote for everyone who didn't vote
	var/non_voters = clients.len - get_total()
	currently_voting = FALSE

	if(!config.vote_no_default && choices.len)
		//clients with voting initialized
		if(non_voters > 0)
			if(mode == "restart")
				tally["Continue Playing"] += non_voters
			if(mode == "gamemode")
				if(master_mode in choices)
					tally[master_mode] += non_voters
			if(mode == "crew_transfer")
				var/factor = 0.0107*world.time**0.393 //magical factor between approx. 0.5 and 1.4
				factor = max(factor,0.5)
				tally["Initiate Crew Transfer"] = round(tally["Initiate Crew Transfer"] * factor)
				to_chat(world, "<font color='purple'>Crew Transfer Factor: [factor]</font>")
	switch(config.toggle_vote_method)
		if(WEIGHTED)
			return weighted()
		if(MAJORITY)
			return majority()
		if(PERSISTENT)
			if(mode == "map")
				return persistent()
			else
				return  majority()
		if(RANDOM)
			return random()
		else
			return  majority()

/datum/controller/vote/proc/weighted()
	var/vote_threshold = 0.15
	var/list/discarded_choices = list()
	var/discarded_votes = 0
	var/total_votes = get_total()
	var/text
	var/list/filteredchoices = tally.Copy()
	var/qualified_votes
	if (total_votes > 0)
		for(var/a in filteredchoices)
			if(!filteredchoices[a])
				filteredchoices -= a //Remove choices with 0 votes, as pickweight gives them 1 vote
				continue
			if(filteredchoices[a] / total_votes < vote_threshold)
				discarded_votes += filteredchoices[a]
				filteredchoices -= a
				discarded_choices += a
		if(filteredchoices.len)
			winner = pickweight(filteredchoices.Copy())
		qualified_votes = total_votes - discarded_votes
		text += "<b>Random Weighted Vote Result: [winner] won with [tally[winner]] vote\s and a [round(100*tally[winner]/qualified_votes)]% chance of winning.</b>"
		for(var/choice in choices)
			if(winner != choice)
				text += "<br>\t [choice] had [tally[choice] != null ? tally[choice] : "0"] vote\s[(tally[choice])? " and [(choice in discarded_choices) ? "did not get enough votes to qualify" : "a [round(100*tally[choice]/qualified_votes)]% chance of winning"]" : null]."
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	return text

/datum/controller/vote/proc/majority()
	var/text
	var/feedbackanswer
	var/greatest_votes = 0
	if (tally.len > 0)
		var/list/winners = list()
		sortTim(tally, /proc/cmp_numeric_dsc,1)
		greatest_votes = tally[tally[1]]
		for (var/c in tally)
			if (tally[c]  == greatest_votes)//must be true a least once
				winners += c
		if (winners.len > 1)
			text = "<b>Vote Tied Between:</b><br>"
			for(var/option in winners)
				text += "\t[option]<br>"
				feedbackanswer = jointext(winners, " ")
		winner = tally[1]
		if(mode == "map")
			if(!feedbackanswer)
				feedbackanswer = winner
				feedback_set("map vote winner", feedbackanswer)
			else
				feedback_set("map vote tie", "[feedbackanswer] chosen: [winner]")
		text += "<b>Vote Result: [winner] won with [greatest_votes] vote\s.</b>"
		for(var/c in tally)
			if(winner != c)
				text += "<br>\t [c] had [tally[c] != null ? tally[c] : "0"]."
	else
		text += "<b>Vote Result: Inconclusive - No choices!</b>"
	return text

/datum/controller/vote/proc/persistent()
	var/datum/persistence_task/vote/task = SSpersistence_misc.tasks["/datum/persistence_task/vote"]
	task.insert_counts(tally)
	task.on_shutdown()
	return majority()

/datum/controller/vote/proc/random()
	var/text
	if (choices.len > 1)
		winner = pick(choices)
		text = "<b>Random Vote Result: [winner] was picked at random.</b>"
	else
		text = "<b>Vote Result: Inconclusive - No choices!</b>"
	return text

/datum/controller/vote/proc/result()
	currently_voting = FALSE
	var/result = get_result()
	var/restart = 0

	log_vote(result)
	to_chat(world, "<font color='purple'>[result]</font>")

	if(winner)
		switch(mode)
			if("restart")
				if(winner == "Restart Round")
					restart = 1
			if("gamemode")
				if(master_mode != winner)
					world.save_mode(winner)
					if(ticker && ticker.mode)
						restart = 1
					else
						master_mode = winner
				if(!going)
					going = 1
					to_chat(world, "<span class='red'><b>The round will start soon.</b></span>")
			if("crew_transfer")
				if(winner == "Initiate Crew Transfer")
					init_shift_change(null, 1)
			if("map")
				//logging
				watchdog.map_path = map_paths[winner]
				log_game("Players voted and chose.... [watchdog.map_path]!")

	if(restart)
		to_chat(world, "World restarting due to vote...")
		feedback_set_details("end_error","restart vote")
		if(blackbox)
			blackbox.save_all_data_to_sql()
		CallHook("Reboot",list())
		sleep(50)
		log_game("Rebooting due to restart vote")
		world.Reboot()

/datum/controller/vote/proc/submit_vote(var/mob/user, var/vote)
	if(mode)
		if(config.vote_no_dead && user.stat == DEAD && !user.client.holder)
			return 0
		if (isnum(vote) && (1>vote) || (vote > choices.len))
			return 0
		if(mode == "map")
			if(!user.client.holder)
				if(isnewplayer(user))
					to_chat(user, "<span class='warning'>Only players that have joined the round may vote for the next map.</span>")
					return 0
				if(isobserver(user))
					var/mob/dead/observer/O = user
					if(O.started_as_observer)
						to_chat(user, "<span class='warning'>Only players that have joined the round may vote for the next map.</span>")
						return 0
		//check vote then remove vote
		if(vote && vote == "cancel_vote")
			cancel_vote(user)
		//add vote
		else if(vote && vote != "cancel_vote")
			add_vote(user, vote)
			return vote //do we need this?
		else
			to_chat(user, "<span class='warning'>You may only vote once.</span>")
	return 0

/datum/controller/vote/proc/get_vote(var/mob/user, var/num = FALSE)
	var/mob_ckey = user.ckey
	//returns voter's choice
	if(mob_ckey)
		if(voters[mob_ckey])
			if(num)
				return choices.Find(voters[mob_ckey])
			else
				return voters[mob_ckey]
	return 0

/datum/controller/vote/proc/add_vote(var/mob/user, var/vote)
	var/mob_ckey = user.ckey
	//adds voter's choice and adds to tally. vote was passed as numbers
	if(voters[mob_ckey])
		cancel_vote(user)
	tally[choices[vote]]++
	voters[mob_ckey] += choices[vote]

/datum/controller/vote/proc/cancel_vote(var/mob/user)
	var/mob_ckey = user.ckey
	if (voters[mob_ckey])
		tally[voters[mob_ckey]]--
		voters -= mob_ckey

/datum/controller/vote/proc/get_total()
	var/total = 0
	//loop through choices in tally for count and add them up
	for (var/c in tally)
		if(c)
			total += tally[c]
	return total

/datum/controller/vote/proc/initiate_vote(var/vote_type, var/initiator_key, var/popup = 0)
	var/mob/user = usr
	if(!world.has_round_started() && !user.client.holder)
		to_chat(user, "<span class='notice'> You can't do that right now!")
		return
	if(currently_voting)
		message_admins("<span class='info'>[initiator_key] attempted to begin a vote, however a vote is already in progress.</span>")
		return
	if(!mode)
		if(started_time != null && !check_rights(R_ADMIN))
			var/next_allowed_time = (started_time + config.vote_delay)
			if(next_allowed_time > world.time)
				to_chat(user, "You must wait [(next_allowed_time - world.time)/10] seconds to call another vote.")
				return 0
		reset()
		switch(vote_type)
			if("restart")
				choices.Add("Restart Round","Continue Playing")
				question = "Restart the round?"
			if("gamemode")
				if(ticker.current_state >= 2)
					return 0
				choices.Add(config.votable_modes)
				question = "What gamemode?"
			if("crew_transfer")
				if(ticker.current_state <= 2)
					return 0
				question = "End the shift?"
				choices.Add("Initiate Crew Transfer", "Continue The Round")
			if("custom")
				question = html_encode(input(user,"What is the vote for?") as text|null)
				if(!question)
					return 0
				for(var/i in 1 to 10)
					var/option = capitalize(html_encode(input(user,"Please enter an option or hit cancel to finish") as text|null))
					if(!option || mode || !user.client)
						break
					choices.Add(option)
			if("map")
				var/list/maps
				question = "What should the next map be?"
				if (config.toggle_maps)
					maps = get_all_maps()
				else
					maps = get_votable_maps()
				for (var/map in maps)
					choices.Add(map)
				if(!choices.len)
					to_chat(world, "<span class='danger'>Failed to initiate map vote, no maps found.</span>")
					return 0
				map_paths = maps
				var/msg = "A map vote was initiated with these options: [english_list(get_list_of_keys(maps))]."
				send2maindiscord(msg)
				send2mainirc(msg)
				send2ickdiscord(config.kill_phrase) // This the magic kill phrase
			else
				return 0

		currently_voting = TRUE
		mode = vote_type
		initiator = initiator_key
		started_time = world.time
		var/text = "[capitalize(mode)] vote started by [initiator]."
		choices = shuffle(choices)
		//initialize tally
		if(config.toggle_vote_method == PERSISTENT && mode == "map")
			var/datum/persistence_task/vote/task = SSpersistence_misc.tasks["/datum/persistence_task/vote"]
			for(var/i = 1; i <= choices.len; i++)
				if(isnull(task.data[choices[i]]))
					tally += choices[i]
					tally[choices[i]] = 0
				else
					tally += choices[i]
					tally[choices[i]] = task.data[choices[i]]
		else
			for (var/c in choices)
				tally += c
				tally[c] = 0
		if(mode == "custom")
			text += "<br>[question]"

		log_vote(text)
		update(1)
		if(popup)
			for(var/client/C in clients)
				if(vote_type == "map" && !C.holder)
					if(C.mob)
						var/mob/M = C.mob
						//Do not prompt non-admin new players or round start observers for a map vote - Pomf
						if(isnewplayer(M))
							continue
						if(isobserver(M))
							var/mob/dead/observer/O = M
							if(O.started_as_observer)
								continue
				interact(C)
		else
			if(istype(user) && user.client)
				interact(user.client)

		to_chat(world, "<font color='purple'><b>[text]</b><br> <a href='?src=\ref[vote]'>Click here</a> or type 'vote' to place your votes.<br>You have [config.vote_period/10] seconds to vote.</font>")
		switch(vote_type)
			if("crew_transfer")
				world << sound('sound/voice/Serithi/Shuttlehere.ogg')
			if("gamemode")
				world << sound('sound/voice/Serithi/pretenddemoc.ogg')
			if("custom")
				world << sound('sound/voice/Serithi/weneedvote.ogg')
			if("map")
				world << sound('sound/misc/rockthevote.ogg')

		if(mode == "gamemode" && going)
			going = 0
			to_chat(world, "<span class='red'><b>Round start has been delayed.</b></span>")

		time_remaining = round(config.vote_period/10)
		return 1
	return 0

/datum/controller/vote/proc/updateFor(hclient_or_mob)
	// This check will succeed if updateFor is called after showing to the player, but will fail
	// on regular updates. Since we only really need this once we don't care if it fails.

	interface.callJavaScript("clearAll", new/list(), hclient_or_mob)
	interface.callJavaScript("update_mode", status_data, hclient_or_mob)
	if(tally.len)
		for (var/i = 1; i <= tally.len; i++)
			var/list/L = list(i, tally[i], tally[tally[i]])
			interface.callJavaScript("update_choices", L, hclient_or_mob)

/datum/controller/vote/proc/interact(client/user)
	set waitfor = FALSE // So we don't wait for each individual client's assets to be sent.

	if(!user || !initialized)
		return

	if(ismob(user))
		var/mob/M = user
		if(M.client)
			user = M.client
		else
			CRASH("The user [M.name] of type [M.type] has been passed as a mob reference without a client to voting.interact()")

	interface.show(user)
	var/list/client_data = list()
	var/admin = 0

	//adds client data
	if(get_vote(user))
		client_data += list(get_vote(user,TRUE))
	else
		client_data += list(0)
	if(user.holder)
		admin = 1
		if(user.holder.rights & R_ADMIN)
			admin = 2
	client_data += list(admin)
	interface.callJavaScript("client_data", client_data, user)
	src.updateFor(user, interface)

/datum/controller/vote/proc/update(refresh = 0)
	if(!interface)
		interface = new/datum/html_interface/nanotrasen/vote(src, "Voting Panel", 400, 400, vote_head)
		interface.updateContent("content", "<div id='vote_main'></div><div id='vote_choices'></div><div id='vote_admin'></div>")

	if(world.time < last_update + 2)
		return
	last_update = world.time
	status_data.len = 0
	status_data += list(mode)
	status_data += list(question)
	status_data += list(time_remaining)
	if(config.toggle_maps)
		status_data += list(1)
	else
		status_data += list(0)
	status_data += list(config.toggle_vote_method)

	if(refresh && interface)
		updateFor()

/datum/controller/vote/Topic(href,href_list[],hsrc)
	var/mob/user = usr
	if(!user || !user.client)
		return	//not necessary but meh...just in-case somebody does something stupid

	var/living_players = 0
	for(var/client/C in clients)
		if(C && C.mob && C.mob.stat == CONSCIOUS)
			living_players++
			break
	switch(href_list["vote"])
		if ("cancel_vote")
			cancel_vote(user)
			src.updateFor(user.client)
			return 0
		if("abort")
			if(user.client.holder)
				if(alert("Are you sure you want to cancel this vote? This will not display the results, and for a map vote, may cause problems.","Confirm","Yes","No") != "Yes")
					reset()
					return
				log_admin("[user] has cancelled a vote currently taking place. Vote type: [mode], question, [question].")
				message_admins("[user] has cancelled a vote currently taking place. Vote type: [mode], question, [question].")
				reset()
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("rig")
			if(user.client.holder)
				rigvote()
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("restart")
			if(user.client.holder)
				initiate_vote("restart",user.client.key)
			else if(!length(admins) && !living_players)
				initiate_vote("restart",user.client.key)
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("gamemode")
			if(user.client.holder)
				initiate_vote("gamemode",user.client.key)
			else
				to_chat(user, "<span class='notice'> You can't do that! This doesn't work anyway.")
		if("crew_transfer")
			if(user.client.holder)
				initiate_vote("crew_transfer",user.client.key)
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("custom")
			if(user.client.holder)
				initiate_vote("custom",user.client.key)
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("map")
			if(user.client.holder)
				initiate_vote("map",user.client.key)
			else if(!length(admins) && !living_players)
				initiate_vote("map",user.client.key)
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("toggle_map")
			if(user.client.holder)
				config.toggle_maps = !config.toggle_maps
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		if("toggle_vote_method")
			if(user.client.holder)
				config.toggle_vote_method = config.toggle_vote_method % 4 + 1
			else
				to_chat(user, "<span class='notice'> You can't do that!")
		//If not calling a vote, submit a vote
		else
			submit_vote(user, round(text2num(href_list["vote"])))
	update()
	user.vote()

/mob/verb/vote()
	var/mob/user = usr
	set category = "OOC"
	set name = "Vote"
	if(vote)
		if(!vote.initialized)
			to_chat(user, "<span class='info'>The voting controller isn't fully initialized yet.</span>")
		else
			vote.interact(user.client)
/datum/controller/vote/proc/rigvote()
	var/rigged_choice = null
	if(choices.len && alert(usr,"Pick existing choice?", "Rig", "Preexisting", "Add a new option") == "Preexisting")
		rigged_choice = input(usr,"Choose a result.","Choose a result.", choices[1]) as null|anything in choices
		if(!rigged_choice)
			return
		vote.tally[rigged_choice] = ARBITRARILY_LARGE_NUMBER
	else
		if(mode == "map")
			var/all_maps = get_all_maps()
			rigged_choice = input(usr, "Pick a map.") as null|anything in all_maps
			if(!rigged_choice)
				return
		else
			rigged_choice = input(usr,"Add a result.","Add a result","") as text|null
		if(!rigged_choice)
			return
		tally[rigged_choice]  = ARBITRARILY_LARGE_NUMBER
	message_admins("Admin [key_name_admin(usr)] rigged the vote for [rigged_choice].")
	log_admin("Admin [key_name(usr)] rigged the vote for [rigged_choice].")
