/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU | SHUTTLEWRENCH

	use_auto_lights = 1
	light_power_on = 1
	light_range_on = 3

/obj/machinery/computer/cultify()
	new /obj/structure/cult_legacy/tome(loc)
	..()

/obj/machinery/computer/New()
	..()
	if(ticker)
		initialize()

/obj/machinery/computer/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSMACHINE))
		return 1
	return ..()

/obj/machinery/computer/initialize()
	..()
	power_change()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity))
		set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		if(3.0)
			if (prob(25))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		else
	return

/obj/machinery/computer/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage))
		set_broken()
	..()

/obj/machinery/computer/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		if(!(stat & BROKEN))
			shake(1, 3)
			playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
			set_broken()
		return 1
	return 0

/obj/machinery/computer/blob_act()
	if (prob(75))
		for(var/x in verbs)
			verbs -= x
		set_broken()
		setDensity(FALSE)

/obj/machinery/computer/update_icon()
	..()
	icon_state = initial(icon_state)
	// Broken
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]b"

	// Powered
	else if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]0"

/obj/machinery/computer/power_change()
	. = ..()
	update_icon()

/obj/machinery/computer/proc/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/computer/togglePanelOpen(var/obj/toggleitem, mob/user, var/obj/item/weapon/circuitboard/CC = null)
	if(!circuit) //we can't disassemble with no circuit, so add some fucking circuits if you want disassembly
		return
	playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
	user.visible_message(	"[user] begins to unscrew \the [src]'s monitor.",
							"You begin to unscrew the monitor...")
	if (do_after(user, src, 20) && (circuit || CC))
		var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
		if(!CC)
			CC = new circuit( A )
		else
			CC.forceMove(A)
		A.circuit = CC
		A.anchored = 1
		for (var/obj/C in src)
			C.forceMove(src.loc)
		if (src.stat & BROKEN)
			to_chat(user, "<span class='notice'>[bicon(src)] The broken glass falls out.</span>")
			getFromPool(/obj/item/weapon/shard, loc)
			A.state = 3
			A.icon_state = "3"
		else
			to_chat(user, "<span class='notice'>[bicon(src)] You disconnect the monitor.</span>")
			A.state = 4
			A.icon_state = "4"
		circuit = null // Used by the busy check to avoid multiple 'You disconnect the monitor' messages
		qdel(src)
		return 1
	else
		return 1 // Needed, otherwise the computer UI will pop open

	return

/obj/machinery/computer/attackby(I as obj, user as mob)
	if(..(I,user))
		return
	else
		src.attack_hand(user)
	return
