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
		var/obj/item/tool/crowbar/halligan/H = I
		if(density && !pried_open) //can't cut an open door open
			if(cut_open)
				pry(user)
				return
			else
				cut(H,user)
				return
	if(istype(I,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/S = I
		if(pried_open)
			if(S.use(2))
				to_chat(user, "<span class='notice'>You begin mending the damage to the [src].</span>")
				if(do_after(user,src,3 SECONDS))
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You finish mending the damage to the [src].</span>")
					icon_state = "shutter2"
					setDensity(TRUE)
					set_opacity(1)
					pried_open = FALSE
			else
				to_chat(user, "<span class='notice'>You need at least 2 sheets to mend the damage to the [src].</span>")
	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(cut_open || pried_open)
			if(!pried_open)
				weld(WT,user)
				to_chat(user, "<span class='notice'>You finish welding the [src].</span>")
				icon_state = "shutter1"
				cut_open = FALSE
			else
				to_chat(user, "<span class='notice'>You need to add metal sheets first.</span>")

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
	if(cut_open && !pried_open)
		icon_state = "shutter2"
		setDensity(TRUE)
		set_opacity(1)
		return FALSE
	if(pried_open)
		icon_state = "shutter3"
		setDensity(FALSE)
		set_opacity(0)
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
	if(cut_open && !pried_open)
		icon_state = "shutter2"
		setDensity(TRUE)
		set_opacity(1)
		return FALSE
	if(pried_open)
		icon_state = "shutter3"
		setDensity(FALSE)
		set_opacity(0)
		return FALSE
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

/obj/machinery/door/poddoor/shutters/examine(mob/user)
	..()
	if(cut_open && !pried_open)
		to_chat(user, "<span class='info'>A hole has been cut into \the [src]. It still needs to be pried open with a Halligan bar.</span>")
		return
	else if(pried_open)
		to_chat(user, "<span class='info'>A hole has been cut into \the [src]. It can be repaired with metal and a welding tool.</span>")

/obj/machinery/door/poddoor/shutters/proc/cut(var/obj/item/tool/crowbar/halligan/T, mob/user as mob)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/breaktime = 30 SECONDS
		if(H.get_strength() >= 2)
			breaktime = 15 SECONDS
		to_chat(user, "<span class='notice'>You begin cutting through \the [src].</span>")
		if(!do_after(user, src, breaktime, 10, custom_checks = new /callback(T, /obj/item/weapon/fireaxe/proc/on_do_after)))
			return
		to_chat(user, "<span class='notice'>You finish cutting through \the [src].</span>")
		cut_open = TRUE
		icon_state = "shutter2"

/obj/machinery/door/poddoor/shutters/proc/pry(mob/user as mob)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/breaktime = 10 SECONDS
		if(H.get_strength() >= 2)
			breaktime = 5 SECONDS
		to_chat(user, "<span class='notice'>You begin prying \the [src] open.</span>")
		if(!do_after(user,src,breaktime))
			return
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You finish prying \the [src] open.</span>")
		pried_open = TRUE
		icon_state = "shutter3"
		setDensity(FALSE)
		set_opacity(0)

/obj/machinery/door/poddoor/shutters/proc/weld(var/obj/item/tool/weldingtool/WT, var/mob/user)
	if(!WT.isOn())
		return 0
	to_chat(user, "<span class='notice'>You start to weld the [src]...</span>")
	WT.playtoolsound(src, 50)
	WT.eyecheck(user)
	if(do_after(user, src, 20))
		if(!WT.isOn())
			return 0
		return 1
	return 0
