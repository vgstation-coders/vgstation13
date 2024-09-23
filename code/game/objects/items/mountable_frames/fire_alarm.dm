/obj/item/mounted/frame/firealarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	flags = FPRINT
	starting_materials = list(MAT_IRON = 2*CC_PER_SHEET_METAL)
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL
	mount_reqs = list("simfloor", "nospace")
	resulttype = /obj/machinery/firealarm/empty