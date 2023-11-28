/obj/machinery/computer/ship_controls
	name = "Ship Controls"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/ship_controls/attack_hand(var/mob/user)
	if(map.has_engines)
		if (!ship_has_power)
			return FALSE
	dodge = TRUE
	return
