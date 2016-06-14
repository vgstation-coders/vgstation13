/obj/machinery/door/poddoor/glass
	name = "shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor_glass_closed"
	var/sound_open = 'sound/machines/shutter_open.ogg'
	var/sound_close = 'sound/machines/shutter_close.ogg'
	opacity = 0

/obj/machinery/door/poddoor/glass/New()
	..()
	layer = 3.1

/obj/machinery/door/poddoor/glass/preopen
	icon_state = "pdoor_glass_opened"
	density = 0

/obj/machinery/door/poddoor/glass/attackby(obj/item/weapon/C as obj, mob/user as mob)
	add_fingerprint(user)
	if(!(iscrowbar(C) || (istype(C, /obj/item/weapon/fireaxe) && C.wielded == 1) ))
		return
	if(density && (stat & NOPOWER) && !operating)
		operating = 1
		spawn(-1)
			flick("pdoor_glass_open", src)
			icon_state = "pdoor_glass_opened"
			sleep(15)
			density = 0
			operating = 0
			return
	return

/obj/machinery/door/poddoor/glass/open()
	if(operating == 1) //doors can still open when emag-disabled
		return
	if(!ticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	flick("pdoor_glass_open", src)
	icon_state = "pdoor_glass_opened"
	playsound(loc, sound_open, 100, 1)
	sleep(10)
	density = 0
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			autoclose()		//TODO: note to self: look into this ~Carn
	return 1

/obj/machinery/door/poddoor/glass/close()
	if(operating)
	//if(welded) //these are not airlocks.
		return
	operating = 1
	flick("pdoor_glass_close", src)
	icon_state = "pdoor_glass_closed"
	playsound(loc, sound_close, 100, 1)
	density = 1
	update_nearby_tiles()

	sleep(10)
	operating = 0
