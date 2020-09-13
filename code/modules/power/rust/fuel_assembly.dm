
/obj/item/weapon/fuel_assembly
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "fuel_assembly"
	name = "fuel rod assembly"
	var/list/rod_quantities
	var/percent_depleted = 1
	layer = ABOVE_OBJ_LAYER

/obj/item/weapon/fuel_assembly/New()
	. = ..()
	rod_quantities = list()

//these can be abstracted away for now
/*
/obj/item/weapon/fuel_rod
/obj/item/weapon/control_rod
*/
