/obj/machinery/chem_master_4000
	name = "\improper ChemMaster 4000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null

	var/windowtype = "chem_master" //For the browser windows

	var/max_pill_count = 20
	var/max_pill_size = 50
	var/last_pill_amt = 1
	var/pillsprite = "1"

	var/useramount

	var/datum/reagents/storage
	var/datum/reagents/buffer

	var/storage_mode = 1 // Where the reagents go, beaker, buffer, flush
	var/buffer_mode = 1 // Storage, flush


// A new, better chem master. Unlike the normal chem master, this variant is able to hold reagents in it regardless of having a beaker.

/obj/machinery/chem_master_4000/New()
	. = ..()

	storage = new/datum/reagents(2000)
	buffer = new/datum/reagents(500)

	storage.my_atom = src
	buffer.my_atom = src

/obj/machinery/chem_master_4000/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)
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

/obj/machinery/chem_master_4000/Topic(href, href_list)
	if(..())
		return 1

/obj/machinery/chem_master_4000/proc/detach()
	if(beaker)
		beaker.forceMove(src.loc)
		beaker.pixel_x = 0 //We fucked with the beaker for overlays, so reset that
		beaker.pixel_y = 0 //We fucked with the beaker for overlays, so reset that
		beaker = null
		update_icon()

/obj/machinery/chem_master_4000/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_master_4000/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master_4000/attack_hand(mob/user as mob)
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
	dat += "<HR>"
	dat += "<b>&ltInternal Chemical Storage&gt</b> <BR>"

	var/s_mode_text
	if(storage_mode == 1)
		s_mode_text = "Beaker"
	if(storage_mode == 2)
		s_mode_text = "Buffer"
	if(storage_mode == 3)
		s_mode_text = "FLUSH"
	dat += "Mode: <A href='?src=\ref[src];togglestorage=1'>[s_mode_text]</A> <BR>"

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

	var/b_mode_text
	if(buffer_mode == 1)
		b_mode_text = "Storage"
	if(buffer_mode == 2)
		b_mode_text = "FLUSH"
	dat += "Mode: <A href='?src=\ref[src];togglebuffer=1'>[b_mode_text]</A> <BR>"

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


	// Make the window
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "[windowtype]", "[name]", 475, 500, src)
	popup.add_stylesheet("chemmaster", 'html/browser/chem_master.css')
	popup.set_content(dat)
	popup.open()
	onclose(user, "[windowtype]")
	return


/obj/machinery/chem_master_4000/Topic(href, href_list)

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

			src.reagents = storage // Because you can't transfer directly to a reagent datum, I don't think.
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

			src.reagents = storage
			R.trans_id_to(src, id, amount)
			src.updateUsrDialog()
			return 1

		if(href_list["eject"])
			detach()
			src.updateUsrDialog()
			return 1

	// Storage
	if(href_list["storage_addall"])
		var/amount

		if(href_list["amount"])
			amount = text2num(href_list["amount"])
		if(isnull(amount) || amount < 0)
			return

		if(storage_mode == 1)
			storage.trans_to(beaker, amount)
		if(storage_mode == 2)
			reagents = buffer
			storage.trans_to(src, amount)
		if(storage_mode == 3)
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

		if(storage_mode == 1)
			storage.trans_id_to(beaker, id, amount)
		if(storage_mode == 2)
			reagents = buffer
			storage.trans_id_to(src, id, amount)
		if(storage_mode == 3)
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
		storage_mode += 1
		if(storage_mode == 4)
			storage_mode = 1
		src.updateUsrDialog()
		return 1


	// Buffer
	if(href_list["buffer_addall"])
		var/amount

		if(href_list["amount"])
			amount = text2num(href_list["amount"])
		if(isnull(amount) || amount < 0)
			return

		if(buffer_mode == 1)
			reagents = storage
			buffer.trans_id_to(src, amount)
		if(buffer_mode == 2)
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

		if(buffer_mode == 1)
			reagents = storage
			buffer.trans_id_to(src, id, amount)
		if(buffer_mode == 2)
			buffer.remove_all(amount)
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
		buffer_mode += 1
		if(buffer_mode == 3)
			buffer_mode = 1
		src.updateUsrDialog()
		return 1

	if(href_list["create_pill"] || href_list["create_pill_multiple"])
		var/count = 1

		if(href_list["create_pill_multiple"])
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
			if(count == 0) //only do this ONCE
				logged_message += "[P.reagents.get_reagent_ids(1)]. Icon: [pillIcon2Name[text2num(pillsprite)]]"

		investigation_log(I_CHEMS, logged_message)
		src.updateUsrDialog()
		return 1

/obj/machinery/chem_master_4000/proc/isgoodnumber(var/num)
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