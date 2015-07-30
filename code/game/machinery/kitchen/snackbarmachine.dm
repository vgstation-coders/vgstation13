/obj/machinery/chem_master/snackbar_machine
	name = "\improper SnackBar Machine"
	desc = "An explosion of flavour in every bite"
	condi = 1
	chem_board = /obj/item/weapon/circuitboard/snackbar_machine
	//var/opened = 0

/obj/machinery/chem_master/snackbar_machine/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)

	if(istype(B, /obj/item/weapon/storage/pill_bottle))
		user << "<span class='warning'>This condiment master does not come with a pill dispenser unit built-in.</span>"
		return

	..()

/obj/machinery/chem_master/snackbar_machine/Topic(href, href_list)

	if(..())
		return 1

	src.add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["close"])
		usr << browse(null, "window=snackbar_machine")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if(href_list["analyze"])
			var/dat = ""
			dat += "<TITLE>SnackBar Machine</TITLE>Reagent info:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=snackbar_machine;size=575x400")
			return

		else if(href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				if(amount < 0)
					return
				R.trans_id_to(src, id, amount)

		else if(href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if(href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(amount < 0)
					return
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)

		else if(href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))

		else if(href_list["toggle"])
			mode = !mode

		else if(href_list["main"])
			attack_hand(usr)
			return

		else if(href_list["eject"])
			if(beaker)
				beaker:loc = src.loc
				beaker = null
				reagents.clear_reagents()
				update_icon()

		else if(href_list["createbar"])
			var/obj/item/weapon/reagent_containers/food/snacks/snackbar/SB = new/obj/item/weapon/reagent_containers/food/snacks/snackbar(src.loc)
			reagents.trans_to(SB, 10)

	src.updateUsrDialog()
	return

/obj/machinery/chem_master/snackbar_machine/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return

	user.set_machine(src)

	var/dat = ""
	if(!beaker)
		dat = "Please insert a beaker.<BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += {"[G.name] , [G.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A>
					<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A>
					<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"}

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += {"[N.name] , [N.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A>
					<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"}
			dat += "<A href='?src=\ref[src];createbar=1'>Create snack bar (10 units max)</A>"
		else
			dat += "Buffer is empty.<BR>"

	user << browse("<TITLE>SnackBar Machine</TITLE>SnackBar Machine menu:<BR><BR>[dat]", "window=snackbar_machine;size=575x400")
	onclose(user, "snackbar_machine")
	return
