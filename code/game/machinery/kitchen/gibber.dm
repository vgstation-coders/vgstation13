
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/occupant // Mob who has been put inside
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
obj/machinery/gibber/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/gibber,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high
	)

	RefreshParts()

/obj/machinery/gibber/attack_ghost(mob/dead/observer/user as mob)
	to_chat(user, "<span class='warning'>You can't do that while dead.</span>")
	return

/obj/machinery/gibber/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(operating)
		to_chat(user, "<span class='notice'>[src] is currently gibbing something!</span>")
		return

	..()
	if(istype(O,/obj/item/weapon/grab))
		return handleGrab(O,user)
	else
		to_chat(user, "<span class='warning'>This item is not suitable for the gibber!</span>")

/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays.len = 0
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] is locked and running</span>")
		return
	if(!(src.occupant))
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	else
		src.startgibbing(user)

// OLD /obj/machinery/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
/obj/machinery/gibber/proc/handleGrab(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
		return
	if(src.occupant)
		to_chat(user, "<span class='warning'>[src] is full! Empty it first.</span>")
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		to_chat(user, "<span class='warning'>This item is not suitable for [src]!</span>")
		return
	if(G.affecting.abiotic(1))
		to_chat(user, "<span class='warning'>Subject may not have abiotic items on.</span>")
		return

	user.visible_message("<span class='warning'>[user] starts to put [G.affecting] into the gibber!</span>", \
		drugged_message = "<span class='warning'>[user] starts dancing with [G.affecting] near the gibber!</span>")
	src.add_fingerprint(user)
	if(do_after(user, src, 30) && G && G.affecting && !occupant)
		user.visible_message("<span class='warning'>[user] stuffs [G.affecting] into the gibber!</span>", \
			drugged_message = "<span class='warning'>[G.affecting] suddenly disappears! How did \he do that?</span>")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.forceMove(src)
		src.occupant = M
		returnToPool(G)
		update_icon()

/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user)
	if(target != user || !istype(user, /mob/living/carbon/human) || user.incapacitated() || get_dist(user, src) > 1)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
		return
	if(src.occupant)
		to_chat(user, "<span class='warning'>[src] is full! Empty it first.</span>")
		return
	if(user.abiotic(1))
		to_chat(user, "<span class='warning'>Subject may not have abiotic items on.</span>")
		return

	src.add_fingerprint(user)

	user.visible_message("<span class='warning'>[user] starts climbing into the [src].</span>", \
		"<span class='warning'>You start climbing into the [src].</span>", \
		drugged_message = "<span class='warning'>[user] starts dancing like a ballerina!</span>")

	if(do_after(user, src, 30) && user && !occupant && !isnull(src.loc))

		user.visible_message("<span class='warning'>[user] climbs into the [src]</span>", \
			"<span class='warning'>You climb into the [src].</span>", \
			drugged_message = "<span class='warning'>[src] consumes [user]!</span>")

		if(user.client)
			user.client.perspective = EYE_PERSPECTIVE
			user.client.eye = src
		user.forceMove(src)
		src.occupant = user
		update_icon()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant)
		return
	for (var/atom/movable/x in src.contents)
		if(x in component_parts)
			continue
		x.forceMove(src.loc)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.forceMove(src.loc)
	src.occupant = null
	update_icon()
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("<span class='warning'>You hear a loud metallic grinding sound.</span>", \
			drugged_message = "<span class='warning'>You faintly hear a guitar solo.</span>")
		return
	use_power(1000)
	visible_message("<span class='warning'>You hear a loud squelchy grinding sound.</span>", \
		drugged_message = "<span class='warning'>You hear a band performance.</span>")
	src.operating = 1
	update_icon()
	var/sourcenutriment = src.occupant.nutrition / 15
	var/sourcetotalreagents

	if(src.occupant.reagents)
		sourcetotalreagents = src.occupant.reagents.total_volume

	var/totalslabs = src.occupant.size

	var/obj/item/weapon/reagent_containers/food/snacks/meat/allmeat[totalslabs]
	for (var/i=1 to totalslabs)
		var/obj/item/weapon/newmeat
		if(istype(occupant.meat_type, /obj/item/weapon/reagent_containers))
			newmeat = new occupant.meat_type(null, occupant)
			newmeat.reagents.add_reagent (NUTRIMENT, sourcenutriment / totalslabs) // Thehehe. Fat guys go first
		else
			newmeat = new occupant.meat_type()

		if(src.occupant.reagents)
			src.occupant.reagents.trans_to (newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the

		allmeat[i] = newmeat

	src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <B>[key_name(user)]</B>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Gibbed <B>[key_name(src.occupant)]</B>"
	log_attack("<B>[key_name(user)]</B> gibbed <B>[key_name(src.occupant)]</B>")

	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user

	src.occupant.death(1)
	src.occupant.ghostize(0)

	qdel(src.occupant)
	src.occupant = null

	spawn(src.gibtime)
		operating = 0
		for (var/i=1 to totalslabs)
			var/obj/item/meatslab = allmeat[i]
			var/turf/Tx = locate(src.x - i, src.y, src.z)
			meatslab.forceMove(src.loc)
			meatslab.throw_at(Tx,i,3)
			if (!Tx.density)
				var/obj/effect/decal/cleanable/blood/gibs/O = getFromPool(/obj/effect/decal/cleanable/blood/gibs, Tx)
				O.New(Tx,i)
		src.operating = 0
		update_icon()



//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	name = "autogibber"
	desc = "Keep far, far away."
	icon_state = "autogibber"

/obj/machinery/gibber/autogibber/New()
	..()
	overlays = null

/obj/machinery/gibber/autogibber/attack_hand(mob/user as mob)
	Bumped(user)

/obj/machinery/gibber/autogibber/attackby(var/obj/item/O as obj, var/mob/user as mob)
	Bumped(user)

/obj/machinery/gibber/autogibber/Bumped(var/atom/A)
	if(stat & (BROKEN | NOPOWER))
		return
	use_power(100)
	if(isliving(A))
		var/mob/living/M = A
		M.visible_message("<span class='warning'>[M] is forcefully sucked into \the [src]!</span>", \
			drugged_message = "<span class='warning'>[M] suddenly vanishes! How did \he do that?</span>")
		M.forceMove(src)
		startautogibbing(M)

/obj/machinery/gibber/autogibber/proc/startautogibbing(mob/living/victim as mob)
	if(!victim)
		visible_message("<span class='warning'>You hear a loud metallic grinding sound.</span>", \
			drugged_message = "<span class='warning'>You faintly hear a guitar solo.</span>")
		return
	use_power(1000)
	visible_message("<span class='warning'>You hear a loud squelchy grinding sound.</span>", \
		drugged_message = "<span class='warning'>You hear a band performance.</span>")
	var/sourcenutriment = victim.nutrition / 15
	var/sourcetotalreagents
	if(victim.reagents)
		sourcetotalreagents = victim.reagents.total_volume

	var/totalslabs = victim.size

	var/obj/item/weapon/reagent_containers/food/snacks/meat/allmeat[totalslabs]
	for (var/i=1 to totalslabs)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/newmeat = null
		if(istype(victim, /mob/living/carbon/human))
			newmeat = new victim.meat_type(src, victim)
		else
			newmeat = victim.drop_meat(src)

		if(newmeat==null)
			return

		newmeat.reagents.add_reagent (NUTRIMENT, sourcenutriment / totalslabs) // Thehehe. Fat guys go first

		if(victim.reagents)
			victim.reagents.trans_to (newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from them

		allmeat[i] = newmeat

	victim.attack_log += "\[[time_stamp()]\] Was auto-gibbed by <B>[src]</B>" //One shall not simply gib a mob unnoticed!
	log_attack("<B>[src]</B> auto-gibbed <B>[key_name(victim)]</B>")
	victim.death(1)
	if(ishuman(victim) || ismonkey(victim) || isalien(victim))
		var/obj/item/organ/internal/brain/B = new(src.loc)
		B.transfer_identity(victim)
		var/turf/Tx = locate(src.x - 2, src.y, src.z)
		B.forceMove(src.loc)
		B.throw_at(Tx,2,3)
		if(isalien(victim))
			var/obj/effect/decal/cleanable/blood/gibs/xeno/O = getFromPool(/obj/effect/decal/cleanable/blood/gibs/xeno, Tx)
			O.New(Tx,2)
		else
			var/obj/effect/decal/cleanable/blood/gibs/O = getFromPool(/obj/effect/decal/cleanable/blood/gibs, Tx)
			O.New(Tx,2)
	else
		victim.ghostize(0)
	qdel(victim)
	playsound(src, 'sound/effects/gib2.ogg', 50, 1)
	for (var/i=1 to totalslabs)
		var/obj/item/meatslab = allmeat[i]
		var/turf/Tx = locate(src.x - i, src.y, src.z)
		meatslab.forceMove(src.loc)
		meatslab.throw_at(Tx,i,3)
		if (!Tx.density)
			var/obj/effect/decal/cleanable/blood/gibs/O = getFromPool(/obj/effect/decal/cleanable/blood/gibs, Tx)
			O.New(Tx,i)

/obj/machinery/gibber/npc_tamper_act(mob/living/L)
	attack_hand(L)