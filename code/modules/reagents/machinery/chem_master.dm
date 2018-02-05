#define MAX_PILL_SPRITE 20 //Max icon state of the pill sprites
var/global/list/pillIcon2Name = list("oblong purple-pink", "oblong green-white", "oblong cyan", "oblong darkred", "oblong orange-striped", "oblong lightblue-drab", \
"oblong white", "oblong white-striped", "oblong purple-yellow", "round white", "round lightblue", "round yellow", "round purple", "round lightgreen", "round red", \
"round green-purple", "round yellow-purple", "round red-yellow", "round blue-cyan", "round green")

#define BEAKER "Beaker"
#define STORAGE "Storage"
#define BUFFER "Buffer"
#define FLUSH "FLUSH"


/obj/machinery/chem_master
	name = "\improper Chem Master"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null

	var/windowtype = "chem_master" //For the browser windows

	var/max_pill_count = 50
	var/max_pill_size = 50
	var/last_pill_amt = 1
	var/pillsprite = "1"
	var/global/list/pill_icon_cache

	var/useramount
	var/clear_reagents = 1 // Whether or not it flushes reagents when you remove the beaker
	var/condi = 0

	var/last_bottle_amt = 1
	var/max_bottle_size = 30
	var/max_bottle_count = 10

	var/datum/reagents/storage
	var/datum/reagents/buffer

	var/storage_mode = BEAKER // Where the reagents go, beaker, buffer, flush
	var/buffer_mode = BEAKER // Storage, flush

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

	var/chem_board = /obj/item/weapon/circuitboard/chemmaster3000
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK


// A new, better chem master. Unlike the normal chem master, this variant is able to hold reagents in it regardless of having a beaker.

/obj/machinery/chem_master/New()
	. = ..()

	if(!clear_reagents)
		storage = new/datum/reagents(2000)
		storage.my_atom = src

	buffer = new/datum/reagents(500)
	buffer.my_atom = src

	component_parts = newlist(
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen)
	component_parts += new chem_board
	RefreshParts()

	if (!pill_icon_cache)
		generate_pill_icon_cache()

/obj/machinery/chem_master/RefreshParts()
	var/scancount = 0
	var/lasercount = 0
	var/manipcount = 0

	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating
	max_pill_size = initial(max_pill_size) + (manipcount * 25) - 25

	if(!clear_reagents)
		reagents = storage
		handle_new_reservoir(scancount * 1000)
	reagents = buffer
	handle_new_reservoir(scancount * 250)

/obj/machinery/chem_master/proc/handle_new_reservoir(var/newvol)
	if(reagents.maximum_volume == newvol)
		return //Volume did not change
	if(reagents.maximum_volume>newvol)
		reagents.remove_any(reagents.maximum_volume-newvol) //If we have more than our new max, remove equally until we reach new max
	reagents.maximum_volume = newvol

