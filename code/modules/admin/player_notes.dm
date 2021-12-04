/datum/admins/proc/notes_add(var/key, var/note)
	if (!key || !note)
		return

	//Loading list of notes for this key
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		infos = list()

	//Overly complex timestamp creation
	var/modifyer = "th"
	switch(time2text(world.timeofday, "DD"))
		if("01","21","31")
			modifyer = "st"
		if("02","22",)
			modifyer = "nd"
		if("03","23")
			modifyer = "rd"
	var/day_string = "[time2text(world.timeofday, "DD")][modifyer]"
	if(copytext(day_string,1,2) == "0")
		day_string = copytext(day_string,2)
	var/full_date = time2text(world.timeofday, "DDD, Month DD of YYYY")
	var/day_loc = findtext(full_date, time2text(world.timeofday, "DD"))

	var/datum/player_info/P = new
	if (owner)
		P.author = owner.ckey
		P.rank = rank
	else
		P.author = "Adminbot"
		P.rank = "Friendly Robot"
		stack_trace("notes_add called on a /datum/admins with no owner.")
	P.content = note
	P.timestamp = "[copytext(full_date,1,day_loc)][day_string][copytext(full_date,day_loc+2)]"

	infos += P
	info << infos

	message_admins("<span class='notice'>[key_name_admin(owner)] has edited [key]'s notes.</span>")
	log_admin("[key_name(owner)] has edited [key]'s notes.")

	del info

	//Updating list of keys with notes on them
	var/savefile/note_list = new("data/player_notes.sav")
	var/list/note_keys
	note_list >> note_keys
	if(!note_keys)
		note_keys = list()
	if(!note_keys.Find(key))
		note_keys += key
	note_list << note_keys
	del note_list


/datum/admins/proc/notes_del(var/key, var/index)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || infos.len < index)
		return

	var/datum/player_info/item = infos[index]
	infos.Remove(item)
	info << infos

	message_admins("<span class='notice'>[key_name_admin(owner)] deleted one of [key]'s notes.</span>")
	log_admin("[key_name(owner)] deleted one of [key]'s notes.")

	del info
