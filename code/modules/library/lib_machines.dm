/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Cachedbook datum from tkdrg, thanks
 *		Library Public Computer
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 *		Research Archive
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
	var/cover //icon_state of the book

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
	desc = "The scanner is used in the process of registering a book or painting for permanent archive in the external library and gallery."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book
	var/obj/item/mounted/frame/painting/custom/cached_painting // Last scanned painting

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/libraryscanner/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/book) || istype(O, /obj/item/mounted/frame/painting/custom))
		if(contents.len)
			to_chat(user, "<span class='warning'>Something is already inserted!</span>")
			return
		user.drop_item(O, src)
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(var/mob/user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/libraryscanner/interact(var/mob/user)
	if(istype(user,/mob/dead) && !isAdminGhost(user))
		to_chat(user, "<span class='danger'>You are too ghostly to use the scanner!</span>")
		return
	user.set_machine(src)
	var/dat = "<HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache || cached_painting)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache || cached_painting)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR>"
	else
		dat += "<BR>"
	dat+= "<BR><A href='?src=\ref[src];eject=1'>\[Remove Book\]</A>"
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
	add_fingerprint(usr)
	updateUsrDialog()
	for(var/obj/machinery/computer/library/L in range(9,src))
		L.updateUsrDialog()

/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	desc = "Used in binding ordinary paper into a book that could be archived."
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/bookbinder/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/paper/nano))
		if(user.drop_item(O, src))
			user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
			visible_message("[src] begins to hum as it warms up its printing drums.")
			playsound(loc, 'sound/machines/electric_loom.ogg', 50, 1)
			spawn(3 SECONDS)
				playsound(loc, 'sound/machines/electric_loom.ogg', 50, 1)
			anim(target = src, a_icon = 'icons/obj/library.dmi', flick_anim = "binder_ani", sleeptime = 6 SECONDS)
			sleep(6 SECONDS)
			visible_message("[src] whirs as it prints and binds a new book.")
			var/obj/item/weapon/book/b = new(loc)
			b.dat = O:info
			b.name = "Print Job #[rand(100, 999)]"
			b.icon_state = "book[rand(1,9)]"
			b.item_state = b.icon_state
			QDEL_NULL(O)
	else
		return ..()

var/global/datum/research/research_archive_datum
var/list/important_archivists = list()

/obj/machinery/researcharchive
	name = "research archive"
	desc = "A high-powered data archive device that takes technology disks and persistently backs them up to specialized servers for the upcoming shift. Usually takes two disks per technology."
	icon = 'icons/obj/library.dmi'
	icon_state = "computer_disk"
	var/on_flick = "on_disk"
	var/off_flick = "off_disk"
	anchored = TRUE
	density = TRUE
	machine_flags =  WRENCHMOVE | FIXED2WORK | EJECTNOTDEL // | SCREWTOGGLE | CROWDESTROY
	pass_flags = PASSTABLE
	idle_power_usage = 4
	use_auto_lights = 1
	light_power_on = 1
	light_range_on = 2
	light_color = LIGHT_COLOR_GREEN
	var/obj/item/weapon/disk/tech_disk/diskslot
	var/busy = FALSE

/obj/machinery/researcharchive/New()
	..()
	if(!research_archive_datum)
		research_archive_datum = new /datum/research()
	update_icon()

/obj/machinery/researcharchive/examine(mob/user)
	..()
	to_chat(user,"<span class='info'><b>The research archive contains the following research:</span></b>")
	for(var/datum/tech/T in get_list_of_elements(research_archive_datum.known_tech))
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		if(T.level < min(6,T.goal_level))
			to_chat(user,"<span class='info'>The [T.id] research is level [T.level].")
		else
			to_chat(user,"<span class='good'>The [T.id] research is complete.</span>")

/obj/machinery/researcharchive/power_change()
	..()
	update_icon()

