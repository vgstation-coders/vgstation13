/obj/structure/centrifuge
	name = "suspicious toilet"
	desc = "This toilet is a cleverly disguised improvised centrifuge."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet11"
	density = 0
	anchored = 1
	var/list/cans = new/list() //These are the empty containers.
	var/obj/item/weapon/reagent_containers/beaker = null // This is the active container

/obj/structure/centrifuge/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It contains [cans.len] empty containers[beaker ? " and an active container!" : "."]</span>")

/obj/structure/centrifuge/attackby(obj/item/weapon/reagent_containers/W as obj, mob/user as mob)
	if(iscrowbar(W))
		var/obj/structure/toilet/T = new /obj/structure/toilet(src.loc)
		T.open = 1
		T.cistern = 1
		T.dir = src.dir
		T.update_icon()
		new /obj/item/stack/rods(get_turf(src), 2)
		to_chat(user, "<span class='notice'>You pry out the rods, destroying the filter.</span>")
		qdel(src)
	if(W.is_open_container())
		if(!W.reagents.total_volume)
			if(user.drop_item(W, src))
				cans += W
				to_chat(user, "<span class='notice'>You add a passive container. It now contains [cans.len].</span>")
		else
			if(!beaker)
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You insert an active container.</span>")
					src.beaker =  W
			else
				to_chat(user, "<span class='warning'>There is already an active container.</span>")
		return
	else
		..()

/obj/structure/centrifuge/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(cans.len || beaker)
		for(var/obj/item/O in cans)
			O.forceMove(src.loc)
			cans -= O
		if(beaker)
			detach()
		to_chat(user, "<span class='notice'>You remove everything from the centrifuge.</span>")
	else
		to_chat(user, "<span class='warning'>There is nothing to eject!</span>")

/obj/structure/centrifuge/verb/flush()
	set name = "Flush"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !Adjacent(usr)) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(!cans || !beaker)
		to_chat(usr, "<span class='warning'>\The [src] needs an active container and multiple passive containers to work.</span>")
		return

	add_fingerprint(usr)
	to_chat(usr, "<span class='notice'>\The [src] groans as it spits out containers.</span>")
	while(cans.len>0 && beaker.reagents.reagent_list.len>0)
		var/obj/item/weapon/reagent_containers/C = cans[1]
		var/datum/reagent/R = beaker.reagents.reagent_list[1]
		beaker.reagents.trans_id_to(C,R.id,50)
		C.forceMove(src.loc)
		cans -= C
	if(!cans.len&&beaker.reagents.reagent_list.len)
		to_chat(usr, "<span class='warning'>With no remaining containers, the rest of the concoction swirls down the drain...</span>")
		beaker.reagents.clear_reagents()
	if(!beaker.reagents.reagent_list.len)
		to_chat(usr, "<span class='notice'>The now-empty active container plops out.</span>")
		detach()
		return

/obj/structure/centrifuge/AltClick()
	if(Adjacent(usr)) //Further sanity in the verb itself
		flush()
		return
	return ..()

/obj/structure/centrifuge/proc/detach()
	if(beaker)
		beaker.forceMove(src.loc)
		beaker = null
		return
