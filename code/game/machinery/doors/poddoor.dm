var/list/poddoors = list()
/obj/machinery/door/poddoor
	name = "Podlock"
	desc = "Why it no open!!!"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	layer = BELOW_TABLE_LAYER
	open_layer = BELOW_TABLE_LAYER
	closed_layer = ABOVE_DOOR_LAYER
	explosion_resistance = 25//used by the old deprecated explosion_recursive.dm

	explosion_block = 3
	penetration_dampening = 20

	var/id_tag = 1.0

	prefix = "r_"
	animation_delay = 5

	var/closedicon = "pdoor1"
	var/openicon = "pdoor0"
	var/closingicon = "pdoorc1"
	var/openingicon = "pdoorc0"

/obj/machinery/door/poddoor/preopen
	icon_state = "pdoor0"
	density = 0
	opacity = 0

/obj/machinery/door/poddoor/glass
	icon_state = "gpdoor1"
	closedicon = "gpdoor1"
	openicon = "gpdoor0"
	closingicon = "gpdoorc1"
	openingicon = "gpdoorc0"
	opacity = 0

/obj/machinery/door/poddoor/glass/preopen
	icon_state = "gpdoor0"
	density = 0

/obj/machinery/door/poddoor/glass/admin
	name = "Explosion-proof Podlock"
	desc = "Why it no open!!!"
	explosion_block = 50
	penetration_dampening = 200

/obj/machinery/door/poddoor/glass/admin/ex_act(severity)

/obj/machinery/door/poddoor/New()
	. = ..()
	if(density)
		layer = closed_layer
	else
		layer = open_layer
	poddoors += src


/obj/machinery/door/poddoor/Destroy()
	poddoors -= src
	..()

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

/obj/machinery/door/poddoor/hitby(atom/movable/AM)
	if(!density)
		return ..()
	else
		denied()
		return FALSE

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (!( iscrowbar(C) || (istype(C, /obj/item/weapon/fireaxe) && C.wielded == 1) ))
		return
	if ((density && (stat & NOPOWER) && !( operating )))
		spawn( 0 )
			src.operating = 1
			flick(openingicon, src)
			src.icon_state = openicon
			src.set_opacity(0)
			sleep(animation_delay)
			setDensity(FALSE)
			src.operating = 0
			return
	return

/obj/machinery/door/poddoor/allowed(mob/M)
	return 0

/obj/machinery/door/poddoor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	playsound(loc, 'sound/machines/poddoor.ogg', 60, 1)
	flick(openingicon, src)
	src.icon_state = openicon
	src.set_opacity(0)
	sleep(animation_delay)
	layer = open_layer
	setDensity(FALSE)
	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			playsound(loc, 'sound/machines/poddoor.ogg', 60, 1)
			autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if (src.operating)
		return
	playsound(loc, 'sound/machines/poddoor.ogg', 60, 1)
	src.operating = 1
	layer = closed_layer
	flick(closingicon, src)
	src.icon_state = closedicon
	src.setDensity(TRUE)
	src.set_opacity(initial(opacity))
	update_nearby_tiles()

	sleep(animation_delay)
	src.operating = 0
	return

/obj/machinery/door/poddoor/ex_act(severity)//Wouldn't it make sense for "Blast Doors" to actually handle explosions better than other doors?
	switch(severity)
		if(1.0)
			if(prob(80))
				qdel(src)
			else
				spark(src, 2)
		if(2.0)
			if(prob(20))
				qdel(src)
			else
				spark(src, 2)
		if(3.0)
			if(prob(80))
				spark(src, 2)
	return

/obj/machinery/door/poddoor/admin
	name = "Explosion-proof Podlock"
	desc = "Why it no open!!!"
	explosion_block = 50
	penetration_dampening = 200

/obj/machinery/door/poddoor/admin/ex_act(severity)

