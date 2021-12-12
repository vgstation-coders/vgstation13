/**********************Mineral processing unit console**************************/

/obj/machinery/computer/smelting
	name = "ore processing console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "orecomp"
	density = 1
	anchored = 1
	circuit = "/obj/item/weapon/circuitboard/smeltcomp"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(access_mining)

	var/frequency = FREQ_DISPOSAL //Same as conveyors.
	var/smelter_tag = null
	var/datum/radio_frequency/radio_connection

	var/list/smelter_data //All the data we have about the smelter, since it uses radio connection based RC.

	var/obj/item/weapon/card/id/id //Ref to the inserted ID card (for claiming points via the smelter).

/obj/machinery/computer/smelting/New()
	. = ..()

	if(ticker && ticker.current_state == 3)
		initialize()

/obj/machinery/computer/smelting/initialize()
	set_frequency(frequency)

/obj/machinery/computer/smelting/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/computer/smelting/process()
	updateUsrDialog()

/obj/machinery/computer/smelting/attack_ai(mob/user)
	add_hiddenprint(user)
	interact(user)

/obj/machinery/computer/smelting/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (NOPOWER | BROKEN) && id) //Power out/this thing is broken, but at least allow the guy to take his ID out if it's still in there.
		id.forceMove(get_turf(src))
		user.put_in_hands(id)

		to_chat(user, "<span class='notify'>You pry the ID card out of \the [src]</span>")
		id = null

	interact(user)

