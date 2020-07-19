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
		world.log << "Database connection failed. Skipping ooc ban loading"
		diary << "Database connection failed. Skipping ooc ban loading"
		return

	//OOC permabans
	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM erro_ban WHERE (bantype = 'OOC_PERMABAN'  OR (bantype = 'OOC_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		var/ckey = query.item[1]
		oocban_keylist.Add("[ckey]")
	qdel(query)
