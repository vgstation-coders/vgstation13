
/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EJECTNOTDEL
	flags = OPENCONTAINER | NOREACT
	pass_flags = PASSTABLE
	log_reagents = 0 //transferred 5u of flour from a flour sack [0x20107e8] to Microwave [0x2007fdd]. transferred 5u of flour from a flour sack [0x20107e8] to Microwave [0x2007fdd]. transferred 5u of flour from a flour sack [0x20107e8] to Microwave [0x2007fdd].
	var/operating = 0 // Is it on?
	var/opened = 0.0
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/reagent_disposal = 1 //Does it empty out reagents when you eject? Default yes.
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items // List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/list/holdingitems = list()
	var/limit = 100
	var/speed_multiplier = 1
	var/scanning_power = 0
	var/global/list/accepts_reagents_from = list(/obj/item/weapon/reagent_containers/glass,
												/obj/item/weapon/reagent_containers/food/drinks,
												/obj/item/weapon/reagent_containers/food/condiment,
												/obj/item/weapon/reagent_containers/dropper)

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/microwave,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/console_screen\
	)

// see code/modules/food/recipes_microwave.dm for recipes
//Cannot use tools - screwdriver and crowbar for recipes. Or at least fix things before you do
//TODO - Get a maint panel sprite and J-J-Jam it in.
//Biiiig Thanks to Kaze_Espada, SuperSayu, Jordie, MrPerson, and HUUUUGE thank you to Arancalos from #coderbus for patiently helping for hours, and practically doing it themselves, to get the microwaves to not have their stock parts as ingredients upon construction. May they enjoy their hard earned plunder.
//HUUUUUUUGE thanks to D3athrow for getting it to the finish line
/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/*******************
*   Initialising
********************/

/obj/machinery/microwave/New()
	. = ..()

	RefreshParts()
	create_reagents(100)

	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe)-/datum/recipe))
			available_recipes+= new type
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent

/*******************
*   Part Upgrades
********************/
/obj/machinery/microwave/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating-1
	speed_multiplier = initial(speed_multiplier)+(T * 0.5)

	T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/M in component_parts)
		T += M.rating-1
	scanning_power = initial(scanning_power)+(T)

/*******************
*   Item Adding
********************/
/obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && isscrewdriver(O)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the microwave.</span>", \
				"<span class='notice'>You start to fix part of the microwave.</span>" \
			)
			if (do_after(user, src,20))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of the microwave.</span>", \
					"<span class='notice'>You have fixed part of the microwave.</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && iswrench(O)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the microwave.</span>", \
				"<span class='notice'>You start to fix part of the microwave.</span>" \
			)
			if (do_after(user, src,20))
				user.visible_message( \
					"<span class='notice'>[user] fixes the microwave.</span>", \
					"<span class='notice'>You have fixed the microwave.</span>" \
				)
				src.icon_state = "mw"
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags |= OPENCONTAINER
		else
			to_chat(user, "<span class='warning'>It's broken!</span>")
			return 1
	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		var/obj/item/weapon/reagent_containers/R = O
		if(istype(R)) // If they're trying to clean it then let them
			if(R.reagents.amount_cache.len == 1 && R.reagents.has_reagent(CLEANER, 5))
				user.visible_message( \
					"<span class='notice'>[user] starts to clean the microwave.</span>", \
					"<span class='notice'>You start to clean the microwave.</span>" \
				)
				if (do_after(user, src,20))
					R.reagents.remove_reagent(CLEANER,5)
					user.visible_message( \
						"<span class='notice'>[user]  has cleaned  the microwave.</span>", \
						"<span class='notice'>You have cleaned the microwave.</span>" \
					)
					src.dirty = 0 // It's clean!
					src.broken = 0 // just to be sure
					src.icon_state = "mw"
					src.flags |= OPENCONTAINER
					return 1
		else //Otherwise bad luck!!
			to_chat(user, "<span class='warning'>It's too dirty!</span>")
			return 1

	if(..())
		return 1

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return 1
	else if(istype(O, /obj/item/weapon/storage/bag/plants) || istype(O, /obj/item/weapon/storage/bag/food/borg))
		var/obj/item/weapon/storage/bag/B = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/G in O.contents)
			B.remove_from_storage(G,src)
			if(contents && contents.len >= limit) //Sanity checking so the microwave doesn't overfill
				to_chat(user, "You fill the Microwave to the brim.")
				break

		if(!O.contents.len)
			to_chat(user, "You empty \the [O] into the Microwave.")
			src.updateUsrDialog()
			return 0
			if (!is_type_in_list(O.contents))
				to_chat(user, "<span class='warning'>Your [O] contains components unsuitable for cookery.</span>")
				return 1

		if(user.drop_item(O, src))
			holdingitems += O
			src.updateUsrDialog()
		return 1
	else if(is_type_in_list(O,acceptable_items))
		if (istype(O,/obj/item/stack) && O:amount>1)
			new O.type (src)
			O:use(1)
			user.visible_message( \
				"<span class='notice'>[user] has added one of [O] to \the [src].</span>", \
				"<span class='notice'>You add one of [O] to \the [src].</span>")
		else
		//	user.before_take_item(O)	//This just causes problems so far as I can tell. -Pete
			if(user.drop_item(O, src))
				user.visible_message( \
					"<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
					"<span class='notice'>You add \the [O] to \the [src].</span>")
	else if(is_type_in_list(O,accepts_reagents_from))
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				to_chat(user, "<span class='warning'>Your [O] contains components unsuitable for cookery.</span>")
				return 1
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		to_chat(user, "<span class='warning'>This is ridiculous. You can not fit \the [G.affecting] in this [src].</span>")
		return 1
	else
		to_chat(user, "<span class='warning'>You have no idea what you can cook with this [O].</span>")
		return 1
	src.updateUsrDialog()

