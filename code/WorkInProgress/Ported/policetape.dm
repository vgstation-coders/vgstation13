//Define all tape types in policetape.dm
/obj/item/taperoll
	name = "tape roll"
	icon = 'icons/policetape.dmi'
	icon_state = "rollstart"
	flags = FPRINT
	w_class = W_CLASS_TINY
	restraint_resist_time = 20 SECONDS
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/tape
	var/icon_base

/obj/item/tape
	name = "tape"
	icon = 'icons/policetape.dmi'
	anchored = 1
	density = 1
	var/icon_base

/obj/item/taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/tape/police
	icon_base = "police"

/obj/item/tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(access_security)
	icon_base = "police"

/obj/item/taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/tape/engineering
	icon_base = "engineering"

/obj/item/tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_one_access = list(access_engine,access_atmospherics)
	icon_base = "engineering"

/obj/item/taperoll/atmos
	name = "atmospherics tape"
	desc = "A roll of atmospherics tape used to block off working areas from the public."
	icon_state = "atmos_start"
	tape_type = /obj/item/tape/atmos
	icon_base = "atmos"

/obj/item/tape/atmos
	name = "atmospherics tape"
	desc = "A length of atmospherics tape. Better not cross it."
	req_one_access = list(access_engine,access_atmospherics)
	icon_base = "atmos"

/obj/item/taperoll/attack_self(mob/user as mob)
	if(icon_state == "[icon_base]_start")
		start = get_turf(src)
		if(istype(start,/turf/space))
			to_chat(usr, "<span class='warning'>You can't place [src] in space</span>")
			return
		to_chat(usr, "<span class='notice'>You place the first end of [src].</span>")
		icon_state = "[icon_base]_stop"
	else
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(istype(end,/turf/space))
			to_chat(usr, "<span class='warning'>You can't place [src] in space</span>")
			return
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(usr, "<span class='notice'>[src] can only be laid in a straight line.</span>")
			return

		var/turf/cur = start
		var/dir
		if (start.x == end.x)
			var/d = end.y-start.y
			if(d)
				d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d)
				d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		var/can_place = 1
		while (cur!=end && can_place)
			if(cur.density == 1)
				can_place = 0
			else
				for(var/obj/O in cur)
					if(!istype(O, /obj/item/tape) && O.density)
						can_place = 0
						break
			cur = get_step_towards(cur,end)
		if (!can_place)
			to_chat(usr, "<span class='warning'>You can't run [src] through that!</span>")
			return

		cur = start
		var/tapetest = 0
		while (cur!=end)
			for(var/obj/item/tape/Ptest in cur)
				if(Ptest.icon_state == "[Ptest.icon_base]_[dir]")
					tapetest = 1
			if(tapetest != 1)
				var/obj/item/tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
		to_chat(usr, "<span class='notice'>You finish placing [src].</span>")
		user.visible_message("<span class='warning'>[user] finishes placing [src].</span>") //Now you know who to whack with a stun baton

/obj/item/taperoll/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(istype(target, /obj/machinery/door/airlock) || istype(target, /obj/machinery/door/firedoor))
		var/turf = get_turf(target)

		if(locate(tape_type) in turf)
			to_chat(user, "<span class='warning'>There's some tape already!</span>")
			return 1

		to_chat(user, "<span class='notice'>You start placing [src].</span>")
		if(!do_mob(user, target, 3 SECONDS))
			return 1

		if(locate(tape_type) in turf)
			to_chat(user, "<span class='warning'>There's some tape already!</span>")
			return 1

		var/atom/tape = new tape_type(turf)
		tape.icon_state = "[icon_base]_door"
		tape.layer = ABOVE_DOOR_LAYER

		to_chat(user, "<span class='notice'>You placed [src].</span>")
		return 1

/obj/item/tape/Bumped(M as mob)
	if(src.allowed(M))
		var/turf/T = get_turf(src)
		for(var/atom/A in T) //Check to see if there's anything solid on the tape's turf (it's possible to build on it)
			if(A.density)
				return
		M:forceMove(T)

/obj/item/tape/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(!density)
		return 1
	if(air_group || (height == 0))
		return 1
	if((mover.checkpass(PASSGLASS) || istype(mover, /obj/item/projectile/meteor) || mover.throwing == 1))
		return 1
	else
		return 0

/obj/item/tape/attackby(obj/item/weapon/W as obj, mob/user as mob)
	breaktape(W, user)

/obj/item/tape/attack_hand(mob/user as mob)
	if (user.a_intent == I_HELP && src.allowed(user))
		if(density == 0)
			user.visible_message("<span class='notice'>[user] pulls [src] back down.</span>")
			src.setDensity(TRUE)
		else
			user.visible_message("<span class='notice'>[user] lifts [src], allowing passage.</span>")
			setDensity(FALSE)
	else
		if(density == 0) //You can pass through it, moron
			return
		breaktape(null, user)

/obj/item/tape/attack_paw(mob/user as mob)
	breaktape(/obj/item/weapon/wirecutters,user)

/obj/item/tape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob)
	if(user.a_intent == I_HELP && (!W || !W.is_sharp()) && !src.allowed(user))
		to_chat(user, "<span class='notice'>You can't break [src] [W ? "with \the [W] " : ""]unless you use force.</span>")
		return
	user.visible_message("<span class='warning'>[user] breaks [src]!</span>")

	var/dir[2]
	var/icon_dir = src.icon_state
	if(icon_dir == "[src.icon_base]_h")
		dir[1] = EAST
		dir[2] = WEST
	if(icon_dir == "[src.icon_base]_v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i=1;i<3;i++)
		var/N = 0
		var/turf/cur = get_step(src,dir[i])
		while(N != 1)
			N = 1
			for (var/obj/item/tape/P in cur)
				if(P.icon_state == icon_dir)
					N = 0
					qdel(P)
			cur = get_step(cur,dir[i])

	qdel(src)
	return
