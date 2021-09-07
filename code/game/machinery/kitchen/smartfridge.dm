#define MAX_SHELVES 4
#define MINIICONS_OFF 0
#define MINIICONS_ON 1
#define MINIICONS_UNCROPPED 2
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	density = 1
	opacity = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	source_temperature = T0C + 4
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/list/datum/fridge_pile/piles = list()
	var/opened = 0.0
	var/display_miniicons = FALSE

	var/list/accepted_types = list(	/obj/item/weapon/reagent_containers/food/snacks/grown,
									/obj/item/weapon/grown,
									/obj/item/seeds,
									/obj/item/weapon/reagent_containers/food/snacks/meat,
									/obj/item/weapon/reagent_containers/food/snacks/honeycomb,
									/obj/item/weapon/reagent_containers/food/snacks/egg,
									/obj/item/weapon/reagent_containers/food/condiment)

	machine_flags = SCREWTOGGLE | CROWDESTROY | EJECTNOTDEL | WRENCHMOVE | FIXED2WORK | EMAGGABLE

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/smartfridge/power_change()
	if( powered() )
		stat &= ~NOPOWER
		set_light(2)
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			if(!(stat & BROKEN))
				kill_light()


/datum/fridge_pile
	var/name = ""
	var/obj/machinery/smartfridge/fridge
	var/amount = 1
	var/shelf = 2
	var/mini_icon

/datum/fridge_pile/New(var/name, var/fridge, var/amount, var/mini_icon)
	src.name = name
	src.fridge = fridge
	src.amount = amount
	src.mini_icon = mini_icon

/datum/fridge_pile/Destroy()
	fridge.piles -= src.name
	fridge = null
	..()

/datum/fridge_pile/proc/addAmount(var/amt)
	amount += amt

/datum/fridge_pile/proc/removeAmount(var/amt)
	amount -= amt
	if(amount <= 0)
		qdel(src)

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

	update_nearby_tiles()

/obj/machinery/smartfridge/Destroy()
	for(var/key in piles)
		qdel(piles[key])
	piles.Cut()

	update_nearby_tiles()

	..()

/obj/machinery/smartfridge/proc/accept_check(var/obj/item/O as obj, var/mob/user as mob)
	for(var/ac_type in accepted_types)
		if(istype(O, ac_type))
			return 1

/obj/machinery/smartfridge/thermal_energy_transfer()
	return -75 //slow

/obj/machinery/smartfridge/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	for(var/obj/item/I in contents)
		I.attempt_heating(src)

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
	..()
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'

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
	..()
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'

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
	desc = "A refrigerated storage unit for slime extracts."

	accepted_types = list(
		/obj/item/slime_extract,
		/obj/item/weapon/slimepotion,
		/obj/item/weapon/slimepotion2,
		/obj/item/weapon/slimesteroid,
		/obj/item/weapon/slimesteroid2,
		/obj/item/weapon/slimenutrient,
		/obj/item/weapon/slimedupe,
		/obj/item/weapon/slimeres
	)

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

/obj/machinery/smartfridge/bloodbank
	name = "\improper Refrigerated Blood Bank"
	desc = "A refrigerated storage unit for blood packs."
	icon_state = "bloodbank"
	icon_on = "bloodbank"

	accepted_types = list(/obj/item/weapon/reagent_containers/blood)

/obj/machinery/smartfridge/bloodbank/New()
	. = ..()
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge/bloodbank,
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

//Separate subtype for mapping so that all newly constructed blood banks don't get filled with blood packs
/obj/machinery/smartfridge/bloodbank/filled/New()
	. = ..()

	for(var/i = 0 to 4)
		insert_item(new /obj/item/weapon/reagent_containers/blood/APlus(src))
		insert_item(new /obj/item/weapon/reagent_containers/blood/AMinus(src))
		insert_item(new /obj/item/weapon/reagent_containers/blood/BPlus(src))
		insert_item(new /obj/item/weapon/reagent_containers/blood/BMinus(src))
		insert_item(new /obj/item/weapon/reagent_containers/blood/OPlus(src))
		insert_item(new /obj/item/weapon/reagent_containers/blood/OMinus(src))
		insert_item(new /obj/item/weapon/reagent_containers/blood/empty(src))

/obj/machinery/smartfridge/bloodbank/power_change()
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



// Returns TRUE on success
/obj/machinery/smartfridge/proc/try_insert_item(var/obj/item/O, var/mob/user)
	if(!allowed(user) && !emagged)
		to_chat(user, "<span class='warning'>[bicon(src)] Access denied.</span>")
		return FALSE
	if(accept_check(O))
		if(!user.drop_item(O, src))
			return FALSE
		insert_item(O)
		user.visible_message(	"<span class='notice'>[user] has added \the [O] to \the [src].", \
								"<span class='notice'>You add \the [O] to \the [src].")
		updateUsrDialog()
		return TRUE
	else
		return dump_bag(O, user)