/obj/machinery/microwave/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/microwave/attack_ai(mob/user as mob)
	if(istype(user,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = user
		if(HAS_MODULE_QUIRK(R, MODULE_CAN_HANDLE_FOOD))
			user.set_machine(src)
			interact(user)
			return 1
		to_chat(user, "<span class='warning'>You aren't equipped to interface with technology this old!</span>")
		return 0
	if(isAdminGhost(user))
		user.set_machine(src)
		interact(user)

/obj/machinery/microwave/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/interact(mob/user as mob) // The microwave Menu
	var/dat = ""
	if(src.broken > 0)
		dat = {"<TT>Bzzzzttttt</TT>"}
	else if(src.operating)
		dat = {"<TT>Microwaving in progress!<BR>Please wait...!</TT>"}
	else if(src.dirty==100)
		dat = {"<TT>This microwave is dirty!<BR>Please clean it before use!</TT>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans))
				items_measures[display_name] = "soybean"
				items_measures_p[display_name] = "soybeans"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/grapes))
				display_name = "Grapes"
				items_measures[display_name] = "bunch of grapes"
				items_measures_p[display_name] = "bunches of grapes"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes))
				display_name = "Green Grapes"
				items_measures[display_name] = "bunch of green grapes"
				items_measures_p[display_name] = "bunches of green grapes"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if (!(O in items_measures))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if (N==1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == CAPSAICIN)
				display_name = "Hotsauce"
			if (R.id == FROSTOIL)
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if (items_counts.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The microwave is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]<HR><BR>"}
			if (scanning_power >= 2 )
				var/datum/recipe/recipe = select_recipe(available_recipes,src)
				if (!recipe)
					dat += {"<font color = 'red'>ERROR: No matching recipe found!</font><br>"}
				else
					var/obj/O = recipe.result
					var/display_name = initial(O.name)
					dat += {"<b>Expected result: </b>[display_name]<br>"}
		dat += {"\
<A href='?src=\ref[src];action=cook'>Turn on!<BR>\
<A href='?src=\ref[src];action=dispose'>Eject ingredients!<BR><BR><BR>\
<A href='?src=\ref[src];action=reagenttoggle'>[reagent_disposal ? "Disable reagent disposal" : "Enable reagent disposal"]<BR>\
"}

	user << browse("<HEAD><TITLE>Microwave Controls</TITLE></HEAD><TT>[dat]</TT>", "window=microwave")
	onclose(user, "microwave")
	return



