#define MAX_SHELVES 4
#define MINIICONS_OFF 0
#define MINIICONS_ON 1
#define MINIICONS_UNCROPPED 2
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/list/datum/fridge_pile/piles = list()
	var/opened = 0.0
	var/display_miniicons = FALSE

	var/list/accepted_types = list(	/obj/item/weapon/reagent_containers/food/snacks/grown,
									/obj/item/weapon/grown,
									/obj/item/seeds,
									/obj/item/weapon/reagent_containers/food/snacks/meat,
									/obj/item/weapon/reagent_containers/food/snacks/egg,
									/obj/item/weapon/reagent_containers/food/condiment)

	machine_flags = SCREWTOGGLE | CROWDESTROY | EJECTNOTDEL

	light_color = LIGHT_COLOR_CYAN
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(2)
		else
			set_light(0)

/datum/fridge_pile
	var/name = ""
	var/obj/machinery/smartfridge/fridge
	var/amount = 1
	var/shelf = 1
	var/mini_icon

/datum/fridge_pile/New(var/name, var/fridge, var/amount, var/mini_icon)
	src.name = name
	src.fridge = fridge
	src.amount = amount
	src.mini_icon = mini_icon

/datum/fridge_pile/Destroy()
	fridge.piles -= src.name
	fridge = null

/datum/fridge_pile/proc/addAmount(var/amt)
	amount += amt

/datum/fridge_pile/proc/removeAmount(var/amt)
	amount -= amt
	if(amount <= 0)
		returnToPool(src)

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

/obj/machinery/smartfridge/Destroy()
	for(var/key in piles)
		returnToPool(piles[key])
	..()

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

			var/datum/fridge_pile/thisPile = piles[O.name]
			if(istype(thisPile))
				thisPile.addAmount(1)
			else
				piles[O.name] = getFromPool(/datum/fridge_pile, O.name, src, 1, costly_bicon(O))
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
					var/datum/fridge_pile/thisPile = piles[G.name]
					if(istype(thisPile))
						thisPile.addAmount(1)
					else
						piles[G.name] = new/datum/fridge_pile(G.name, src, 1, costly_bicon(G))
					objects_loaded++
		if(objects_loaded)

			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [bag].</span>", \
								 "<span class='notice'>You load \the [src] with \the [bag].</span>")
			if(bag.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

	else if(istype(O, /obj/item/weapon/paper) && user.drop_item(O, src.loc))
		var/list/params_list = params2list(params)
		if(O.loc == src.loc && params_list.len)
			var/clamp_x = WORLD_ICON_SIZE/2
			var/clamp_y = WORLD_ICON_SIZE/2
			O.pixel_x = Clamp(text2num(params_list["icon-x"]) - clamp_x, -clamp_x, clamp_x)
			O.pixel_y = Clamp(text2num(params_list["icon-y"]) - clamp_y, -clamp_y, clamp_y)
			to_chat(user, "<span class='notice'>You hang \the [O.name] on the fridge.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return 1
	piles = sortList(piles)
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

	var/dat = list()

	if(contents.len == 0)
		dat += "<font color = 'red'><TT>No product loaded!</TT></font>"
	else
		var/imagedesc
		switch(display_miniicons)
			if(MINIICONS_ON)
				imagedesc = "On"
			if(MINIICONS_UNCROPPED)
				imagedesc = "Uncropped"
			if(MINIICONS_OFF)
				imagedesc = "Off"
		dat += "<span class='imageToggleButton'><TT>Images: <a href='byond://?src=\ref[src];display_miniicons=1;'>[imagedesc]</A></TT></span>"

		dat += "<TT><b>Select an item:</b></TT>"

		var/list/shelves[MAX_SHELVES]
		for(var/i = 1 to MAX_SHELVES)
			shelves[i] = list()

		for(var/key in piles)
			var/datum/fridge_pile/P = piles[key]
			shelves[P.shelf] += P

		var/shelfcounter = 1
		for(var/list/shelf in shelves)
			var/pilecounter = 1

			if(shelfcounter != 1)
				dat += "<hr>"
			dat += "<table>"

			for(var/datum/fridge_pile/P in shelf)
				var/escaped_name = url_encode(P.name) //This is necessary to contain special characters in Topic() links, otherwise, BYOND sees "Dex+" and drops the +.
				var/color = pilecounter % 2 == 0 ? "#e6e6e6" : "#f2f2f2"
				dat += "<tr style='background-color:[color]'>"
				if(display_miniicons)
					dat += "<td class='fridgeIcon [display_miniicons == MINIICONS_UNCROPPED ? "" : "cropped"]'>[P.mini_icon]</td>"
				dat += "<td class='pileName'><TT>"
				dat += "<FONT color = 'blue'><B>[capitalize(P.name)]</B>: [P.amount] </font>"
				dat += "<a href='byond://?src=\ref[src];pile=[escaped_name];amount=1'>Vend</A> "
				if(P.amount > 5)
					dat += "(<a href='byond://?src=\ref[src];pile=[escaped_name];amount=5'>x5</A>)"
					if(P.amount > 10)
						dat += "(<a href='byond://?src=\ref[src];pile=[escaped_name];amount=10'>x10</A>)"
						if(P.amount > 25)
							dat += "(<a href='byond://?src=\ref[src];pile=[escaped_name];amount=25'>x25</A>)"
				if(P.amount > 1)
					dat += "(<a href='?src=\ref[src];pile=[escaped_name];amount=[P.amount]'>All</A>)"
				dat += "</TT></td>"

				dat += "<td class='shelfButton'><TT>"
				dat += P.shelf > 1 ? "<a href='?src=\ref[src];pile=[escaped_name];shelf=up'>&#8743;</A>" : "&nbsp"
				dat += P.shelf < MAX_SHELVES ? "<a href='?src=\ref[src];pile=[escaped_name];shelf=down'>&#8744;</A>" : "&nbsp"
				dat += "</TT></td>"

				dat += "</tr>"
				pilecounter++

			dat += "</table>"
			shelfcounter++

	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal

	var/datum/browser/clean/popup = new(user, "smartfridge", "[src] Supplies", 450, 500)
	popup.add_stylesheet("common", 'html/browser/smartfridge.css') //Completely fucking nuke common.css, because clean.css doesn't clean shit.
	popup.set_content(dat)
	popup.open()

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	var/N = href_list["pile"]
	if(href_list["amount"])
		var/amount = text2num(href_list["amount"])
		var/datum/fridge_pile/thisPile = piles[N]
		if(!istype(thisPile)) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
			return

		thisPile.removeAmount(amount)

		var/i = amount
		for(var/obj/O in contents)
			if(O.name == N)
				O.forceMove(src.loc)
				i--
				if(i <= 0)
					break

	else if(href_list["shelf"])
		var/datum/fridge_pile/thisPile = piles[N]
		if(href_list["shelf"] == "up" && thisPile.shelf > 1)
			thisPile.shelf -= 1
		else if(href_list["shelf"] == "down" && thisPile.shelf < MAX_SHELVES)
			thisPile.shelf += 1

	else if(href_list["display_miniicons"])
		switch(display_miniicons)
			if(MINIICONS_ON)
				display_miniicons = MINIICONS_UNCROPPED
			if(MINIICONS_UNCROPPED)
				display_miniicons = MINIICONS_OFF
			if(MINIICONS_OFF)
				display_miniicons = MINIICONS_ON

	src.updateUsrDialog()

#undef MAX_SHELVES
#undef MINIICONS_ON
#undef MINIICONS_OFF
#undef MINIICONS_UNCROPPED
