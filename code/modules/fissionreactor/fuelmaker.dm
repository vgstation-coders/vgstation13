/*
in this file:
the machine which makes fuel rods have things in them.
*/

//because radon is a gas, we need to interface with gasses. yeah, this kind of sucks, but what are you gonna do? (inb4 make better code lol)
/obj/machinery/atmospherics/unary/fissionfuelmaker
	name="isotopic separational combiner." //just about the most technobable you could get.
	var/datum/reagents/held_elements=new /datum/reagents
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 200
	active_power_usage = 1000
	icon='icons/obj/fissionreactor/fuelmaker.dmi'
	icon_state="fuelmaker"
	var/obj/item/weapon/fuelrod/heldrod = null
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/update_icon()
	..()
	if(!powered())
		icon_state="fuelmaker_off[heldrod?"_insert":""]"
		return
	if(stat & BROKEN)
		icon_state="fuelmaker_broken[heldrod?"_insert":""]"
		return
	icon_state="fuelmaker[heldrod?"_insert":""]"
	
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/examine()
	..()
	if(heldrod)
		to_chat(usr,"There is a fuel rod inserted into it.")
	else
		to_chat(usr,"The fuel rod receptacle is empty.")