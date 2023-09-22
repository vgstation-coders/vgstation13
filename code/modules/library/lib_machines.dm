/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Cachedbook datum from tkdrg, thanks
 *		Library Public Computer
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */

 #define LIBRARY_BOOKS_PER_PAGE 25

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/description
	var/ckey // ADDED 24/2/2015 - N3X
	var/category
	var/content
	var/programmatic=0                // Is the book programmatically added to the catalog?
	var/forbidden=0
	var/path = /obj/item/weapon/book // Type path of the book to generate

/datum/cachedbook/proc/LoadFromRow(var/list/row)
	id = row["id"]
	author = row["author"]
	title = row["title"]
	category = row["category"]
	ckey = row["ckey"]
	description = row["description"]
	if("content" in row)
		content = row["content"]
	programmatic=0

// Builds a SQL statement
/datum/library_query
	var/author
	var/list/categories
	var/title
	var/order_by
	var/descending

	var/category

// So we can have catalogs of books that are programmatic, and ones that aren't.
/datum/library_catalog
	var/list/cached_books = list()

/datum/library_catalog/initialize()
	var/newid=1
	for(var/typepath in typesof(/obj/item/weapon/book/manual)-/obj/item/weapon/book/manual)
		var/obj/item/weapon/book/B = new typepath(null)
		var/datum/cachedbook/CB = new()
		CB.forbidden=B.forbidden
		CB.title = B.name
		CB.author = B.author
		CB.programmatic=1
		CB.path=typepath
		CB.id = "M[newid]"
		newid++
		cached_books["[CB.id]"]=CB


/datum/library_catalog/proc/rmBookByID(var/mob/user, var/id, var/library_table)
	if("[id]" in cached_books)
		var/datum/cachedbook/CB = cached_books["[id]"]
		if(CB.programmatic)
			to_chat(user, "<span class='danger'>That book cannot be removed from the system, as it does not actually exist in the database.</span>")
			return

	var/sqlid = text2num(id)
	if(!sqlid)
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery("DELETE FROM `[library_table]` WHERE id=:id", list("id" = sqlid))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
	qdel(query)

/datum/library_catalog/proc/getItemByID(var/id, var/library_table)
	if("[id]" in cached_books)
		return cached_books["[id]"]

	var/sqlid = text2num(id)
	if(!sqlid)
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT id, author, title, content, category, description, ckey FROM `[library_table]` WHERE id=:id", list("id" = sqlid))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =query.item[1],
			"author"  =query.item[2],
			"title"   =query.item[3],
			"content" = query.item[4],
			"category"=query.item[5],
			"description" =query.item[6],
			"ckey"    =query.item[7]
		))
		cached_books["[id]"]=CB
		qdel(query)
		return CB
	qdel(query)
	return null

var/global/datum/library_catalog/library_catalog = new()

/** Scanner **/
/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book
	var/obj/item/mounted/frame/painting/custom/cached_painting // Last scanned painting

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/libraryscanner/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item(O, src)
	if(istype(O, /obj/item/mounted/frame/painting/custom))
		user.drop_item(O, src)
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(var/mob/user as mob)
	if(istype(user,/mob/dead))
		to_chat(user, "<span class='danger'>Nope.</span>")
		return
	usr.set_machine(src)
	var/dat = "<HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache || cached_painting)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache || cached_painting)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=\ref[src];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	user << browse(dat, "window=scanner")
	onclose(user, "scanner")

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/weapon/book/B in contents)
			cache = B
			break
		for (var/obj/item/mounted/frame/painting/custom/C in contents)
			cached_painting = C
			break
	if(href_list["clear"])
		cache = null
		cached_painting = null
	if(href_list["eject"])
		for(var/obj/item/weapon/book/B in contents)
			B.forceMove(src.loc)
		for (var/obj/item/mounted/frame/painting/custom/C in contents)
			C.forceMove(src.loc)
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/bookbinder/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/paper/nano))
		if(user.drop_item(O, src))
			user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
			src.visible_message("[src] begins to hum as it warms up its printing drums.")
			sleep(rand(200,400))
			src.visible_message("[src] whirs as it prints and binds a new book.")
			var/obj/item/weapon/book/b = new(src.loc)
			b.dat = O:info
			b.name = "Print Job #[rand(100, 999)]"
			b.icon_state = "book[rand(1,9)]"
			b.item_state = b.icon_state
			QDEL_NULL(O)
	else
		return ..()
