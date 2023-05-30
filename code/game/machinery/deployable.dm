/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = FALSE
	density = TRUE
	icon_state = "barrier0"
	pass_flags_self = PASSTABLE
	health = 140
	maxHealth = 140
	on_armory_manifest = TRUE

	machine_flags = EMAGGABLE

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/deployable/barrier/New()
	..()
	update_icon()

/obj/machinery/deployable/barrier/update_icon()
	icon_state = "barrier[anchored]"

/obj/machinery/deployable/barrier/emag_act(var/mob/user)
	if (!emagged)
		emagged = TRUE
		req_access = 0
		if(user)
			to_chat(user, "You break the ID authentication lock on \the [src].")
		spark(src, 2)

/obj/machinery/deployable/barrier/examine(var/mob/user)
	..()
	if(emagged)
		to_chat(user, "<span class='warning'>It seems to be malfunctioning.</span>")

/obj/machinery/deployable/barrier/attackby(var/obj/item/weapon/W, var/mob/user)
	if(isID(W) || isPDA(W) || isRoboID(W))
		if(!isrobot(user))
			if(!allowed(user))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return
		anchored = !anchored
		update_icon()
		if (anchored)
			to_chat(user, "Barrier lock toggled on.")
		else
			to_chat(user, "Barrier lock toggled off.")
	else
		. = ..()
		if(.)
			return
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")
		user.delayNextAttack(1 SECONDS)
		user.do_attack_animation(src, user)
		take_damage(W.force, damage_type = W.damtype)

/obj/machinery/deployable/barrier/bullet_act(var/obj/item/projectile/Proj)
	. = ..()
	if(Proj.damage)
		take_damage(Proj.damage, damage_type = Proj.damage_type)

/obj/machinery/deployable/barrier/ex_act(var/severity)
	switch(severity)
		if(1)
			explode()
		if(2)
			take_damage(25)

/obj/machinery/deployable/barrier/emp_act(var/severity)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	if(prob(50/severity))
		anchored = !anchored
		icon_state = "barrier[anchored]"

/obj/machinery/deployable/barrier/blob_act()
	take_damage(25)

/obj/machinery/deployable/barrier/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return 1
	else
		return 0

/obj/machinery/deployable/barrier/proc/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>")
	spark(src)
	explosion(loc,-1,-1,0)
	qdel(src)

/obj/machinery/deployable/barrier/take_damage(incoming_damage, damage_type = BRUTE, skip_break, mute) //Custom take_damage() proc because of unimplemented general object damage resistances.
	var/modifier = 1
	if(damage_type == BRUTE)
		modifier = 0.75
	health -= incoming_damage * modifier
	try_break()

/obj/machinery/deployable/barrier/try_break()
	if(health <= 0)
		explode()
