/*
 * Library Computer
 */

#define MAIN_MENU 0
#define INVENTORY 1
#define CHECKED_OUT 2
#define CHECKOUT_BOOK 3
#define EXTERNAL_ARCHIVE 4
#define UPLOAD_NEW_TITLE 5
#define PRINT_BIBLE 6
#define PRINT_MANUAL 7
#define FORBIDDEN_LORE 8
#define PRINT_QUEUE 9

/obj/machinery/computer/library/checkout
	name = "Check-In/Out Computer"
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	req_access = list(access_library) //This access requirement is currently only used for the delete button showing and importing inventories
	var/arcanecheckout = 0
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive

	var/busy = 0
	var/book_cooldown = 6 SECONDS
	var/max_queue_size = 10
	var/list/printing_queue = list()
	var/booklist
	pass_flags = PASSTABLE
	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK | SHUTTLEWRENCH

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

	var/last_id_processed = -1

/obj/machinery/computer/library/checkout/Destroy()
	QDEL_LIST(printing_queue)
	checkouts.Cut()
	inventory.Cut()
	scanner = null
	..()

/obj/machinery/computer/library/checkout/attack_hand(var/mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/library/checkout/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat=""
	switch(screenstate)
		if(MAIN_MENU)
			// Main Menu

			dat += {"<ol>
				<li><A href='?src=\ref[src];switchscreen=[INVENTORY]'>View General Inventory</A></li>
				<li><A href='?src=\ref[src];switchscreen=[CHECKED_OUT]'>View Checked Out Inventory</A></li>
				<li><A href='?src=\ref[src];switchscreen=[CHECKOUT_BOOK]'>Check out a Book</A></li>
				<li><A href='?src=\ref[src];switchscreen=[EXTERNAL_ARCHIVE]'>Connect to External Archive</A></li>
				<li><A href='?src=\ref[src];switchscreen=[UPLOAD_NEW_TITLE]'>Upload New Title to Archive</A></li>
				<li><A href='?src=\ref[src];switchscreen=[PRINT_BIBLE]'>Print a Bible</A></li>
				<li><A href='?src=\ref[src];switchscreen=[PRINT_MANUAL]'>Print a Manual</A></li>
				<li><A href='?src=\ref[src];switchscreen=[PRINT_QUEUE]'>View Queue</A></li>"}
			if(src.emagged)
				dat += "<li><A href='?src=\ref[src];switchscreen=[FORBIDDEN_LORE]'>Access the Forbidden Lore Vault</A></li>"
			dat += "</ol>"

			if(src.arcanecheckout)
				new /obj/item/weapon/tome(src.loc)
				to_chat(user, "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a dusty old tome sitting on the desk. You don't really remember printing it.</span>")
				user.visible_message("[user] stares at the blank screen for a few moments, his expression frozen in fear. When he finally awakens from it, he looks a lot older.", 2)
				src.arcanecheckout = 0
		if(INVENTORY)
			// Inventory
			dat += "<h3>Inventory</h3>"
			for(var/obj/item/weapon/book/b in inventory)
				dat += "[b.name] <A href='?src=\ref[src];delbook=\ref[b]'>(Delete)</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A><BR>"
		if(CHECKED_OUT)
			// Checked Out
			dat += "<h3>Checked Out Books</h3><BR>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)

				dat += {"\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>
					<A href='?src=\ref[src];checkin=\ref[b]'>(Check In)</A><BR><BR>"}
			dat += "<A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A><BR>"
		if(CHECKOUT_BOOK)
			// Check Out a Book

			dat += {"<h3>Check Out a Book</h3><BR>
				Book: [src.buffer_book]
				<A href='?src=\ref[src];editbook=1'>\[Edit\]</A><BR>
				Recipient: [src.buffer_mob]
				<A href='?src=\ref[src];editmob=1'>\[Edit\]</A><BR>
				Checkout Date : [world.time/600]<BR>
				Due Date: [(world.time + checkoutperiod)/600]<BR>
				(Checkout Period: [checkoutperiod] minutes) (<A href='?src=\ref[src];increasetime=1'>+</A>/<A href='?src=\ref[src];decreasetime=1'>-</A>)
				<A href='?src=\ref[src];checkout=1'>(Commit Entry)</A><BR>
				<A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A><BR>"}
		if(EXTERNAL_ARCHIVE)
			dat += "<h3>External Archive</h3>"
			if(!SSdbcore.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				num_results = src.get_num_results()
				num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
				dat += {"<ul>
					<li><A href='?src=\ref[src];id=-1'>(Order book by SS<sup>13</sup>BN)</A></li>
				</ul>"}
				var/pagelist = get_pagelist()

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
						<td>Description</td>
						<td>Controls</td>
					</tr>"}

				for(var/datum/cachedbook/CB in get_page(page_num))
					if(CB) last_id_processed = CB.id
					var/author = CB.author
					var/controls =  "<A href='?src=\ref[src];preview=[CB.id]'>\[Preview\]</A> <A href='?src=\ref[src];id=[CB.id]'>\[Order\]</A>"
					if(isAdminGhost(user))
						author += " (<A style='color:red' href='?src=\ref[src];delbyckey=[ckey(CB.ckey)]'>[ckey(CB.ckey)])</A>)"
					if(isAdminGhost(user) || allowed(user))
						controls +=  " <A style='color:red' href='?src=\ref[src];del=[CB.id]'>\[Delete\]</A>"
					dat += {"<tr>
						<td>[author]</td>
						<td>[CB.title] ([CB.id])</td>
						<td>[CB.category]</td>
						<td>[CB.description]</td>
						<td>
							[controls]
						</td>
					</tr>"}

				dat += "</table><br />[pagelist]"

			dat += "<br /><A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A><BR>"
		if(UPLOAD_NEW_TITLE)
			dat += "<h3>Upload a New Title</h3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9, src))
					scanner = S
					break
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else

				dat += {"<TT>Data marked for upload...</TT><BR>
					<TT>Title: </TT>[scanner.cache.name]<BR>"}
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"

				dat += {"<TT>Author: </TT><A href='?src=\ref[src];uploadauthor=1'>[scanner.cache.author]</A><BR>
					<TT>Category: </TT><A href='?src=\ref[src];uploadcategory=1'>[upload_category]</A><BR>
					<A href='?src=\ref[src];upload=1'>\[Upload\]</A><BR>"}
			dat += "<A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A><BR>"
		if(PRINT_MANUAL)
			dat += "<H3>Print a Manual</H3>"
			dat += "<table>"

			var/list/forbidden = list(
				/obj/item/weapon/book/manual
			)

			if(!emagged)
				forbidden |= /obj/item/weapon/book/manual/nuclear

			var/obj/item/weapon/book/manual/M = null

			for(var/manual_type in typesof(/obj/item/weapon/book/manual))
				if (!(manual_type in forbidden))
					M = manual_type
					dat += "<tr><td><A href='?src=\ref[src];manual=[initial(M.id)]'>[initial(M.title)]</A></td></tr>"
			dat += "</table>"
			dat += "<BR><A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A><BR>"

		if(FORBIDDEN_LORE)

			dat += {"<h3>Accessing Forbidden Lore Vault v 1.3</h3>
				Are you absolutely sure you want to proceed? EldritchTomes Inc. takes no responsibilities for loss of sanity resulting from this action.<p>
				<A href='?src=\ref[src];arccheckout=1'>Yes.</A><BR>
				<A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>No.</A><BR>"}

		if(PRINT_QUEUE)
			dat += "<h3>Printer Queue</h3>"
			dat += "   <A href='?src=\ref[src];clearqueue=1'>Stop the presses!</A><BR>"
			dat += "   <A href='?src=\ref[src];import_template=1'>Import Template</A><BR><BR><BR>"
			for(var/obj/item/B in printing_queue)
				dat+="[B.name] <A href='?src=\ref[src];delqueue=[printing_queue.Find(B)]'>(Delete)</A><BR>"
			dat+= "<A href='?src=\ref[src];switchscreen=[MAIN_MENU]'>(Return to main menu)</A>"

	var/datum/browser/B = new /datum/browser/clean(user, "library", "Book Inventory Management")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/checkout/emag_act(mob/user)
	if(!emagged)
		src.emagged = 1
		if(user)
			to_chat(user, "<span class='notice'>You override the library computer's printing restrictions.</span>")
		return 1
	return

/obj/machinery/computer/library/checkout/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		scanner.computer = src
		to_chat(user, "[scanner]'s associated machine has been set to [src].")
		for (var/mob/V in hearers(src))
			V.show_message("[src] lets out a low, short blip.", 2)
	else
		return ..()

/obj/machinery/computer/library/checkout/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=library")
		onclose(usr, "library")
		return 1

	if(href_list["pagenum"])
		if(!num_pages)
			page_num = 0
		else
			var/pn = text2num(href_list["pagenum"])
			if(!isnull(pn))
				page_num = clamp(pn, 0, num_pages)

	if(href_list["page"])
		if(num_pages == 0)
			page_num = 0
		else
			page_num = clamp(text2num(href_list["page"]), 0, num_pages)
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

	if(href_list["search"])
		num_results = src.get_num_results()
		num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
		page_num = 0
		screenstate = EXTERNAL_ARCHIVE

	if(href_list["del"])
		if(!allowed(usr))
			to_chat(usr,"<span class='warning'>You do not have access to make deletion requests.</span>")
			return
		if(!isAdminGhost(usr)) //old: !usr.check_rights(R_ADMIN)
			to_chat(usr, "<span class='notice'>Your deletion request has been transmitted to Central Command.</span>")
			request_delete_item(getItemByID(href_list["del"], library_table),usr)
		else
			delete_item(getItemByID(href_list["del"], library_table), usr)

	if(href_list["delbyckey"])
		if(!usr.check_rights(R_ADMIN))
			to_chat(usr, "You aren't an admin, piss off.")
			return
		var/tckey = ckey(href_list["delbyckey"])
		var/ans = alert(usr,"Are you sure you wish to delete all books by [tckey]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/datum/DBQuery/query = SSdbcore.NewQuery("DELETE FROM `[library_table]` WHERE ckey=:tckey", list("tckey" = tckey))
			var/datum/DBQuery/response = query.Execute()
			if(!response)
				to_chat(usr, query.ErrorMsg())
				qdel(query)
				return
			if(response.item.len==0)
				to_chat(usr, "<span class='danger'>Unable to find any matching rows.</span>")
				qdel(query)
				return
			log_admin("[src]: [usr.name]/[usr.key] has deleted [response.item.len] books written by [tckey]!")
			message_admins("[key_name_admin(usr)] has deleted [response.item.len] books written by [tckey]!")
			qdel(query)
			src.updateUsrDialog()
			return

	if(href_list["switchscreen"])
		var/command = text2num(href_list["switchscreen"])
		if(command == PRINT_BIBLE)
			if(!busy || printing_queue.len<max_queue_size)
				var/obj/item/weapon/storage/bible/B = new
				B = new(src)
				if (usr.mind && usr.mind.faith) // The user has a faith
					var/datum/religion/R = usr.mind.faith
					var/obj/item/weapon/storage/bible/HB = R.holy_book
					if (!HB)
						B = chooseBible(R, usr)
					else
						B.icon_state = HB.icon_state
						B.item_state = HB.item_state
					B.name = R.bible_name
					B.my_rel = R

				else if (ticker.religions.len) // No faith
					var/datum/religion/R = input(usr, "Which holy book?") as anything in ticker.religions
					if(!R.holy_book)
						return
					B.icon_state = R.holy_book.icon_state
					B.item_state = R.holy_book.item_state
					B.name = R.bible_name
					B.my_rel = R
				printbook(B)

			else
				visible_message("<b>[src]</b>'s monitor flashes, \"Printer queue is full.\"")
		else
			screenstate = command
	if(href_list["arccheckout"])
		if(src.emagged)
			src.arcanecheckout = 1
		src.screenstate = MAIN_MENU
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = copytext(sanitize(input("Enter the book's title:") as text|null),1,MAX_MESSAGE_LEN)
	if(href_list["editmob"])
		buffer_mob = copytext(sanitize(input("Enter the recipient's name:") as text|null),1,MAX_NAME_LEN)
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = sanitize(buffer_book)
		b.mobname = sanitize(buffer_mob)
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"])
		checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/weapon/book/b = locate(href_list["delbook"])
		inventory.Remove(b)
	if(href_list["uploadauthor"])
		var/newauthor = copytext(sanitize(input("Enter the author's name: ") as text|null),1,MAX_MESSAGE_LEN)
		if(newauthor && scanner)
			scanner.cache.author = newauthor
	if(href_list["uploadcategory"])
		var/newcategory = input("Choose a category: ") in library_section_names
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(!scanner)
			for(var/obj/machinery/libraryscanner/S in range(9))
				scanner = S
				break
		if(!scanner)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		if(scanner)
			if(has_cached_data())
				var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(!SSdbcore.Connect())
						alert("Connection to Archive has been severed. Aborting.")
					else
						var/sqltitle = get_scanner_title(scanner)
						var/sqlauthor = get_scanner_author(scanner)
						var/sqlcontent = get_scanner_dat(scanner)
						var/sqlcategory = get_scanner_category(scanner, upload_category)
						var/sqldesc = get_scanner_desc(scanner)
						var/datum/DBQuery/query = SSdbcore.NewQuery("INSERT INTO [library_table] (author, title, content, category, description, ckey) VALUES (:author, :title, :content, :category, :description, :ckey)",
							list(
								"author" = sqlauthor,
								"title" =  sqltitle,
								"content" = sqlcontent,
								"category" = sqlcategory,
								"description" = sqldesc,
								"ckey" = "[ckey(usr.key)]"
							))
						var/response = query.Execute()
						if(!response)
							to_chat(usr, query.ErrorMsg())
						else
							if (scanner.cache)
								log_admin("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] characters in length")
								message_admins("[key_name_admin(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] characters in length")
							else if (scanner.cached_painting)
								log_admin("[usr.name]/[usr.key] has uploaded the painting titled [scanner.cached_painting.name]")
								message_admins("[key_name_admin(usr)] has uploaded the painting titled [scanner.cached_painting.name]")
						qdel(query)

	if(href_list["id"])
		if(href_list["id"]=="-1")
			href_list["id"] = input("Enter your order:") as null|num
			if(!href_list["id"])
				return

		if(!SSdbcore.IsConnected())
			to_chat(usr,"<span class='warning'>Connection to Archive has been severed. Aborting.</span>")
			return

		var/datum/cachedbook/newbook = getItemByID(href_list["id"], library_table) // Sanitized in getItemByID
		if(!newbook || !newbook.id)
			to_chat(usr,"<span class='warning'>No book found!</span>")
			return
		if((newbook.forbidden == 2 && !emagged) || newbook.forbidden == 1)
			to_chat(usr,"<span class='warning'>This book is forbidden and cannot be printed!</span>")
			return
		if(busy && printing_queue.len>=max_queue_size)
			to_chat(usr,"<span class='warning'>The printer queue is full!</span>")
			return
		make_external_book(newbook, FALSE)

	if(href_list["manual"])
		if(!href_list["manual"])
			return
		if(busy && printing_queue.len>=max_queue_size)
			to_chat(usr,"<span class='warning'>The printer queue is full!</span>")
			return
		var/manual_id = text2num(href_list["manual"])
		var/the_manual_type
		for (var/manual_type in typesof(/obj/item/weapon/book/manual))
			var/obj/item/weapon/book/manual/M = manual_type
			if (initial(M.id) == manual_id)
				the_manual_type = manual_type
				break

		if (!the_manual_type)
			visible_message("<b>[src]</b>'s monitor flashes, \"The manual requested cannot be found in the database. Please contact an administrator.\"")
			return
		var/obj/newmanual = new the_manual_type(src)
		printbook(newmanual)

	if(href_list["preview"])
		var/datum/cachedbook/PVB = getItemByID(href_list["preview"], library_table)
		if(!istype(PVB) || PVB.programmatic)
			return
		/*var/list/_http = world.Export("[config.library_url]?id=[PVB.id]")
		if(!_http || !_http["CONTENT"])
			return
		var/http = file2text(_http["CONTENT"])
		if(!http)
			return*/
		usr << browse("<TT><I>[PVB.title] by [PVB.author].</I></TT> <BR>" + "[PVB.content]", "window=[PVB.title];size=600x800")

	if(href_list["delqueue"])
		var/slot = text2num(href_list["delqueue"])
		var/obj/O = printing_queue[slot]
		if(O)
			printing_queue-=O
			qdel(O)

	if(href_list["clearqueue"])
		for(var/obj/O in printing_queue)
			printing_queue-=O
			qdel(O)

	if(href_list["import_template"])
		if(!SSdbcore.IsConnected())
			to_chat(usr,"<span class='warning'>Connection to Archive has been severed. Aborting.</span>")
			return
		if(printing_queue.len)
			to_chat(usr,"<span class='warning>Cannot load a template while there is a printing queue.</span>")
			return
		if(!allowed(usr))
			to_chat(usr,"<span class='warning>Large print jobs are only permitted for library staff.</span>")
			return
		var/code = input("Input exported library template code:","Large Order","") as message|null
		if(!code || (!issilicon(usr) && !Adjacent(usr)))
			return
		var/list/full_template = splittext(code,",")
		if(full_template.len>10)
			var/confirm=alert("Are you sure you wish to queue this print job? It is [full_template.len] items long.","Large Order","Yes","No")
			if(confirm == "No")
				return
		for(var/element in full_template)
			var/getid = text2num(element)
			if(!isnum(getid))
				continue
			var/datum/cachedbook/newbook = getItemByID(getid, library_table) // Sanitized in getItemByID
			if(!newbook || !newbook.id)
				continue
			if((newbook.forbidden == 2 && !emagged) || newbook.forbidden == 1)
				continue
			make_external_book(newbook, TRUE)
			screenstate = PRINT_QUEUE
	/*if(href_list["export_template"])
		var/output_code = ""
		var(for/obj/item/I in inventory)
			output_code += get_id_by_content(I)

		Needs query support
	*/


	add_fingerprint(usr)
	updateUsrDialog()

//If already printing but less than max_queue_size items in queue, attempts to add to queue
//If not busy, prints immediately and initiates loop
//Forcequeue: add it even if already over max queue size
/obj/machinery/computer/library/checkout/proc/printbook(obj/item/B, forcequeue=FALSE)
	if(busy)
		if(forcequeue || (printing_queue.len<max_queue_size))
			printing_queue+=B
		return //Sanity
	playsound(loc, "sound/effects/dotmatrixprinter.ogg", 40, 1)
	anim(target = src, a_icon = 'icons/obj/library.dmi', flick_anim = "computer_ani")
	busy = TRUE
	spawn(1.4 SECONDS)
		B.forceMove(loc)
	spawn(book_cooldown)
		busy = FALSE
		if(printing_queue.len)
			var/obj/item/I = printing_queue[1]
			printing_queue-=I
			printbook(I)
			updateUsrDialog()


/obj/machinery/computer/library/checkout/proc/delete_item(var/datum/cachedbook/B, mob/user)
	if(!istype(B) || !user)
		return
	if(!user.check_rights(R_ADMIN))
		return
	var/ans = alert(user, "Are you sure you wish to delete \"[B.title]\", by [B.author]? This cannot be undone.", "c System", "Yes", "No")
	if(ans!="Yes")
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery("DELETE FROM `[library_table]` WHERE id=:id", list("library_table" = library_table, "id" = "[B.id]"))
	var/response = query.Execute()
	if(!response)
		to_chat(user, query.ErrorMsg())
		qdel(query)
		return
	log_admin("[src]: [user.name]/[user.key] has deleted \"[B.title]\", by [B.author] ([B.ckey])!")
	message_admins("[key_name_admin(user)] has deleted \"[B.title]\", by [B.author] ([B.ckey])!")
	src.updateUsrDialog()
	qdel(query)

/obj/machinery/computer/library/checkout/proc/request_delete_item(var/datum/cachedbook/B, mob/requester)
	log_admin("[src]: [requester.name]/[requester.key] requested [B.title] be deleted permanently.")
	var/raw = "[src]: Request to permanently delete [B] from the library database. <A href='?src=\ref[src];preview=[B.id]'>\[Preview\]</A> <A style='color:red' href='?src=\ref[src];del=[B.id]'>\[Delete\]</A>"
	var/formal = "<span class='notice'><b>  [src]: [key_name(requester, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[requester]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[requester]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[requester]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[requester]'>JMP</A>) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>) (<a href='?_src_=holder;role_panel=\ref[requester]'>RP</a>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[requester]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[requester]'>RPLY</A>):</b> [raw]</span>"
	send_prayer_to_admins(formal, raw, 'sound/effects/msn.ogg', "Centcomm", key_name(requester), get_turf(requester))

/obj/machinery/computer/library/checkout/proc/get_scanner_title(var/obj/machinery/libraryscanner/LS)
	return LS.cache.title || "Untitled Book"

/obj/machinery/computer/library/checkout/proc/get_scanner_author(var/obj/machinery/libraryscanner/LS)
	return LS.cache.author || "Anonymous"

/obj/machinery/computer/library/checkout/proc/get_scanner_dat(var/obj/machinery/libraryscanner/LS)
	return LS.cache.dat || "..."

/obj/machinery/computer/library/checkout/proc/get_scanner_category(var/obj/machinery/libraryscanner/LS, var/upload_category)
	return upload_category || "Fiction"

/obj/machinery/computer/library/checkout/proc/get_scanner_desc(var/obj/machinery/libraryscanner/LS)
	return LS.cache.book_desc || "No description available"

/obj/machinery/computer/library/checkout/proc/has_cached_data()
	return scanner.cache

/*
 * Library Scanner
 */

/obj/machinery/computer/library/checkout/proc/make_external_book(var/datum/cachedbook/newbook, forceprint = FALSE)
	if(!newbook || !newbook.id)
		return
	var/obj/item/weapon/book/B = new newbook.path(src)

	if (!newbook.programmatic)
		/*var/list/_http = world.Export("[config.library_url]?id=[newbook.id]")
		if(!_http || !_http["CONTENT"])
			return
		var/http = file2text(_http["CONTENT"])
		if(!http)
			return*/
		B.name = "Book: [newbook.title]"
		B.title = newbook.title
		B.author = newbook.author
		//B.dat = http
		B.dat = newbook.content
		if(newbook.cover)
			B.icon_state = newbook.cover
		else
			B.icon_state = "book[rand(1,9)]"
	B.item_state = B.icon_state
	printbook(B, forceprint)

#undef MAIN_MENU
#undef INVENTORY
#undef CHECKED_OUT
#undef CHECKOUT_BOOK
#undef EXTERNAL_ARCHIVE
#undef UPLOAD_NEW_TITLE
#undef PRINT_BIBLE
#undef PRINT_MANUAL
#undef FORBIDDEN_LORE
