/////////////////////////////////////////
// Machine that makes glass 'smart'
// Held within a pane of glass
// used for linking to buttons 'n shit
// made when a floor light is attached to a window
/////////////////////////////////////////

/obj/machinery/smartglass_electronics
	name = "smartglass electronics"
	desc = "This should be inside a pane of smart glass. How are you seeing this?"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"
	anchored = 0
	density = 0
	use_power = 2
	idle_power_usage = 0
	active_power_usage = 5
	power_channel = ENVIRON
	machine_flags = MULTITOOL_MENU
	
	//Smartglass vars
	var/smart_power = 0
	var/one_way_power = 0
	var/obj/structure/window/GLASS //Ref to the window we're in
	
	//Radio vars
	var/id_tag	
	var/frequency = 1449
	var/datum/radio_frequency/radio_connection
	
/obj/machinery/smartglass_electronics/cultify()
	qdel(src)
	return
	
/obj/machinery/smartglass_electronics/New()
	..()
	GLASS = loc
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	
//Multitool menu needs to communicate with the glass the electronics are inside

/obj/machinery/smartglass_electronics/multitool_menu(var/mob/user)
	return {"
		<ul>
			<li>[format_tag("ID Tag", "id_tag","set_id")]</a></li>
			<li><a href='?src=\ref[src];transparentoggle=1'>Toggle Transparency</a></li>
			<li><a href='?src=\ref[src];onewaytoggle=1'>Toggle One-way mode</a></li>
		</ul>
		"}	

/obj/machinery/smartglass_electronics/proc/toggle_smart_power()
	if(stat & (NOPOWER | BROKEN))
		power_change()
	if (smart_power)
		smart_power = 0
		if (active_power_usage > 5)
			active_power_usage -= 5
		if (!one_way_power)
			use_power = 0
	else
		smart_power = 1
		active_power_usage += 5
		use_power = 2
	GLASS.smart_toggle()
	return smart_power

/obj/machinery/smartglass_electronics/proc/toggle_oneway_power()
	if(stat & (NOPOWER | BROKEN))
		power_change()
	if(!GLASS.one_way && !GLASS.one_way_smart)
		return
	if (one_way_power)
		one_way_power = 0
		if (active_power_usage > 5)
			active_power_usage -= 5
		if (!smart_power)
			use_power = 0
	else
		one_way_power = 1
		active_power_usage += 5
		use_power = 2
	GLASS.oneway_toggle()
	return one_way_power


/obj/machinery/smartglass_electronics/power_change()
	if(stat & (NOPOWER | BROKEN))
		if (smart_power)
			smart_power = 0
			GLASS.smart_toggle()
		if (one_way_power)
			one_way_power = 0
			GLASS.oneway_toggle()
		if (use_power)
			use_power = 0
		if (active_power_usage > 5)
			active_power_usage = 5
		
// This is here to allow access to the electronics.
/obj/machinery/smartglass_electronics/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(href_list["close"])
		return
	var/ghost_flags=0
	if(ghost_write)
		ghost_flags |= PERMIT_ALL
	if(!canGhostWrite(usr,src,"",ghost_flags))
		if(usr.restrained() || usr.lying || usr.stat)
			return 1
		if ((!in_range(GLASS, usr) || !istype(GLASS.loc, /turf)) && !istype(usr, /mob/living/silicon))
			to_chat(usr, "<span class='warning'>WARNING: Connection failure. Reduce range.</span>")
			return 1
	else if(!custom_aghost_alerts)
		log_adminghost("[key_name(usr)] screwed with [src] ([href])!")

	return handle_multitool_topic(href,href_list,usr)
		
		
/*************************************
// RADIO SHIT
*************************************/
		
/obj/machinery/smartglass_electronics/multitool_topic(var/mob/user, var/list/href_list, var/obj/structure/window/GLASS)
	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id_tag) as null|text), 1, MAX_MESSAGE_LEN)
		if(newid)
			id_tag = newid
			initialize()
		return MT_UPDATE
	
	if("transparentoggle" in href_list)
		toggle_smart_power()
		return MT_UPDATE	
	
	if("onewaytoggle" in href_list)
		toggle_oneway_power()
		return MT_UPDATE
	
	return ..()
	
/obj/machinery/smartglass_electronics/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return

	switch(signal.data["command"])
		
		if("toggle_transparency")
			toggle_smart_power()
			
		if("toggle_oneway")
			toggle_oneway_power()
			
			
/obj/machinery/smartglass_electronics/Destroy()
	..()
	radio_controller.remove_object(src, frequency)
	qdel(radio_connection)
	radio_connection = null