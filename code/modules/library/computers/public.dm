/obj/machinery/computer/library/public
	name = "visitor computer"

/obj/machinery/computer/library/public/attack_hand(var/mob/user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/computer/library/public/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat = ""
	switch(screenstate)
		if(0)

			var/list/category_elements = list()
			for(var/i=1,i<=library_section_names.len, ++i)
				category_elements += "<option value='[library_section_names[i]]'>[library_section_names[i]]</option>"
			category_elements = category_elements.Join("")

			var/script = {"
				<script type="text/javascript">
					function toggleForm() {
						var form = document.getElementById('category-form');
						if (form.style.display === 'none' || form.style.display === '') {
							form.style.display = 'block';
						} else {
							form.style.display = 'none';
						}
					}
				</script>"}

			dat += {"<h2>Search Settings</h2><br />
				<A href='?src=\ref[src];settitle=1'>Filter by Title: [query.title]</A><br />
				<A href='?src=\ref[src];setauthor=1'>Filter by Author: [query.author]</A><br />
				<A href="javascript:toggleForm();">Filter by Categories: [query.categories ? query.categories.Join(", ") : ""]</A><br />
				<form id='category-form' name='setcategories' action='?src=\ref[src]' method='get' style='display:none; width: 130px'>
					<input type='hidden' name='src' value='\ref[src]'>
					<input type='hidden' name='setcategories' value='1'>
					<select name='categories' multiple style='width: 100%; height: 80px; display: inline-block;'>
						[category_elements]
					</select>
					<input type='submit' value='Set Categories' onclick='toggleForm();'>
				</form>
				[script]
				[query.order_by ? "Sorting By: [uppertext(copytext(query.order_by, 1, 2))][copytext(query.order_by, 2)] <A href='?src=\ref[src];clearsort=1'>Remove Sort</A><br />" : ""]
				<A href='?src=\ref[src];search=1'>\[Start Search\]</A><br />"}
		if(1)
			if(!SSdbcore.Connect())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><br />"
			else if(num_results == 0)
				dat += "<em>No results found.</em>"
			else
				var/pagelist = get_pagelist()

				dat += pagelist
				dat += {"<form name='pagenum' action='?src=\ref[src]' method='get'>
										<input type='hidden' name='src' value='\ref[src]'>
										<input type='text' name='pagenum' value='[page_num]' maxlength="5" size="5">
										<input type='submit' value='Jump To Page'>
							</form>"}
				dat += {"<table border=\"0\">
					<tr>
						<td><A href='?src=\ref[src];orderby=author'>Author</A> [get_sort_arrow("author")]</td>
						<td><A href='?src=\ref[src];orderby=title'>Title</A> [get_sort_arrow("title")]</td>
						<td style='white-space: nowrap;'><A href='?src=\ref[src];orderby=category'>Category</A> [get_sort_arrow("category")]</td>
						<td style='white-space: nowrap;'><A href='?src=\ref[src];orderby=id'>SS<sup>13</sup>BN</A> [get_sort_arrow("id")]</td>
					</tr>"}
				for(var/datum/cachedbook/CB in get_page(page_num))
					dat += {"<tr>
						<td>[CB.author]</td>
						<td>[CB.title]</td>
						<td>[CB.category]</td>
						<td>[CB.id]</td>
					</tr>"}

				dat += "</table><br />[pagelist]"
			dat += "<A href='?src=\ref[src];back=1'>\[Go Back\]</A><br />"
	var/datum/browser/B = new /datum/browser/clean(user, "library", "Library Visitor")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/public/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["pagenum"])
		if(!num_pages)
			page_num = 0
		else
			var/pn = text2num(href_list["pagenum"])
			if(!isnull(pn))
				page_num = clamp(pn, 0, num_pages)

	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			query.title = sanitize(newtitle)
		else
			query.title = null
	if(href_list["setcategories"])
		var/list/newcategories
		if(!islist(href_list["categories"]))
			newcategories = list(href_list["categories"])
		else
			newcategories = href_list["categories"]
		if(newcategories)
			if("Any" in newcategories)
				query.categories = null
			else
				query.categories = list()
				for(var/category in newcategories)
					query.categories += sanitize(category)
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			query.author = sanitize(newauthor)
		else
			query.author = null
	if(href_list["orderby"])
		var/neworderby = href_list["orderby"]
		if(query.order_by == neworderby)
			query.descending = !query.descending
		else
			query.order_by = neworderby
			query.descending = FALSE

	if(href_list["clearsort"])
		query.order_by = null
		query.descending = FALSE

	if(href_list["page"])
		if(num_pages == 0)
			page_num = 0
		else
			page_num = clamp(text2num(href_list["page"]), 0, num_pages)

	if(href_list["search"])
		num_results = src.get_num_results()
		num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
		page_num = 0

		screenstate = 1

	if(href_list["back"])
		screenstate = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

