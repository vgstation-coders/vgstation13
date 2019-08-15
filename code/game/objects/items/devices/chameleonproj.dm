/obj/item/device/chameleon
	name = "chameleon-projector"
	desc = "A device that can scan an object's appearance and cloak a user."
	icon_state = "shield0"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	origin_tech = Tc_SYNDICATE + "=4;" + Tc_MAGNETS + "=4"
	var/cham_proj_scan = 1 //Scanning function starts on
	var/can_use = 1
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_item = /obj/item/trash/cigbutt
	var/saved_icon = 'icons/obj/clothing/masks.dmi'
	var/saved_icon_state = "cigbutt"
	var/saved_overlays

/obj/item/device/chameleon/dropped()
	spawn() //So the chammy project is dropped into the dummy before the dummy empties itself out
		disrupt()

/obj/item/device/chameleon/equipped()
	disrupt()

/obj/item/device/chameleon/attack_self()
	toggle()

/obj/item/device/chameleon/verb/toggle_scaning()
	set name = "Toggle Chameleon Projector Scanning"
	set category = "Object"

	if(usr.isUnconscious())
		return

	cham_proj_scan = !cham_proj_scan
	to_chat(usr, "You [cham_proj_scan ? "activate":"deactivate"] [src]'s scanning function")

/obj/item/device/chameleon/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!cham_proj_scan) //Is scanning disabled ?
		return
	if(!active_dummy)
		if(istype(target, /obj/item) && !istype(target, /obj/item/weapon/disk/nuclear) || istype(target, /mob))
			playsound(src, 'sound/weapons/flash.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			saved_item = target.type
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_overlays = target.overlays.Copy()
			return 1

/obj/item/device/chameleon/proc/toggle()
	if(!can_use || !saved_item)
		return
	if(active_dummy)
		eject_all()
		//playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
		qdel(active_dummy)
		active_dummy = null
		to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
		can_use = 0
		spawn(20) //Stop spamming this shit
			can_use = 1
	else
		//playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/O = new saved_item(src)
		if(!O)
			return
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(O, usr, saved_icon, saved_icon_state, saved_overlays, src)
		qdel(O)
		O = null
		to_chat(usr, "<span class='notice'>You activate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
		can_use = 0
		spawn(20) //Stop spamming this shit
			can_use = 1

/obj/item/device/chameleon/proc/disrupt(var/delete_dummy = 1)
	if(active_dummy)
		spark(src, 5)
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = 0
		spawn(50)
			can_use = 1

/obj/item/device/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.forceMove(active_dummy.loc)
		if(isliving(A))
			var/mob/M = A
			M.reset_view(null)
			M.layer = MOB_LAYER //Reset the mob's layer
			M.plane = MOB_PLANE

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = 0
	anchored = 0
	var/can_move = 1
	var/obj/item/device/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(var/obj/O, var/mob/M, new_icon, new_iconstate, new_overlays, var/obj/item/device/chameleon/C)
	name = O.name
	desc = O.desc
	icon = new_icon
	icon_state = new_iconstate
	overlays = new_overlays
	dir = O.dir
	M.forceMove(src)
	M.layer = OBJ_LAYER //Needed for some things, notably lockers
	M.plane = OBJ_PLANE
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/proc/disrupt()
	for(var/mob/M in src)
		to_chat(M, "<span class='warning'>Your chameleon-projector deactivates.</span>")
	master.disrupt()


/obj/effect/dummy/chameleon/attackby()
	disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	disrupt()

/obj/effect/dummy/chameleon/ex_act(severity)
	for(var/mob/M in src)
		M.ex_act(severity)
	disrupt()

/obj/effect/dummy/chameleon/emp_act(severity)
	for(var/mob/M in src)
		M.emp_act(severity)
	disrupt()

/obj/effect/dummy/chameleon/blob_act()
	..()
	disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	disrupt()

/obj/effect/dummy/chameleon/relaymove(var/mob/user, direction)
	if(istype(loc, /turf/space))
		return //No magical space movement!

	if(can_move)
		can_move = 0
		switch(user.bodytemperature)
			if(300 to INFINITY)
				spawn(8)
					can_move = 1
			if(295 to 300)
				spawn(11)
					can_move = 1
			if(280 to 295)
				spawn(14)
					can_move = 1
			if(260 to 280)
				spawn(18)
					can_move = 1
			else
				spawn(23)
					can_move = 1
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	..()
