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

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Permissions Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:125px;text-align:right;'>CKEY <a class='small' href='?src=\ref[src];editrights=add'>\[+\]</a></th>
<th style='width:125px;'>RANK</th><th style='width:100%;'>PERMISSIONS</th>
</tr>
"}

	for(var/adm_ckey in admin_datums)
		var/datum/admins/D = admin_datums[adm_ckey]
		if(!D)
			continue
		var/rank = D.rank ? D.rank : "*none*"
		var/rights = rights2text(D.rights," ")
		if(!rights)
			rights = "*none*"
		output += {"<tr>
<td style='text-align:right;'>[adm_ckey] <a class='small' href='?src=\ref[src];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>
<td><a href='?src=\ref[src];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>
<td><a class='small' href='?src=\ref[src];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></font></td>
</tr>"}

		/*output += "<tr>"

		output += {"<td style='text-align:right;'>[adm_ckey] <a class='small' href='?src=\ref[src];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>
<td><a href='?src=\ref[src];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>
<td><a class='small' href='?src=\ref[src];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></font></td>"}
		output += "</tr>"*/

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=editrights;size=600x500")

/datum/admins/proc/log_admin_rank_modification(var/adm_ckey, var/new_rank)
	if(config.admin_legacy_system)
		return

	if(!usr.client)
		return

	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='warning'>You do not have permission to do this!</span>")
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/datum/DBQuery/select_query = SSdbcore.NewQuery("SELECT id FROM erro_admin WHERE ckey = :adm_ckey", list("adm_ckey" = "[adm_ckey]"))
	if(!select_query.Execute())
		message_admins("Error: [select_query.ErrorMsg()]")
		log_sql("Error: [select_query.ErrorMsg()]")
		qdel(select_query)
		return

	var/new_admin = 1
	var/admin_id
	while(select_query.NextRow())
		new_admin = 0
		admin_id = text2num(select_query.item[1])
	qdel(select_query)
	if(new_admin)
		var/datum/DBQuery/insert_query = SSdbcore.NewQuery("INSERT INTO `erro_admin` (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, :adm_ckey, :new_rank, -1, 0)",
			list(
				"adm_ckey" = "[adm_ckey]",
				"new_rank" = "[new_rank]",
		))
		if(!insert_query.Execute())
			message_admins("Error: [insert_query.ErrorMsg()]")
			log_sql("Error: [insert_query.ErrorMsg()]")
			qdel(insert_query)
			return
		qdel(insert_query)
		var/datum/DBQuery/log_query = SSdbcore.NewQuery("INSERT INTO [sqlfdbkdb].`erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , :ckey, :address, :log_text)",
		list(
			"ckey" = "[usr.ckey]",
			"address" = "[usr.client.address]",
			"log_text" = "Added new admin [adm_ckey] to rank [new_rank]",
		)) // FIXME: [sqlfdbkdb] is the default name of the feedback DB.
		if(!log_query.Execute())
			message_admins("Error: [log_query.ErrorMsg()]")
			log_sql("Error: [log_query.ErrorMsg()]")
			qdel(log_query)
			return
		qdel(log_query)
		to_chat(usr, "<span class='notice'>New admin added.</span>")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/datum/DBQuery/insert_query = SSdbcore.NewQuery("UPDATE `erro_admin` SET rank = :new_rank WHERE id = :admin_id",
				list(
					"new_rank" = "[new_rank]",
					"admin_id" = "[admin_id]",
			))
			if(!insert_query.Execute())
				message_admins("Error: [insert_query.ErrorMsg()]")
				log_sql("Error: [insert_query.ErrorMsg()]")
				qdel(insert_query)
				return
			qdel(insert_query)
			var/datum/DBQuery/log_query = SSdbcore.NewQuery("INSERT INTO [sqlfdbkdb].`erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , :ckey, :address, :log_text)",
				list(
					"ckey" = "[usr.ckey]",
					"address" = "[usr.client.address]",
					"log_text" = "Edited the rank of [adm_ckey] to [new_rank]"
				)) // FIXME: [sqlfdbkdb] is the default name of the feedback DB.
			if(!log_query.Execute())
				message_admins("Error: [log_query.ErrorMsg()]")
				log_sql("Error: [log_query.ErrorMsg()]")
				qdel(log_query)
				return
			qdel(log_query)
			to_chat(usr, "<span class='notice'>Admin rank changed.</span>")

/datum/admins/proc/log_admin_permission_modification(var/adm_ckey, var/new_permission)
	if(config.admin_legacy_system)
		return

	if(!usr.client)
		return

	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='warning'>You do not have permission to do this!</span>")
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	if(!adm_ckey || !new_permission)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(istext(new_permission))
		new_permission = text2num(new_permission)

	if(!istext(adm_ckey) || !isnum(new_permission))
		return

	var/datum/DBQuery/select_query = SSdbcore.NewQuery("SELECT id, flags FROM erro_admin WHERE ckey = :adm_ckey", list("adm_ckey" = "[adm_ckey]"))
	if(!select_query.Execute())
		message_admins("Error: [select_query.ErrorMsg()]")
		log_sql("Error: [select_query.ErrorMsg()]")
		qdel(select_query)
		return

	var/admin_id
	var/admin_rights
	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])
		admin_rights = text2num(select_query.item[2])
	qdel(select_query)
	if(!admin_id)
		return

	if(admin_rights & new_permission) //This admin already has this permission, so we are removing it.
		var/datum/DBQuery/insert_query = SSdbcore.NewQuery("UPDATE `erro_admin` SET flags = :flags WHERE id = :admin_id",
			list(
				"flags" = (admin_rights & ~new_permission),
				"admin_id" = admin_id
			))
		if(!insert_query.Execute())
			message_admins("Error: [insert_query.ErrorMsg()]")
			log_sql("Error: [insert_query.ErrorMsg()]")
			qdel(insert_query)
			return
		qdel(insert_query)
		var/datum/DBQuery/log_query = SSdbcore.NewQuery("INSERT INTO [sqlfdbkdb].`erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , :ckey, :address, :log_text)",
		 	list(
				 "ckey" = "[usr.ckey]",
				 "address" = "[usr.client.address]",
				 "log_text" = "Removed permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]",
			 ))
		if(!log_query.Execute())
			message_admins("Error: [log_query.ErrorMsg()]")
			log_sql("Error: [log_query.ErrorMsg()]")
			qdel(log_query)
			return
		qdel(log_query)
		to_chat(usr, "<span class='notice'>Permission removed.</span>")
	else //This admin doesn't have this permission, so we are adding it.
		var/datum/DBQuery/insert_query = SSdbcore.NewQuery("UPDATE `erro_admin` SET flags = :flags WHERE id = :admin_id",
			list(
				"flags" = (admin_rights | new_permission),
				"admin_id" = admin_id,
		))
		if(!insert_query.Execute())
			message_admins("Error: [insert_query.ErrorMsg()]")
			log_sql("Error: [insert_query.ErrorMsg()]")
			qdel(insert_query)
			return
		qdel(insert_query)
		var/datum/DBQuery/log_query = SSdbcore.NewQuery("INSERT INTO [sqlfdbkdb].`erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , :ckey, :address, :log_text)",
		 	list(
				 "ckey" = "[usr.ckey]",
				 "address" = "[usr.client.address]",
				 "log_text" = "Added permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]",
		))
		if(!log_query.Execute())
			message_admins("Error: [log_query.ErrorMsg()]")
			log_sql("Error: [log_query.ErrorMsg()]")
			qdel(log_query)
			return
		qdel(log_query)
		to_chat(usr, "<span class='notice'>Permission added.</span>")
