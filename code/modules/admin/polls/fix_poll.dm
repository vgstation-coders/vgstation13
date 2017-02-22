/client/proc/fix_poll()
	set name = "Fix Poll"
	set category = "Special Verbs"
	if(!check_rights(R_POLLING))
		return
	if(!dbcon.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return

	var/DBQuery/get_broken_polls = dbcon.NewQuery("SELECT question FROM erro_poll_question WHERE option IS NULL AND polltype != 'TEXT' AND DATE(endtime) > NOW()") //all polls that end in the future, don't have options, and aren't text response polls
	get_broken_polls.Execute()

	var/list/broken_polls = list()
	while(get_broken_polls.NextRow())
		var/pollquestion = get_broken_polls.item[1]
		broken_polls += pollquestion

	var/selectedpoll = input("Select poll lacking options that you'd like to fix.","THEY'RE BROKEN") as null|anything in broken_polls
	if(!selectedpoll)
		return

	var/dowhat = alert(src, "What would you like to do with this poll? Please note that if this poll's question matches another one verbatum, this will affect both.","What do you plan to do?","End Poll","Add Options","Cancel")
	if(dowhat == "Cancel")
		return

	if(dowhat == "End Poll") //Verbatum matching questions are all affected by this.
		var/DBQuery/end_this_poll = dbcon.NewQuery("UPDATE erro_poll_question SET endtime = NOW() WHERE question = '[selectedpoll]' AND WHERE option IS NULL AND polltype != 'TEXT' AND DATE(endtime) > NOW()")
		end_this_poll.Execute()
		return

	var/pollid = 0
	var/polltype = ""
	var/DBQuery/query_get_id = dbcon.NewQuery("SELECT id, polltype FROM erro_poll_question WHERE question = '[selectedpoll]' AND WHERE option IS NULL AND polltype != 'TEXT' AND DATE(endtime) > NOW()")
	if(!query_get_id.Execute())
		var/err = query_get_id.ErrorMsg()
		log_game("SQL ERROR obtaining id from poll_question table. Error : \[[err]\]\n")
		return
	if(query_get_id.NextRow())
		pollid = query_get_id.item[1]
		polltype = query_get_id.item[2]
	var/add_option = 1
	var/i = 1
	while(add_option)
		var/option = input("Write your option [i]","Option") as message
		if(!option)
			return
		option = sanitizeSQL(option)
		var/percentagecalc
		switch(alert("Calculate option [i] results as percentage?",,"Yes","No","Cancel"))
			if("Yes")
				percentagecalc = 1
			if("No")
				percentagecalc = 0
			else
				return
		var/minval = 0
		var/maxval = 0
		var/descmin = ""
		var/descmid = ""
		var/descmax = ""
		if(polltype == "NUMVAL")
			minval = input("Set minimum rating value.","Minimum rating") as num
			if(!minval)
				return
			maxval = input("Set maximum rating value.","Maximum rating") as num
			if(!maxval)
				return
			if(minval >= maxval)
				to_chat(src, "Minimum rating value can't be more than maximum rating value")
				return
			descmin = input("Optional: Set description for minimum rating","Minimum rating description") as message
			if(descmin)
				descmin = sanitizeSQL(descmin)
			descmid = input("Optional: Set description for median rating","Median rating description") as message
			if(descmid)
				descmid = sanitizeSQL(descmid)
			descmax = input("Optional: Set description for maximum rating","Maximum rating description") as message
			if(descmax)
				descmax = sanitizeSQL(descmax)
		var/DBQuery/query_polladd_option = dbcon.NewQuery("INSERT INTO erro_poll_option (pollid, text, percentagecalc, minval, maxval, descmin, descmid, descmax) VALUES ('[pollid]', '[option]', '[percentagecalc]', '[minval]', '[maxval]', '[descmin]', '[descmid]', '[descmax]')")
		if(!query_polladd_option.Execute())
			var/err = query_polladd_option.ErrorMsg()
			log_game("SQL ERROR adding new poll option to table. Error : \[[err]\]\n")
			return
		else
			i++
		switch(alert("Add more options?",,"Add option","Finish"))
			if("Add option")
				add_option = 1
			if("Finish")
				add_option = 0