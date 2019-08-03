#define MAX_PILL_SPRITE 40 //Max icon state of the pill sprites
var/global/list/pillIcon2Name = list("oblong purple-pink", "oblong green-white", "oblong cyan", "oblong darkred", "oblong orange-striped", "oblong lightblue-drab", \
"oblong white", "oblong white-striped", "oblong purple-yellow", "round white", "round lightblue", "round yellow", "round purple", "round lightgreen", "round red", \
"round green-purple", "round yellow-purple", "round red-yellow", "round blue-cyan", "round green","oblong green-yellow","oblong grey-purple","oblong black-red", \
"oblong yellow-grey","oblong green-purple","oblong blue-red","oblong green-brown","oblong yellow-cyan","oblong purple-cyan","oblong yellow-red","round pink", \
"round purple-red","round black","round green-blue","round orange","round blue-beige","round blue","round beige-yellow","round red-green","round darkpink")

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/container = null
	var/list/accepted_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/weapon/reagent_containers/food/drinks)
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 1 //1 = from buffer to container. 0 = from buffer to disposals.
	var/slurpmode = 0 //1 = from obj to container. 0 = from obj to buffer.
	var/slurp_types = list(/obj/structure/reagent_dispensers, /obj/item/weapon/reagent_containers/glass/bucket,
		/obj/item/weapon/reagent_containers/glass/jar, /obj/structure/mopbucket) //types of objects we can slurp from when adjacent
	var/condi = 0
	var/windowtype = "chem_master" //For the browser windows
	var/useramount = 30 // Last used amount
	var/last_pill_amt = 10
	var/last_bottle_amt = 3
	//var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"
	var/tmp/last_sound_time = 0

	var/global/list/pill_icon_cache

	var/chem_board = /obj/item/weapon/circuitboard/chemmaster3000
	var/max_bottle_size = 30
	var/max_pill_count = 20
	var/max_pill_size = 50
	var/pill_display_number = MAX_PILL_SPRITE/2

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/

