/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags_1 = CONDUCT_1 | NOBLUDGEON_1
	slot_flags = SLOT_BELT
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/can_use = 1
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_appearance = null

/obj/item/device/chameleon/New()
	..()
	var/obj/item/cigbutt/butt = /obj/item/cigbutt
	saved_appearance = initial(butt.appearance)

/obj/item/device/chameleon/dropped()
	..()
	disrupt()

/obj/item/device/chameleon/equipped()
	..()
	disrupt()

/obj/item/device/chameleon/attack_self(mob/user)
	if (isturf(user.loc) || istype(user.loc, /obj/structure) || active_dummy)
		toggle(user)
	else
		to_chat(user, "<span class='userwarning'>You can't use [src] while inside something.</span>")

/obj/item/device/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!check_sprite(target))
		return
	if(!active_dummy)
		if(isitem(target) && !istype(target, /obj/item/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			var/obj/temp = new/obj()
			temp.appearance = target.appearance
			temp.layer = initial(target.layer) // scanning things in your inventory
			temp.plane = initial(target.plane)
			saved_appearance = temp.appearance

/obj/item/device/chameleon/proc/check_sprite(atom/target)
	if(target.icon_state in icon_states(target.icon))
		return TRUE
	return FALSE

/obj/item/device/chameleon/proc/toggle(mob/user)
	if(!can_use || !saved_appearance)
		return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		qdel(active_dummy)
		active_dummy = null
		to_chat(user, "<span class='notice'>You deactivate \the [src].</span>")
		new /obj/effect/temp_visual/emp/pulse(get_turf(src))
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(get_turf(user))
		C.activate(user, saved_appearance, src)
		to_chat(user, "<span class='notice'>You activate \the [src].</span>")
		new /obj/effect/temp_visual/emp/pulse(get_turf(src))
	user.cancel_camera()

/obj/item/device/chameleon/proc/disrupt(delete_dummy = 1)
	if(active_dummy)
		for(var/mob/M in active_dummy)
			to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = 0
		spawn(50) can_use = 1

/obj/item/device/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.forceMove(active_dummy.loc)
		if(ismob(A))
			var/mob/M = A
			M.reset_perspective(null)

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = FALSE
	var/can_move = 0
	var/obj/item/device/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(mob/M, saved_appearance, obj/item/device/chameleon/C)
	appearance = saved_appearance
	if(istype(M.buckled, /obj/vehicle))
		var/obj/vehicle/V = M.buckled
		GET_COMPONENT_FROM(VRD, /datum/component/riding, V)
		if(VRD)
			VRD.force_dismount(M)
		else
			V.unbuckle_mob(M, force = TRUE)
	M.forceMove(src)
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/attackby()
	master.disrupt()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/dummy/chameleon/attack_hand()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_animal()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_slime()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_alien()
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act(S, T)
	contents_explosion(S, T)
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(mob/user, direction)
	if(isspaceturf(loc) || !direction)
		return //No magical space movement!

	if(can_move < world.time)
		var/amount
		switch(user.bodytemperature)
			if(300 to INFINITY)
				amount = 10
			if(295 to 300)
				amount = 13
			if(280 to 295)
				amount = 16
			if(260 to 280)
				amount = 20
			else
				amount = 25

		can_move = world.time + amount
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	return ..()
