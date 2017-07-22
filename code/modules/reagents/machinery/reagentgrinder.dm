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
			var/atom/movable/holder = E.holder
			holder.on_moved.Remove(targetMoveKey)
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
		if (O.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [O] is too big to fit.</span>")
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

	//There used to be a check here to only allow certain whitelisted things to be put inside the mortar. Now we just check size. God help us.
	if(O.w_class >= W_CLASS_SMALL)
		to_chat(user, "<span class ='warning'>That's too big to fit inside!</span>")
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

			dat += {"<A href='?src=\ref[src];action=process'>Process the reagents</a><BR>
				<A href='?src=\ref[src];action=extract'>Extract the reagents</a><BR><BR>"}
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
		if ("process")
			grind()
		if("extract")
			grind(1)
		if("eject")
			eject()
		if("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/reagentgrinder/proc/detach()
	if (!beaker)
		return
	beaker.forceMove(src.loc)
	if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
		var/obj/item/weapon/reagent_containers/glass/beaker/large/cyborg/borgbeak = beaker
		borgbeak.return_to_modules()
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && beaker && !(stat & (NOPOWER|BROKEN) && user.dexterity_check()) && !inuse)
		detach()
		return
	return ..()

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

	for(var/obj/item/O in holdingitems)
		O.forceMove(src.loc)
		holdingitems -= O
	holdingitems = list()

/obj/machinery/reagentgrinder/proc/remove_object(var/obj/item/O)
	holdingitems -= O
	qdel(O)
	O = null

/obj/machinery/reagentgrinder/proc/grind(var/extract=0)

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

	for (var/obj/item/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		if(!O.ground_act(src,extract))
			remove_object(O)
		else
			break
			//What should we do if something ungrindable found its way inside?
