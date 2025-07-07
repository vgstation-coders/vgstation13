
/obj/item/weapon/fuel_assembly
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "fuel_assembly"
	name = "fuel rod assembly"
	desc = "A bundle of R-UST fuel rods compressed together into a portable assembly. Inert outside of a fuel injector."
	var/list/rod_current_quantities
	var/list/rod_starting_quantities
	var/percent_depleted = 1
	layer = ABOVE_OBJ_LAYER

/obj/item/weapon/fuel_assembly/New()
	. = ..()
	rod_current_quantities = list()
	rod_starting_quantities = list()

/obj/item/weapon/fuel_assembly/examine(var/mob/user)
	..()
	var/out = list()
	out += "This assembly"
	if(percent_depleted == 1)
		out += " is completely spent."
	else
		out += " has [100 - floor(percent_depleted * 100)]% of its fuel remaining."
	to_chat(user, jointext(out, ""))
	if(rod_starting_quantities.len == 0) return
	out = list()
	out += "Its original contents are stamped into the side:<br>"
	for(var/k, v in rod_starting_quantities)
		out += "[k]: [v]<br>"
	var/completetext = jointext(out, "")
	to_chat(user, completetext)



//these can be abstracted away for now
/*
/obj/item/weapon/fuel_rod
/obj/item/weapon/control_rod
*/
