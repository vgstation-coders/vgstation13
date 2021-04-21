#define BAGEL_REQUIREMENT 17

//checks if a file exists and contains text
//returns text as a string if these conditions are met
/proc/return_file_text(filename)
	if(fexists(filename) == 0)
		error("File not found ([filename])")
		return

	var/text = file2text(filename)
	if(!text)
		error("File empty ([filename])")
		return

	return text

/proc/get_maps(root="maps/voting/")
	var/list/maps = list() //an associative list to be returned, associates title with path+binary
	var/list/all_maps = list() //list of all maps, skipped or otherwise
	var/recursion_limit = 20 //lots of maps waiting to be played, feels like TF2
	//Get our potential maps
	testing("starting in [root]")
	for(var/potential in flist(root))
		if(copytext(potential,-1,0) != "/")
			continue // Not a directory, ignore it.
		testing("Inside [root + potential]")
		if(!recursion_limit)
			break
		//our current working directory
		var/path = root + potential
		//The DMB that has the map we want.
		var/binary
		//Looking for a binary
		var/min = -1
		var/max = -1
		var/skipping = 0
		for(var/binaries in flist(path))
			testing("Checking file [binaries]")
			if(copytext(binaries,-4,0) == ".txt")
				var/list/lines = file2list(path+binaries)
				for(var/line in lines)
					if(findtext(line,"max"))
						max = text2num(copytext(line,5,0))
						testing("[path] maximum players is [line] found [max]")
					else if(findtext(line,"min"))
						min = text2num(copytext(line,5,0))
						testing("[path] minimum players is [line] found [min]")
					else
						warning("Our file had excessive lines, skipping.")
						skipping = 3 //useless file
						min = null
						max = null
				if(!isnull(min) && !isnull(max))
					if((min != -1) && clients.len < min)
						skipping = 1 //too little players
					else if((max != -1) && clients.len > max)
						skipping = 2 //too many players
			if(copytext(binaries,-4,0) == ".dmb")
				if(binary)
					warning("Extra DMB [binary] in map folder, skipping.")
					continue
				binary = binaries
				continue
		if(skipping < 3)
			var/fullpath = path+binary
			if(copytext(fullpath,-4,0) == ".dmb")
				all_maps[copytext(potential,1,length(potential))] = path + binary // Makes key not have / at end, looks better in lists
			else
				binary = null
				continue
		if(skipping)
			message_admins("Skipping map [potential] due to [skipping == 1 ? "not enough players." : "too many players."] Players min = [min] || max = [max]")
			warning("Skipping map [potential] due to [skipping == 1 ? "not enough players." : "too many players."] Players min = [min] || max = [max]")
			binary = null
			continue
		if(potential == "Snow Taxi/")
			var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
			var/allowed_months = list(1, 2, 7, 12)
			if (!(MM in allowed_months))
				message_admins("Skipping map [potential] as this is no longer the Christmas season.")
				warning("Skipping map [potential] as this is no longer the Christmas season.")
				binary = null
				continue
		if(potential == "Lamprey/") //Available if the station is wrecked enough
			var/crew_score = score["crewscore"] //So that we can use this in the admin messaging
			if(crew_score > -20000)
				message_admins("Skipping map [potential], station requires lower than -20000 score (is [crew_score]).")
				warning("Skipping map [potential], station requires lower than -20000 score (is [crew_score]).")
				binary = null
				continue
		if(potential == "Castle Station/") //Available if revolutionaries won
			if(!ticker.revolutionary_victory)
				message_admins("Skipping map [potential], revolutionaries have not won.")
				warning("Skipping map [potential], revolutionaries have not won.")
				binary = null
				continue
		if(potential == "Bagel Station/")
			if(score["bagelscooked"] < BAGEL_REQUIREMENT)
				message_admins("Skipping map [potential], less than [BAGEL_REQUIREMENT] bagels made.")
				warning("Skipping map [potential], less than [BAGEL_REQUIREMENT] bagels made.")
				binary = null
				continue
		if(!binary)
			warning("Map folder [path] does not contain a valid byond binary, skipping.")
		else
			maps[copytext(potential,1,length(potential))] = path + binary // Makes key not have / at end, looks better in lists
			binary = null
		recursion_limit--
	var/list/maplist = get_list_of_keys(maps)
	send2maindiscord("A map vote was initiated with these options: [english_list(maplist)].")
	send2mainirc("A map vote was initiated with these options: [english_list(maplist)].")
	send2ickdiscord(config.kill_phrase) // This the magic kill phrase
	vote.allmaps = all_maps
	return maps

//Sends resource files to client cache
/client/proc/getFiles()
	for(var/file in args)
		src << browse_rsc(file)

/client/proc/browse_files(root="data/logs/", max_iterations=10, list/valid_extensions=list(".txt",".log",".htm", ".csv", ".dmm"))
	var/path = "data/logs/"
	if((root != path) && (root != (path + "runtime/")))
		root = path
	for(var/i=0, i<max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1,"/")

		var/choice = input(src,"Choose a file to access:","Download",null) as null|anything in choices
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path,-1,0) != "/")		//didn't choose a directory, no need to iterate again
			break

	var/extension = copytext(path,-4,0)
	if( !fexists(path) || !(extension in valid_extensions) )
		to_chat(src, "<span class='red'>Error: browse_files(): File not found/Invalid file([path]).</span>")
		return

	return path

#define FTPDELAY 200	//200 tick delay to discourage spam
/*	This proc is a failsafe to prevent spamming of file requests.
	It is just a timer that only permits a download every [FTPDELAY] ticks.
	This can be changed by modifying FTPDELAY's value above.

	PLEASE USE RESPONSIBLY, Some log files can reach sizes of 4MB!	*/
/client/proc/file_spam_check()
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<span class='red'>Error: file_spam_check(): Spam. Please wait [round(time_to_wait/10)] seconds.</span>")
		return 1
	fileaccess_timer = world.time + FTPDELAY
	return 0
#undef FTPDELAY
#undef BAGEL_REQUIREMENT
