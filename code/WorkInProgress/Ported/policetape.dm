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
	var/robot_compatibility

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
	robot_compatibility = MODULE_CAN_LIFT_SECTAPE

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
	robot_compatibility = MODULE_CAN_LIFT_ENGITAPE

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
	robot_compatibility = MODULE_CAN_LIFT_ENGITAPE

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

/obj/item/tape/attack_robot(mob/user)
	if(Adjacent(user))
		return attack_hand(user)

/obj/item/tape/allowed(mob/user)
	if(isrobot(user) && !isMoMMI(user))
		var/mob/living/silicon/robot/R = user
		return HAS_MODULE_QUIRK(R, robot_compatibility)

	return ..()

/obj/item/tape/attack_paw(mob/user as mob)
	breaktape(null,user, TRUE)

/obj/item/tape/attack_animal(var/mob/living/L)
	if(istype(L, /mob/living/simple_animal))
		var/mob/living/simple_animal/SA = L
		if(SA.melee_damage_lower < 5)
			return
	breaktape(null,L, TRUE)

/obj/item/tape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob, var/override = FALSE)
	if(!override && user.a_intent == I_HELP && (!W || !W.is_sharp()) && !src.allowed(user))
		to_chat(user, "<span class='notice'>You can't break [src] [W ? "with \the [W] " : ""]unless you use force.</span>")
		return

	if (!destroy_tape(user, W)) // If we could destroy the tape or not.
		user.visible_message("<span class='warning'>[user] fails to break [src]!</span>")
		return FALSE

	user.visible_message("<span class='warning'>[user] breaks [src]!</span>")
	qdel(src)

/obj/item/tape/proc/destroy_tape(var/mob/user, var/obj/item/weapon/W)
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

	return TRUE

// Syndie tapes

// -- /taperoll/syndie = contains all the things dealing with charges

/obj/item/taperoll/syndie
	var/charges_left = 3

/obj/item/taperoll/syndie/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	icon_base = "police"
	tape_type = /obj/item/tape/police/syndie

/obj/item/taperoll/syndie/atmos
	name = "atmospherics tape"
	desc = "A roll of atmospherics tape used to block off working areas from the public."
	icon_state = "atmos_start"
	icon_base = "atmos"
	tape_type = /obj/item/tape/atmos/syndie
	siemens_coefficient = 1

/obj/item/taperoll/syndie/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	icon_base = "engineering"
	tape_type = /obj/item/tape/engineering/syndie

/obj/item/taperoll/syndie/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (charges_left & (istype(target, /obj/machinery/door/airlock) || istype(target, /obj/machinery/door/firedoor)))
		charges_left--
		if (!(charges_left))
			to_chat(user, "<span class = 'warning'>There is no tape left.</span>")
			qdel(src)
			return TRUE
		to_chat(user, "<span class = 'notice'>There [charges_left > 1 ? "are" : "is"] [charges_left] roll[charges_left > 1 ? "s" : ""] of tape left.</span>")
	. = ..()

/obj/item/taperoll/syndie/afterattack(var/atom/A, mob/user, proximity_flag)
	if (!charges_left)
		to_chat(user, "<span class = 'warning'>There is no tape left.</span>")
		qdel(src)

/obj/item/taperoll/syndie/attack_self(var/mob/user)
	if (charges_left)
		..()
		if (icon_state == "[icon_base]_start")
			charges_left--
			if (!charges_left)
				to_chat(user, "<span class = 'warning'>There is no tape left.</span>")
				qdel(src)
				return
			to_chat(user, "<span class = 'notice'>There [charges_left > 1 ? "are" : "is"] [charges_left] roll[charges_left > 1 ? "s" : ""] of tape left.</span>")
	else
		to_chat(user, "<span class = 'warning'>There is no tape left.</span>")
		qdel(src)

// -- Syndie police tape : it cuffs people attempting to attack it. It's also unbreakable by simple mobs.

/obj/item/tape/police/syndie/destroy_tape(var/mob/user, var/obj/item/weapon/W)
	if (istype(W))
		if (!W.is_sharp() || !(W.force >= 10))
			to_chat(user, "<span class='warning'>The tape resists your attack!")
			return FALSE
		return ..() // We could destroy it
	else // Attacks with bare hands, cuffs himself on it
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.has_organ_for_slot(slot_handcuffed))
				H.visible_message("<span class='danger'>[H] wraps \his hands on the tape!</span>", "<span class='danger'>The tape wraps itself on your hands!</span>")
				var/obj/item/taperoll/police/cuffs
				cuffs = new(get_turf(src))
				cuffs.on_restraint_apply(H)
				H.put_in_hands(cuffs) // Unlike normal cuffs, those cuffs don't transfer from one inventory to another. We need to place them in an inventory first for the icon to show.
				H.equip_to_slot(cuffs, slot_handcuffed)
		return FALSE


/obj/item/tape/police/syndie/examine(mob/user)
	. = ..()
	if (get_dist(user, src) < 3)
		to_chat(user, "<span class = 'warning'>This one looks heavier than the usual.</span>")

// -- Syndie engie tape : shocks and sparks you (useful for lighting those plasma fires)

/obj/item/tape/engineering/syndie
	var/charged = TRUE
	siemens_coefficient = 1

/obj/item/tape/engineering/syndie/destroy_tape(var/mob/user)
	if (spark_and_shock(user)) // If you were shocked, you couldn't destroy the tape !
		return FALSE
	return ..()

/obj/item/tape/engineering/syndie/proc/spark_and_shock(var/mob/user)
	if (user && charged)
		spark(src, 5)
		return shock(user, 50)
	else // No user, or not charged
		return FALSE

/obj/item/tape/engineering/syndie/proc/shock(var/mob/user, var/damage)
	if (!istype(user, /mob/living))
		return FALSE
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.get_item_by_slot(slot_gloves)
		if(G & G.siemens_coefficient == 0)
			return FALSE

	var/mob/living/L = user
	return L.electrocute_act(damage, src)

/obj/item/tape/engineering/syndie/examine(mob/user)
	. = ..()
	if (get_dist(user, src) < 3 && charged)
		to_chat(user, "<span class = 'warning'>The reflective strips on it seem strangely active, somehow.</span>")

/obj/item/tape/engineering/syndie/emp_act(severity)
	charged = FALSE
	spark(src, 5)

// Atmos syndie tape : hard to break and cut off your hands

/obj/item/tape/atmos/syndie/destroy_tape(var/mob/user, var/obj/item/weapon/W)
	if (!W)
		if (istype(user, /mob/living))
			var/mob/living/L = user
			if(ishuman(L))
				to_chat(L, "<span class='danger'>You cut your hand on the tape!")
				var/datum/organ/external/active_hand = L.get_active_hand_organ()
				active_hand.droplimb(1)
			else
				to_chat(L, "<span class='danger'>You cut yourself on the tape!")
			L.audible_scream()
			L.adjustBruteLoss(10)
		return FALSE
	if (!W.is_sharp() || !(W.force >= 10))
		to_chat(user, "<span class='warning'>The tape resists your attack!")
		return FALSE

	return ..()

/obj/item/tape/atmos/syndie/examine(mob/user)
	. = ..()
	if (get_dist(user, src) < 3)
		to_chat(user, "<span class = 'warning'>This one looks much sharper than the usual.</span>")
