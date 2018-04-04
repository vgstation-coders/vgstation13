//Construction handled in code/game/machinery/constructable_frame.dm

/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox20"
	desc = "A display case for prized possessions. It tempts you to kick it."
	density = 1
	anchored = 1
	var/health = 30
	var/obj/item/occupant = null
	var/destroyed = 0
	var/locked = 0
	var/ue=null
	var/image/occupant_overlay=null
	var/obj/item/weapon/circuitboard/airlock/circuit

/obj/structure/displaycase/Destroy()
	..()
	if(circuit)
		qdel(circuit)
		circuit = null
	dump()

/obj/structure/displaycase/captains_laser/New()
	..()
	occupant=new /obj/item/weapon/gun/energy/laser/captain(src)
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/gooncode/New()
	..()
	occupant=new /obj/item/toy/gooncode(src)
	desc = "The glass is cracked and there are traces of something leaking out."
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/lamarr/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY && prob(50))
		occupant=new /obj/item/clothing/shoes/magboots/funk(src)
	else
		occupant=new /obj/item/clothing/mask/facehugger/lamarr(src)
	locked=1
	req_access=list(access_rd)
	update_icon()

/obj/structure/displaycase/examine(mob/user)
	..()
	var/msg = "<span class='info'>Peering through the glass, you see that it contains:</span>"
	if(occupant)
		msg+= "[bicon(occupant)] <span class='notice'>\A [occupant]</span>"
	else
		msg+= "Nothing."
	to_chat(user, msg)

/obj/structure/displaycase/proc/dump()
	if(occupant)
		occupant.forceMove(get_turf(src))
		occupant=null
	occupant_overlay=null
	update_icon()

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			getFromPool(/obj/item/weapon/shard, loc)
			if (occupant)
				dump()
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/displaycase/blob_act()
	if (prob(75))
		getFromPool(/obj/item/weapon/shard, loc)
		if(occupant)
			dump()
		qdel(src)

/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			setDensity(FALSE)
			src.destroyed = 1
			getFromPool(/obj/item/weapon/shard, loc)
			playsound(src, "shatter", 70, 1)
			update_icon()
	else
		playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassbox2b"
	else
		src.icon_state = "glassbox2[locked]"
	overlays.len = 0
	if(occupant)
		var/icon/occupant_icon=getFlatIcon(occupant)
		occupant_icon.Scale(19,19)
		occupant_overlay = image(occupant_icon)
		occupant_overlay.pixel_x= 8 * PIXEL_MULTIPLIER
		occupant_overlay.pixel_y= 8 * PIXEL_MULTIPLIER
		if(locked)
			occupant_overlay.alpha=128//ChangeOpacity(0.5)
		//underlays += occupant_overlay
		overlays += occupant_overlay
	return

/obj/structure/displaycase/npc_tamper_act(mob/living/L)
	dump() //Screw fingerprints checking and other crap, gremlin magic

/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I=W
		if(!check_access(I))
			to_chat(user, "<span class='rose'>Access denied.</span>")
			return
		locked = !locked
		if(!locked)
			to_chat(user, "[bicon(src)] <span class='notice'>\The [src] clicks as locks release, and it slowly opens for you.</span>")
		else
			to_chat(user, "[bicon(src)] <span class='notice'>You close \the [src] and swipe your card, locking it.</span>")
		update_icon()
	else if(iscrowbar(W) && (!locked || destroyed))
		user.visible_message("[user.name] pries \the [src] apart.", \
			"You pry \the [src] apart.", \
			"You hear something pop.")
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		dump()

		var/obj/item/weapon/circuitboard/airlock/C = circuit
		if(!C)
			C = new (src)
			C.installed = 1
		C.one_access=!(req_access && req_access.len>0)
		if(!C.one_access)
			C.conf_access=req_access
		else
			C.conf_access=req_one_access

		if(!destroyed)
			var /obj/machinery/constructable_frame/machine_frame/new_machine_frame = new(get_turf(src))
			new_machine_frame.build_path = 1
			new_machine_frame.build_state = 2
			new_machine_frame.circuit = C
			C.forceMove(new_machine_frame)
			circuit = null
			C = null
			new_machine_frame.icon_state="box_glass_circuit"
		else
			C.forceMove(get_turf(src))
			C.installed = 0
			new /obj/machinery/constructable_frame/machine_frame(get_turf(src))
		qdel(src)
		return

	else if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		src.health -= W.force
		src.healthcheck()
		..()
	else
		if(locked)
			to_chat(user, "<span class='rose'>It's locked, you can't put anything into it.</span>")
		else if(!occupant)
			if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You insert \the [W] into \the [src], and it floats as the hoverfield activates.</span>")
				occupant=W
				update_icon()

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/proc/getPrint(mob/user as mob)
	return md5(user:dna:uni_identity)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if (destroyed)
		if(occupant)
			dump()
			to_chat(user, "<span class='danger'>You smash your fist into the delicate electronics at the bottom of the case, and deactivate the hoverfield permanently.</span>")
			src.add_fingerprint(user)
			update_icon()
	else
		if(user.a_intent == I_HURT)
			user.delayNextAttack(8)
			user.visible_message("<span class='danger'>[user.name] kicks \the [src]!</span>", \
				"<span class='danger'>You kick \the [src]!</span>", \
				"You hear glass crack.")
			src.health -= 2
			healthcheck()
		else if(!locked)
			if(ishuman(user))
				if(!ue)
					to_chat(user, "<span class='notice'>You press your thumb against the fingerprint scanner, registering your identity with the case.</span>")
					ue = getPrint(user)
					return
				if(ue!=getPrint(user))
					to_chat(user, "<span class='rose'>Access denied.</span>")
					return

				to_chat(user, "<span class='notice'>You press your thumb against the fingerprint scanner, and deactivate the hoverfield built into the case.</span>")
				if(occupant)
					dump()
				else
					to_chat(src, "[bicon(src)] <span class='rose'>\The [src] is empty!</span>")
		else
			user.delayNextAttack(10) // prevent spam
			user.visible_message("[user.name] gently runs their hands over \the [src] in appreciation of its contents.", \
				"You gently run your hands over \the [src] in appreciation of its contents.", \
				"You hear someone streaking glass with their greasy hands.")

/obj/structure/displaycase/acidable()
	return 0


/obj/structure/displaycase/broken
	name = "broken display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox2b"
	desc = "A display case for prized possessions. It seems to be broken."
	density = 0
	health = 0
	destroyed = 1
