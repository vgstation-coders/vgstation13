var/oocban_keylist[0]

/proc/ooc_unban(mob/M)
	if(!M)
		return 0
	return oocban_keylist.Remove("[M.ckey]")

/proc/ooc_ban(mob/M)
	if(!M)
		return 0
	return oocban_keylist.Add("[M.ckey]")

/proc/oocban_loadbanfile()
	if(!SSdbcore.Connect())
		diary << "Database connection failed. Skipping ooc ban loading"
		return

	//OOC permabans
	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM erro_ban WHERE (bantype = :ooc_perma  OR (bantype = :ooc_temp AND expiration_time > Now())) AND isnull(unbanned)",
		list(
			"ooc_perma" = "OOC_PERMABAN",
			"ooc_temp" = "OOC_TEMPBAN",
		))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		var/ckey = query.item[1]
		oocban_keylist.Add("[ckey]")
	qdel(query)