/obj/machinery/chem_master/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)
	if(..())
		return 1

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			to_chat(user, "<span class='warning'>There already is a beaker loaded in the machine.</span>")
			return
		if(B.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [B] is too big to fit.</span>")
			return
		if(!user.drop_item(B, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [B]!</span>")
			return
		src.beaker = B
		to_chat(user, "<span class='notice'>You add the beaker into \the [src]!</span>")
		src.updateUsrDialog()
		update_icon()
		return 1

	if(istype(B, /obj/item/weapon/storage/pill_bottle))
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

/obj/machinery/chem_master/proc/detach()
	if(beaker)
		beaker.forceMove(src.loc)
		beaker.pixel_x = 0 //We fucked with the beaker for overlays, so reset that
		beaker.pixel_y = 0 //We fucked with the beaker for overlays, so reset that
		beaker = null
		update_icon()

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	user.set_machine(src)

	var/dat = list()
	// Beaker
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker.</A><BR>"

		if(R.total_volume)
			// Beaker buttons
			dat += {"
				<table>
					<td class="column1">
						Add to reagent buffer: <A href='?src=\ref[src];beaker_addall=1;amount=[R.total_volume]'>All</A>
					</td>
				</table>
			"}

			// Beaker reagents
			dat += "<table>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "<tr>"
				dat += {"
					<td class="column1">
						[G.name] , [round(G.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[G]'>(?)</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];beaker_add=[G.id];amount=1'>1u</A>
						<A href='?src=\ref[src];beaker_add=[G.id];amount=5'>5u</A>
						<A href='?src=\ref[src];beaker_add=[G.id];amount=10'>10u</A>
						<A href='?src=\ref[src];beaker_addcustom=[G.id]'>Custom</A>
						<A href='?src=\ref[src];beaker_add=[G.id];amount=[G.volume]'>All</A>
					</td>
				"}
				dat += "</tr>"
			dat += "</table>"
		else
			dat += "Beaker is empty."
	else
		dat += "No beaker inserted."


	// Internal Storage - Just storage. Moves to either buffer or beaker, has a flush mode.
	// Can flush, move to beaker or move to buffer
	if(!clear_reagents) // Don't display this part of the UI at all
		dat += "<HR>"
		dat += "<b>&ltInternal Chemical Storage&gt</b> <BR>"

		dat += "Mode: <A href='?src=\ref[src];togglestorage=1'>[storage_mode]</A> <BR>"

		if(storage.total_volume)
			dat += "<table>"
			for(var/datum/reagent/G in storage.reagent_list)
				dat += "<tr>"
				dat += {"
						<td class="column1">
							[G.name] , [round(G.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[G]'>(?)</A>
						</td>
						<td class="column2">
							<A href='?src=\ref[src];storage_add=[G.id];amount=1'>1u</A>
							<A href='?src=\ref[src];storage_add=[G.id];amount=5'>5u</A>
							<A href='?src=\ref[src];storage_add=[G.id];amount=10'>10u</A>
							<A href='?src=\ref[src];storage_addcustom=[G.id]'>Custom</A>
							<A href='?src=\ref[src];storage_add=[G.id];amount=[G.volume]'>All</A>
						</td>
						"}
				dat += "</tr>"
			dat += "</table>"
		else
			dat += "No reagents in internal storage."

	// Buffer - Like normal chem masters, except retains without a beaker.
	// Makes pills. Can flush or move to internal storage
	dat += "<HR>"
	dat += "<b>&ltInternal Chemical Buffer&gt</b> <BR>"

	dat += "Mode: <A href='?src=\ref[src];togglebuffer=1'>[buffer_mode]</A> <BR>"

	if(buffer.total_volume)
		dat += "<table>"
		for(var/datum/reagent/G in buffer.reagent_list)
			dat += "<tr>"
			dat += {"
					<td class="column1">
						[G.name] , [round(G.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[G]'>(?)</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];buffer_add=[G.id];amount=1'>1u</A>
						<A href='?src=\ref[src];buffer_add=[G.id];amount=5'>5u</A>
						<A href='?src=\ref[src];buffer_add=[G.id];amount=10'>10u</A>
						<A href='?src=\ref[src];buffer_addcustom=[G.id]'>Custom</A>
						<A href='?src=\ref[src];buffer_add=[G.id];amount=[G.volume]'>All</A>
					</td>
					"}
			dat += "</tr>"
		dat += "</table>"
	else
		dat += "No reagents in buffer."

	// Pill sprite selection
	if(!condi)
		dat += "<HR>"
		dat += "<div class='pillIconsContainer'>"
		for(var/i = 1 to MAX_PILL_SPRITE)
			dat += {"<a href="?src=\ref[src]&pill_sprite=[i]" class="pillIconWrapper[i == text2num(pillsprite) ? " linkOnMinimal" : ""]">
						<div class="pillIcon">
							[pill_icon_cache[i]]
						</div>
					</a>"}
			if (i%10 == 0)
				dat +="<br>"
		dat += "</div>"


	// Pill creation
	dat += "<BR>"
	if(!condi)
		dat += "<A href='?src=\ref[src];createpill=1'>Create single pill ([max_pill_size] units max)</A><BR>"
		dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills ([max_pill_size] units max each; [max_pill_count] max)</A><BR>"
	dat += "<A href='?src=\ref[src];createbottle=1'>Create single bottle ([max_bottle_size] units max each; [max_bottle_count] max)</A><BR>"
	dat += "<A href='?src=\ref[src];createbottle_multiple=1'>Create multiple bottles ([max_bottle_size] units max each; [max_bottle_count] max)</A><BR>"

	// Make the window
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "[windowtype]", "[name]", 475, 500, src)
	popup.add_stylesheet("chemmaster", 'html/browser/chem_master.css')
	popup.set_content(dat)
	popup.open()
	onclose(user, "[windowtype]")
	return


/obj/machinery/chem_master/Topic(href, href_list)

	if(..())
		return 1
	usr.set_machine(src)

	// Beaker
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if(href_list["beaker_addall"])
			var/amount

			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			if(isnull(amount) || amount < 0)
				return

			if(clear_reagents)
				src.reagents = buffer
			else
				src.reagents = storage

			R.trans_to(src, amount)
			src.updateUsrDialog()
			return 1

		if(href_list["beaker_addcustom"])
			var/id = href_list["beaker_addcustom"]

			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "beaker_add" = "[id]"))

			src.updateUsrDialog()
			return 1

		if(href_list["beaker_add"])
			var/id = href_list["beaker_add"]
			var/amount

			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			if(isnull(amount) || amount < 0)
				return

			if(clear_reagents)
				src.reagents = buffer
			else
				src.reagents = storage

			R.trans_id_to(src, id, amount)
			src.updateUsrDialog()
			return 1

		if(href_list["eject"])
			detach()
			if(clear_reagents)
				if(buffer && buffer.total_volume)
					buffer.remove_all(buffer.total_volume)
				if(storage && storage.total_volume)
					storage.remove_all(storage.total_volume)
			src.updateUsrDialog()
			return 1

	// Storage
	if(!clear_reagents)
		if(href_list["storage_addall"])
			var/amount

			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			if(isnull(amount) || amount < 0)
				return

			if(storage_mode == BEAKER && beaker)
				storage.trans_to(beaker, amount)
			if(storage_mode == BUFFER && buffer)
				reagents = buffer
				storage.trans_to(src, amount)
			if(storage_mode == FLUSH)
				storage.remove_all(amount)
			src.updateUsrDialog()
			return 1

		if(href_list["storage_add"])
			var/id = href_list["storage_add"]
			var/amount

			if(href_list["amount"])
				amount = text2num(href_list["amount"])
			if(isnull(amount) || amount < 0)
				return

			if(storage_mode == BEAKER && beaker)
				storage.trans_id_to(beaker, id, amount)
			if(storage_mode == BUFFER && buffer)
				reagents = buffer
				storage.trans_id_to(src, id, amount)
			if(storage_mode == FLUSH)
				storage.remove_reagent(id, amount)
			src.updateUsrDialog()
			return 1

		if(href_list["storage_addcustom"])
			var/id = href_list["storage_addcustom"]

			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "storage_add" = "[id]"))

			src.updateUsrDialog()
			return 1

		if(href_list["togglestorage"])
			switch(storage_mode)
				if(BEAKER)	
					storage_mode = BUFFER
				if(BUFFER)	
					storage_mode = FLUSH
				if(FLUSH)	
					storage_mode = BEAKER
			src.updateUsrDialog()
			return 1


	// Buffer
	if(href_list["buffer_addall"])
		var/amount

		if(href_list["amount"])
			amount = text2num(href_list["amount"])
		if(isnull(amount) || amount < 0)
			return

		if(buffer_mode == BEAKER && beaker)
			buffer.trans_to(beaker, amount)
		if(buffer_mode == STORAGE && storage)
			reagents = storage
			buffer.trans_to(src, amount)
		if(buffer_mode == FLUSH)
			buffer.remove_all(amount)
		src.updateUsrDialog()
		return 1

	if(href_list["buffer_add"])
		var/id = href_list["buffer_add"]
		var/amount

		if(href_list["amount"])
			amount = text2num(href_list["amount"])
		if(isnull(amount) || amount < 0)
			return

		if(buffer_mode == BEAKER)
			buffer.trans_id_to(beaker, id, amount)
		if(buffer_mode == STORAGE) 	// If it's trying to move to storage but we don't have one because we clear reagents
			if(clear_reagents) 		// Transfer to the beaker instead.
				return
			else
				reagents = storage
				buffer.trans_id_to(src, id, amount)
		if(buffer_mode == FLUSH)
			buffer.remove_reagent(id, amount)
		src.updateUsrDialog()
		return 1

	if(href_list["buffer_addcustom"])
		var/id = href_list["buffer_addcustom"]

		useramount = input("Select the amount to transfer.", 30, useramount) as num
		useramount = isgoodnumber(useramount)
		src.Topic(null, list("amount" = "[useramount]", "buffer_add" = "[id]"))

		src.updateUsrDialog()
		return 1

	if(href_list["togglebuffer"])
		switch(buffer_mode)
			if(BEAKER)
				buffer_mode = STORAGE
				if(clear_reagents)
					buffer_mode = FLUSH
			if(STORAGE)	
				buffer_mode = FLUSH
			if(FLUSH)	
				buffer_mode = BEAKER
		src.updateUsrDialog()
		return 1


	// Bottles
	if (href_list["createbottle"] || href_list["createbottle_multiple"])
		if(condi)
			var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
			reagents = buffer
			reagents.trans_to(P, 50)
			src.updateUsrDialog()
			return 1
		else
			var/count = 1
			if(href_list["createbottle_multiple"])
				count = isgoodnumber(input("Select the number of bottles to make.", "Amount:", last_bottle_amt) as num)
			count = Clamp(count, 1, 4)
			last_bottle_amt = count
			var/amount_per_bottle = reagents.total_volume > 0 ? reagents.total_volume/count : 0
			amount_per_bottle = min(amount_per_bottle,max_bottle_size)

			var/name = reject_bad_text(input(usr,"Name:", "Name your bottle!","[reagents.get_master_reagent_name()] ([amount_per_bottle] units)") as null|text)
			if(!name)
				return

			while(count--)
				var/obj/item/weapon/reagent_containers/glass/bottle/unrecyclable/P = new/obj/item/weapon/reagent_containers/glass/bottle/unrecyclable/(src.loc,max_bottle_size)
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) * PIXEL_MULTIPLIER//random position
				P.pixel_y = rand(-7, 7) * PIXEL_MULTIPLIER
				reagents.trans_to(P,amount_per_bottle)
			src.updateUsrDialog()
			return 1

	// Pill bottles
	if(href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(src.loc)
			loaded_pill_bottle = null
		src.updateUsrDialog()
		return 1


	// Pills
	if(href_list["createpill"] || href_list["createpill_multiple"])
		var/count = 1

		if(href_list["createpill_multiple"])
			count = isgoodnumber(input("Select the number of pills to make.", "Amount:", last_pill_amt) as num)
		count = min(50, count)
		last_pill_amt = count
		if(!count)
			return

		reagents = buffer
		var/amount_per_pill = reagents.total_volume/count
		if(amount_per_pill > max_pill_size)
			amount_per_pill = max_pill_size
		var/name = reject_bad_text(input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)") as null|text)
		if(!name)
			return
		var/logged_message = " - [key_name(usr)] has made [count] pill[count > 1 ? "s, each" : ""] named '[name]' and containing "

		while(count--)
			if((amount_per_pill == 0 || reagents.total_volume == 0) && !href_list["createempty"]) //Don't create empty pills unless "createempty" is 1!
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

	if(href_list["pill_sprite"])
		pillsprite = href_list["pill_sprite"]
		src.updateUsrDialog()
		return 1

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

// Pill sprites
/obj/machinery/chem_master/proc/generate_pill_icon_cache()
	pill_icon_cache = list()
	for(var/i = 1 to MAX_PILL_SPRITE)
		pill_icon_cache += bicon(icon('icons/obj/chemical.dmi', "pill" + num2text(i)))

// Sprite updating
/obj/machinery/chem_master/update_icon()

	overlays.len = 0

	if(beaker)
		beaker.pixel_x = -9 * PIXEL_MULTIPLIER//Move it far to the left
		beaker.pixel_y = 5 * PIXEL_MULTIPLIER//Move it up
		beaker.update_icon() //Forcefully update the beaker
		overlays += beaker //Set it as an overlay

	if(reagents.total_volume && !(stat & (BROKEN|NOPOWER))) //If we have reagents in here, and the machine is powered and functional
		var/image/overlay = image('icons/obj/chemical.dmi', src, "mixer_overlay")
		overlay.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += overlay

	var/image/mixer_prongs = image('icons/obj/chemical.dmi', src, "mixer_prongs")
	overlays += mixer_prongs //Add prongs on top of all of this

/obj/machinery/chem_master/on_reagent_change()
	update_icon()

// Other
/obj/machinery/chem_master/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return

// Chem master 4000
/obj/machinery/chem_master/chemical_manipulator
	name = "\improper Chemical Manipulator"
	icon_state = "manipulator"
	/obj/item/weapon/circuitboard/chemical_manipulator
	clear_reagents = 0

/obj/machinery/chem_master/chemical_manipulator/update_icon()

// Condimaster
/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	icon_state = "condimaster"
	chem_board = /obj/item/weapon/circuitboard/condimaster
	windowtype = "condi_master"
	condi = 1

#undef MAX_PILL_SPRITE

#undef BEAKER
#undef STORAGE
#undef BUFFER
#undef FLUSH