/obj/machinery/researcharchive/update_icon()
	// Broken
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]b"
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_computer_disk")

	// Unpowered/Disabled
	else if(stat & (FORCEDISABLE|NOPOWER))
		if(icon_state != "[initial(icon_state)]0")
			anim(target = src, a_icon = 'icons/obj/computer.dmi', flick_anim = off_flick)
		icon_state = "[initial(icon_state)]0"
		kill_moody_light()

	// Functional
	else
		if(icon_state == "[initial(icon_state)]0")
			anim(target = src, a_icon = 'icons/obj/computer.dmi', flick_anim = on_flick)
		icon_state = initial(icon_state)
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_computer_disk")

/obj/machinery/researcharchive/attackby(var/obj/item/weapon/W, var/mob/user)
	if(stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken!</span>")
		return
	if(..())
		return

	if(busy)
		return

	if (!istype(W,/obj/item/weapon/disk/tech_disk))
		to_chat(user, "<span class='warning'>\The [src] only accepts technology disks.</span>")
		return
	var/obj/item/weapon/disk/tech_disk/TD = W
	if(!TD.stored)
		to_chat(user, "<span class='notice'>\The [W] has no data!</span>")
		return

	if(TD.stored.id in list("syndicate", "Nanotrasen", "anomaly"))
		to_chat(user, "<span class='notice'>\The [src] cannot process this technology data due to proprietary encoding.</span>")
		return

	if (!user.drop_item(W, src))
		return
	if(diskslot)
		user.put_in_hands(diskslot)
		visible_message("<span class='notice'>\The [user] swaps the disks in \the [src].</span>","<span class='notice'>You swap the disks in \the [src].</span>")
	else
		visible_message("<span class='notice'>\The [user] adds \the [W] to \the [src].</span>","<span class='notice'>You add \the [W] to \the [src].</span>")
	diskslot = W
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	update_icon()
	attack_hand(user) //Attempt to archive immediately.

/obj/machinery/researcharchive/attack_hand(var/mob/user)
	. = ..()
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>\The [src] is unpowered.</span>")
		return

	if(!diskslot)
		to_chat(user, "<span class='notice'>There is no inserted technology disk.</span>")
		return

	if(busy)
		return

	playsound(loc, "sound/machines/heps.ogg", 50, 1)
	anim(target = src, a_icon = 'icons/obj/library.dmi', flick_anim = "computer_disk_ani")

	busy = TRUE
	use_power(200)
	spawn(3 SECONDS)

		for(var/datum/tech/T in get_list_of_elements(research_archive_datum.known_tech))
			if(T.id != diskslot.stored.id)
				continue
			if(T.level < diskslot.stored.level)
				if(T.level>=6)
					visible_message("<span class='warning'>\The [src] rejects the data disk as [T.id] data has already reached its maximum.")
					break
				//Pick the lowest: +3 levels, level 6, maximum level of tech, or the maximum level on the disk
				//Example: increase to level 4 in one pass, then increase to level 6 in second pass
				T.level = min(T.level+3, 6, T.max_level, diskslot.stored.level)
				qdel(diskslot)
				diskslot = null
				playsound(loc, "sound/machines/paistartup.ogg", 50, 1)
				visible_message("<span class='good'>\The [src] accepts the data disk, increasing the [T.id] archive to [T.level].</span>")
				if(!(user.real_name in important_archivists))
					important_archivists += user.real_name
				if(is_research_fully_archived())
					command_alert(/datum/command_alert/archive_thanks)
					station_bonus += 800 //one time payment
			else
				playsound(loc, "sound/machines/buzz-sigh.ogg", 50, 1)
				visible_message("<span class='warning'>\The [src] rejects the data disk as it contains no new information.</span>")
				diskslot.forceMove(loc)
				diskslot = null
			break
		busy = FALSE

/obj/machinery/researcharchive/kick_act(var/mob/user)
	..()
	if(!busy)
		diskslot.forceMove(loc)
		diskslot = null

/obj/machinery/researcharchive/proc/admin_research()
	for(var/datum/tech/T in get_list_of_elements(research_archive_datum.known_tech))
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		T.level = min(6,T.goal_level)

/proc/is_research_fully_archived()
	var/archived = TRUE
	for(var/datum/tech/T in get_list_of_elements(research_archive_datum.known_tech))
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		if(T.level < min(6,T.goal_level))
			archived = FALSE
			break
	return archived