/obj/machinery/computer/smelting/interact(mob/user)
	if(stat & (NOPOWER | BROKEN)) //It's broken ya derp.
		if(user.machine == src)
			user.unset_machine(src)
		return

	if(!smelter_data)
		request_status()
		if(!smelter_data) //Still no data.
			to_chat(user, "<span class='warning'>Unable to find an ore processing machine.</span>")
			if(user.machine == src)
				user.unset_machine(src)
			return
	user.set_machine(src)

	var/dat = {"
	<div style="overflow:hidden;">
	<div class="block">
	The ore processor is currently <A href='?src=\ref[src];toggle_power=1' class='[smelter_data["on"] ? "linkOn" : "linkDanger"]'>[smelter_data["on"] ? "processing" : "disabled"]</a>
	"}

	if(smelter_data["credits"] != -1)
		dat += "<br>Current unclaimed credits: $[num2septext(smelter_data["credits"])]<br>"

		if(istype(id))
			dat += "You have [id.GetBalance(format = 1)] credits in your bank account. <A href='?src=\ref[src];eject=1'>Eject ID.</A><br>"
			dat += "<A href='?src=\ref[src];claim=1'>Claim points.</A><br>"
		else
			dat += text("No ID inserted. <A href='?src=\ref[src];insert=1'>Insert ID.</A><br>")

	else if(id)	//I don't care but the ID got in there in some way, allow them to eject it atleast.
		dat += "<br><A href='?src=\ref[src];eject=1'>Eject ID.</A>"

	dat += {"</div>
	<div style="float:left;" class="block">
	<table>
		<tr>
			<th>Mineral</th>
			<th>Amount</th>
		</tr>"}

	for(var/ore_id in smelter_data["ore"])
		dat += {"
		<tr>
			<td>[smelter_data["ore"][ore_id]["name"]]</td>
			<td>[smelter_data["ore"][ore_id]["amount"]]</td>
		</tr>
		"}

	dat += "</table></div>"

	dat += {"
	<div style="float:left;" class="block">
	<b>Available recipes: </b><br>
	<table>
		<tr>
			<th>Output</th>
			<th colspan="2">Priority</th>
		</tr>
	"}
	var/list/recipes = smelter_data["recipes"]

	for(var/datum/smelting_recipe/R in recipes)
		var/idx = recipes.Find(R)

		dat += {"
		<tr>
			<td>[R.name]</td>
		"}

		if(idx != 1)
			dat += {"
			<td><a href='?src=\ref[src];inc_priority=[idx]'>+</a></td>
			"}

		if(idx != recipes.len)
			dat += {"
			<td><a href='?src=\ref[src];dec_priority=[idx]'>-</a></td>
			"}

		dat += {"
		</tr>
		"}

	dat += {"
	</table></div></div>"}


	var/datum/browser/popup = new(user, "console_processing_unit", name, 460, 620, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/smelting/Topic(href, href_list)
	. = ..()
	if(.)
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["close"])
		usr.unset_machine(src)
		return 1

	if(href_list["toggle_power"])
		send_signal(list("toggle_power" = 1))
		request_status()
		return 1

	if(href_list["eject"])
		if(!id)
			return

		id.forceMove(get_turf(src))
		if(usr.Adjacent(src))
			usr.put_in_hands(id)
		id = null
		updateUsrDialog()
		return 1

	if(href_list["claim"])
		send_signal(list("claimcredits" = get_card_account(id)))
		request_status()
		return 1

	if(href_list["insert"])
		if(smelter_data && smelter_data["credits"] == -1)	//No credit mode.
			return 1

		if(id)
			to_chat(usr, "<span class='notify'>There is already an ID in the console!</span>")
			return 1

		if(!allowed(usr))
			to_chat(usr, "<span class='warning'>The machine rejects your access credentials.</span>")
			return 1

		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I))
			if(usr.drop_item(I, src))
				id = I

		updateUsrDialog()
		return 1

	if(href_list["inc_priority"])
		send_signal(list("inc_priority" = text2num(href_list["inc_priority"])))
		updateUsrDialog()
		return 1

	if(href_list["dec_priority"])
		send_signal(list("dec_priority" = text2num(href_list["dec_priority"])))
		updateUsrDialog()
		return 1


/obj/machinery/computer/smelting/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/weapon/card/id))
		if(smelter_data && smelter_data["credits"] == -1)	//No credit mode.
			return 1

		if(id)
			to_chat(usr, "<span class='notify'>There is already an ID in the console!</span>")
			return 1

		if(user.drop_item(W, src))
			id = W
			updateUsrDialog()
			return 1

	. = ..()

//Just a little helper proc
/obj/machinery/computer/smelting/proc/send_signal(list/data)
	if(!frequency)
		return

	var/datum/signal/signal = new /datum/signal
	signal.data["tag"] = smelter_tag
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data += data

	radio_connection.post_signal(src, signal)

/obj/machinery/computer/smelting/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER | BROKEN) || !signal || !signal.data["tag"] || signal.data["tag"] != smelter_tag)
		return

	if(signal.data["type"] != "smelter") //So I can forgo sanity, henk.
		return

	smelter_data = signal.data
	updateUsrDialog()

/obj/machinery/computer/smelting/proc/request_status()
	smelter_data = null
	send_signal(list("sigtype" = "status"))

/obj/machinery/computer/smelting/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","smelter_tag")]</li>
	</ul>
	"}

/**********************Mineral processing unit**************************/

/obj/machinery/mineral/processing_unit
	name = "ore processor"
	desc = "Turns lumpy rocks into completely smooth sheets."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace_o"
	density = 1
	anchored = 1
	idle_power_usage = 50
	active_power_usage = 500 //This shit's able to compress tiny little diamonds into really big diamonds, of course this uses a lot of power.
	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU
	light_power_on = 2
	light_range_on = 3
	light_color = LIGHT_COLOR_ORANGE

	allowed_types = list(/obj/item/stack/ore) //Does nothing for now, functions are a mess in this
	max_moved = 100

	var/datum/radio_frequency/radio_connection

	var/datum/materials/ore
	var/list/recipes[0]
	var/on = 0 //0 = off, 1 =... oh you know!

	var/credits = 0 //Amount of money, set to -1 to disable the $ amount showing in the menu (recycling, for example)

/obj/machinery/mineral/processing_unit/power_change()
	. = ..()
	update_icon()

/obj/machinery/mineral/processing_unit/update_icon()
	if(stat & (NOPOWER | BROKEN) || !on)
		icon_state = "furnace_o"
		kill_light()
	else if(on)
		icon_state = "furnace"
		set_light(light_range_on, light_power_on)

/obj/machinery/mineral/processing_unit/RefreshParts()
	var/i = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/A in component_parts)
		i += A.rating

	max_moved = initial(max_moved) * (i / 2)

	i = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/A in component_parts)
		i += A.rating - 1

	idle_power_usage = initial(idle_power_usage) - (i * (initial(idle_power_usage) / 4))
	active_power_usage = initial(active_power_usage) - (i * (initial(active_power_usage) / 4))

/obj/machinery/mineral/processing_unit/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/processing_unit,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

	ore = new

	for(var/recipe in typesof(/datum/smelting_recipe) - /datum/smelting_recipe)
		recipes += new recipe()

	if(ticker && ticker.current_state == 3)
		broadcast_status()

/obj/machinery/mineral/processing_unit/initialize()
	set_frequency(frequency)

/obj/machinery/mineral/processing_unit/proc/broadcast_status()
	var/list/data[5]

	data["recipes"] = recipes

	data["on"] = on
	data["ore"] = list()
	for(var/metal in ore.storage)
		var/datum/material/M = ore.getMaterial(metal)
		var/amount = ore.getAmount(metal)
		if (M.default_show_in_menus || amount != 0)
			// display 1 = 1 sheet in the interface.
			data["ore"][metal] = list("name" = M.name, "amount" = amount / M.cc_per_sheet)

	data["credits"] = credits

	data["type"] = "smelter"

	send_signal(data)

/obj/machinery/mineral/processing_unit/proc/send_signal(list/data)
	var/datum/signal/signal = new /datum/signal
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data["tag"] = id_tag
	signal.data += data

	radio_connection.post_signal(src, signal)

/obj/machinery/mineral/processing_unit/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

//seperate proc so the recycling machine can override it.
/obj/machinery/mineral/processing_unit/proc/grab_ores()
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	var/sheets_this_tick = 0
	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		sheets_this_tick++
		if(sheets_this_tick >= max_moved)
			break

		if(!istype(A, /obj/item/stack/ore) || !A.materials) // Check if it's an ore
			A.forceMove(out_T)
			continue

		credits += A.materials.getValue()
		ore.addFrom(A.materials, FALSE)
		qdel(A)

/obj/machinery/mineral/processing_unit/process()
	if(stat & (NOPOWER | BROKEN))
		return

	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Enter(mover, mover.loc, TRUE) || !out_T.Enter(mover, mover.loc, TRUE))
		return

	grab_ores() //Grab some more ore to process this tick.

	if(!on)
		use_power = 1
		broadcast_status()
		return

	var/sheets_this_tick = 0

	for(var/datum/smelting_recipe/R in recipes)
		while(R.checkIngredients(ore)) //While we have materials for this
			for(var/ore_id in R.ingredients)
				ore.removeAmount(ore_id, R.ingredients[ore_id]) //arg1 = ore name, arg2 = how much per sheet
				score["oremined"] += 1 //Count this ore piece as processed for the scoreboard

			drop_stack(R.yieldtype, out_T)

			sheets_this_tick++
			if(sheets_this_tick >= max_moved)
				break

		if(sheets_this_tick >= max_moved) //Second one is so it cancels the for loop when the while loop gets broken.
			break

	if(sheets_this_tick) //We produced something this tick, make it take more power.
		use_power = 2
	else
		use_power = 1

	broadcast_status()