/obj/machinery/smartfridge/proc/insert_item(var/obj/item/O)
	var/formatted_name = format_text(O.name)
	var/datum/fridge_pile/thisPile = piles[formatted_name]
	if(istype(thisPile))
		thisPile.addAmount(1)
	else
		piles[formatted_name] = new/datum/fridge_pile(formatted_name, src, 1, costly_bicon(O))


/obj/machinery/smartfridge/proc/dump_bag(var/obj/item/weapon/storage/bag/B, var/mob/user)
	if(!istype(B))
		return FALSE
	if(!allowed(user) && !emagged)
		to_chat(user, "<span class='warning'>[bicon(src)] Access denied.</span>")
		return FALSE
	var/objects_loaded = 0
	for(var/obj/G in B.contents)
		if(!accept_check(G))
			continue
		if(!B.remove_from_storage(G, src))
			continue
		insert_item(G)
		objects_loaded++
	if(objects_loaded)
		user.visible_message("<span class='notice'>[user] loads \the [src] with \the [B].</span>", \
							"<span class='notice'>You load \the [src] with \the [B].</span>")
		if(B.contents.len > 0)
			to_chat(user, "<span class='notice'>Some items are refused.</span>")
	updateUsrDialog()
	return TRUE

//Unwrenching a SmartFridge is especially longer to make it much easier to intervene
/obj/machinery/smartfridge/wrenchAnchor(var/mob/user, var/obj/item/I, var/time_to_wrench = 10 SECONDS)

	. = ..()
	if(.)
		update_nearby_tiles()

/obj/machinery/smartfridge/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if((stat & NOPOWER) || (contents.len >= MAX_N_OF_ITEMS))
		return FALSE
	if(accept_check(AM))
		piles = sortList(piles)
		AM.forceMove(src)
		insert_item(AM)
		return TRUE
	else if(istype(AM,/obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/bag/B = AM
		var/objects_loaded = 0
		for(var/obj/G in B.contents)
			if(!accept_check(G))
				continue
			if(!B.remove_from_storage(G, src))
				continue
			insert_item(G)
			objects_loaded++
		if(objects_loaded)
			return TRUE
	return FALSE

/obj/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(..())
		return 1
	if(stat & NOPOWER)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return 1
	if(contents.len >= MAX_N_OF_ITEMS)
		to_chat(user, "<span class='notice'>\The [src] is full.</span>")
		return 1
	if(try_insert_item(O, user))
		piles = sortList(piles)
		return 1
	else if(istype(O, /obj/item/weapon/paper) && user.drop_item(O, src.loc))
		if(O.loc == src.loc && params)
			O.setPixelOffsetsFromParams(params)
			O.layer = MACHINERY_LAYER + 0.1 //so it layers below the pills we'll be ejecting from the fridge. resets when picked up - i guess someone COULD drag the paper away but I'm not about to lose sleep over that
			to_chat(user, "<span class='notice'>You hang \the [O.name] on the fridge.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return 1
	updateUsrDialog()
	return 1

/obj/machinery/smartfridge/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/smartfridge/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/smartfridge/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/smartfridge/emag(mob/user)
	new/obj/effect/sparks(get_turf(src))
	playsound(loc,"sparks",50,1)
	emagged = !emagged
	if(emagged)
		to_chat(user, "<span class='warning'>You disable the security protocols.</span>")
	else
		to_chat(user, "<span class='warning'>You restore the security protocols.</span>")

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
				dat += "<FONT color = 'blue'><B>[sanitize(P.name)]</B>: [P.amount] </font>"
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
		return 1

	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	if(!allowed(usr) && !emagged) //this explicitly means all topic() options below this line require access
		to_chat(usr, "<span class='warning'>[bicon(src)] Access denied.</span>")
		return

	usr.set_machine(src)

	var/formatted_name = format_text(href_list["pile"])
	if(href_list["amount"])
		var/amount = text2num(href_list["amount"])
		var/datum/fridge_pile/thisPile = piles[formatted_name]
		if(!istype(thisPile)) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
			return

		thisPile.removeAmount(amount)

		var/i = amount
		for(var/obj/O in contents)
			if(format_text(O.name) == formatted_name)
				O.forceMove(src.loc)
				i--
				if(i <= 0)
					break

	else if(href_list["shelf"])
		var/datum/fridge_pile/thisPile = piles[formatted_name]
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

/obj/machinery/smartfridge/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(!istype(mover))
		return !anchored
	return ..()

#undef MAX_SHELVES
#undef MINIICONS_ON
#undef MINIICONS_OFF
#undef MINIICONS_UNCROPPED
