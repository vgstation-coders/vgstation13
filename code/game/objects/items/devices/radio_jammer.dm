var/global/list/radio_jammers = list()

/obj/item/device/radio_jammer
	name = "universal recorder"
	desc = "A device that will jam the output from nearby radios."
	icon_state = "taperecorderidle"
	item_state = "analyzer"
	starting_materials = list(MAT_IRON = 100)
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_SYNDICATE + "=5"
	var/jam_radius = 7 //lets make this a var so there can be some interesting things

/obj/item/device/radio_jammer/New()
	. = ..()
	radio_jammers += src

/obj/item/device/radio_jammer/Destroy()
	radio_jammers -= src
	. = ..()

