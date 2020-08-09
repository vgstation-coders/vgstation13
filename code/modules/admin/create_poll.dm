/client/proc/create_poll()
	set name = "Create Poll"
	set category = "Special Verbs"
	if(!check_rights(R_POLLING))
		return
	if(!SSdbcore.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/polltype = input("Choose poll type.","Poll Type") in list("Single Option","Text Reply","Rating","Multiple Choice")
	var/choice_amount = 0
	switch(polltype)
		if("Single Option")
			polltype = "OPTION"
		if("Text Reply")
			polltype = "TEXT"
		if("Rating")
			polltype = "NUMVAL"
		if("Multiple Choice")
			polltype = "MULTICHOICE"
			choice_amount = input("How many choices should be allowed?","Select choice amount") as num
	var/starttime = SQLtime()
	var/endtime = input("Set end time for poll as format YYYY-MM-DD HH:MM:SS. All times in server time. HH:MM:SS is optional and 24-hour. Must be later than starting time for obvious reasons.", "Set end time", SQLtime()) as text
	if(!endtime)
		to_chat(usr, "<span class='warning'>endtime is null!</span>")
		return
	var/datum/DBQuery/query_validate_time = SSdbcore.NewQuery("SELECT STR_TO_DATE(:endtime,'%Y-%c-%d %T')", list("endtime" = endtime))
	if(!query_validate_time.Execute())
		var/err = query_validate_time.ErrorMsg()
		log_sql("SQL ERROR validating endtime. Error : \[[err]\]\n")
		qdel(query_validate_time)
		return
	if(query_validate_time.NextRow())
		endtime = query_validate_time.item[1]
		if(!endtime)
			to_chat(src, "Datetime entered is invalid.")
			return
	qdel(query_validate_time)
	var/datum/DBQuery/query_time_later = SSdbcore.NewQuery("SELECT DATE(:endtime) < NOW()", list("endtime" = endtime))
	if(!query_time_later.Execute())
		var/err = query_time_later.ErrorMsg()
		log_sql("SQL ERROR comparing endtime to NOW(). Error : \[[err]\]\n")
		qdel(query_time_later)
		return
	if(query_time_later.NextRow())
		var/checklate = text2num(query_time_later.item[1])
		if(checklate)
			src << "Datetime entered is not later than current server time."
			return
	qdel(query_time_later)
	var/adminonly
	switch(alert("Admin only poll?",,"Yes","No","Cancel"))
		if("Yes")
			adminonly = 1
		if("No")
			adminonly = 0
		else
			return
	var/question = input("Write your question","Question") as message
	if(!question)
		return
	var/datum/DBQuery/query_polladd_question = SSdbcore.NewQuery("INSERT INTO erro_poll_question (polltype, starttime, endtime, question, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip) VALUES (:polltype, :starttime, :endtime, :question, :adminonly, :choice_amount, :ckey, :address)",
		list(
			"polltype" = polltype,
			"starttime" = starttime,
			"endtime" = endtime,
			"question" = question,
			"adminonly" = adminonly,
			"choice_amount" = choice_amount,
			"ckey" = ckey,
			"address" = address,
	))
	if(!query_polladd_question.Execute())
		var/err = query_polladd_question.ErrorMsg()
		qdel(query_polladd_question)
		log_sql("SQL ERROR adding new poll question to table. Error : \[[err]\]\n")
		return
	qdel(query_polladd_question)
	var/pollid = 0
	var/datum/DBQuery/query_get_id = SSdbcore.NewQuery("SELECT id FROM erro_poll_question WHERE question = :question AND starttime = :starttime AND endtime = :endtime AND createdby_ckey = :ckey AND createdby_ip = :address",
		list(
			"question" = question,
			"starttime" = starttime,
			"endtime" = endtime,
			"ckey" = ckey,
			"address" = address,
	))
	if(!query_get_id.Execute())
		var/err = query_get_id.ErrorMsg()
		qdel(query_get_id)
		log_sql("SQL ERROR obtaining id from poll_question table. Error : \[[err]\]\n")
		return
	if(query_get_id.NextRow())
		pollid = query_get_id.item[1]
	qdel(query_get_id)
	log_admin("[key_name(src)] created the poll with id [pollid].")
	message_admins("<span class='notice'>[key_name_admin(src)] created the poll with id [pollid].</span>")

	var/add_option = 1
	if(polltype == "TEXT")
		add_option = 0
	while(add_option)
		var/option = input("Write your option","Option") as message
		if(!option)
			return
		var/percentagecalc
		switch(alert("Calculate option results as percentage?",,"Yes","No","Cancel"))
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
				src << "Minimum rating value can't be more than maximum rating value"
				return
			descmin = input("Optional: Set description for minimum rating","Minimum rating description") as message
			descmid = input("Optional: Set description for median rating","Median rating description") as message
			descmax = input("Optional: Set description for maximum rating","Maximum rating description") as message
		var/datum/DBQuery/query_polladd_option = SSdbcore.NewQuery("INSERT INTO erro_poll_option (pollid, text, percentagecalc, minval, maxval, descmin, descmid, descmax) VALUES (:pollid, :option, :percentagecalc, :minval, :maxval, :descmin, :descmid, :descmax)",
			list(
				"pollid" = pollid,
				"option" = option,
				"percentagecalc" = percentagecalc,
				"minval" = minval,
				"maxval" = maxval,
				"descmin" = descmin,
				"descmid" = descmid,
				"descmax" = descmax,
		))
		if(!query_polladd_option.Execute())
			var/err = query_polladd_option.ErrorMsg()
			log_sql("SQL ERROR adding new poll option to table. Error : \[[err]\]\n")
			qdel(query_polladd_option)
			return
		qdel(query_polladd_option)
		switch(alert(" ",,"Add option","Finish"))
			if("Add option")
				add_option = 1
			if("Finish")
				add_option = 0
