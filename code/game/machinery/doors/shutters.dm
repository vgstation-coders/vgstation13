/obj/machinery/door/poddoor/shutters
	name = "Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"
	power_channel = ENVIRON
	var/sound_open = 'sound/machines/shutter_open.ogg'
	var/sound_close = 'sound/machines/shutter_close.ogg'
	animation_delay = 7
	var/cut_open = FALSE
	var/pried_open = FALSE

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "shutter0"
	density = 0
	opacity = 0
	layer = BELOW_TABLE_LAYER

/obj/machinery/door/poddoor/shutters/attackby(var/obj/item/I, var/mob/user)
	add_fingerprint(user)
	if(istype(I,/obj/item/tool/crowbar/halligan))
		if(!density) //can't cut an open door open, dumbass
			if(cut_open)
				if(!pried_open)
					pry(user)
					return
			else
				if(!pried_open)
					cut(user)
					return
	if(iswelder(I))
		if(cut_open || pried_open)
			if(pried_open)
				to_chat(user, "<span class='notice'>You bend \the [src] back into place and weld it shut.</span>")
			else
				to_chat(user, "<span class='notice'>You weld \the [src] shut.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			close()
			cut_open = FALSE
			pried_open = FALSE

	if(istype(I,/obj/item/weapon))
		var/obj/item/weapon/C = I
		if(!(iscrowbar(C) || (istype(C, /obj/item/weapon/fireaxe) && C.wielded == 1) ))
			return
		if(density && (stat & (FORCEDISABLE|NOPOWER)) && !operating)
			operating = 1
			spawn(-1)
				flick("shutterc0", src)
				icon_state = "shutter0"
				sleep(animation_delay)
				plane = open_plane
				layer = open_layer
				setDensity(FALSE)
				set_opacity(0)
				operating = 0

/obj/machinery/door/poddoor/shutters/open()
	if(cut_open || pried_open) //it broke
		return FALSE
	if(!density) //it's already open bro
		return FALSE
	if(operating == 1) //doors can still open when emag-disabled
		return
	if(!ticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	flick("shutterc0", src)
	icon_state = "shutter0"
	playsound(src.loc, sound_open, 100, 1)
	sleep(animation_delay)
	plane = open_plane
	layer = open_layer
	setDensity(FALSE)
	set_opacity(0)
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			autoclose()		//TODO: note to self: look into this ~Carn
	return 1

/obj/machinery/door/poddoor/shutters/close()
	if(operating)
		return
	operating = 1
	plane = closed_plane
	layer = closed_layer
	icon_state = "shutter1"
	if(!cut_open && !pried_open)
		flick("shutterc1", src)
		playsound(src.loc, sound_close, 100, 1)
	density = 1
	if(visible)
		set_opacity(1)
	update_nearby_tiles()

	sleep(animation_delay)
	operating = 0

/obj/machinery/door/poddoor/shutters/examine()
	..()
	if(cut_open)
		to_chat(user, "<span class='info'>A hole has been cut into \the [src]. It still needs to be pried open with a Halligan bar.</span>")
		return
	else if(pried_open)
		to_chat(user, "<span class='info'>A hole has been cut into \the [src]. It can be repaired with a welding tool.</span>")

/obj/machinery/door/poddoor/shutters/update_icon()
	if(cut_open)
		icon_state = "shutter2"
		return
	else if(pried_open)
		icon_state = "shutter3"
//		plane = open_plane DEBUG
//		layer = open_layer DEBUG
		setDensity(FALSE)
		set_opacity(0)
		return
	..()

/obj/machinery/door/poddoor/shutters/proc/cut(mob/user as mob)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/breaktime = 30 SECONDS
		if(H.get_strength() >= 2)
			breaktime = 15 SECONDS
		to_chat(user, "<span class='notice'>You begin cutting through \the [src].</span>")
		if(!do_after(user, src, breaktime, 10, custom_checks = new /callback(I, /obj/item/weapon/fireaxe/proc/on_do_after)))
			return
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You finish cutting through \the [src].</span>")
		cut = TRUE
		update_icon()

/obj/machinery/door/poddoor/shutters/proc/pry(mob/user as mob)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/breaktime = 10 SECONDS
		if(H.get_strength() >= 2)
			breaktime = 5 SECONDS
		to_chat(user, "<span class='notice'>You begin prying \the [src] open.</span>")
		if(!do_after(breaktime))
			return
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You finish prying \the [src] open.</span>")
		pried = TRUE
		update_icon()
