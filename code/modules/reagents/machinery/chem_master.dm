#define MAX_PILL_SPRITE 20 //Max icon state of the pill sprites

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 1
	var/condi = 0
	var/windowtype = "chem_master" //For the browser windows
	var/useramount = 30 // Last used amount
	var/last_pill_amt = 10
	var/last_bottle_amt = 3
	//var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"

	var/global/list/pill_icon_cache

	var/chem_board = /obj/item/weapon/circuitboard/chemmaster3000
	var/max_bottle_size = 30
	var/max_pill_count = 20

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/targetMoveKey

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/

/obj/machinery/chem_master/New()
	. = ..()

	create_reagents(100)

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
	var/scancount = 0
	var/lasercount = 0
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	max_bottle_size = initial(max_bottle_size) + lasercount*5
	max_pill_count = initial(max_pill_count) + manipcount*5
	handle_new_reservoir(scancount*25+100)

/obj/machinery/chem_master/proc/handle_new_reservoir(var/newvol)
	if(reagents.maximum_volume == newvol)
		return //Volume did not change
	if(reagents.maximum_volume>newvol)
		reagents.remove_any(reagents.maximum_volume-newvol) //If we have more than our new max, remove equally until we reach new max
	reagents.maximum_volume = newvol

/obj/machinery/chem_master/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()

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

	else if(istype(B, /obj/item/weapon/reagent_containers/glass))

		if(src.beaker)
			to_chat(user, "<span class='warning'>There already is a beaker loaded in the machine.</span>")
			return
		if(!user.drop_item(B, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [B]!</span>")
			return

		src.beaker = B
		if(user.type == /mob/living/silicon/robot)
			var/mob/living/silicon/robot/R = user
			R.uneq_active()
			targetMoveKey =  R.on_moved.Add(src, "user_moved")

		to_chat(user, "<span class='notice'>You add the beaker into \the [src]!</span>")

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

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if(href_list["analyze"])
			var/dat = list()
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			//usr << browse(dat, "window=chem_master;size=575x400")
			dat = jointext(dat,"")
			var/datum/browser/popup = new(usr, "[windowtype]", "[name]", 585, 400, src)
			popup.set_content(dat)
			popup.open()
			onclose(usr, "[windowtype]")
			return 1

		else if(href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				if(amount < 0)
					return
				R.trans_id_to(src, id, amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))
			src.updateUsrDialog()
			return 1

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
			src.updateUsrDialog()
			return 1

		else if(href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))
			src.updateUsrDialog()
			return 1

		else if(href_list["toggle"])
			mode = !mode
			src.updateUsrDialog()
			return 1

		else if(href_list["main"])
			attack_hand(usr)
			src.updateUsrDialog()
			return 1

		else if(href_list["eject"])
			if(beaker)
				detach()
			src.updateUsrDialog()
			return 1

		else if(href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1
			if(href_list["createpill_multiple"])
				count = isgoodnumber(input("Select the number of pills to make.", "Amount:", last_pill_amt) as num)
			count = min(max_pill_count, count)
			last_pill_amt = count
			if(!count)
				return

			var/amount_per_pill = reagents.total_volume/count
			if(amount_per_pill > 50)
				amount_per_pill = 50
			if(href_list["createempty"])
				amount_per_pill = 0 //If "createempty" is 1, pills are empty and no reagents are used.

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
					logged_message += "[P.reagents.get_reagent_ids(1)]"

			investigation_log(I_CHEMS, logged_message)

			src.updateUsrDialog()
			return 1

		else if (href_list["createbottle"] || href_list["createbottle_multiple"])
			if(!condi)
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
					var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc,max_bottle_size)
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

		/*
		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 20 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				if ( i%4==1 )
					dat += "<tr>"

				dat += "<td><a href=\"?src=\ref[src]&bottle_sprite=[i]\"><img src=\"bottle[i].png\" /></a></td>"

				if ( i%4==0 )
					dat +="</tr>"

			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		*/

		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
			src.updateUsrDialog()
			return 1

		/*
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
		*/

/obj/machinery/chem_master/proc/detach()
	if(beaker)
		beaker.forceMove(src.loc)
		beaker.pixel_x = 0 //We fucked with the beaker for overlays, so reset that
		beaker.pixel_y = 0 //We fucked with the beaker for overlays, so reset that
		if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/mob/living/silicon/robot/R = beaker:holder:loc
			if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
				beaker.forceMove(R)
			else
				beaker.forceMove(beaker:holder)
		beaker = null
		reagents.clear_reagents()
		update_icon()

/obj/machinery/chem_master/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && beaker && !(stat & (NOPOWER|BROKEN) && usr.dexterity_check()))
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
		pill_icon_cache += "<img src='data:image/png;base64,[icon2base64(icon('icons/obj/chemical.dmi', "pill" + num2text(i)))]'>"
		//This is essentially just bicon(). Ideally we WOULD use just bicon(), but right now it's fucked up when used on icons because it goes by their \ref.

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return

	user.set_machine(src)

	var/dat = list()
	if(!beaker)
		dat += "Please insert a beaker.<BR>"
		if(!condi)
			if(src.loaded_pill_bottle)
				dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
			else
				dat += "No pill bottle inserted.<BR><BR>"
		//dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else if(windowtype == "chem_master")
			dat += "No pill bottle inserted.<BR><BR>"
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
		else
			dat += "Buffer is empty.<BR>"
		if(!condi)
			//dat += {"<a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><a href=\"?src=\ref[src]&change_bottle=1\"><img src=\"bottle[bottlesprite].png\" /></a><BR>"}
			//dat += {"<a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"}

			dat += {"<div class="li" style="padding: 0px 0px 4px;"></div>"}
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += {"<a href="?src=\ref[src]&pill_sprite=[i]" style="display: inline-block; padding:0px 4px 0px 4px; margin:0 2px 2px 0; [i == text2num(pillsprite) ? "background: #2f943c;" : ""]"> <!--Yes we are setting the style here because I suck at CSS and I have no shame-->
							<div class="pillIcon">
								[pill_icon_cache[i]]
							</div>
						</a>"}
				if (i%10 == 0)
					dat +="<br>"

			dat += {"<HR><A href='?src=\ref[src];createpill=1'>Create single pill (50 units max)</A><BR>
					<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills (50 units max each; [max_pill_count] max)</A><BR>
					<A href='?src=\ref[src];createpill_multiple=1;createempty=1'>Create empty pills</A><BR>
					<A href='?src=\ref[src];createbottle=1'>Create bottle ([max_bottle_size] units max)</A><BR>
					<A href='?src=\ref[src];createbottle_multiple=1'>Create multiple bottles ([max_bottle_size] units max each; 4 max)</A><BR>"}
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "[windowtype]", "[name]", 575, 500, src)
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

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	condi = 1
	icon_state = "condimaster"
	chem_board = /obj/item/weapon/circuitboard/condimaster
	windowtype = "condi_master"

#undef MAX_PILL_SPRITE
