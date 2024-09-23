/obj/item/mounted/frame/light_switch
	name = "light switch frame"
	desc = "Wire it up to a wall to create new light switches."
	icon = 'icons/obj/power.dmi'
	icon_state = "light-p"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")
	resulttype = /obj/machinery/light_switch
	building = FALSE