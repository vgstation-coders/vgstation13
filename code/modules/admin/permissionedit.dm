/client/proc/edit_admin_permissions()
	set category = "Admin"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions"
	if(!check_rights(R_PERMISSIONS))
		return
	usr.client.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!check_rights(R_PERMISSIONS))
		return

	var/list/output = list({"<!DOCTYPE html>
<html>
<head>
<title>Permissions Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:150px;text-align:right;'>CKEY <a class='small' href='?src=[REF(src)];[HrefToken()];editrights=add'>\[+\]</a></th>
<th style='width:125px;'>RANK</th>
<th style='width:40%;'>PERMISSIONS</th>
<th style='width:20%;'>DENIED</th>
<th style='width:40%;'>ALLOWED TO EDIT</th>
</tr>
"})

	for(var/adm_ckey in GLOB.admin_datums+GLOB.deadmins)
		var/datum/admins/D = GLOB.admin_datums[adm_ckey]
		if(!D)
			D = GLOB.deadmins[adm_ckey]
			if (!D)
				continue

		var/deadminlink = ""
		if (D.deadmined)
			deadminlink = " <a class='small' href='?src=[REF(src)];[HrefToken()];editrights=activate;ckey=[adm_ckey]'>\[RA\]</a>"
		else
			deadminlink = " <a class='small' href='?src=[REF(src)];[HrefToken()];editrights=deactivate;ckey=[adm_ckey]'>\[DA\]</a>"

		output += "<tr>"
		output += "<td style='text-align:center;'>[adm_ckey]<br>[deadminlink]<a class='small' href='?src=[REF(src)];[HrefToken()];editrights=remove;ckey=[adm_ckey]'>\[-\]</a><a class='small' href='?src=[REF(src)];[HrefToken()];editrights=sync;ckey=[adm_ckey]'>\[SYNC TGDB\]</a></td>"
		output += "<td><a href='?src=[REF(src)];[HrefToken()];editrights=rank;ckey=[adm_ckey]'>[D.rank.name]</a></td>"
		output += "<td><a class='small' href='?src=[REF(src)];[HrefToken()];editrights=permissions;ckey=[adm_ckey]'>[rights2text(D.rank.include_rights," ")]</a></td>"
		output += "<td><a class='small' href='?src=[REF(src)];[HrefToken()];editrights=permissions;ckey=[adm_ckey]'>[rights2text(D.rank.exclude_rights," ", "-")]</a></td>"
		output += "<td><a class='small' href='?src=[REF(src)];[HrefToken()];editrights=permissions;ckey=[adm_ckey]'>[rights2text(D.rank.can_edit_rights," ", "*")]</a></td>"
		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(jointext(output, ""),"window=editrights;size=1000x650")

/datum/admins/proc/edit_rights_topic(list/href_list)
	if(!check_rights(R_PERMISSIONS))
		message_admins("[key_name_admin(usr)] attempted to edit admin permissions without sufficient rights.")
		log_admin("[key_name(usr)] attempted to edit admin permissions without sufficient rights.")
		return
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Edit blocked: Advanced ProcCall detected.</span>")
		return
	var/datum/asset/permissions_assets = get_asset_datum(/datum/asset/simple/permissions)
	permissions_assets.send(src)
	var/admin_ckey = ckey(href_list["ckey"])
	var/datum/admins/D = GLOB.admin_datums[admin_ckey]
	var/use_db
	var/task = href_list["editrights"]
	var/skip
	if(task == "activate" || task == "deactivate" || task == "sync")
		skip = TRUE
	if(!CONFIG_GET(flag/admin_legacy_system) && CONFIG_GET(flag/protect_legacy_admins) && task == "rank")
		if(admin_ckey in GLOB.protected_admins)
			to_chat(usr, "<span class='admin prefix'>Editing the rank of this admin is blocked by server configuration.</span>")
			return
	if(!CONFIG_GET(flag/admin_legacy_system) && CONFIG_GET(flag/protect_legacy_ranks) && task == "permissions")
		if(D.rank in GLOB.protected_ranks)
			to_chat(usr, "<span class='admin prefix'>Editing the flags of this rank is blocked by server configuration.</span>")
			return
	if(CONFIG_GET(flag/load_legacy_ranks_only) && (task == "rank" || task == "permissions"))
		to_chat(usr, "<span class='admin prefix'>Database rank loading is disabled, only temporary changes can be made to an admin's rank or permissions.</span>")
		use_db = FALSE
		skip = TRUE
	if(check_rights(R_DBRANKS, FALSE))
		if(!skip)
			if(!SSdbcore.Connect())
				to_chat(usr, "<span class='danger'>Unable to connect to database, changes are temporary only.</span>")
				use_db = FALSE
			else
				use_db = alert("Permanent changes are saved to the database for future rounds, temporary changes will affect only the current round", "Permanent or Temporary?", "Permanent", "Temporary", "Cancel")
				if(use_db == "Cancel")
					return
				if(use_db == "Permanent")
					use_db = TRUE
					admin_ckey = sanitizeSQL(admin_ckey)
				else
					use_db = FALSE
	if(task != "add")
		D = GLOB.admin_datums[admin_ckey]
		if(!D)
			D = GLOB.deadmins[admin_ckey]
		if(!D)
			return
		if((task != "sync") && !check_if_greater_rights_than_holder(D))
			message_admins("[key_name_admin(usr)] attempted to change the rank of [admin_ckey] without sufficient rights.")
			log_admin("[key_name(usr)] attempted to change the rank of [admin_ckey] without sufficient rights.")
			return
	switch(task)
		if("add")
			admin_ckey = add_admin(use_db)
			if(!admin_ckey)
				return
			change_admin_rank(admin_ckey, use_db)
		if("remove")
			remove_admin(admin_ckey, use_db, D)
		if("rank")
			change_admin_rank(admin_ckey, use_db, D)
		if("permissions")
			change_admin_flags(admin_ckey, use_db, D)
		if("activate")
			force_readmin(admin_ckey, D)
		if("deactivate")
			force_deadmin(admin_ckey, D)
		if("sync")
			sync_lastadminrank(admin_ckey, D)
	edit_admin_permissions()

/datum/admins/proc/add_admin(use_db)
	. = ckey(input("New admin's ckey","Admin ckey") as text|null)
	if(!.)
		return FALSE
	if(. in GLOB.admin_datums+GLOB.deadmins)
		to_chat(usr, "<span class='danger'>[.] is already an admin.</span>")
		return FALSE
	if(use_db)
		. = sanitizeSQL(.)
		var/datum/DBQuery/query_add_admin = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin")] (ckey, rank) VALUES ('[.]', 'NEW ADMIN')")
		if(!query_add_admin.warn_execute())
			return FALSE
		var/datum/DBQuery/query_add_admin_log = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (datetime, adminckey, adminip, operation, log) VALUES ('[SQLtime()]', '[sanitizeSQL(usr.ckey)]', INET_ATON('[sanitizeSQL(usr.client.address)]'), 'add admin', 'New admin added: [.]')")
		if(!query_add_admin_log.warn_execute())
			return FALSE

/datum/admins/proc/remove_admin(admin_ckey, use_db, datum/admins/D)
	if(alert("Are you sure you want to remove [admin_ckey]?","Confirm Removal","Do it","Cancel") == "Do it")
		GLOB.admin_datums -= admin_ckey
		GLOB.deadmins -= admin_ckey
		D.disassociate()
		if(use_db)
			var/datum/DBQuery/query_add_rank = SSdbcore.NewQuery("DELETE FROM [format_table_name("admin")] WHERE ckey = '[admin_ckey]'")
			if(!query_add_rank.warn_execute())
				return
			var/datum/DBQuery/query_add_rank_log = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (datetime, adminckey, adminip, operation, log) VALUES ('[SQLtime()]', '[sanitizeSQL(usr.ckey)]', INET_ATON('[sanitizeSQL(usr.client.address)]'), 'remove admin', 'Admin removed: [admin_ckey]')")
			if(!query_add_rank_log.warn_execute())
				return
		message_admins("[key_name_admin(usr)] removed [admin_ckey] from the admins list [use_db ? "permanently" : "temporarily"]")
		log_admin("[key_name(usr)] removed [admin_ckey] from the admins list [use_db ? "permanently" : "temporarily"]")

/datum/admins/proc/force_readmin(admin_ckey, datum/admins/D)
	if(!D || !D.deadmined)
		return
	D.activate()
	message_admins("[key_name_admin(usr)] forcefully readmined [admin_ckey]")
	log_admin("[key_name(usr)] forcefully readmined [admin_ckey]")

/datum/admins/proc/force_deadmin(admin_ckey, datum/admins/D)
	if(!D || D.deadmined)
		return
	message_admins("[key_name_admin(usr)] forcefully deadmined [admin_ckey]")
	log_admin("[key_name(usr)] forcefully deadmined [admin_ckey]")
	D.deactivate() //after logs so the deadmined admin can see the message.

/datum/admins/proc/change_admin_rank(admin_ckey, use_db, datum/admins/D)
	var/datum/admin_rank/R
	var/list/rank_names = list("*New Rank*")
	for(R in GLOB.admin_ranks)
		if((R.rights & usr.client.holder.rank.can_edit_rights) == R.rights)
			rank_names[R.name] = R
	var/new_rank = input("Please select a rank", "New rank") as null|anything in rank_names
	if(new_rank == "*New Rank*")
		new_rank = ckeyEx(input("Please input a new rank", "New custom rank") as text|null)
	if(!new_rank)
		return
	R = rank_names[new_rank]
	if(!R) //rank with that name doesn't exist yet - make it
		if(D)
			R = new(new_rank, D.rank.rights) //duplicate our previous admin_rank but with a new name
		else
			R = new(new_rank) //blank new admin_rank
		GLOB.admin_ranks += R
	if(use_db)
		new_rank = sanitizeSQL(new_rank)
		if(!R)
			var/datum/DBQuery/query_add_rank = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_ranks")] (rank, flags, exclude_flags, can_edit_rights) VALUES ('[new_rank]', '0', '0', '0')")
			if(!query_add_rank.warn_execute())
				return
			var/datum/DBQuery/query_add_rank_log = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (datetime, adminckey, adminip, operation, log) VALUES ('[SQLtime()]', '[sanitizeSQL(usr.ckey)]', INET_ATON('[sanitizeSQL(usr.client.address)]'), 'add rank', 'New rank added: [admin_ckey]')")
			if(!query_add_rank_log.warn_execute())
				return
		var/old_rank
		var/datum/DBQuery/query_get_rank = SSdbcore.NewQuery("SELECT rank FROM [format_table_name("admin")] WHERE ckey = '[admin_ckey]'")
		if(!query_get_rank.warn_execute())
			return
		if(query_get_rank.NextRow())
			old_rank = query_get_rank.item[1]
		var/datum/DBQuery/query_change_rank = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET rank = '[new_rank]' WHERE ckey = '[admin_ckey]'")
		if(!query_change_rank.warn_execute())
			return
		var/datum/DBQuery/query_change_rank_log = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (datetime, adminckey, adminip, operation, log) VALUES ('[SQLtime()]', '[sanitizeSQL(usr.ckey)]', INET_ATON('[sanitizeSQL(usr.client.address)]'), 'change admin rank', 'Rank of [admin_ckey] changed from [old_rank] to [new_rank]')")
		if(!query_change_rank_log.warn_execute())
			return
	if(D) //they were previously an admin
		D.disassociate() //existing admin needs to be disassociated
		D.rank = R //set the admin_rank as our rank
		var/client/C = GLOB.directory[admin_ckey]
		D.associate(C)
	else
		D = new(R, admin_ckey, TRUE) //new admin
	message_admins("[key_name_admin(usr)] edited the admin rank of [admin_ckey] to [new_rank] [use_db ? "permanently" : "temporarily"]")
	log_admin("[key_name(usr)] edited the admin rank of [admin_ckey] to [new_rank] [use_db ? "permanently" : "temporarily"]")

