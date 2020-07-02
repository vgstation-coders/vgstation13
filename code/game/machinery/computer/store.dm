/obj/machinery/computer/merch
	name = "Merch Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "store"
	circuit = "/obj/item/weapon/circuitboard/merch"
	var/datum/html_interface/interface
	var/tmp/next_process = 0
	var/machine_id = ""

	light_color = LIGHT_COLOR_ORANGE

	var/categories = list(
		"Food" = list(
			/datum/storeitem/menu1,
			/datum/storeitem/menu2,
			),
		"Tools" = list(
			/datum/storeitem/pen,
			/datum/storeitem/wrapping_paper,
			),
		"Electronics" = list(
			/datum/storeitem/boombox,
			/datum/storeitem/diskettebox,
			/datum/storeitem/diskettebox_large,
			),
		"Toys" = list(
			/datum/storeitem/beachball,
			/datum/storeitem/snap_pops,
			/datum/storeitem/crayons,
			///datum/storeitem/dorkcube,
			/datum/storeitem/unecards,
			/datum/storeitem/roganbot,
			),
		"Clothing" = list(
			/datum/storeitem/robotnik_labcoat,
			/datum/storeitem/robotnik_jumpsuit,
			),
		"Luxury" = list(
			/datum/storeitem/wallet,
			/datum/storeitem/photo_album,
			/datum/storeitem/painting,
			),
		)

/obj/machinery/computer/merch/New()
	..()
	if(Holiday == VALENTINES_DAY)
		var/valentines = list("Valentine's Day" = list(/datum/storeitem/valentinechocolatebar,),)
		categories += valentines

	machine_id = "[station_name()] Merch Computer #[multinum_display(num_merch_computers,4)]"
	num_merch_computers++

	var/head = {"
		<style type="text/css">
			span.area
			{
				display: block;
				white-space: nowrap;
				text-overflow: ellipsis;
				overflow: hidden;
				width: auto;
			}
		</style>
	"}

	src.interface = new/datum/html_interface/nanotrasen(src, src.name, 800, 700, head)
	html_machines += src

	refresh_ui()

/obj/machinery/computer/merch/proc/refresh_ui()

	var/dat = {"<tbody id="StoreTable">"}

	for(var/category_name in categories)
		var/list/category_items = categories[category_name]
		dat += {"
			<table>
			<th><h2>[category_name]</h2></th>
			"}
		for(var/store_item in category_items)
			dat += make_div(store_item)

		dat += "</table>"

	dat += "</tbody>"

	interface.updateLayout(dat)

/obj/machinery/computer/merch/Destroy()
	..()
	html_machines -= src
	qdel(interface)
	interface = null

/obj/item/weapon/circuitboard/merch
	name = "\improper Merchandise Computer Circuitboard"
	build_path = /obj/machinery/computer/merch

/obj/machinery/computer/merch
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU | PURCHASER

/obj/machinery/computer/merch/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/merch/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/merch/proc/make_div(var/store_ID)
	var/datum/storeitem/SI = centcomm_store.items["[store_ID]"]
	if(SI.stock == 0)
		return "<tr><td><i>[SI.name] (SOLD OUT)</i></td></tr>"
	else
		. = "<tr><td><A href='?src=\ref[src];choice=buy;chosen_item=[store_ID]'>[SI.name] ([!(SI.cost) ? "free" : "[SI.cost]$"])"
		if(SI.stock != -1)
			. += " ([SI.stock] left!)"
		. += "</A></td></tr>"

		. += "<tr><td><i>[SI.desc]</i></td></tr>"

/obj/machinery/computer/merch/attack_hand(var/mob/user)
	. = ..()
	if(.)
		interface.hide(user)
		return

	refresh_ui()
	interact(user)

/obj/machinery/computer/merch/interact(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(user.stat || user.restrained() || !allowed(user))
		return

	interface.show(user)

/obj/machinery/computer/merch/Topic(href, href_list)
	if(..())
		return

	src.add_fingerprint(usr)

	switch(href_list["choice"])
		if ("buy")
			var/itemID = href_list["chosen_item"]
			if(!centcomm_store.PlaceOrder(usr,itemID,src))
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to charge your account.</span>")
			else
				to_chat(usr, "[bicon(src)]<span class='notice'>Transaction complete! Enjoy your product.</span>")

	src.refresh_ui()
	return

/obj/machinery/computer/merch/update_icon()

	if(stat & BROKEN)
		icon_state = "comm_logsb"
	else if(stat & NOPOWER)
		icon_state = "comm_logs0"
	else
		icon_state = initial(icon_state)
