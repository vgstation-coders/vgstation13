/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	anchored = 0
	var/lockedby = ""
	pressure_resistance = 5
	flags = FPRINT  | OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/tmp/lastsound

/obj/structure/mopbucket/New()
	..()
	create_reagents(100)
	mopbucket_list.Add(src)

/obj/structure/mopbucket/Destroy()
	mopbucket_list.Remove(src)
	..()

/obj/structure/mopbucket/attack_hand(mob/user as mob)
	..()
	if(!anchored)
		anchored = 1
		user.visible_message("<span class='notice'>[user] locks [src]'s wheels!</span>")
		lockedby += "\[[time_stamp()]\] [usr] ([usr.ckey]) - locked [src]"
		icon_state = "mopbucket_deploy"
	else
		anchored = 0
		user.visible_message("<span class='notice'>[user] unlocks [src]'s wheels!</span>")
		lockedby += "\[[time_stamp()]\] [usr] ([usr.ckey]) - unlocked [src]"
		icon_state = "mopbucket"

/obj/structure/mopbucket/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/mop))
		return 0
	return ..()

/obj/structure/mopbucket/mop_act(obj/item/weapon/mop/M, mob/user as mob)
	if (istype(M))
		if (M.reagents.total_volume <= 1)
			src.reagents.trans_to(M, 25 - M.reagents.total_volume)
			to_chat(user, "<span class='notice'>You wet [M].</span>")
			if(lastsound + 2 SECONDS < world.time)
				playsound(src, 'sound/effects/mopbucket.ogg', 50, 1)
				lastsound = world.time
		else
			var/amount_to_reduce = 100 - reagents.total_volume < M.reagents.total_volume ? 100 - reagents.total_volume : 0
			M.reagents.trans_to(src, M.reagents.total_volume - amount_to_reduce)
			to_chat(user, "<span class='notice'>You wring [M] into [src].</span>")
			if(lastsound + 2 SECONDS < world.time)
				playsound(src, 'sound/effects/mopbucket.ogg', 50, 1)
				lastsound = world.time
	return 1

/obj/structure/mopbucket/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O))
		return
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src))
		return
	if(reagents && reagents.total_volume)
		var/static/list/dump_types = list(/obj/structure/sink,/obj/structure/toilet)
		if(is_type_in_list(O,dump_types))
			reagents.clear_reagents()
			to_chat(user, "<span class='notice'>You empty [src] into [O].</span>")
			if(lastsound + 2 SECONDS < world.time)
				playsound(src, 'sound/effects/slosh.ogg', 50, 1)
				lastsound = world.time
		if(istype(O,/turf/simulated/floor) && O.reagents)
			reagents.trans_to(O)
			to_chat(user, "<span class='notice'>You empty [src] onto [O].</span>")
			if(lastsound + 2 SECONDS < world.time)
				playsound(src, 'sound/effects/slosh.ogg', 50, 1)
				lastsound = world.time


/obj/structure/mopbucket/ex_act(severity)
	switch(severity)
		if(1.0)
			if(reagents && reagents.total_volume && isturf(loc))
				var/turf/T = loc
				if(T.reagents)
					reagents.trans_to(T,reagents.total_volume) // Spill em out
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				if(reagents && reagents.total_volume && isturf(loc))
					var/turf/T = loc
					if(T.reagents)
						reagents.trans_to(T,reagents.total_volume) // Spill em out
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				if(reagents && reagents.total_volume && isturf(loc))
					var/turf/T = loc
					if(T.reagents)
						reagents.trans_to(T,reagents.total_volume) // Spill em out
				qdel(src)
				return
