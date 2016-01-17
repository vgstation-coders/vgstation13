/*----------------------
File created due to bloat in Chemistry-Machinery.dm
1/15/2016
Contains:
* All-In-One Grinder
* Mortar
----------------------*/

/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
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

	if (!is_allowed(O))
		to_chat(user, "Cannot refine into a reagent.")
		return 1

	if(istype(O,/obj/item/stack))
		var/obj/item/stack/N = new O.type(src, amount=1)
		var/obj/item/stack/S = O
		S.use(1)
		holdingitems += N
		src.updateUsrDialog()
		return 0

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

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:1016: dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += {"<A href='?src=\ref[src];action=process'>Process contents</a><BR>
				<A href='?src=\ref[src];action=extract'>Extract reagents</a><BR><BR>"}
			// END AUTOFIX
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject contents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach beaker</a><BR>"
	else
		dat += "Please wait..."
	dat = list2text(dat)
	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder", src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "reagentgrinder")

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..()) return 1
	usr.set_machine(src)
	switch(href_list["action"])
		if ("process")
			grind(1)
		if("extract")
			grind(0)
		if("eject")
			eject()
		if ("detach")
			detach()
	src.updateUsrDialog()

/obj/machinery/reagentgrinder/proc/detach()
	if (usr.stat != 0) return
	if (!beaker) return
	beaker.forceMove(get_turf(src))
	if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
		var/mob/living/silicon/robot/R = beaker:holder:loc
		if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
			beaker.forceMove(R)
		else
			beaker.forceMove(beaker:holder)
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()
	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.forceMove(get_turf(src))
	holdingitems.Cut()

/obj/machinery/reagentgrinder/proc/is_allowed(var/obj/item/I)
	if(I.grindable_reagent || istype(I, /obj/item/weapon/reagent_containers/food/snacks) || istype(I,/obj/item/weapon/grown)) return 1
	return 0

/obj/machinery/reagentgrinder/proc/grind(var/process = 0) //passed to grind_item
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(get_turf(src), speed_multiplier < 2 ? 'sound/machines/blender.ogg' : 'sound/machines/blenderfast.ogg', 50, 1)
	inuse = 1
	spawn(60/speed_multiplier)
		inuse = 0
		interact(usr)

		for(var/obj/item/I in holdingitems)
			holdingitems -= I
			if(beaker.reagents.grind_item(I,process)) break
		src.updateUsrDialog()

/* --------------------------
End Grinder
Begin Mortar
---------------------------*/

/obj/item/weapon/reagent_containers/glass/mortar
	name = "mortar"
	desc = "This is a reinforced bowl, used for crushing reagents. Unga bunga Rockstop."
	icon = 'icons/obj/food.dmi'
	icon_state = "mortar"
	flags = FPRINT  | OPENCONTAINER
	volume = 50
	amount_per_transfer_from_this = 5
	/*PLAN
	[Process] - produces grindable_reagent, or if none, tries to extract
	[Extract] - extracts reagents*/

	var/obj/item/crushable = null

/obj/item/weapon/reagent_containers/glass/mortar/Destroy()
	qdel(crushable)
	crushable = null
	. = ..()

/obj/item/weapon/reagent_containers/glass/mortar/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (isscrewdriver(O))
		if(crushable)
			crushable.forceMove(user.loc)
		new /obj/item/stack/sheet/metal(user.loc)
		new /obj/item/trash/bowl(user.loc)
		qdel(src) //Important detail
		return
	if (crushable)
		to_chat(user, "<span class ='warning'>There's already something inside!</span>")
		return 1
	if (!O.grindable_reagent && !istype(O, /obj/item/weapon/reagent_containers/food/snacks) && !istype(O,/obj/item/weapon/grown))
		to_chat(user, "<span class ='warning'>You can't grind that!</span>")
		return ..()

	if(istype(O, /obj/item/stack/))
		var/obj/item/stack/N = new O.type(src, amount=1)
		var/obj/item/stack/S = O
		S.use(1)
		crushable = N
		to_chat(user, "<span class='notice'>You place \the [N] in \the [src].</span>")
		return 0
	else if(!user.drop_item(O, src))
		to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
		return

	crushable = O
	to_chat(user, "<span class='notice'>You place \the [O] in \the [src].</span>")
	return 0

/obj/item/weapon/reagent_containers/glass/mortar/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(user.get_inactive_hand() != src) return ..()
	if(crushable)
		crushable.forceMove(user.loc)
		user.put_in_active_hand(crushable)
		crushable = null
	return

/obj/item/weapon/reagent_containers/glass/mortar/attack_self(mob/user as mob)
	if(!crushable)
		to_chat(user, "<span class='notice'>There is nothing to be crushed.</span>")
		return
	if (reagents.total_volume >= volume)
		to_chat(user, "<span class='warning'>There is no more space inside!</span>")
		return

	to_chat(user, "<span class='notice'>You grind the contents into reagents!</span>")
	reagents.grind_item(crushable,1)
	crushable = null
	return

/obj/item/weapon/reagent_containers/glass/mortar/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [crushable ? "an unground [crushable] inside." : "nothing to be crushed."]</span>")
