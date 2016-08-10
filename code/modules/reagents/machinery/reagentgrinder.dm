/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	pass_flags = PASSTABLE
	var/inuse = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10
	var/speed_multiplier = 1
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/metal           = list(IRON = 20),
		/obj/item/stack/sheet/mineral/plasma  = list(PLASMA = 20),
		/obj/item/stack/sheet/mineral/uranium = list(URANIUM = 20),
		/obj/item/stack/sheet/mineral/clown   = list(BANANA = 20),
		/obj/item/stack/sheet/mineral/silver  = list(SILVER = 20),
		/obj/item/stack/sheet/mineral/gold    = list(GOLD = 20),
		/obj/item/weapon/grown/nettle         = list(SACID = 0),
		/obj/item/weapon/grown/deathnettle    = list(PACID = 0),
		/obj/item/stack/sheet/charcoal        = list("charcoal" = 20),

		//Blender Stuff
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list(SOYMILK = -10), //I have no fucking idea what most of these numbers mean and I hate them.
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list(KETCHUP = -7),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list(CORNOIL = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list(FLOUR = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk = list(RICE = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list(CHERRYJELLY = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium = list(PLASTICIDE = 5),

		/obj/item/seeds = list(BLACKPEPPER = 5),


		//archaeology!
		/obj/item/weapon/rocksliver = list(GROUND_ROCK = 30),

		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/weapon/reagent_containers/pill = list(),
		/obj/item/weapon/reagent_containers/food = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list(TOMATOJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list(CARROTJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list(BERRYJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list(BANANA = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list(POTATO = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = list(APPLEJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon = list(LEMONJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = list(ORANGEJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime = list(LIMEJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = list(WATERMELONJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list(WATERMELONJUICE = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries = list(POISONBERRYJUICE = 0),
	)


	var/list/holdingitems = list()
	var/targetMoveKey

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

	return

/obj/machinery/reagentgrinder/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()


/obj/machinery/reagentgrinder/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating-1
	limit = initial(limit)+(T * 5)

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

/obj/machinery/reagentgrinder/crowbarDestroy(mob/user)
	if(beaker)
		to_chat(user, "You can't do that while \the [src] has a beaker loaded!")
		return -1
	return ..()

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
		else
			if(!user.drop_item(O, src))
				to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
				return

			src.beaker =  O
			if(user.type == /mob/living/silicon/robot)
				var/mob/living/silicon/robot/R = user
				R.uneq_active()
				targetMoveKey =  R.on_moved.Add(src, "user_moved")

			update_icon()
			src.updateUsrDialog()
			return 1

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold any more items.")
		return 1

	//Fill machine with bags
	if(istype(O, /obj/item/weapon/storage/bag/plants)||istype(O, /obj/item/weapon/storage/bag/chem))
		var/obj/item/weapon/storage/bag/B = O
		for (var/obj/item/G in O.contents)
			B.remove_from_storage(G,src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "You fill the All-In-One grinder to the brim.")
				break

		if(!O.contents.len)
			to_chat(user, "You empty the [O] into the All-In-One grinder.")

		src.updateUsrDialog()
		return 0

	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "Cannot refine into a reagent.")
		return 1

	if(!user.drop_item(O, src))
		user << "<span class='notice'>\The [O] is stuck to your hands!</span>"
		return 1

	holdingitems += O
	src.updateUsrDialog()
	return 0

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
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))

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
			grind()
		if("juice")
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
	if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
		var/mob/living/silicon/robot/R = beaker:holder:loc
		if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
			beaker.loc = R
		else
			beaker.loc = beaker:holder
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && beaker && !(stat & (NOPOWER|BROKEN) && usr.dexterity_check()) && !inuse)
		if(holdingitems.len)
			grind()
		else
			detach()
		return
	return ..()

/obj/machinery/reagentgrinder/proc/eject()
	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems = list()

/obj/machinery/reagentgrinder/proc/is_allowed(var/obj/item/weapon/reagent_containers/O)
	for (var/i in blend_items)
		if(istype(O, i))
			return 1
	return 0

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(var/obj/item/weapon/grown/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(var/obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(var/obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(var/obj/item/weapon/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(var/obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(var/obj/item/O)
	holdingitems -= O
	qdel(O)
	O = null

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(get_turf(src), speed_multiplier < 2 ? 'sound/machines/juicer.ogg' : 'sound/machines/juicerfast.ogg', 30, 1)
	inuse = 1
	spawn(50/speed_multiplier)
		inuse = 0
		interact(usr)
	//Snacks
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()


	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(get_turf(src), speed_multiplier < 2 ? 'sound/machines/blender.ogg' : 'sound/machines/blenderfast.ogg', 50, 1)
	inuse = 1
	spawn(60/speed_multiplier)
		inuse = 0
		updateUsrDialog()
	//Snacks and Plants
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if (O.reagents != null && O.reagents.has_reagent(NUTRIMENT))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount(NUTRIMENT), space))
						O.reagents.remove_reagent(NUTRIMENT, min(O.reagents.get_reagent_amount(NUTRIMENT), space))
				else
					if (O.reagents != null && O.reagents.has_reagent(NUTRIMENT))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount(NUTRIMENT)*abs(amount)), space))
						O.reagents.remove_reagent(NUTRIMENT, min(O.reagents.get_reagent_amount(NUTRIMENT), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for (var/obj/item/stack/sheet/O in holdingitems)
		var/allowed = get_allowed_by_id(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.amount, 1); i++)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if (space < amount)
					break
			if (i == round(O.amount, 1))
				remove_object(O)
				break

	//xenoarch
	for(var/obj/item/weapon/rocksliver/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space), O.geological_data)

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//Everything else - Transfers reagents from it into beaker
	for (var/obj/item/weapon/reagent_containers/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)

	//All other generics
	for (var/obj/item/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)