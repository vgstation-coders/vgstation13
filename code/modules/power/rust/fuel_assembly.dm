
/obj/item/fuel_assembly
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "fuel_assembly"
	name = "fuel rod assembly"
	var/list/rod_quantities
	var/percent_depleted = 1
	layer = ABOVE_OBJ_LAYER

/obj/item/fuel_assembly/New()
	. = ..()
	rod_quantities = list()

//these can be abstracted away for now
/*
/obj/item/fuel_rod
/obj/item/control_rod
*/
