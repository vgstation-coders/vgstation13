/obj/machinery/washing_machine
	name = "washing machine"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = 1
	anchored = 1.0
	var/wash_state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	//0 = closed
	//1 = open
	var/hacked = TRUE //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon
	var/speed_coefficient = 1
	var/size_coefficient = 1
	//Lists for each bin tier in order T1, T2, T3, T4. Whitelist doesn't change but its there for future proofing.
	//The lists are organized as type = size_coeff minimum to process
	var/list/whitelist_list = list(
		//Tier 1 and above
		/obj/item/stack/sheet/hairlesshide = 1,
		/obj/item/clothing/under = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/clothing/head = 1,
		/obj/item/clothing/gloves = 1,
		/obj/item/clothing/shoes = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/bedsheet = 1
		)
	var/list/blacklist_list = list(
		//Tier 1 and above
		//Nothing
		//Tier 2 and above
		/obj/item/clothing/head/helmet = 2,
		/obj/item/clothing/head/bomb_hood = 2,
		//Tier 3 and above
		/obj/item/clothing/suit/space = 3,
		/obj/item/clothing/suit/syndicatefake = 3,
		/obj/item/clothing/suit/cyborg_suit = 3,
		/obj/item/clothing/suit/bomb_suit = 3,
		/obj/item/clothing/suit/armor = 3,
		//Tier 4 and above
		/mob/living/carbon/human = 4,
		//Tier 5 and above
		/obj/item/clothing/mask/cigarette = 5,
		)

	machine_flags = SCREWTOGGLE | WRENCHMOVE

/obj/machinery/washing_machine/proc/is_in_blacklist(atom/A)
	for(var/type in blacklist_list)
		if(istype(A, type) && size_coefficient < blacklist_list[type])
			return TRUE
	return FALSE

/obj/machinery/washing_machine/proc/is_in_whitelist(atom/A)
	for(var/type in whitelist_list)
		if(istype(A, type) && size_coefficient >= whitelist_list[type])
			return TRUE
	return FALSE

/obj/machinery/washing_machine/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/washing_machine,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin
	)
	RefreshParts()

/obj/machinery/washing_machine/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	speed_coefficient = 1/T
	T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating
	size_coefficient = T