/obj/machinery/mineral/processing_unit/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER | BROKEN) || !signal.data["tag"] || signal.data["tag"] != id_tag)
		return

	if(signal.data["sigtype"] == "status")
		broadcast_status()

	if(signal.data["toggle_power"])
		on = !on
		update_icon()

	if(signal.data["claimcredits"])
		if(credits < 1)	//Is there actual money to collect?
			return 1

		var/datum/money_account/acct = signal.data["claimcredits"]
		if(istype(acct) && acct.charge(-credits, null, "Claimed mining credits.", src.name, dest_name = "Processing Machine"))
			credits = 0

	if(signal.data["inc_priority"])
		var/idx = clamp(signal.data["inc_priority"], 2, recipes.len)
		recipes.Swap(idx, idx - 1)

	if(signal.data["dec_priority"])
		var/idx = clamp(signal.data["dec_priority"], 1, recipes.len - 1)
		recipes.Swap(idx, idx + 1)

/////////////////////////////////////////////////
// Recycling Furnace
/obj/machinery/mineral/processing_unit/recycle
	name = "recycling furnace"

	credits = -1

/obj/machinery/mineral/processing_unit/recycle/grab_ores()
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(in_T.density || out_T.density)
		return

	for(var/atom/movable/A in in_T.contents)
		if(A.anchored)
			continue

		if(!(A.w_type in list(NOT_RECYCLABLE, RECYK_BIOLOGICAL)))
			if(A.recycle(ore))
				ore.addFrom(A.materials, FALSE)
				qdel(A)
				continue

		A.forceMove(out_T)

/obj/machinery/mineral/processing_unit/recycle/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/processing_unit/recycling,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()
