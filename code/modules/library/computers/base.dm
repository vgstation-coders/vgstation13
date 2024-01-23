/obj/machinery/computer/library
	name = "visitor computer"
	anchored = 1
	density = 1
	var/screenstate = 0
	var/page_num = 0
	var/num_pages = 0
	var/num_results = 0
	var/datum/library_query/query = new()
	var/library_table = "library"
	computer_flags = NO_ONOFF_ANIMS
	pass_flags = PASSTABLE
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	moody_state = "overlay_computer_old"

	var/list/library_section_names = list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")

/obj/machinery/computer/library/proc/interact_check(var/mob/user)
	if(stat & (FORCEDISABLE | BROKEN | NOPOWER))
		return TRUE

	if ((get_dist(src, user) > 1))
		if (!issilicon(user)&&!isobserver(user))
			user.unset_machine()
			user << browse(null, "window=library")
			return TRUE

	user.set_machine(src)
	return FALSE

/obj/machinery/computer/library/proc/get_page(var/page_num)
	if(!query)
		return

	var/list/arguments = list()
	var/list/searchquery_parts = list()

	if(query.title && query.title != "")
//		to_chat(world, "\red query title ([query.title])")
		searchquery_parts += "WHERE title LIKE :query_title"
		arguments["query_title"] = "%[query.title]%"

	if(query.author && query.author != "")
//		to_chat(world, "\red query author ([query.author])")
		searchquery_parts += "[searchquery_parts.len ? "AND" : "WHERE"] author LIKE :query_author"
		arguments["query_author"] = "%[query.author]%"

	if(query.categories && query.categories[1] != "")
		var/list/in_placeholders = list()
		for(var/i=1, i<=query.categories.len, i++)
//		to_chat(world, "\red query category ([query.categories[i]])")
			var/placeholder = ":query_category_[i]"
			in_placeholders += placeholder
			arguments["query_category_[i]"] = query.categories[i]
		searchquery_parts += "[searchquery_parts.len ? "AND" : "WHERE"] category IN ([in_placeholders.Join(", ")])"

	if(query.order_by && (query.order_by in list("author", "title", "category", "id")))
//		to_chat(world, "\red query order_by ([query.order_by])")
		var/option = query.descending ? "DESC" : "ASC"
		searchquery_parts += "ORDER BY [query.order_by] [option]"

	arguments["lim_inf"] = page_num * LIBRARY_BOOKS_PER_PAGE
	arguments["lim_sup"] = LIBRARY_BOOKS_PER_PAGE

	var/searchquery = searchquery_parts.Join(" ")
	var/sql = "SELECT id, author, title, content, category, description, ckey FROM `[library_table]` [searchquery] LIMIT :lim_inf, :lim_sup"

	var/datum/DBQuery/_query = SSdbcore.NewQuery(sql, arguments)
	_query.Execute()
	if(_query.ErrorMsg())
		world.log << _query.ErrorMsg()
		qdel(_query)
		return

	var/list/results = list()
	while(_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =_query.item[1],
			"author"  =_query.item[2],
			"title"   =_query.item[3],
			"content"   =_query.item[4],
			"category"=_query.item[5],
			"description" = _query.item[6],
			"ckey"    =_query.item[7]
		))
		results += CB
	qdel(_query)
	return results

/obj/machinery/computer/library/proc/get_num_results()
	var/sql = "SELECT COUNT(*) FROM `[library_table]`"
	//if(query)
		//sql += query.toSQL()

	var/datum/DBQuery/_query = SSdbcore.NewQuery(sql)
	if(!_query.Execute())
		message_admins("Error: [_query.ErrorMsg()]")
		log_sql("Error: [_query.ErrorMsg()]")
		qdel(_query)
		return
	while(_query.NextRow())
		. = text2num(_query.item[1])
		qdel(_query)
		return
	qdel(_query)
	return 0

/obj/machinery/computer/library/proc/get_pagelist()
	var/pagelist = "<div class='pages'>"
	var/start = max(0,page_num-3)
	var/end = min(num_pages, page_num+3)
	for(var/i = start,i <= end,i++)
		var/dat = "<a href='?src=\ref[src];page=[i]'>[i]</a>"
		if(i == page_num)
			dat = "<font size=3><b>[dat]</b></font>"
		if(i != end)
			dat += " "
		pagelist += dat
	pagelist += "</div>"
	return pagelist

/obj/machinery/computer/library/proc/getItemByID(var/id, var/library_table)
	return library_catalog.getItemByID(id, library_table)

/obj/machinery/computer/library/cultify()
	new /obj/structure/cult_legacy/tome(loc)
	..()

/obj/machinery/computer/library/proc/get_sort_arrow(var/column)
	if(query.order_by == column)
		return query.descending ? "↓" : "↑"
	return ""
