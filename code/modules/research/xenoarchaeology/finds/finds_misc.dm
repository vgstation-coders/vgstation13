
//legacy crystal
/obj/machinery/crystal
	name = "Crystal"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crystal"
	var/randomize = TRUE

/obj/machinery/crystal/New()
	..()
	if(randomize)
		icon_state = "crystal[pick("","2")]"
