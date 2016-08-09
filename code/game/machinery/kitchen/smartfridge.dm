/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/item_quants = list()
	//var/ispowered = 1 //starts powered
	//var/isbroken = 0
	//OBSOLETE: That's what the BROKEN and NOPOWER stat bitflags are for
	var/opened = 0.0

	var/list/accepted_types = list(	/obj/item/weapon/reagent_containers/food/snacks/grown,
									/obj/item/weapon/grown,
									/obj/item/seeds/,
									/obj/item/weapon/reagent_containers/food/snacks/meat,
									/obj/item/weapon/reagent_containers/food/snacks/egg)

	machine_flags = SCREWTOGGLE | CROWDESTROY | EJECTNOTDEL

	light_color = LIGHT_COLOR_CYAN
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(2)
		else
			set_light(0)


/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/smartfridge/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/smartfridge/proc/accept_check(var/obj/item/O as obj, var/mob/user as mob)
	for(var/ac_type in accepted_types)
		if(istype(O, ac_type))
			return 1

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	icon_on = "seeds"
	icon_off = "seeds-off"

	accepted_types = list(/obj/item/seeds)

	light_color = null

/obj/machinery/smartfridge/seeds/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge/seeds,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	icon_on = "smartfridge_chem"
	req_one_access = list(access_chemistry, access_medical)

	accepted_types = list(	/obj/item/weapon/reagent_containers/glass,
							/obj/item/weapon/storage/pill_bottle,
							/obj/item/weapon/reagent_containers/pill)

/obj/machinery/smartfridge/medbay/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge/medbay,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."

	accepted_types = list(	/obj/item/weapon/storage/pill_bottle,
							/obj/item/weapon/reagent_containers)

/obj/machinery/smartfridge/chemistry/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge/chemistry,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

	accepted_types = list(	/obj/item/weapon/reagent_containers/glass,
							/obj/item/weapon/reagent_containers/food/drinks,
							/obj/item/weapon/reagent_containers/food/condiment)

/obj/machinery/smartfridge/drinks/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge/drinks,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/smartfridge/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"

	accepted_types = list(/obj/item/slime_extract)

/obj/machinery/smartfridge/extract/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge/extract,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()


/obj/machinery/smartfridge/power_change()
	if( powered() )
		stat &= ~NOPOWER
		if(!(stat & BROKEN))
			icon_state = icon_on
	else
		spawn(rand(0, 15))
		stat |= NOPOWER
		if(!(stat & BROKEN))
			icon_state = icon_off


/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(stat & NOPOWER)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return 1

	if(..())
		return 1

	if(accept_check(O))
		if(contents.len >= MAX_N_OF_ITEMS)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return 1
		else
			if(!user.drop_item(O, src))
				return 1

			if(item_quants[O.name])
				item_quants[O.name]++
			else
				item_quants[O.name] = 1
			user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
								 "<span class='notice'>You add \the [O] to \the [src].")

	else if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/bag/bag = O
		var/objects_loaded = 0
		for(var/obj/G in bag.contents)
			if(accept_check(G))
				if(contents.len >= MAX_N_OF_ITEMS)
					to_chat(user, "<span class='notice'>\The [src] is full.</span>")
					return 1
				else
					bag.remove_from_storage(G,src)
					if(item_quants[G.name])
						item_quants[G.name]++
					else
						item_quants[G.name] = 1
					objects_loaded++
		if(objects_loaded)

			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [bag].</span>", \
								 "<span class='notice'>You load \the [src] with \the [bag].</span>")
			if(bag.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

	else if(istype(O, /obj/item/weapon/paper) && user.drop_item(O, src.loc))
		var/list/params_list = params2list(params)
		if(O.loc == src.loc && params_list.len)
			var/clamp_x = 16
			var/clamp_y = 16
			O.pixel_x = Clamp(text2num(params_list["icon-x"]) - clamp_x, -clamp_x, clamp_x)
			O.pixel_y = Clamp(text2num(params_list["icon-y"]) - clamp_y, -clamp_y, clamp_y)
			to_chat(user, "<span class='notice'>You hang \the [O.name] on the fridge.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return 1
	item_quants = sortList(item_quants)
	updateUsrDialog()
	return 1

/obj/machinery/smartfridge/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/smartfridge/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/smartfridge/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/interact(mob/user as mob)
	if(stat & NOPOWER)
		return

	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		for (var/O in item_quants)
			if(item_quants[O] > 0)
				var/N = item_quants[O]
				var/escaped_name = url_encode(O) //This is necessary to contain special characters in Topic() links, otherwise, BYOND sees "Dex+" and drops the +.

				dat += {"<FONT color = 'blue'><B>[capitalize(O)]</B>:
					[N] </font>
					<a href='byond://?src=\ref[src];vend=[escaped_name];amount=1'>Vend</A> "}
				if(N > 5)
					dat += "(<a href='byond://?src=\ref[src];vend=[escaped_name];amount=5'>x5</A>)"
					if(N > 10)
						dat += "(<a href='byond://?src=\ref[src];vend=[escaped_name];amount=10'>x10</A>)"
						if(N > 25)
							dat += "(<a href='byond://?src=\ref[src];vend=[escaped_name];amount=25'>x25</A>)"
				if(N > 1)
					dat += "(<a href='?src=\ref[src];vend=[escaped_name];amount=[N]'>All</A>)"
				dat += "<br>"

		dat += "</TT>"
	user << browse("<HEAD><TITLE>[src] Supplies</TITLE></HEAD><TT>[dat]</TT>", "window=smartfridge")
	onclose(user, "smartfridge")
	return

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	var/N = href_list["vend"]
	var/amount = text2num(href_list["amount"])

	if(item_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
		return

	item_quants[N] = max(item_quants[N] - amount, 0)

	var/i = amount
	for(var/obj/O in contents)
		if(O.name == N)
			O.forceMove(src.loc)
			i--
			if(i <= 0)
				break

	src.updateUsrDialog()