/obj/machinery/chem_master/New()
	. = ..()

	create_reagents(1000)

	component_parts = newlist(
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	component_parts += new chem_board

	RefreshParts()
	update_icon() //Needed to add the prongs cleanly

	if (!pill_icon_cache)
		generate_pill_icon_cache()

/obj/machinery/chem_master/RefreshParts()
	var/lasercount = 0
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	max_bottle_size = initial(max_bottle_size) + lasercount*5
	max_pill_count = initial(max_pill_count) + manipcount*5
	max_pill_size = initial(max_pill_size) + manipcount*25

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)
	if(..())
		return 1

	else if(is_type_in_list(B, accepted_containers))
		if(src.container)
			to_chat(user, "<span class='warning'>There already is \a [container] loaded in the machine.</span>")
			return
		if(B.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [B] is too big to fit.</span>")
			return
		if(!user.drop_item(B, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [B]!</span>")
			return

		src.container = B

		to_chat(user, "<span class='notice'>You add \the [container] into \the [src]!</span>")

		src.updateUsrDialog()
		update_icon()
		return 1

	else if(istype(B, /obj/item/weapon/storage/pill_bottle))
		if(windowtype != "chem_master") //Only the chemmaster will accept pill bottles
			to_chat(user, "<span class='warning'>This [name] does not come with a pill dispenser unit built-in.</span>")
			return
		if(src.loaded_pill_bottle)
			to_chat(user, "<span class='warning'>There already is a pill bottle loaded in the machine.</span>")
			return
		if(!user.drop_item(B, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [B]!</span>")
			return

		src.loaded_pill_bottle = B

		to_chat(user, "<span class='notice'>You add the pill bottle into \the [src]'s dispenser slot!</span>")

		src.updateUsrDialog()
		return 1

	else if(istype(B, /obj/item/weapon/reagent_containers/pill))
		B.icon_state = "pill"+pillsprite
		var/name = stripped_input(user,"Name:","Name your pill!","[B.reagents.get_master_reagent_name()] ([B.reagents.total_volume] units)")
		if(name)
			B.name = "[name] pill"
		else
			to_chat(user, "<span class='warning'>[bicon(src)] Invalid name!</span>")
		return 1

/obj/machinery/chem_master/Topic(href, href_list)

	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(src.loc)
			loaded_pill_bottle = null
		src.updateUsrDialog()
		return 1

	else if(href_list["close"])
		usr << browse(null, "window=[windowtype]")
		usr.unset_machine()
		return 1

	else if(href_list["pill_sprite"])
		pillsprite = href_list["pill_sprite"]
		src.updateUsrDialog()
		return 1

	else if(href_list["pill_icon_toggle"])
		if (pill_display_number == MAX_PILL_SPRITE/2)
			pill_display_number = MAX_PILL_SPRITE
		else
			pill_display_number = MAX_PILL_SPRITE/2
		src.updateUsrDialog()
		return 1

	if(container)
		var/datum/reagents/R = container.reagents
		if(href_list["analyze"])
			var/datum/reagent/reagent = locate(href_list["analyze"])
			var/dat = list()
			if(!reagent)
				dat += "No info. Please contact technical support if you believe this is an error."
			else
				dat += "[condi ? "Condiment" : "Chemical"] information:<BR><BR>Name:<BR>[reagent.name]<BR><BR>Description:<BR>[reagent.description]<BR><BR>"
				if(!condi)
					if(istype(reagent, /datum/reagent/blood))
						dat += "Blood type: [reagent.data["blood_type"] || "Unknown"]<BR>Blood DNA: [reagent.data["blood_DNA"] || "Unable to determine"]<BR><BR>"
					dat += "Density:<BR>[reagent.density]<BR><BR>Specific heat capacity:<BR>[reagent.specheatcap]<BR><BR><BR>"
				dat += "<A href='?src=\ref[src];main=1'>(Back)</A>"

			dat = jointext(dat,"")
			var/datum/browser/popup = new(usr, "[windowtype]", "[name]", 585, 400, src)
			popup.set_content(dat)
			popup.open()
			return 1

		else if(href_list["add"])
			var/id = href_list["add"]
			var/amount
			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			else if(href_list["percent"])
				amount = R.get_reagent_amount(id) * text2num(href_list["percent"]) / 100
			if(isnull(amount) || amount < 0)
				return
			R.trans_id_to(src, id, amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["addall"])
			var/amount
			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			else if(href_list["percent"])
				amount = R.total_volume * text2num(href_list["percent"]) / 100
			if(isnull(amount) || amount < 0)
				return
			R.trans_to(src, amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["slurpall"])
			var/obj/O = locate(href_list["disp"])
			if(!is_type_in_list(O, slurp_types) || get_dist(src, O) > 1)
				return
			var/amount
			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			else if(href_list["percent"])
				amount = O.reagents.total_volume * text2num(href_list["percent"]) / 100
			if(isnull(amount) || amount < 0)
				return
			if(slurpmode)
				O.reagents.trans_to(container, amount, log_transfer = TRUE, whodunnit = usr)
			else
				O.reagents.trans_to(src, amount, log_transfer = TRUE, whodunnit = usr)

			src.updateUsrDialog()
			return 1

		else if(href_list["remove"])
			var/id = href_list["remove"]
			var/amount
			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			else if(href_list["percent"])
				amount = reagents.get_reagent_amount(id) * text2num(href_list["percent"]) / 100
			if(isnull(amount) || amount < 0)
				return
			if(mode)
				reagents.trans_id_to(container, id, amount)
			else
				reagents.remove_reagent(id, amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["removeall"])
			var/amount
			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			else if(href_list["percent"])
				amount = reagents.total_volume * text2num(href_list["percent"]) / 100
			if(isnull(amount) || amount < 0)
				return
			if(mode)
				reagents.trans_to(container, amount)
			else
				reagents.remove_all(amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["addcustom"])
			var/id = href_list["addcustom"]
			useramount = input("Select the amount of units to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))
			return 1
		else if(href_list["addallcustom"])
			useramount = input("Select the amount of units to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "addall" = "1"))
			return 1
		else if(href_list["slurpallcustom"])
			useramount = input("Select the amount of units to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "slurpall" = "1", "disp" = href_list["disp"]))
			return 1
		else if(href_list["removecustom"])
			var/id = href_list["removecustom"]
			useramount = input("Select the amount of units to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))
			return 1
		else if(href_list["removeallcustom"])
			useramount = input("Select the amount of units to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "removeall" = "1"))
			return 1

		else if(href_list["toggle"])
			mode = !mode
			src.updateUsrDialog()
			return 1

		else if(href_list["toggle_disp"])
			slurpmode = !slurpmode
			src.updateUsrDialog()
			return 1

		else if(href_list["main"])
			attack_hand(usr)
			src.updateUsrDialog()
			return 1

		else if(href_list["eject"])
			if(container)
				detach()
			return 1

		else if(href_list["createpill"] || href_list["createpill_multiple"])
			if(reagents.total_volume == 0)
				to_chat(usr, "<span class='warning'>[bicon(src)] Buffer is empty!</span>")
				if(last_sound_time + 1 SECONDS < world.time)
					playsound(src, 'sound/machines/chime.ogg', 50)
					last_sound_time = world.time
				return

			var/count = 1
			if(href_list["createpill_multiple"])
				count = isgoodnumber(input("Select the number of pills to make.", "Amount:", last_pill_amt) as num)
			count = min(max_pill_count, count)
			last_pill_amt = count
			if(!count)
				return

			var/amount_per_pill = reagents.total_volume/count
			if(amount_per_pill > max_pill_size)
				amount_per_pill = max_pill_size

			var/name = stripped_input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)")
			if(!name)
				to_chat(usr, "<span class='warning'>[bicon(src)] Invalid name!</span>")
				return

			var/logged_message = " - [key_name(usr)] has made [count] pill[count > 1 ? "s, each" : ""] named '[name]' and containing "

			while(count--)
				if(amount_per_pill == 0 || reagents.total_volume == 0)
					break

				var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
				if(!name)
					name = "[reagents.get_master_reagent_name()] ([amount_per_pill] units)"
				P.name = "[name] pill"
				P.pixel_x = rand(-7, 7) * PIXEL_MULTIPLIER//Random position
				P.pixel_y = rand(-7, 7) * PIXEL_MULTIPLIER
				P.icon_state = "pill"+pillsprite
				reagents.trans_to(P,amount_per_pill)
				if(src.loaded_pill_bottle)
					if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
						P.forceMove(loaded_pill_bottle)
				if(count == 0) //only do this ONCE
					logged_message += "[P.reagents.get_reagent_ids(1)]. Icon: [pillIcon2Name[text2num(pillsprite)]]"

			investigation_log(I_CHEMS, logged_message)

			src.updateUsrDialog()
			return 1

		else if (href_list["createbottle"] || href_list["createbottle_multiple"])
			if(reagents.total_volume == 0)
				to_chat(usr, "<span class='warning'>[bicon(src)] Buffer is empty!</span>")
				return
			if(!condi)
				var/count = 1
				if(href_list["createbottle_multiple"])
					count = isgoodnumber(input("Select the number of bottles to make.", "Amount:", last_bottle_amt) as num)
				count = Clamp(count, 1, 4)
				last_bottle_amt = count

				var/amount_per_bottle = reagents.total_volume > 0 ? reagents.total_volume/count : 0
				amount_per_bottle = min(amount_per_bottle,max_bottle_size)

				var/name = stripped_input(usr,"Name:", "Name your bottle!","[reagents.get_master_reagent_name()] ([amount_per_bottle] units)")
				if(!name)
					to_chat(usr, "<span class='warning'>[bicon(src)] Invalid name!</span>")
					return

				while(count--)
					if(amount_per_bottle == 0 || reagents.total_volume == 0)
						break

					var/obj/item/weapon/reagent_containers/glass/bottle/unrecyclable/P = new/obj/item/weapon/reagent_containers/glass/bottle/unrecyclable/(src.loc,max_bottle_size)
					P.name = "[name] bottle"
					P.pixel_x = rand(-7, 7) * PIXEL_MULTIPLIER//random position
					P.pixel_y = rand(-7, 7) * PIXEL_MULTIPLIER
					//P.icon_state = "bottle"+bottlesprite
					reagents.trans_to(P,amount_per_bottle)
				src.updateUsrDialog()
				return 1
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
				reagents.trans_to(P, 50)
				src.updateUsrDialog()
				return 1

/obj/machinery/chem_master/proc/detach()
	if(container)
		container.forceMove(src.loc)
		container.pixel_x = 0 //We fucked with the beaker for overlays, so reset that
		container.pixel_y = 0 //We fucked with the beaker for overlays, so reset that
		container = null
		reagents.clear_reagents()
		update_icon()
		updateUsrDialog()

/obj/machinery/chem_master/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && container && !(stat & (NOPOWER|BROKEN) && usr.dexterity_check()))
		detach()
		return
	return ..()

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/proc/generate_pill_icon_cache()
	pill_icon_cache = list()
	for(var/i = 1 to MAX_PILL_SPRITE)
		pill_icon_cache += bicon(icon('icons/obj/chemical.dmi', "pill" + num2text(i)))

/obj/machinery/chem_master/proc/generate_pill_icon_div(pill_display_number)
	var/dat = list()
	dat += "<HR>"
	dat += "<a href='?src=\ref[src];pill_icon_toggle=1'>Toggle Additional Pill Icons</a><br>"
	dat += "<div class='pillIconsContainer'>"
	for(var/i = 1 to pill_display_number)
		dat += {"<a href="?src=\ref[src]&pill_sprite=[i]" class="pillIconWrapper[i == text2num(pillsprite) ? " linkOnMinimal" : ""]">
					<div class="pillIcon">
						[pill_icon_cache[i]]
					</div>
				</a>"}
		if (i%10 == 0)
			dat += "<br>"

	dat += "</div>"
	return dat

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return

	user.set_machine(src)

	var/dat = list()

	if(!container)
		dat += "Please insert a beaker.<BR>"
		if(!condi)
			if(src.loaded_pill_bottle)
				dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
			else
				dat += "No pill bottle inserted.<BR><BR>"
			dat += generate_pill_icon_div(pill_display_number)
	else
		var/datum/reagents/R = container.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"

		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else if(windowtype == "chem_master")
			dat += "No pill bottle inserted.<BR><BR>"

		//
		// BEAKER
		//

		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += {"
				<table>
					<td class="column1">
						Add to buffer:
					</td>
					<td class="column2">
						<A href='?src=\ref[src];addall=1;percent=[100/3]'>33%</A>
						<A href='?src=\ref[src];addall=1;percent=50'>50%</A>
						<A href='?src=\ref[src];addallcustom=1'>Custom</A>
						<A href='?src=\ref[src];addall=1;amount=[R.total_volume]'>All</A>
					</td>
				</table>
			"}

			dat += "<table>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "<tr>"
				var/reg_name = G.name
				if (istype(G,/datum/reagent/vaccine))
					var/datum/reagent/vaccine/vaccine = G
					var/vaccines = ""
					for (var/A in vaccine.data["antigen"])
						vaccines += "[A]"
					if (vaccines == "")
						vaccines = "blank"
					reg_name = "[reg_name] ([vaccines])"
				dat += {"
					<td class="column1">
						[reg_name] , [round(G.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[G]'>(?)</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];add=[G.id];amount=1'>1u</A>
						<A href='?src=\ref[src];add=[G.id];amount=5'>5u</A>
						<A href='?src=\ref[src];add=[G.id];amount=10'>10u</A>
						<A href='?src=\ref[src];addcustom=[G.id]'>Custom</A>
						<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>All</A>
					</td>
				"}
				dat += "</tr>"
			dat += "</table>"

		//
		// NEARBY SLURPABLES
		//
		var/found_valid_disp = FALSE
		for(var/obj/O in orange(1,src))
			if(!is_type_in_list(O, slurp_types))
				continue
			if(!O.reagents.total_volume)
				continue
			if(!found_valid_disp)
				dat += "<HR>"
				dat += "<table><td class='column1'>Transfer to <A href='?src=\ref[src];toggle_disp=1'>[(!slurpmode ? "buffer" : "container")]:</A></td></table>"
				found_valid_disp = TRUE
			dat += {"
				<table>
					<td class="column1">
						\The [O], [O.reagents.total_volume] Units - ([dir2arrow(get_dir(src,O))])
					</td>
					<td class="column2">
						<A href='?src=\ref[src];slurpall=1;disp=\ref[O];amount=10'>10u</A>
						<A href='?src=\ref[src];slurpall=1;disp=\ref[O];amount=50'>50u</A>
						<A href='?src=\ref[src];slurpall=1;disp=\ref[O];amount=100'>100u</A>
						<A href='?src=\ref[src];slurpallcustom=1;disp=\ref[O]'>Custom</A>
						<A href='?src=\ref[src];slurpall=1;disp=\ref[O];amount=[O.reagents.total_volume]'>All</A>
					</td>
				</table>
			"}

		//
		// BUFFER
		//

		dat += "<HR>"
		if(reagents.total_volume)
			dat += {"
				<table>
					<td class="column1">
						Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];removeall=1;percent=[100/3]'>33%</A>
						<A href='?src=\ref[src];removeall=1;percent=50'>50%</A>
						<A href='?src=\ref[src];removeallcustom=1'>Custom</A>
						<A href='?src=\ref[src];removeall=1;amount=[reagents.total_volume]'>All</A>
					</td>
				</table>
			"}

			dat += "<table>"
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "<tr>"
				var/reg_name = N.name
				if (istype(N,/datum/reagent/vaccine))
					var/datum/reagent/vaccine/vaccine = N
					var/vaccines = ""
					for (var/A in vaccine.data["antigen"])
						vaccines += "[A]"
					if (vaccines == "")
						vaccines = "blank"
					reg_name = "[reg_name] ([vaccines])"
				dat += {"
					<td class="column1">
						[reg_name] , [round(N.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[N]'>(?)</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];remove=[N.id];amount=1'>1u</A>
						<A href='?src=\ref[src];remove=[N.id];amount=5'>5u</A>
						<A href='?src=\ref[src];remove=[N.id];amount=10'>10u</A>
						<A href='?src=\ref[src];removecustom=[N.id]'>Custom</A>
						<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>All</A>
					</td>
				"}
				dat += "</tr>"
			dat += "</table>"
		else
			dat += "Buffer is empty.<BR>"

		if(condi)
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
		else
			//
			// PILL ICONS
			//

			dat += generate_pill_icon_div(pill_display_number)




			//
			// BUTTONS
			//
			dat += {"<HR><A href='?src=\ref[src];createpill=1'>Create single pill ([max_pill_size] units max)</A><BR>
					<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills ([max_pill_size] units max each; [max_pill_count] max)</A><BR>
					<A href='?src=\ref[src];createbottle=1'>Create bottle ([max_bottle_size] units max)</A><BR>
					<A href='?src=\ref[src];createbottle_multiple=1'>Create multiple bottles ([max_bottle_size] units max each; 4 max)</A><BR>"}

	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "[windowtype]", "[name]", 475, 500, src)
	popup.add_stylesheet("chemmaster", 'html/browser/chem_master.css')
	popup.set_content(dat)
	popup.open()
	onclose(user, "[windowtype]")
	return

/obj/machinery/chem_master/proc/isgoodnumber(var/num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 1
		else
			num = round(num)
		return num
	else
		return 0

/obj/machinery/chem_master/kick_act(mob/living/H)
	..()
	if(container)
		detach()

/obj/machinery/chem_master/update_icon()

	overlays.len = 0

	if(container)
		container.pixel_x = -9 * PIXEL_MULTIPLIER//Move it far to the left
		container.pixel_y = 5 * PIXEL_MULTIPLIER//Move it up
		container.update_icon() //Forcefully update the beaker
		overlays += container //Set it as an overlay

	if(reagents.total_volume && !(stat & (BROKEN|NOPOWER))) //If we have reagents in here, and the machine is powered and functional
		var/image/overlay = image('icons/obj/chemical.dmi', src, "mixer_overlay")
		overlay.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += overlay

	var/image/mixer_prongs = image('icons/obj/chemical.dmi', src, "mixer_prongs")
	overlays += mixer_prongs //Add prongs on top of all of this

/obj/machinery/chem_master/on_reagent_change()
	update_icon()

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	condi = 1
	icon_state = "condimaster"
	chem_board = /obj/item/weapon/circuitboard/condimaster
	windowtype = "condi_master"

#undef MAX_PILL_SPRITE
