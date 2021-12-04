//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	icon_state = "d_analyzer"
	var/obj/item/weapon/loaded_item = null
	var/decon_mod = 1

	research_flags = CONSOLECONTROL

/obj/machinery/r_n_d/destructive_analyzer/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/destructive_analyzer,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/Destroy()
	if(linked_console && linked_console.linked_destroy == src)
		linked_console.linked_destroy = null

	. = ..()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
		T += S.rating * 0.1
	T = clamp(T, 0, 1)
	decon_mod = T

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/r_n_d/destructive_analyzer/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(loaded_item)
		to_chat(user, "<span class='rose'>You can't open the maintenance panel while an item is loaded!</span>")
		return -1
	return ..()

/obj/machinery/r_n_d/destructive_analyzer/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(..())
		if(loaded_item)
			loaded_item.forceMove(loc)
		return TRUE
	return FALSE

/obj/machinery/r_n_d/destructive_analyzer/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(istype(AM, /obj/item) && !loaded_item && !panel_open)
		var/obj/item/I = AM
		if(!I.origin_tech)
			return FALSE
		var/list/temp_tech = ConvertReqString2List(I.origin_tech)

		if(temp_tech.len == 0)
			return FALSE

		busy = 1
		loaded_item = I
		I.forceMove(src)
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = 0
			if(linked_console)
				linked_console.updateUsrDialog()
		return TRUE
	return FALSE

/obj/machinery/r_n_d/destructive_analyzer/attackby(var/obj/O, var/mob/user)
	if(..())
		return 1
	if(istype(O, /obj/item) && !loaded_item && !panel_open)
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)

		if(temp_tech.len == 0)
			to_chat(user, "<span class='warning'>You cannot deconstruct this item!</span>")
			return

		if(isrobot(user)) //Don't put your module items in there!
			var/mob/living/silicon/robot/R = user
			if(R.is_in_modules(O))
				to_chat(user, "<span class='warning'>You cannot insert something that is part of you.</span>")
				return

		if(user.drop_item(O, src))
			busy = 1
			loaded_item = O
			to_chat(user, "<span class='notice'>You add the [O.name] to the machine!</span>")
			flick("d_analyzer_la", src)
			spawn(10)
				icon_state = "d_analyzer_l"
				busy = 0
				if(linked_console)
					linked_console.updateUsrDialog()
	return 1

/obj/machinery/r_n_d/destructive_analyzer/attack_hand(mob/user as mob)
	if (..(user))
		return
	if (loaded_item && !panel_open && !busy)
		to_chat(user, "<span class='notice'>You remove the [loaded_item.name] from the [src].</span>")
		loaded_item.forceMove(src.loc)
		loaded_item = null
		icon_state = "d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/attack_ghost(mob/user)
	return

/obj/machinery/r_n_d/destructive_analyzer/npc_tamper_act(mob/living/L)
	//Put a random nearby item inside.
	var/list/pickable_items = list()

	for(var/obj/item/I in range(1, L))
		var/list/temp_tech = ConvertReqString2List(I.origin_tech)
		if(temp_tech.len)
			pickable_items.Add(I)

	if(!pickable_items.len)
		return

	var/obj/item/I = pick(pickable_items)
	if(L.Adjacent(I))
		visible_message("<span class='danger'>\The [L] stuffs \the [I] into \the [src]!</span>")
		attackby(I, L)


/obj/machinery/r_n_d/destructive_analyzer/kick_act(mob/living/carbon/human/H)
	..()
	if(linked_console)
		linked_console.deconstruct_item(H)

//For testing purposes only.
/*/obj/item/weapon/deconstruction_test
	name = "Test Item"
	desc = "WTF?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "d20"
	g_amt = 5000
	m_amt = 5000
	origin_tech = Tc_MATERIALS + "=5;" + Tc_PLASMATECH + "=5;" + Tc_SYNDICATE + "=5;" + Tc_PROGRAMMING + "=9"*/