/datum/admins/proc/change_admin_flags(admin_ckey, use_db, datum/admins/D)
	var/new_flags = input_bitfield(usr, "Include permission flags<br>[use_db ? "This will affect ALL admins with this rank." : "This will affect only the current admin [admin_ckey]"]", "admin_flags", D.rank.include_rights, 350, 590, allowed_edit_list = usr.client.holder.rank.can_edit_rights)
	if(isnull(new_flags))
		return
	var/new_exclude_flags = input_bitfield(usr, "Exclude permission flags<br>Flags enabled here will be removed from a rank.<br>Note these take precedence over included flags.<br>[use_db ? "This will affect ALL admins with this rank." : "This will affect only the current admin [admin_ckey]"]", "admin_flags", D.rank.exclude_rights, 350, 670, "red", usr.client.holder.rank.can_edit_rights)
	if(isnull(new_exclude_flags))
		return
	var/new_can_edit_flags = input_bitfield(usr, "Editable permission flags<br>These are the flags this rank is allowed to edit if they have access to the permissions panel.<br>They will be unable to modify admins to a rank that has a flag not included here.<br>[use_db ? "This will affect ALL admins with this rank." : "This will affect only the current admin [admin_ckey]"]", "admin_flags", D.rank.can_edit_rights, 350, 710, allowed_edit_list = usr.client.holder.rank.can_edit_rights)
	if(isnull(new_can_edit_flags))
		return
	if(use_db)
		var/old_flags
		var/old_exclude_flags
		var/old_can_edit_flags
		var/datum/DBQuery/query_get_rank_flags = SSdbcore.NewQuery("SELECT flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")] WHERE rank = '[D.rank.name]'")
		if(!query_get_rank_flags.warn_execute())
			return
		if(query_get_rank_flags.NextRow())
			old_flags = text2num(query_get_rank_flags.item[1])
			old_exclude_flags = text2num(query_get_rank_flags.item[2])
			old_can_edit_flags = text2num(query_get_rank_flags.item[3])
		var/datum/DBQuery/query_change_rank_flags = SSdbcore.NewQuery("UPDATE [format_table_name("admin_ranks")] SET flags = '[new_flags]', exclude_flags = '[new_exclude_flags]', can_edit_flags = '[new_can_edit_flags]' WHERE rank = '[D.rank.name]'")
		if(!query_change_rank_flags.warn_execute())
			return
		var/datum/DBQuery/query_change_rank_flags_log = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (datetime, adminckey, adminip, operation, log) VALUES ('[SQLtime()]', '[sanitizeSQL(usr.ckey)]', INET_ATON('[sanitizeSQL(usr.client.address)]'), 'change rank flags', 'Permissions of [admin_ckey] changed from[rights2text(old_flags," ")][rights2text(old_exclude_flags," ", "-")][rights2text(old_can_edit_flags," ", "*")] to[rights2text(new_flags," ")][rights2text(new_exclude_flags," ", "-")][rights2text(new_can_edit_flags," ", "*")]')")
		if(!query_change_rank_flags_log.warn_execute())
			return
		for(var/datum/admin_rank/R in GLOB.admin_ranks)
			if(R.name != D.rank.name)
				continue
			R.rights = new_flags &= ~new_exclude_flags
			R.exclude_rights = new_exclude_flags
			R.include_rights = new_flags
			R.can_edit_rights = new_can_edit_flags
		for(var/i in GLOB.admin_datums+GLOB.deadmins)
			var/datum/admins/A = GLOB.admin_datums[i]
			if(!A)
				A = GLOB.deadmins[i]
				if (!A)
					continue
			if(A.rank.name != D.rank.name)
				continue
			var/client/C = GLOB.directory[A.target]
			A.disassociate()
			A.associate(C)
	else
		D.disassociate()
		if(!findtext(D.rank.name, "([admin_ckey])")) //not a modified subrank, need to duplicate the admin_rank datum to prevent modifying others too
			D.rank = new("[D.rank.name]([admin_ckey])", new_flags, new_exclude_flags, new_can_edit_flags) //duplicate our previous admin_rank but with a new name
			//we don't add this clone to the admin_ranks list, as it is unique to that ckey
		else
			D.rank.rights = new_flags &= ~new_exclude_flags
			D.rank.include_rights = new_flags
			D.rank.exclude_rights = new_exclude_flags
		var/client/C = GLOB.directory[admin_ckey] //find the client with the specified ckey (if they are logged in)
		D.associate(C) //link up with the client and add verbs
	message_admins("[key_name_admin(usr)] edited the permissions of [use_db ? " rank [D.rank.name] permanently" : "[admin_ckey] temporarily"]")
	log_admin("[key_name(usr)] edited the permissions of [use_db ? " rank [D.rank.name] permanently" : "[admin_ckey] temporarily"]")

/datum/admins/proc/sync_lastadminrank(admin_ckey, datum/admins/D)
	var/sqlrank = sanitizeSQL(D.rank.name)
	admin_ckey = sanitizeSQL(admin_ckey)
	var/datum/DBQuery/query_sync_lastadminrank = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET lastadminrank = '[sqlrank]' WHERE ckey = '[admin_ckey]'")
	if(!query_sync_lastadminrank.warn_execute())
		return
	to_chat(usr, "<span class='admin'>Sync of [admin_ckey] successful.</span>")
