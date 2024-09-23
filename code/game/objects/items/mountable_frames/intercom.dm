/obj/item/mounted/frame/intercom
	name = "Intercom frame"
	desc = "Used for repairing or building intercoms."
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom-frame"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")
	resulttype = /obj/item/device/radio/intercom
	building = FALSE