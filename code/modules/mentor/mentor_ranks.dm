/proc/load_mentors()
	//clear the datums references
	mentor_datums.Cut()
	mentors.Cut()


	establish_db_connection()
	if(!dbcon.IsConnected())
		world.log << "Failed to connect to database in load_mentors()."
		diary << "Failed to connect to database in load_mentors()."
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM mentors")
	query.Execute()
	while(query.NextRow())
		var/ckey = ckey(query.item[1])
		var/datum/mentors/D = new(ckey)				//create the mentor datum and store it for later use
		if(!D)	continue									//will occur if an invalid rank is provided
		D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new mentor datum

	#ifdef TESTING
	var/msg = "mentors Built:\n"
	for(var/ckey in mentor_datums)
		var/datum/mentors/D = mentor_datums[ckey]
		msg += "\t[ckey] - [D.rank.name]\n"
	testing(msg)
	#endif
