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
	use_power = 0 //Apparently we use power_connection for this
	idle_power_usage = 0
	active_power_usage = 50
	power_channel = ENVIRON
	machine_flags = MULTITOOL_MENU
	
	//Smartglass vars
	var/smart_power = 0
	var/obj/structure/window/GLASS //Ref to the window we're in
	
	//Radio vars
	var/id_tag	
	var/frequency = 1449
	var/datum/radio_frequency/radio_connection
	
	//power vars
	var/datum/power_connection/consumer/electromagic = null
	
	
/obj/machinery/smartglass_electronics/cultify()
	qdel(src)
	return
	
/obj/machinery/smartglass_electronics/New()
	..()
	GLASS = loc
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	electromagic=new(GLASS,GLASS)
	electromagic.idle_usage=idle_power_usage
	electromagic.active_usage=active_power_usage
	electromagic.power_changed.Add(src,"power_change")
	electromagic.use = 2
	electromagic.set_enabled()

/obj/machinery/smartglass_electronics/Destroy()
	radio_controller.remove_object(src, frequency)
	qdel(radio_connection)
	radio_connection = null
	if(electromagic)
		qdel(electromagic)
		electromagic = null
	..()
	
/**********************
// POWER SHIT
**********************/
	
/obj/machinery/smartglass_electronics/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)	
	//should add randomized window states here	
	
/obj/machinery/smartglass_electronics/power_change()
	if(stat & (NOPOWER | BROKEN))
		if (smart_power)
			smart_power = 0
			GLASS.smart_toggle()

/**********************
// SMARTGLASS PROCS
**********************/
			
/obj/machinery/smartglass_electronics/proc/toggle_smart_power()
	if (smart_power)
		smart_power = 0
	else
		smart_power = 1
	GLASS.smart_toggle()
	return smart_power


/**********************
// MULTITOOL SHIT
**********************/

/obj/machinery/smartglass_electronics/multitool_menu(var/mob/user)
	return {"
		<ul>
			<li>[format_tag("ID Tag", "id_tag","set_id")]</a></li>
			<li><a href='?src=\ref[src];transparentoggle=1'>Toggle Transparency</a></li>
		</ul>
		"}	
		
// Overwrite standard behavior else it'll never work
/obj/machinery/smartglass_electronics/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span class='warning'>WARNING: Device is not powered.</span>")
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
	
	return ..()
	
/obj/machinery/smartglass_electronics/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return

	switch(signal.data["command"])
		
		if("toggle_transparency")
			toggle_smart_power()

			