/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if( wash_state != 4 )
		to_chat(usr, "\The [src] cannot run in this state.")
		return

	if( locate(/mob,contents))
		wash_state = 8
	else
		wash_state = 5
	update_icon()
	sleep(20 SECONDS * speed_coefficient)
	for(var/atom/A in contents)
		A.clean_blood()
	for(var/obj/item/I in contents)
		I.decontaminate()

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		var/obj/item/stack/sheet/wetleather/WL = new(src)
		WL.amount = HH.amount
		WL.source_string = HH.source_string
		WL.name = HH.source_string ? "wet [HH.source_string] leather" : "wet leather"
		qdel(HH)
		HH = null

	if(crayon)
		var/color
		if(istype(crayon,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			color = CR.colourName
		else if(istype(crayon,/obj/item/weapon/stamp))
			var/obj/item/weapon/stamp/ST = crayon
			color = ST._color

		if(color)
			var/new_jumpsuit_icon_state = ""
			var/new_jumpsuit_item_state = ""
			var/new_jumpsuit_name = ""
			var/new_glove_icon_state = ""
			var/new_glove_item_state = ""
			var/new_glove_name = ""
			var/new_shoe_icon_state = ""
			var/new_shoe_name = ""
			var/new_sheet_icon_state = ""
			var/new_sheet_name = ""
			var/new_softcap_icon_state = ""
			var/new_softcap_name = ""
			var/ccoil_test = null
			var/new_desc = "The colors are a bit dodgy."
			for(var/T in typesof(/obj/item/clothing/under))
				var/obj/item/clothing/under/J = new T
				if(color == J._color)
					new_jumpsuit_icon_state = J.icon_state
					new_jumpsuit_item_state = J.item_state
					new_jumpsuit_name = J.name
					qdel(J)
					J = null
					break
				qdel(J)
				J = null
			for(var/T in typesof(/obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = new T
				if(color == G._color)
					new_glove_icon_state = G.icon_state
					new_glove_item_state = G.item_state
					new_glove_name = G.name
					qdel(G)
					G = null
					break
				qdel(G)
				G = null
			for(var/T in typesof(/obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = new T
				if(color == S._color)
					new_shoe_icon_state = S.icon_state
					new_shoe_name = S.name
					qdel(S)
					S = null
					break
				qdel(S)
				S = null
			for(var/T in typesof(/obj/item/weapon/bedsheet))
				var/obj/item/weapon/bedsheet/B = new T
				if(color == B._color)
					new_sheet_icon_state = B.icon_state
					new_sheet_name = B.name
					qdel(B)
					B = null
					break
				qdel(B)
				B = null
			for(var/T in typesof(/obj/item/clothing/head/soft))
				var/obj/item/clothing/head/soft/H = new T
				if(color == H._color)
					new_softcap_icon_state = H.icon_state
					new_softcap_name = H.name
					qdel(H)
					H = null
					break
				qdel(H)
				H = null
			for(var/T in typesof(/obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/test = new T
				if(test._color == color)
					ccoil_test = 1
					qdel(test)
					test = null
					break
				qdel(test)
				test = null
			if(new_jumpsuit_icon_state && new_jumpsuit_name)
				for(var/obj/item/clothing/under/J in contents)
					J.item_state = new_jumpsuit_item_state
					J.icon_state = new_jumpsuit_icon_state
					J._color = color
					J.name = new_jumpsuit_name
					J.desc = new_desc
			if(new_glove_icon_state && new_glove_name)
				for(var/obj/item/clothing/gloves/G in contents)
					G.item_state = new_glove_item_state
					G.icon_state = new_glove_icon_state
					G._color = color
					G.name = new_glove_name
					G.update_icon()
					if(!istype(G, /obj/item/clothing/gloves/black/thief))
						G.desc = new_desc
			if(new_shoe_icon_state && new_shoe_name)
				for(var/obj/item/clothing/shoes/S in contents)
					if (S.chained == 1)
						S.chained = 0
						S.slowdown = NO_SLOWDOWN
						new /obj/item/weapon/handcuffs( src )
					S.icon_state = new_shoe_icon_state
					S._color = color
					S.name = new_shoe_name
					S.desc = new_desc
			if(new_sheet_icon_state && new_sheet_name)
				for(var/obj/item/weapon/bedsheet/B in contents)
					B.icon_state = new_sheet_icon_state
					B._color = color
					B.name = new_sheet_name
					B.desc = new_desc
			if(new_softcap_icon_state && new_softcap_name)
				for(var/obj/item/clothing/head/soft/H in contents)
					H.icon_state = new_softcap_icon_state
					H._color = color
					H.name = new_softcap_name
					H.desc = new_desc
			if(ccoil_test)
				for(var/obj/item/stack/cable_coil/H in contents)
					H._color = color
					H.icon_state = "coil_[color]"
		qdel(crayon)
		crayon = null

	if( locate(/mob,contents))
		wash_state = 7
		gibs_ready = 1
	else
		wash_state = 4
	update_icon()

/obj/machinery/washing_machine/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && user.dexterity_check())
		start()
		return
	return ..()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(wash_state in list(1,3,6) )
		usr.forceMove(src.loc)


/obj/machinery/washing_machine/update_icon()
	icon_state = "wm_[wash_state][panel_open]"

/obj/machinery/washing_machine/attackby(obj/item/weapon/W, mob/user)
	if(..())
		update_icon()
		return 1
	else if(is_in_blacklist(W))
		to_chat(user, "This item does not fit.")
		return
	else if(istype(W,/obj/item/toy/crayon) ||istype(W,/obj/item/weapon/stamp))
		if(wash_state in list(	1, 3, 6 ))
			if(!crayon)
				if(user.drop_item(W, src))
					crayon = W
	else if(istype(W,/obj/item/weapon/grab))
		if(contents.len < (5 * size_coefficient))
			if((wash_state == 1) && hacked)
				var/obj/item/weapon/grab/G = W
				if(ishuman(G.assailant) && isliving(G.affecting) && !is_in_blacklist(G.affecting))
					G.affecting.forceMove(src)
					qdel(G)
					G = null
					wash_state = 3
		else
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
	else if(istype(W,/obj/item/weapon/holder/animal))
		if(contents.len < (5 * size_coefficient))
			if((wash_state == 1) && hacked)
				if(user.drop_item(W, src))
					wash_state = 3
					var/obj/item/weapon/holder/animal/A = locate(/obj/item/weapon/holder/animal, contents)
					contents.Add(A.stored_mob)
					qdel(locate(contents,/obj/item/weapon/holder/animal))
		else
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
	else if(is_in_whitelist(W))
		if(contents.len < (5 * size_coefficient))
			if(wash_state in list(1, 3))
				if(user.drop_item(W, src))
					wash_state = 3
			else
				to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
	update_icon()

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(..())
		return 1
	switch(wash_state)
		if(1)
			wash_state = 2
		if(2)
			wash_state = 1
			for(var/atom/movable/O in contents)
				O.forceMove(src.loc)
		if(3)
			wash_state = 4
		if(4)
			wash_state = 3
			for(var/atom/movable/O in contents)
				O.forceMove(src.loc)
			crayon = null
			wash_state = 1
		if(5)
			to_chat(user, "<span class='warning'>\The [src] is busy.</span>")
		if(6)
			wash_state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.attack_log += "\[[time_stamp()]\] was gibbed by <B>[key_name(user)]</B> via washing machine."
					user.attack_log += "\[[time_stamp()]\] gibbed <B>[key_name(M)]</B> via washing machine."
					log_attack("<B>[key_name(user)]</B> gibbed <B>[key_name(M)] via washing machine.</B>")
					M.gib()
			for(var/atom/movable/O in contents)
				O.forceMove(src.loc)
			crayon = null
			wash_state = 1
	update_icon()
