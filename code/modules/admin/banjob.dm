

var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks
	//is now a list-of-lists:
		//jobban_keylist["playerckey1"] is an associative list with key: rank, value: reason

/proc/jobban_fullban(mob/M, rank, reason)
	if (!M || !M.key)
		return
	if(islist(jobban_keylist[M.ckey]))
		jobban_keylist[M.ckey][rank] = reason
	else
		jobban_keylist[M.ckey] = list(rank = reason)
	jobban_savebanfile()

//unused
/proc/jobban_client_fullban(ckey, rank)
	if (!ckey || !rank)
		return
	if(!islist(jobban_keylist[ckey]))
		jobban_keylist[ckey][rank] = list()
	jobban_keylist[ckey] = list(rank = null)
	jobban_savebanfile()

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(M && rank)
		/*
		if(_jobban_isbanned(M, rank))
			return "Reason Unspecified"	//for old jobban
		if (guest_jobbans(rank))
			if(config.guest_jobban && IsGuestKey(M.key))
				return "Guest Job-ban"
			if(config.usewhitelist && !check_whitelist(M))
				return "Whitelisted Job"
		*/
		var/list/s = jobban_keylist[M.ckey]
		if(s?.len)
			var/reason = s[rank]
			if(!reason)
				reason = "Reason Unspecified"
			return reason
/*
		for (var/s in jobban_keylist)
			if( findtext(s,"[M.ckey] - [rank]") == 1 )
				var/startpos = findtext(s, "## ")+3
				if(startpos && startpos<length(s))
					var/text = copytext(s, startpos, 0)
					if(text)
						return text
				return "Reason Unspecified"
*/
	return 0

/*
DEBUG
/mob/verb/list_all_jobbans()
	set name = "list all jobbans"

	for(var/s in jobban_keylist)
		to_chat(world, s)

/mob/verb/reload_jobbans()
	set name = "reload jobbans"

	jobban_loadbanfile()
*/

/proc/jobban_loadbanfile()
	if(config.ban_legacy_system)
		var/savefile/S=new("data/job_full.ban")
		var/list/list_of_bans = list()
		S["keys[0]"] >> list_of_bans
//		S["keys[0]"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if (!length(list_of_bans))
			jobban_keylist = list()
			log_admin("jobban_keylist was empty")
		else
			var/first_space
			var/doublehash
			var/ckey
			var/rank
			var/reason
			for(var/this_ban in list_of_bans)
				first_space = findtext(this_ban, " ")
				ckey = copytext(this_ban, 1, first_space)
				doublehash = findtext(this_ban, "##")
				rank = copytext(this_ban, first_space + 3, doublehash ? doublehash - 1 : 0)
				reason = doublehash ? copytext(this_ban, doublehash + 3, 0) : null
				if(!jobban_keylist[ckey])
					jobban_keylist[ckey] = list()
				jobban_keylist[ckey][rank] = reason

	else
		if(!SSdbcore.Connect())
			diary << "Database connection failed. Reverting to the legacy ban system."
			config.ban_legacy_system = 1
			jobban_loadbanfile()
			return

		//Job permabans
		var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = :bantype AND isnull(unbanned)",
			list(
				"bantype" = "JOB_PERMABAN"
			))
		if(!query.Execute())
			message_admins("Error: [query.ErrorMsg()]")
			log_sql("Error: [query.ErrorMsg()]")
			qdel(query)
			return

		while(query.NextRow())
			var/ckey = query.item[1]
			var/job = query.item[2]
			if(!jobban_keylist[ckey])
				jobban_keylist[ckey] = list()
			jobban_keylist[ckey][job] = null
			//jobban_keylist.Add("[ckey] - [job]")
		qdel(query)
		//Job tempbans
		var/datum/DBQuery/query1 = SSdbcore.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = :bantype AND isnull(unbanned) AND expiration_time > Now()",
			list(
				"bantype" = "JOB_TEMPBAN",
			))
		if(!query1.Execute())
			log_sql("Error: [query1.ErrorMsg()]")
			qdel(query1)
			return

		while(query1.NextRow())
			var/ckey = query1.item[1]
			var/job = query1.item[2]
			if(!jobban_keylist[ckey])
				jobban_keylist[ckey] = list()
			jobban_keylist[ckey][job] = null
			//jobban_keylist.Add("[ckey] - [job]")
		qdel(query1)

/proc/jobban_savebanfile()
	var/savefile/S = new("data/job_full.ban")

	var/list/list_of_bans = list()
	var/list/these_bans
	var/reason
	for(var/ckey in jobban_keylist)
		these_bans = jobban_keylist[ckey]
		for(var/this_rank in these_bans)
			reason = these_bans[this_rank]
			list_of_bans += "[ckey] - [this_rank]" + reason ? " ## [reason]" : null

	S["keys[0]"] << list_of_bans
//	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [rank]")
	jobban_savebanfile()


/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")


/proc/jobban_updatelegacybans()
	if(!jobban_runonce)
		log_admin("Updating jobbanfile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in jobban_keylist)
			if(!jobban_keylist[T])
			//if(!T)
				continue
		jobban_runonce++	//don't run this update again

/proc/jobban_remove(X)

	var/list/list_of_bans = list()
	var/list/these_bans
	var/reason
	for(var/ckey in jobban_keylist)
		these_bans = jobban_keylist[ckey]
		for(var/this_rank in these_bans)
			reason = these_bans[this_rank]
			if(findtext("[ckey] - [this_rank]" + reason ? " ## [reason]" : null, "[X]"))
				jobban_keylist[ckey].Remove(this_rank)
				jobban_savebanfile()
				return 1
	return 0
