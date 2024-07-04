/obj/item
	var/blend_reagent
	var/grind_amount //Zero add these reagents in proportion to the nutriment inside, and minus numbers multiply it, ..--==the more you know!*
	var/grind_flags = 0 // GRIND_TRANSFER, GRIND_NUTRIMENT_TO_REAGENT
	var/juice_reagent

/obj/machinery/reagentgrinder
	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 100
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	pass_flags = PASSTABLE | PASSRAILING
	var/inuse = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/max_combined_w_class = 20
	var/speed_multiplier = 1
	var/list/obj/item/holdingitems = list()

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
//Leaving large beakers out of the component part list to try and dodge beaker cloning.
/obj/machinery/reagentgrinder/New()
	. = ..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

	component_parts = newlist(
		/obj/item/weapon/circuitboard/reagentgrinder,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

	if(ticker)
		initialize()

/obj/machinery/reagentgrinder/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating-1
	max_combined_w_class = initial(max_combined_w_class)+(T * 5)

	T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating-1
	speed_multiplier = initial(speed_multiplier)+(T * 0.50)

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return

/obj/machinery/reagentgrinder/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(beaker)
		to_chat(user, "You can't reach \the [src]'s maintenance panel with the beaker in the way!")
		return -1
	return ..()

/obj/machinery/reagentgrinder/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(beaker)
		to_chat(user, "You can't do that while \the [src] has a beaker loaded!")
		return FALSE
	return ..()

/obj/machinery/reagentgrinder/splashable()
	return FALSE

/obj/machinery/reagentgrinder/table_shift()
	pixel_y = 8

/obj/machinery/reagentgrinder/table_unshift()
	pixel_y = 0

/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(..())
		return 1

	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 0
		if (panel_open)
			to_chat(user, "You can't load a beaker while the maintenance panel is open.")
			return 0
		if (O.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [O] is too big to fit.</span>")
			return 0
		else
			if(!user.drop_item(O, src, failmsg = TRUE))
				return

			src.beaker =  O

			update_icon()
			src.updateUsrDialog()
			return 1

	var/sum_w_class = 0
	for(var/obj/item/I in holdingitems)
		sum_w_class += I.w_class

	//Fill machine with bags
	if(istype(O, /obj/item/weapon/storage/bag/plants)||istype(O, /obj/item/weapon/storage/bag/chem))
		var/obj/item/weapon/storage/bag/B = O
		var/items_transferred = 0
		for(var/obj/item/G in O.contents)
			if(sum_w_class + G.w_class > max_combined_w_class)
				if(items_transferred > 0)
					to_chat(user, "You fill \the [src] to the brim.")
				else
					to_chat(user, "\The [src] is too full for \the [G].")
				break
			B.remove_from_storage(G,src)
			holdingitems += G
			sum_w_class += G.w_class
			items_transferred++

		if(!O.contents.len)
			to_chat(user, "You empty \the [O] into \the [src].")

		src.updateUsrDialog()
		return 0

	if (isnull(O.grind_amount) && !O.juice_reagent)
		to_chat(user, "Cannot refine into a reagent.")
		return 1

	if(sum_w_class + O.w_class >= max_combined_w_class)
		to_chat(usr, "\The [src] is too full for \the [O].")
		return 1

	if(!user.drop_item(O, src))
		to_chat(user, "<span class='notice'>\The [O] is stuck to your hands!</span>")
		return 1

	holdingitems += O
	src.updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if (istype(AM,/obj/item/weapon/reagent_containers/glass) || \
		istype(AM,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(AM,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker || panel_open)
			return FALSE
		var/obj/item/O = AM
		if (O.w_class > W_CLASS_SMALL)
			return FALSE
		else
			AM.forceMove(src)

			src.beaker =  AM

			update_icon()
			src.updateUsrDialog()
			return TRUE

	var/sum_w_class = 0
	for(var/obj/item/I in holdingitems)
		sum_w_class += I.w_class

	//Fill machine with bags
	if(istype(AM, /obj/item/weapon/storage/bag/plants)||istype(AM, /obj/item/weapon/storage/bag/chem))
		var/obj/item/weapon/storage/bag/B = AM
		var/items_transferred = 0
		for(var/obj/item/G in B.contents)
			if(sum_w_class + G.w_class > max_combined_w_class)
				break
			B.remove_from_storage(G,src)
			holdingitems += G
			sum_w_class += G.w_class
			items_transferred++

		src.updateUsrDialog()
		if(!items_transferred)
			return FALSE
		return TRUE

	if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if (isnull(O.grind_amount) && !O.juice_reagent)
			return FALSE
		if(sum_w_class + O.w_class >= max_combined_w_class)
			return FALSE
	
		O.forceMove(src)

		holdingitems += O
		src.updateUsrDialog()
		return TRUE
	return FALSE

/obj/machinery/reagentgrinder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/attack_robot(mob/user as mob)
	return attack_hand(user)

/obj/machinery/reagentgrinder/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = list()

	if(!inuse)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = 1
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = 0
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = 1
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"


		dat += {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if (is_beaker_ready && !is_chamber_empty && !(stat & (FORCEDISABLE|NOPOWER|BROKEN)))

			dat += {"<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>
				<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"}
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder", src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "reagentgrinder")
	return


/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	switch(href_list["action"])
		if ("grind")
			if(pre_use(60))
				grind()
		if("juice")
			if(pre_use(50))
				juice()
		if("eject")
			eject()
		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/reagentgrinder/proc/detach()
	if (!beaker)
		return
	beaker.forceMove(src.loc)
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/AltClick(mob/user)
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return ..()
	if(!anchored)
		return ..()
	if(!user.incapacitated() && Adjacent(user) && user.dexterity_check())
		var/list/choices = list(
			list("Grind", "radial_grind"),
			list("Juice", "radial_juice"),
			list("Eject Ingredients", "radial_eject"),
			list("Detach Beaker", "radial_detachbeaker")
		)

		var/task = show_radial_menu(usr,loc,choices,custom_check = new /callback(src, nameof(src::radial_check()), user))
		if(!radial_check(user))
			return

		switch(task)
			if("Grind")
				if(pre_use(60))
					grind()
			if("Juice")
				if(pre_use(50))
					juice()
			if("Eject Ingredients")
				eject()
			if("Detach Beaker")
				detach()
		return
	return ..()

/obj/machinery/reagentgrinder/proc/radial_check(mob/living/user)
	return istype(user) && !user.incapacitated() && user.Adjacent(src)

/obj/machinery/reagentgrinder/CtrlClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && user.dexterity_check() && !inuse && holdingitems.len && anchored)
		grind() //Checks for beaker and power/broken internally
		return
	return ..()

/obj/machinery/reagentgrinder/proc/eject()
	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return
	if (inuse)
		return

	for(var/obj/item/O in holdingitems)
		O.forceMove(src.loc)
		holdingitems -= O
	holdingitems = list()

/obj/item/proc/get_juice_amount()
	return 5

/obj/item/weapon/reagent_containers/food/snacks/grown/get_juice_amount()
	if (potency <= 0)
		return 5
	else
		return round(5*sqrt(potency))

/obj/machinery/reagentgrinder/proc/remove_object(var/obj/item/O)
	holdingitems -= O
	QDEL_NULL(O)

/obj/machinery/reagentgrinder/proc/pre_use(var/speed = 50)
	power_change()
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return
	if(inuse)
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src, speed_multiplier < 2 ? 'sound/machines/juicer.ogg' : 'sound/machines/juicerfast.ogg', 30, 1)
	inuse = 1
	spawn(speed/speed_multiplier)
		inuse = 0
		updateUsrDialog()
	return 1

/obj/machinery/reagentgrinder/proc/juice()
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		if(!O.juice_reagent)
			continue

		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		var/amount = O.get_juice_amount()

		beaker.reagents.add_reagent(O.juice_reagent, min(amount, space))

		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()
	for (var/obj/item/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			return
		O.get_ground_value(beaker)
		if(O.gcDestroyed)
			holdingitems -= O
		if(!O.reagents || !O.reagents.reagent_list.len)
			remove_object(O)

/obj/item/proc/get_ground_value(var/obj/item/weapon/reagent_containers/beaker)
	if((grind_flags & GRIND_TRANSFER) && reagents)
		reagents.trans_to(beaker, reagents.total_volume) //Transfer these to beaker
	if(blend_reagent)
		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		if(grind_flags & GRIND_NUTRIMENT_TO_REAGENT)
			if(grind_amount <= 0 && reagents?.has_reagent(NUTRIMENT))
				var/amount = grind_amount
				if(grind_amount == 0)
					amount = -1
				beaker.reagents.add_reagent(blend_reagent, min(round(reagents.get_reagent_amount(NUTRIMENT)*abs(amount)), space))
				reagents.remove_reagent(NUTRIMENT, min(reagents.get_reagent_amount(NUTRIMENT), space))
			else
				reagents.trans_id_to(beaker, blend_reagent, min(grind_amount, space))
		else
			if (grind_amount == 0)
				if (reagents?.has_reagent(blend_reagent))
					beaker.reagents.add_reagent(blend_reagent,min(reagents.get_reagent_amount(blend_reagent), space))
			else
				var/data
				if(type == /obj/item/weapon/rocksliver)
					var/obj/item/weapon/rocksliver/R = src
					data = R.geological_data
				beaker.reagents.add_reagent(blend_reagent,min(grind_amount, space),data)

/obj/item/stack/sheet/get_ground_value(var/obj/item/weapon/reagent_containers/beaker)
	if(blend_reagent)
		while(beaker.reagents.total_volume < beaker.reagents.maximum_volume && use(1))
			beaker.reagents.add_reagent(blend_reagent, grind_amount, additional_data = list("color" = color))
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				return

/obj/item/weapon/reagent_containers/food/snacks/get_ground_value(var/obj/item/weapon/reagent_containers/beaker)
	if (dip?.total_volume)
		dip.trans_to(beaker, dip.total_volume)
	..()