/*
/obj/machinery/door/poddoor/two_tile_hor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	src.SetOpacity(0)
	f1.SetOpacity(0)
	f2.SetOpacity(0)

	sleep(10)
	setDensity(FALSE)
	f1.setDensity(FALSE)
	f2.setDensity(FALSE)

	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/two_tile_hor/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"

	src.setDensity(TRUE)
	f1.setDensity(TRUE)
	f2.setDensity(TRUE)

	sleep(10)
	src.SetOpacity(initial(opacity))
	f1.SetOpacity(initial(opacity))
	f2.SetOpacity(initial(opacity))

	update_nearby_tiles()

	src.operating = 0
	return

/obj/machinery/door/poddoor/four_tile_hor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	setDensity(FALSE)
	src.sd_SetOpacity(0)

	f1.setDensity(FALSE)
	f1.sd_SetOpacity(0)
	f2.setDensity(FALSE)
	f2.sd_SetOpacity(0)
	f3.setDensity(FALSE)
	f3.sd_SetOpacity(0)
	f4.setDensity(FALSE)
	f4.sd_SetOpacity(0)

	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/four_tile_hor/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.setDensity(TRUE)

	f1.setDensity(TRUE)
	f1.sd_SetOpacity(1)
	f2.setDensity(TRUE)
	f2.sd_SetOpacity(1)
	f3.setDensity(TRUE)
	f3.sd_SetOpacity(1)
	f4.setDensity(TRUE)
	f4.sd_SetOpacity(1)

	if (src.visible)
		src.sd_SetOpacity(1)
	update_nearby_tiles()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/two_tile_ver/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.setDensity(FALSE)
	src.sd_SetOpacity(0)

	f1.setDensity(FALSE)
	f1.sd_SetOpacity(0)
	f2.setDensity(FALSE)
	f2.sd_SetOpacity(0)

	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/two_tile_ver/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.setDensity(TRUE)

	f1.setDensity(TRUE)
	f1.sd_SetOpacity(1)
	f2.setDensity(TRUE)
	f2.sd_SetOpacity(1)

	if (src.visible)
		src.sd_SetOpacity(1)
	update_nearby_tiles()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/four_tile_ver/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	setDensity(FALSE)
	src.sd_SetOpacity(0)

	f1.setDensity(FALSE)
	f1.sd_SetOpacity(0)
	f2.setDensity(FALSE)
	f2.sd_SetOpacity(0)
	f3.setDensity(FALSE)
	f3.sd_SetOpacity(0)
	f4.setDensity(FALSE)
	f4.sd_SetOpacity(0)

	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/four_tile_ver/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.setDensity(TRUE)

	f1.setDensity(TRUE)
	f1.sd_SetOpacity(1)
	f2.setDensity(TRUE)
	f2.sd_SetOpacity(1)
	f3.setDensity(TRUE)
	f3.sd_SetOpacity(1)
	f4.setDensity(TRUE)
	f4.sd_SetOpacity(1)

	if (src.visible)
		src.sd_SetOpacity(1)
	update_nearby_tiles()

	sleep(10)
	src.operating = 0
	return




/obj/machinery/door/poddoor/two_tile_hor
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	icon = 'icons/obj/doors/1x2blast_hor.dmi'

/obj/machinery/door/poddoor/two_tile_hor/New()
	..()
	f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
	f2 = new/obj/machinery/door/poddoor/filler_object (get_step(src,EAST))
	f1.setDensity(density)
	f2.setDensity(density)
	f1.sd_SetOpacity(opacity)
	f2.sd_SetOpacity(opacity)

/obj/machinery/door/poddoor/two_tile_hor/Destroy()
	del f1
	del f2
	..()

/obj/machinery/door/poddoor/two_tile_ver
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	icon = 'icons/obj/doors/1x2blast_vert.dmi'

/obj/machinery/door/poddoor/two_tile_ver/New()
	..()
	f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
	f2 = new/obj/machinery/door/poddoor/filler_object (get_step(src,NORTH))
	f1.setDensity(density)
	f2.setDensity(density)
	f1.sd_SetOpacity(opacity)
	f2.sd_SetOpacity(opacity)

/obj/machinery/door/poddoor/two_tile_ver/Destroy()
	del f1
	del f2
	..()

/obj/machinery/door/poddoor/four_tile_hor
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	var/obj/machinery/door/poddoor/filler_object/f3
	var/obj/machinery/door/poddoor/filler_object/f4
	icon = 'icons/obj/doors/1x4blast_hor.dmi'

/obj/machinery/door/poddoor/four_tile_hor/New()
	..()
	f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
	f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,EAST))
	f3 = new/obj/machinery/door/poddoor/filler_object (get_step(f2,EAST))
	f4 = new/obj/machinery/door/poddoor/filler_object (get_step(f3,EAST))
	f1.setDensity(density)
	f2.setDensity(density)
	f3.setDensity(density)
	f4.setDensity(density)
	f1.sd_SetOpacity(opacity)
	f2.sd_SetOpacity(opacity)
	f4.sd_SetOpacity(opacity)
	f3.sd_SetOpacity(opacity)

/obj/machinery/door/poddoor/four_tile_hor/Destroy()
	del f1
	del f2
	del f3
	del f4
	..()

/obj/machinery/door/poddoor/four_tile_ver
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	var/obj/machinery/door/poddoor/filler_object/f3
	var/obj/machinery/door/poddoor/filler_object/f4
	icon = 'icons/obj/doors/1x4blast_vert.dmi'

/obj/machinery/door/poddoor/four_tile_ver/New()
	..()
	f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
	f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,NORTH))
	f3 = new/obj/machinery/door/poddoor/filler_object (get_step(f2,NORTH))
	f4 = new/obj/machinery/door/poddoor/filler_object (get_step(f3,NORTH))
	f1.setDensity(density)
	f2.setDensity(density)
	f3.setDensity(density)
	f4.setDensity(density)
	f1.sd_SetOpacity(opacity)
	f2.sd_SetOpacity(opacity)
	f4.sd_SetOpacity(opacity)
	f3.sd_SetOpacity(opacity)

/obj/machinery/door/poddoor/four_tile_ver/Destroy()
	del f1
	del f2
	del f3
	del f4
	..()
*/
/obj/machinery/door/poddoor/filler_object
	name = ""
	icon_state = ""