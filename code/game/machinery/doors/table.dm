//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/table
	name = "table door"
	opacity = 0
	animation_delay = 0
	pass_flags_self = PASSTABLE
	layer = TABLE_LAYER
	open_layer = TABLE_LAYER
	throwpass = 1	//You can throw objects over this, despite its density.
	use_power = MACHINE_POWER_USE_NONE
	machine_flags = SCREWTOGGLE
	icon = 'icons/obj/doors/tabledoor.dmi'
	icon_state = "metaldoor_closed"
	prefix = "metal" //Corresponds to the mineral type

	soundeffect = 'sound/effects/wood_door_slam.ogg'
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	sheet_type = /obj/item/stack/sheet/metal

/obj/machinery/door/table/Destroy()
	QDEL_NULL(electronics)
	setDensity(FALSE)
	update_adjacent()
	. = ..()

/obj/machinery/door/table/Bumped(atom/user)
	if(operating)
		return

	if(istype(user, /obj/mecha))
		open()
	else if (istype(user, /obj/machinery/bot) && SpecialAccess(user))
		open()
	else if(ismob(user))
		var/mob/M = user
		if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //This is what we call blind trust
			return
		TryToSwitchState(user)
	return

/obj/machinery/door/table/proc/update_adjacent()
	for(var/direction in cardinal)
		var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
		if(T)
			T.update_icon()

/obj/machinery/door/table/door_animate(animation) // no spritework for it
	return

/obj/machinery/door/table/attack_ai(mob/user as mob) //those aren't really machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && get_dist(user,src) <= 1) //but robots can, not remotely though
		return TryToSwitchState(user) //also >nesting if statements

/obj/machinery/door/table/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/table/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/table/proc/TryToSwitchState(mob/user as mob)
	if(operating)
		return

	if(!user.restrained() && (user.size > SIZE_TINY))
		add_fingerprint(user)
		SwitchState()
	return

/obj/machinery/door/table/proc/SwitchState()
	if(!density)
		return close()
	else
		return open()

/obj/machinery/door/table/proc/dismantle()
	if (electronics)
		electronics.forceMove(loc)
		electronics = null
	if(sheet_type)
		new sheet_type(loc)
	qdel(src)

/obj/machinery/door/table/open()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/table/close()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/table/attackby(obj/item/W as obj, mob/user as mob, params)
	if(..())
		return

	if (!electronics)
		if(W.is_wrench(user))
			to_chat(user, "<span class='notice'>Now disassembling [src]...</span>")
			W.playtoolsound(src, 50)
			if(do_after(user, src,50))
				dismantle()

		else if(istype(W,/obj/item/weapon/circuitboard/airlock))
			if(user.drop_item(W,src))
				electronics = W
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You add [electronics] to [src].</span>")

	// Make open doors able to remove circuits
	else if(!density && panel_open && iscrowbar(I) && electronics)
		user.visible_message("[user] is removing [electronics] from [src].", "You start to remove \the [electronics] from [src].")
		I.playtoolsound(src, 100)
		if(do_after(user, src, 40) && src && !density && electronics)
			to_chat(user, "<span class='notice'>You removed [electronics]!</span>")
			electronics.forceMove(loc)
			electronics = null

/obj/machinery/door/table/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		dismantle()
	return ..()

/obj/machinery/door/table/blob_act()
	if(prob(75))
		dismantle()

/obj/machinery/door/table/ex_act(severity)
	switch(severity)
		if(1.0)
			dismantle()
		if(2.0)
			if (prob(50))
				dismantle()
		if(3.0)
			if (prob(25))
				dismantle()

/obj/machinery/door/table/reinforced
	name = "reinforced table door"
	icon_state = "rmetaldoor_closed"
	prefix = "rmetal"
	sheet_type = /obj/item/stack/sheet/plasteel

/obj/machinery/door/table/wood
	name = "wooden table door"
	icon_state = "wooddoor_closed"
	prefix = "wood"
	sheet_type = /obj/item/stack/sheet/wood

/obj/machinery/door/table/glass
	name = "glass table door"
	icon_state = "glassdoor_closed"
	prefix = "glass"
	sheet_type = /obj/item/stack/sheet/glass/rglass

/obj/machinery/door/table/glass/plasma
	name = "plasma glass table door"
	icon_state = "pglassdoor_closed"
	prefix = "pglass"
	sheet_type = /obj/item/stack/sheet/glass/plasmarglass
