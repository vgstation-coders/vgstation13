/////////////////////////////////////////
// Machine that makes glass 'smart'
// Held within a pane of glass
// used for linking to buttons 'n shit
// made when a floor light is attached to a window
/////////////////////////////////////////

/obj/machinery/smartglass_electronics
	name = "internal smartglass electronics"
	desc = "This inside a pane of smart glass. How are you seeing this?"
	icon = null
	icon_state = null
	anchored = 0
	density = 0
	use_power = 2 //It uses power to amke the window transparent
	idle_power_usage = 0
	active_power_usage = 2
	power_channel = ENVIRON
	var/id_tag	
	
/obj/machinery/smartglass_electronics/cultify()
	return //TODO: change to cultglass
	
/obj/machinery/smartglass_electronics/New()
	..()
	machine_flags |= MULTITOOL_MENU
	
//Needs multitool menu option to toggle power (aka opaque/transparent)
//Needs multitool menu option to toggle one-way
	/*
/obj/smartglass_electronics/multitool_menu(mob/user as mob)
	return {"
		<ul>
			[format_tag("ID Tag","id_tag")]
			(<a href="?src=\ref[src];smart_toggle()">Toggle power</a>)
		</ul>"
		}
*/