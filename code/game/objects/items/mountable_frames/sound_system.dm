/obj/item/mounted/frame/soundsystem
	name = "sound system frame"
	desc = "Used for repairing or building sound systems."
	icon = 'icons/obj/radio.dmi'
	icon_state = "wallradio"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")
	resulttype = /obj/machinery/media/receiver/boombox/wallmount
	building = FALSE