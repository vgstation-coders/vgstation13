var/cluwneban_keylist[0]

// TODO: Add some way to store parameters in the database.
#define CLUWNEBAN_CLUWNE   0
#define CLUWNEBAN_CATBEAST 1

/proc/cluwne_unban(mob/M)
	if(!M)
		return 0
	return cluwneban_keylist.Remove("[M.ckey]")

/proc/cluwne_ban(mob/M)
	if(!M)
		return 0
	return cluwneban_keylist.Add("[M.ckey]")


/proc/equip_cluwneban(var/event_args/player_spawn/evargs)
	if(is_cluwne_banned(evargs.character.ckey))
		var/mob/living/simple_animal/hostile/retaliate/cluwne/C = evargs.character:Cluwneize(skip_intro=TRUE)
		to_chat(C, "<span class='sinister'><big>YOUR PENANCE BEGINS NOW.</big></span>")

/proc/assignrole_cluwneban(var/event_args/player_spawn/evargs)
	evargs.rank = "Assistant" // Forced to assistant so we don't take cool job slots.

/proc/cluwneban_loadbanfile()
	if(!establish_db_connection())
		world.log << "Database connection failed. Skipping cluwne ban loading"
		diary << "Database connection failed. Skipping cluwne ban loading"
		return

	// Hooks into character equipping shit.
	on_post_equip_char.Add(global, "equip_cluwneban")
	on_pre_assignrole.Add(global,  "assignrole_cluwneban")

	//cluwne permabans
	var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM erro_ban WHERE (bantype = 'CLUWNEBAN' AND (expiration_time == -1 OR expiration_time > Now()) AND isnull(unbanned)")
	query.Execute()

	while(query.NextRow())
		var/ckey = query.item[1]
		cluwneban_keylist.Add("[ckey]")