/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if (!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	if (!recipe)
		dirty += 1
		if (prob(max(10,dirty*5)))
			if (!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
		else if (has_extra_item())
			if (!wzhzhzh(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
		else
			if (!wzhzhzh(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
	else
		var/halftime = round(recipe.time/10/2)
		if (!wzhzhzh(halftime))
			abort()
			return
		if (!wzhzhzh(halftime))
			abort()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
		cooked = recipe.make_food(src)
		stop()
		if(cooked)
			cooked.forceMove(src.loc)
		return

/obj/machinery/microwave/proc/wzhzhzh(var/seconds as num)
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10/speed_multiplier)
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	src.visible_message("<span class='notice'>The microwave turns on.</span>", "<span class='notice'>You hear a microwave.</span>")
	src.operating = 1
	src.icon_state = "mw1"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/stop()
	playsound(src, 'sound/machines/ding.ogg', 50, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/dispose()
	if(operating)
		return
	for (var/obj/O in contents)
		O.forceMove(src.loc)
	if (src.reagents.total_volume)
		src.dirty++
		if(reagent_disposal)
			if(scanning_power >= 1) //You get one bottle, don't fuck it up
				var/obj/item/weapon/reagent_containers/food/condiment/C = new(get_turf(src))
				reagents.trans_to(C, reagents.total_volume)
			reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of the microwave contents.</span>")
	src.updateUsrDialog()

/obj/machinery/microwave/proc/muck_start()
	playsound(src, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	playsound(src, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message("<span class='warning'>The microwave gets covered in muck!</span>")
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.flags &= ~OPENCONTAINER //So you can't add condiments
	src.icon_state = "mwbloody" // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/microwave/proc/broke()
	spark(src, 2)
	src.icon_state = "mwb" // Make it look all busted up and shit
	src.visible_message("<span class='warning'>The microwave breaks!</span>") //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.flags &= ~OPENCONTAINER //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/microwave/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
		O = null
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent(CARBON, amount)
	ffuu.reagents.add_reagent(TOXIN, amount/10)
	return ffuu

/obj/machinery/microwave/CtrlClick(mob/user)
	if(isAdminGhost(user) || (!user.incapacitated() && Adjacent(user) && user.dexterity_check() && anchored))
		if(issilicon(user) && !attack_ai(user))
			return ..()
		cook() //Cook checks for power, brokenness, and contents internally
		return
	return ..()

/obj/machinery/microwave/AltClick(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return ..()
	if(!anchored)
		return ..()
	if(isAdminGhost(user) || (!user.incapacitated() && Adjacent(user) && user.dexterity_check()))
		if(issilicon(user) && !attack_ai(user))
			return ..()
		var/list/choices = list(
			list("Cook", "radial_cook"),
			list("Eject Ingredients", "radial_eject"),
			list("Toggle Reagent Disposal", (reagent_disposal ? "radial_chem_notrash" : "radial_chem_trash")),
			list("Examine", "radial_examine")
		)
		var/event/menu_event = new(owner = usr)
		menu_event.Add(src, "radial_check_handler")

		var/task = show_radial_menu(usr,loc,choices,custom_check = menu_event)
		if(!radial_check(usr))
			return

		switch(task)
			if("Cook")
				cook()
			if("Eject Ingredients")
				dispose()
			if("Toggle Reagent Disposal")
				reagent_disposal = !reagent_disposal
				updateUsrDialog()
			if("Examine")
				usr.examination(src)
		return
	return ..()

/obj/machinery/microwave/proc/radial_check_handler(list/arguments)
	var/event/E = arguments["event"]
	return radial_check(E.holder)

/obj/machinery/microwave/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(src.operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			dispose()

		if ("reagenttoggle")
			reagent_disposal = !reagent_disposal
			updateUsrDialog()
	return

/obj/machinery/microwave/npc_tamper_act(mob/living/L)
	//Put a random nearby item inside. 50% chance to start cooking
	var/list/pickable_items = list()

	for(var/obj/item/I in range(1, L))
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks) || is_type_in_list(I, acceptable_items))
			pickable_items.Add(I)

	if(!pickable_items.len)
		return

	var/obj/item/I = pick(pickable_items)
	if(L.Adjacent(I))
		visible_message("<span class='danger'>\The [L] stuffs \the [I] into \the [src]!</span>")
		attackby(I, L)
	else
		return

	if(prob(50))
		cook()
