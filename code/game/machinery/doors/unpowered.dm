/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0


/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(locked)
		return

	..(AM)
	return

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	// TODO: is energy blade only attack circuity like emag?
	if (istype(I, /obj/item/weapon/card/emag))
		return

	if (locked)
		return

	..()
	return

/obj/machinery/door/unpowered/attack_hand(mob/user as mob)
	if(istype(user,/mob/dead/observer))
		return
	..()

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/obj/doors/shuttle.dmi'
	icon_state = "door_closed"
	animation_delay = 14

	explosion_block = 1

	soundeffect = 'sound/machines/airlock.ogg'
	var/pitch = 30

// copy pasted from /obj/machinery/door and added playsound() in the middle
/obj/machinery/door/unpowered/shuttle/open(var/forced=0)
	if(!density)
		return 1
	if(operating > 0)
		return
	if(!ticker)
		return 0
	if(!operating)
		operating = 1

	set_opacity(0)
	playsound(get_turf(src), soundeffect, pitch, 1)
	door_animate("opening")
	sleep(animation_delay)
	layer = open_layer
	density = 0
	explosion_resistance = 0
	update_icon()
	set_opacity(0)
	update_nearby_tiles()
	//update_freelook_sight()

	if(operating == 1)
		operating = 0

	return 1

// copy pasted from /obj/machinery/door and added playsound() in the middle
/obj/machinery/door/unpowered/shuttle/close(var/forced=0)
	if (density || operating || jammed)
		return
	operating = 1

	layer = closed_layer

	density = 1
	playsound(get_turf(src), soundeffect, pitch, 1)
	door_animate("closing")
	sleep(animation_delay)
	update_icon()

	if (!glass)
		src.set_opacity(1)

		var/obj/effect/beam/B = locate() in loc
		if(B)
			qdel(B)

	// TODO: rework how fire works on doors
	var/obj/fire/F = locate() in loc
	if(F)
		qdel(F)

	update_nearby_tiles()
	operating = 0

/obj/machinery/door/unpowered/shuttle/cultify()
	new /obj/machinery/door/mineral/wood(loc)
	..()
