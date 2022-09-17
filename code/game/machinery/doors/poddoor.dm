var/list/poddoors = list()
/obj/machinery/door/poddoor
	name = "Podlock"
	desc = "Why it no open!!!"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	layer = ABOVE_DOOR_LAYER
	open_layer = BELOW_TABLE_LAYER
	closed_layer = ABOVE_DOOR_LAYER

	explosion_block = 3
	penetration_dampening = 20

	id_tag = 1.0

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
	layer = BELOW_TABLE_LAYER

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
	layer = BELOW_TABLE_LAYER

/obj/machinery/door/poddoor/glass/admin
	name = "Explosion-proof Podlock"
	desc = "Why it no open!!!"
	explosion_block = 50
	penetration_dampening = 200

/obj/machinery/door/poddoor/glass/admin/ex_act(severity)

/obj/machinery/door/poddoor/New()
	. = ..()
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

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C, mob/user)
	add_fingerprint(user)
	if(!density)
		return
	if(istype(C, /obj/item/weapon/melee/energy/sword/ninja))
		attempt_slicing(user)
	else if(iscrowbar(C) || istype(C, /obj/item/weapon/fireaxe) && C.wielded)
		if(!operating && (stat & (NOPOWER|FORCEDISABLE)))
			spawn()
				operating = TRUE
				flick(openingicon, src)
				icon_state = openicon
				set_opacity(FALSE)
				sleep(animation_delay)
				setDensity(FALSE)
				operating = FALSE

/obj/machinery/door/poddoor/allowed(mob/M)
	return 0

/obj/machinery/door/poddoor/open()
	if(!density) //it's already open bro
		return FALSE
	if (operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	playsound(loc, 'sound/machines/poddoor.ogg', 60, 1)
	flick(openingicon, src)
	icon_state = openicon
	set_opacity(0)
	sleep(animation_delay)
	layer = open_layer
	setDensity(FALSE)
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			playsound(loc, 'sound/machines/poddoor.ogg', 60, 1)
			autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if (operating)
		return
	playsound(loc, 'sound/machines/poddoor.ogg', 60, 1)
	operating = 1
	plane = closed_plane
	layer = closed_layer
	flick(closingicon, src)
	icon_state = closedicon
	setDensity(TRUE)
	set_opacity(initial(opacity))
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

/obj/machinery/door/poddoor/filler_object
	name = ""
	icon_state = ""
