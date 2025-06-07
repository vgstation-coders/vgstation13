var/paxban_keylist[0]

/proc/pax_unban(mob/M)
	if(!M)
		return 0
	return paxban_keylist.Remove("[M.ckey]")

/proc/pax_ban(mob/M)
	if(!M)
		return 0
	return paxban_keylist.Add("[M.ckey]")

/proc/paxban_loadbanfile()
	if(!SSdbcore.Connect())
		diary << "Database connection failed. Skipping pax ban loading"
		return

	//OOC permabans
	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM erro_ban WHERE (bantype = :pax_perma  OR (bantype = :pax_temp AND expiration_time > Now())) AND isnull(unbanned)",
		list(
			"pax_perma" = "pax_PERMABAN",
			"pax_temp" = "pax_TEMPBAN",
		))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		var/ckey = query.item[1]
		paxban_keylist.Add("[ckey]")
	qdel(query)
