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
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/id_tag	
	machine_flags = MULTITOOL_MENU
	var/smart_power = 0
	var/one_way_power = 0
	var/obj/structure/window/GLASS
	
/obj/machinery/smartglass_electronics/cultify()
	qdel(src)
	return
	
/obj/machinery/smartglass_electronics/New()
	..()
	
//Multitool menu needs to communicate with the glass the electronics are inside

/obj/machinery/smartglass_electronics/multitool_menu(var/mob/user)
	return {"
		<ul>
			<li>[format_tag("ID Tag", "id_tag","set_id")]</a></li>
			<li><a href="?src=\ref[src];toggle_smart_power()">Toggle Transparency</a></li>
			<li><a href="?src=\ref[src];toggle_oneway_power()">Toggle One-way mode</a></li>
		</ul>
		"}

/*	
//			[format_tag("ID Tag","id_tag")]
			
			<li>[format_tag("Transparency", "smart_power","toggle_smart_power")]</a></li></br>
			<li>[format_tag("One-way", "one_way_power","toggle_oneway_power")]</a></li></br>
*/			

/obj/machinery/smartglass_electronics/proc/toggle_smart_power()
	if (smart_power)
		smart_power = 0
		active_power_usage -= 5
		if (!one_way_power)
			use_power = 0
		else
			smart_power = 1
			active_power_usage += 5
			use_power = 2
		GLASS.smart_toggle()

/obj/machinery/smartglass_electronics/proc/toggle_oneway_power()
	if (one_way_power)
		one_way_power = 0
		active_power_usage -= 5
		if (!smart_power)
			use_power = 0
		else
			one_way_power = 1
			active_power_usage += 5
			use_power = 2
		GLASS.oneway_toggle()


/obj/machinery/smartglass_electronics/multitool_topic(var/mob/user, var/list/href_list, var/obj/structure/window/GLASS)
	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id_tag) as null|text), 1, MAX_MESSAGE_LEN)
		if(newid)
			id_tag = newid
			initialize()
		return MT_UPDATE

	return ..()