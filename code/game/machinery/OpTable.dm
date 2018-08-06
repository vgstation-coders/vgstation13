/obj/machinery/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0
	throwpass = 1 //so Adjacent passes.
	var/rating = 1 //Use this for upgrades some day

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if (computer)
			break
//	spawn(100) //Wont the MC just call this process() before and at the 10 second mark anyway?
//		process()

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				setDensity(FALSE)
		else
	return

/obj/machinery/optable/blob_act()
	if(prob(75))
		qdel(src)

/obj/machinery/optable/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/machinery/optable/attack_hand(mob/user as mob)
	if (M_HULK in usr.mutations)
		to_chat(usr, text("<span class='notice'>You destroy the table.</span>"))
		visible_message("<span class='warning'>[usr] destroys the operating table!</span>")
		setDensity(FALSE)
		qdel(src)

/obj/machinery/optable/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(!ismob(O)) //humans only
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(!Adjacent(user) || !user.Adjacent(src)) // is the mob too far away from you, or are you too far away from the source
		return
	if(O.locked_to)
		var/datum/locking_category/category = O.locked_to.get_lock_cat_for(O)
		if(!istype(category, /datum/locking_category/buckle/bed/roller))
			return
	else if(O.anchored)
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishigherbeing(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	var/mob/living/L = O
	if(!istype(L)|| L == user)
		return

	L.unlock_from() //We checked above that they can ONLY be buckled to a rollerbed to allow this to happen!
	take_victim(L, user)
	return

/obj/machinery/optable/proc/check_victim()
	if (victim)
		if (victim.loc == src.loc)
			if (victim.lying)
				if (victim.pulse)
					icon_state = "table2-active"
				else
					icon_state = "table2-idle"

				return 1

		victim.reset_view()
		victim = null

	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user as mob)
	if (victim)
		to_chat(user, "<span class='bnotice'>The table is already occupied!</span>")

	C.unlock_from()
	C.forceMove(loc)

	if (C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src

	if (ishuman(C))
		victim = C
		C.resting = 1 //This probably shouldn't be using this variable
		C.update_canmove() //but for as long as it does we're adding sanity to it

	if (C == user)
		user.visible_message("[user] climbs on the operating table.","You climb on the operating table.")
	else
		visible_message("<span class='warning'>[C] has been laid on the operating table by [user].</span>")

	add_fingerprint(user)

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.isUnconscious() || !ishuman(usr) || usr.locked_to || usr.restrained())
		return

	take_victim(usr, usr)

/obj/machinery/optable/attackby(obj/item/weapon/W as obj, mob/living/carbon/user as mob)
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, src, 40))
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			switch(rating)
				if(1)
					new /obj/item/weapon/stock_parts/scanning_module(src.loc)
				if(2)
					new /obj/item/weapon/stock_parts/scanning_module/adv(src.loc)
				if(3)
					new /obj/item/weapon/stock_parts/scanning_module/adv/phasic(src.loc)
			new /obj/structure/table/reinforced(src.loc)
			qdel(src)
		return
	if (istype(W, /obj/item/weapon/grab))
		if(iscarbon(W:affecting))
			take_victim(W:affecting,usr)
			returnToPool(W)
			return
	if(isrobot(user))
		return
	//user.drop_item(W, src.loc) why?

/obj/machinery/optable/npc_tamper_act(mob/living/user)
	//Messages are overridden for this proc
	. = NPC_TAMPER_ACT_NOMSG

	if(!victim)
		return

	var/list/pickable_items = list()

	for(var/obj/item/I in adjacent_atoms(user))
		pickable_items.Add(I)

	if(!pickable_items.len)
		user.visible_message("<span class='notice'>\The [user] tries to think of a way to screw \the [victim] up without any tools nearby, but fails miserably.</span>")
		return

	var/obj/item/tool = pick(pickable_items)

	user.visible_message(pick(
	"<span class='danger'>\The [user] grabs \a nearby [tool] and contemplates using it on \the [victim]!</span>",
	"<span class='danger'>\The [user]'s eyes light up as \he tries to use \the [tool] to operate on \the [victim]</span>",
	"<span class='danger'>\The [user] rubs its hands devilishly and attempts to operate on \the [victim] with \the [tool].</span>"))
	if(isgremlin(user))
		var/mob/living/simple_animal/hostile/gremlin/G = user
		G.stand_still(4)

	global.do_surgery(victim, user, tool)
